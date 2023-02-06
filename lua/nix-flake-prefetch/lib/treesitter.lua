local ts = vim.treesitter
local utils = require "nvim-treesitter.ts_utils"

local lib = {}

function lib.get_node_at_cursor()
  return utils.get_node_at_cursor()
end

function lib.get_node_text(...)
  return ts.query.get_node_text(...)
end

function lib.find_node(node, type)
  for child, _ in node:iter_children() do
    if child:type() == type then
      return child
    end
  end
end

function lib.find_nodes(node, type)
  local nodes = {}
  for child, _ in node:iter_children() do
    if child:type() == type then
      table.insert(nodes, child)
    end
  end
  return nodes
end

function lib.iter_captures(bufnr, query)
  local parser = vim.treesitter.get_parser(bufnr, "nix", {})
  local tree = parser:parse()[1]
  local root = tree:root()
  return query:iter_captures(root, bufnr, root:start(), root:end_())
end

return lib
