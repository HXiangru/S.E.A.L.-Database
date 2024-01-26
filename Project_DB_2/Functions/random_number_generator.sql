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

        -- Exit the loop if the random number is not found in your_table
        EXIT WHEN NOT EXISTS (SELECT 1 FROM your_table WHERE your_column = random_number);
    END LOOP;

    RETURN random_number;
END;
$BODY$;