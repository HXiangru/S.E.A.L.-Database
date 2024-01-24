CREATE OR REPLACE FUNCTION public.insert_user_data(
    p_username1 VARCHAR,
    p_password1 VARCHAR)
RETURNS void
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    INSERT INTO user_data (user_id, username1, password1)
    VALUES (uuid_generate_v4(), p_username1, p_password1);
END;
$BODY$;