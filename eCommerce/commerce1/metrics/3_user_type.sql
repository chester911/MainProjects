# 월별 신규, 기존 고객 수

with user_types as
(select a.*,
	case when substr(a.order_date, 1, 7)= substr(b.first_order, 1, 7) then 'new_user'
		else 'old_user'
	end as user_type
from
	(select customerId,
		substr(invoiceDate, 1, 10) as order_date,
		quantity,
		unitPrice
	from retail) as a
    left join
			(select customerId,
				min(substr(invoiceDate, 1, 10)) as first_order
			from retail
            group by 1) as b
		on a.customerId= b.customerId)

select substr(order_date, 1, 7) as ym,
	user_type,
    count(distinct customerId) as user_cnt,
    round(sum(quantity* unitPrice), 1) as rev
from user_types
group by 1, 2
order by 1;