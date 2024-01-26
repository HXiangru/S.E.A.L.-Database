CREATE OR REPLACE FUNCTION import_image(
    p_image_path text,
    p_scrape_image text)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    l_unique_name text;
    l_picture_number INTEGER;
    l_file_path text;
BEGIN
    -- Concatenate elements of the scrape_images array
    l_unique_name := p_scrape_image;

    -- Generate a unique random number
    l_picture_number := generate_unique_random_number();

    -- Define the file path in the storage directory
    l_file_path := 'C:\Program Files\PostgreSQL\16\data\test\' || l_unique_name || l_picture_number;

    -- Copy the data from the user-specified path to the target directory
    EXECUTE FORMAT('COPY (SELECT %L) TO %L', p_image_path, l_file_path);

    -- Insert the file path into the data_reference table
    INSERT INTO data_reference (picture_number, link_path)
    VALUES (l_picture_number, l_file_path);
-- 	INSERT INTO data_tags(picture_number)
-- 	VALUE (l_picture_number)
END;
$$;
