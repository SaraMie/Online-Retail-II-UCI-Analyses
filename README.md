
This project explores and cleans a retail dataset to get know about its sales growth, furthermore it do segmentation for the customers. It built in SQL queries for EDA, ETL, Analyses and Power BI for visualize those analyses

## Business Context

Who is the retailer: UK-based online gift shop

Primary audience: potential employers and stakeholders — see `sql/` for technical details and the dashboard for business insights

Why it matters: Understand business performance and identify customer groups to prioritize.

## Business Questions

1. How did sales perform year over year (YoY)? and what drove it ?
2. How can customers be segmented using RFM to target them differently?

## Dataset

- Source: UCI Machine Learning Repository — Online Retail II (link: [<dataset URL>](https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci))
- Period: Dec 2009 – Dec 2011 | ~ 1067371 rows | 8 columns
- Key fields: Invoice, StockCode, Quantity, InvoiceDate, Price, Customer ID, Country

## Data Cleaning

Summarize the main steps and the numbers (only list steps actually performed):

- Removed duplicates
- Removed negative  and 0 sales
- Kept missing Customer ID filled with ‘Guest’
- Kept missing Description filled with ‘Unknown’
- Kept ‘Unspecified’ Countries
- add flags columns: Is_Guest, Is_Cancelled
- add transaction_id unique not null column as primary key, represent each transaction
- add Revenue column : Quantity * Price
- add date parts columns

Rows before: 1067371 → after cleaning:  1026999

Columns before: 8 → after cleaning:  16

Files :

- remove duplicate and store the result in `transactions_no_dup` (file: sql/no_dup table.sql)
- cleaning columns and store the result in `transactions_clean` (file: ssql/columns cleaning.sql)

for more details check the [`/Cleaning Process`](https://github.com/SaraMie/Online-Retail-II-UCI-Analyses/tree/main/Cleaning%20process)

# Overview Dashboard

Overview of the full dataset, Dec 2009 to Dec 2011, before any exclusions

![overview_dash.png](overview_dash.png)

# Analysis

> **Revenue was flat in 2011 (+1.9%).** Customers neither ordered more often (about 115 orders per customer in both years) nor spent more per order (AOV stayed around $18). Registered customers, who generate most of the revenue, declined slightly. Guest orders grew, but at roughly half the value of a registered customer’s order, so they didn’t offset the decline. Revenue is also concentrated: a quarter of registered customers (Champions) generate 70% of it.
> 

### Y-o-Y Revenue

Y-o-Y growth it’s a percentage that describes the change of a measure comparing to previous year; we mostly care about Revenue Y-o-Y 

**Formula :**

`YoY Growth (%) = ((Current Value - Previous Value) / Previous Value) * 100`

before calculating Y-o-Y we need to verify if there missing days or months

![image.png](image.png)

**Query:  `sql/missing_days.sql`**

for 2009 → Just December

for 2010 → have all the months with some missing days, range from 3 to 10 days

for 2011 → have all the months with some missing days, range from 3 to 22 days. if we exclude the 22: range from 3 to 8

Month with only 8 days  is not real month, so it’ll be exclude in YoY calculation

> Note : the excluding will be for each year, for get a real balanced YoY
> 

a Year with only 1 month not a year, so it’ll be exclude in YoY calculation

 I set 10 missing days as the threshold for be a month

### YoY revenue growth

![image.png](image%201.png)

**Query:  `sql/yoy_revenue.sql`**

- It seems the Revenue growth over 2011 is almost flat (only 1.9%)

## Orders per Customer and Average Order Value

- Orders per Customer is average number of orders by each customer, represent purchase frequency

**Formula :**

 `Orders per Customer = Total Number of Orders / Number of Unique Customers`

- AOV is average amont spent for order

**Formula :**

 `AOV = Total Revenue / Total Number of Orders`

Overall (2010 and 2011 years) Orders per customers was 168 with 18.54$ as AOV means 

![image.png](image%202.png)

Orders didn’t increased over the 2011 and even the AOV stuck on 18$

![image.png](image%203.png)

a registered customer made only 88 order with AOV about 20$ in 2011, which is less then 2010

while the guests are making orders (+117k in 2011) but the AOV is the half of what a registered customer order

![image.png](image%204.png)

**Query:  `sql/ord per cust & aov.sql`**

## Registered Customers vs. Guests

**Overall totals :**

![image.png](image%205.png)

The Registered customers make most orders (77%) and revenue (85%), in other hand the Guest orders not easy number but revenue does not (+229k makes 14% of all revenue)

**per Years (2009 excluded) :**

![image.png](image%206.png)

for Registered customers as observed the volume of orders and revenue are slight decrease where Orders went from 38% to 36% in 2011 , Revenue went from 41% to 40%

We note that Guests went from +98k to +117k in 2011 while the revenue went down from 1.3M to 1.2M. Indicates that volume orders of guests doesn’t means more revenue.

**Query:  `sql/reg vs guest.sql`**

# Customer Segmentation using RFM

RFM is type of customer segmentation and behavioral targeting used to help businesses rank and segment customers based on the recency, frequency, and monetary value of a transaction. help the marketers and business owners to determine the target audience to use their budget most effectively

**Approach** 

```markdown
Calculating Metrics per customer

↓

Calculate R, F and M per customer as score for according metric from 1 to 5

↓

Map the scores to named Segments
```

**Segment Mapping**

| Segment | Rule | Meaning |
| --- | --- | --- |
| Champions | R ≥ 4 and F ≥ 4 | Recent, frequent, high spenders |
| Loyal | R ≥ 3 and F ≥ 3 | Buy regularly |
| Potential loyalists | R 3-5, F 4-5 | Upsell, loyalty perks |
| New customers | R ≥ 4 and F ≤ 2 | Recent, but few orders so far |
| At risk | R ≤ 2 and F ≥ 3 | Used to buy a lot, gone quiet |
| Can’t lose them | R 1-2, F 4-5, M 4-5 | Direct outreach, high priority |
| Lost | R ≤ 2 and F ≤ 2 | Low and inactive |

**Query:  `sql/rfm.sql`**

**Result :**  table ‘rfm_segmentation’ that contains the columns : customer_id, days_since_last_order, total_spend,  #_orders, R, F, M, Score, Segment

### RFM Analysis

![image.png](image%207.png)

**Query:  `sql/rfm_analysis.sql`**

Revenue ÷ customers metric :

- Above 1x means the segment brings in more than its share.
- Below 1x means it brings in less than its share.

Accordingly the segments ‘Champions’ , ‘Can’t lose them’ brings in more . while other segments brings in less than its share except ‘loyal customers’   was approximately to contributes equally

Among the 8 Segments we observe Champions, loyal , lost with big numbers. while other segments contributes with less than 5% of total revenue, and less than 11% of total registered customers

![image.png](image%208.png)

Champions: The greater part of customers (25% of customers) with huge slice of revenue (70%) and spend +7k $ as average, so the business depends on a quarter of its customers

Can’t lose them : a small group (4%) but a high spender (3,382 on average). They are valuable customers who have gone quiet, so they are worth winning back first.

Lost: the largest group by count after Champions (25%) but only 2.8% of revenue, so they are not worth much effort.

At risk: 11% of customers with a low revenue share, so they matter less than “Can’t lose them”

# Key Insights

- **Guest growth isn’t replacing registered revenue.** Guests place 23% of orders but bring in only 14% of revenue, because a guest order is worth about half a registered customer’s order. In 2011 guest orders grew about 19% (98k to 117k) while guest revenue slipped from 1.3M to 1.2M, so extra guest traffic isn’t offsetting the registered decline.
- Revenue depends heavily on a quarter of customers, so losing even a few Champions would hurt far more than losing the same number of Lost customers. Retention should come before acquisition
- Even their numbers less then 5% of customers but the “Cant lose them” segment share in revenue by 5%  of total. they’re valuable and slipping away, so they are the first group to target with a win-back campaign.

# Limitation

- The data covers Dec 2009 to Dec 2011, so only two comparable years are available. One YoY comparison can’t separate a real trend from normal year-to-year variation
- **Incomplete months excluded.** Dec 2009 (the only month of that year) and the partial Dec 2011 were left out so that YoY compares like-for-like months. Revenue from the excluded periods isn’t reflected in the results.
- **Guests can’t be tracked.** Guest orders have no customer ID, so they can’t be linked across purchases. Repeat behavior, lifetime value and RFM could only be measured for registered customers.
- **RFM thresholds are arbitrary.** Scores of 1-5 and the segment rules are my own choices, not validated against actual behavior. Different cutoffs would change segment sizes and the revenue shares reported.
- **Descriptive, not causal.** The analysis shows what changed, not why. Possible drivers (pricing, marketing, stock availability, seasonality) aren’t in the data.
