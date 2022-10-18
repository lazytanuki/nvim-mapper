-- nvim-mapper
local M = {}
M.mapper_records = {}

-- Set a mapping
local function map(virtual, buffnr, mode, keys, cmd, options, category, unique_identifier, description)
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
    buffer_only = buffer_only,
  }

  maybe_existing_record = M.mapper_records[unique_identifier]

  if maybe_existing_record == nil then
    M.mapper_records[unique_identifier] = record
  elseif maybe_existing_record.mode ~= mode
      or maybe_existing_record.keys ~= keys
      or maybe_existing_record.cmd ~= cmd
      or maybe_existing_record.category ~= category
      or maybe_existing_record.description ~= description
  then
    print("Mapper error : unique identifier " .. unique_identifier .. " cannot be used twice")
  end

  -- Set the mapping
  if not virtual then
    if vim.fn.has("nvim-0.7.0") then
      if buffnr ~= nil then
        vim.keymap.set(mode, keys, cmd, vim.tbl_extend("force", options, { buffer = buffnr }))
      else
        vim.keymap.set(mode, keys, cmd, options)
      end
    else
      if buffnr ~= nil then
        vim.api.nvim_buf_set_keymap(buffnr, mode, keys, cmd, options)
      else
        vim.api.nvim_set_keymap(mode, keys, cmd, options)
      end
    end
  end
end

-- Set a buffer mapping
function M.map_buf(buffnr, mode, keys, cmd, options, category, unique_identifier, description)
  map(false, buffnr, mode, keys, cmd, options, category, unique_identifier, description)
end

-- Set a global mapping
function M.map(mode, keys, cmd, options, category, unique_identifier, description)
  map(false, nil, mode, keys, cmd, options, category, unique_identifier, description)
end

-- Set a virtual buffer mapping
function M.map_buf_virtual(mode, keys, cmd, options, category, unique_identifier, description)
  map(true, true, mode, keys, cmd, options, category, unique_identifier, description)
end

-- Set a virtual global mapping
function M.map_virtual(mode, keys, cmd, options, category, unique_identifier, description)
  map(true, nil, mode, keys, cmd, options, category, unique_identifier, description)
end

function M.setup(opts)
  -- Keymap
  if opts.no_map ~= true then
    if opts.map_toggle == nil then
      M.map(
        "n",
        "<leader>MM",
        ":Telescope mapper<CR>",
        { silent = true },
        "Telescope",
        "telescope_mapper_toggle",
        "Show mappings using Telescope"
      )
    else
      M.map(
        "n",
        opts.map_toggle,
        ":Telescope mapper<CR>",
        { silent = true },
        "Telescope",
        "telescope_mapper_toggle",
        "Show mappings using Telescope"
      )
    end
  end

  -- Search path
  if opts.search_path ~= nil then
    vim.g.mapper_search_path = opts.search_path
  else
    vim.g.mapper_search_path = vim.fn.stdpath("config") .. "/lua"
  end

  -- Selected action
  if opts.action_on_enter ~= nil then
    vim.g.mapper_action_on_enter = opts.action_on_enter
  else
    vim.g.mapper_action_on_enter = "definition"
  end
end

return M
