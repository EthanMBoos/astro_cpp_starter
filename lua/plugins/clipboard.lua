return {
  "ojroques/nvim-osc52",
  config = function()
    local osc52 = require("osc52")

    osc52.setup {
      max_length = 0, -- No length limit
      silent = true,  -- Recommended: Set to true so holding 'x' doesn't spam "Copied!" messages
      trim = false,
    }

    local function copy()
      -- SAFETY CHECK: Ignore if the operation was explicitly sent to the black hole register ("_")
      if vim.v.event.regname == "_" then
        return
      end

      -- Otherwise, copy EVERYTHING (yanks, deletes, cuts, changes)
      local text = vim.fn.getreg(vim.v.event.regname)
      if text then
        osc52.copy(text)
      end
    end

    vim.api.nvim_create_autocmd("TextYankPost", { callback = copy })
  end,
}
