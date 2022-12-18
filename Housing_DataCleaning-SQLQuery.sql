/*
Cleaning Data in SQL Queries
*/

select * from dbo.nashvillehousing

-- Standardize Date Format
 
 select cast(saledate as  date) from dbo.nashvillehousing

 Alter table dbo.nashvillehousing
 add Sale_date date

 update dbo.nashvillehousing
 set Sale_date = cast(saledate as  date)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
Select a.ParcelID, a.[UniqueID ], a.PropertyAddress, b.PropertyAddress, b.ParcelID, b. [UniqueID ], ISNULL(a.PropertyAddress, b.PropertyAddress)  from
dbo.nashvillehousing a
join dbo.nashvillehousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
Set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from
dbo.nashvillehousing a
join dbo.nashvillehousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select
PARSENAME(Replace(Propertyaddress, ',', '.'),1) Property_City,
PARSENAME(Replace(Propertyaddress, ',', '.'),2) Property_Address,
PARSENAME(Replace(OwnerAddress, ',', '.'),1) OwnerAddress_State,
PARSENAME(Replace(OwnerAddress, ',', '.'),2) OwnerAddress_City,
PARSENAME(Replace(OwnerAddress, ',', '.'),3) Owner_Address

from dbo.nashvillehousing

Alter table dbo.nashvillehousing
Add Property_City Nvarchar(255), Property_Address Nvarchar(255), OwnerAddress_State Nvarchar(255), OwnerAddress_City Nvarchar(255), Owner_Address Nvarchar(255)

update dbo.nashvillehousing
set
Property_City = PARSENAME(Replace(Propertyaddress, ',', '.'),1), 
Property_Address = PARSENAME(Replace(Propertyaddress, ',', '.'),2),
OwnerAddress_State = PARSENAME(Replace(OwnerAddress, ',', '.'),1),
OwnerAddress_City = PARSENAME(Replace(OwnerAddress, ',', '.'),2),
Owner_Address = PARSENAME(Replace(OwnerAddress, ',', '.'),3)


select * from dbo.nashvillehousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldasVacant), count(SoldAsVacant)
from dbo.nashvillehousing
group by SoldAsVacant 
order by count(SoldAsVacant) desc

select soldasvacant, 
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else
SoldAsVacant
end
from dbo.nashvillehousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates

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

From dbo.nashvillehousing
--order by ParcelID
)
--Delete
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress




Select *
From dbo.nashvillehousing

-- Delete Unused Columns

Alter Table dbo.nashvillehousing
Drop Column PropertyAddress, Saledate, OwnerAddress, TaxDistrict
