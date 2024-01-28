CREATE OR REPLACE FUNCTION public.insert_data_tags(
	p_data_tags text[],
	p_picture_number integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    -- Generate a unique random number and insert a new row into data_tags
    INSERT INTO data_tags (picture_number, specimen, bone, sex, age, side_of_body, plane_of_picture, orientation) -- Add more columns as needed
    VALUES (p_picture_number, p_data_tags[1], p_data_tags[2], p_data_tags[3], p_data_tags[4], p_data_tags[5], p_data_tags[6], p_data_tags[7]); -- Adjust based on the number of tags
END;
$BODY$;

ALTER FUNCTION public.insert_data_tags(text[], integer)
    OWNER TO postgres;
