use OnlineRetail;

drop table rfm_segmentation;
with customer_metrics as (
select
	Customer_ID,
	DATEDIFF(day, max(InvoiceDate) , MAX(MAX(invoiceDate)) over () ) as days_since_last_order,
	-- MAX(MAX(invoiceDate)) over () ) represent the recent order date among the whole dataset
	sum(Revenue)  as total_spend,
	count( transaction_id) as #_orders
from transactions_clean
where Customer_ID != 'Guest'
group by Customer_ID

)



select 
	*,
	CASE
		WHEN R IN (4,5) AND F IN (4,5)                  THEN 'Champions'
		WHEN R IN (1,2) AND F IN (4,5) AND M IN (4,5)   THEN 'Cant lose them'
		WHEN R IN (1,2) AND F IN (3,4,5)                THEN 'At risk'
		WHEN R BETWEEN 3 AND 5 AND F BETWEEN 3 AND 5    THEN 'Loyal customers'
		WHEN R IN (4,5) AND F = 2                       THEN 'Potential loyalists'
		WHEN R IN (4,5) AND F = 1                       THEN 'New customers'
		WHEN R = 3 AND F IN (1,2)                       THEN 'Need attention'
		WHEN R IN (1,2) AND F IN (1,2)                  THEN 'Lost'
		ELSE 'Other' -- if it appears : wrong rule OR wrong rules order
	END AS Segment
into rfm_segmentation
from (

select
	*,
	NTILE(5) over(order by days_since_last_order desc) as R, -- old means worst
	NTILE(5) over(order by #_orders ) as F,   -- the more ,the better 
	NTILE(5) over(order by total_spend) as M,  -- the more ,the better 
	concat(NTILE(5) over(order by days_since_last_order desc), NTILE(5) over(order by #_orders desc), NTILE(5) over(order by total_spend)) as Score

from customer_metrics

) t

