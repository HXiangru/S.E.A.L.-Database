CREATE OR REPLACE FUNCTION public.insert_data_reference(
	p_picture_number1 integer,
	p_file_path1 text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    -- Insert a new row into data_reference with the provided picture_number and file_path
    INSERT INTO data_reference (picture_number, link_path)
    VALUES (p_picture_number1, p_file_path1);
END;
$BODY$;

ALTER FUNCTION public.insert_data_reference(integer, text)
    OWNER TO postgres;