-- +goose Up
-- +goose StatementBegin
DROP TABLE IF EXISTS library_known_media;
CREATE TABLE library_known_media (
    -- uid UUID PRIMARY KEY NOT NULL,
    uid UUID NOT NULL,
    md5 UUID UNIQUE NOT NULL,
    md5_lower UBIGINT NOT NULL,
    duplicates BIGINT NOT NULL DEFAULT 0,
    id BIGINT NOT NULL DEFAULT 0,
    title VARCHAR NOT NULL DEFAULT '',
    vote_average DOUBLE NOT NULL DEFAULT 0.0,
    vote_count BIGINT NOT NULL DEFAULT 0,
    status VARCHAR NOT NULL DEFAULT '',
    release_date DATE NOT NULL DEFAULT 'infinity',
    revenue BIGINT NOT NULL DEFAULT 0,
    runtime BIGINT NOT NULL DEFAULT 0,
    adult BOOLEAN NOT NULL DEFAULT FALSE,
    backdrop_path VARCHAR NOT NULL DEFAULT '',
    budget BIGINT NOT NULL DEFAULT 0,
    homepage VARCHAR NOT NULL DEFAULT '',
    imdb_id VARCHAR NOT NULL DEFAULT '',
    original_language VARCHAR NOT NULL DEFAULT '',
    original_title VARCHAR NOT NULL DEFAULT '',
    overview VARCHAR NOT NULL DEFAULT '',
    popularity DOUBLE NOT NULL DEFAULT 0.0,
    poster_path VARCHAR NOT NULL DEFAULT '',
    tagline VARCHAR NOT NULL DEFAULT '',
    genres VARCHAR NOT NULL DEFAULT '',
    production_companies VARCHAR NOT NULL DEFAULT '',
    production_countries VARCHAR NOT NULL DEFAULT '',
    spoken_languages VARCHAR NOT NULL DEFAULT '',
    keywords VARCHAR NOT NULL DEFAULT ''
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS library_known_media;
-- +goose StatementEnd
