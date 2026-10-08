
## cleaning decisions
|Rule|Action|Rows affected|% of total|Why|
|-|-|-|-|-|
|duplicate rows|removed||||
|Cancellation|flagged|||for return analysis|
|Missing customer|kept with 'Guest' value , flagged||22|valid sales, represent the unregistered customers|
|Unspecified Country|kept||0.07|valid transactions, excluded only from country-level views|
|price <= 0|remove|||not real sales|


## Added columns

| Column | Type | Logic | Why it's added |
|---|---|---|---|
| `transaction_id` | INT (identity) | Auto-generated | Surrogate key, since the dataset has no natural primary key |
| `Revenue` | NUMERIC | `Quantity * Price` | Line total; negative on cancellations, so summing gives net revenue |
| `Is_Guest` | SMALLINT | 1 if `Customer_ID` is NULL, else 0 | Separates customer-level analysis (RFM, retention) from overall sales |
| `Is_Cancelled` | SMALLINT | 1 if `Invoice` starts with `C`, else 0 | Excludes returns from sales revenue and allows return-rate analysis |
| `Invoice_year` | INT | Extracted from `InvoiceDate` | Quick grouping for yearly trends |
| `Invoice_month` | INT | Extracted from `InvoiceDate` | Monthly trends and seasonality |
| `Invoice_day` | INT | Extracted from `InvoiceDate` | Day-level patterns |
| `Invoice_hour` | INT | Extracted from `InvoiceDate` | Time-of-day ordering patterns |

## Steps and SQL

### 1. Checking duplicate and remove them if exists

I used `ROW_NUMBER()` to rank rows within each group of identical values; any row with `row_num > 1` is an extra copy. NULLs are treated as equal, so rows with a missing `Customer_ID` are handled correctly.
```sql
select
	ROW_NUMBER() over(partition by Invoice, StockCode, Description, Quantity, Price,InvoiceDate, Customer_ID, Country order by invoice) as row_num
from transactions
```
### 2. Cancelled transactions
to deal with 

### 3. 
