require("hibiya")
-- nvim config starts here

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", {desc = "Exit Terminal Mode"})
vim.keymap.set("n", "<leader>m", function() 
    local line = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, line - 1, line - 1, false, {"# %%"})
end, {desc = "For REPL python execution for Data Science"})
