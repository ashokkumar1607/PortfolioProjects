---Data Transformation on Housing DataSet


----Standardize date format

update housingdata
set SaleDate=convert(date,SaleDate)

alter table housingdata
add SaleDateAltered date

update housingdata
set SaleDateAltered = convert(date,SaleDate) 

select * from dbo.housingdata


----Populate Property Address Data
select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress
from housingdata a 
join housingdata b 
on a.parcelid=b.parcelid
where b.propertyaddress is null or a.propertyaddress is null

update a
set propertyaddress=isnull(a.propertyaddress,b.propertyaddress)
from housingdata a
join housingdata b
on a.parcelid=b.parcelid and
a.uniqueid <> b.uniqueid



--Transforming Address to Individual Columns(Address, City, State)

	--Property Address to Individual Columns(Address,City)
select * from housingdata

select propertyaddress,substring(propertyaddress,1,charindex(',',propertyaddress)-1),
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))
from housingdata

alter table housingdata
add PropertyAddressAltered nvarchar(255), PropertyCityAltered nvarchar(50)

update housingdata
set PropertyAddressAltered=substring(propertyaddress,1,charindex(',',propertyaddress)-1),
PropertyCityAltered=substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))


	--alternate method
alter table housingdata
add PropertyAddressAltered nvarchar(255), PropertyCityAltered nvarchar(50)

update housingdata
set PropertyAddressAltered=parsename(replace(propertyaddress,',','.'),2),
PropertyCityAltered=parsename(replace(propertyaddress,',','.'),1)


	--Owner Address to Individual Columns(Address,City,State)

select * from housingdata

select parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)
from housingdata

alter table housingdata
add AlteredOwnerAddress nvarchar(255),AlteredOwnerCity nvarchar(50),AlteredOwnerState nvarchar(25)

update housingdata
set AlteredOwnerAddress=parsename(replace(owneraddress,',','.'),3),
AlteredOwnerCity=parsename(replace(owneraddress,',','.'),2),
AlteredOwnerState=parsename(replace(owneraddress,',','.'),1)



--Changing Y and N in 'Sold as Vacant' to Yes and No respectively

update housingdata
set soldasvacant=case when soldasvacant='Y' then 'Yes'
				  when soldasvacant='N' then 'No'
				  else soldasvacant
				  end

select soldasvacant, count(soldasvacant)
from housingdata
group by soldasvacant


----Remove Duplicate

with rownumcte as(
select *,ROW_NUMBER() over (partition by parcelid,propertyaddress,saleprice,saledate,legalreference order by uniqueid)row_num from housingdata
)
delete from rownumcte
where row_num>1


---delete unused columns

alter table housingdata
drop column owneraddress,taxdistrict,propertyaddress,saledate

select * from housingdata