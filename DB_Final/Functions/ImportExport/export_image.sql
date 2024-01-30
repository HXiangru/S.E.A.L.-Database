-- FUNCTION: public.export_image(integer, text)

-- DROP FUNCTION IF EXISTS public.export_image(integer, text);

CREATE OR REPLACE FUNCTION public.export_image(
	p_picture_number integer,
	p_output_directory text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    image_oid OID;
    file_path TEXT;
    scrape_name TEXT;
BEGIN
    -- Retrieve the scrape_name from data_tags
    SELECT dt.scrape_name INTO scrape_name
    FROM data_tags dt
    WHERE dt.picture_number = p_picture_number;

    -- Retrieve the image OID from data_reference
    SELECT dr.stored_image_OID INTO image_oid
    FROM data_reference dr
    WHERE dr.picture_number = p_picture_number;

    IF image_oid IS NOT NULL THEN
        -- Generate the file path in the output directory with scrape_name
        file_path := p_output_directory || '/' || scrape_name || '.jpg';

        -- Export the Large Object data to a file using lo_export
        PERFORM lo_export(image_oid, file_path);
    ELSE
        RAISE NOTICE 'No image found for picture_number %', p_picture_number;
    END IF;
END;
$BODY$;

ALTER FUNCTION public.export_image(integer, text)
    OWNER TO postgres;