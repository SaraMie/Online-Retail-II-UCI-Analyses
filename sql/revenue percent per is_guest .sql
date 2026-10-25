--with not_pr as (
--select 
--	transaction_id,
--	StockCode
--from transactions_clean
--where StockCode like 'M%' 
--	or StockCode like 'dot'
--	or StockCode like 'post'
--	or StockCode like 'd'
	

--)

-- share of registered customers 
select
	100.00 * sum(revenue)/(select SUM(revenue) as total from transactions_clean where Is_Cancelled= 0 ) as rev_percent_reg

from transactions_clean
where Is_Cancelled= 0 and Is_Guest= 0

-- share of not-registered customers 
select
	100.00 * sum(revenue)/(select SUM(revenue) as total from transactions_clean where Is_Cancelled= 0 ) as rev_percent_reg

from transactions_clean
where Is_Cancelled= 0 and Is_Guest= 1