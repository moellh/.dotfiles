-- After the runtime's ftplugin/markdown.vim, which sets formatlistpat itself:
-- its pattern plus 1) numbers and - [ ] task boxes, so wrapped lines of list
-- items line up with the item's text (breakindentopt list:-1 in
-- ftplugin/markdown.lua)
vim.opt_local.formatlistpat = [=[^\s*\%(\d\+[.)]\|[-*+]\)\s\+\%(\[.\]\s\+\)\?\|^\[^\ze[^\]]\+\]:\&^.\{4\}]=]
