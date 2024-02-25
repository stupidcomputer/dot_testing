-- randomuser's
--  _       _ _     _
-- (_)_ __ (_) |_  | |_   _  __ _
-- | | '_ \| | __| | | | | |/ _` |
-- | | | | | | |_ _| | |_| | (_| |
-- |_|_| |_|_|\__(_)_|\__,_|\__,_|

-- helper functions {{{
local keymapper = vim.keymap
local globals = vim.g
local opt = vim.o
local cmd = vim.cmd
function nnoremap(l, r)
	keymapper.set('n', l, r) -- noremap is implied
end

function inoremap(l, r)
	keymapper.set('i', l, r)
end

function tnoremap(l, r)
	keymapper.set('t', l, r)
end
-- }}}

-- custom mappings {{{
globals.mapleader = ' '
nnoremap(';', ':')
nnoremap(':', ';')
nnoremap('<leader><leader>', ':')

-- source init.vim
-- requires rebuilding the configuration first
nnoremap('<leader>rr', function()
	cmd.source('~/.config/nvim/init.lua')
end)
-- edit init.vim
nnoremap('<leader>re', function()
	cmd.edit('~/dot_testing/config/nvim/init.lua')
end)
-- openup netrw
nnoremap('<leader>fs', function()
	cmd.Lexplore()
end)

inoremap('qp', '<c-g>u<Esc>[s1z=`]a<c-g>u')
inoremap("<C-a>", "<Esc>mZ0i<Tab><Esc>`ZlA")
inoremap('jk', '<Esc>')
inoremap('zz', '<Esc>:w!<CR>a')

tnoremap('<Esc>', '<C-\\><C-n>')
-- }}}

-- vim options {{{
opt.compatible = false
opt.number = true
opt.foldmethod = 'marker'
opt.encoding = 'utf8'
opt.list = true
opt.lcs = 'tab:->,trail:_,eol:^'
opt.clipboard = 'unnamedplus'
opt.spell = true
opt.spelllang = "en_us"
opt.title = true
opt.ts = 2
opt.sw = 2
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = 'nosplit'
opt.hidden = true
opt.linebreak = true
opt.path = '.,/usr/include,**'
vim.cmd.colorscheme('earth')
opt.statusline="%f %r%m%q%h%=%y 0x%02B %04l:%03c:%03p"
vim.api.nvim_exec("let &titlestring='%{expand(\"%:p\")}'", true)

globals.vimtex_view_method = 'zathura'
-- }}}

-- autocommands {{{
function setTabbing(lang, width)
	vim.api.nvim_create_autocmd({"Filetype"}, {
		pattern = {lang},
		callback = function()
			vim.bo.expandtab = true
			vim.bo.tabstop = width
			vim.bo.shiftwidth = width
		end
	})
end

setTabbing("python", 4)
setTabbing("javascript", 4)
setTabbing("css", 4)
setTabbing("html", 4)
setTabbing("nix", 2)

vim.api.nvim_create_autocmd({"TermOpen"}, {
	pattern = {"*"},
	callback = function()
		vim.wo.number = false
	end
})
-- }}}

-- netrw options {{{
globals.netrw_winsize = -28
globals.netrw_banner = 0
-- for tree view
globals.netrw_liststyle = 3
-- use previous window to open files
globals.netrw_browser_split = 4
-- }}}

-- packer.nvim {{{
-- taken from packer.nvim readme
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

local packer = require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
	use 'nvim-lua/plenary.nvim'
	use 'nvim-telescope/telescope.nvim'
	use 'octarect/telescope-menu.nvim'
	use 'VonHeikemen/lsp-zero.nvim'
	use 'neovim/nvim-lspconfig'
	use 'hrsh7th/nvim-cmp'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'L3MON4D3/LuaSnip'
	use 'lervag/vimtex'
	use 'https://github.com/protex/better-digraphs.nvim'

	if packer_bootstrap then
		require('packer').sync()
	end
end);
-- }}}

nnoremap('<leader>ff', function()
	require('telescope.builtin').find_files()
end)

inoremap('<C-k><C-k>', function()
	require('better-digraphs').digraphs("insert")
end)

-- luasnip configuration {{{
local luasnip = require("luasnip")
local ls_extras = require("luasnip.extras")
require("luasnip.loaders.from_snipmate").lazy_load()
vim.cmd[[
	imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
]]

luasnip.add_snippets("tex", {
	luasnip.snippet("env", {
		luasnip.text_node("\\begin{"), luasnip.insert_node(1), luasnip.text_node("}"),
		luasnip.text_node({ "", "\t" }), luasnip.insert_node(0),
		luasnip.text_node({ "", "\\end{" }), ls_extras.rep(1), luasnip.text_node("}")
	})
})
-- }}}

return packer
