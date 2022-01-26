Select *
From [Claver Projects].dbo.Nash

--- We are first going to have a uniform date format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From [Claver Projects].dbo.Nash

--- the code above is the final table result

Update Nash
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Nash
Add SaleDateConverted Date;

Update Nash
SET SaleDateConverted = CONVERT(Date,SaleDate)

--- Secondly, we are going to work with the Property Address data

Select *
From [Claver Projects].dbo.NASH
Where PropertyAddress is null

--- we can populate the address if we get a reference point

--- the parcelID provides us a reference for the address. Example No. 61&62

Select *
From [Claver Projects].dbo.Nash
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Claver Projects].dbo.Nash as a
JOIN [Claver Projects].dbo.Nash as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
---when that is run, we notice the different same parcelIds yet having an address is one and none in the other

update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Claver Projects].dbo.Nash as a
JOIN [Claver Projects].dbo.Nash as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

---here is the magic

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Claver Projects].dbo.Nash as a
JOIN [Claver Projects].dbo.Nash as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


--- we now go on to sort the address and spread it to different columns
Select PropertyAddress
From [Claver Projects].dbo.Nash
--- we notice here that the address is joined and tried to be separated by a delimeter.

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
From [Claver Projects].dbo.Nash
---we notice that there is a comma after the address so we reomve that

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [Claver Projects].dbo.Nash
--- that does the magic for the spilt property address. So we update the tabel.

ALTER TABLE Nash
Add PropertySplitAddress Nvarchar(255);

Update Nash
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Nash
Add PropertySplitCity Nvarchar(255);

Update Nash
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--- we review and notice two new columns added at the extreme right

Select *
From [Claver Projects].dbo.Nash


--- we do the same for the owner address. Problem?

Select OwnerAddress
From [Claver Projects].dbo.Nash
--- we notice that the address, state and city are in the same column. We separate those. But not using a substring.

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Claver Projects].dbo.Nash
--- we number (3,2,1 because parsname works backwards.) But lets go ahead and update our tables.

ALTER TABLE Nash
Add OwnerSplitAddress Nvarchar(255);

Update Nash
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nash
Add OwnerSplitCity Nvarchar(255);

Update Nash
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Nash
Add OwnerSplitState Nvarchar(255);

Update Nash
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--- our table now.
Select *
From [Claver Projects].dbo.Nash


-- we go over to the "sold as vacant" field and we change the 'Y' & 'N' to 'YES' & 'NO' respectively
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Claver Projects].dbo.Nash
Group by SoldAsVacant
order by 2

-- that gives us the summary of the entries as they are now. We are going to edit them using CASE

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From [Claver Projects].dbo.Nash


Update Nash
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
--- AND THE MAGIC IS DONE! NEXT?

---Like most tables, there are duplicates and we now want to remove those.
--- we use a CTE. we need to indentify the duplicate rows. we are going to use row number.
--- we partion the IDs by elements that are supposed to be unique, which is the ORDERID.

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Claver Projects].dbo.Nash
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

---MAGIC?
Select *
From [Claver Projects].dbo.Nash

---we split some columns and created new ones. Therefore, we have to delete the nolonger relevant columns

Select *
From [Claver Projects].dbo.Nash


ALTER TABLE Nash
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

---our data table now looks more user friendly

Select *
From [Claver Projects].dbo.Nash


---we stop here for now