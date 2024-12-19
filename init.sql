-- init.sql
CREATE TABLE IF NOT EXISTS packages (
    name TEXT PRIMARY KEY,
    version TEXT NOT NULL,
    build_phase TEXT,
    install_phase TEXT,
    unpack_phase TEXT,
    source_url TEXT,
    source_hash TEXT,
    meta_description TEXT,
    meta_license TEXT,
    meta_platforms TEXT[],
    builder_func TEXT
);