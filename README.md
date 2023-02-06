# nix-flake-prefetch.nvim

Fetch derivation src hashes using [nix3-flake-prefetch(1)][nix-flake-prefetch].

## Dependencies

- [nvim-treesitter]
- [rapidjson]
- [tree-sitter-nix]

## Features

- [x] support `fetchFromGitHub`
- [ ] support `fetchgit` with a `rev` attribute
- [x] provide a [cmp] source

## Setup

```lua
require("nix-flake-prefetch.cmp").setup()

local cmp = require "cmp"
cmp.setup {
  sources = cmp.config.sources {
    { name = "nix-flake-prefetch" },
  },
}
```

[cmp]: https://github.com/hrsh7th/nvim-cmp
[nix-flake-prefetch]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake-prefetch.html
[nvim-treesitter]: https://github.com/nvim-treesitter/nvim-treesitter
[rapidjson]: https://github.com/xpol/lua-rapidjson
[tree-sitter-nix]: https://github.com/cstrahan/tree-sitter-nix
