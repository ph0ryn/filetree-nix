{
  description = "A fast, lightweight file explorer TUI with VSCode-like interface and Vim keybindings.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
        };
    in
    {
      overlays.default = final: _prev: {
        filetree = final.rustPlatform.buildRustPackage {
          pname = "filetree";
          version = "0.3.5";

          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;

          nativeBuildInputs = final.lib.optionals final.stdenv.hostPlatform.isLinux [
            final.pkg-config
          ];

          buildInputs = final.lib.optionals final.stdenv.hostPlatform.isLinux [
            final.xorg.libX11
            final.xorg.libxcb
          ];

          meta = {
            description = "A fast, lightweight file explorer TUI with VSCode-like interface and Vim keybindings.";
            homepage = "https://github.com/ph0ryn/filetree-nix";
            license = final.lib.licenses.mit;
            mainProgram = "ft";
          };
        };
      };

      packages = forAllSystems (
        system:
        let
          pkgs = (pkgsFor system).extend self.overlays.default;
        in
        {
          inherit (pkgs) filetree;
          default = self.packages.${system}.filetree;
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/ft";
          meta.description = "A fast, lightweight file explorer TUI with VSCode-like interface and Vim keybindings.";
        };
      });
    };
}
