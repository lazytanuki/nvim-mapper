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
    config = function() require("nvim-mapper").setup{} end,
    before = "telescope.nvim"
}
```

> Note that nvim-mapper needs to be one of the first plugins to load, if you want to use it to define your keymaps in the other plugins configuration functions.

Then in your Telescope config function, you may call the `load_extension("mapper")` function to load the Telescope extension, like so :

```lua
use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
    config = function() require("telescope").load_extension("mapper") end
}
```

Here are the defaults for the `setup()` method (that needs to be called) :

```lua
require("nvim-mapper").setup({
    -- do not assign the default keymap (<leader>MM)
    no_map = false,
    -- where should ripgrep look for your keybinds definitions.
    -- Default config search path is ~/.config/nvim/lua
    search_path = os.getenv("HOME") .. "/.config/nvim/lua",
    -- what should be done with the selected keybind when pressing enter.
    -- Available actions:
    --   * "definition" - Go to keybind definition (default)
    --   * "execute" - Execute the keybind command
    action_on_enter = "definition",
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
-- For Neovim < v0.7.0
vim.api.nvim_set_keymap('n', '<leader>P', ":MarkdownPreview<CR>", {silent = true, noremap = true})

-- For Neovim >= v0.7.0
vim.keymap.set({ "i", "s" }, '<c-k>', function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, {silent = true})

-- The same using nvim-mapper
Mapper = require("nvim-mapper")

-- For Neovim < v0.7.0
Mapper.map('n', '<leader>P', ":MarkdownPreview<CR>", {silent = true, noremap = true}, "Markdown", "md_preview", "Display Markdown preview in Qutebrowser")

-- For Neovim >= 0.7.0
Mapper.map({ "i", "s" }, '<c-k>', function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump(1)
  end
end, {silent = true}, "Snippets", "snippet_jump_or_expand", "Expand or jump to next snippet placeholder")
```

### Buffer keymaps :

```lua
-- A stock buffer keymap
-- For Neovim < v0.7.0
vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {noremap = true, silent = true})

-- For Neovim >= v0.7.0
vim.keymap.set({ "i", "s" }, '<c-k>', function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, {silent = true, buffer = 5})

-- The same using nvim-mapper
Mapper = require("nvim-mapper")

-- For Neovim < v0.7.0
Mapper.map_buf(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {noremap = true, silent = true}, "LSP", "lsp_definitions", "Go to definition")

-- For Neovim >= 0.7.0
Mapper.map_buf(bufnr, { "i", "s" }, '<c-k>', function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump(1)
  end
end, {silent = true}, "Snippets", "snippet_jump_or_expand", "Expand or jump to next snippet placeholder")

-- Alternatively for Neovim >= 0.7.0, the standard map() function can be used, specifying bufnr in the options table
Mapper.map({ "i", "s" }, '<c-k>', function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump(1)
  end
end, {silent = true, buffer = bufnr}, "Snippets", "snippet_jump_or_expand", "Expand or jump to next snippet placeholder")
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
    M.map_buf = function(bufnr, mode, keys, cmd, options, _, _, _)
        vim.api.nvim_buf_set_keymap(bufnr, mode, keys, cmd, options)
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
