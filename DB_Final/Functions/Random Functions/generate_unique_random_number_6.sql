CREATE OR REPLACE FUNCTION public.generate_unique_random_number(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    random_number INTEGER;
BEGIN
    LOOP
        random_number := floor(random() * 900000 + 100000)::INTEGER;
        EXIT WHEN NOT EXISTS (SELECT 1 FROM data_tags WHERE picture_number = random_number);
    END LOOP;

    RETURN random_number;
END;
$BODY$;

ALTER FUNCTION public.generate_unique_random_number()
    OWNER TO postgres;