-- +goose Up
-- +goose StatementBegin
ALTER TABLE library_metadata ADD COLUMN tombstoned_at TIMESTAMPTZ DEFAULT 'infinity';
ALTER TABLE library_metadata ALTER COLUMN tombstoned_at SET NOT NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE library_metadata DROP COLUMN IF EXISTS tombstoned_at;
-- +goose StatementEnd