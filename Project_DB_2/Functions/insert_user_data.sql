CREATE OR REPLACE FUNCTION public.insert_user_data(
	p_username1 character varying)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    INSERT INTO user_data (user_id, username1)
    VALUES (uuid_generate_v4(), p_username1);
END;
$BODY$;

ALTER FUNCTION public.insert_user_data(character varying, character varying)
    OWNER TO postgres;
