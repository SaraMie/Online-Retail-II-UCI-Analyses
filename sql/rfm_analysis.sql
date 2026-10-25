-----
select
	Segment
	, COUNT(Customer_ID) [number of customers]
	, cast (round(100.0 * COUNT(Customer_ID) / (select COUNT(Customer_ID) from rfm_segmentation), 2) as float) [% of customers]
	, cast (round(100.0 * SUM(total_spend)/ (select sum(total_spend) from rfm_segmentation ), 2)  as float) [% of revenue]
	, cast (
		round(
			100.0 * SUM(total_spend)/ (select sum(total_spend) from rfm_segmentation ) / 
			(100.0 * COUNT(Customer_ID) / (select COUNT(Customer_ID) from rfm_segmentation))
		, 2) 
		as float) [Revenue ÷ customers]
	, cast ( round(avg(total_spend) ,2)   as float) [average spend]
from rfm_segmentation
group by Segment