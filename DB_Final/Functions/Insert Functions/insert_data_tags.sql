CREATE OR REPLACE FUNCTION public.insert_data_tags(
    p_data_tags text[],
    p_picture_number integer,
    p_scrape_names text
)
RETURNS void
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    -- Check array length before accessing specific indices
    IF array_length(p_data_tags, 1) >= 7 THEN
        -- Insert into data_tags table
        INSERT INTO data_tags (
            picture_number,
            specimen,
            bone,
            sex,
            age,
            side_of_body,
            plane_of_picture,
            orientation,
            scrape_name
        )
        VALUES (
            p_picture_number,
            p_data_tags[1],
            p_data_tags[2],
            p_data_tags[3],
            p_data_tags[4],
            p_data_tags[5],
            p_data_tags[6],
            p_data_tags[7],
            p_scrape_names
        );
    ELSE
        -- Handle the case where the array doesn't have enough elements
        RAISE EXCEPTION 'Array p_data_tags does not have enough elements.';
    END IF;
END;
$BODY$;

ALTER FUNCTION public.insert_data_tags(text[], integer, text)
OWNER TO postgres;

