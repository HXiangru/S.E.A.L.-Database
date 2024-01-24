CREATE OR REPLACE FUNCTION public.create_standard_user(
    p_username VARCHAR,
    p_password VARCHAR)
RETURNS void
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    -- Create the user
    EXECUTE 'CREATE USER ' || quote_ident(p_username) || ' WITH PASSWORD ' || quote_literal(p_password);

    -- Grant privileges to add, change, and delete rows
    EXECUTE 'GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO ' || quote_ident(p_username);

    -- Grant privileges to import/export OID files
    EXECUTE 'GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ' || quote_ident(p_username);

    -- Grant privileges to import/export text arrays
    EXECUTE 'GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO ' || quote_ident(p_username);
END;
$BODY$;