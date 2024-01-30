-- FUNCTION: public.insert_data_uncertainty(integer, text[])

-- DROP FUNCTION IF EXISTS public.insert_data_uncertainty(integer, text[]);

CREATE OR REPLACE FUNCTION public.insert_data_uncertainty(
	p_data_uncertainty BOOLEAN[],
	picture_number1 INTEGER
	)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    -- Insert a new row into uncertainty with the provided uncertainties and picture_number
    INSERT INTO uncertainty (
        picture_number,
        uncertainty_specimen,
        uncertainty_bone,
        uncertainty_sex,
        uncertainty_age,
        uncertainty_side_of_body,
        uncertainty_plane_of_picture,
        uncertainty_orientation
    )
    VALUES (
        picture_number1,
        p_data_uncertainty[1],
        p_data_uncertainty[2],
        p_data_uncertainty[3],
        p_data_uncertainty[4],
        p_data_uncertainty[5],
        p_data_uncertainty[6],
        p_data_uncertainty[7]
    );
END;
$BODY$;

ALTER FUNCTION public.insert_data_uncertainty(integer, text[])
    OWNER TO postgres;