noremap = { noremap = true }
function nnoremap(l, r)
	vim.keymap.set('n', l, r, noremap)
end

vim.env.mapleader = ' '
nnoremap(';', ':')
nnoremap(':', ';')

-- nnoremap('<leader>ym', ':set number!<CR>:set list!<CR>')
-- nnoremap('<leader>rr', function() vim.cmd.source('~/.config/nvim/init.lua') end)
-- nnoremap('<leader>re', function() vim.cmd.edit('~/.config/nvim/init.lua') end)
vim.keymap.set('n', '<leader>rr', function() vim.cmd.source('~/.config/nvim/init.lua') end)

-- conf.nocompatible = true
-- not sure why this does not work
-- will checkout later
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
