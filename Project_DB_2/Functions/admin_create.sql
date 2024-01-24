CREATE OR REPLACE FUNCTION public.admin_create(
	user_name character varying,
	user_password character varying)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
	BEGIN
		EXECUTE 'CREATE ROLE ' || quote_ident(user_name) || ' PASSWORD ' || quote_literal(user_password) || ' SUPERUSER';
    	EXECUTE 'ALTER ROLE ' || quote_ident(user_name) || ' CREATEROLE';
	END;
$BODY$;