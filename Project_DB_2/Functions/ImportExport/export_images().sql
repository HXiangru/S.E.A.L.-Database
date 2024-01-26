CREATE OR REPLACE FUNCTION export_image(
    p_picture_number INTEGER,
    p_target_directory TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    l_file_path TEXT;
BEGIN
    -- Generate a unique identifier for the filename
    l_file_path := p_target_directory || '/' || generate_unique_identifier(p_picture_number);

    -- Ensure the target directory exists; create it if not (adjust as needed)
    -- Note: PostgreSQL doesn't have a built-in command to create directories.
    -- You need to handle directory creation outside of the function.

    -- Check if the file exists before exporting
    IF EXISTS (SELECT 1 FROM data_reference WHERE picture_number = p_picture_number) THEN
        -- Export the data from data_reference to a server-side file
        EXECUTE FORMAT(
            'COPY (SELECT link_path FROM data_reference WHERE picture_number = %L) TO ''%s'' WITH CSV HEADER',
            p_picture_number,
            l_file_path
        );
    ELSE
        RAISE EXCEPTION 'No data found for picture_number %', p_picture_number;
    END IF;
END;
$$;
