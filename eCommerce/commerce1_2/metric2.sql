# 1개월 이내의 재구매율
-- 현재 월 고객 중 몇 %가 저번달에도 구매했는지?

-- 2011년 1월 재구매율
(select substr(a.order_date, 1, 7) as ym,
	count(distinct a.customerId) as cust_prev,
    count(distinct b.customerId) as cust_before,
    count(distinct b.customerId)/ count(distinct a.customerId)* 100 as retention_rate
from
	(select customerId,
		substr(invoiceDate, 1, 10) as order_date,
		country
	from retail
    where substr(invoiceDate, 1, 7)= '2011-01') as a
    left join
			(select customerId,
				substr(invoiceDate, 1, 10) as order_date,
                country
			from retail
            where substr(invoiceDate, 1, 7)= '2010-12') as b
		on a.customerId= b.customerId
			and year(a.order_date)= year(b.order_date)+ 1
group by 1
order by 1 desc)

union

-- 2011년 2월~ 재구매율
(select *
from
(select substr(a.order_date, 1, 7) as ym,
	count(distinct a.customerId) as cust_prev,
    count(distinct b.customerId) as cust_before,
    count(distinct b.customerId)/ count(distinct a.customerId)* 100 as retention_rate
from
	(select customerId,
		substr(invoiceDate, 1, 10) as order_date,
		country
	from retail
    where year(invoiceDate)= 2011) as a
    left join
			(select customerId,
				substr(invoiceDate, 1, 10) as order_date,
                country
			from retail
            where year(invoiceDate)= 2011) as b
		on a.customerId= b.customerId
			and month(a.order_date)= month(b.order_date)+ 1
group by 1
order by 1) as a
where ym!= '2011-01');