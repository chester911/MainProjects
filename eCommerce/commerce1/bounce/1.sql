# 이탈 패턴 1. 한 번만 구매한 유저

-- 1. 대량, 고액 구매

-- 고객 별 주문 횟수
with orders as
(select customerId,
	count(distinct invoiceNo) as order_cnt
from retail_log.retail
group by 1)

select churn_type,
	-- churn 유형 별 인당 / 주문당 구매 수량, 금액
    sum(quantity)/ count(distinct customerId) as qty_per_cust,
    sum(quantity* unitPrice)/ count(distinct customerId) as rev_per_cust,
    sum(quantity)/ count(distinct invoiceNo) as qty_per_order,
    sum(quantity* unitPrice)/ count(distinct invoiceNo) as atv_per_order
from
-- churn, non churn 분류
	(select a.*,
		case when b.order_cnt= 1 then 'churn'
			else 'non_churn'
		end as churn_type
	from retail_log.retail as a
		left join orders as b
			on a.customerId= b.customerId) as churn
group by 1
order by field(churn_type, 'churn', 'non_churn');