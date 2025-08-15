return {
  {
    "jakemason/ouroboros.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      extension_preferences_table = {
        cpp = { h = 1 },
        h   = { cpp = 1 },
      },
    },
    config = function(_, opts)
      require("ouroboros").setup(opts)
    end,
  },
}
