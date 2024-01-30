1)	The first step is to start building all the tables required for managing the database, the SQL query is all_tables.sql. The query consists of five tables:
	a.	Data_tags  		-- These tables are still incomplete
	b.	Data_reference		-- 
	c.	Data_uncertainty
	d.	User_data
	e.	User_documentation
	f.	Now import the file data_tags.csv into data_tags table, and link_path into data_reference table in the link_path column
	g.	Important note: use the query remove_rows.sql to delete the rows [125,126,127]
2)	After having installed the tables and alterations have been made, now is time to fill picture_number in data_tags, data_refernce, and data_uncertainty. Using the queries and functions.
	a.	First fill the picture_number column in data_tags the required using picture_number_column_generator.sql query, this will use the function generate_unique_random_number().sql
	b.	Then use the queries to transfer the columns from data_tags to data_reference and data_uncertainty
		i.	To transfer from data_tags to data_refernce: picture_number_from_data_tags_to_data_reference.sql
		ii.	To transfer from data_tags to data_uncertainties: picture_number_from_data_tags_to_data_uncertainty.sql
	c.	Use the query insert_scrape_name.sql to fill in the column scrape_name in data_tags
	d.	Use the query store_image_as_binary_file.sql to fill in the stored_image column in data_reference 
3)	So after having altered the tables and each one contains the necessary information about the seals, it is now time to focus on the functions that allow for the automated scalability of the database.
