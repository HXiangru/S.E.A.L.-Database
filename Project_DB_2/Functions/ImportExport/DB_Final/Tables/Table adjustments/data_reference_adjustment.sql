-- Add a picture_number column to the data_reference table
ALTER TABLE public.data_reference
ADD COLUMN picture_number integer;

-- Delete rows with null
DELETE FROM public.data_reference
WHERE picture_number IS NULL;

-- Add a primary key constraint using picture_number
ALTER TABLE public.data_reference
ADD CONSTRAINT data_reference_pkey PRIMARY KEY (picture_number);

-- Add a foreign key constraint referencing the picture_number column in data_tags
ALTER TABLE public.data_reference
ADD CONSTRAINT data_reference_data_tags_fk
FOREIGN KEY (picture_number)
REFERENCES public.data_tags (picture_number);
