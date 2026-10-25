use OnlineRetail;
drop table transactions_clean;
select 
	transaction_id,
	Invoice,
	StockCode,
	ISNULL(description, 'Unknown') as Description, 
	ISNULL(Customer_ID, 'Guest') as Customer_ID,
	Country,
	Quantity,
	Price,
	Quantity*Price as Revenue,
	InvoiceDate,
	year(invoicedate) as invoice_year,
	month(invoicedate) as invoice_month,
	day(invoicedate) as invoice_day,
	datepart(hour, invoicedate) as invoice_hour,
	case
		when Invoice like 'C%' then 1
		else 0
	end as Is_Cancelled,
	case
		when Customer_ID is null then 1
		else 0
	end as Is_Guest
into transactions_clean
from transactions_no_dup as main
where price > 0