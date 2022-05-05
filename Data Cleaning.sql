SELECT *
FROM Portfolio_Project.nashvillehousing;

-- Standardize Date Format


SELECT saleDate, str_to_date(SaleDate, '%M%d,%Y')
FROM Portfolio_Project.nashvillehousing;


UPDATE Portfolio_Project.nashvillehousing
SET SaleDate = str_to_date(SaleDate, '%M%d,%Y');


-- Populate Property Address data

SELECT *
FROM Portfolio_Project.nashvillehousing
-- Where PropertyAddress is null
ORDER BY ParcelID;



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM Portfolio_Project.nashvillehousing a
JOIN Portfolio_Project.nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID  <> b.UniqueID;



UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project.nashvillehousing a
JOIN Portfolio_Project.nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM Portfolio_Project.nashvillehousing;
-- WHERE PropertyAddress IS NULL
-- ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, locate(',', PropertyAddress) + 1 , LENGTH(PropertyAddress)) as Address
FROM Portfolio_Project.nashvillehousing;


ALTER TABLE Portfolio_Project.nashvillehousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE Portfolio_Project.nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) -1 );


ALTER TABLE Portfolio_Project.nashvillehousing
ADD PropertySplitCity Nvarchar(255);

UPDATE Portfolio_Project.nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, locate(',', PropertyAddress) + 1 , LENGTH(PropertyAddress));




SELECT *
FROM Portfolio_Project.nashvillehousing;


SELECT OwnerAddress
FROM Portfolio_Project.nashvillehousing;


SELECT
SUBSTRING(OwnerAddress, 1, locate(',', OwnerAddress) -1 )
FROM Portfolio_Project.nashvillehousing;

SELECT
SUBSTRING(OwnerAddress, locate(',', OwnerAddress) + 1 , LENGTH(OwnerAddress)) as Adr
FROM Portfolio_Project.nashvillehousing;


SELECT
SUBSTR(OwnerAddress,-2)
FROM Portfolio_Project.nashvillehousing;


ALTER TABLE Portfolio_Project.nashvillehousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Portfolio_Project.nashvillehousing
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, locate(',', OwnerAddress) -1 );


ALTER TABLE Portfolio_Project.nashvillehousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE Portfolio_Project.nashvillehousing
SET OwnerSplitCity = SUBSTRING(OwnerAddress, locate(',', OwnerAddress) + 1 , LENGTH(OwnerAddress));



ALTER TABLE Portfolio_Project.nashvillehousing
ADD OwnerSplitState Nvarchar(255);

UPDATE Portfolio_Project.nashvillehousing
SET OwnerSplitState = SUBSTR(OwnerAddress,-2);


SELECT 
SUBSTRING(OwnerSplitCity, 1, locate(',', OwnerSplitCity) -1 )
FROM Portfolio_Project.nashvillehousing;

UPDATE Portfolio_Project.nashvillehousing
SET OwnerSplitCity = SUBSTRING(OwnerSplitCity, 1, locate(',', OwnerSplitCity) -1 );

SELECT *
FROM Portfolio_Project.nashvillehousing;

-- Change Y and N fields in Sold as Vacant Column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project.nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM Portfolio_Project.nashvillehousing;


UPDATE Portfolio_Project.nashvillehousing
SET SoldAsVacant =
CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				   ORDER BY
					UniqueID
					) row_num

FROM Portfolio_Project.nashvillehousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;
-- ORDER BY PropertyAddress

-- Delete Unused Columns

SELECT *
FROM Portfolio_Project.nashvillehousing;

ALTER TABLE Portfolio_Project.nashvillehousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;
