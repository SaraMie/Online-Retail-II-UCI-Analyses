
-- ord per customer and AOV Overall (excluding 2009)
select
	count(transaction_id) / count(distinct Customer_ID)	[Orders per customer]  -- how many orders per customer
	, ROUND( SUM(Revenue) / count(distinct transaction_id), 2) [AOV $]
	

from transactions_clean
where invoice_year>2009

-- ord per customer and AOV per year
select
	
	invoice_year ,
	count(transaction_id) / count(distinct Customer_ID)	[Orders per customer]  -- how many orders per customer
	, ROUND( SUM(Revenue) / count(distinct transaction_id), 2) [AOV $]
	

from transactions_clean
where invoice_year>2009
group by invoice_year

-- ord per customer and AOV per year and registered 
select
	is_guest,
	invoice_year ,
	count(transaction_id) / count(distinct Customer_ID)	[Orders per customer]  -- how many orders per customer
	, ROUND( SUM(Revenue) / count(distinct transaction_id), 2) [AOV $]
	

from transactions_clean
where invoice_year>2009
group by Is_Guest, invoice_year
order by is_guest, invoice_year
