# lib.nix
rec {
  attrsToList = attrs:
    builtins.map (name: { 
      inherit name; 
      value = builtins.getAttr name attrs; 
    }) (builtins.attrNames attrs);

  escapeSqlString = str:
    builtins.replaceStrings ["'"] ["''"] (toString str);

  listToSqlArray = list:
    let
      quotedItems = map (x: "'${escapeSqlString x}'") list;
      arrayStr = builtins.concatStringsSep "," quotedItems;
    in
    "ARRAY[${arrayStr}]";

  nixValueToSql = value:
    if builtins.isBool value then
      if value then "TRUE" else "FALSE"
    else if builtins.isInt value || builtins.isFloat value then
      toString value
    else if value == null then
      "NULL"
    else if builtins.isList value then
      listToSqlArray value
    else
      "'${escapeSqlString value}'";

  extractMeta = drv:
    if drv ? meta then {
      meta_description = drv.meta.description or null;
      meta_license = drv.meta.license or null;
      meta_platforms = drv.meta.platforms or [];
    } else {
      meta_description = null;
      meta_license = null;
      meta_platforms = [];
    };

  # Detect which builder function was used
  detectBuilder = drv:
    if drv ? buildCommand then
      # Simple derivation
      "derivation"
    else if drv ? isPythonAttrs then
      "buildPythonPackage"
    else if drv ? goModules then
      "buildGoModule"
    else if drv ? cargoSha256 then
      "buildRustPackage"
    else if drv ? perlFlags then
      "buildPerlPackage"
    else if drv ? npmDepsHash then
      "buildNpmPackage"
    else if drv ? gradleTask then
      "buildGradle"
    # Add more builders as needed
    else
      # Default to mkDerivation if no specific builder is detected
      "mkDerivation";

  flattenDerivation = drv:
    let
      meta = extractMeta drv;
    in
    {
      name = drv.name or null;
      version = drv.version or null;
      build_phase = drv.buildPhase or null;
      install_phase = drv.installPhase or null;
      unpack_phase = drv.unpackPhase or null;
      source_url = drv.src.url or null;
      source_hash = drv.src.outputHash or null;
      builder_func = detectBuilder drv;  # Store which builder function was used
    } // meta;

  derivationToSql = table: drv:
    let
      flatDrv = flattenDerivation drv;
      attrs = attrsToList flatDrv;
      columns = builtins.concatStringsSep ", " (map (attr: attr.name) attrs);
      values = builtins.concatStringsSep ", " (map (attr: nixValueToSql attr.value) attrs);
    in
    "INSERT INTO ${table} (${columns}) VALUES (${values});";

  fileToSql = table: file:
    let
      expr = import file { };
      normalized = if builtins.isAttrs expr then expr else throw "Expected an attribute set";
    in
    builtins.concatStringsSep "\n" (
      builtins.map (attr: derivationToSql table attr.value) 
        (attrsToList normalized)
    );
}