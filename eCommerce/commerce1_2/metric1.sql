# 주간 현황
with user_types as
(select a.*,
	case when substr(a.invoiceDate, 1, 7)= substr(b.first_order, 1, 7) then 'new_user'
		else 'old_user'
	end as user_type
from retail as a
	left join
    -- 기존, 신규 고객 분류
    -- 고객 별 첫 구매 일자 활용
			(select customerId,
				min(substr(invoiceDate, 1, 10)) as first_order
			from retail
            group by 1) as b
		on a.customerId= b.customerId)
        
select substr(invoiceDate, 1, 7) as ym,
	yearweek(invoiceDate) as yearweek,
    user_type,
    count(distinct customerId) as cust_cnt,
    count(distinct invoiceNo) as order_cnt,
    sum(quantity* unitPrice) as rev_total
from user_types
group by 1, 2, 3
order by 1, 2, 3;