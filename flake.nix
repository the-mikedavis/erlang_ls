{
  description = "A Language Server and Debug Adapter for Erlang";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11"; };

  outputs = { self, nixpkgs, ... }: {
    packages.x86_64-linux.default =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      in pkgs.beamPackages.callPackage ./nix { src = ./.; };
  };
}
