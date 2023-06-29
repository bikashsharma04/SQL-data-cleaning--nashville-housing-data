use databasename.
select * from Nashville_housing_data


-----/// data cleaning in sql////-----



-- Standardize Date Format
select SaleDate, convert(date,SaleDate) from Nashville_housing_data

alter table Nashville_housing_data
add SaleDate2 date;
update Nashville_housing_data
set SaleDate2 = convert(date,SaleDate)

select * from Nashville_housing_data
-------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
select * from Nashville_housing_data
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashville_housing_data a
join Nashville_housing_data b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashville_housing_data a
join Nashville_housing_data b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-----------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

select
substring (PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as Address,
substring (PropertyAddress , CHARINDEX (',',PropertyAddress)+1 , len(PropertyAddress)) as Address
from Nashville_housing_data

alter table Nashville_housing_data
add PropertySplitAddress Nvarchar(255);

update Nashville_housing_data
set PropertySplitAddress = substring (PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) 

alter table Nashville_housing_data
add PropertySplitCity Nvarchar (255);

update Nashville_housing_data
set PropertySplitCity = substring (PropertyAddress , CHARINDEX (',',PropertyAddress)+1 , len(PropertyAddress))

select * from Nashville_housing_data
----owners address
select OwnerAddress from Nashville_housing_data

select 
PARSENAME(REPLACE (OwnerAddress,',','.'),3),
PARSENAME(REPLACE (OwnerAddress,',','.'),2),
PARSENAME(REPLACE (OwnerAddress,',','.'),1)
from Nashville_housing_data

alter table Nashville_housing_data
add OwnersSplitAdress Nvarchar (255);

update Nashville_housing_data
set OwnersSplitAdress = PARSENAME(REPLACE (OwnerAddress,',','.'),3)

alter table Nashville_housing_data
add OwnersSplitCity Nvarchar (255);

update Nashville_housing_data
set OwnersSplitCity = PARSENAME(REPLACE (OwnerAddress,',','.'),2)

alter table Nashville_housing_data
add OwnersSplitState Nvarchar (255);

update Nashville_housing_data
set OwnersSplitState = PARSENAME(REPLACE (OwnerAddress,',','.'),1)

select * from Nashville_housing_data
---------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
select DISTINCT(SoldAsVacant),count(SoldAsVacant) 
from Nashville_housing_data
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 end
from Nashville_housing_data

Update Nashville_housing_data
set SoldAsVacant =case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 end
--------------------------------------------------------------------------------------------------
-- Remove Duplicates

--always delete duplicates using temp table never delete orignal data

with rownumCTE as (
select *, 
ROW_NUMBER () over(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 Saledate,
			 LegalReference
			 order by
			  UniqueID
			  ) row_num
from Nashville_housing_data

)
select *
from rownumCTE
where row_num > 1
order by PropertyAddress

------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
--always delete stuff on temp table never delete orignal data

select *
from Nashville_housing_data

 alter table Nashville_housing_data
 drop column SaleDate, PropertyAddress, TaxDistrict, OwnerAddress
