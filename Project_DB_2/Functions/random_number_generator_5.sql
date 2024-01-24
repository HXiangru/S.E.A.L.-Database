CREATE OR REPLACE FUNCTION generate_random_number_5_digits()
RETURNS INTEGER AS $$
DECLARE
    random_number INTEGER;
BEGIN
    -- Generate a random 5-digit number
    WHILE TRUE
    LOOP
        random_number := floor(random() * (99999 - 10000 + 1) + 10000)::INTEGER;

        EXIT WHEN NOT EXISTS (SELECT 1 FROM your_table WHERE your_column = random_number);
    END LOOP;

    RETURN random_number;
END;
$$ LANGUAGE plpgsql;
