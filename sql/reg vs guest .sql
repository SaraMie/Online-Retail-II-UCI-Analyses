-- Registered Customers vs. Guests 
-- overall
select 
	Is_Guest
	, count(transaction_id)  [Orders]
	, sum(Revenue) [Revenue]
	-- multiply by 100.0 is necessary for orders percent cause the int division 
	,  CAST(ROUND(( 100.0 * count(transaction_id) / (select count(transaction_id) from transactions_clean)) , 2) as float) [from total Orders (%)]
	, CAST( round(100.0 * (sum(Revenue) / (select sum(Revenue) from transactions_clean)), 2) as float) [from total Revenue (%)]
from transactions_clean
group by Is_Guest

-- per years but 2009 excluded
select 
	Is_Guest
	, invoice_year
	, count(transaction_id)  [Orders]
	, sum(Revenue) [Revenue]
	-- multiply by 100.0 is necessary for orders percent cause the int division 
	,  CAST(ROUND(( 100.0 * count(transaction_id) / (select count(transaction_id) from transactions_clean)) , 2) as float) [from total Orders (%)]
	, CAST( round(100.0 * (sum(Revenue) / (select sum(Revenue) from transactions_clean)), 2) as float) [from total Revenue (%)]
from transactions_clean
where invoice_year > 2009
group by Is_Guest, invoice_year
order by Is_Guest, invoice_year 