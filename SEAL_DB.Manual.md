# Manual of Search Edit Archive Library (S.E.A.L.) 

<br> 

**Authors**  
*XiangRu Huang,*

**Contents**
1. Installation of PostgresSQL & pgAdmin
2. Database Creation
3. Connection via R
4. Querying Examples
5. Editing Examples
6. Use of Shiny APP

<br> 

---

<br> 

## 1. Installation of PostgresSQL & pgAdmin

<br> 

### PostgresSQL (version 16)

<br> 

https://www.postgresql.org/download/

* Set default port *5432*
* Set password for default user *postgre*

<br> 

### pgAdmin (version 4 v8.2)

<br> 

https://www.pgadmin.org/download/

Login the default server with default port, default user with the password you have set. The default server information:  
* Hostname: *localhost*
* Port: *5432*
* Password: *password*
* User: *postgres*

<br> 

---

<br> 

## 2. Database Creation

<br> 

The folder that is available in Github should include this file as well as a folder called *Project_DB2* (https://github.com/hxr303/S.E.A.L.-Database/tree/main/Project_DB_2). Download this folder, as it contains all the queries, functions, and files required to build this database with some contained data. 

<br> 

**1. Open pgAdmin, log in to your server.**
  
<br> 

**2. Create all functions by running the following code in *Query Tool*. Make sure every function is created successfully.**  

*export_image.sql*
```sql
CREATE OR REPLACE FUNCTION public.export_image(
	p_picture_number integer,
	p_target_directory text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    l_file_path TEXT;
BEGIN
    -- Generate a unique identifier for the filename
    l_file_path := p_target_directory || '/' || generate_unique_identifier(p_picture_number);

    -- Ensure the target directory exists; create it if not (adjust as needed)
    -- Note: PostgreSQL doesn't have a built-in command to create directories.
    -- You need to handle directory creation outside of the function.

    -- Check if the file exists before exporting
    IF EXISTS (SELECT 1 FROM data_reference WHERE picture_number = p_picture_number) THEN
        -- Export the data from data_reference to a server-side file
        EXECUTE FORMAT(
            'COPY (SELECT link_path FROM data_reference WHERE picture_number = %L) TO ''%s'' WITH CSV HEADER',
            p_picture_number,
            l_file_path
        );
    ELSE
        RAISE EXCEPTION 'No data found for picture_number %', p_picture_number;
    END IF;
END;
$BODY$;

ALTER FUNCTION public.export_image(integer, text)
    OWNER TO postgres;
```

<br> 

*import_image.sql*
```sql
-- FUNCTION: public.import_image(text, text[], boolean[])

-- DROP FUNCTION IF EXISTS public.import_image(text, text[], boolean[]);

CREATE OR REPLACE FUNCTION public.import_image(
    p_image_path text,
    p_data_tags text[],
    p_data_uncertainties boolean[]
)
RETURNS void
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    l_unique_name text;
    l_picture_number INTEGER;
    l_file_path text;
    l_image_data bytea;
BEGIN
    -- Generate a unique random number
    l_picture_number := generate_unique_random_number();

    -- Generate unique text scrape
    l_unique_name = generate_unique_identifier(p_data_tags) || l_picture_number::text;

    -- Define the file path in the storage directory
    l_file_path := 'C:\Program Files\PostgreSQL\16\Storage_Directory\' || l_unique_name;

    -- Use proper syntax for COPY command to read image data into a bytea variable
    EXECUTE FORMAT('COPY (SELECT pg_read_binary_file(%L)) TO %L', p_image_path, l_file_path) INTO l_image_data;

    -- Call insert_data_tags with the array of tags and the generated picture_number
    CALL insert_data_tags(p_data_tags, l_picture_number, l_unique_name);

    -- Call insert_uncertainty with the array of boolean values corresponding to the data_tags
    CALL insert_data_uncertainty(p_data_uncertainties, l_picture_number);

    -- Insert the file path and image data into the data_reference table
    INSERT INTO data_reference (picture_number, link_path, stored_images)
    VALUES (l_picture_number, l_file_path, l_image_data);
END;
$BODY$;

ALTER FUNCTION public.import_image(text, text[], boolean[])
    OWNER TO postgres;
```

<br> 

*insert_data_reference.sql*
```sql
CREATE OR REPLACE FUNCTION public.insert_data_reference(
	p_picture_number1 integer,
	p_file_path1 text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    -- Insert a new row into data_reference with the provided picture_number and file_path
    INSERT INTO data_reference (picture_number, link_path)
    VALUES (p_picture_number1, p_file_path1);
END;
$BODY$;

ALTER FUNCTION public.insert_data_reference(integer, text)
    OWNER TO postgres;
```

insert_data_tags.sql
```sql
CREATE OR REPLACE FUNCTION public.insert_data_tags(
	p_data_tags text[],
	p_picture_number integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    -- Generate a unique random number and insert a new row into data_tags
    INSERT INTO data_tags (picture_number, specimen, bone, sex, age, side_of_body, plane_of_picture, orientation) -- Add more columns as needed
    VALUES (p_picture_number, p_data_tags[1], p_data_tags[2], p_data_tags[3], p_data_tags[4], p_data_tags[5], p_data_tags[6], p_data_tags[7]); -- Adjust based on the number of tags
END;
$BODY$;

ALTER FUNCTION public.insert_data_tags(text[], integer)
    OWNER TO postgres;
```

<br> 

*insert_data_uncertainty.sql*
```sql
CREATE OR REPLACE FUNCTION public.insert_data_uncertainty(
	picture_number1 integer,
	p_data_uncertainty text[])
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    -- Insert a new row into uncertainty with the provided uncertainties and picture_number
    INSERT INTO uncertainty (
        picture_number,
        uncertainty_specimen,
        uncertainty_bone,
        uncertainty_sex,
        uncertainty_age,
        uncertainty_side_of_body,
        uncertainty_plane_of_picture,
        uncertainty_orientation
    )
    VALUES (
        picture_number1,
        p_data_uncertainty[1],
        p_data_uncertainty[2],
        p_data_uncertainty[3],
        p_data_uncertainty[4],
        p_data_uncertainty[5],
        p_data_uncertainty[6],
        p_data_uncertainty[7]
    );
END;
$BODY$;

ALTER FUNCTION public.insert_data_uncertainty(integer, text[])
    OWNER TO postgres;
```

<br> 

*insert_user_data.sql*
```sql
CREATE OR REPLACE FUNCTION public.insert_user_data(
	p_username1 character varying)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    INSERT INTO user_data (user_id, username1, user_random)
    VALUES (uuid_generate_v4(), p_username1, generate_random_number_5_digits());
END;
$BODY$;

ALTER FUNCTION public.insert_user_data(character varying)
    OWNER TO postgres;
```

*generate_unique_identifier.sql*
```sql
CREATE OR REPLACE FUNCTION public.generate_unique_identifier(
	data_list text[])
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_identifier VARCHAR(255);
BEGIN
    -- Concatenate non-null tags into one long string
    SELECT CONCAT_WS('',
        COALESCE(data_list[1], ''),  -- assuming data_list[1] corresponds to specimen
        COALESCE(data_list[2], ''),  -- assuming data_list[2] corresponds to bone
        COALESCE(data_list[3], ''),  -- assuming data_list[3] corresponds to sex
        COALESCE(data_list[4], ''),  -- assuming data_list[4] corresponds to age
        COALESCE(data_list[5], ''),  -- assuming data_list[5] corresponds to side_of_body
        COALESCE(data_list[6], ''),  -- assuming data_list[6] corresponds to plane_of_picture
        COALESCE(data_list[7], '')   -- assuming data_list[7] corresponds to orientation
    )
    INTO v_identifier;

    RETURN v_identifier;
END;
$BODY$;

ALTER FUNCTION public.generate_unique_identifier(text[])
    OWNER TO postgres;
```

<br> 

*generate_unique_random_number_5.sql*
```sql
CREATE OR REPLACE FUNCTION public.generate_random_number_5_digits(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    random_number INTEGER;
BEGIN
    -- Generate a random 5-digit number
    WHILE TRUE
    LOOP
        random_number := floor(random() * (99999 - 10000 + 1) + 10000)::INTEGER;

        EXIT WHEN NOT EXISTS (SELECT 1 FROM your_table WHERE your_column = random_number);
    END LOOP;

    RETURN random_number;
END;
$BODY$;

ALTER FUNCTION public.generate_random_number_5_digits()
    OWNER TO postgres;
```

<br> 

*generate_unique_random_number_6.sql*
```sql
CREATE OR REPLACE FUNCTION public.generate_unique_random_number(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    random_number INTEGER;
BEGIN
    LOOP
        random_number := floor(random() * 900000 + 100000)::INTEGER;
        EXIT WHEN NOT EXISTS (SELECT 1 FROM data_tags WHERE picture_number = random_number);
    END LOOP;

    RETURN random_number;
END;
$BODY$;

ALTER FUNCTION public.generate_unique_random_number()
    OWNER TO postgres;
```

<br> 

*admin_create.sql*
```sql
CREATE OR REPLACE FUNCTION public.admin_create(
	user_name character varying,
	user_password character varying)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
	BEGIN
		EXECUTE 'CREATE ROLE ' || quote_ident(user_name) || ' PASSWORD ' || quote_literal(user_password) || ' SUPERUSER';
    	EXECUTE 'ALTER ROLE ' || quote_ident(user_name) || ' CREATEROLE';
		SELECT insert_user_data(user_name);
	END;
$BODY$;
```

<br> 

*create_standard_user.sql*
```sql
CREATE OR REPLACE FUNCTION public.create_standard_user(
	p_username character varying,
	p_password character varying)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    -- Create the user
    EXECUTE 'CREATE USER ' || quote_ident(p_username) || ' WITH PASSWORD ' || quote_literal(p_password);

    -- Grant privileges to add, change, and delete rows
    EXECUTE 'GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO ' || quote_ident(p_username);

    -- Grant privileges to import/export OID files
    EXECUTE 'GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ' || quote_ident(p_username);

    -- Grant privileges to import/export text arrays
    EXECUTE 'GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO ' || quote_ident(p_username);
	SELECT insert_user_data(p_username);
END;
$BODY$;

ALTER FUNCTION public.create_standard_user(character varying, character varying)
    OWNER TO postgres;
```

<br> 

*perform_user_action_with_documentation.sql*
```sql
CREATE OR REPLACE FUNCTION public.perform_user_action_with_documentation(
	p_username character varying,
	p_action_type character varying,
	p_affected_picture_number integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_user_id INTEGER;
BEGIN
    -- Retrieve the user_id based on the provided username
    SELECT user_random INTO v_user_id
    FROM user_data
    WHERE username1 = p_username;

    IF NOT FOUND THEN
        -- Username does not exist, handle accordingly
        RAISE EXCEPTION 'Username % does not exist in user_data', p_username;
    END IF;

    -- Record the action in user_documentation using the retrieved user_id and affected_picture_number
    INSERT INTO user_documentation (user_random, action_type, affected_row_id, timestamp)
    VALUES (v_user_id, p_action_type, p_affected_picture_number, CURRENT_TIMESTAMP);
END;
$BODY$;

ALTER FUNCTION public.perform_user_action_with_documentation(character varying, character varying, integer)
    OWNER TO postgres;
```

<br> 
<br> 

**3. Create tables**.  

1. The third step is to start building all the tables required for managing the database by *Query Tool*. Run the following code (*all_tables.sql*).The query consists of five incomplete tables
   1. Data_tags  	
   2. Data_reference		
   3. Data_uncertainty
   4. User_data (private table)
   5. User_documentation
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- data_reference table is used to allow for files to be exported
CREATE TABLE IF NOT EXISTS public.data_reference
(
    --picture_id integer NOT NULL DEFAULT nextval('data_reference_picture_id_seq'::regclass),
    link_path text COLLATE pg_catalog."default"
    --picture_number integer,
    --CONSTRAINT data_reference_pkey PRIMARY KEY (picture_id)
);

-- The main table containing the tags for the images
-- The commented out section will be filled with a ALTER TABLE QUERY
CREATE TABLE IF NOT EXISTS public.data_tags
(
    specimen text COLLATE pg_catalog."default",
    bone text COLLATE pg_catalog."default",
    sex text COLLATE pg_catalog."default",
    age text COLLATE pg_catalog."default",
    side_of_body text COLLATE pg_catalog."default",
    plane_of_picture text COLLATE pg_catalog."default",
    orientation text COLLATE pg_catalog."default"
	--	picture_number integer,
	--  logic_tag integer NOT NULL DEFAULT nextval('data_tags_logic_tag_seq'::regclass),
	--  scrape_name text COLLATE pg_catalog."default",
	--  CONSTRAINT data_tags_pkey PRIMARY KEY (logic_tag),
	--	CONSTRAINT unique_picture_number UNIQUE (picture_number)
);

-- The main table containing the uncertainties of each of the tags (datatype: BOOL)
CREATE TABLE IF NOT EXISTS public.uncertainty
(
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
    user_id uuid NOT NULL DEFAULT uuid_generate_v4(),
    username1 character varying(255) COLLATE pg_catalog."default",
    logic_id SERIAL PRIMARY KEY,
    user_random integer
);


-- Table documenting users intentions, filled by perform_user_action_with_documentation()
CREATE TABLE IF NOT EXISTS public.user_documentation
(
    documentation_id SERIAL PRIMARY KEY,
    action_type character varying(255) COLLATE pg_catalog."default",
    affected_row_id integer,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_random integer
);
```

2. Now import the file *data_tags.csv* into *data_tags* table,*link_path.csv* into *data_reference* table, and *Uncertainties.csv* into *uncertainty* table. Remember to enable the Header while importing.

3. Run the following code (*remove_rows.sql*) to delete the rows *[125,126,127*] in tables.

```sql
-- Assuming you want to delete rows from data_tags where logic_tag is in [125, 126, 127]
DELETE FROM data_tags
WHERE serial_id IN (125, 126, 127);

-- Assuming you want to delete rows from data_tags where logic_tag is in [125, 126, 127]
DELETE FROM data_reference
WHERE serial_id IN (125, 126, 127);

-- Assuming you want to delete rows from data_tags where logic_tag is in [125, 126, 127]
DELETE FROM uncertainty
WHERE serial_id IN (125, 126, 127);
```

<br> 
   
**3. Table adjustments**

1. After having installed the tables and alterations have been made, now is time to fill *picture_number* in *data_tags*, *data_refernce*, and *data_uncertainty*. Using the queries and functions.
   1. First fill the picture_number column in data_tags the required using picture_number_column_generator.sql query, this will use the function generate_unique_random_number().sql
   2. Then use the queries to transfer the columns from data_tags to data_reference and data_uncertainty
      1. To transfer from data_tags to data_reference: picture_number_from_data_tags_to_data_reference.sql
      2. To transfer from data_tags to data_uncertainties: picture_number_from_data_tags_to_data_uncertainty.sql
   3. Use the following code insert_scrape_name.sql to fill in the column scrape_name in data_tags
   4. Use the query store_image_as_binary_file.sql to fill in the stored_image column in data_reference 

<br>

**4. After having altered the tables and each one contains the necessary information about the seals, it is now time to focus on the functions that allow for the automated scalability of the database.**






<br> 

---

<br> 

## 3. Connection via R

<br> 

**Software setup needed, install and library package *RPostgreSQL* in R.**
```r
install.packages("RPostgreSQL")
library(RPostgreSQL)
```

<br> 

**Establish the connection, by providing name of database, port of server, user name and password.**
```r
con <- dbConnect(
  PostgreSQL(),
  dbname = "S.E.A.L.",       #name of imported database
  port = 5432,               #port of imported server
  user = "postgres",         #username
  password = "password")     #password
```

<br> 

**Test a random query to check the connection.**
```r
test_query <- "SELECT 1"
test_result <- dbGetQuery(con, test_query)
if (!is.null(result)) {
  cat("Connection verified. Test query successful.\n")
} else {
  cat("Error: Connection test query failed.\n")
}
```

<br> 

**Disconnect**
```r
dbDisconnect(con)
```

<br> 

**Error**

The connection process should be the same for both Windows system and macOS system, however, but Windows users may encounter errors with the version of *libpq* in the *RPostgreSQL* package. However, it might occur when the *libpq* version is over 10. In this case, we need to alter the authetication from from *scram-sha-256* to another one, here we chose *md5*.

```r
RPosgreSQL error: 
could not connect postgres@localhost:5432 on dbname "S.E.A.L.": SCRAM authentication requires libpq version 10 or above
```

1. Check again if your libpq.dll files are over version 10, and have newest softwares (e.g. R, RPostgreSQL)
2. Close all the softwares and terminals.
3. Go to the install location of PostgreSQL, open folder *data*, you’ll see two conf files called *pg_hba* and *postgresql*.
4. Set *password_encryption = md5* in postgresql.conf
5. Set *METHODS* be *md5* in pg_hba.conf
6.  Open the prompt (SQL shell, or called psql), log in, change the password using the following command 
   ```psql
   ALTER USER here-is-your-username WITH PASSWORD 'here-is-your-new-password';
   ```
7. Reload the server of PostgreSQL, re log in to pgAdmin
8. Restart Rstudio, reconnect the server and it should work now 

<br> 

---

<br> 

## 4. Querying Examples

<br> 

**1. Select/exclude certain columns and/or rows**
  
<br>

Query all tables in the selected database
```r
tables <- dbListTables(con)
print(tables)
```

<br>

Get all information from the table "data_tags"
```r
initial.query <- "SELECT * FROM data_tags"
initial.table <- dbGetQuery(con, initial.query)
```

<br>

Get columns "specimen" and "bone" from the table "data_tags"
```r
query <- "SELECT specimen, bone FROM data_tags"
table <- dbGetQuery(con, query)
```

<br>

Get all rows having "ulna" in column "bone" from the table "data_tags"
```r
query <- "SELECT * FROM public.data_tags WHERE bone = 'ulna'"
table <- dbGetQuery(con, query)
```

<br>

Get columns "specimen" and "bone" from the table "data_tags", but only with rows having "A. pusilus_1" in column "specimen" and "rib" in column "bone"
```r
query <- "SELECT specimen, bone FROM public.data_tags
           WHERE specimen = 'Arctocephalus pusillus_1'
           AND bone = 'rib';"
table <- dbGetQuery(con, query)
```

<br>

Get all rows containing "ume" in column "bone" from the table "data_tags"
```r
query <- "SELECT * FROM data_tags
          WHERE bone like '%ume%';"
table <- dbGetQuery(con, query)
```

<br>

Get all rows containing "hum" in column "bone", with "hum" as the start
```r
query <- "SELECT * FROM data_tags
          WHERE bone like 'hum%';"
table <- dbGetQuery(con, query)
```

<br>

Get all rows containing "rus" in column "bone", with "rus" as the end
```r
query <- "SELECT * FROM data_tags
          WHERE bone like '%rus';"
table <- dbGetQuery(con, query)
```

<br>

Get all rows not containing "ume" in column "bone" from the table "data_tags"
```r
query <- "SELECT * FROM data_tags
          WHERE bone NOT like '%ume%';"
table <- dbGetQuery(con, query)
```

<br>

Get rows containing “1"，“2” and "3" in column "logic_tag" from the table "data_tags"
```r
query <- "SELECT * FROM data_tags
          WHERE logic_tag IN (1, 2, 3);"
table <- dbGetQuery(con, query)
```

<br>

Get rows not containing “rib"，“humerus” and "scapula" in column "bone" from the table "data_tags"
```r
query <- "SELECT * FROM data_tags
          WHERE bone NOT IN ('rib', 'humerus', 'scapula');"
table <- dbGetQuery(con, query)
```

<br>

Find a certain cell from table "data_tags" by giving a certain row and column
```r
query <- "SELECT bone FROM data_tags
          WHERE logic_tag = '19';"
table <- dbGetQuery(con, query)
```

<br> 
<br>

**2. Multiple conditions** 

<br>  

AND: both conditions are true
```r
query <- "SELECT * FROM data_tags
          WHERE specimen = 'Arctocephalus pusillus_1'
          AND bone = 'rib';"
table <- dbGetQuery(con, query)
```

<br>

OR: any condition should be true
```r
query <- "SELECT * FROM data_tags
          WHERE specimen = 'Arctocephalus pusillus_1'
          OR bone = 'humerus';"
table <- dbGetQuery(con, query)
```

<br>

AND & OR: in this case, either both specimen = 'Arctocephalus pusillus_1' is true, or both bone = 'humerus' and sex = 'female' are true
```r
query <- "SELECT * FROM data_tags
          WHERE specimen = 'Arctocephalus pusillus_1'
          OR bone = 'humerus'
          AND sex = 'female';"
table <- dbGetQuery(con, query)
```

<br>

IS NOT NULL: select rows that is not null in column "logic_tag" from the table "data_tags"
```r
query <- 'SELECT * FROM data_tags
          WHERE "logic_tag" IS NOT NULL;'
table <- dbGetQuery(con, query)
```

<br>

BETWEEN: select rows that is between 1 and 10 in column "logic_tag" from the table "data_tags"
```r
query <- "SELECT * FROM data_tags
          WHERE logic_tag BETWEEN 1 AND 10
          ORDER BY logic_tag;"
table <- dbGetQuery(con, query)
```

<br>  
<br>

**3. Order data (changes to tables in R only)**
   
<br>

Get ordered table "data_tags" based on "logic_tag" in ascending order
```r
query <- "SELECT * FROM data_tags ORDER BY logic_tag;"
```
Or
```r
query <- "SELECT * FROM data_tags ORDER BY specimen ASC;"
table <- dbGetQuery(con, query5)
```

<br>

Get ordered table "data_tags" based on "logic_tag" in descending order
```r
query <- "SELECT * FROM data_tags ORDER BY logic_tag DESC;"
table <- dbGetQuery(con, query)
```

<br>

Get ordered table "data_tags" based on "bone" first, then "logic_tag"
```r
query <- "SELECT * FROM data_tags ORDER BY bone,logic_tag;"
table <- dbGetQuery(con, query)
```

<br>
<br>

**4. Group data**

<br>

Check all "specimen"s by grouping
```r
query <- "SELECT specimen FROM msp GROUP BY specimen;"
table <- dbGetQuery(con, query)
```

<br>

Check all "specimen"s by grouping, and count each "specimen"
```r
query <- "SELECT specimen, count(1)
          FROM msp GROUP BY specimen;"
table <- dbGetQuery(con, query)
```

<br>

Check all "specimen"s from the table "data_tags", count each "specimen", and find the max/min number in their "logic_tag"
```r
query <- "SELECT specimen, count(1),max(logic_tag),min(logic_tag)
          FROM data_tags GROUP BY specimen;"
table <- dbGetQuery(con, query)
```

<br>

Limit the max "logic_tag" be smaller than 100
```r
query <- "SELECT specimen, count(1), max(logic_tag), min(logic_tag)
          FROM data_tags
          GROUP BY specimen
          HAVING max(logic_tag) < 100;"
table <- dbGetQuery(con, query)
```

<br>
<br>

**5. Join relational tables**

<br>  

Join two tables "data_tags" and "data_uncertainty" together, with the corresponding columns table1."bone" and table2."bone"
```r
query <- "SELECT *
          FROM data_tags 
          INNER JOIN data_uncertainty 
          ON data_tags.\"bone\" = data_uncertainty.\"bone\";"
table <- dbGetQuery(con, query)
```

<br>

Set "data_tags" and "data_uncertainty" as t1 and t2 in query
```r
query <- "SELECT *
          FROM data_tags AS t1
          INNER JOIN data_uncertainty AS t2
          ON t1.\"bone\" = t2.\"bone\";"
table <- dbGetQuery(con, query)
```


<br>
<br>

**6. Users**

Create a user
```r
???
```

<br>

Query the user documentation
```r
user.query <- "SELECT * FROM user_documentation"
user.table <- dbGetQuery(con, user.query)
```

<br>

---

<br>

## 5. Editing Examples

<br>

**Roll back commitment**

Use it to avoid editorial mistakes.

<br>

* Start editing
```r
dbBegin(con)
```

* Roll back
```r
dbRollback(con)
```

* Commit
```r
dbCommit(con)
```

* Disconnect
```r
dbDisconnect(con)
```

<br>

**1. Update data**

<br>

Set all rows in "sex" column into "male" from table "data_tags"
```r
query <- "UPDATE data_tags SET sex = 'male';"
dbExecute(con, query)
```

<br>

Set "sex" column of the "Cystophora cristata" row in "specimen" column to "male"
```r
query <- "UPDATE data_tags
          SET sex = 'female'
          WHERE specimen = 'Cystophora cristata';"
dbExecute(con, query)
```

<br>

Set a certain cell from table "data_tags" by giving a certain row and column
```r
query <- "UPDATE data_tags
          SET sex = 'female'
          WHERE logic_tag = '1';"
dbExecute(con, query)
```

<br>
<br>

**2. Insert data**

<br>

Insert a new row with "specimen" as "specimen"
```r
query <- "INSERT INTO public.data_tags (\"specimen\") VALUES ('specimen');"
dbExecute(con, query)
```

<br>

Insert a new column called "size" with the data type of integer
```r
query <- "ALTER TABLE data_tags ADD COLUMN size INTEGER"
dbExecute(con, query)
```

<br>
<br>

**3. Delete data**

<br>

Delete the table "data_tags"
```r
query <- "DELETE FROM data_tags"
dbExecute(con, query)
```

<br>

Delete "specimen" column from table "data_tags"
```r
query <- "ALTER TABLE data_tags DROP COLUMN specimen"
dbExecute(con, query)
```

<br>

Delete the "specimen" row in "specimen" column from table "data_tags"
```r
query <- "DELETE FROM data_tags
          WHERE specimen = 'specimen';"
dbExecute(con, query)
```

<br>
<br>

**4. Create tables**

<br>

Create the table named msp, including columns "specimen" and "picture_number" with data types "text" and "integer", add more columns as needed
```r
query <- "CREATE TABLE IF NOT EXISTS public.msp (
          specimen TEXT,
          picture_number INTEGER);"
dbExecute(con, query)
```

<br>

Create the table and set "picture_number" as the primary key
```r
query <- "CREATE TABLE IF NOT EXISTS public.msp (
          specimen TEXT,
          picture_number INTEGER,
          CONSTRAINT picture_number_pkey PRIMARY KEY (picture_number));"
dbExecute(con, query)
```

<br>
<br>

**5. Order data (changes to the table from the dataset)**

<br>

Get ordered table "data_tags" based on "logic_tag" in ascending order
```r
query <- "SELECT * FROM data_tags ORDER BY logic_tag;"
```
Or
```r
query <- "SELECT * FROM data_tags ORDER BY specimen ASC;"
table <- dbGetQuery(con, query5)
```

<br>

Get ordered table "data_tags" based on "logic_tag" in descending order
```r
query <- "SELECT * FROM data_tags ORDER BY logic_tag DESC;"
table <- dbGetQuery(con, query)
```

<br>

Get ordered table "data_tags" based on "bone" first, then "logic_tag"
```r
query <- "SELECT * FROM data_tags ORDER BY bone,logic_tag;"
table <- dbGetQuery(con, query)
```

<br>
<br>

**6. Query the editing history**

```r
???
```

<br>

---

<br>

## 6. USE of Shiny APP

<br>





