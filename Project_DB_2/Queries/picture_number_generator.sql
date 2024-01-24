DO $$ 
DECLARE
    row_data RECORD;
    new_picture_number INTEGER;
BEGIN
    -- Loop through rows where specimen is not NULL
    FOR row_data IN SELECT * FROM public.data_tags WHERE specimen IS NOT NULL
    LOOP
        -- Generate a new unique random number
        new_picture_number := generate_unique_random_number();

        -- Update each row with the generated random number
        UPDATE public.data_tags
        SET picture_number = new_picture_number
        WHERE logic_tag = row_data.logic_tag;

        -- You can add additional logic or print statements if needed
        -- RAISE NOTICE 'Updated picture_number for logic_tag %', row_data.logic_tag;
    END LOOP;
END $$;
