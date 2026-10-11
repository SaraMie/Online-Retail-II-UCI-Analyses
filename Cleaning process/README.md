
- [ ] add numbers for cleaning decisions
- [ ] add link to SQL queries files

# Transactions Data Cleaning (T-SQL)
 
Cleaning of the raw `transactions` table into an analysis-ready table, `transactions_no_dup`. The steps remove duplicates and invalid rows, handle missing values, and add flag, revenue and date columns for downstream analysis (RFM, retention, return rates, seasonality).
 
**Source table:** `transactions`
**Output table:** `transactions_clean`
**Dialect:** T-SQL (SQL Server)

## cleaning decisions

| Rule | Action | Rows affected | % of total | Why |
|---|---|---|---|---|
| Duplicate rows | Removed | _TBD_ | _TBD_ | Exact copies inflate sales and counts |
| Cancellations (`Invoice` starts with `C`) | Kept, flagged (`Is_Cancelled`) | _TBD_ | _TBD_ | Needed for return analysis |
| Missing `Customer_ID` | Kept, filled with `'Guest'`, flagged (`Is_Guest`) | _TBD_ | ~22% | Valid sales from unregistered customers |
| Unspecified `Country` | Kept | _TBD_ | ~0.07% | Valid transactions; excluded only from country-level views |
| `Price <= 0` | Removed | _TBD_ | _TBD_ | Not real sales |
| Missing `Description` | Kept, filled with `'Unknown'` | _TBD_ | _TBD_ | Sale is valid; the product label is just missing |
---


## Added columns

| Column | Type | Logic | Why it's added |
|---|---|---|---|
| `transaction_id` | INT (identity) | Auto-generated | Surrogate key, since the dataset has no natural primary key |
| `Revenue` | NUMERIC | `Quantity * Price` | Line total; negative on cancellations, so summing gives net revenue |
| `Is_Guest` | SMALLINT | `1` if `Customer_ID` is NULL, else `0` | Separates customer-level analysis (RFM, retention) from overall sales |
| `Is_Cancelled` | SMALLINT | `1` if `Invoice` starts with `C`, else `0` | Excludes returns from sales revenue and allows return-rate analysis |
| `Invoice_year` | INT | `YEAR(InvoiceDate)` | Yearly trends |
| `Invoice_month` | INT | `MONTH(InvoiceDate)` | Monthly trends and seasonality |
| `Invoice_day` | INT | `DAY(InvoiceDate)` | Day-level patterns |
| `Invoice_hour` | INT | `DATEPART(HOUR, InvoiceDate)` | Time-of-day ordering patterns |
 
---

## Steps and SQL

### 1. Checking duplicate and remove them if exists

`ROW_NUMBER()` numbers the rows inside each group of identical values. Any row with `row_num > 1` is an extra copy. NULLs are treated as equal in `PARTITION BY`, so rows with a missing `Customer_ID` are handled correctly.
```sql
WITH ranked AS (
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY Invoice, StockCode, Description, Quantity,
                         Price, InvoiceDate, Customer_ID, Country
            ORDER BY Invoice
        ) AS row_num
    FROM transactions
)
SELECT COUNT(*) AS duplicate_rows
FROM ranked
WHERE row_num > 1;
```
### 2. Creating non-duplication table
`DISTINCT` keeps one copy of each row. The result is copied into a new table, `transactions_no_dup`, so the raw data stays untouched. An identity column is added at the same time as the surrogate key.
```sql
select 
	IDENTITY(int, 1, 1) as tranctions_id, -- auto increment id
	no_dup.*
into transactions_no_dup
from (
	select distinct *
	from transactions
) as no_dup
; 
```
### 3. Columns Cleaning 
Two columns contain missing values: `Customer_ID` and `Description`. and Invalid values in `Price`
#### 1. Customer_id 
A NULL `Customer_ID` means the buyer is an unregistered (guest) customer. The NULLs are replaced with `'Guest'` using `ISNULL`.
```sql
ISNULL(Customer_ID, 'Guest')
> **Note:** If `Customer_ID` is numeric, cast it to text first. Otherwise `ISNULL` tries to convert `'Guest'` to a number and fails. The `Is_Guest` flag is computed from the original NULL, so it is not affected by the replacement.
```
#### 2. Description
NULLs in `Description` mean the product label was lost or never recorded, so they are replaced with `'Unknown'`.
```sql
ISNULL(description, 'Unknown')
```
#### 3. Price
Rows with a price of zero or less are not real sales (free items, adjustments, bad debt entries) and are filtred.

### 3. Added Columns

#### 1. Is_Cancelled flag
this is a flag column with 0 and 1 values, so tracking cancelled transactions is much easier.
```sql
case
	when Invoice like 'C%' then 1 -- the invoice value that started with 'C' is cancelled transaction
	else 0
end
```
#### 2. Is_Guest flag
that flag is tracking guest customers
```sql
case
	when Customer_ID is null then 1
	else 0
end
```
#### 3. transaction_id
An integer primary key for `transactions_no_dup`. It is created in step 2 with `IDENTITY(INT, 1, 1)`, so no extra SQL is needed here.
#### 4. Revenue
The line total, which gives the dataset a real sales measure. It is negative for cancellations, so `SUM(Revenue)` returns net revenue.
```sql
Quantity*Price as Revenue
```
#### 5. InvoiceDate parts
The date is split into parts to make time-based grouping simple.
```sql
YEAR(InvoiceDate)             AS Invoice_year,
MONTH(InvoiceDate)            AS Invoice_month,
DAY(InvoiceDate)              AS Invoice_day,
DATEPART(HOUR, InvoiceDate)   AS Invoice_hour
```

### 4. Build the final table (`transactions_clean`)
Steps 3 and 4 showed each rule on its own. This step combines them in a single query that reads from `transactions_no_dup` and writes the result to `transactions_clean`. In one pass it:
 
- **Filters** out rows with `Price <= 0` (the `WHERE` clause).
- **Fills** missing `Customer_ID` and `Description` values with `'Guest'` and `'Unknown'`.
- **Adds** `Revenue`, the four date-part columns, and the `Is_Cancelled` and `Is_Guest` flags.
- **Keeps** the surrogate key `transaction_id` from step 2.
The `Is_Guest` flag reads `Customer_ID` from the source table, where it is still NULL, so it is correct even though the output column is filled with `'Guest'`. Cancellations are kept (flagged, not removed), so return analysis is still possible.
 
The query starts with a `DROP TABLE IF EXISTS` so it can be re-run safely whenever the cleaning logic changes.
```sql
drop table transactions_clean; -- if already exists a table with that name
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
```













```
#### 5. InvoiceDate parts



