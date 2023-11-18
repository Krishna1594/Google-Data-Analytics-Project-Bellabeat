show global variables like 'local_infile';
USE Bellabeat_DB
SHOW TABLES
CREATE TABLE IF NOT EXISTS sleep(
	Id TEXT,
    DateLogged TEXT,
    TotalRecords TEXT,
    TotalMinsSlept TEXT,
    TotalMinsBed TEXT);
LOAD DATA LOCAL INFILE 'C:/Users/krish/OneDrive/Desktop/Professional Data Analytics Cert-GOOGLE/CASE STUDY -FINAL PROJECT/TRACK 1-BellaBeat/archive (1)/Fitabase Data 4.12.16-5.12.16/Database/sleeps.csv'
INTO TABLE sleep
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;