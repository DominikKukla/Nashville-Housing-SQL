-- Exploratory Data Analysis
-- --------------------------

USE sql_project;

SELECT *
FROM nashville;

-- Distribution of properties between cities
SELECT PropertyCity,
	COUNT(PropertyCity) AS PorpertyCount,
    ROUND(COUNT(PropertyCity)/(SELECT COUNT(*) FROM nashville) * 100, 2) AS PorpertyCountPercentage
FROM nashville
GROUP BY PropertyCity
ORDER BY 2 DESC;
# Majority of properties are in Nashville (71% of all listed)
# Franklin and Bellevue both have only one property listed

-- Average property sale price between cities
SELECT PropertyCity,
	ROUND(AVG(SalePriceFixed)) AS avgSalePrice,
    ROUND((SELECT AVG(SalePriceFixed) FROM nashville)) AS avgOverall
FROM nashville
GROUP BY PropertyCity
ORDER BY 2 DESC;
# Average property sale price is highest in Nashville (366615), which is the only
# city with average sale price exceeding overall average (327512).
# Bellevue is an outlier due to having only one property listed and
# it being more than tenfold cheaper (25000) compared to overall average (327512).

-- Average property year of build between cities
SELECT PropertyCity,
	ROUND(AVG(YearBuilt)) AS avgYearBuilt
FROM nashville
WHERE YearBuilt IS NOT NULL
GROUP BY PropertyCity
ORDER BY 2 DESC;
# The averagely newest properties are located in Antioch (1983)
# while averagely oldest properties are located in Old Hickory (1958).

-- Correlation between YearBuilt and SalePrice
SELECT YearBuilt,
	ROUND(AVG(SalePriceFixed)) AS avgSalePrice
FROM nashville
WHERE YearBuilt IS NOT NULL
GROUP BY YearBuilt
ORDER BY 1;

WITH YearBuiltCTE AS (
	SELECT YearBuilt,
		ROUND(AVG(SalePriceFixed)) AS avgSalePrice,
		ROUND((SELECT AVG(SalePriceFixed) FROM nashville)) AS avgOverall
	FROM nashville
	WHERE YearBuilt >= 1899
	GROUP BY YearBuilt
	ORDER BY 1
)
SELECT YearBuilt,
	avgSalePrice,
    CASE
		WHEN avgSalePrice > avgOverall THEN 'Above AVG'
        ELSE 'Below AVG'
	END AS Status
FROM YearBuiltCTE;
# Data before 1899 is inconsistent and won't be looked at.
# Comparison between YearBuilt and average SalePrice shows no signs of linear correlation.
# Properties built between 1908 and 1916 on average are sold pricier that overall average.
# Properties built between 1942 and 1992 on average are sold cheaper that overall average.
# Properties built between 2002 and onwards on average are sold cheaper that overall average.

-- Count of properties per LandUse
SELECT LandUse,
	COUNT(LandUse) AS PropertyCount,
    ROUND(COUNT(LandUse)/(SELECT COUNT(*) FROM nashville) * 100, 2) AS PorpertyCountPercentage
FROM nashville
GROUP BY LandUse
ORDER BY 2 DESC;
# The vast majority of properties are intended for residential use.
# The broadest usage is for single family housing (60.5%),
# then for residential condominiums (25.4%).