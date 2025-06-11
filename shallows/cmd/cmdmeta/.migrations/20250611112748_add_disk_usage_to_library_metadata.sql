-- +goose Up
-- +goose StatementBegin
ALTER TABLE library_metadata ADD COLUMN disk_usage UBIGINT DEFAULT 0;
ALTER TABLE library_metadata ALTER COLUMN disk_usage SET NOT NULL;
UPDATE library_metadata SET disk_usage = bytes;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE library_metadata DROP COLUMN IF EXISTS disk_usage;
-- +goose StatementEnd
