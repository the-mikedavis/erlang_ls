# upstream: https://github.com/NixOS/nixpkgs/blob/af5b994d79e53709463ba4ff036f4ac50ebd3951/pkgs/development/beam-modules/erlang-ls/default.nix
# for my fork ;)
{ fetchFromGitHub, fetchgit, fetchHex, rebar3Relx, buildRebar3, rebar3-proper
, stdenv, writeScript, lib, src }:
let
  deps = import ./rebar-deps.nix {
    inherit fetchHex fetchFromGitHub fetchgit;
    builder = buildRebar3;
    overrides = (self: super: {
      proper = super.proper.overrideAttrs (_: {
        configurePhase = "true";
      });
    });
  };
in
rebar3Relx {
  pname = "erlang-ls";
  version = "0.0.0-rc.0";
  inherit src;
  releaseType = "escript";
  beamDeps = builtins.attrValues deps;
  buildPlugins = [ rebar3-proper ];
  buildPhase = "HOME=. make";
  doCheck = false;
  installPhase = ''
    mkdir -p $out/bin
    cp _build/default/bin/erlang_ls $out/bin/
    cp _build/dap/bin/els_dap $out/bin/
  '';
  meta = with lib; {
    homepage = "https://github.com/erlang-ls/erlang_ls";
    description = "The Erlang Language Server";
    platforms = platforms.unix;
    license = licenses.asl20;
  };
}
