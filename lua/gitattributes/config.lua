local M = {
    debug = false,
}

---@param opts GitAttributesConfig
function M.setup(opts)
    M.debug = opts.debug or M.debug
    M.on_match = opts.on_match or M.on_match
end

---@param data GitAttributesData
function M.on_match(data)
    if data.attributes["linguist-generated"] then
        vim.bo[data.buffer].readonly = true
        vim.bo[data.buffer].modifiable = false
    end
    if data.attributes["linguist-language"] then
        vim.bo[data.buffer].filetype = data.attributes["linguist-language"]
    end
end

---@type GitAttributesConfig
return M
