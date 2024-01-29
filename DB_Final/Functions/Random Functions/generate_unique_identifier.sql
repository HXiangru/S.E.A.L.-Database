CREATE OR REPLACE FUNCTION public.generate_unique_identifier(
	data_list text[])
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_identifier VARCHAR(255);
BEGIN
    -- Concatenate non-null tags into one long string
    SELECT CONCAT_WS('',
        COALESCE(data_list[1], ''),  -- assuming data_list[1] corresponds to specimen
        COALESCE(data_list[2], ''),  -- assuming data_list[2] corresponds to bone
        COALESCE(data_list[3], ''),  -- assuming data_list[3] corresponds to sex
        COALESCE(data_list[4], ''),  -- assuming data_list[4] corresponds to age
        COALESCE(data_list[5], ''),  -- assuming data_list[5] corresponds to side_of_body
        COALESCE(data_list[6], ''),  -- assuming data_list[6] corresponds to plane_of_picture
        COALESCE(data_list[7], '')   -- assuming data_list[7] corresponds to orientation
    )
    INTO v_identifier;

    RETURN v_identifier;
END;
$BODY$;

ALTER FUNCTION public.generate_unique_identifier(text[])
    OWNER TO postgres;