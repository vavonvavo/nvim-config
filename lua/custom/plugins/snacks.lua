return {
  {
    'folke/snacks.nvim',
    ---@type snacks.Config
    opts = {
      picker = { enabled = true },
    },
    keys = {
      {
        '<leader>gg',
        function()
          Snacks.lazygit()
        end,
        desc = 'Lazygit',
      },
    },
  },
}
