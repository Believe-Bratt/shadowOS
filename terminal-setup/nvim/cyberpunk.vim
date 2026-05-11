" ============================================================================
" ShadowOS Neovim Colorscheme — Cyberpunk Neon
" ============================================================================

hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "cyberpunk"

" ─── Color Palette ──────────────────────────────────────────────────────
let s:bg_dark       = "#0A0A0F"
let s:bg_panel      = "#1A1A2E"
let s:bg_menu       = "#2A2A3E"
let s:bg_visual     = "#00FFFF1A"
let s:bg_cursor     = "#00FFFF22"
let s:fg_light      = "#F0F0FF"
let s:fg_dim        = "#666677"
let s:fg_comment    = "#555577"
let s:neon_cyan     = "#00FFFF"
let s:neon_magenta  = "#FF00FF"
let s:neon_amber    = "#FFBF00"
let s:neon_green    = "#00FF88"
let s:neon_red      = "#FF0055"
let s:neon_blue     = "#00D4FF"
let s:white         = "#FFFFFF"

" ─── Highlight Groups ───────────────────────────────────────────────────
hi Normal         guibg=s:bg_dark       guifg=s:fg_light
hi Cursor         guibg=s:neon_cyan     guifg=s:bg_dark
hi CursorLine     guibg=s:bg_cursor
hi CursorColumn   guibg=s:bg_cursor
hi LineNr         guibg=s:bg_dark       guifg=s:fg_comment
hi CursorLineNr   guibg=s:bg_cursor     guifg=s:neon_cyan   gui=bold
hi SignColumn     guibg=s:bg_dark       guifg=s:fg_comment
hi StatusLine     guibg=s:bg_panel      guifg=s:neon_cyan   gui=bold
hi StatusLineNC   guibg=s:bg_dark       guifg=s:fg_dim
hi VertSplit      guibg=s:bg_dark       guifg=s:bg_panel
hi TabLine        guibg=s:bg_dark       guifg=s:fg_dim
hi TabLineFill    guibg=s:bg_dark
hi TabLineSel     guibg=s:neon_cyan     guifg=s:bg_dark     gui=bold
hi Pmenu          guibg=s:bg_menu       guifg=s:fg_light
hi PmenuSel       guibg=s:neon_cyan     guifg=s:bg_dark     gui=bold
hi PmenuSbar      guibg=s:bg_panel
hi PmenuThumb     guibg=s:neon_magenta
hi MatchParen     guibg=#FF005522       guifg=s:neon_magenta gui=bold
hi Search         guibg=#FFBF0033       guifg=s:neon_amber   gui=bold
hi IncSearch      guibg=#FF00FF33       guifg=s:neon_magenta gui=bold
hi Visual         guibg=s:bg_visual     guifg=s:neon_cyan
hi VisualNOS      guibg=s:bg_visual     guifg=s:neon_red
hi Folded         guibg=s:bg_panel      guifg=s:neon_cyan
hi FoldColumn     guibg=s:bg_dark       guifg=s:fg_comment
hi Title          guibg=NONE            guifg=s:neon_magenta gui=bold
hi NonText        guibg=NONE            guifg=s:fg_comment
hi SpecialKey     guibg=NONE            guifg=s:fg_comment
hi ErrorMsg       guibg=NONE            guifg=s:neon_red     gui=bold
hi WarningMsg     guibg=NONE            guifg=s:neon_amber   gui=bold
hi ModeMsg        guibg=NONE            guifg=s:neon_green   gui=bold
hi MoreMsg        guibg=NONE            guifg=s:neon_cyan
hi Question       guibg=NONE            guifg=s:neon_green
hi Directory      guibg=NONE            guifg=s:neon_cyan
hi WildMenu       guibg=s:neon_cyan     guifg=s:bg_dark     gui=bold
hi ColorColumn    guibg=#FF005508
hi CursorIM       guibg=s:neon_cyan     guifg=s:bg_dark
hi Todo           guibg=NONE            guifg=s:neon_amber   gui=bold
hi Comment        guibg=NONE            guifg=s:fg_comment   gui=italic

" ─── Syntax Highlights ──────────────────────────────────────────────────
hi Constant       guifg=s:neon_amber
hi String         guifg=s:neon_green
hi Character      guifg=s:neon_green
hi Number         guifg=s:neon_amber
hi Boolean        guifg=s:neon_amber
hi Float          guifg=s:neon_amber
hi Identifier     guifg=s:fg_light
hi Function       guifg=s:neon_cyan    gui=bold
hi Keyword        guifg=s:neon_magenta gui=bold
hi Statement      guifg=s:neon_magenta
hi Conditional    guifg=s:neon_magenta gui=bold
hi Repeat         guifg=s:neon_magenta
hi Loop           guifg=s:neon_magenta
hi Operator       guifg=s:neon_cyan
hi PreProc        guifg=s:neon_amber   gui=bold
hi Include        guifg=s:neon_cyan
hi Define         guifg=s:neon_magenta
hi Macro          guifg=s:neon_amber
hi Typedef        guifg=s:neon_blue
hi Type           guifg=s:neon_blue    gui=bold
hi StorageClass   guifg=s:neon_magenta
hi Structure      guifg=s:neon_blue
hi Tag            guifg=s:neon_magenta
hi Special        guifg=s:neon_amber
hi SpecialChar    guifg=s:neon_amber
hi Delimiter      guibg=NONE            guifg=s:fg_dim
hi SpecialComment guifg=s:fg_comment   gui=italic
hi Debug          guifg=s:neon_red
hi Underlined     guifg=NONE            gui=underline
hi Ignore         guifg=NONE
hi Error          guifg=s:neon_red     guibg=#FF00551A    gui=bold
hi Todo           guifg=s:neon_amber   guibg=NONE          gui=bold

" ─── Git Signs ──────────────────────────────────────────────────────────
hi GitAddSign     guifg=s:neon_green
hi GitChangeSign  guifg=s:neon_amber
hi GitDeleteSign  guifg=s:neon_red
hi GitChangeDeleteSign guifg=s:neon_magenta

" ─── LSP Diagnostics ────────────────────────────────────────────────────
hi DiagnosticError       guifg=s:neon_red
hi DiagnosticWarning     guifg=s:neon_amber
hi DiagnosticInfo        guifg=s:neon_cyan
hi DiagnosticHint        guifg=s:fg_comment
hi DiagnosticVirtualText guifg=s:fg_comment

" ─── Diff ────────────────────────────────────────────────────────────────
hi DiffAdd        guibg=#00FF881A  guifg=s:neon_green
hi DiffChange     guibg=#FFBF001A  guifg=s:neon_amber
hi DiffDelete     guibg=#FF00551A  guifg=s:neon_red
hi DiffText       guibg=#00FFFF22  guifg=s:neon_cyan  gui=bold

" ─── Spelling ────────────────────────────────────────────────────────────
hi SpellBad       guibg=#FF00551A  guisp=s:neon_red    gui=undercurl
hi SpellCap       guibg=#FFBF001A  guisp=s:neon_amber  gui=undercurl
hi SpellRare      guibg=#FF00FF1A  guisp=s:neon_magenta gui=undercurl
hi SpellLocal     guibg=#00D4FF1A  guisp=s:neon_blue   gui=undercurl

" ─── Links ───────────────────────────────────────────────────────────────
hi link Boolean          Number
hi link Float            Number
hi link Conditional      Statement
hi link Repeat           Statement
hi link Label            Statement
hi link Exception        Statement
hi link Typedef          Type
hi link StorageClass     Type
hi link Structure        Type
hi link SpecialChar      Special
hi link Tag              Function
hi link htmlTag          Function
hi link htmlEndTag       Function
hi link xmlTag           Function
hi link xmlEndTag        Function
hi link cssClassName     Function
hi link cssIdentifier    Function