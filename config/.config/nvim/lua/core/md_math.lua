-- Last modified: 2026-11-23

-- Description: LaTeX math in notebooks ($...$, $$...$$) as images sized like
--   the text around them, rendered by snacks.nvim (pdflatex, kitty graphics).
--   - The math font is as large as in a LaTeX document whose line spacing is
--     one terminal row (10pt text on 12pt lines, scaled to the row height).
--   - Every image covers whole cells, so kitty never stretches it and all
--     formulas share one scale.
--   - Inline math fills exactly one row with its baseline on the text
--     baseline. \frac{a}{b} turns into a/b there, anything else taller than
--     a row (e.g. \binom) shrinks until it fits.
--   - Display math gets as many rows as it needs, and at least as many as its
--     source lines. So no line disappears, and the layout stays put when the
--     cursor enters it and the source shows up instead.
--   setup() hooks into snacks; called from the snacks spec in
--   plugins/notebook.lua. snacks only renders math in notebooks
--   (lua/core/notebook.lua attaches it).

local M = {}

-- kitty font JetBrains Mono: ascent 1020 + descent 300 per 1000 units, so the
-- baseline lies at 1020/1320 of a row
local BASELINE = 1020 / 1320
-- A row is 1.2 math em, LaTeX's own line spacing. Matching ems exactly would
-- make the math look small: Computer Modern's x-height is 0.43 em, JetBrains
-- Mono's 0.55 em
local ROW_EM = 1.2
-- Inline math may poke this far out of its row before it shrinks (the
-- overhang gets clipped): keeps x^2, x_j and parentheses at full size
local SLACK = "0.3pt"
-- Page size is kept this far below whole cells, so that rounding to pixels
-- never adds a cell
local EPS = "0.4pt"
local DENSITY = 192 -- dpi for the PNG, cells are 6pt (16px) wide

-- Display environments become their math mode versions, the image is one box
local ENVS = {
    align = "aligned",
    ["align*"] = "aligned",
    flalign = "aligned",
    ["flalign*"] = "aligned",
    eqnarray = "aligned",
    ["eqnarray*"] = "aligned",
    gather = "gathered",
    ["gather*"] = "gathered",
    multline = "multlined",
    ["multline*"] = "multlined",
    equation = "",
    ["equation*"] = "",
}

-- Size of one cell in TeX points, as snacks converts image sizes to cells
-- (snacks.image.util.fit: pixels / dpi * 96 * scale / cell size)
local function cell_pt()
    local t = Snacks.image.terminal.size()
    local width = 0.75 * t.cell_width / t.scale
    return width, width * t.cell_height / t.cell_width
end

-- Math in the source without its delimiters, environments made boxable
local function body(src)
    src = vim.trim(src)
    src = src:match "^%$%$(.-)%$%$$"
        or src:match "^%$(.-)%$$"
        or src:match "^\\%[(.-)\\%]$"
        or src:match "^\\%((.-)\\%)$"
        or src
    local function env(kind)
        return function(name)
            local to = ENVS[name]
            if to == nil then
                return nil -- keep it
            end
            return to == "" and "" or ("\\%s{%s}"):format(kind, to)
        end
    end
    src = src:gsub("\\begin{([%a*]+)}", env "begin")
    src = src:gsub("\\end{([%a*]+)}", env "end")
    src = src:gsub("\\label%b{}", ""):gsub("\\nonumber", ""):gsub("\\notag", "")
    return vim.trim(src)
end

-- Inline fractions as a/b: a stacked one only fits a row at half size
local function slash_fractions(src)
    local function part(s)
        s = vim.trim(s:sub(2, -2))
        local single = s:match "^%w$"
            or s:match "^%d+%.?%d*$"
            or s:match "^\\%a+$"
            or s:match "^|[^|]*|$"
            or s:match "^%b()$"
        return single and s or "(" .. s .. ")"
    end
    local n
    repeat -- inner fractions in the next round
        src, n = src:gsub("\\[dt]?frac%s*(%b{})%s*(%b{})", function(num, den)
            return "{" .. part(num) .. "/" .. part(den) .. "}"
        end)
    until n == 0
    return src
end

-- Rows of source the display math covers when it stands alone on them, else 1
local function source_rows(buf, range)
    local lines = vim.api.nvim_buf_get_lines(buf, range[1] - 1, range[3], false)
    if #lines == 0 then
        return 1
    end
    local before = lines[1]:sub(1, range[2])
    local after = lines[#lines]:sub(range[4] + 1)
    if before:find "%S" or after:find "%S" then
        return 1
    end
    return #lines
end

-- snacks.image.doc transform for latex: wraps the formula in a document that
-- sizes the page to whole cells (see the description at the top)
local function transform(img, ctx)
    if not (img.content and img.ext == "math.tex") then
        return
    end
    local node = ctx.content and ctx.content.node
    local inline = node and node:type() == "inline_formula"
    local col, row = cell_pt()
    local size = row / ROW_EM
    local asc = row * BASELINE
    local color = (Snacks.util.color "SnacksImageMath" or "#000000"):upper():sub(2)
    -- Cells wide: round up, a hair of overhang is fine
    local width = ("\\dimexpr\\fpeval{max(1,ceil(\\the\\wd\\nbBox/\\the\\nbCol-0.05))}\\nbCol-%s\\relax"):format(EPS)

    local fit
    if inline then
        fit = {
            "\\sbox\\nbBox{\\color[HTML]{" .. color .. "}$" .. slash_fractions(body(img.content)) .. "$}",
            -- shrink until it fits the row, the baseline stays in place
            ("\\edef\\nbScale{\\fpeval{min(1,(\\the\\nbAsc+%s)/max(\\the\\ht\\nbBox,1sp),(\\the\\nbDsc+%s)/max(\\the\\dp\\nbBox,1sp))}}"):format(
                SLACK,
                SLACK
            ),
            "\\sbox\\nbBox{\\scalebox{\\nbScale}{\\usebox\\nbBox}}",
            ("\\makebox[%s]{\\raisebox{0pt}[\\nbAsc][\\dimexpr\\nbDsc-%s\\relax]{\\usebox\\nbBox}}"):format(
                width,
                EPS
            ),
        }
    else
        local min_rows = source_rows(ctx.buf, img.range)
        fit = {
            "\\sbox\\nbBox{\\color[HTML]{" .. color .. "}$\\displaystyle " .. body(img.content) .. "$}",
            -- whole rows, centered vertically
            ("\\edef\\nbRows{\\fpeval{max(%d,ceil((\\the\\ht\\nbBox+\\the\\dp\\nbBox)/\\the\\nbRow-0.02))}}"):format(
                min_rows
            ),
            ("\\makebox[%s]{\\vbox to \\dimexpr\\nbRows\\nbRow-%s\\relax{\\vss\\hbox{\\usebox\\nbBox}\\vss}}"):format(
                width,
                EPS
            ),
        }
    end

    local tex = {
        "\\RequirePackage{fix-cm}",
        "\\documentclass[border=0pt]{standalone}",
        "\\usepackage{amsmath,amssymb,mathtools,graphicx,xcolor}",
        ("\\newdimen\\nbCol \\nbCol=%.4fpt"):format(col),
        ("\\newdimen\\nbRow \\nbRow=%.4fpt"):format(row),
        ("\\newdimen\\nbAsc \\nbAsc=%.4fpt"):format(asc),
        ("\\newdimen\\nbDsc \\nbDsc=%.4fpt"):format(row - asc),
        "\\newsavebox\\nbBox",
        -- macros between "snacks: header start/end" comments in the notebook
        Snacks.image.doc.get_header(ctx.buf),
        "\\begin{document}",
        -- every line ends in % so no stray spaces widen the page
        ("\\fontsize{%.4f}{%.4f}\\selectfont%%"):format(size, row),
    }
    for _, line in ipairs(fit) do
        tex[#tex + 1] = line .. "%"
    end
    tex[#tex + 1] = "\\end{document}"
    img.content = table.concat(tex, "\n")
    -- marks the image as ours for the placement size below
    img.content_id = "nbmath-" .. vim.fn.sha256(img.content):sub(1, 12)
end

function M.setup()
    Snacks.image.doc.transforms.latex = transform
    -- no -trim: the transparent margin is part of the cell grid
    Snacks.image.config.convert.magick.math = { "-density", DENSITY, "{src}[{page}]" }

    -- snacks squeezes images of up to two rows into one row of inline text
    -- and pads them by two cells. Ours are sized already: show them as they
    -- are unless they don't fit the window
    local Placement = Snacks.image.placement
    local state = Placement.state
    function Placement:state()
        local ret = state(self)
        if not (self.img.info and self.img.src:find "/nbmath%-") then
            return ret
        end
        local size = Snacks.image.util.fit(self.img.file, { width = 1e9, height = 1e9 }, { info = self.img.info })
        local room = math.huge
        for _, win in ipairs(ret.wins) do
            local info = vim.fn.getwininfo(win)[1]
            room = math.min(room, info.width - info.textoff)
        end
        if size.width <= room then
            ret.loc.width, ret.loc.height = size.width, size.height
        end
        return ret
    end

    -- The source of a formula shows while the cursor is inside it, not on the
    -- whole cursor line ('concealcursor' keeps that line rendered, like the
    -- markup in lua/core/notebook.lua)
    local Inline = Snacks.image.inline
    function Inline:conceal()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local row, col = cursor[1], cursor[2]
        for _, img in pairs(self.imgs) do
            local r = img.opts.range -- 1-based rows, 0-based cols, end exclusive
            local at = r
                and img.opts.conceal
                and row >= r[1]
                and row <= r[3]
                and (row > r[1] or col >= r[2])
                and (row < r[3] or col < r[4])
            if at then
                img:hide()
            else
                img:show()
            end
        end
    end
end

return M
