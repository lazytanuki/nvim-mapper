-- nvim-mapper
local M = {}

-- Set a mapping
local function map(virtual, buffnr, mode, keys, cmd, options, category,
                   unique_identifier, description)

    if vim.g.mapper_records == nil then vim.g.mapper_records = {} end

    local buffer_only
    if buffnr == nil then
        buffer_only = false
    else
        buffer_only = true
    end

    local record = {
        mode = mode,
        keys = keys,
        cmd = cmd,
        options = options,
        category = category,
        unique_identifier = unique_identifier,
        description = description,
        buffer_only = buffer_only
    }

    local new_records = vim.g.mapper_records

    -- Check unique_identifier collisons
    local already_defined = false
    for i, _ in pairs(vim.g.mapper_records) do
        local other_record = vim.g.mapper_records[i]
        if (other_record.unique_identifier == unique_identifier) then
            already_defined = true
            -- If the exact same mapping exists, do not redefine
            -- If the same unique_identifier exists but the rest is not the same, print error
            if (other_record.mode == mode and other_record.keys == keys and
                other_record.cmd == cmd and other_record.category == category and
                other_record.description == description) then
            else
                print(
                    "Mapper error : unique identifier " .. unique_identifier ..
                        " cannot be used twice")
            end

        end
    end

    if not already_defined then table.insert(new_records, record) end
    vim.g.mapper_records = new_records

    -- Set the mapping
    if not virtual then
        if buffnr ~= nil then
            vim.api.nvim_buf_set_keymap(buffnr, mode, keys, cmd, options)
        else
            vim.api.nvim_set_keymap(mode, keys, cmd, options)
        end
    end
end

-- Set a buffer mapping
function M.map_buf(buffnr, mode, keys, cmd, options, category,
                   unique_identifier, description)
    map(false, buffnr, mode, keys, cmd, options, category, unique_identifier,
        description)
end

-- Set a global mapping
function M.map(mode, keys, cmd, options, category, unique_identifier,
               description)
    map(false, nil, mode, keys, cmd, options, category, unique_identifier,
        description)
end

-- Set a virtual buffer mapping
function M.map_buf_virtual(mode, keys, cmd, options, category,
                           unique_identifier, description)
    map(true, true, mode, keys, cmd, options, category, unique_identifier,
        description)
end

-- Set a virtual global mapping
function M.map_virtual(mode, keys, cmd, options, category, unique_identifier,
                       description)
    map(true, nil, mode, keys, cmd, options, category, unique_identifier,
        description)
end

function M.setup(opts)
    -- Keymap
    if opts.no_map ~= true then
        if opts.map_toggle == nil then
            M.map("n", "<leader>MM", ":Telescope mapper<CR>", { silent = true }, "Telescope", "telescope_mapper_toggle", "Show mappings using Telescope")
        else
            M.map("n", opts.map_toggle, ":Telescope mapper<CR>", { silent = true }, "Telescope", "telescope_mapper_toggle", "Show mappings using Telescope")
        end
    end

    -- Search path
    if opts.search_path ~= nil then
        vim.g.mapper_search_path = opts.search_path
    else
        vim.g.mapper_search_path = os.getenv("HOME") .. "/.config/nvim/lua"
    end
end

return M
