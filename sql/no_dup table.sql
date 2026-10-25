

select 
	IDENTITY(int, 1, 1) as tranctions_id,
	no_dup.*
into transactions_no_dup
from (
	select distinct *
	from transactions
) as no_dup
;

select * from transactions_no_dup