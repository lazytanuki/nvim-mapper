local finders = require("telescope.finders")
local strings = require("plenary.strings")
local entry_display = require("telescope.pickers.entry_display")

local M = {}

local function mode_highlight(mode)
    if (mode == "i") then
        return "Special"
    elseif (mode == "n") then
        return "SpecialChar"
    elseif (mode == "v") then
        return "Visual"
    else
        return "Normal"
    end
end

-- Creates a Telescope `finder` based on the given options
-- and list of mappers
M.mapper_finder = function(mappers)
    local widths = {
        keys = 0,
        category = 0,
        description = 0,
        mode = 0,
        cmd = 0
    }

    -- The mapper has the following keys :
    -- - buffer_only: bool
    -- - category: str
    -- - cmd: str
    -- - keys: str
    -- - mode: str
    -- - options: table
    -- - where_file: str
    -- - where_line: int
    --
    -- We want the display line to be like this :
    -- category mapping description

    -- Loop over all of the mappers and find the maximum length of
    -- each of the keys
    for _, mapper in pairs(mappers) do
        mapper.description_display = mapper.description
        for key, value in pairs(widths) do
            widths[key] = math.max(value,
                                   strings.strdisplaywidth(mapper[key] or ''))
        end
    end

    -- The mapper display line
    local displayer = entry_display.create {
        -- separator = " | ",
        separator = " ▏",
        items = {
            {width = widths.category},
            {width = widths.mode},
            {width = widths.keys},
            {width = widths.description},
            {width = widths.cmd},

        }
    }
    local make_display = function(mapper)
        return displayer {
            {mapper.category, "TelescopeResultsClass"},
            {mapper.mode, mode_highlight(mapper.mode)},
            {mapper.keys, "TelescopeResultsComment"},
            {mapper.description},
        }
    end

    return finders.new_table {
        results = mappers,
        entry_maker = function(mapper)
            mapper.value = mapper.description
            mapper.ordinal = mapper.description .. mapper.unique_identifier .. mapper.keys .. mapper.category
            mapper.display = make_display
            mapper.id = mapper.unique_identifier
            mapper.lines = mapper.lines
            return mapper
        end
    }
end

return M
