local M = {}

function M.setup()
  require("cmp").register_source("nix_flake_prefetch", require("nix-flake-prefetch.cmp.source").new())
end

return M
