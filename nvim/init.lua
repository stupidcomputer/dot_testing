-- randomuser's
--  _       _ _     _
-- (_)_ __ (_) |_  | |_   _  __ _
-- | | '_ \| | __| | | | | |/ _` |
-- | | | | | | |_ _| | |_| | (_| |
-- |_|_| |_|_|\__(_)_|\__,_|\__,_|

-- helper functions {{{
function nnoremap(l, r)
	vim.keymap.set('n', l, r) -- noremap is implied
end

function inoremap(l, r)
	vim.keymap.set('i', l, r)
end

function tnoremap(l, r)
	vim.keymap.set('t', l, r)
end
-- }}}

-- custom mappings {{{
vim.g.mapleader = ' '
nnoremap(';', ':')
nnoremap(':', ';')
nnoremap('<leader><leader>', ':')

-- source init.vim
nnoremap('<leader>rr', function()
	vim.cmd.source('~/.config/nvim/init.lua')
end)
-- edit init.vim
nnoremap('<leader>re', function()
	vim.cmd.edit('~/.config/nvim/init.lua')
end)
-- openup netrw
nnoremap('<leader>fs', function()
	vim.cmd.Lexplore()
end)

inoremap('qp', '<c-g>u<Esc>[s1z=`]a<c-g>u')
inoremap("<C-a>", "<Esc>mZ0i<Tab><Esc>`ZlA")

tnoremap('<Esc>', '<C-\\><C-n>')
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

-- autocmds for python
vim.api.nvim_create_autocmd({"Filetype"}, {
	pattern = {"python"},
	callback = function()
		vim.bo.expandtab = true
		vim.bo.tabstop = 4
		vim.bo.shiftwidth = 4
	end
})
-- }}}

-- vim options {{{
vim.o.compatible = false
vim.o.number = true
vim.o.foldmethod = 'marker'
vim.o.encoding = 'utf8'
vim.o.list = true
vim.o.lcs = 'tab:->,trail:_,eol:^'
vim.o.clipboard = 'unnamedplus'
vim.o.spell = true
vim.o.spelllang = "en_us"
vim.o.title = true
vim.o.ts = 2
vim.o.sw = 2
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'nosplit'
vim.o.hidden = true
vim.opt.path:append {'**'}
vim.cmd.colorscheme('earth')
vim.o.statusline="%f %r%m%q%h%=%y 0x%02B %04l:%03c:%03p"
vim.api.nvim_exec("let &titlestring='%{expand(\"%:p\")}'", true)
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
	use 'vimwiki/vimwiki'

	if packer_bootstrap then
		require('packer').sync()
	end
end)
-- }}}
