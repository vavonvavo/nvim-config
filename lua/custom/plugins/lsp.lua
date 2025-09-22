return {
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      on_attach = function(client, bufnr)
        -- Disable formatting since we use conform.nvim
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
      settings = {
        typescript = {
          format = { enable = false },
          preferences = {
            importModuleSpecifier = 'relative',
          },
        },
        javascript = {
          format = { enable = false },
          preferences = {
            importModuleSpecifier = 'relative',
          },
        },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local lspconfig = require 'lspconfig'
      local util = require 'lspconfig.util'

      -- Get enhanced capabilities from cmp
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Server configurations
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              analyses = { unusedparams = true },
              staticcheck = true,
              usePlaceholders = true,
            },
          },
        },
        graphql = {
          cmd = { 'graphql-languageserver', '--method', 'textDocument/hover' },
          filetypes = { 'graphql', 'typescriptreact', 'javascriptreact' },
          settings = {
            graphql = { format = true },
          },
        },
        buf_ls = {
          cmd = { 'buf-ls', 'serve' },
          filetypes = { 'proto' },
          settings = {
            buf = { lint = true },
          },
        },
        cssls = {
          settings = {
            css = { validate = true },
            scss = { validate = true },
            less = { validate = true },
          },
        },
      }

      -- Setup servers
      for server, config in pairs(servers) do
        config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})
        lspconfig[server].setup(config)
      end

      -- Conditional biome setup
      local root_dir = util.root_pattern('biome.json', '.git')(vim.fn.getcwd())
      if root_dir and vim.fn.filereadable(root_dir .. '/biome.json') == 1 then
        lspconfig.biome.setup {
          capabilities = capabilities,
          root_dir = util.root_pattern('biome.json', '.git'),
        }
      end

      -- Mason tool installer for servers and tools
      require('mason-tool-installer').setup {
        ensure_installed = {
          'lua-language-server',
          'stylua',
          'eslint_d',
          'prettier',
          'gopls',
          'graphql-language-service-cli',
          'buf',
          'css-lsp',
        },
      }
    end,
  },
}
