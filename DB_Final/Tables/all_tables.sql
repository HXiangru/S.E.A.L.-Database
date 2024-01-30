CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- data_reference table is used to allow for files to be exported
CREATE TABLE IF NOT EXISTS public.data_reference
(
    serial_id SERIAL PRIMARY KEY,
    link_path text COLLATE pg_catalog."default",
    picture_number integer,
    stored_image_oid OID
);

-- The main table containing the tags for the images
-- The commented out section will be filled with an ALTER TABLE QUERY
CREATE TABLE IF NOT EXISTS public.data_tags
(
    specimen text COLLATE pg_catalog."default",
    bone text COLLATE pg_catalog."default",
    sex text COLLATE pg_catalog."default",
    age text COLLATE pg_catalog."default",
    side_of_body text COLLATE pg_catalog."default",
    plane_of_picture text COLLATE pg_catalog."default",
    orientation text COLLATE pg_catalog."default",
    picture_number integer,
    logic_tag SERIAL PRIMARY KEY,
    scrape_name text COLLATE pg_catalog."default",
    CONSTRAINT unique_picture_number UNIQUE (picture_number)
);

-- The main table containing the uncertainties of each of the tags (datatype: BOOL)
CREATE TABLE IF NOT EXISTS public.uncertainty
(
    serial_id SERIAL PRIMARY KEY,
    uncertainty_specimen text COLLATE pg_catalog."default",
    uncertainty_bone text COLLATE pg_catalog."default",
    uncertainty_sex text COLLATE pg_catalog."default",
    uncertainty_age text COLLATE pg_catalog."default",
    uncertainty_side_of_body text COLLATE pg_catalog."default",
    uncertainty_plane_of_picture text COLLATE pg_catalog."default",
    uncertainty_orientation text COLLATE pg_catalog."default",
    picture_number integer
);

-- Table that records users, filled by the insert_user_data()
CREATE TABLE IF NOT EXISTS public.user_data
(
    user_id uuid DEFAULT uuid_generate_v4(),
    username1 character varying(255) COLLATE pg_catalog."default",
    logic_id SERIAL PRIMARY KEY,
    user_random integer
);

-- Table documenting users' intentions, filled by perform_user_action_with_documentation()
CREATE TABLE IF NOT EXISTS public.user_documentation
(
    documentation_id SERIAL PRIMARY KEY,
    action_type character varying(255) COLLATE pg_catalog."default",
    affected_row_id integer,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_random integer
);
