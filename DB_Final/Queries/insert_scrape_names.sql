DO $$ 
DECLARE
    v_scrape_name TEXT;
    data_row public.data_tags;
BEGIN
    -- Loop through each row in the table
    FOR data_row IN (SELECT * FROM public.data_tags WHERE specimen IS NOT NULL) LOOP
        -- Concatenate the values for the current row
        v_scrape_name := COALESCE(data_row.specimen, '') || 
                         COALESCE(data_row.bone, '') || 
                         COALESCE(data_row.sex, '') || 
                         COALESCE(data_row.age, '') || 
                         COALESCE(data_row.side_of_body, '') || 
                         COALESCE(data_row.plane_of_picture, '') || 
                         COALESCE(data_row.orientation, '') || 
                         COALESCE(CAST(data_row.picture_number AS TEXT), ''); -- Cast picture_number to TEXT
        
        -- Update the scrape_name column for the current row
        UPDATE public.data_tags
        SET scrape_name = v_scrape_name
        WHERE logic_tag = data_row.logic_tag;
        
        RAISE NOTICE 'Specimen: %, Scrape Name: %', data_row.specimen, v_scrape_name;
    END LOOP;
END $$;



