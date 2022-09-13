# 월별 재구매율
-- 2011년 재구매율 먼저 계산
-- 2010년 12월 ~ 2011년 1월 재구매율은 따로 추출해 병합

-- 2011년 재구매율
select a.order_ym,
	count(distinct a.customerId) as cust_curr,
    count(distinct b.customerId) as cust_prev
from
	(select customerId,
		substr(invoiceDate, 1, 7) as order_ym
	from retail
    where year(invoiceDate)= 2011) as a
	left join
			(select customerId,
				substr(invoiceDate, 1, 7) as order_ym
			from retail
            where year(invoiceDate)= 2011) as b
		on a.customerId= b.customerId
			and right(a.order_ym, 2)= right(b.order_ym, 2)+ 1
group by 1
order by 1;