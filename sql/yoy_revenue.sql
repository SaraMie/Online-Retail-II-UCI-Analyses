-- Calculating yoy with exclude the invalid months

with invalid_months as (
select 
	-- getting only the month to be exclude it for each year
	invoice_month
from transactions_clean
	
-- year tie so month
group by invoice_year, invoice_month
having
	DATEDIFF(day, DATEFROMPARTS(invoice_year, invoice_month, 1), EOMONTH(DATEFROMPARTS(invoice_year, invoice_month, 1))) - count(distinct invoice_day) > 10
)

select 
    invoice_year,
    SUM(Revenue)                 as total_revnue,

    -- YoY % = (this year - last year) / last year * 100
    -- multiply 100.0 for getting fraction number + percent
   
    ROUND(100.0* (SUM(Revenue) - LAG(SUM(Revenue)) over (order by invoice_year))
          / LAG(SUM(Revenue)) over (order by invoice_year), 4)                       as [YoY Revenue %]


from transactions_clean as main
inner join invalid_months as cte on cte.invoice_month != main.invoice_month -- joining where month is not invalid month
where Is_Cancelled = 0    -- YoY calculated for only completed transactions
    and invoice_year > 2009  -- cause we have just 1 month in 2009

group by invoice_year
order by invoice_year;