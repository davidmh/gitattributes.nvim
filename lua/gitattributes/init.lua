local config = require("gitattributes.config")
local utils = require("gitattributes.utils")

local M = {}

---@param opts GitAttributesConfig
function M.setup(opts)
    config.setup(opts or {})

    local group = vim.api.nvim_create_augroup("gitattributes", { clear = true })
    vim.api.nvim_create_autocmd("BufReadPost", {
        group = group,
        callback = function(args)
            if vim.bo[args.buf].buftype ~= "" or args.file == "" then
                return
            end

            vim.schedule(function()
                local attributes = utils.file_attributes(args.file)
                if vim.tbl_isempty(attributes) then
                    return
                end

                local data = {
                    path = args.file,
                    buffer = args.buf,
                    attributes = attributes,
                }
                local ok, _ = pcall(config.on_match, data)
                if not ok then
                    vim.notify(
                        "Error running on_match with params: " .. vim.inspect(data),
                        vim.log.levels.ERROR,
                        { title = "gitattributes.nvim" }
                    )
                end
            end)
        end,
    })
end

return M
