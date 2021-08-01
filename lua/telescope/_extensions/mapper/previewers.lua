local previewers = require("telescope.previewers")
local utils = require('telescope.utils')
local defaulter = utils.make_default_callable

local M = {}

M.previewer = defaulter(function(_)
    return previewers.new_buffer_previewer({
        title = "Mapping details",
        define_preview = function(self, entry, _)
            -- Find the mapping corresponding to the entry
            for i, _ in pairs(vim.g.mapper_records) do
                if (vim.g.mapper_records[i].unique_identifier == entry.unique_identifier) then
                    -- Write the entry lines
                    local lines = entry.lines
                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

                    -- Set wrap for the preview window
                    vim.api.nvim_win_set_option(self.state.winid, "wrap", true)

                    -- Color
                    local syntax_matches = {
                        nvim_mapper_id = "^Id",
                        nvim_mapper_cat = "^Category",
                        nvim_mapper_mode = "^Mode",
                        nvim_mapper_keys = "^Keys",
                        nvim_mapper_cmd = "^Command",
                        nvim_mapper_buf_only = "^Buffer only",
                        nvim_mapper_description = "^Description",
                        nvim_mapper_opts = "^Options",
                        nvim_mapper_definition = "^Definition",
                    }

                    -- Syntax colors
                    for key, value in pairs(syntax_matches) do
                        vim.api.nvim_buf_call(self.state.bufnr, function() vim.cmd(":syntax match " .. key .. " \"" .. value .. "\"") end)
                        vim.api.nvim_buf_call(self.state.bufnr, function() vim.cmd(":hi link " .. key .. " Operator") end)

                        if (key == "nvim_mapper_keys" or key == "nvim_mapper_cmd" or key == "nvim_mapper_opts" or key == "nvim_mapper_id" or key == "nvim_mapper_definition") then
                            vim.api.nvim_buf_call(self.state.bufnr, function()
                                -- "\(^Definition: \+\)\@<=.*"
                                vim.cmd(":syntax match MapperCode '\\(" .. value .. ": \\+\\)\\@<=.*'")
                            end)
                        end
                        vim.api.nvim_buf_call(self.state.bufnr, function() vim.cmd(":hi link MapperCode Comment") end)
                    end
                end
            end
        end
    })
end, {})

return M
