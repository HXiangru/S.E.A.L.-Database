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

1. Set port
2. Set password for default user *postgre*





<br> 

### pgAdmin

<br> 

https://www.pgadmin.org/download/





<br> 

---

<br> 

## 2. Database Creation

<br> 










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
6.  Open the prompt (SQL shell, or called psql), change the password using the coommand *ALTER USER here-is-your-username WITH PASSWORD 'here-is-your-new-password';*
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

<br>

---

<br>

## 5. Editing Examples

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

---

<br>

## 6. USE of Shiny APP

<br>





