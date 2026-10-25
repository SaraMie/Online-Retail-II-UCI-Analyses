
select 
	
	invoice_month,
	invoice_year,
	-- calculating missing days for each month
	DATEDIFF(day, DATEFROMPARTS(invoice_year, invoice_month, 1), EOMONTH(DATEFROMPARTS(invoice_year, invoice_month, 1))) - count(distinct invoice_day) #_missing_days
	-- use distinct to get day as 1 row
from transactions_clean
-- year tie so month
group by invoice_year, invoice_month
order by invoice_year, invoice_month

