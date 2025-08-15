return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  -- Configure the plugin
  config = function()
    require("refactoring").setup({
      -- Custom print statements for C++
      print_var_statements = {
        cpp = {
          -- This function creates a 'std::cout' line to print a variable's name and value
          -- For example, for a variable 'myVar', it generates:
          -- std::cout << "myVar: " << myVar << std::endl;
          'std::cout << "%s: " << %s << std::endl;',
        },
      },
      printf_statements = {
        cpp = {
          -- This creates a 'std::cout' line to mark a location in the code with file and line number
          -- It generates:
          -- std::cout << "HERE: full/path/to/file.cpp:123" << std::endl;
          'std::cout << "HERE: %s: " << __FILE__ << ":" << __LINE__ << std::endl;',
        },
      },
    })
  end,
}
