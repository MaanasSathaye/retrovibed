-- +goose Up
-- +goose StatementBegin
ALTER TABLE library_metadata ADD COLUMN known_media_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid;
ALTER TABLE library_metadata ALTER COLUMN known_media_id SET NOT NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE library_metadata DROP COLUMN IF EXISTS known_media_id;
-- +goose StatementEnd
