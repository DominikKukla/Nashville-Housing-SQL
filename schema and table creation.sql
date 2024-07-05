-- Prior to importing, the format of the SaleDate column was changed
-- in Excel in order not to omit a plethora of rows due to the wrong date format.


-- Creating the schema and the table.

CREATE SCHEMA IF NOT EXISTS sql_project;
USE sql_project;

DROP TABLE IF EXISTS nashville;
CREATE TABLE nashville (
	UniqueID INT PRIMARY KEY NOT NULL,
    ParcelID VARCHAR(30) NOT NULL,
    LandUse VARCHAR(50) NOT NULL,
    PropertyAddress VARCHAR(100),
    SaleDate DATE NOT NULL,
    SalePrice VARCHAR(20),
    LegalReference VARCHAR(20),
    SoldAsVacant VARCHAR(10),
    OwnerName VARCHAR(100),
    OwnerAddress VARCHAR(100),
    Acreage VARCHAR(10),
	TaxDistrict VARCHAR(50),
    LandValue VARCHAR(10),
    BuildingValue VARCHAR(10),
	TotalValue VARCHAR(10),
    YearBuilt VARCHAR(10),
    Bedrooms VARCHAR(10),
    FulllBath VARCHAR(10),
    HalfBath VARCHAR(10)
);

-- Importing the data via the 'Table Data Import Wizard'