local Job = require "plenary.job"
local ts = require "nix-flake-prefetch.lib.treesitter"

local lib = {}

function lib.prefetch(uri, opts)
  local args = { "flake", "prefetch", "--json" }
  if type(uri) == "table" then
    vim.list_extend(args, uri)
  elseif type(uri) == "string" then
    table.insert(args, uri)
  else
    error("invalid argument: expected 'uri' to be a string or table, but got: '" .. type(uri) .. "'")
  end

  local job_opts = {
    command = "nix",
    args = args,
  }
  return Job:new(vim.tbl_deep_extend("force", job_opts, opts))
end

---@class Position
---@field col number
---@field row number

---@class Context
---@field bufnr number
---@field cursor Position

-- local sexpr = [[
-- (binding
--   expression: (apply_expression
--     function: (variable_expression
--       name: (identifier) @fetcher
--     )
--     argument: (_
--       (binding_set
--         binding: (binding
--           attrpath: (attrpath attr: (identifier))
--           expression: (_ (_))
--         ) @args
--       )
--     )
--   ) @block
-- )
-- ]]
local sexpr = [[
(binding
  expression: (apply_expression
    function: (variable_expression
      name: (identifier)
    )
    argument: (_
      (binding_set
        binding: (binding
          attrpath: (attrpath attr: (identifier))
          expression: (_ (_))
        )
      )
    )
  ) @block
)
]]

---@param context Context
function lib.uri_at_cursor(context)
  local bufnr = context.bufnr

  local cursor_node = ts.get_node_at_cursor()
  local query = vim.treesitter.parse_query("nix", sexpr)

  local fetcher
  local args = {}
  for _, node, _ in ts.iter_captures(bufnr, query) do
    local row, col = cursor_node:range()
    if vim.treesitter.is_in_node_range(node, row, col) then
      local func = node:field("function")[1]
      fetcher = ts.get_node_text(ts.find_node(func, "identifier"), bufnr)
      local bindings = node:field("argument")[1]:named_child(0)
      for binding, _ in bindings:iter_children() do
        if binding:type() == "binding" then
          local id = ts.get_node_text(binding:field("attrpath")[1]:field("attr")[1], bufnr)
          if id ~= "hash" then
            local value = ts.get_node_text(binding:field("expression")[1]:child(1), bufnr)
            args[id] = value
          end
        end
      end
    end
  end

  if fetcher == "fetchFromGitHub" then
    return "github:" .. args.owner .. "/" .. args.repo .. "/" .. args.rev
  elseif fetcher == "fetchgit" then
    if args.rev then
      print "fetchgit doesn't support a rev attribute, right now"
      -- TODO: Figure out how to pass rev to `nix flake check`
      return nil
    else
      return args.url
    end
  elseif fetcher == "fetchurl" then
    return args.url
  end

  print("unknown fetcher `" .. fetcher .. "`")
end

function lib.can_complete(bufnr)
  local cursor_node = ts.get_node_at_cursor()
  if cursor_node == nil then
    return false
  end

  if cursor_node:type() ~= "string_expression" then
    return false
  end
  local binding = cursor_node:parent()
  if binding:type() ~= "binding" then
    return false
  end
  local attrpath = binding:field("attrpath")[1]
  local attr = attrpath:field("attr")[1]
  if attr:type() ~= "identifier" then
    return false
  end
  local text = ts.get_node_text(attr, bufnr)
  return text == "hash"
end

return lib
