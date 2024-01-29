-- Create the sequence
CREATE SEQUENCE data_tags_logic_tag_seq;

-- Add the columns to data_tags
ALTER TABLE public.data_tags
ADD COLUMN picture_number INTEGER,
ADD COLUMN logic_tag INTEGER NOT NULL DEFAULT nextval('data_tags_logic_tag_seq'::regclass),
ADD COLUMN scrape_name TEXT COLLATE pg_catalog."default",
ADD CONSTRAINT data_tags_pkey PRIMARY KEY (logic_tag),
ADD CONSTRAINT unique_picture_number UNIQUE (picture_number);

