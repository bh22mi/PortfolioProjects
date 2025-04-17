/* cleaning data in sql queries */

select * from nashvillehousing;

-- standardize dateformat

select SaleDate, STR_TO_DATE(SaleDate,'%M %D %Y') as formattedDate
from nashvillehousing;

update nashvillehousing
set SaleDate = STR_TO_DATE(SaleDate,'%M %D %Y') ;


-- populate property address

select *
from nashvillehousing
order by parcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing a 
join nashvillehousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID;
-- where a.PropertyAddress is null;

UPDATE nashvillehousing a JOIN nashvillehousing b
 ON a.ParcelID = b.ParcelID 
  AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
where a.PropertyAddress is null;


-- breaking out address into indivisual columns (address, city, state)
-- property address

select PropertyAddress
from nashvillehousing;

select substring(propertyAddress,1, INSTR(propertyAddress,',') - 1) as ADDRESS,
substring(propertyAddress, INSTR(propertyAddress,',') + 1, length(propertyAddress)) as CITY
from nashvillehousing;

ALTER TABLE nashvillehousing
ADD propertySplitAddress text, ADD propertyCity text;

UPDATE nashvillehousing
SET 
propertySplitAddress = substring(propertyAddress,1, INSTR(propertyAddress,',') - 1),
propertyCity = substring(propertyAddress, INSTR(propertyAddress,',') + 1);


-- owner address

select * from nashvillehousing;

select SUBSTRING_INDEX(ownerAddress, ',', 1) as street,
SUBSTRING_INDEX(SUBSTRING_INDEX(ownerAddress, ',', 2), ',', -1) as city,
SUBSTRING_INDEX(ownerAddress, ',', -1) as state
from nashvillehousing;

ALTER TABLE nashvillehousing
ADD ownerStreetAddress text, 
ADD ownerCity text,
ADD ownerState text;

UPDATE nashvillehousing
 SET ownerStreetAddress = SUBSTRING_INDEX(ownerAddress, ',', 1),
 ownerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(ownerAddress, ',', 2), ',', -1),
 ownerState = SUBSTRING_INDEX(ownerAddress, ',', -1);
 
 -- SET Y and N to yes and no
 
 select DISTINCT SoldAsVacant, count(SoldAsVacant)
 from nashvillehousing
 group by SoldAsVacant;
 
 select soldasvacant,
 case
  when soldasvacant = 'Y' then 'Yes'
  when soldasvacant = 'N' then 'No'
  else soldasvacant
 end
from nashvillehousing;

update nashvillehousing
set soldasvacant = case
  when soldasvacant = 'Y' then 'Yes'
  when soldasvacant = 'N' then 'No'
  else soldasvacant
end;
  
-- remove duplicates
WITH rowNumCTE AS(
select *,
 ROW_NUMBER() OVER (PARTITION BY parcelID, LandUse,PropertyAddress, SaleDate, SalePrice,LegalReference
 order by uniqueID) row_num
 from nashvillehousing
 order by parcelID
 )
 
 select * from rowNumCTE
 where row_num > 1
 order by propertyAddress;
 
 DELETE FROM nashvillehousing
WHERE UniqueID NOT IN (
  SELECT * FROM (
    SELECT MIN(UniqueID)
    FROM nashvillehousing
    GROUP BY ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference
  ) AS keep_ids
);


-- delete unused columns

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

 
  
  

