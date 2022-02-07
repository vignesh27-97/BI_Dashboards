--1. Total Sales via Invoice
select sum("Total") as "Total Sales" from "Invoice";


--2. Total Sales via InvoiceLine
select sum("UnitPrice") as "Total Sales" from "InvoiceLine"; 


--3. Total tracks sold
select count(il."TrackId") 
from "Track" t 
join "InvoiceLine" il on t."TrackId" = il."TrackId";

--4. Total Sales by customers country
select c."Country", sum(i."Total") as "Total Sales" 
from "Invoice" i 
join "Customer" c on c."CustomerId" = i."CustomerId" 
group by c."Country"
order by "Total Sales" desc;

--5. Total Sales by customers geography
select c."Country", c."State", c."City", sum(i."Total") as "Total Sales"
from "Invoice" i 
join "Customer" c on c."CustomerId" = i."CustomerId" 
group by c."Country", c."State", c."City"
order by c."Country";

--6. Total sales by customer  
select c."LastName"||','||c."FirstName" as "Customer Name" , sum(i."Total") as "Total Sales" 
from "Customer" c 
join "Invoice" i on i."CustomerId" = c."CustomerId" 
group by "Customer Name"
order by "Total Sales" desc;


--7. Total Sales by company

select c."Company", sum(i."Total") as "Total Sales"
from "Customer" c 
join "Invoice" i on c."CustomerId" = i."CustomerId"
group by c."Company"
order by "Total Sales" desc;


--8. Total Sales by artist  
  
select y."Name" as "Artist", sum("Total") as "Total Sales"
from  
	(select x."Name", x."UnitPrice" * x."Quantity" as "Total"
	from  
			(select ar."Name", il."UnitPrice",il."Quantity" 
			from "Artist" ar
			join "Album" al on ar."ArtistId" = al."ArtistId" 
			join "Track" t on al."AlbumId" = t."AlbumId" 
			join "InvoiceLine" il on t."TrackId" = il."TrackId" 
			order by ar."Name" desc ) as x ) as y
group by y."Name"
order by "Total Sales" desc;


-- Top 20 Artists
select y."Name" as "Artist", sum("Total") as "Total Sales"
from  
	(select x."Name", x."UnitPrice" * x."Quantity" as "Total"
	from  
			(select ar."Name", il."UnitPrice",il."Quantity" 
			from "Artist" ar
			join "Album" al on ar."ArtistId" = al."ArtistId" 
			join "Track" t on al."AlbumId" = t."AlbumId" 
			join "InvoiceLine" il on t."TrackId" = il."TrackId" 
			order by ar."Name" desc ) as x ) as y
group by y."Name"
order by "Total Sales" desc
limit 20;
  
--9. Total Sales by Album

select y."Title" as "Album", sum("Total") as "Total Sales"
from  
	(select x."Title", x."UnitPrice" * x."Quantity" as "Total"
	from  
			(select al."Title", il."UnitPrice",il."Quantity" 
			from "Artist" ar
			join "Album" al on ar."ArtistId" = al."ArtistId" 
			join "Track" t on al."AlbumId" = t."AlbumId" 
			join "InvoiceLine" il on t."TrackId" = il."TrackId" 
			order by al."Title" desc ) as x ) as y
group by y."Title"
order by "Total Sales" desc;


--10. Total Sales by Sales Person (Employee)

select e."EmployeeId", e."FirstName", e."LastName", sum(i."Total") as "Total Sales"
from "Employee" e 
join "Customer" c  on c."SupportRepId" = e."EmployeeId" 
join "Invoice" i on i."CustomerId" = c."CustomerId" 
where e."Title" = 'Sales Support Agent'
group by e."EmployeeId", e."FirstName", e."LastName" 
order by "Total Sales" desc;


--11. Total Sales by Media type 

select x."Media Type", x."Total Quantity" * 0.99 as "Total Sales" 
from
(
select mt."Name" as "Media Type", sum(il."Quantity") as "Total Quantity"
from "MediaType" mt 
join "Track" t on t."MediaTypeId" = mt."MediaTypeId" 
join "InvoiceLine" il on il."TrackId" = t."TrackId"
group by mt."Name"
order by "Total Quantity" desc) as x;


--12. Total Sales by Genre   

select x."Genre", x."Total Quantity" * 0.99 as "Total Sales"
from
(
select g."Name" as "Genre", sum(il."Quantity") as "Total Quantity"
from "Genre" g
join "Track" t on t."GenreId" = g."GenreId" 
join "InvoiceLine" il on il."TrackId" = t."TrackId" 
group by g."Name"
order by "Total Quantity" desc) as x;


--13. Total Sales by year 

select extract(year from "InvoiceDate") as "Year", sum("Total") as "Total Sales"
from "Invoice" i
group by "Year"
order by "Year";

--14. Total Sales by Year-Month

select extract(year from "InvoiceDate") as "Year", to_char("InvoiceDate",'Month') as "Month", sum("Total") as "Total Sales"
from "Invoice" i
group by "Year", "Month"
order by "Year", "Total Sales" desc;


--15. Employee Details

select e."FirstName", e."LastName", date(e."BirthDate") as "DOB", date(e."HireDate") as "Hire Date", 
		date_part('year', age('2013-12-31',date(e."HireDate"))) as "Years of Working",
		e."Address" , e."City" , e."State" , e."Country" , e."Title" , e1."FirstName"||' '||e1."LastName" as "Manager Name", e1."Title" 
from "Employee" e , "Employee" e1 
where e."ReportsTo" = e1."EmployeeId";

--16. Total sales by employee age at the time of invoice date

select e."FirstName"  || ' ' || e."LastName" as "Full Name", date("InvoiceDate") as "Invoice Date" ,  date_part('year',age("BirthDate"::date)) - date_part('year',age("InvoiceDate"::date)) as "Age", sum("Total") as "Total Sales" 
from "Employee" e 
inner join "Customer" c on e."EmployeeId" = c."SupportRepId" 
inner join "Invoice" i on c."CustomerId" = i."CustomerId" 
group by "Full Name", "Invoice Date", "Age" 
order by "Full Name", "Age";


--17. Total sales by employee who are in their 30s, 40s, 50s, and 60s

select e."FirstName"  || ' ' || e."LastName" as "Full Name", date(i."InvoiceDate") as "Invoice Date" , date_part('year',age(e."BirthDate"::date)) - date_part('year',age(i."InvoiceDate"::date)) as "Age",  sum("Total") as "Total Sales" 
from "Employee" e 
inner join "Customer" c on e."EmployeeId" = c."SupportRepId" 
inner join "Invoice" i on c."CustomerId" = i."CustomerId" 
where date_part('year',age("BirthDate")) between 30 and 70
group by "Full Name" , "Invoice Date" , "Age"
order by "Full Name", "Age";


------------------------------------------------------------------------------

