CREATE OR REPLACE FUNCTION public.generate_unique_identifier(
	row_id integer)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_identifier VARCHAR(255);
BEGIN
    -- Concatenate non-null tags into one long string
    SELECT CONCAT(
        COALESCE(specimen, ''),
        COALESCE(bone, ''),
        COALESCE(sex, ''),
		COALESCE(age, ''),
		COALESCE(side_of_body, ''),
		COALESCE(plane_of_picture, ''),
		COALESCE(orientation, ''),
		picture_number::VARCHAR
    )
    INTO v_identifier
    FROM data_tags
    WHERE picture_number = row_id;

    RETURN v_identifier;
END;
$BODY$;