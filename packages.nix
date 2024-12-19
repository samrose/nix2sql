# packages.nix
{ pkgs ? import <nixpkgs> {} }:

{
  hello = pkgs.stdenv.mkDerivation {
    name = "hello";
    version = "2.12.1";
    src = pkgs.fetchurl {
      url = "https://ftp.gnu.org/gnu/hello/hello-2.12.1.tar.gz";
      sha256 = "sha256-jZkUuXxX+4Oc0NWQq3802yZlEphGkqNnxjqNNg5iLbA=";
    };
    meta = {
      description = "A program that produces a familiar, friendly greeting";
      license = "GPL-3.0";
      platforms = [ "x86_64-linux" "aarch64-darwin" ];
    };
  };

  gopkg = pkgs.buildGoModule {
    name = "example-go";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "example";
      repo = "example-go";
      rev = "v1.0.0";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    vendorSha256 = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
    meta = {
      description = "An example Go package";
      license = "MIT";
      platforms = [ "x86_64-linux" ];
    };
  };

  pythonpkg = pkgs.python3Packages.buildPythonPackage {
    pname = "example-python";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "example";
      repo = "example-python";
      rev = "v0.1.0";
      sha256 = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=";
    };
    meta = {
      description = "An example Python package";
      license = "BSD";
      platforms = [ "x86_64-linux" "x86_64-darwin" ];
    };
  };
}