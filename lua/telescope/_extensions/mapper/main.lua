-- telescope modules
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

-- telescope-mapper modules
local _finders = require("telescope._extensions.mapper.finders")
local _previewers = require("telescope._extensions.mapper.previewers")
local _utils = require("telescope._extensions.mapper.utils")

local M = {}

-- This creates a picker with a list of all of the mappers
M.mapper = function(opts)
    pickers.new(opts or {}, {
        prompt_title = 'Select a mapping',
        results_title = 'Mappings',
        finder = _finders.mapper_finder(_utils.get_mappers()),
        sorter = conf.generic_sorter(opts),
        previewer = _previewers.previewer.new(opts)
    }):find()
end

return M
