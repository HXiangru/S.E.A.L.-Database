# ??? Manual

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

### PostgresSQL

<br> 

https://www.postgresql.org/download/

* Set default port *5432*
* Set password for default user *postgre*





<br> 

### pgAdmin

<br> 

https://www.pgadmin.org/download/

Login the default server with default port, default user with the password you have set. The default server information:  
* Hostname: localhost
* Port: 5432
* Password: ‘password’
* User: postgres



<br> 

---

<br> 

## 2. Database Creation

<br> 

The folder that is available in Github should include this file as well as a folder called *Project_DB2* (https://github.com/hxr303/S.E.A.L.-Database/tree/main/Project_DB_2). Download this folder, as it contains all the queries, functions, and files required to build this database with some contained data. 

<br> 

**1. Open pgAdmin, log in to your server.**
  
<br> 

**2. Open *Query Tool*, run the following ode**.  

   ```sql
   CREATE TABLE IF NOT EXISTS public.data_tags
   (
     specimen text COLLATE pg_catalog."default",
     bone text COLLATE pg_catalog."default",
     sex text COLLATE pg_catalog."default",
     age text COLLATE pg_catalog."default",
     side_of_body text COLLATE pg_catalog."default",
     plane_of_picture text COLLATE pg_catalog."default",
     orientation text COLLATE pg_catalog."default"
   )
   ```

   * Importing *data_tags.csv* which should be located in *files*, will be imported into PostgreSQL, it is important that *header* is enabled in *options*.
   
   * After the CSV file has been imported, add two columns by running the following code in *Query Tool*.  
   
   ```sql
   ALTER TABLE data_tags
   ADD COLUMN picture_number INTEGER,
   ADD CONSTRAINT unique_picture_number UNIQUE (picture_number);

   ALTER TABLE data_tags
   ADD COLUMN logic_tag SERIAL NOT NULL DEFAULT nextval('data_tags_logic_tag_seq'::regclass),
   ADD CONSTRAINT data_tags_pkey PRIMARY KEY (logic_tag);
   ```

<br> 
<br> 

**3. Add the randomly generated numbers to the *picture_number* column by running the following code in *Query Tool*.**  
   
   * Add the function *generate_unique_random_number* first
   
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

   * Generate picture number
   
   ```sql
   DO $$ 
   DECLARE
       row_data RECORD;
       new_picture_number INTEGER;
   BEGIN
       -- Loop through rows where specimen is not NULL
       FOR row_data IN SELECT * FROM public.data_tags WHERE specimen IS NOT NULL
       LOOP
           -- Generate a new unique random number
           new_picture_number := generate_unique_random_number();

           -- Update each row with the generated random number
           UPDATE public.data_tags
           SET picture_number = new_picture_number
           WHERE logic_tag = row_data.logic_tag;

           -- You can add additional logic or print statements if needed
           -- RAISE NOTICE 'Updated picture_number for logic_tag %', row_data.logic_tag;
       END LOOP;
   END $$;
   ```

<br> 
<br> 

**4. Create *user_data* table in which user data is stored (UUID, usernames, password)**
   
   * First add the extension by running the following code in *Query Tool*. b.	After you run this code you might see in your function dropdown that a lot of UUID functions got added, they are extensions from the UUID-ossa package which allows them to become a global entity.
   
   ```sql
   CREATE OR REPLACE FUNCTION public.create_standard_user(
    p_username VARCHAR,
     p_password VARCHAR)
   RETURNS void
   LANGUAGE 'plpgsql'
   COST 100
   VOLATILE PARALLEL UNSAFE
   AS $BODY$
   BEGIN
       -- Create the user
       EXECUTE 'CREATE USER ' || quote_ident(p_username) || ' WITH PASSWORD' ||  quote_literal(p_password);

       -- Grant privileges to add, change, and delete rows
       EXECUTE 'GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO ' || quote_ident(p_username);

       -- Grant privileges to import/export OID files
       EXECUTE 'GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ' || quote_ident(p_username);

       -- Grant privileges to import/export text arrays
       EXECUTE 'GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO ' || quote_ident(p_username);
   END;
   $BODY$;
   ```

   * Add *user_data* table by running the following code in *Query Tool*.
   ```sql
   -- Enable the uuid-ossp extension
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

   CREATE TABLE IF NOT EXISTS public.user_data (
       user_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
       username1 VARCHAR(255),
       password1 VARCHAR(255)
   );
   ```

<br> 
<br> 

**5. Creating the user functions that will be used for creating a user in the database**

   * Admin is a SUPERUSER by running the following code in *Query Tool*. It can change any feature within the database, and later in the UI there might be an option to create additional admins if the database becomes scalable.
  
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
     END;
   $BODY$;
   ```

   * Create a standard user by running the following code in *Query Tool*. This function is not a superuser so the user needs to be granted permission to execute certain queries, and only has access to the table *data_tags*.
     * Insert, update, and delete rows
     * Usage of all sequences in the schema
     * Grant executes all functions in the public schema

  ```sql
  CREATE OR REPLACE FUNCTION public.create_standard_user(
      p_username VARCHAR,
      p_password VARCHAR)
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
  END;
  $BODY$;
  ```

   * Gnenerate the random correspondant UUID to take input of a user that has just created a username and 'password', by running the following code in *Query Tool*.
  
```sql
CREATE OR REPLACE FUNCTION public.insert_user_data(
    p_username1 VARCHAR,
    p_password1 VARCHAR)
RETURNS void
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    INSERT INTO user_data (user_id, username1, password1)
    VALUES (uuid_generate_v4(), p_username1, p_password1);
END;
$BODY$;
```

<br> 
<br> 

**6. Create *user_documentation* table. This will record the changes being made to the table *data_tags*. It allows to take the user that is editing it and the details also the *picture_number* specifying the row that was edited.**

* Run the following code to create the function first.

```sql
CREATE OR REPLACE FUNCTION public.perform_user_action_with_documentation(
	p_username character varying,
	p_action_type character varying,
	p_password character varying,
	p_affected_picture_number integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_user_id UUID;
BEGIN
    -- Retrieve the user_id based on the provided username
    SELECT user_id INTO v_user_id
    FROM user_data
    WHERE username1 = p_username;

    IF NOT FOUND THEN
        -- Username does not exist, handle accordingly
        RAISE EXCEPTION 'Username % does not exist in user_data', p_username;
    END IF;

    -- Record the action in user_documentation using the retrieved user_id and affected_picture_number
    INSERT INTO user_documentation (user_id, action_type, affected_row_id, timestamp)
    VALUES (v_user_id, p_action_type, p_affected_picture_number, CURRENT_TIMESTAMP);
END;
$BODY$;
```

* Build the *user_documentation.sql* table by running the following code in *Query Tool*.
  *  Documentation_id which is the serial primary key
  *  User_id is UUID from the user_data table
  *  Action_type is a VARCHAR
  *  Affected_row_id is INTEGER
  *  Timestamp gives data and time

```sql
CREATE TABLE user_documentation (
    documentation_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES user_data(user_id),
    action_type VARCHAR(255),
    affected_row_id INTEGER,  -- Reference to the row in data_tags
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```









<br> 

---

<br> 

## 3. Connection via R

<br> 

Software setup needed, install and library package *RPostgreSQL* in R.
```r
install.packages("RPostgreSQL")
library(RPostgreSQL)
```

Establish the connection, by providing name of database, port of server, user name and password.
```r
con <- dbConnect(
  PostgreSQL(),
  dbname = "pro306",         #name of imported database
  port = 5432,               #port of imported server
  user = "postgres",         #username
  password = "password")     #password
```

Test a random query to check the connection.
```r
test_query <- "SELECT 1"
test_result <- dbGetQuery(con, test_query)
if (!is.null(result)) {
  cat("Connection verified. Test query successful.\n")
} else {
  cat("Error: Connection test query failed.\n")
}
```

The connection process should be the same for both Windows system and macOS system, however, but Windows users may encounter errors with the version of *libpq* in the *RPostgreSQL* package. However, it might occur when the *libpq* version is over 10. In this case, we need to alter the authetication from from *scram-sha-256* to another one, here we chose *md5*.

```r
RPosgreSQL error: 
could not connect postgres@localhost:5432 on dbname "pro306": SCRAM authentication requires libpq version 10 or above
```

1. Check again if your libpq.dll files are over version 10, and have newest softwares (e.g. R, RPostgreSQL)
2. Go to the install location of PostgreSQL, open folder *data*, you’ll see two conf files called *pg_hba* and *postgresql*.
3. Set *password_encryption = md5* in postgresql.conf
4. Set *METHODS* be *md5* in pg_hba.conf
5. Reload PostgreSQL
6.  Open the prompt (SQL shell, or called psql), log in, change the password using the following coommand 
   ```psql
   ALTER USER here-is-your-username WITH PASSWORD 'here-is-your-new-password';
   ```
7.  Go to Rstudio, reconnect the server and it should work now 

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

Get all information from the table "msp"
```r
initial.query <- "SELECT * FROM msp"
initial.table <- dbGetQuery(con, initial.query)
```

Get columns "specimen" and "bone" from the table "msp"
```r
query <- "SELECT specimen, bone FROM msp"
table <- dbGetQuery(con, query)
```

Get all rows having "ulna" in column "bone" from the table "msp"
```r
query <- "SELECT * FROM public.msp WHERE bone = 'ulna'"
table <- dbGetQuery(con, query)
```

Get columns "specimen" and "bone" from the table "msp", but only with rows having "A. pusilus_1" in column "specimen" and "rib" in column "bone"
```r
query <- "SELECT specimen, bone FROM public.msp
           WHERE specimen = 'A. pusilus_1'
           AND bone = 'rib';"
table <- dbGetQuery(con, query)
```
Get all rows containing "ume" in column "bone" from the table "msp"
```r
query <- "SELECT *
          FROM msp
          WHERE bone like '%ume%';"
table <- dbGetQuery(con, query)
```

Get all rows containing "hum" in column "bone", with "hum" as the start
```r
query <- "SELECT *
          FROM msp
          WHERE bone like 'hum%';"
table <- dbGetQuery(con, query)
```

Get all rows containing "rus" in column "bone", with "rus" as the end
```r
query <- "SELECT *
          FROM msp
          WHERE bone like '%rus';"
table <- dbGetQuery(con, query)
```

Get all rows not containing "ume" in column "bone" from the table "msp"
```r
query <- "SELECT *
          FROM msp
          WHERE bone NOT like '%ume%';"
table <- dbGetQuery(con, query)
```

Get rows containing “1800"，“1801” and "1802" in column "picture number" from the table "msp"
```r
query <- "SELECT *
          FROM msp
          WHERE \"picture number\" IN (1800, 1801, 1802);"
table <- dbGetQuery(con, query)
```

Get rows not containing “rib"，“humerus” and "scapula" in column "bone" from the table "msp"
```r
query <- "SELECT *
          FROM msp
          WHERE bone NOT IN ('rib', 'humerus', 'scapula');"
table <- dbGetQuery(con, query)
```

Find a certain cell from table "msp" by giving a certain row and column
```r
query <- "SELECT bone
          FROM msp
          WHERE \"picture number\" = '1900';"
table <- dbGetQuery(con, query)
```
<br> 
<br>

**2. Order data (changes to tables in R only)**
   
<br>

Get ordered table "msp" based on "picture number" in ascending order
```r
query <- "SELECT * FROM msp ORDER BY \"picture number\";"
```
Or
```r
query <- "SELECT * FROM msp ORDER BY specimen ASC;"
table <- dbGetQuery(con, query5)
```

Get ordered table "msp" based on "picture number" in descending order
```r
query <- "SELECT * FROM msp ORDER BY \"picture number\" DESC;"
table <- dbGetQuery(con, query)
```

Get ordered table "msp" based on "specimen" first, then picture number"
```r
query <- "SELECT * FROM msp ORDER BY specimen,\"picture number\";"
table <- dbGetQuery(con, query)
```

<br>
<br>

**3. Group data**

<br>

Check all "specimen"s by grouping
```r
query <- "SELECT specimen FROM msp GROUP BY specimen;"
table <- dbGetQuery(con, query)
```

Check all "specimen"s by grouping, and count each "specimen"
```r
query <- "SELECT specimen, count(1)
          FROM msp GROUP BY specimen;"
table <- dbGetQuery(con, query)
```

Check all "specimen"s by grouping, count each "specimen", and find the max/min number in their "picture number"
```r
query <- "SELECT specimen, count(1),max(\"picture number\"),min(\"picture number\")
          FROM msp GROUP BY specimen;"
table <- dbGetQuery(con, query)
```

Limit the max "picture number" be smaller than 1800
```r
query <- "SELECT specimen, count(1),max(\"picture number\"),min(\"picture number\")
          FROM msp GROUP BY specimen
          HAVING max(\"picture number\") < 1800;"
table <- dbGetQuery(con, query)
```
<br>
<br>

**4. Multiple conditions** 

<br>  

AND: both conditions are true
```r
query <- "SELECT * FROM msp
          WHERE specimen = 'A. pusilus_1'
          AND bone = 'rib';"
table <- dbGetQuery(con, query)
```

OR: any condition should be true
```r
query <- "SELECT * FROM msp
          WHERE specimen = 'A. pusilus_1'
          OR bone = 'humerus';"
table <- dbGetQuery(con, query)
```

AND & OR: in this case, either both specimen = 'A. pusilus_1' is true, or both bone = 'humerus' and sex = 'female' are true
```r
query <- "SELECT * FROM msp
          WHERE specimen = 'A. pusilus_1'
          OR bone = 'humerus'
          AND sex = 'female';"
table <- dbGetQuery(con, query)
```

IS NOT NULL: select rows that is not null in column "editing user" from the table "msp"
```r
query <- 'SELECT * FROM msp
          WHERE "editing user" IS NOT NULL;'
table <- dbGetQuery(con, query)
```

BETWEEN: select rows that is between 1 and 1800 in column "picture number" from the table "msp"
```r
query <- "SELECT * FROM msp
          WHERE \"picture number\" BETWEEN 1 AND 1800
          ORDER BY \"picture number\";"
table <- dbGetQuery(con, query)
```

<br>  
<br>

**5. Join relational tables**

<br>  

Join two tables "table1" and "table2" together, with the corresponding columns table1."ID" and table2."ID"
```r
query <- "SELECT *
          FROM table1
          INNER JOIN table2
          ON table1.\"ID\" = table2.\"ID\";"
table <- dbGetQuery(con, query)
```

Set "table1" and "table2" as t1 and t2 in query
```r
query <- "SELECT *
          FROM table1 AS t1
          INNER JOIN table2 AS t2
          ON t1.\"ID\" = t2.\"ID\";"
table <- dbGetQuery(con, query)
```

Query the user documentation
```r
???
```

<br>
<br>

**6. Create a user**

```r
???
```

<br>

---

<br>

## 5. Editing

<br>

**Roll back commitment**

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

Set all rows in "sex" column into "male" from table "msp"
```r
query <- "UPDATE msp SET sex = 'male';"
dbExecute(con, query)
```

Set "sex" column of the "C. cristata" row in "specimen" column to "male"
```r
query <- "UPDATE msp
          SET sex = 'female'
          WHERE specimen = 'C. cristata';"
dbExecute(con, query)
```

Set a certain cell from table "msp" by giving a certain row and column
```r
query <- "UPDATE msp
          SET sex = 'female'
          WHERE \"picture number\" = '1';"
dbExecute(con, query)
```

<br>
<br>

**2. Insert data**

<br>

Insert a new row with "specimen" as "specimen"
```r
query <- "INSERT INTO public.msp (\"specimen\") VALUES ('specimen');"
dbExecute(con, query)
```

<br>
<br>

**3. Delete data**

<br>

Delete the table "msp"
```r
query <- "DELETE FROM msp"
dbExecute(con, query)
```

Delete the "specimen" row in "specimen" column from table "msp"
```r
query <- "DELETE FROM msp
          WHERE specimen = 'specimen';"
dbExecute(con, query)
```

<br>
<br>

**4. Order data (changes to the table from the dataset)**

<br>

Get ordered table "msp" based on "picture number" in ascending order
```r
query <- "SELECT * FROM msp ORDER BY \"picture number\";"
```
Or
```r
query <- "SELECT * FROM msp ORDER BY specimen ASC;"
dbExecute(con, query)
```

Get ordered table "msp" based on "picture number" in descending order
```r
query <- "SELECT * FROM msp ORDER BY \"picture number\" DESC;"
dbExecute(con, query)
```

Get ordered table "msp" based on "specimen" first, then picture number"
```r
query <- "SELECT * FROM msp ORDER BY specimen,\"picture number\";"
dbExecute(con, query)
```

<br>
<br>

**5. Query the editing history**

```r
???
```

<br>

---

<br>

## 6. USE of Shiny APP

<br>





