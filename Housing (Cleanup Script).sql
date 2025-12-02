USE housing;
SELECT * FROM nashville;

-- Change txt format of 'saledate' to date format, then change the column type to date type

SELECT saledate, STR_TO_DATE(saledate, '%d-%b-%y') AS converted_date
FROM nashville;

UPDATE nashville
SET saledate = STR_TO_DATE(saledate, '%d-%b-%y');

ALTER TABLE nashville
MODIFY COLUMN saledate DATE;

SHOW COLUMNS FROM nashville;

-- seperate property adress

SELECT SUBSTRING_INDEX(propertyaddress, ',', 1),
 SUBSTRING(propertyaddress, LOCATE(',', propertyaddress) +1) as address
FROM nashville;

ALTER TABLE nashville
ADD propertysplitaddress varchar(255);

UPDATE nashville
SET propertysplitaddress = SUBSTRING_INDEX(propertyaddress, ',', 1);

ALTER TABLE nashville
ADD propertysplitcity varchar(255);

UPDATE nashville
SET propertysplitcity =  SUBSTRING(propertyaddress, LOCATE(',', propertyaddress) +1);

SELECT * FROM nashville;

-- -- seperate owner adress


SELECT owneraddress
 FROM nashville;

SELECT SUBSTRING_INDEX(owneraddress, ',', 1) as address,
SUBSTRING_INDEX(owneraddress, ',', -1) as state,
TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1)) AS city
from nashville;


ALTER TABLE nashville
ADD splitowneraddress varchar(255);

ALTER TABLE nashville
ADD splitownerstate varchar(255);

ALTER TABLE nashville
ADD splitownercity varchar(255);

UPDATE nashville
SET splitowneraddress = SUBSTRING_INDEX(owneraddress, ',', 1);

UPDATE nashville
SET splitownerstate = SUBSTRING_INDEX(owneraddress, ',', -1);

UPDATE nashville
SET splitownercity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1));

SELECT * from nashville;

-- fix y/yes n/no -s

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
from nashville
GROUP BY soldasvacant
ORDER BY 2;

SELECT soldasvacant, CASE
when soldasvacant ='Y' then 'Yes'
when soldasvacant ='N' then 'No'
else soldasvacant
end as correctsoldasvacant
FROM nashville;

UPDATE nashville
SET soldasvacant =  CASE
when soldasvacant ='Y' then 'Yes'
when soldasvacant ='N' then 'No'
else soldasvacant
end ;

-- Check duplicates,SINCE IN MYSQL WE CANT DELETE VIA CTE WE HAVE TO CREATE A COPY TABLE AND INSERT ROW COUNT WHICH TELLS US DUPLICATES.

CREATE TABLE nashville2
LIKE nashville;

ALTER TABLE nashville2
ADD COLUMN rownumber int;

INSERT INTO nashville2
SELECT *,
ROW_NUMBER() 
OVER(PARTITION BY parcelid, propertyaddress,saleprice,saledate,legalreference ORDER BY UNIQUEID) as row_num
FROM nashville
ORDER BY parcelid;

DELETE
FROM nashville2
WHERE rownumber >1;

SELECT *
FROM nashville2
WHERE rownumber >1;

-- nashville2 is the main table since it doesnt have duplicates

ALTER TABLE nashville2
DROP COLUMN  taxdistrict; 

DESCRIBE nashville2;