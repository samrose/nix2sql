let
  lib = import ./lib.nix;
  pkgs = import <nixpkgs> {};
  
  # Convert packages to SQL
  packagesSQL = lib.fileToSql "packages" ./packages.nix;
  
  # Write the SQL file
  sqlFile = pkgs.writeText "insert-packages.sql" packagesSQL;
in
sqlFile