local has_telescope, telescope = pcall(require, 'telescope')
local main = require('telescope._extensions.mapper.main')
local utils = require('telescope._extensions.mapper.utils')

if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
end

utils.init_file()

return telescope.register_extension{
  setup = main.setup,
  exports = { mapper = main.mapper }
}
