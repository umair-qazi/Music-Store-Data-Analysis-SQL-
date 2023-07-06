-- Project Phase I

-- 1.Who is the senior most employee based on job title?

-- 1st approach - if employee dont report to any other employee it means that employee is the senior most employee
SELECT * FROM project.employee
WHERE reports_to IS NULL ;

-- 2nd approach - senior most employee will have the highest level in levels column
SELECT * FROM project.employee
ORDER BY levels DESC
LIMIT 1 ;

-- 2. Which countries have the most Invoices?

-- 1st approach - We can find most invoiced country by counting the invoice id's for their respective country
SELECT billing_country AS Country , COUNT(DISTINCT invoice_id) AS Invoices
FROM project.invoice
GROUP BY billing_country
ORDER BY Invoices DESC
LIMIT 1 ;

-- 2nd approach - By using dense rank over the count of invoice id
WITH cte AS (SELECT billing_country AS Country , DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT invoice_id) DESC) AS Rnk
FROM project.invoice
GROUP BY billing_country)
SELECT * FROM cte
WHERE Rnk = 1 ;

-- 3. What are top 3 values of total invoice? 

-- 1st approach - If we consider to solve problem using total column in invoice table then we can get top 3 values using dense rank on total column
WITH cte AS (SELECT total, DENSE_RANK() OVER (ORDER BY total DESC) AS Rnk
FROM project.invoice)
SELECT * FROM cte
WHERE Rnk <= 3 ;

-- 2nd approach - If we consider to solve problem using count of invoice id
SELECT billing_country , COUNT(invoice_id)
FROM project.invoice
GROUP BY billing_country
LIMIT 3 ;

/* 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

/* To find city which has best customer we can consider the sum of amount spent (total) by grouping it according to city.
   After finding sum , the city which has the highest value will be our best customers city */
   
-- 1st approach - By using the sum of total column for the respective city and limiting the output  
SELECT billing_city AS City , SUM(total) AS Invoice_total
FROM project.invoice
GROUP BY billing_city
ORDER BY Invoice_total DESC
LIMIT 1 ;

-- 2nd approach - By using dense rank on sum of total column 
WITH cte AS (SELECT billing_city AS City ,SUM(total) AS Invoice_total,
DENSE_RANK() OVER (ORDER BY SUM(total) DESC) AS Rnk
FROM project.invoice
GROUP BY billing_city)
SELECT * FROM cte
WHERE Rnk = 1 ;

/* 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money */

-- 1st approach - By joining the customer and invoice table and using the sum of total column
SELECT c.customer_id ,c.first_name, c.last_name , SUM(i.total) AS Amount_spent
FROM project.customer c INNER JOIN project.invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY Amount_spent DESC
LIMIT 1 ;

-- 2nd approach - By joining the customer and invoice table and using dense rank over sum of total
WITH cte AS (SELECT c.customer_id ,c.first_name, c.last_name , SUM(i.total) AS Amount_spent ,
DENSE_RANK() OVER (ORDER BY SUM(i.total) DESC ) AS Rnk
FROM project.customer c INNER JOIN project.invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id)
SELECT * FROM cte
WHERE Rnk = 1 ;


-- Project Phase II

/* 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A */

-- 1st approach - By joining customer,invoice,invoice_line,track,genre tables and giving genre name condition 

-- If we consider email starting with A only
SELECT DISTINCT c.email , c.first_name , c.last_name , g.name
FROM project.customer c INNER JOIN project.invoice i ON c.customer_id = i.customer_id
INNER JOIN project.invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN project.track t ON il.track_id = t.track_id
INNER JOIN project.genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock' AND UPPER(c.email) LIKE 'A%'
ORDER BY c.email ;

-- If we consider all the emails but ordering it alphabetically
SELECT DISTINCT c.email , c.first_name , c.last_name , g.name
FROM project.customer c INNER JOIN project.invoice i ON c.customer_id = i.customer_id
INNER JOIN project.invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN project.track t ON il.track_id = t.track_id
INNER JOIN project.genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock' 
ORDER BY c.email ;

-- 2nd approach - By joining customer , invoice,invoice_line table and using subquery in where statement

-- If we consider email starting with A only
SELECT DISTINCT c.email , c.first_name , c.last_name
FROM project.customer c INNER JOIN project.invoice i ON c.customer_id = i.customer_id
INNER JOIN project.invoice_line il ON i.invoice_id = il.invoice_id
WHERE track_id IN (SELECT t.track_id FROM project.track t INNER JOIN project.genre g ON t.genre_id = g.genre_id WHERE g.name = 'Rock')
AND UPPER(c.email) LIKE 'A%'
ORDER BY c.email ;

-- If we consider all the emails but ordering it alphabetically
SELECT DISTINCT c.email , c.first_name , c.last_name
FROM project.customer c INNER JOIN project.invoice i ON c.customer_id = i.customer_id
INNER JOIN project.invoice_line il ON i.invoice_id = il.invoice_id
WHERE track_id IN (SELECT t.track_id FROM project.track t INNER JOIN project.genre g ON t.genre_id = g.genre_id WHERE g.name = 'Rock')
ORDER BY c.email ;    


/* 2. Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands */
select * from track;

-- 1st approach -- By using joins
SELECT a.name , COUNT(t.track_id) AS Total_track_count
FROM project.artist a INNER JOIN project.album al ON a.artist_id = al.artist_id
INNER JOIN project.track t ON al.album_id = t.album_id
INNER JOIN project.genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock' 
GROUP BY a.name
ORDER BY Total_track_count DESC
LIMIT 10 ;

-- 2nd approach -- By using subquery
SELECT a.name , COUNT(t.track_id) AS Total_track_count
FROM project.artist a INNER JOIN project.album al ON a.artist_id = al.artist_id
INNER JOIN project.track t ON al.album_id = t.album_id
WHERE track_id IN (SELECT track_id FROM project.track INNER JOIN project.genre g ON t.genre_id = g.genre_id WHERE g.name = 'Rock')
GROUP BY a.name
ORDER BY Total_track_count DESC
LIMIT 10 ;

-- 3rd approach -- By using cte
WITH cte AS (SELECT a.name , COUNT(t.track_id) AS Total_track_count,
DENSE_RANK() OVER (ORDER BY COUNT(t.track_id) DESC) AS Rnk
FROM project.artist a INNER JOIN project.album al ON a.artist_id = al.artist_id
INNER JOIN project.track t ON al.album_id = t.album_id
INNER JOIN project.genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock' 
GROUP BY a.name)
SELECT * FROM cte
WHERE Rnk < 11 ;

/* 3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first */

-- using subquery
SELECT name , milliseconds
FROM project.track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM project.track)
ORDER BY milliseconds DESC ;


-- Project Phase III

-- 1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

SELECT CONCAT(c.first_name,' ',c.last_name) AS Customer_name , ar.name AS Artist_name , SUM(il.unit_price * il.quantity) AS Total_spent
FROM project.customer c LEFT JOIN project.invoice i ON c.customer_id = i.customer_id
INNER JOIN project.invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN project.track t ON il.track_id = t.track_id
INNER JOIN project.album al ON t.album_id = al.album_id
INNER JOIN project.artist ar ON al.artist_id = ar.artist_id
GROUP BY 1 , 2
ORDER BY 1;


/* 2. We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres */

WITH cte AS (SELECT i.billing_country AS Country , g.name AS Genre ,
DENSE_RANK() OVER (PARTITION BY i.billing_country ORDER BY COUNT(il.quantity) DESC) AS Rnk
FROM project.invoice i INNER JOIN project.invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN project.track t ON il.track_id = t.track_id 
INNER JOIN project.genre g ON t.genre_id = g.genre_id
GROUP BY 1 ,2)
SELECT Country , Genre AS Top_Genre
FROM cte
WHERE Rnk = 1 ;


/* 3. Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount */

WITH cte AS (SELECT c.first_name,c.last_name,i.billing_country AS Country , SUM(i.total) AS Total_Amount_spent ,
DENSE_RANK() OVER (PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC ) AS Rnk
FROM project.customer c INNER JOIN project.invoice i ON c.customer_id = i.customer_id
GROUP BY 1,2,3 )
SELECT * FROM cte
WHERE Rnk = 1 ;







		




