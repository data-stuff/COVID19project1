/*
cleaning data
*/

--- see data
select *
from NashvilleHousing

--- standardize date
/*
select SaleDate, convert (date, SaleDate)
from NashvilleHousing

update NashvilleHousing ---one way
set SaleDate = convert (date, SaleDate)
*/ 

alter table NashvilleHousing
add DateSold date;

update NashvilleHousing --- or another
set DateSold = SaleDate;

alter table NashvilleHousing
drop column SaleDate;

--- fill the missing property adress
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull  (a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull  (a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

/*
confirmation
*/
---select a.ParcelID, a.PropertyAddress
---from NashvilleHousing as a
---where a.PropertyAddress is null 

--- Breaking Property Address into individual collumns (Adress, City)
select PropertyAddress
from NashvilleHousing
--- where PropertyAddress is null
order by ParcelID

select 
substring ( PropertyAddress, 1, charindex (',', PropertyAddress) -1) as Address
, substring (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, len (PropertyAddress)) as City
from NashvilleHousing

alter table NashvilleHousing
add PropAddress nvarchar (255);

update NashvilleHousing 
set PropAddress = substring ( PropertyAddress, 1, charindex (',', PropertyAddress) -1)
 
alter table NashvilleHousing
add City nvarchar (255);

update NashvilleHousing 
set City = substring (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, len (PropertyAddress))

alter table NashvilleHousing
drop column PropertyAddress;

select *
from NashvilleHousing

--- Breaking Property Address into individual collumns (Adress, City, State)
select OwnerAddress
from NashvilleHousing

select
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

alter table NashvilleHousing
add Owner_Address nvarchar (255);

update NashvilleHousing 
set Owner_Address = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add Owner_City nvarchar (255);

update NashvilleHousing 
set Owner_City = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add Owner_State nvarchar (255);

update NashvilleHousing 
set Owner_State = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)

alter table NashvilleHousing
drop column OwnerAddress;

select *
from NashvilleHousing

--- Chanhe 'Y' and 'N' to a uniform 'Yes' and 'No' on SoldAsVacant
select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 1, 2

select SoldAsVacant
	,case 
	when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else SoldAsVacant
	end as Uniform 
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case 
	when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else SoldAsVacant
	end

--- Remove duplicates with CTES 
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropAddress,
				 SalePrice,
				 DateSold,
				 LegalReference
				 ORDER BY
					UniqueID
					) Row_Num

From NashvilleHousing
)

delete  --- Use SELECT * function first to confirm
from RowNumCTE
where Row_Num > 1
---order by LegalReference

--- remove unnecessary columns
alter table NashvilleHousing
drop column TaxDistrict;

--- CleanData
select UniqueID, ParcelID, DateSold, PropAddress, City, LandUse, Acreage, SalePrice, SoldAsVacant, LegalReference, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath, OwnerName, Owner_Address, Owner_City, Owner_State
from NashvilleHousing
