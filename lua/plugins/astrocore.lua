-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false, -- sets vim.opt.relativenumber
        number = false, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      n = {
         -- Diffview git diffing
        ["<Leader>gdd"] = {"<cmd>DiffviewOpen<cr>", desc = "Open diff view of the working tree"},
        ["<Leader>gdm"] = {"<cmd>DiffviewOpen master..HEAD<cr>", desc = "Compare current branch with master"},
        ["<Leader>gdf"] = {"<cmd>DiffviewFileHistory --follow %<cr>", desc = "View current file history"},
        ["<Leader>gdl"] = {"<cmd>.DiffviewFileHistory --follow<cr>", desc = "View line history"},
        ["<Leader>gdc"] = {"<cmd>DiffviewClose<cr>", desc = "Close diff views"},
        ["<Leader>gdh"] = {"<cmd>DiffviewFileHistory<CR>", desc = "View entire history"},

        -- Hunk-based Diffing (with gitsigns.nvim)
        ["<Leader>ghp"] = { function() require("gitsigns").preview_hunk() end, desc = "Preview hunk" },
        ["<Leader>ghs"] = { function() require("gitsigns").stage_hunk() end, desc = "Stage hunk" },
        ["<Leader>ghu"] = { function() require("gitsigns").undo_stage_hunk() end, desc = "Unstage hunk" },
        ["<Leader>ghr"] = { function() require("gitsigns").reset_hunk() end, desc = "Reset hunk" },
        
        -- Visual Enhancements (Word or Line Diffs)
        ["<Leader>gtw"] = { function() require("gitsigns").toggle_word_diff() end, desc = "Toggle word diff highlight" },
        ["<Leader>gtl"] = { function() require("gitsigns").toggle_linehl() end, desc = "Toggle line highlight" },
        ["<Leader>gtd"] = { function() require("gitsigns").toggle_deleted() end, desc = "Toggle highlight deleted lines" },

        -- Non-LSP recursive file search h/cpp swap
        ["<Leader>h"] = { "<cmd>Ouroboros<cr>", desc = "Switch between header/source file" },
        
        -- Clangd hotkeys (Swap source and find def/ref)
        ["<Leader>H"] = {"<cmd>ClangdSwitchSourceHeader<cr>",  desc = "Switch between header/source file" },
        ["<Leader>fd"] = { function() vim.lsp.buf.definition() end, desc = "Go to Definition"},
        ["<Leader>fD"] = { function() vim.lsp.buf.declaration() end, desc = "Go to Declaration"},
        ["<Leader>fr"] = { function() require("snacks.picker").lsp_references() end, desc = "Go to References"},
        ["<Leader>ca"] = { function() vim.lsp.buf.code_action() end, desc = "Code actions"},
        
        -- Requires newer clangd version 20
        ["<Leader>fh"] = { function() vim.lsp.buf.typehierarchy() end, desc = "Find Type Hierarchy (Base / Derived Classes)"},
        ["<Leader>fi"] = { function() vim.lsp.buf.incoming_calls() end, desc = "Incoming Calls (Who calls me?)"},
        ["<Leader>fo"] = { function() vim.lsp.buf.outgoing_calls() end, desc = "Outgoing calls (Who do I call?)"},
        ["<Leader>fn"] = { function() vim.lsp.buf.rename() end, desc = "Rename symbol across project"},
        ["<leader>fst"] = { "<cmd>ClangdAST<cr>", desc = "View Clangd AST" },


        -- Tab between buffers
        ["<Tab>"] = { function() require("astrocore.buffer").nav(1) end, desc = "Next buffer"},
        ["<S-Tab>"] = { function() require("astrocore.buffer").nav(-1) end, desc = "Previous buffer"},

        -- Refactoring.nvim mappings
        ["<leader>rr"] = { function() require('refactoring').select_refactor() end, desc = "Refactor: Select" },
        ["<leader>ri"] = { function() require('refactoring').refactor('Inline Variable') end, desc = "Refactor: Inline Variable" },
        ["<leader>rdp"] = { function() require('refactoring').debug.printf() end, desc = "Refactor: Debug Print" },
        ["<leader>rdv"] = { function() require('refactoring').debug.print_var() end, desc = "Refactor: Debug Print Variable" },
      },
      v = {
        -- Refactoring.nvim mappings
        ["<leader>rr"] = { function() require('refactoring').select_refactor() end, desc = "Refactor: Select" },
        ["<leader>re"] = { function() require('refactoring').refactor('Extract Function') end, desc = "Refactor: Extract Function" },
        ["<leader>rv"] = { function() require('refactoring').refactor('Extract Variable') end, desc = "Refactor: Extract Variable" },
        ["<leader>ri"] = { function() require('refactoring').refactor('Inline Variable') end, desc = "Refactor: Inline Variable" },
        ["<leader>rdp"] = { function() require('refactoring').debug.printf() end, desc = "Refactor: Debug Print" },
        ["<leader>rdv"] = { function() require('refactoring').debug.print_var() end, desc = "Refactor: Debug Print Variable" },

        -- Clangd AST from visual selection
        ["<leader>fst"] = { "<cmd>ClangdAST<cr>", desc = "View Clangd AST" },

      },
    },
  },
}
