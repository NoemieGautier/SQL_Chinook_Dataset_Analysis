libname chinook "C:\Users\ngautier\OneDrive - IESEG\Business Reporting tools\Chinook Database";
/* FINANCIAL 
Evolution of sales per year and month*/

PROC SQL;
Select Year(Datepart(invoicedate)) as Year, Month(Datepart(invoicedate)) as Month, sum(Total) as Sales
From chinook.Invoices
Group BY Year, Month
Order By Year desc, month desc;
QUIT;

/* Evolution of sales per year*/

PROC SQL;
Select Year(Datepart(invoicedate)) as Year, Sum(Total) as Sales
From Chinook.Invoices
Group by Year
Order by year desc;
QUIT;

/*Average Number of tracks purchased per invoice*/

PROC SQL;
Select Count(*) / Count (Distinct InvoiceID) as Number_of_tracks
From chinook.invoice_items;
QUIT;

/* CUSTOMERS 
How many customers do we have?*/

PROC SQL;
Select Count(*) as Nbr_of_customers
From chinook.Customers;
QUIT;

/* How many customers are clients?*/

PROC SQL;
Select Distinct Count(Distinct CustomerID) as Nbr_of_clients 
From chinook.Invoices;
QUIT;

/* Number of customers and number of clients together*/

PROC SQL;
Select Count(Distinct C.CustomerID) as Nbr_of_customers, Count(Distinct I.CustomerID) as Nbr_of_clients 
From chinook.Customers as C,chinook.Invoices as I
Where C.CustomerID = I.CustomerID;
QUIT;

/* How long has it been since the last purchase (recency),
How many purchases has the customer done (frequency),
How much does the customer spend on average (monetary value)?*/

PROC SQL;
select C.customerID, max(Invoicedate)'Recency' format=Datetime.,Count(I.InvoiceID)  as Frequency, Avg(I.Total) as Monetary_value Format=8.2
from Chinook.customers as c,
	 Chinook.Invoices as I
where C.customerid = I.customerid
group by C.customerID;
QUIT;


/* Tenure of customers*/

Proc SQL; 
select Distinct CustomerID, min(round(yrdif(datepart(Invoicedate),today()))) as Years_with_company
From Chinook.Invoices
Group By CustomerID
Order By Years_with_company Desc;
QUIT;


/*Where are our customers located and what is our biggest market */

PROC SQL;
Select Distinct BillingCountry, Count(Distinct CustomerID) as Nbr_of_Customers, Sum(Total) as Sales_per_Country
From Chinook.Invoices 
Group By BillingCountry
Order by Sales_per_Country desc;
QUIT;

/*Customers that ordered more than the average customer in their country. */

proc sql;
select distinct C.CustomerID, c.firstname, C.lastname, count(I.InvoiceID) as nbr_invoices
from Chinook.customers as c,
	 Chinook.Invoices as I
where C.customerid = I.customerid
group by C.Firstname, C.lastname
having nbr_invoices >
	(select avg(invoices)
	from (select count(I.InvoiceID) as invoices
		  from Chinook.customers as C,
	 	  	   Chinook.Invoices as I
          where C.customerid = I.customerid 
			AND C.country = I.Billingcountry				
		  group by C.customerid));
quit;

/*The total amount spent by US customers, and by non-US customers */

proc sql;
select CASE WHEN I.customerID IN (select customerID from Chinook.customers
									WHERE country = "USA")
			THEN "USA"
			ELSE "Non-USA"
			END as location,
			Sum(I.Total) as Total_Amount
	FROM Chinook.Customers as C INNER JOIN Chinook.Invoices as I
	ON C.customerid = I.customerid
	GROUP BY Location;
quit;

/* INTERNAL BUSINESS PROCESSES 
Tracks that are bought most to least */

PROC SQL;
select T.Name, T.Composer, T.TrackID, Sum(I.Quantity) as Items_sold
from Chinook.Invoice_items as I, Chinook.Tracks as T
Where T.TrackID = I.TrackID
Group by T.Name, T.Composer, T.TrackID
Order By Items_sold desc;
QUIT;

/* Genres that are bought most to least*/

PROC SQL;
select G.Name, T.GenreID, Sum(I.Quantity) as Items_sold
from Chinook.Invoice_items as I, Chinook.Tracks as T, Chinook.Genres as G
Where T.TrackID = I.TrackID
AND G.GenreID = T.GenreID
Group by G.Name, T.GenreID
Order By Items_sold desc;
QUIT;

/* Media types that are bought most to least*/

PROC SQL;
select M.Name, T.MediaTypeID, Sum(I.Quantity) as Items_sold
from Chinook.Invoice_items as I, Chinook.Tracks as T, Chinook.Media_types as M
Where T.TrackID = I.TrackID
AND M.MediaTypeID = T.MediatypeID
Group by M.Name, T.MediaTypeID
Order By Items_sold desc;
QUIT;

/*Playlists that have the most sold genre but not the second one*/

PROC SQL;
SELECT DISTINCT a.name as PlayListName
FROM chinook.playlists as a, chinook.playlist_track as b, chinook.tracks as c, chinook.genres as d
WHERE a.playlistid = b.playlistid and
	  b.trackid = c.trackid and
	  c.genreId = d.genreId and
	  d.name = "Rock"
EXCEPT 
SELECT DISTINCT a.name as PlayListName
FROM chinook.playlists as a, chinook.playlist_track as b, chinook.tracks as c, chinook.genres as d
WHERE a.playlistid = b.playlistid and
	  b.trackid = c.trackid and
	  c.genreId = d.genreId and
	  d.name = "Latin";
QUIT;

/*Tracks that have no sells*/

proc sql;
select T.TrackID, T.AlbumID, T.GenreID, T.Composer, T.Bytes, IT.Quantity
   from Chinook.Tracks as T
        left join
        Chinook.Invoice_Items as IT
        on T.TrackID=IT.TrackID
   where IT.InvoiceID is missing
		Order by T.Bytes desc, T.TrackID, T.AlbumID, T.GenreID, T.Composer, IT.Quantity;
quit;


/*EMPLOYEES*/
*How many employees do we have;
Proc SQL; 
SELECT Count(*) 
FROM chinook.employees;
QUIT;

*How many are about to retire (age > 60);

Proc SQL; 
SELECT employeeID, round(yrdif(datepart(birthdate),today())) as age, round(yrdif( datepart(hiredate), today())) as Active
FROM chinook.employees
WHERE yrdif(datepart(birthdate),today()) > 60;
QUIT;

*How long have they been in the company for;

Proc SQL; 
SELECT employeeID, round(yrdif(datepart(birthdate),today())) as age, round(yrdif( datepart(hiredate), today())) as Active
FROM chinook.employees;
QUIT;

/*How many different role? */

Proc SQL; 
Select count( distinct Title) as nbr_of_roles 
From Chinook.Employees;
QUIT;

/*Employee Overview*/

Proc SQL; 
SELECT employeeID, FirstName, LastName, Title, round(yrdif(datepart(birthdate),today())) as age, round(yrdif( datepart(hiredate), today())) as Active
FROM chinook.employees;
QUIT;

/*How many sales does each of the salespeople have?*/

Proc SQL;
Select E.employeeID, E.firstname, E.lastname, E.City, sum(I.total) as total_sales_of_employees
From Chinook.Employees as E, Chinook.Invoices as I, Chinook.Customers as C
Where  E.employeeID = C.SupportrepID
	AND C.customerID = I.CustomerID
Group by E.EmployeeID, E.FirstName, E.Lastname, E.city
Order by 4;
QUIT;

/*How many sales does each of the supervisors have?*/

Proc SQL;
Select S.employeeID, S.firstname, S.lastname, S.city, sum(I.total) as total_sales_of_employees
From Chinook.employees as E, Chinook.Employees as S, Chinook.Invoices as I, Chinook.Customers as C
Where  E.employeeID = C.SupportrepID
	AND C.customerID = I.CustomerID
	AND E.Reportsto = S.EmployeeID
Group by S.EmployeeID, S.FirstName, S.Lastname, S.city 
Order by 4;
QUIT;

/*Which sales agent made the most sales in 2013? */

proc sql;
select C.SupportRepID, E.FirstName, E.LastName, Sum(I.Total) as Sales2013
from Chinook.Customers as C, Chinook.Invoices as I, Chinook.Employees as E
Where C.CustomerID = I.CustomerID
AND C.SupportRepID = E.EmployeeID
AND Year(Datepart(I.invoicedate)) = 2013
Group By C.SupportRepID, E.FirstName, E.LastName
Order By Sales2013 desc;
quit;