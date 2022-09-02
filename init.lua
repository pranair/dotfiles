--thanks to https://oroques.dev/notes/neovim-init/#set-options
--for the idea
local opt = vim.opt
local cmd = vim.cmd 
local g = vim.g

cmd [[packadd packer.nvim]]
cmd [[packadd termdebug]]

cmd[[filetype plugin indent on]]
cmd[[command! -nargs=+ Rg execute 'silent AsyncRun!  rg  --vimgrep . -e <args>']]
cmd[[command! GenCtags lua gen_ctags()]]
cmd[[autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o]]
cmd[[command! -nargs=+ Lines lua SearchAllBuffers('<args>')]]
cmd [[set omnifunc=syntaxcomplete#Complete]]

require('packer').startup(function() 
    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    use 'wbthomason/packer.nvim'
    use 'ctrlpvim/ctrlp.vim'
    use 'jiangmiao/auto-pairs'
    use 'preservim/nerdtree'
    use 'ludovicchabant/vim-gutentags'
    use 'tpope/vim-fugitive'
    use 'neomake/neomake' 
    use 'preservim/tagbar'
    use 'jlanzarotta/bufexplorer'
    use 'mbbill/undotree'
    use 'skywind3000/asyncrun.vim'
    use 'folke/tokyonight.nvim'
    use {'nvim-treesitter/nvim-treesitter', run =  ':TSUpdate'}
    use 'rafamadriz/neon'
    use 'vim-airline/vim-airline'
    use 'vim-airline/vim-airline-themes'
    use 'nvim-lua/plenary.nvim'
    use 'neovim/nvim-lspconfig'
end)

-------------------- Begin Options ------------------------
local ts = require 'nvim-treesitter.configs'
ts.setup {
    highlight = {enable = true}, 
}

opt.wrap = false
opt.wildmenu = true
opt.wildignorecase = true
--opt.lazyredraw = true
opt.confirm = true
opt.hidden = true
opt.autoread = true
opt.hlsearch= true
opt.incsearch= true
opt.ignorecase= true
opt.autoindent = true
opt.smartindent = true 
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.expandtab = true
opt.splitbelow = true 
opt.splitright = true
opt.writebackup = false
opt.backup =  false

opt.inccommand = "nosplit"
opt.encoding = "UTF-8"
opt.path:append("**")
opt.wildmode = {"longest:full", "full"}
opt.grepprg = "rg"
opt.backspace = {"indent", "eol", "start"}
opt.shiftwidth = 4 
opt.tabstop = 4 
opt.softtabstop = 4 
opt.cmdheight = 1

opt.makeprg = "bash run.sh"

-- make it pretty, precious
cmd[[colorscheme neon]]

-------------------- End Options --------------------------

-------------------- Begin Functions ---------------------- 
function gen_ctags()
    local Job = require 'plenary.job'
    local callbacks = {
        on_exit = function (job_id, data, event)
            if data == 0 then
                print("Ctags generation complete")
            else 
                print("Ctags generation failure!")
            end
        end
    }
    local job = vim.fn.jobstart("ctags -R", callbacks)
end

function insert_errorformat(...)
    opt.errorformat = {}
    for k, v in pairs({...}) do
        opt.errorformat:append(v)
    end 
end

function SearchAllBuffers(args)
    local files = ''
    local buffers = vim.api.nvim_list_bufs() 
    for b, x in pairs(buffers) do
        if vim.api.nvim_buf_get_option(b, 'buflisted') then
            files = string.format("%s \"%s\"", files, vim.api.nvim_buf_get_name(b))
        end
    end
    local options = ' --vimgrep ' .. files
    vim.api.nvim_command('silent AsyncRun! -strip ' .. 'rg ' .. args .. options)
end

local function map(mode, lhs, rhs, opts)
    local options = {noremap = true}
    if opts then options = vim.tbl_extend('force', options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-------------------- End Functions ---------------------- 

--- Build options

-- insert_errorformat("%-Gmake%.%#", "%f:%l:%c:%m", "%f:%m", "compile%m", "%-G%.%#") -- gcc cmake linux
-- insert_errorformat("lua: %f:%l: %m", "%f:%l:%c:%m", "%-G%.%#") -- lua

-------------------- Begin Mapping ---------------------- 
-- the dictator
g.mapleader =  " "

-- fold
map("n", "<Space>a", "za") 

map("n", "Y", "y$") -- much needed

-- tabs
map("n", "H", "gT")
map("n", "L", "gt")
map("n", "<leader>1", "1gt")
map("n", "<leader>2", "2gt")
map("n", "<leader>3", "3gt")
map("n", "<leader>4", "4gt")
map("n", "<leader>5", "5gt")
map("n", "<leader>6", "6gt")
map("n", "<leader>7", "7gt")
map("n", "<leader>8", "8gt")
map("n", "<leader>9", "9gt")
map("n", "<leader>0", ":tablast<cr>")

-- macros
map("n", "Q", "@@")

-- buffer and file stuff
map("n", "s", ":CtrlPBuffer<CR>")
map("n", "<M-f>", ":CtrlP<CR>")
map("n", "<C-p>", ":b#<CR>")
map("n", "<leader>x", ":b#<CR>:bd #<CR>")

-- anti-rsp
map("n", "\\", ",")
map("n", ",", ";")
map("n", ";", ":")
map("n", "'", "`")

-- NOTE: find better ones?
map("n", "<Up>", ":resize -2<CR>")
map("n", "<Down>", ":resize +2<CR>")
map("n", "<Left>", ":vertical resize +2<CR>")
map("n", "<Right>", ":vertical resize -2<CR>")

-- Window switching
map("n", "<M-h>", "<C-W>h")
map("n", "<M-j>", "<C-W>j")
map("n", "<M-k>", "<C-W>k")
map("n", "<M-l>", "<C-W>l")

map("n", "<M-q>", ":cclose<CR>:lclose<CR>")

map("n", "<leader>y", "\"+y")
map("v", "<leader>y", "\"+y")

-- init files
-- TODO: fix this for init.lua
--map("n", "<leader>r", ":so $MYVIMRC<CR>:noh<CR>")
--map("n", "<leader>, ", ":e $MYVIMRC<CR>")
map("n", "<leader>,r", ":so $MYVIMRC<CR>:noh<CR>")
map("n", "<leader>,,", ":e $MYVIMRC<CR>")

-- plugin specific
map("n", "<leader>u", ":UndotreeToggle<CR>")
map("n", "<leader>n", ":NERDTreeToggle<CR>")

map("n", "<Leader>sr", [[:%s/\<<C-r><C-w>\>/]]) -- replace
map("n", "<leader>t", ":!date<CR>") -- TEMP: wsl only

map("n", "<leader>/", ":noh<CR>")
map("v", "<Space>", "za")
map("x", "K", ":move '<-2<CR>gv-gv")
map("x", "J", ":move '>+1<CR>gv-gv")
map("t", "<Esc>" , "<C-\\><C-n>") -- escape in terminal mode

-- map("n", "gd", "<C-]>") -- tags

-- some shada stuff
map("n", "<leader>rs", ":mksession! ~/.vim_session<CR>") 
map("n", "<leader>rr", ":so ~/.vim_session<CR>") 

--map("n", "<leader>m", [[execute "AsyncRun! lua " . expand('%:t')<CR>:copen<cr>)]]) -- compile
map("n", "<leader>m", [[:Neomake!<CR>]]) -- compile
map("n", "<leader>f", [[:Rg <c-r>=expand("<cword>")<cr><cr>]]) -- search word under cursor
-------------------- End Mapping ---------------------- 

-------------------- Misc -----------------------------
-- some globals
g["airline#extensions#tagbar#enabled"] = 0
g["airline#extensions#tabline#tab_nr_type"] = 1 
g["airline#extensions#tabline#tabnr_formatter"] = 'tabnr'
g["airline#extensions#tabline#enabled"] = 1
g["airline_powerline_fonts"] = 1
g["airline_theme"] = 'night_owl'
g["ctrlp_map"] = ''
g["ctrlp_working_path_mode"] = '' 
g["ctrlp_custom_ignore"] = {
    dir =  '.git$|.yardoc|.ccls-cache|public$|log|tmp$',
    file = '.so$|.dat$|.ds_store$'
}
g["NERDTreeQuitOnOpen"] = 1

if vim.fn.executable('rg') then
    g.ctrlp_user_command = 'rg %s --files --color=never --glob ""'
end
-------------------- Fin -----------------------------

-------------------- LSP -----------------------------
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'clangd', 'pyright', 'rust_analyzer', 'tsserver' }
require'lspconfig'.pyright.setup{}
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    }
  }
end

vim.diagnostic.config({virtual_text = false})
