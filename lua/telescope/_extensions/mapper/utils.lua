local Path = require('plenary.path')
local job = require("plenary.job")

local M = {}

-- Fetches mapper information to be passed to picker
M.get_mappers = function()
  -- Search path
  local search_dir = vim.g.mapper_search_path

  -- Initialization
  local records = require('nvim-mapper').mapper_records
  local regex_table = {}

  if records == nil then
    return {}
  end

  -- For each record, build a regex
  for unique_identifier, record in pairs(records) do
    local regex = '\\((.+,\\s*)+"' .. unique_identifier .. '"\\s*,.+\\)'
    table.insert(regex_table, regex)
    record.regex = regex
  end

  -- Use rg to find all of these regex in one run
  local rg_regex = "(" .. table.concat(regex_table, "|") .. ")"
  job:new({
    command = "rg",
    args = {
      rg_regex, search_dir, "--color=never",
      "--line-number",
      "--multiline",
      "--multiline-dotall",
    },
    cwd = "/usr/bin",
    on_exit = function(j, return_val)
      if (return_val ~= 0) then
        print("Rg error")
        -- return
      end

      vim.g.nvim_mapper_rg_output = j:result()
    end
  }):sync()

  -- Scan the output to match the results with the mappings
  local rg_output = vim.g.nvim_mapper_rg_output

  for i, _ in pairs(rg_output) do
    local rg_record = rg_output[i]
    for j, _ in pairs(records) do
      if (string.find(rg_record, records[j].unique_identifier) ~= nil) then
        -- Get the file path and line number for mappings
        local rg_record_split = vim.split(rg_record, ":")

        -- Get file path
        records[j].filename = rg_record_split[1]

        -- Get line number
        records[j].row = tonumber(rg_record_split[2])
        records[j].col = 0
      end
    end
  end

  -- Create the mapping scratch buffers text
  for _, record in pairs(records) do
    record.lines = Record_buf_lines(record)
  end

  -- Telescope wants an indexed array
  local indexed_records = {}
  for _, record in pairs(records) do
    local mode_str
    if (type(record.mode) == "table") then
      mode_str = table.concat(record.mode, ", ")
    else
      mode_str = record.mode
    end

    record.mode = mode_str
    table.insert(indexed_records, record)
  end

  return indexed_records
end

-- Make the text that is displayed in the preview
function Record_buf_lines(record)
  local lines = {}

  local modes = {}
  local mode_str = ""

  if (type(record.mode) == "table") then
    modes = record.mode
  else
    table.insert(modes, record.mode)
  end

  for i, mode in ipairs(modes) do
    if (i > 1) then
      mode_str = mode_str .. ", "
    end

    if (mode == "n") then
      mode_str = mode_str .. "normal"
    elseif (mode == "i") then
      mode_str = mode_str .. "insert"
    elseif (mode == "v") then
      mode_str = mode_str .. "visual"
    elseif (mode == "t") then
      mode_str = mode_str .. "terminal"
    elseif (mode == "o") then
      mode_str = mode_str .. "operator pending"
    elseif (mode == "s") then
      mode_str = mode_str .. "select"
    elseif (mode == "r") then
      mode_str = mode_str .. "replace"
    else
      mode_str = mode_str .. mode
    end
  end

  local filename
  local row
  local cmd_str
  if record.filename ~= nil then filename = record.filename:gsub(vim.g.mapper_search_path .. "/", "") else filename = "" end
  if record.row ~= nil then row = record.row else row = "" end
  if type(record.cmd) == "function" then cmd_str = "function" else cmd_str = record.cmd end

  table.insert(lines, "Id:           " .. record.unique_identifier)
  table.insert(lines, "Category:     " .. record.category)
  table.insert(lines, "Mode:         " .. mode_str)
  table.insert(lines, "Keys:         " .. record.keys)
  table.insert(lines, "Command:      " .. cmd_str)
  table.insert(lines, "Buffer only:  " .. tostring(record.buffer_only))
  table.insert(lines, "Options:      " .. vim.inspect(record.options):gsub("\n", ""):gsub("{  ", "{"):gsub("  ", " "))
  table.insert(lines, "Definition:   " .. filename .. ":" .. row)
  table.insert(lines, "")
  table.insert(lines, record.description)

  return lines
end

return M
