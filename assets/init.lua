require("lazy").setup({
  "folke/which-key.nvim",
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  "folke/neodev.nvim",
})

require("melange").setup (
    { "savq/melange-nvim" }
)


vim.cmd.colorscheme 'melange'