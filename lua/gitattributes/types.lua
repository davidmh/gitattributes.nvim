---@class GitAttributesConfig
---@field debug boolean Controls debug logging
---@field on_match fun(data: GitAttributesData) Called when a match is found
---@field setup fun(opts: GitAttributesConfig) Sets up the configuration

---@class GitAttributeExpression
---@field pattern string The glob pattern
---@field attributes string[] The attribute associated with the pattern

---@class GitAttributesData
---@field path string The file path
---@field buffer number The buffer number
---@field attributes GitAttributes The attributes associated with the file

---@class GitAttributes
---@field linguist-generated boolean?
---@field linguist-language string?
---@field text boolean|string?
---@field diff string?
