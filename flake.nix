{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-gotk4.url = "github:NixOS/nixpkgs?ref=nixos-26.05";
    gotk4-nix.url = "github:diamondburned/gotk4-nix/main";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-gotk4,
      gotk4-nix,
      flake-utils,
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-gotk4 = nixpkgs-gotk4.legacyPackages.${system};
      in
      {
        devShells.default = gotk4-nix.lib.mkShell {
          base.pname = "gotkit";
          pkgs = pkgs-gotk4;

          buildInputs = with pkgs-gotk4; [
            gobject-introspection
            glib
            graphene
            gdk-pixbuf
            gtk4
            gtk3
            vulkan-headers
            gnome-desktop
            libadwaita
          ];

          packages = [
            pkgs.clang
            self.formatter.${system}
          ];

          go = pkgs.go_1_27;
          inherit (pkgs) gopls gotools;

          shellHook = ''
            export CC=clang # for speed
          '';
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
