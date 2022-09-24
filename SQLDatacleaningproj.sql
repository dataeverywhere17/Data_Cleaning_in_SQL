select *
From [Portfollio Project]..NashvilleHousing

--Standardize Date format

Select SaleDate, CONVERT (Date,SaleDate)
From [Portfollio Project]..NashvilleHousing-- This is a preffered approach to convert the dates

Update [Portfollio Project]..NashvilleHousing
SET SaleDATE = CONVERT(Date,SaleDate)

ALTER Table [Portfollio Project]..NashvilleHousing -- This is the another way to do the same
ADD SaleDateConverted Date;

Update [Portfollio Project]..NashvilleHousing
SET SaleDATEConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT (Date,SaleDate)
From [Portfollio Project]..NashvilleHousing

--Populate Property address data

Select *
from [Portfollio Project]..NashvilleHousing
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyADdress,b.PropertyAddress)
from [Portfollio Project]..NashvilleHousing a
JOIN [Portfollio Project]..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]-- joining the table to itself in order to populate the property address. as if the parcel if is same that means the property address is also same adn the unique id is mentioned so as to distinguish it
where a.PropertyAddress is null

Update a -- when we use join we should use the alias
SET PropertyAddress=ISNULL(a.PropertyADdress,b.PropertyAddress)
from [Portfollio Project]..NashvilleHousing a
JOIN [Portfollio Project]..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null



--Breaking address into individual columns.
Select *
from [Portfollio Project]..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address-- we use -1 to remove the comma--
,SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) As Address
from [Portfollio Project]..NashvilleHousing

ALTER Table [Portfollio Project]..NashvilleHousing
ADD PropertysplitAddress Nvarchar(255)

Update [Portfollio Project]..NashvilleHousing
SET PropertysplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER Table [Portfollio Project]..NashvilleHousing
ADD PropertysplitCity Nvarchar(255)

Update [Portfollio Project]..NashvilleHousing
SET PropertysplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select *
From [Portfollio Project]..NashvilleHousing

Select OwnerAddress
From [Portfollio Project]..NashvilleHousing
--the better appraoch on sperating contents like this is by PARSENAME--
SELECT
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From [Portfollio Project]..NashvilleHousing

ALTER Table [Portfollio Project]..NashvilleHousing
ADD OwnersplitAddress Nvarchar(255)

Update [Portfollio Project]..NashvilleHousing
SET OwnersplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


ALTER Table [Portfollio Project]..NashvilleHousing
ADD OwnersplitCity Nvarchar(255)

Update [Portfollio Project]..NashvilleHousing
SET OwnersplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALTER Table [Portfollio Project]..NashvilleHousing
ADD OwnersplitState Nvarchar(255)

Update [Portfollio Project]..NashvilleHousing
SET OwnersplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From [Portfollio Project]..NashvilleHousing

---Changing Y and N to Yes and NO in Sold as vacant column
Select Distinct(Soldasvacant),Count(SoldasVacant)
from [Portfollio Project]..NashvilleHousing
group by Soldasvacant
order by 2

Select Soldasvacant,
CASE when SoldAsVacant ='Y' THEN 'Yes'
	when SoldasVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END
from [Portfollio Project]..NashvilleHousing

Update [Portfollio Project]..NashvilleHousing
SET Soldasvacant= CASE when SoldAsVacant ='Y' THEN 'Yes'
	when SoldasVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END

	--Remove Duplicates-

With RownumCTE as (
Select *,
Row_Number() OVER(
Partition BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				) Row_num
from [Portfollio Project]..NashvilleHousing
)
Select *
from RownumCTE
where row_num>1
Order by PropertyAddress--To check the total number of duplicates present

With RownumCTE as (
Select *,
Row_Number() OVER(
Partition BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				) Row_num
from [Portfollio Project]..NashvilleHousing
)
Delete
from RownumCTE
where row_num>1-- This step deletes all of the duplicates

-- Delete Unused Columns

Select *
from [Portfollio Project]..NashvilleHousing
Alter Table [Portfollio Project]..NashvilleHousing
DROP Column OwnerAddress, taxDistrict, PropertyAddress, SaleDate