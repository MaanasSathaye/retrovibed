-- +goose Up
-- +goose StatementBegin
CREATE TABLE library_known_media (
    uid UUID PRIMARY KEY NOT NULL,
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

--INSERT INTO library_tmdb (
--       uid,
--       id,
--       title,
--       vote_average,
--       vote_count,
--       status,
--       release_date,
--       revenue,
--       runtime,
--       adult,
--       backdrop_path,
--       budget,
--       homepage,
--       imdb_id,
--       original_language,
--       original_title,
--       overview,
--       popularity,
--       poster_path,
--       tagline,
--       genres,
--       production_companies,
--       production_countries,
--       spoken_languages,
--       keywords
--) SELECT
--       CAST(TO_HEX('tmdb') || '-0000-0000-0000-' || LPAD(TO_HEX(COALESCE(csv.id, 0)), 12, '0') AS UUID) AS uid,
--       COALESCE(csv.id, 0),
--       COALESCE(csv.title, ''),
--       COALESCE(csv.vote_average, 0.0),
--       COALESCE(csv.vote_count, 0),
--       COALESCE(csv.status, ''),
--       COALESCE(csv.release_date, 'infinity'::DATE), -- Cast 'infinity' to DATE type
--       COALESCE(csv.revenue, 0),
--       COALESCE(csv.runtime, 0),
--       COALESCE(csv.adult, FALSE),
--       COALESCE(csv.backdrop_path, ''),
--       COALESCE(csv.budget, 0),
--       COALESCE(csv.homepage, ''), -- This will ensure empty string if NULL from CSV
--       COALESCE(csv.imdb_id, ''),
--       COALESCE(csv.original_language, ''),
--       COALESCE(csv.original_title, ''),
--       COALESCE(csv.overview, ''),
--       COALESCE(csv.popularity, 0.0),
--       COALESCE(csv.poster_path, ''),
--       COALESCE(csv.tagline, ''),
--       COALESCE(csv.genres, ''),
--       COALESCE(csv.production_companies, ''),
--       COALESCE(csv.production_countries, ''),
--       COALESCE(csv.spoken_languages, ''),
--       COALESCE(csv.keywords, '')
--FROM '~/Downloads/archive/TMDB_movie_dataset_v11.csv' AS csv;
--PRAGMA create_fts_index('library_known_media', 'id', 'title', overwrite = 1);
