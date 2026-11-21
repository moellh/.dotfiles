# Local LLMs with llama.cpp

Offline LLMs served by llama.cpp's OpenAI-compatible API on
<http://127.0.0.1:8080> (API and web UI, localhost only). OpenCode reaches it
as `llamacpp/local`, which always means the active profile.

## Profiles

Each model is a profile in `~/.config/llm/profiles/<name>.env` (model file,
its Hugging Face source, GPU headroom, sampling settings from the model card).
The scripts live in `~/.scripts` (`run-llm`, `llm-switch`, `llm-download`), all
of it in the dotfiles.

Not in the dotfiles:

- `~/.local/share/llm/models/` holds the model files (several GB each).
  Override the location with `LLM_HOME`.
- `~/.local/state/llm/active.env` is a symlink to the active profile, so each
  machine picks its own.

| Profile | Model | Notes |
| --- | --- | --- |
| `lfm2.5-8b-a1b` (default) | Liquid AI LFM2.5-8B-A1B Q4_K_M | MoE with 1.5B active params: fastest generation here. Always reasons before answering. Card: good at tool use/agentic work, not for heavy programming. |
| `gemma-4-e4b` | Gemma 4 E4B, unsloth QAT UD-Q4_K_XL | Lowest RAM use. Text only (vision projector not downloaded). |
| `qwen3.5-4b` | Qwen3.5-4B Q4_K_M | Fastest prompt processing, slowest generation. |

```sh
llm-switch                  # list profiles, * marks the active one
llm-switch gemma-4-e4b      # switch; restarts the server if it is running
```

## Setup on a new machine

```sh
llm-download --all          # or: llm-download lfm2.5-8b-a1b
llm-switch lfm2.5-8b-a1b
```

`llm-download` uses the `hf` CLI, or runs it through `uvx` if `hf` isn't
installed. To add a model, write a new profile with `LLAMA_MODEL`,
`LLAMA_HF_REPO` and `LLAMA_HF_FILE`, then run `llm-download <profile>`.

## Run

The user service `llama-local` (in the dotfiles) is deliberately not enabled
at login; start it when needed.

```sh
systemctl --user start llama-local
systemctl --user status llama-local
journalctl --user -u llama-local -f
systemctl --user stop llama-local
```

Manual run of a profile without switching, with overrides:

```sh
LLM_PROFILE=qwen3.5-4b LLAMA_CTX_SIZE=65536 run-llm
```

Environment variables override the profile, which overrides the defaults in
`run-llm`: `LLAMA_CTX_SIZE`, `LLAMA_THREADS`, `LLAMA_FIT_TARGET`,
`LLAMA_DEVICE`, `LLAMA_GPU_LAYERS`, `LLAMA_CACHE_TYPE_K`/`_V`,
`LLAMA_SPEC_TYPE`, `LLAMA_REASONING`, sampling (`LLAMA_TEMPERATURE`,
`LLAMA_TOP_K`, `LLAMA_TOP_P`, `LLAMA_MIN_P`, `LLAMA_PRESENCE_PENALTY`,
`LLAMA_REPEAT_PENALTY`), `LLAMA_PORT`, `LLAMA_MODEL`. Extra llama-server
arguments can be appended.

## OpenCode

The `llamacpp` provider lives in the OpenCode config
(`~/.config/opencode/opencode.json`) with one model, `local`.

- Interactive: start `opencode` and pick "Local llama.cpp (active profile)"
  with `/models`. OpenCode v2's TUI has no `--model` flag.
- One-shot: `opencode run -m llamacpp/local "..."`
- After editing the OpenCode config, run `opencode reload`: the background
  OpenCode server caches config per directory.
- OpenCode's system prompt is ~10K tokens, so the first message of a session
  takes about 2-3 minutes here. Later turns reuse the prompt cache. For plain
  offline chat the llama.cpp web UI at <http://127.0.0.1:8080> is much faster
  to start.

## Hardware and tuning

Laptop: i5-7300HQ (4 cores, AVX2), GTX 1050 2 GiB, 8 GB RAM (one faulty 8 GB
module removed), so models are split between GPU and CPU and the CPU side is
the bottleneck.

- `--device Vulkan1` is the GTX 1050; `Vulkan0` is the much slower Intel iGPU.
- Threads default to 3. With one core busy (e.g. Spotify), 4 threads dropped
  Qwen3.5-4B generation from ~5 to ~2 t/s.
- `--fit` fills VRAM up to `LLAMA_FIT_TARGET` MiB of headroom. Qwen works with
  128 (64 OOMed); LFM2.5 and Gemma 4 need 512 (128 OOMs on Vulkan compute
  buffers).
- K/V caches use Q8 on the GPU: faster than F16 or Q4 here. KV on the CPU and
  MTP speculative decoding were both slower.
- vLLM is not an option: the GTX 1050 (Pascal, sm_61) is unsupported.

## Measured performance

2026-11-21, 3 threads, Spotify running (~1 core busy), 32K context:

| Profile | Generation | Prompt | RAM (RSS) | Word problem | IPv4 validator (11 tests) |
| --- | ---: | ---: | ---: | :---: | :---: |
| lfm2.5-8b-a1b | 10.9-14.7 t/s | 54 t/s | 3.2 GiB | correct | 11/11 |
| gemma-4-e4b | 6.9-7.2 t/s | 78 t/s | 2.1 GiB | wrong | 11/11 |
| qwen3.5-4b | 4.5-4.6 t/s | 93 t/s | 2.7 GiB | wrong | 11/11 |

Earlier Qwen3.5-4B llama-bench runs (prompt / generation t/s): CPU only
21.2 / 5.80; Intel HD 630 10.3 / 2.85; GTX 1050 with Q8 KV 92.2 / 9.89.
