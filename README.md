This neovim plugin aims at helping you keep track of your keymaps.

It is meant to work with the [telescope](https://github.com/nvim-telescope/telescope.nvim) plugin.
It helps you search for currently active keymaps, get info about them, and jump to their definition if you want to change them.

![demo](https://user-images.githubusercontent.com/36456999/127230715-88411776-3ff1-40ca-85f9-4cad75f6d2cb.gif)

Installation
============

Install using your favorite plugin manager ! Here with packer :

```lua
use {
    "lazytanuki/nvim-mapper",
    config = function() require("nvim-mapper").setup{} end
}
```

Here are the defaults for the `setup()` method (that needs to be called) :

```lua
require("nvim-mapper").setup({
    no_map = false,                                        -- do not assign the default keymap (<leader>MM)
    search_path = os.getenv("HOME") .. "/.config/nvim/lua" -- default config search path is ~/.config/nvim/lua
})
```

Requirements
------------

To use this plugin, you need to have **ripgrep** installed.

Usage
=====

Defining your keymaps with nvim-mapper
--------------------------------------

To use this plugin, you need to define your keymaps with `nvim-mapper` functions instead of stock functions.

Defining a keymap with nvim-mapper is pretty much the same as with the stock lua function, except that some additional info is required :

### Global keymaps :

```lua
-- A stock keymap
vim.api.nvim_set_keymap('n', '<leader>P', ":MarkdownPreview<CR>", {silent = true, noremap = true})

-- The same using nvim-mapper
Mapper = require("nvim-mapper")
Mapper.map('n', '<leader>P', ":MarkdownPreview<CR>", {silent = true, noremap = true}, "Markdown", "md_preview", "Display Markdown preview in Qutebrowser")
```

### Buffer keymaps :

```lua
-- A stock buffer keymap
vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {noremap = true, silent = true})

-- The same using nvim-mapper
Mapper = require("nvim-mapper")
Mapper.map_buf(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {noremap = true, silent = true}, "LSP", "lsp_definitions", "Go to definition")
```

### Virtual keymaps :

Not all keymaps are ones you defined yourself. You can also create "virtual" keymaps to document other keymaps, such as default keymaps. Here is an example with [nvim-treesitter-textobjects configuration](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) :

```lua
function M.treesitter_text_objects()
    require("nvim-treesitter.configs").setup {
        textobjects = {
            select = {
                enable = true,
                lookahead = true,
                -- The keymaps are defined in the configuration table, no way to get our Mapper in there !
                keymaps = {
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ac"] = "@class.outer",
                    ["ic"] = "@class.inner"
                }
            }
        }
    }
    -- Hopefully we can still document them
    Mapper.map_virtual("o", "af", "", {}, "Navigation", "treesitter_function_outer", "Function outer motion")
    Mapper.map_virtual("o", "if", "", {}, "Navigation", "treesitter_function_inner", "Function inner motion")
    Mapper.map_virtual("o", "ac", "", {}, "Navigation", "treesitter_class_outer", "Class outer motion")
    Mapper.map_virtual("o", "ic", "", {}, "Navigation", "treesitter_class_inner", "Class inner motion")
end
```

Looking for keymaps
-------------------

The default keymap to open the Telescope extension is `<leader>MM`.

The command would be `:Telescope mapper`.

You can jump to the keymap definition by using your own Telescope keymaps (open in new tab, in split, ...)

Prevent issues when module is not installed
-------------------------------------------

To avoid having a non-functional config when the module is not currently installed, place this file somewhere in your `lua` folder :

```lua
local M = {}

local function is_module_available(name)
    if package.loaded[name] then
        return true
    else
        for _, searcher in ipairs(package.searchers or package.loaders) do
            local loader = searcher(name)
            if type(loader) == 'function' then
                package.preload[name] = loader
                return true
            end
        end
        return false
    end
end

if is_module_available("nvim-mapper") then
    local mapper = require("nvim-mapper")

    M.map = function(mode, keys, cmd, options, category, unique_identifier,
                     description)
        mapper.map(mode, keys, cmd, options, category, unique_identifier,
                   description)
    end
    M.map_buf = function(bufnr, mode, keys, cmd, options, category, unique_identifier,
                         description)
        mapper.map_buf(bufnr, mode, keys, cmd, options, category, unique_identifier,
                       description)
    end
    M.map_virtual = function(mode, keys, cmd, options, category,
                             unique_identifier, description)
        mapper.map_virtual(mode, keys, cmd, options, category,
                           unique_identifier, description)
    end
    M.map_buf_virtual = function(mode, keys, cmd, options, category,
                                 unique_identifier, description)
        mapper.map_buf_virtual(mode, keys, cmd, options, category,
                               unique_identifier, description)
    end
else
    M.map = function(mode, keys, cmd, options, _, _, _)
        vim.api.nvim_set_keymap(mode, keys, cmd, options)
    end
    M.map_buf = function(mode, keys, cmd, options, _, _, _)
        vim.api.nvim_buf_set_keymap(mode, keys, cmd, options)
    end
    M.map_virtual = function(_, _, _, _, _, _, _) return end
    M.map_buf_virtual = function(_, _, _, _, _, _, _) return end

end

return M
```

You can then use the mapper function safely like this :

```lua
Mapper = require(<path to previous file>)

Mapper.map(...)
```

Credits
=======

Huge thanks to the Neovim team for the awesome work ! 😋

Also, thanks to :

- people behind [Telescope](https://github.com/nvim-telescope/telescope.nvim) for the great plugin
- people behind the [telescope-project](https://github.com/nvim-telescope/telescope-project.nvim) plugin, which code I used to understand the Telescope API
