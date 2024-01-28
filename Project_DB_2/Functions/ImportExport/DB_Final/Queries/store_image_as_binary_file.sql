-- Update stored_images column in data_reference with image data from the file system
UPDATE data_reference
SET stored_image = pg_read_binary_file(link_path::text)
WHERE link_path IS NOT NULL;
