CREATE OR REPLACE FUNCTION public.perform_user_action_with_documentation(
	p_username character varying,
	p_action_type character varying,
	p_affected_picture_number integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_user_id INTEGER;
BEGIN
    -- Retrieve the user_id based on the provided username
    SELECT user_random INTO v_user_id
    FROM user_data
    WHERE username1 = p_username;

    IF NOT FOUND THEN
        -- Username does not exist, handle accordingly
        RAISE EXCEPTION 'Username % does not exist in user_data', p_username;
    END IF;

    -- Record the action in user_documentation using the retrieved user_id and affected_picture_number
    INSERT INTO user_documentation (user_random, action_type, affected_row_id, timestamp)
    VALUES (v_user_id, p_action_type, p_affected_picture_number, CURRENT_TIMESTAMP);
END;
$BODY$;

ALTER FUNCTION public.perform_user_action_with_documentation(character varying, character varying, integer)
    OWNER TO postgres;