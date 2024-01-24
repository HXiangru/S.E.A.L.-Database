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
    logic_tag integer NOT NULL DEFAULT nextval('data_tags_logic_tag_seq'::regclass),
    CONSTRAINT data_tags_pkey PRIMARY KEY (logic_tag),
    CONSTRAINT unique_picture_number UNIQUE (picture_number)
)