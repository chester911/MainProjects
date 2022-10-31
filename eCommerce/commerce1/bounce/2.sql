-- 2. 사용 기간이 긴 물품을 구매했을 것이다.

with orders as
(select customerId,
	count(distinct invoiceNo) as order_cnt
from retail_log.retail
group by 1)

select a.rnk,
    a.description as churn_product,
    b.description as non_churn_product
from
-- 이탈 고객이 구매한 물품 순위 (주문 건수 기준)
	(select row_number() over(order by count(distinct invoiceNo) desc) as rnk,
		a.stockCode,
		a.description
	from retail_log.retail as a
		left join orders as b
			on a.customerId= b.customerId
	where b.order_cnt= 1
	group by a.stockCode) as a
    left join
    -- 비 이탈 고객이 구매한 물품 순위 (주문 건수 기준)
			(select row_number() over(order by count(distinct invoiceNo) desc) as rnk,
				a.stockCode,
                a.description
			from retail_log.retail as a
				left join orders as b
					on a.customerId= b.customerId
			where b.order_cnt!= 1
            group by a.stockCode) as b
		on a.rnk= b.rnk;