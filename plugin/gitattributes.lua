local group = vim.api.nvim_create_augroup("gitattributes", { clear = true })

vim.g.gitattributes_config = {
    debug = false,
    ---@param data GitAttributesData
    on_match = function(data)
        if data.attributes["linguist-generated"] then
            vim.bo[data.buffer].readonly = true
            vim.bo[data.buffer].modifiable = false
        end
        if data.attributes["linguist-language"] then
            vim.bo[data.buffer].filetype = data.attributes["linguist-language"]
        end
    end,
}

vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(args)
        local utils = require("gitattributes.utils")

        if vim.bo[args.buf].buftype ~= "" or args.file == "" then
            return
        end

        vim.schedule(function()
            local git_root = utils.find_git_root(args.file)
            if not git_root then
                return
            end
            local attributes = utils.file_attributes(args.file, git_root)
            if vim.tbl_isempty(attributes) then
                return
            end

            local data = {
                path = args.file,
                buffer = args.buf,
                attributes = attributes,
            }
            local ok, _ = pcall(vim.g.gitattributes_config.on_match, data)
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
