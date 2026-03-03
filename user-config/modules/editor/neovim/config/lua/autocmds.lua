require "nvchad.autocmds"

-- Soft wrap with adaptive indentation for prose filetypes
local prose_filetypes = { markdown = true, org = true, text = true, rst = true, asciidoc = true }

vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  callback = function()
    local ft = vim.bo.filetype
    if prose_filetypes[ft] then
      vim.wo.wrap = true
      vim.wo.linebreak = true
      vim.wo.breakindent = true
      vim.opt_local.breakindentopt = "shift:2"
    end
  end,
})
