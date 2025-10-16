return {
  -- 1. Configure Global Mappings (for normal code buffers)
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      local maps = opts.mappings
      -- Register the Alt-keys globally
      maps.n["<M-h>"] = { function() vim.cmd("vertical resize -5") end, desc = "Resize Left" }
      maps.n["<M-j>"] = { function() vim.cmd("resize +5") end, desc = "Resize Down" }
      maps.n["<M-k>"] = { function() vim.cmd("resize -5") end, desc = "Resize Up" }
      maps.n["<M-l>"] = { function() vim.cmd("vertical resize +5") end, desc = "Resize Right" }
      return opts
    end,
  },

  -- 2. Configure Neo-tree specifically
  -- This forces the keys into the Neo-tree window configuration
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      -- Ensure window mappings table exists
      if not opts.window then opts.window = {} end
      if not opts.window.mappings then opts.window.mappings = {} end

      -- Add the resize mappings directly to Neo-tree
      opts.window.mappings["<M-h>"] = function() vim.cmd("vertical resize -5") end
      opts.window.mappings["<M-j>"] = function() vim.cmd("resize +5") end
      opts.window.mappings["<M-k>"] = function() vim.cmd("resize -5") end
      opts.window.mappings["<M-l>"] = function() vim.cmd("vertical resize +5") end

      return opts
    end,
  },
}
