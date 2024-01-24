CREATE OR REPLACE FUNCTION transfer_file_and_update_location(
    p_file_path text,
    p_new_location text
)
RETURNS VOID AS $$
DECLARE
    v_picture_id integer;
    loid oid;
BEGIN
    -- Get the next value of the picture_id serial
    SELECT nextval('data_reference_picture_id_seq') INTO v_picture_id;

    -- Update data_reference with the new file location
    UPDATE data_reference
    SET link_path = p_new_location
    WHERE picture_id = v_picture_id;

    -- If no row is updated, insert a new row
    IF NOT FOUND THEN
        INSERT INTO data_reference (picture_id, link_path)
        VALUES (v_picture_id, p_new_location);
    END IF;

    -- Open a new Large Object
    loid := lo_import(p_file_path);

    -- Update the Large Object OID in data_reference
    UPDATE data_reference
    SET large_object_oid = loid
    WHERE picture_id = v_picture_id;

    -- Optional: Delete the original file if needed
    -- SELECT pg_file_unlink(p_file_path);
END;
$$ LANGUAGE plpgsql;
