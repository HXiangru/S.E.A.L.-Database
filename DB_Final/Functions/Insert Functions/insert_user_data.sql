CREATE OR REPLACE FUNCTION public.insert_user_data(
	p_username1 character varying)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    INSERT INTO user_data (user_id, username1, user_random)
    VALUES (uuid_generate_v4(), p_username1, generate_random_number_5_digits());
END;
$BODY$;

ALTER FUNCTION public.insert_user_data(character varying)
    OWNER TO postgres;
