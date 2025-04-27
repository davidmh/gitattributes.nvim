local config = require("gitattributes.config")

local M = {}

local LOG_PATH = vim.fn.stdpath("cache") .. "/gitattributes.log"

--- Holds the cache for gitattributes files, indexed by their path and modification time.
---@type table<string, table<number, GitAttributeExpression>>
local GITATTRIBUTES_CACHE = {}

--- Find the nearest .gitattributes file relative to the given path.
---@param file_path string The current file path
---@return string? path The path to the folder containing the .gitattributes file
function M.find_root(file_path)
    return vim.fs.root(vim.fs.dirname(file_path), { ".gitattributes" })
end

--- Reads the contents of a .gitattributes file and returns the dictionary of
--- glob patterns to attributes.
---@param gitattributes_path string The path to the .gitattributes file
---@return table<number, GitAttributeExpression> prop_dict The list of dictionaries containing the glob patterns and attributes
function M.get_prop_dictionary(gitattributes_path)
    local stat, err = vim.uv.fs_stat(gitattributes_path)
    if err then
        M.log(gitattributes_path, err)
        return {}
    end
    local cache_key = gitattributes_path .. ":" .. stat.mtime.sec
    if GITATTRIBUTES_CACHE[cache_key] then
        return GITATTRIBUTES_CACHE[cache_key]
    end

    local results = {}

    for _, line in ipairs(vim.fn.readfile(gitattributes_path)) do
        -- Skip empty lines and comments
        if line:match("^%s*$") or line:match("^#") then
            goto skip
        end

        -- Split the line into pattern and attributes
        local parts = vim.split(line, "%s+", { trimempty = true })
        if #parts >= 2 then
            -- The first element is the pattern, the rest are the attributes
            local pattern = table.remove(parts, 1)
            table.insert(results, {
                pattern = pattern,
                attributes = parts,
            })
        end

        ::skip::
    end

    return results
end

--- Find the gitattributes associated with the current file.
---@param path string The current file path
---@return GitAttributes attributes The list of gitattributes matching the file
function M.file_attributes(path)
    local gitattributes_root = M.find_root(path)
    local attributes_dict = {}

    if not gitattributes_root then
        return {}
    end

    local gitattributes_path = vim.fs.joinpath(gitattributes_root, ".gitattributes")

    local prop_dict = M.get_prop_dictionary(gitattributes_path)
    local relative_path = vim.fs.relpath(gitattributes_root, path)

    if relative_path == nil then
        return {}
    end

    for _, entry in ipairs(prop_dict) do
        local pattern = vim.glob.to_lpeg(entry.pattern)
        if pattern:match(relative_path) ~= nil then
            for _, attr in ipairs(entry.attributes) do
                local parts = vim.split(attr, "=", { trimempty = true })
                local attribute_name = table.remove(parts, 1)
                if vim.startswith(attribute_name, "-") then
                    attributes_dict[attribute_name:sub(2)] = false
                else
                    attributes_dict[attribute_name] = parts[1] or true
                end
            end
        end
    end

    return attributes_dict
end

---@param label string
---@param message string?
function M.log(label, message)
    if config.debug then
        vim.schedule(function()
            local log_message = string.format("[%s] %s: %s", os.date("%Y-%m-%d %H:%M:%S"), label, message or "")
            local log_file = io.open(LOG_PATH, "a")
            if log_file then
                log_file:write(log_message .. "\n")
                log_file:close()
            end
        end)
    end
end

--- Time the execution of a function and log the elapsed time.
---@generic T
---@param label string The label for the action
---@param action fun(): T The action to be timed
---@return T
function M.time(label, action)
    if config.debug then
        M.log(label .. " started")
        local start_time = vim.loop.hrtime()
        local result = action()
        local end_time = vim.loop.hrtime()
        local elapsed_time = (end_time - start_time) / 1e6
        M.log(label .. " ended", "elapsed_time = " .. elapsed_time)
        return result
    end

    return action()
end

return M
