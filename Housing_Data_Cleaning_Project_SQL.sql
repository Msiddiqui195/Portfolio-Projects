/*

Cleaning Data in SQL Queries

*/

Select *
From Portfolio_Project2.dbo.Nasville_Housing


--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

Select saleDateConverted, CONVERT(Date,SaleDate)
From Portfolio_Project2.dbo.Nasville_Housing

Update Nasville_Housing
Set SaleDate = CONVERT(date,SaleDate)

Alter Table Nasville_Housing
Add SaleDateConverted Date;

Update Nasville_Housing
Set SaleDateConverted = CONVERT(date,SaleDate)


--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address

Select *
From Portfolio_Project2.dbo.Nasville_Housing
Where PropertyAddress is NULL

Select *
From Portfolio_Project2.dbo.Nasville_Housing
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Project2.dbo.Nasville_Housing a
Join Portfolio_Project2.dbo.Nasville_Housing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is Null

Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Project2.dbo.Nasville_Housing a
Join Portfolio_Project2.dbo.Nasville_Housing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null



--------------------------------------------------------------------------------------------------------------------------
--Breaking Out Property Address Into Individual Columns (Address,City,State)

Select PropertyAddress
From Portfolio_Project2.dbo.Nasville_Housing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
From Portfolio_Project2.dbo.Nasville_Housing

Alter Table Nasville_Housing
Add Property_Split_Address Nvarchar(255);

Update Nasville_Housing
Set Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter Table Nasville_Housing
Add Property_Split_City Nvarchar(255);

Update Nasville_Housing
Set Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select*
From Portfolio_Project2.dbo.Nasville_Housing



--------------------------------------------------------------------------------------------------------------------------
--Breaking Out Owner Address Into Individual Columns (Address,City,State)

Select OwnerAddress
From Portfolio_Project2.dbo.Nasville_Housing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Portfolio_Project2.dbo.Nasville_Housing

Alter Table Nasville_Housing
Add Owner_Split_Address Nvarchar(255);

Update Nasville_Housing
Set Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter Table Nasville_Housing
Add Owner_Split_City Nvarchar(255);

Update Nasville_Housing
Set Owner_Split_City = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter Table Nasville_Housing
Add Owner_Split_State Nvarchar(255);

Update Nasville_Housing
Set Owner_Split_State = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From Portfolio_Project2.dbo.Nasville_Housing



--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project2.dbo.Nasville_Housing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From Portfolio_Project2.dbo.Nasville_Housing
Order by 1

Update Nasville_Housing
Set SoldAsVacant = 
	CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End



--------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) Row_num

From Portfolio_Project2.dbo.Nasville_Housing
--Order by ParcelID
)

Select *
From RowNumCTE
Where Row_num > 1
Order by PropertyAddress





WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) Row_num

From Portfolio_Project2.dbo.Nasville_Housing
--Order by ParcelID
)

Delete
From RowNumCTE
Where Row_num > 1



--------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
From Portfolio_Project2.dbo.Nasville_Housing

Alter Table Portfolio_Project2.dbo.Nasville_Housing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Portfolio_Project2.dbo.Nasville_Housing
Drop Column SaleDate