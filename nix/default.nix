# Adapted from  https://github.com/NixOS/nixpkgs/blob/af5b994d79e53709463ba4ff036f4ac50ebd3951/pkgs/development/beam-modules/erlang-ls/default.nix
{ fetchFromGitHub, fetchHex, openssl, rebar3, gnutar, erlang_26
, lib, src, stdenv }:
let
  # Rebuild deps with `rebar3 nix lock -o nix/rebar-deps.nix`.
  deps = import ./rebar-deps.nix { inherit fetchHex fetchFromGitHub; };
  erlang = erlang_26;
in
stdenv.mkDerivation {
  name = "erlang-ls";
  version = "0.0.0-rc.0";
  inherit src;
  # nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ rebar3 openssl gnutar ];
  buildPhase = ''
    mkdir -p _checkouts
    ${toString (lib.mapAttrsToList (k: v: /* sh */ ''
      cp -R --no-preserve=mode ${v} _checkouts/${k}
    '') deps)}
    HOME=. rebar3 escriptize
    HOME=. rebar3 as dap escriptize
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv _build/default/bin/erlang_ls $out/bin
    sed -i 's|/usr/bin/env escript|${erlang}/bin/escript|' $out/bin/erlang_ls
  '';
}
