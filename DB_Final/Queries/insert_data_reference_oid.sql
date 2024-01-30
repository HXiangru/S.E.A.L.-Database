DO $$ 
DECLARE
    row_data RECORD;                                 -- declaring row_data for the FOR loop
    image_oid OID;                                   -- Large object declaration (this will store the image data)
BEGIN
    FOR row_data IN (SELECT link_path FROM data_reference) LOOP
        BEGIN
            -- Import the image into the Large Object
            BEGIN
                image_oid := lo_import(row_data.link_path);
            EXCEPTION
                WHEN OTHERS THEN
                    RAISE NOTICE 'Error importing image for path: %, Error: %', row_data.link_path, SQLERRM;
                    CONTINUE; -- Skip to the next iteration in case of an error
            END;

            -- Update the existing row with the new stored_image_oid
            UPDATE data_reference 
            SET stored_image_oid = image_oid
            WHERE link_path = row_data.link_path;

            RAISE NOTICE 'Image imported and stored successfully for path: %', row_data.link_path;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Error processing file: %, Error: %', row_data.link_path, SQLERRM;
        END;
    END LOOP;
END $$;
