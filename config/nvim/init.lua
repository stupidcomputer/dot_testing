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
vim.opt.signcolumn = 'yes'
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
setTabbing("htmldjango", 4)
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

-- lazy.nvim {{{
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" }
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-telescope/telescope.nvim" },
		{ "nvim-tree/nvim-tree.lua" },
		{ 'dinhhuy258/git.nvim' },
		{ "octarect/telescope-menu.nvim" },
		{ "VonHeikemen/lsp-zero.nvim" },
		{ "neovim/nvim-lspconfig" },
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "L3MON4D3/LuaSnip" },
		{ "saadparwaiz1/cmp_luasnip" },
		{ "lervag/vimtex" },
		{ "https://github.com/protex/better-digraphs.nvim" },
	},
	checker = { enabled = true },
})
-- }}}

nnoremap('<leader>ff', function()
	require('telescope.builtin').find_files()
end)

inoremap('<C-k><C-k>', function()
	require('better-digraphs').digraphs("insert")
end)

-- lsp config {{{
local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup({})
lspconfig.texlab.setup({})
lspconfig.nixd.setup({})
lspconfig.pylsp.setup({
	settings = {
		pylsp = {
			plugins = {
				pycodestyle = {
					ignore = {"W391"},
					maxLineLength = 100,
				}
			}
		}
	}
})
-- }}}

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

luasnip.add_snippets("tex", {
	luasnip.snippet("desc", {
		luasnip.text_node("\\begin{description}"),
		luasnip.text_node({ "", "\t\\item " }), luasnip.insert_node(1),
		luasnip.text_node({ "", "\\end{description}" })
	})
})
-- }}}

-- nvim-tree {{{
require('nvim-tree').setup()
-- }}}

-- nvim-cmp setup {{{
local cmp = require("cmp")
cmp.setup({
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}),
	snippet = {
		expand = function(args)
			vim.snippet.expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		['<C-h>'] = cmp.mapping.select_next_item({behavior = 'select'}),
		['<C-k>'] = cmp.mapping.select_prev_item({behavior = 'select'}),
		['<C-Space>'] = cmp.mapping.confirm({select = false}),
	}),
})
-- }}}

-- git.nvim setup {{{
require('git').setup()
-- }}}
