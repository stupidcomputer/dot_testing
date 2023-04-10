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
nnoremap('<leader>rr', function()
	cmd.source('~/.config/nvim/init.lua')
end)
-- edit init.vim
nnoremap('<leader>re', function()
	cmd.edit('~/.config/nvim/init.lua')
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
opt.path = '.,/usr/include,**'
vim.cmd.colorscheme('earth')
opt.statusline="%f %r%m%q%h%=%y 0x%02B %04l:%03c:%03p"
vim.api.nvim_exec("let &titlestring='%{expand(\"%:p\")}'", true)

globals.vimtex_view_method = 'zathura'
-- }}}

-- autocommands {{{
-- swapfile handler
vim.api.nvim_create_autocmd({"SwapExists"}, {
	pattern = {"*"},
	callback = function()
		vim.fn.system("vim-swap-handler " .. vim.api.nvim_buf_get_name(0))
		print(vim.v.shell_error)
		if (vim.v.shell_error == 0) then
			vim.v.swapchoice = 'o'
			print("opened in other place. you should have teleported there")
		elseif (vim.v.shell_error == 1) then
			vim.v.swapchoice = 'o'
			print("file opened readonly. orphaned swap file?")
		end
	end
})

-- autocmds for sxhkd and bspwm config files
vim.api.nvim_create_autocmd({"BufWrite"}, {
	pattern = {"bspwmrc"},
	callback = function()
		vim.fn.system("bspc wm -r")
	end
})
vim.api.nvim_create_autocmd({"BufWrite"}, {
	pattern = {"sxhkdrc"},
	callback = function()
		vim.fn.system("killall sxhkd -USR1")
	end
})

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
setTabbing("javascript", 2)

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

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
	use 'tpope/vim-surround'
	use 'tpope/vim-commentary'
	use 'tpope/vim-fugitive'
	use 'https://github.com/vimwiki/vimwiki.git'
	use 'lervag/vimtex'

	if packer_bootstrap then
		require('packer').sync()
	end
end);
-- }}}
