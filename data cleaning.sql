-- Data Cleaning
-- --------------------------
USE sql_project;

SELECT *
FROM nashville;

-- Creating a copy of the original data
CREATE TABLE IF NOT EXISTS nashville_copy
SELECT *
FROM nashville;

-- Changing column name from FulllBath to FullBath
ALTER TABLE nashville
RENAME COLUMN FulllBath TO FullBath;

-- Changing '' into NULL values
UPDATE nashville
SET OwnerName = NULL
WHERE OwnerName = '';

UPDATE nashville
SET OwnerAddress = NULL
WHERE OwnerAddress = '';

UPDATE nashville
SET Acreage = NULL
WHERE Acreage = '';

UPDATE nashville
SET TaxDistrict = NULL
WHERE TaxDistrict = '';

UPDATE nashville
SET LandValue = NULL
WHERE LandValue = '';

UPDATE nashville
SET BuildingValue = NULL
WHERE BuildingValue = '';

UPDATE nashville
SET TotalValue = NULL
WHERE TotalValue = '';

UPDATE nashville
SET YearBuilt = NULL
WHERE YearBuilt = '';

UPDATE nashville
SET Bedrooms = NULL
WHERE Bedrooms = '';

UPDATE nashville
SET FullBath = NULL
WHERE FullBath = '';

UPDATE nashville
SET HalfBath = NULL
WHERE HalfBath = '';

SELECT *
FROM nashville;

-- Deleting duplicates
SELECT *
FROM (
		SELECT *,
			ROW_NUMBER() OVER(PARTITION BY ParcelID, LandUse, PropertyAddress, SaleDate, LegalReference ORDER BY ParcelID) AS row_num
		FROM nashville
		) AS dups
WHERE row_num > 1;

DELETE FROM nashville
WHERE UniqueID IN (
					SELECT UniqueID
					FROM (
							SELECT *,
								ROW_NUMBER() OVER(PARTITION BY ParcelID, LandUse, PropertyAddress, SaleDate, LegalReference ORDER BY ParcelID) AS row_num
							FROM nashville
							) AS dups
					WHERE row_num > 1
);

SELECT *
FROM nashville;

-- Standardizing SalePrice column
SELECT *
FROM nashville
WHERE SalePrice LIKE '%$%';

SELECT SalePrice, REGEXP_REPLACE(SalePrice, '[$,]', '')
FROM nashville
WHERE SalePrice LIKE '%$%';

UPDATE nashville
SET SalePrice = REGEXP_REPLACE(SalePrice, '[$,]', '')
WHERE SalePrice LIKE '%$%';

SELECT *
FROM nashville;

-- Standardizing SoldAsVacant column
SELECT DISTINCT SoldAsVacant
FROM nashville;

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'N' THEN 'No'
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END
FROM nashville;

UPDATE nashville
SET SoldAsVacant =
					CASE
						WHEN SoldAsVacant = 'N' THEN 'No'
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						ELSE SoldAsVacant
					END;

SELECT *
FROM nashville;

-- Splitting PropertyAddress column
ALTER TABLE nashville
RENAME COLUMN PropertyAddress TO PropertyAddressSplit;

ALTER TABLE nashville
ADD COLUMN PropertyAddress VARCHAR(30) AFTER PropertyAddressSplit;

ALTER TABLE nashville
ADD COLUMN PropertyCity VARCHAR(15) AFTER PropertyAddress;

SELECT PropertyAddressSplit,
	REGEXP_REPLACE(SUBSTRING_INDEX(PropertyAddressSplit, ',', 1), '  ', ' ')
FROM nashville;

UPDATE nashville
SET PropertyAddress = REGEXP_REPLACE(SUBSTRING_INDEX(PropertyAddressSplit, ',', 1), '  ', ' ');

UPDATE nashville
SET PropertyAddress = NULL
WHERE PropertyAddress = '';

SELECT PropertyAddressSplit,
	LTRIM(SUBSTRING_INDEX(PropertyAddressSplit, ',', -1))
FROM nashville;

UPDATE nashville
SET PropertyCity = LTRIM(SUBSTRING_INDEX(PropertyAddressSplit, ',', -1));

UPDATE nashville
SET PropertyCity = NULL
WHERE PropertyCity = '';

ALTER TABLE nashville
DROP COLUMN PropertyAddressSplit;

SELECT *
FROM nashville;

-- Splitting OwnerAddress column
ALTER TABLE nashville
RENAME COLUMN OwnerAddress TO OwnerAddressSplit;

ALTER TABLE nashville
ADD COLUMN OwnerAddress VARCHAR(30) AFTER OwnerAddressSplit;

ALTER TABLE nashville
ADD COLUMN OwnerCity VARCHAR(15) AFTER OwnerAddress;

ALTER TABLE nashville
ADD COLUMN OwnerState VARCHAR(5) AFTER OwnerCity;

SELECT OwnerAddressSplit,
	REGEXP_REPLACE(SUBSTRING_INDEX(OwnerAddressSplit, ',', 1), '  ', ' ')
FROM nashville;

UPDATE nashville
SET OwnerAddress = REGEXP_REPLACE(SUBSTRING_INDEX(OwnerAddressSplit, ',', 1), '  ', ' ');

SELECT OwnerAddressSplit,
	LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddressSplit, ',', 2), ',', -1))
FROM nashville;

UPDATE nashville
SET OwnerCity = LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddressSplit, ',', 2), ',', -1));

SELECT OwnerAddressSplit,
	LTRIM(SUBSTRING_INDEX(OwnerAddressSplit, ',', -1))
FROM nashville;

UPDATE nashville
SET OwnerState = LTRIM(SUBSTRING_INDEX(OwnerAddressSplit, ',', -1));

ALTER TABLE nashville
DROP COLUMN OwnerAddressSplit;

SELECT *
FROM nashville;

-- (manual) Fixing wrong PropertyAddress AND UNKNOWN PropertyCity
SELECT *
FROM nashville
WHERE PropertyCity = 'UNKNOWN';

#'46010'

SELECT *
FROM nashville
WHERE ParcelID = '093 06 1B 618.00';

SELECT PropertyAddress, PropertyCity
FROM nashville
WHERE ParcelID = '093 06 1B 618.00'
	AND PropertyCity <> 'UNKNOWN';

#'231 5TH AVE N' 'NASHVILLE'

UPDATE nashville
SET PropertyAddress = '231 5TH AVE N'
WHERE UniqueID = 46010;

UPDATE nashville
SET PropertyCity = 'NASHVILLE'
WHERE UniqueID = 46010;

SELECT *
FROM nashville;

-- Populating blank PropertyAddress and PropertyCity rows
SELECT *
FROM nashville
WHERE PropertyAddress IS NULL;

SELECT n1.UniqueID, n1.ParcelID, n2.PropertyAddress, n2.PropertyCity
FROM nashville n1
	JOIN nashville n2
		ON n1.ParcelID = n2.ParcelID
			AND n1.UniqueID <> n2.UniqueID
            AND n1.PropertyAddress IS NULL;

UPDATE nashville n1
	JOIN nashville n2
		ON n1.ParcelID = n2.ParcelID
			AND n1.UniqueID <> n2.UniqueID
            AND n1.PropertyAddress IS NULL
SET n1.PropertyAddress = n2.PropertyAddress
WHERE n1.ParcelID = n2.ParcelID;

UPDATE nashville n1
	JOIN nashville n2
		ON n1.ParcelID = n2.ParcelID
			AND n1.UniqueID <> n2.UniqueID
            AND n1.PropertyCity IS NULL
SET n1.PropertyCity = n2.PropertyCity
WHERE n1.ParcelID = n2.ParcelID;

SELECT *
FROM nashville;

-- Casting TotalValue, LandValue, BuildingValue, SalePrice AS DECIMALs
ALTER TABLE nashville
ADD COLUMN SalePriceFixed DECIMAL AFTER SalePrice;

UPDATE nashville
SET SalePriceFixed = CAST(SalePrice AS DECIMAL);

SELECT *
FROM nashville
WHERE SalePrice LIKE '%,%';

UPDATE nashville
SET SalePrice = REGEXP_REPLACE(SalePrice, '[,]', '');

ALTER TABLE nashville
DROP COLUMN SalePrice;

ALTER TABLE nashville
ADD COLUMN LandValueFixed DECIMAL AFTER LandValue;

UPDATE nashville
SET LandValueFixed = CAST(LandValue AS DECIMAL);

ALTER TABLE nashville
DROP COLUMN LandValue;

ALTER TABLE nashville
ADD COLUMN BuildingValueFixed DECIMAL AFTER BuildingValue;

UPDATE nashville
SET BuildingValueFixed = CAST(BuildingValue AS DECIMAL);

ALTER TABLE nashville
DROP COLUMN BuildingValue;

ALTER TABLE nashville
ADD COLUMN TotalValueFixed DECIMAL AFTER TotalValue;

UPDATE nashville
SET TotalValueFixed = CAST(TotalValue AS DECIMAL);

ALTER TABLE nashville
DROP COLUMN TotalValue;

SELECT *
FROM nashville;