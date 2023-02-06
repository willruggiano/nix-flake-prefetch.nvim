{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-nix.url = "github:cachix/pre-commit-hooks.nix";

    firvish.url = "github:willruggiano/firvish.nvim/wip/v2.0";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.pre-commit-nix.flakeModule
      ];

      systems = ["x86_64-linux" "aarch64-darwin"];
      perSystem = {
        config,
        pkgs,
        system,
        inputs',
        ...
      }: {
        apps.update-docs.program = pkgs.writeShellApplication {
          name = "update-docs";
          runtimeInputs = with pkgs; [lemmy-help];
          text = ''
            lemmy-help lua/**/*.lua > doc/nix-flake-prefetch.txt
          '';
        };

        devShells.default = pkgs.mkShell {
          name = "nix-flake-prefetch.nvim";
          buildInputs = with pkgs; [lemmy-help luajit];
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };

        formatter = pkgs.alejandra;

        packages.default = pkgs.vimUtils.buildVimPluginFrom2Nix {
          name = "nix-flake-prefetch";
          src = ./.;
          propagatedBuildInputs = [inputs'.firvish.packages.default];
        };

        pre-commit = {
          settings = {
            hooks.alejandra.enable = true;
            hooks.stylua.enable = true;
          };
        };
      };
    };
}
