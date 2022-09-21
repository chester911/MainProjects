# 구매 금액대 별 고객 수
-- 기존, 신규 고객 분류해서 파악
select substr(order_date, 1, 7) as ym,
	rev_bin,
    user_type,
    count(distinct customerId) as cust_cnt
from
(select a.customerId,
	a.order_date,
    case when substr(a.order_date, 1, 7)= substr(b.first_order, 1, 7) then 'new_user'
		else 'old_user'
	end as user_type,
    case when rev between 0 and 10 then 'cust_1'
			when rev between 11 and 50 then 'cust_2'
            when rev between 51 and 100 then 'cust_3'
            when rev between 101 and 500 then 'cust_4'
            when rev between 501 and 1000 then 'cust_5'
            else 'cust_6'
		end as rev_bin
from
	(select customerId,
		substr(invoiceDate, 1, 10) as order_date,
        quantity* unitPrice as rev
	from retail) as a
    left join
			(select customerId,
				min(substr(invoiceDate, 1, 10)) as first_order
			from retail
            group by 1) as b
		on a.customerId= b.customerId) as a
group by 1, 2, 3;