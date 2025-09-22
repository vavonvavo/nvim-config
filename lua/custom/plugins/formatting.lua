return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre', 'BufNewFile' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettier', 'biome' },
        javascriptreact = { 'prettier', 'biome' },
        typescript = { 'prettier', 'biome' },
        typescriptreact = { 'prettier', 'biome' },
        css = { 'prettier' },
        html = { 'prettier' },
        json = { 'prettier', 'biome' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
      },
      formatters = {
        prettier = {
          condition = function(self, ctx)
            return vim.fs.find({
              '.prettierrc',
              '.prettierrc.js',
              '.prettierrc.json',
              '.prettierrc.toml',
              '.prettierrc.yaml',
              '.prettierrc.yml',
              '.prettierignore',
            }, { path = ctx.filename, upward = true })[1]
          end,
        },
        biome = {
          condition = function(self, ctx)
            return vim.fs.find('biome.json', { path = ctx.filename, upward = true })[1]
          end,
        },
      },
    },
  },
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      
      lint.linters_by_ft = {
        javascript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescript = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
      }

      local function has_eslint_config()
        local config_files = vim.fs.find({
          '.eslintrc',
          '.eslintrc.js',
          '.eslintrc.json',
          '.eslintrc.cjs',
          '.eslintrc.yaml',
          '.eslintrc.yml',
          'eslint.config.js',
          'eslint.config.mjs',
          'eslint.config.cjs',
        }, { upward = true })
        
        if #config_files > 0 then
          return true
        end
        
        local package_json_files = vim.fs.find('package.json', { upward = true })
        for _, file in ipairs(package_json_files) do
          local ok, package_json = pcall(vim.fn.json_decode, vim.fn.readfile(file))
          if ok and package_json.eslintConfig then
            return true
          end
        end
        
        return false
      end

      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          local ft = vim.bo.filetype
          if vim.tbl_contains({ 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }, ft) then
            if has_eslint_config() then
              lint.try_lint()
            end
          else
            lint.try_lint()
          end
        end,
      })

      vim.keymap.set('n', '<leader>cl', function()
        if vim.tbl_contains({ 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }, vim.bo.filetype) then
          if has_eslint_config() then
            lint.try_lint()
          else
            vim.notify('No ESLint config found', vim.log.levels.INFO)
          end
        else
          lint.try_lint()
        end
      end, { desc = 'Trigger linting for current file' })
    end,
  },
}