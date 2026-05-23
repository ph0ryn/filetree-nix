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
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.rustPlatform.buildRustPackage {
            pname = "filetree";
            version = "0.3.5";

            src = ./.;
            cargoLock.lockFile = ./Cargo.lock;

            nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              pkgs.pkg-config
            ];

            buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              pkgs.xorg.libX11
              pkgs.xorg.libxcb
            ];

            meta = {
              description = "A fast, lightweight file explorer TUI with VSCode-like interface and Vim keybindings.";
              homepage = "https://github.com/ph0ryn/filetree-nix";
              license = pkgs.lib.licenses.mit;
              mainProgram = "ft";
            };
          };
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
