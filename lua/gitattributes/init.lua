local M = {}

function M.setup()
    vim.notify_once(
        "No need to call setup, set vim.g.gitattributes_config instead",
        vim.log.levels.INFO,
        { title = "gitattributes.nvim" }
    )
end

return M
