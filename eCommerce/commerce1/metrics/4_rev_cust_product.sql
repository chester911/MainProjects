# 월별 상품별 구매자 수, 매출
-- 신규, 기존 고객별로 분류해 대시보드에서 사용할 수 있도록
with user_types as
(select a.*,
	case when substr(a.invoiceDate, 1, 7)= substr(b.first_order, 1, 7) then 'old_user'
		else 'new_user'
	end as user_type
from retail as a
	left join
			-- 고객 별 첫 주문 일자
			(select customerId,
				min(substr(invoiceDate, 1, 10)) as first_order
			from retail
            group by 1) as b
		on a.customerId= b.customerId)

select substr(invoiceDate, 1, 7) as ym,
	stockCode,
    description,
    user_type,
    count(distinct customerId) as cust_cnt,
    round(sum(quantity* unitPrice), 1) as rev
from user_types
group by 1, 2, 4
order by 1, 4;