# Generated by rebar3_nix
{ fetchHex, fetchFromGitHub }:
{
  getopt = fetchHex {
    pkg = "getopt";
    version = "1.0.1";
    sha256 = "sha256-U+Grg7nOtlyWctPno1uAkum9ybPugHIUcaFhwQxZlZw=";
  };
  zipper = fetchHex {
    pkg = "zipper";
    version = "1.0.1";
    sha256 = "sha256-ah/T4fDMHR31ZCyaDOIXgDZBGwpclkKFHR2idr1zfC0=";
  };
  quickrand = fetchHex {
    pkg = "quickrand";
    version = "2.0.7";
    sha256 = "sha256-uKy/iaIkvCF8MHDKi+vG6yNtvn+XZ5k7J0CE6gRNNfA=";
  };
  providers = fetchHex {
    pkg = "providers";
    version = "1.8.1";
    sha256 = "sha256-5FdFrenEdqmkaeoIQOQYqxk2DcRPAaIzME4RikRIa6A=";
  };
  katana_code = fetchHex {
    pkg = "katana_code";
    version = "2.1.1";
    sha256 = "sha256-BoDzNSW5qILm9NMCJRixXEb2SL17Db6GkAmA/hwpFAQ=";
  };
  bucs = fetchHex {
    pkg = "bucs";
    version = "1.0.16";
    sha256 = "sha256-/2pccqUArXrsHuO6FkrjxFDq3uiYsNFR4frKGKyNDWI=";
  };
  yamerl = fetchFromGitHub {
    owner = "erlang-ls";
    repo = "yamerl";
    rev = "9a9f7a2e84554992f2e8e08a8060bfe97776a5b7";
    sha256 = "1gb44v27paxwxm443m5f554wiziqi2kd300hgjjdg6fyvy3mvhss";
  };
  uuid = fetchHex {
    pkg = "uuid_erl";
    version = "2.0.1";
    sha256 = "sha256-q1fKzNUfFwAR5fREzoZfhLQWBeSDqe/MRowa+uyHVTs=";
  };
  tdiff = fetchHex {
    pkg = "tdiff";
    version = "0.1.2";
    sha256 = "sha256-4MLhaPmSUqWIl2jVyPHmUQoYRZLUz6BrIneKGNM9eHU=";
  };
  redbug = fetchHex {
    pkg = "redbug";
    version = "2.0.6";
    sha256 = "sha256-qtlJhnH0q5HqylCZ/oWmFhgVimNuYoaJLE989K8XHQQ=";
  };
  rebar3_format = fetchHex {
    pkg = "rebar3_format";
    version = "0.8.2";
    sha256 = "sha256-yo/ydjjCFpWT0USdrL6IlWNBk+0zNOkGtU/JfwgfUhM=";
  };
  json_polyfill = fetchHex {
    pkg = "json_polyfill";
    version = "0.1.4";
    sha256 = "sha256-SMOX7iVH+kWe3gGjDsDoVxer7TAQhnpj7qrF8gMnQwM=";
  };
  gradualizer = fetchFromGitHub {
    owner = "josefs";
    repo = "gradualizer";
    rev = "3021d29d82741399d131e3be38d2a8db79d146d4";
    sha256 = "052f8x9x93yy00pbkl1745ffnwj3blcm39j12i4k166y1zbnwy00";
  };
  erlfmt = fetchHex {
    pkg = "erlfmt";
    version = "1.5.0";
    sha256 = "sha256-OTOkDPvnkK2U5bZQs2iB3nBFYxkmPBR5tVbpr9vYDHU=";
  };
  ephemeral = fetchHex {
    pkg = "ephemeral";
    version = "2.0.4";
    sha256 = "sha256-Syk9gPdfnEV1/0ucjoiaVoAvQLAYv1fnTxlkTv7myFA=";
  };
  elvis_core = fetchHex {
    pkg = "elvis_core";
    version = "3.2.5";
    sha256 = "sha256-NNkhjwuAclEZA79sy/WesXZd7Pxz/MaDO6XIlZ2384M=";
  };
  docsh = fetchHex {
    pkg = "docsh";
    version = "0.7.2";
    sha256 = "sha256-Tn20YbsHVA0rw9NmuFE/AZdxLQSVu4V0TzZ9OBUHYTQ=";
  };
}
