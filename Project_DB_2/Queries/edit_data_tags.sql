ALTER TABLE data_tags
ADD CONSTRAINT unique_picture_number UNIQUE (picture_number);
ALTER TABLE your_table
ADD COLUMN logic_tag SERIAL PRIMARY KEY;
	
