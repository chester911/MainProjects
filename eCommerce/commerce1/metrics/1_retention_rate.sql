# 월별 재구매율

-- 2011년 1월 구매자 중 2010년 12월에 구매한 사람들
(select a.order_ym,
	count(distinct a.customerId) as cust_curr,
    count(distinct b.customerId) as cust_prev,
    count(distinct b.customerId)/ count(distinct a.customerId)* 100 as retention_rate
from
	(select customerId,
		substr(invoiceDate, 1, 7) as order_ym
	from retail
    where substr(invoiceDate, 1, 7)= '2011-01') as a
	left join
			(select customerId,
				substr(invoiceDate, 1, 7) as order_ym
			from retail
            where substr(invoiceDate, 1, 7)= '2010-12') as b
		on a.customerId= b.customerId
			and left(a.order_ym, 4)= left(b.order_ym, 4)+ 1
group by 1
order by 1)
	union
-- 2011년 재구매율
-- 해당 월 구매자들 중 전 월에 구매를 진행한 고객들의 비율
(select a.order_ym,
	count(distinct a.customerId) as cust_curr,
    count(distinct b.customerId) as cust_prev,
    count(distinct b.customerId)/ count(distinct a.customerId)* 100 as retention_rate
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
where a.order_ym!= '2011-01'
group by 1
order by 1);