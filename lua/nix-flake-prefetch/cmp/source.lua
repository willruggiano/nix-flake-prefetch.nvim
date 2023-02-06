local cmp = require "cmp"
local json = require "rapidjson"
local lib = require "nix-flake-prefetch.lib"

local source = {}
source.__index = source

function source.new()
  return setmetatable({}, source)
end

function source.get_debug_name()
  return "nix-flake-prefetch"
end

function source.is_available()
  return vim.bo.filetype == "nix"
end

function source.complete(_, params, callback)
  if lib.can_complete(params.context.bufnr) then
    local uri = lib.uri_at_cursor(params.context)
    if uri then
      local job = lib.prefetch(uri, {
        on_exit = function(self)
          local output = json.decode(self:result()[1])
          callback {
            items = {
              {
                label = output.hash,
                kind = cmp.lsp.CompletionItemKind.Value,
              },
              {
                label = output.storePath,
                kind = cmp.lsp.CompletionItemKind.File,
              },
            },
          }
        end,
      })
      job:start()
    end
  else
    callback()
  end
end

return source
