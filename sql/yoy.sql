
select 
    invoice_year,
    COUNT(transaction_id)        as [#_orders],
    COUNT(distinct Customer_ID)  as [#_reg_custm],
    SUM(Revenue)                 as total_revnue,

    -- YoY % = (this year - last year) / last year * 100
    -- multiply 1.0* for getting fraction number
    ROUND( 100.0* (COUNT(transaction_id) - LAG(COUNT(transaction_id)) over (order by invoice_year))
          / LAG(COUNT(transaction_id)) over (order by invoice_year), 4)              as orders_yoy_pct,

    ROUND( 100.0* (COUNT(distinct Customer_ID) - LAG(COUNT(distinct Customer_ID)) over (order by invoice_year))
          / LAG(COUNT(distinct Customer_ID)) over (order by invoice_year), 4)        as custm_yoy_pct,

    ROUND(100.0* (SUM(Revenue) - LAG(SUM(Revenue)) over (order by invoice_year))
          / LAG(SUM(Revenue)) over (order by invoice_year), 4)                       as revenue_yoy_pct


from transactions_clean
where Is_Cancelled = 0 --and Is_Guest = 1   -- completed + registered
    and invoice_year > 2009  -- cause we have just 1 month in 2009
group by invoice_year
order by invoice_year;

