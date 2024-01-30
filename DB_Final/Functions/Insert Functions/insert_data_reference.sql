-- FUNCTION: public.insert_data_reference(integer, text, OID)

-- DROP FUNCTION IF EXISTS public.insert_data_reference(integer, text, OID);

CREATE OR REPLACE FUNCTION public.insert_data_reference(
	p_picture_number integer,
	p_link_path text,
	p_stored_image_oid OID)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    INSERT INTO public.data_reference (picture_number, link_path, stored_image_OID)
    VALUES (p_picture_number, p_link_path, p_stored_image_OID);
END;
$BODY$;

ALTER FUNCTION public.insert_data_reference(integer, text, OID)
    OWNER TO postgres;
