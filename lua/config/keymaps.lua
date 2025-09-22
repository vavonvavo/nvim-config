-- Basic keymaps
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Telescope file browser
vim.keymap.set(
  'n',
  '<leader>fe',
  ':Telescope file_browser path=%:p:h select_buffer=true<CR>',
  { noremap = true, silent = true, desc = 'Open file browser (relative path)' }
)

vim.keymap.set(
  'n',
  '<leader>fE',
  ':Telescope file_browser path=' .. vim.fn.getcwd() .. ' select_buffer=true<CR>',
  { noremap = true, silent = true, desc = 'Open file browser (project root)' }
)

vim.keymap.set('n', '<leader>fh', ':Telescope file_browser hidden=true<CR>', { noremap = true, silent = true, desc = 'Open file browser (show hidden files)' })

-- Diagnostics
vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Show Diagnostic (float)', noremap = true, silent = true })

-- LSP keymaps (buffer-local, set when LSP attaches)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('gd', function() require('telescope.builtin').lsp_definitions() end, '[G]oto [D]efinition')
    map('gr', function() require('telescope.builtin').lsp_references() end, '[G]oto [R]eferences')
    map('gI', function() require('telescope.builtin').lsp_implementations() end, '[G]oto [I]mplementation')
    map('<leader>D', function() require('telescope.builtin').lsp_type_definitions() end, 'Type [D]efinition')
    map('<leader>ds', function() require('telescope.builtin').lsp_document_symbols() end, '[D]ocument [S]ymbols')
    map('<leader>ws', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, '[W]orkspace [S]ymbols')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  end,
})