#!/usr/bin/env python3
"""
PDF Reader for Anki Card Generation

Two-pass PDF analysis:
1. Pass 1: Extract structure from text using Ollama model
2. Pass 2: Analyze each page in parallel with vision model

Output: JSON with page-level content and figure detection
"""

import argparse
import json
import os
import subprocess
import sys
import tempfile
import time
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import Optional, Dict, List, Any


class RateLimiter:
    """Semaphore-based rate limiter for concurrent API calls."""
    def __init__(self, max_calls: int):
        self.semaphore = threading.Semaphore(max_calls)
    
    def __enter__(self):
        self.semaphore.acquire()
        return self
    
    def __exit__(self, *args):
        self.semaphore.release()


def check_dependencies() -> bool:
    """Check if required tools are available."""
    missing = []
    
    # Check pdftotext
    try:
        subprocess.run(["pdftotext", "-v"], capture_output=True)
    except FileNotFoundError:
        missing.append("pdftotext (install: apt-get install poppler-utils)")
    
    # Check pdf2image (Python package)
    try:
        from pdf2image import convert_from_path
    except ImportError:
        missing.append("pdf2image (install: pip install pdf2image)")
    
    if missing:
        print("Missing dependencies:")
        for dep in missing:
            print(f"  - {dep}")
        return False
    return True


def extract_all_text(pdf_path: str) -> str:
    """Extract all text from PDF using pdftotext."""
    result = subprocess.run(
        ["pdftotext", "-layout", pdf_path, "-"],
        capture_output=True,
        text=True
    )
    return result.stdout


def extract_text_from_pdf(pdf_path: str) -> List[Dict]:
    """Extract text from each page using pdftotext."""
    pages = []
    
    # Get page count
    result = subprocess.run(
        ["pdfinfo", pdf_path],
        capture_output=True,
        text=True
    )
    
    page_count = 1
    for line in result.stdout.split("\n"):
        if line.startswith("Pages:"):
            page_count = int(line.split(":")[1].strip())
            break
    
    # Extract text per page
    with tempfile.TemporaryDirectory() as tmpdir:
        for page_num in range(1, page_count + 1):
            output_file = os.path.join(tmpdir, f"page_{page_num}.txt")
            
            result = subprocess.run(
                ["pdftotext", "-f", str(page_num), "-l", str(page_num),
                 "-layout", pdf_path, output_file],
                capture_output=True
            )
            
            text = ""
            if os.path.exists(output_file):
                with open(output_file, "r", encoding="utf-8", errors="ignore") as f:
                    text = f.read()
            
            pages.append({
                "num": page_num,
                "text": text.strip(),
                "has_figure": False,
                "figure_desc": "",
                "vision_analysis": "",
                "key_concepts": [],
                "important_details": []
            })
    
    return pages


def render_page_to_image(pdf_path: str, page_num: int, output_path: str) -> bool:
    """Render a single PDF page to image."""
    try:
        from pdf2image import convert_from_path
        
        images = convert_from_path(
            pdf_path,
            first_page=page_num,
            last_page=page_num,
            dpi=200
        )
        
        if images:
            images[0].save(output_path, "PNG")
            return True
    except Exception as e:
        print(f"Error rendering page {page_num}: {e}", file=sys.stderr)
    
    return False


def extract_document_structure(full_text: str, model: str = "kimi-k2.5:cloud") -> Dict:
    """
    Pass 1: Extract document structure using text-only model call.
    
    Returns:
        Dict with title, summary, sections, and key_terms
    """
    prompt = f"""Analyze this lecture document and extract its structure for generating Anki flashcards.

Document text:
{full_text[:30000]}

Provide a JSON response with these fields:
{{
    "title": "Document title (brief)",
    "summary": "One-paragraph summary (~100 words) of the document content",
    "sections": [
        {{
            "name": "Section name",
            "start_page": first_page_number,
            "end_page": last_page_number,
            "key_concepts": ["concept1", "concept2"]
        }}
    ],
    "global_key_terms": {{
        "Term1": "Brief definition",
        "Term2": "Brief definition"
    }}
}}

Focus on:
1. Identifying major sections/topics and their page ranges
2. Extracting key terminology with definitions
3. Creating a coherent summary for context
4. Use page numbers (1-indexed) from the document"""

    try:
        import ollama
        
        response = ollama.chat(
            model=model,
            messages=[{
                "role": "user",
                "content": prompt
            }],
            think=False
        )
        
        content = response.get("message", {}).get("content", "")
        return parse_structure_response(content)
        
    except Exception as e:
        print(f"Warning: Structure extraction failed: {e}", file=sys.stderr)
        return {
            "title": "Unknown",
            "summary": "",
            "sections": [],
            "global_key_terms": {}
        }


def parse_structure_response(response: str) -> Dict:
    """Parse the structure extraction response."""
    import re
    
    try:
        json_match = re.search(r'\{[\s\S]*\}', response)
        if json_match:
            data = json.loads(json_match.group())
            return {
                "title": data.get("title", "Unknown"),
                "summary": data.get("summary", ""),
                "sections": data.get("sections", []),
                "global_key_terms": data.get("global_key_terms", {})
            }
    except json.JSONDecodeError:
        pass
    
    return {
        "title": "Unknown",
        "summary": "",
        "sections": [],
        "global_key_terms": {}
    }


def get_section_for_page(page_num: int, sections: List[Dict]) -> str:
    """Get the section name for a given page number."""
    for section in sections:
        start = section.get("start_page", 0)
        end = section.get("end_page", 0)
        if start <= page_num <= end:
            return section.get("name", "")
    return ""


def analyze_page_with_vision(
    image_path: str,
    document_summary: str,
    section_name: str,
    page_num: int,
    model: str = "kimi-k2.5:cloud",
    rate_limiter: Optional[RateLimiter] = None,
    max_retries: int = 3
) -> Dict:
    """
    Analyze a page image using Ollama vision model.
    
    Args:
        image_path: Path to the page image
        document_summary: Brief summary of the document
        section_name: Current section name
        page_num: Page number for error reporting
        model: Model to use
        rate_limiter: Optional rate limiter for concurrent calls
        max_retries: Maximum retry attempts
    
    Returns:
        Dict with analysis results
    """
    prompt = f"""Analyze this lecture slide for generating Anki flashcards.

Document context:
{document_summary}

Current section: {section_name if section_name else "Unknown"}

Provide a JSON response with these fields:
{{
    "content_summary": "Brief summary of the main topic",
    "key_concepts": ["list of key concepts/terms to make cards about"],
    "has_figure": true/false,
    "figure_description": "Description of any diagrams, charts, tables, or figures (empty if none)",
    "figure_type": "diagram/chart/table/flowchart/equation/none",
    "important_details": ["specific details, formulas, or facts to include in cards"],
    "definitions": ["exact definitions from the slide, preserving precise wording"],
    "algorithms_pseudocode": ["any algorithms, pseudo-code, step-by-step procedures, or protocol sequences shown on this slide — transcribe them fully"],
    "formulas": ["mathematical formulas, equations, or calculations with full notation"],
    "handwritten_annotations": ["any handwritten notes, annotations, or additions visible on the slide that are NOT part of the printed content"]
}}

Focus on:
1. Identify ALL key terms and concepts on this slide
2. Note any figures suitable for image occlusion cards
3. Extract formulas, definitions, and relationships — preserve technical notation exactly
4. CRITICALLY: Capture any algorithms, pseudo-code, or step-by-step procedures in full detail
5. CRITICALLY: Capture exact definitions using the precise wording from the slide
6. Look for handwritten annotations or notes added on top of printed content — these often contain important exam-relevant details
7. Include all relevant details for card generation — quantitative facts (numbers, rates, sizes) are especially important

Be comprehensive - better to extract too much than too little."""

    last_error = None
    for attempt in range(max_retries):
        try:
            import ollama
            
            # Use rate limiter if provided
            if rate_limiter:
                with rate_limiter:
                    response = ollama.chat(
                        model=model,
                        messages=[{
                            "role": "user",
                            "content": prompt,
                            "images": [image_path]
                        }],
                        think=False
                    )
            else:
                response = ollama.chat(
                    model=model,
                    messages=[{
                        "role": "user",
                        "content": prompt,
                        "images": [image_path]
                    }],
                    think=False
                )
            
            content = response.get("message", {}).get("content", "")
            return parse_vision_response(content)
            
        except Exception as e:
            last_error = e
            if attempt < max_retries - 1:
                wait_time = 2 ** attempt  # 1, 2, 4 seconds
                print(f"    Retry {attempt + 1}/{max_retries} for page {page_num} after error: {e}", file=sys.stderr)
                time.sleep(wait_time)
    
    # All retries failed
    print(f"    Failed to analyze page {page_num} after {max_retries} attempts: {last_error}", file=sys.stderr)
    return {
        "content_summary": "",
        "key_concepts": [],
        "has_figure": False,
        "figure_description": "",
        "figure_type": "none",
        "important_details": [],
        "error": str(last_error)
    }


def parse_vision_response(response: str) -> Dict:
    """Parse the vision model response into structured data."""
    import re
    
    try:
        json_match = re.search(r'\{[\s\S]*\}', response)
        if json_match:
            data = json.loads(json_match.group())
            return {
                "content_summary": data.get("content_summary", ""),
                "key_concepts": data.get("key_concepts", []),
                "has_figure": data.get("has_figure", False),
                "figure_description": data.get("figure_description", ""),
                "figure_type": data.get("figure_type", "none"),
                "important_details": data.get("important_details", []),
                "definitions": data.get("definitions", []),
                "algorithms_pseudocode": data.get("algorithms_pseudocode", []),
                "formulas": data.get("formulas", []),
                "handwritten_annotations": data.get("handwritten_annotations", [])
            }
    except json.JSONDecodeError:
        pass

    has_figure = any(kw in response.lower() for kw in
                     ["figure", "diagram", "chart", "table", "graph"])

    return {
        "content_summary": response[:500] if response else "",
        "key_concepts": [],
        "has_figure": has_figure,
        "figure_description": "",
        "figure_type": "none",
        "important_details": [],
        "definitions": [],
        "algorithms_pseudocode": [],
        "formulas": [],
        "handwritten_annotations": []
    }


def process_page_vision(
    page: Dict,
    pdf_path: str,
    tmpdir: str,
    document_summary: str,
    sections: List[Dict],
    model: str,
    rate_limiter: RateLimiter
) -> Dict:
    """Process a single page with vision model (for parallel execution)."""
    page_num = page["num"]
    section_name = get_section_for_page(page_num, sections)
    
    # Render page to image
    image_path = os.path.join(tmpdir, f"page_{page_num}.png")
    
    if not render_page_to_image(pdf_path, page_num, image_path):
        return {
            **page,
            "vision_analysis": "",
            "error": "Failed to render page to image"
        }
    
    # Analyze with vision
    vision_result = analyze_page_with_vision(
        image_path,
        document_summary,
        section_name,
        page_num,
        model,
        rate_limiter
    )
    
    # Merge results
    return {
        **page,
        "vision_analysis": vision_result.get("content_summary", ""),
        "has_figure": vision_result.get("has_figure", False),
        "figure_desc": vision_result.get("figure_description", ""),
        "key_concepts": vision_result.get("key_concepts", []),
        "important_details": vision_result.get("important_details", []),
        "figure_type": vision_result.get("figure_type", "none"),
        "definitions": vision_result.get("definitions", []),
        "algorithms_pseudocode": vision_result.get("algorithms_pseudocode", []),
        "formulas": vision_result.get("formulas", []),
        "handwritten_annotations": vision_result.get("handwritten_annotations", [])
    }


def process_pdf(
    pdf_path: str,
    model: str = "kimi-k2.5:cloud",
    skip_vision: bool = False,
    workers: int = 2,
    skip_structure: bool = False
) -> Dict:
    """
    Process a PDF file with two-pass analysis.
    
    Args:
        pdf_path: Path to PDF file
        model: Ollama model to use
        skip_vision: Skip vision analysis (text-only mode)
        workers: Number of parallel workers for vision analysis
        skip_structure: Skip structure extraction pass
    
    Returns:
        Dict with pages and metadata
    """
    
    if not os.path.exists(pdf_path):
        raise FileNotFoundError(f"PDF not found: {pdf_path}")
    
    print(f"Processing: {pdf_path}")
    
    # Pass 1: Extract text
    print("  Extracting text...", flush=True)
    pages = extract_text_from_pdf(pdf_path)
    
    # Pass 1b: Extract structure from text
    structure = {"summary": "", "sections": [], "global_key_terms": {}}
    if not skip_vision and not skip_structure:
        print("  Extracting document structure...", flush=True)
        full_text = "\n".join(p["text"] for p in pages)
        structure = extract_document_structure(full_text, model)
        
        if structure.get("title"):
            print(f"    Title: {structure['title']}", flush=True)
        if structure.get("summary"):
            print(f"    Summary: {structure['summary'][:100]}...", flush=True)
    
    # Pass 2: Vision analysis (parallel)
    if not skip_vision:
        print(f"  Analyzing {len(pages)} pages with vision model ({workers} workers)...", flush=True)
        
        rate_limiter = RateLimiter(workers)
        results = {}
        
        with tempfile.TemporaryDirectory() as tmpdir:
            with ThreadPoolExecutor(max_workers=workers) as executor:
                # Submit all tasks
                futures = {
                    executor.submit(
                        process_page_vision,
                        page, pdf_path, tmpdir,
                        structure.get("summary", ""),
                        structure.get("sections", []),
                        model,
                        rate_limiter
                    ): page["num"]
                    for page in pages
                }
                
                # Collect results as they complete
                for future in as_completed(futures):
                    page_num = futures[future]
                    try:
                        result = future.result()
                        results[page_num] = result
                        print(f"    Processed page {page_num}/{len(pages)}", flush=True)
                    except Exception as e:
                        print(f"    Error processing page {page_num}: {e}", file=sys.stderr)
                        results[page_num] = {
                            "num": page_num,
                            "text": pages[page_num - 1]["text"],
                            "vision_analysis": "",
                            "error": str(e)
                        }
        
        # Sort by page number
        pages = [results[i] for i in range(1, len(pages) + 1)]
    
    return {
        "source": os.path.basename(pdf_path),
        "title": structure.get("title", ""),
        "summary": structure.get("summary", ""),
        "sections": structure.get("sections", []),
        "global_key_terms": structure.get("global_key_terms", {}),
        "pages": pages,
        "total_pages": len(pages)
    }


def process_text_file(file_path: str) -> Dict:
    """Process a text or markdown file."""
    
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    import re
    sections = re.split(r'\n(?=#{1,3} |#{1,3}$)', content)
    
    pages = []
    for i, section in enumerate(sections, 1):
        pages.append({
            "num": i,
            "text": section.strip(),
            "has_figure": False,
            "figure_desc": "",
            "vision_analysis": "",
            "key_concepts": [],
            "important_details": []
        })
    
    return {
        "source": os.path.basename(file_path),
        "title": "",
        "summary": "",
        "sections": [],
        "global_key_terms": {},
        "pages": pages,
        "total_pages": len(pages)
    }


def get_default_output_path(input_path: str) -> str:
    """Generate default output path based on input file."""
    path = Path(input_path)
    return str(path.parent / f"{path.stem}_analysis.json")


def main():
    parser = argparse.ArgumentParser(
        description="Process PDFs and text files for Anki card generation"
    )
    parser.add_argument(
        "files",
        nargs="+",
        help="PDF or text files to process"
    )
    parser.add_argument(
        "-m", "--model",
        default="kimi-k2.5:cloud",
        help="Ollama model (default: kimi-k2.5:cloud)"
    )
    parser.add_argument(
        "-o", "--output",
        help="Output JSON file (default: <input>_analysis.json)"
    )
    parser.add_argument(
        "-w", "--workers",
        type=int,
        default=2,
        help="Number of parallel workers for vision analysis (default: 2)"
    )
    parser.add_argument(
        "--text-only",
        action="store_true",
        help="Skip vision analysis, extract text only"
    )
    parser.add_argument(
        "--skip-structure",
        action="store_true",
        help="Skip structure extraction pass (faster, less context)"
    )
    parser.add_argument(
        "--check-deps",
        action="store_true",
        help="Check dependencies and exit"
    )
    
    args = parser.parse_args()
    
    if args.check_deps:
        sys.exit(0 if check_dependencies() else 1)
    
    if not args.files:
        parser.error("No files provided. Use --check-deps to verify dependencies.")
    
    if not check_dependencies():
        print("Run with --check-deps for installation instructions")
        sys.exit(1)
    
    results = []
    for file_path in args.files:
        ext = Path(file_path).suffix.lower()
        
        if ext == ".pdf":
            result = process_pdf(
                file_path,
                model=args.model,
                skip_vision=args.text_only,
                workers=args.workers,
                skip_structure=args.skip_structure
            )
        elif ext in [".txt", ".md"]:
            result = process_text_file(file_path)
        else:
            print(f"Skipping unsupported file: {file_path}", file=sys.stderr)
            continue
        
        results.append(result)
    
    output = json.dumps(results, indent=2)
    
    # Determine output path
    output_path = args.output
    if not output_path and args.files:
        output_path = get_default_output_path(args.files[0])
    
    if output_path:
        with open(output_path, "w") as f:
            f.write(output)
        print(f"Output written to: {output_path}")
    else:
        print(output)


if __name__ == "__main__":
    main()