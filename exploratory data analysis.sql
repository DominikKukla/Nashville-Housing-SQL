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
# The majority of properties are in Nashville (71% of all listed).
# Franklin and Bellevue both have only one property listed.

-- Average property sale price between cities
SELECT PropertyCity,
	ROUND(AVG(SalePriceFixed)) AS avgSalePrice,
    ROUND((SELECT AVG(SalePriceFixed) FROM nashville)) AS avgOverall
FROM nashville
GROUP BY PropertyCity
ORDER BY 2 DESC;
# The average property sale price is highest in Nashville (366615), which is the only
# city with an average sale price exceeding the overall average (327512).
# Bellevue is an outlier due to having only one property listed and
# being more than tenfold cheaper (25000) compared to the overall average (327512).

-- Average property year of build between cities
SELECT PropertyCity,
	ROUND(AVG(YearBuilt)) AS avgYearBuilt
FROM nashville
WHERE YearBuilt IS NOT NULL
GROUP BY PropertyCity
ORDER BY 2 DESC;
# The averagely newest properties are located in Antioch (1983),
# while the averagely oldest properties are located in Old Hickory (1958).

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
# The comparison between YearBuilt and average SalePrice shows no signs of linear correlation.
# Properties built between 1908 and 1916, on average, are sold at a higher price than the overall average.
# Properties built between 1942 and 1992, on average, are sold cheaper that overall average.
# Properties built between 2002 and onwards, on average, are sold cheaper that overall average.

-- Count of properties per LandUse
SELECT LandUse,
	COUNT(LandUse) AS PropertyCount,
    ROUND(COUNT(LandUse)/(SELECT COUNT(*) FROM nashville) * 100, 2) AS PorpertyCountPercentage
FROM nashville
GROUP BY LandUse
ORDER BY 2 DESC;
# The vast majority of properties are intended for residential use.
# The broadest usage is for single-family housing (60.5%),
# followed by for residential condominiums (25.4%).

-- Correlation between Acreage and LandValue
SELECT Acreage,
	LandValueFixed
FROM nashville
WHERE Acreage IS NOT NULL
ORDER BY Acreage;

WITH AcreageCTE AS (
	SELECT Acreage,
		LandValueFixed,
		ROW_NUMBER() OVER(ORDER BY Acreage) AS row_num
	FROM nashville
	WHERE Acreage IS NOT NULL
	ORDER BY Acreage
)
SELECT *
FROM AcreageCTE
WHERE row_num = ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.1)
	OR row_num = ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.2)
    OR row_num = ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.3)
    OR row_num = ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.4)
    OR row_num = ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.5)
    OR row_num = ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.6)
    OR row_num = ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.7)
    OR row_num = ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.8)
    OR row_num = ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.9);

WITH AcreageCTE AS (
	SELECT Acreage,
		LandValueFixed,
		ROW_NUMBER() OVER(ORDER BY Acreage) AS row_num
	FROM nashville
	WHERE Acreage IS NOT NULL
	ORDER BY Acreage
)
SELECT
    CASE
		WHEN row_num < ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.1) THEN '[D0,D1]'
        WHEN row_num BETWEEN ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.1) AND ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.2) THEN '[D1,D2]'
        WHEN row_num BETWEEN ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.2) AND ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.3) THEN '[D2,D3]'
		WHEN row_num BETWEEN ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.3) AND ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.4) THEN '[D3,D4]'
        WHEN row_num BETWEEN ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.4) AND ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.5) THEN '[D4,D5]'
        WHEN row_num BETWEEN ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.5) AND ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.6) THEN '[D5,D6]'
        WHEN row_num BETWEEN ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.6) AND ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.7) THEN '[D6,D7]'
        WHEN row_num BETWEEN ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.7) AND ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.8) THEN '[D7,D8]'
        WHEN row_num BETWEEN ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.8) AND ROUND((SELECT COUNT(*) FROM AcreageCTE)*0.9) THEN '[D8,D9]'
        ELSE '[D9,D10]'
	END AS Ranges,
	ROUND(AVG(Acreage), 2) AS avgRangeAcreage,
    ROUND(AVG(LandValueFixed)) AS avgLandValue,
    (SELECT ROUND(AVG(LandValueFixed)) FROM AcreageCTE) AS avgOverall
FROM AcreageCTE
GROUP BY Ranges;

# *Notice*
# My curiosity decided to stroll me through the statistics domain, which is not so familiar to me as of now.
# I have yet to go on my journey to university to soak up the ropes of statistics.
# Thus, I sincerely apologise should any of the conclusions below appear to be incorrect or misleading.

# *Explanation*
# [D0,D1] is the data range between the 0th decile and the 1st decile of values ordered by rising Acreage;
# [D1,D2] is the data range between the 1th decile and the 2st decile of values ordered by rising Acreage; and so on.
# ----------------------------------------------------------------------------------------
# LandValue seem to be somewhat correlated with Acreage values, but the correlation is not linear.
# All bottom seven ranges of Acreage have an average LandValue lower than the overall average.
# All top three ranges of Acreage have an average LandValue higher than the overall average.
# Average LandValue in the fisrt Acreage range ([D0,D1]) have visibly the lowest average LandValue.
# Average LandValue in ranges from [D1,D2] to [D6,D7] does not seem to grow alongside average Acreage.
# Average LandValue in the top 3 Acreage ranges show signs of a positive correlation between average Acreage.