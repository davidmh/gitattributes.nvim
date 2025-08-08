# gitattributes.nvim

A Neovim plugin to detect properties defined in [gitattributes] files,
including the extended attributes used by the [Linguist overrides] for
GitHub/GitLab.

## Installation

Using lazy.nvim

```lua
{ "davidmh/gitattributes.nvim" }
```

## Default config

The default configuration covers the two use cases I found most useful:

- Setting a filetype for files using the `linguist-language=<language>` attribute.
- Revoke write permissions for files matching the `linguist-generated` attribute.


```lua
vim.g.gitattributes_config = {
    ---@param data GitAttributesData
    on_match = function(data)
        if data.attributes["linguist-generated"] then
            vim.bo[data.buffer].readonly = true
            vim.bo[data.buffer].modifiable = false
        end
        if data.attributes["linguist-language"] then
            vim.bo[data.buffer].filetype = data.attributes["linguist-language"]
        end
    end
}

```

## Notes

The type for the attributes includes only a subset of the attributes defined in
the [gitattributes] documentation, but all the attributes should be available
at runtime.

[gitattributes]: https://git-scm.com/docs/gitattributes
[Linguist overrides]: https://github.com/github-linguist/linguist/blob/main/docs/overrides.md
