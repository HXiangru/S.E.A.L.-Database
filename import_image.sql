-- FUNCTION: public.import_image(text, text[], boolean[])

-- DROP FUNCTION IF EXISTS public.import_image(text, text[], boolean[]);

CREATE OR REPLACE FUNCTION public.import_image(
	p_image_path text,
	p_data_tags text[],
	p_data_uncertainties boolean[])
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    l_unique_name text;
    l_picture_number INTEGER;
    l_file_path text;
    l_oid OID;
    l_directory text := 'C:\Program Files\PostgreSQL\16\data\PermissionData\Export\';
BEGIN
    -- Generate a unique random number
    l_picture_number := generate_unique_random_number();

    -- Generate unique text scrape
    l_unique_name = generate_unique_identifier(p_data_tags) || l_picture_number::text;

    -- Define the file path in the storage directory
    l_file_path := l_directory || l_unique_name;

    -- Use lo_import to get OID for image data
    l_oid := lo_import(p_image_path);

    -- Export the image data to a file in the storage directory
    EXECUTE 'SELECT lo_export($1, $2)' USING l_oid, l_file_path;

    -- Call insert_data_tags with the array of tags and the generated picture_number
    PERFORM insert_data_tags(p_data_tags, l_picture_number, l_unique_name);

    -- Call insert_uncertainty with the array of boolean values corresponding to the data_tags
    PERFORM insert_data_uncertainty(p_data_uncertainties, l_picture_number);

    -- Insert the file path and OID into the data_reference table
    PERFORM insert_data_reference(l_picture_number, l_file_path, l_oid);
END;
$BODY$;

ALTER FUNCTION public.import_image(text, text[], boolean[])
    OWNER TO postgres;
