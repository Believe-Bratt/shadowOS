" ============================================================================
" ShadowOS Neovim Configuration — Cyberpunk UI
" ============================================================================

" ─── Plugin Manager (vim-plug) ───────────────────────────────────────────────
call plug#begin(stdpath('data') . '/plugged')

" UI Enhancements
Plug 'nvim-lualine/lualine.nvim'          " Status line
Plug 'akinsho/bufferline.nvim'            " Buffer tabs
Plug 'goolord/alpha-nvim'                 " Dashboard
Plug 'nvim-neo-tree/neo-tree.nvim'        " File explorer
Plug 'nvim-telescope/telescope.nvim'      " Fuzzy finder
Plug 'folke/which-key.nvim'               " Key hints
Plug 'nvim-treesitter/nvim-treesitter'    " Syntax highlighting

" LSP & Completion
Plug 'neovim/nvim-lspconfig'              " LSP config
Plug 'williamboman/mason.nvim'            " Package manager
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'hrsh7th/nvim-cmp'                   " Completion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'                   " Snippets

" Git
Plug 'lewis6991/gitsigns.nvim'            " Git signs
Plug 'f-person/git-blame.nvim'            " Git blame

" Editor
Plug 'numToStr/Comment.nvim'              " Commenting
Plug 'windwp/nvim-autopairs'              " Auto pairs
Plug 'tpope/vim-surround'                 " Surround
Plug 'tpope/vim-repeat'                   " Repeat
Plug 'folke/trouble.nvim'                 " Diagnostics

" Colors & Icons
Plug 'kyazdani42/nvim-web-devicons'       " Icons

call plug#end()

" ─── Core Settings ───────────────────────────────────────────────────────────
set nocompatible
filetype plugin indent on
syntax on
set hidden
set encoding=utf-8
set pumheight=10
set fileencoding=utf-8
set termguicolors
set background=dark

" Tabs & Indentation
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set smartindent

" UI
set number
set relativenumber
set signcolumn=yes
set wrap
set linebreak
set scrolloff=8
set sidescrolloff=8
set mouse=a
set splitright
set splitbelow
set noshowmode
set cmdheight=0
set updatetime=300
set timeoutlen=500

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch

" Files
set undofile
set undodir=~/.vim/undo//
set backup
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//

" ─── Color Scheme ────────────────────────────────────────────────────────────
colorscheme cyberpunk

" ─── Lualine ─────────────────────────────────────────────────────────────────
lualine = require('lualine')
lualine.setup({
    options = {
        theme = 'cyberpunk',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = { statusline = { 'dashboard' } },
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
    inactive_sections = {
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'location' }
    },
    tabline = {},
    extensions = { 'nvim-tree', 'neo-tree', 'trouble' }
})

" ─── Bufferline ──────────────────────────────────────────────────────────────
require('bufferline').setup({
    options = {
        mode = 'buffers',
        numbers = 'none',
        close_command = 'bdelete! %d',
        right_mouse_command = 'bdelete! %d',
        left_mouse_command = 'buffer %d',
        middle_mouse_command = nil,
        indicator = {
            icon = '▎',
            style = 'icon',
        },
        buffer_close_icon = '',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 18,
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            return "("..count..")"
        end,
        custom_filter = function(buf_number, buf_numbers)
            return true
        end,
        offsets = {
            {
                filetype = 'neo-tree',
                text = 'File Explorer',
                highlight = 'Directory',
                text_align = 'left'
            }
        },
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        persist_ sort = 'directory',
        separator_style = 'slant',
        enforce_regular_tabs = false,
        always_show_bufferline = true,
    }
})

" ─── Neo-tree ─────────────────────────────────────────────────────────────────
require('neo-tree').setup({
    close_if_last_window = true,
    popup_border_style = 'rounded',
    enable_git_status = true,
    enable_diagnostics = true,
    sort_case_insensitive = false,
    sort_function = nil,
    default_component_configs = {
        container = {
            enable_character_fade = true
        },
        indent = {
            indent_size = 2,
            padding = 1,
            with_markers = true,
            indent_marker = '│',
            highlight = 'NeoTreeIndentMarker',
        },
        icon = {
            folder_closed = '',
            folder_open = '',
            folder_empty = 'ﰊ',
            default = ''
        },
        modified = {
            symbol = '[+]',
            highlight = 'NeoTreeModified',
        },
        name = {
            trailing_slash = false,
            use_git_status_colors = true,
            highlight = 'NeoTreeFileName',
        },
        git_status = {
            symbol = '',
            highlight = 'NeoTreeDimText',
        },
        file_size = {
            enabled = true,
            required_width = 64,
        },
        type = {
            enabled = true,
            required_width = 122,
        },
        last_modified = {
            enabled = true,
            required_width = 88,
        },
        created = {
            enabled = true,
            required_width = 110,
        },
    },
    window = {
        position = 'left',
        width = 30,
        mapping_options = {
            noremap = true,
            nowait = true,
        },
    },
    nesting_rules = {
        ['*.js'] = {'*.js.map'},
        ['*.ts'] = {'*.ts.map'},
    },
    filesystem = {
        filtered_items = {
            visible = false,
            hide_dotfiles = true,
            hide_gitignored = true,
            hide_by_name = { '.git', 'node_modules', '.cache' },
            never_show = { '.git', 'node_modules', '.cache' }
        },
        follow_current_file = true,
        hijack_netrw_behavior = 'open_current',
        use_libuv_file_watcher = false,
    },
    git_status = {
        window = {
            position = 'float'
        }
    }
})

" ─── Telescope ───────────────────────────────────────────────────────────────
require('telescope').setup({
    defaults = {
        vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case'
        },
        prompt_prefix = '🔍 ',
        selection_caret = '› ',
        entry_prefix = '  ',
        initial_mode = 'insert',
        selection_strategy = 'reset',
        sorting_strategy = 'ascending',
        layout_strategy = 'horizontal',
        layout_config = {
            horizontal = {
                prompt_position = 'top',
                preview_width = 0.55,
                results_width = 0.8,
            },
            vertical = {
                mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
        },
        file_sorter = require('telescope.sorters').get_fuzzy_file,
        file_ignore_patterns = { 'node_modules', '.git/' },
        generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
        path_display = { 'truncate' },
        winblend = 0,
        border = {},
        borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
        colorize = true,
        use_less = true,
        set_env = { ['COLORTERM'] = 'truecolor' },
        file_previewer = require('telescope.previewers').vim_buffer_cat.new,
        grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
        qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
        buffer_previewer_maker = require('telescope.previewers').buffer_previewer_maker,
    },
    pickers = {
        find_files = {
            theme = 'dropdown',
            find_command = { 'rg', '--files', '--hidden', '-g', '!.git' }
        }
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case'
        }
    }
})

" ─── Which-Key ───────────────────────────────────────────────────────────────
require('which-key').setup({
    plugins = {
        marks = true,
        registers = true,
        spelling = {
            enabled = true,
            suggestions = 20,
        },
        presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
        },
    },
    window = {
        border = 'single',
        padding = { 1, 2, 1, 2 },
    },
    layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = 'left',
    },
    icons = {
        breadcrumb = '»',
        separator = '➜',
        group = '+',
    },
    show_help = true,
    show_keys = true,
})

" ─── Dashboard (Alpha) ───────────────────────────────────────────────────────
local alpha = require('alpha')
local dashboard = require('alpha.themes.dashboard')

dashboard.section.header.val = {
    ' ╔══════════════════════════════════════════════╗ ',
    ' ║  🌑 SHADOWOS — Cyberpunk Neovim              ║ ',
    ' ║  Neon Vanguard Edition                       ║ ',
    ' ╚══════════════════════════════════════════════╝ ',
    '',
    '  🔹 AI-Powered Editing',
    '  🔹 Neon Syntax Highlighting',
    '  🔹 Integrated Terminal',
    '',
}

dashboard.section.buttons.val = {
    dashboard.button('f', '🔍  Find file', ':Telescope find_files<CR>'),
    dashboard.button('n', '📄  New file', ':ene<CR>'),
    dashboard.button('r', '📜  Recent files', ':Telescope oldfiles<CR>'),
    dashboard.button('g', '🔍  Live grep', ':Telescope live_grep<CR>'),
    dashboard.button('c', '⚙️  Config', ':e ~/.config/nvim/init.vim<CR>'),
    dashboard.button('q', '🚪  Quit', ':qa<CR>'),
}

alpha.setup(dashboard.config)

" ─── Treesitter ───────────────────────────────────────────────────────────────
require('nvim-treesitter.configs').setup({
    ensure_installed = { 'vim', 'lua', 'python', 'bash', 'javascript', 'typescript', 'go', 'rust', 'c', 'cpp' },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
    rainbow = { enable = true },
})

" ─── LSP ───────────────────────────────────────────────────────────────────────
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.pyright.setup({ capabilities = capabilities })
lspconfig.tsserver.setup({ capabilities = capabilities })
lspconfig.gopls.setup({ capabilities = capabilities })
lspconfig.rust_analyzer.setup({ capabilities = capabilities })
lspconfig.clangd.setup({ capabilities = capabilities })

" ─── Completion (nvim-cmp) ───────────────────────────────────────────────────
local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
    })
})

" ─── Git Signs ────────────────────────────────────────────────────────────────
require('gitsigns').setup({
    signs = {
        add = { hl = 'GitAddSign', text = '│', numhl = 'GitAddNr', linehl = 'GitAddLn' },
        change = { hl = 'GitChangeSign', text = '│', numhl = 'GitChangeNr', linehl = 'GitChangeLn' },
        delete = { hl = 'GitDeleteSign', text = '_', numhl = 'GitDeleteNr', linehl = 'GitDeleteLn' },
        topdelete = { hl = 'GitDeleteSign', text = '‾', numhl = 'GitDeleteNr', linehl = 'GitDeleteLn' },
        changedelete = { hl = 'GitChangeDeleteSign', text = '~', numhl = 'GitChangeDeleteNr', linehl = 'GitChangeDeleteLn' },
    },
    signcolumn = true,
    numhl = false,
    linehl = false,
    word_diff = false,
    watch_gitdir = { interval = 1000, follow_files = true },
    current_line_blame = true,
    current_line_blame_opts = { virt_text = true, virt_text_pos = 'eol', delay = 1000, ignore_whitespace = false },
    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d %H:%M:%S> - <summary>',
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil,
    max_file_length = 40000,
    preview_config = { border = 'single', style = 'minimal', relative = 'cursor' },
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end
        map('n', '<leader>hs', gs.stage_hunk)
        map('n', '<leader>hr', gs.reset_hunk)
        map('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end)
        map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end)
        map('n', '<leader>hS', gs.stage_buffer)
        map('n', '<leader>hu', gs.undo_stage_hunk)
        map('n', '<leader>hR', gs.reset_buffer)
        map('n', '<leader>hp', gs.preview_hunk)
        map('n', '<leader>hb', function() gs.blame_line{full=true} end)
        map('n', '<leader>tb', gs.toggle_current_line_blame)
        map('n', '<leader>hd', gs.diffthis)
        map('n', '<leader>hD', function() gs.diffthis('~') end)
        map('n', '<leader>td', gs.toggle_deleted)
    end
})

" ─── Comment ─────────────────────────────────────────────────────────────────
require('Comment').setup({
    padding = true,
    sticky = true,
    ignore = nil,
    toggler = {
        line = 'gcc',
        block = 'gbc',
    },
    opleader = {
        line = 'gc',
        block = 'gb',
    },
    extra = {
        above = 'gcO',
        below = 'gco',
        eol = 'gcA',
    },
    mappings = {
        basic = true,
        extra = true,
    },
    pre_hook = nil,
    post_hook = nil,
})

" ─── Autopairs ────────────────────────────────────────────────────────────────
require('nvim-autopairs').setup({
    check_ts = true,
    ts_config = { lua = { 'string', 'source' }, javascript = { 'string', 'template_string' }, java = false },
    disable_filetype = { 'TelescopePrompt', 'spectre_panel' },
    fast_wrap = { map = '<M-e>', chars = { '{', '[', '(', '"', "'" }, pattern = [=[[%'%"%>%]%)%}]]=], offset = 0, expand_key = 'l', expand_key_remap = true }
})

" ─── Trouble ─────────────────────────────────────────────────────────────────
require('trouble').setup({
    position = 'bottom',
    height = 10,
    width = 50,
    icons = true,
    mode = 'workspace_diagnostics',
    fold_open = '',
    fold_close = '',
    group = true,
    padding = true,
    action_keys = {
        close = 'q',
        cancel = '<esc>',
        refresh = 'r',
        jump = { '<cr>', '<tab>' },
        open_split = { '<c-x>' },
        open_vsplit = { '<c-v>' },
        open_tab = { '<c-t>' },
        jump_close = { 'o' },
        toggle_mode = 'm',
        toggle_preview = 'P',
        hover = 'K',
        details = '?',
    },
    indent_lines = true,
    auto_open = false,
    auto_close = false,
    auto_preview = true,
    auto_fold = false,
    signs = {
        error = '',
        warning = '',
        information = '',
        hint = '',
        other = '﫠'
    },
    use_diagnostic_signs = false
})

" ─── Key Mappings ─────────────────────────────────────────────────────────────
local keymap = vim.keymap.set
keymap('n', '<leader>e', ':NeoTree reveal<CR>', { noremap = true, silent = true })
keymap('n', '<leader>f', ':Telescope find_files<CR>', { noremap = true, silent = true })
keymap('n', '<leader>g', ':Telescope live_grep<CR>', { noremap = true, silent = true })
keymap('n', '<leader>b', ':Telescope buffers<CR>', { noremap = true, silent = true })
keymap('n', '<leader>h', ':Telescope help_tags<CR>', { noremap = true, silent = true })
keymap('n', '<leader>d', ':TroubleToggle<CR>', { noremap = true, silent = true })
keymap('n', '<leader>q', ':bd<CR>', { noremap = true, silent = true })
keymap('n', '<C-h>', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })
keymap('n', '<C-l>', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
keymap('n', '<C-p>', ':Telescope find_files<CR>', { noremap = true, silent = true })

" ─── End of Neovim Config ──────────────────────────────────────────────────── 
