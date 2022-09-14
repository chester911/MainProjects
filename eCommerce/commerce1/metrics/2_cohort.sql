# 코호트
-- 1개월 단위
-- 해당 월에 첫 구매를 한 고객들 중 n개월 뒤에도 구매를 한 고객들
select substr(first_order, 1, 7) as ym,
	diff_month,
    count(distinct customerId) as cust_cnt
from
	(select a.*,
		b.first_order,
        -- 첫 주문 일자와 다음 주문 일자의 차이
		timestampdiff(month, b.first_order, a.order_date) as diff_month
	from
		(select customerId,
			substr(invoiceDate, 1, 10) as order_date
		from retail) as a
		left join
		-- 고객 별 첫 주문 일자
				(select customerId,
					min(substr(invoiceDate, 1, 10)) as first_order
				from retail
				group by 1) as b
			on a.customerId= b.customerId) as a
group by 1, 2
order by 1;