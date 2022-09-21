# 상품 가격대 별 구매 고객 수
-- 기존, 신규 고객 분류해서 파악
select substr(order_date, 1, 7) as ym,
	price_bin,
    user_type,
    count(distinct customerId) as cust_cnt
from
(select a.*,
	case when substr(a.order_date, 1, 7)= substr(b.first_order, 1, 7) then 'new_user'
		else 'old_user'
	end as user_type
from
	(select customerId,
		substr(invoiceDate, 1, 10) as order_date,
		case when unitPrice between 0 and 10 then 'low_price'
				when unitPrice between 11 and 50 then 'mid_low_price'
				when unitPrice between 51 and 100 then 'high_price'
				else 'max_price'
			end as price_bin
	from retail) as a
	left join
			(select customerId,
				min(substr(invoicedate, 1, 10)) as first_order
			from retail
            group by 1) as b
		on a.customerId= b.customerId) as a
group by 1, 2, 3
order by 1, field(price_bin, 'low_price', 'mid_low_price', 'high_price', 'max_price');