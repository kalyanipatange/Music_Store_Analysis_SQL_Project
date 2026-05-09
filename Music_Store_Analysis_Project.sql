-- SQL PROJECT- MUSIC STORE DATA ANALYSIS --

-- 1. Who is the senior most employee based on job title?
select * from employee
order by levels desc 
 limit 1;
 
 -- 2. Which countries have the most Invoices?
 select billing_country , count(*) as Most_Invoices from invoice
 group by billing_country 
 order by Most_Invoices desc;
 
 -- 3. What are top 3 values of total invoice?
 
 select total as total_invoice from invoice
 order by total_invoice desc
 limit 3;
 
 -- 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
 -- Write a query that returns one city that has the highest sum of invoice totals. 
 -- Return both the city name & sum of all invoice totals
 
 select billing_city ,sum(total) as invoice_total from invoice
 group by billing_city 
 order by invoice_total desc;
 
 -- 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
 -- Write a query that returns the person who has spent the most money
 
 select c.customer_id,c.last_name , c.first_name,sum(total) as Most_Money from customer c 
 join invoice i 
 on c.customer_id=i.customer_id
 group by c.customer_id, c.last_name , c.first_name
 order by Most_Money desc
 limit 1;
 
 -- Question Set 2 – Moderate
 
 -- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
 -- Return your list ordered alphabetically by email starting with A
 
 select first_name , last_name ,email from customer c 
  join invoice i   on c.customer_id=i.customer_id
  join invoice_line il   on i.invoice_id=il.invoice_id
  where track_id IN ( select track_id from track  t 
  join genre g on t.genre_id=g.genre_id
  where g.name like 'Rock')
  
  order by email;
  
  -- 2. Let's invite the artists who have written the most rock music in our dataset. 
  -- Write a query that returns the Artist name and total track count of the top 10 rock bands
  

select ar.artist_id,ar.name ,count(ar.artist_id)as number_of_songs from track tr 
join album2 al on al.artist_id= tr.album_id
join artist ar on ar.artist_id= al.artist_id 
join genre gr on gr.genre_id=tr.genre_id

where gr.name like 'Rock'
group by ar.artist_id,ar.name
order by number_of_songs desc 
limit 10;

 -- 3.Return all the track names that have a song length longer than the average song length. 
 -- Return the Name and Milliseconds for each track. 
 -- Order by the song length with the longest songs listed first
 
 select count(*)from track1;
 
 
SELECT name,milliseconds
FROM track1
WHERE milliseconds> 
	(SELECT AVG(milliseconds) AS avg_track_length
	FROM track1 )
ORDER BY  milliseconds DESC;


-- Question Set 3 – Advance

-- 1. Find how much amount spent by each customer on artists?
--  Write a query to return customer name, artist name and total spent

with best_selling_artist as (
select ar.name, ar.artist_id, sum(il.unit_price *il.quantity) as total_sales from invoice_line il  

join track1 tr on tr.track_id=il.track_id
join album2 al on al.album_id=tr.album_id
join artist ar on ar.artist_id=al.artist_id

group by 1,2
order by 3 desc
limit 1
)
select c.customer_id,c.first_name,c.last_name ,bsa.name,sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il  on il.invoice_id=i.invoice_id
join track1 tr on tr.track_id=il.track_id
join album2 al on al.album_id=tr.album_id
join best_selling_artist bsa on bsa.artist_id=al.artist_id
group by 1,2,3,4
ORDER BY 5 DESC;

-- 2.We want to find out the most popular music Genre for each country.
-- We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres


WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track1 ON track1.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track1.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


-- 3. Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount

WITH Customter_with_country AS 
(
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
