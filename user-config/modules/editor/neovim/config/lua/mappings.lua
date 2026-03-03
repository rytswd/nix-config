require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- ============================================================
-- Emacs-style keybindings (all modes)
-- ============================================================

-- Movement — insert mode
map("i", "<C-a>", "<Home>", { desc = "Beginning of line" })
map("i", "<C-e>", "<End>", { desc = "End of line" })
map("i", "<C-f>", "<Right>", { desc = "Forward char" })
map("i", "<C-b>", "<Left>", { desc = "Backward char" })
map("i", "<C-n>", "<Down>", { desc = "Next line" })
map("i", "<C-p>", "<Up>", { desc = "Previous line" })
map("i", "<M-f>", "<S-Right>", { desc = "Forward word" })
map("i", "<M-b>", "<S-Left>", { desc = "Backward word" })

-- Movement — normal mode
map("n", "<C-a>", "^", { desc = "Beginning of line (first non-blank)" })
map("n", "<C-e>", "$", { desc = "End of line" })
map("n", "<C-f>", "l", { desc = "Forward char" })
map("n", "<C-b>", "h", { desc = "Backward char" })
map("n", "<C-n>", "j", { desc = "Next line" })
map("n", "<C-p>", "k", { desc = "Previous line" })
map("n", "<M-f>", "w", { desc = "Forward word" })
map("n", "<M-b>", "b", { desc = "Backward word" })

-- Movement — visual mode
map("v", "<C-a>", "^", { desc = "Beginning of line (first non-blank)" })
map("v", "<C-e>", "$", { desc = "End of line" })
map("v", "<C-f>", "l", { desc = "Forward char" })
map("v", "<C-b>", "h", { desc = "Backward char" })
map("v", "<C-n>", "j", { desc = "Next line" })
map("v", "<C-p>", "k", { desc = "Previous line" })
map("v", "<M-f>", "w", { desc = "Forward word" })
map("v", "<M-b>", "b", { desc = "Backward word" })

-- Deletion — insert mode
map("i", "<C-d>", "<Del>", { desc = "Delete char forward" })
map("i", "<C-k>", "<C-o>D", { desc = "Kill to end of line" })
map("i", "<M-d>", "<C-o>de", { desc = "Kill word forward" })
map("i", "<M-BS>", "<C-w>", { desc = "Kill word backward" })

-- Deletion — normal mode
map("n", "<C-d>", "x", { desc = "Delete char forward" })
map("n", "<C-k>", "D", { desc = "Kill to end of line" })
map("n", "<M-d>", "de", { desc = "Kill word forward" })
map("n", "<M-BS>", "db", { desc = "Kill word backward" })

-- Deletion — visual mode
map("v", "<C-d>", "d", { desc = "Delete selection" })
map("v", "<C-k>", "D", { desc = "Kill to end of line" })
map("v", "<M-d>", "d", { desc = "Delete selection" })

-- Command-line mode
map("c", "<C-a>", "<Home>", { desc = "Beginning of line" })
map("c", "<C-e>", "<End>", { desc = "End of line" })
map("c", "<C-f>", "<Right>", { desc = "Forward char" })
map("c", "<C-b>", "<Left>", { desc = "Backward char" })
map("c", "<C-d>", "<Del>", { desc = "Delete char forward" })
map("c", "<M-f>", "<S-Right>", { desc = "Forward word" })
map("c", "<M-b>", "<S-Left>", { desc = "Backward word" })
map("c", "<M-BS>", "<C-w>", { desc = "Kill word backward" })
