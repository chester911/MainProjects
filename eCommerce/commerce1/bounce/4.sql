# RFM 기법으로 이탈 유저를 분류

with date_diff as
(select *,
	timestampdiff(week, recent_order, '2011-08-01') as week_diff
from
-- 유저별 최신 주문일
	(select customerId,
		max(substr(invoiceDate, 1, 10)) as recent_order
	from retail_log.retail
	group by 1) as recent_orders),

-- 이탈 고객들
churn_users as
(select distinct customerId
from
-- 이탈, 비이탈 고객 분류
	(select *,
		case when week_diff>= 2 then 'churn'
			else 'non_churn'
		end as churn_type
	from date_diff) as churn_types
where churn_type= 'churn'),

-- rfm 점수
rfm_scores as
(select customerId,
	ntile(5) over(order by week_diff) as recency,
	ntile(5) over(order by order_cnt) as frequency,
    ntile(5) over(order by total_rev) as monetary
from
	(select customerId,
		-- 최신 주문일
		max(substr(invoiceDate, 1, 10)) as recent_order,
        timestampdiff(week, max(substr(invoiceDate, 1, 10)), '2011-08-01') as week_diff,
		-- 총 결제 건수
		count(distinct invoiceNo) as order_cnt,
		-- 총 결제 금액
		sum(quantity* unitPrice) as total_rev
	from retail_log.retail
	where customerId in (select distinct customerId
						from churn_users)
	group by 1) as rfm_table)

select customerId,
	case when rfm between 3 and 4 then 'super_light'
		when rfm between 5 and 7 then 'light'
        when rfm between 8 and 10 then 'normal'
        when rfm between 11 and 13 then 'vip'
        else 'vvip'
	end as user_classes
from
	(select customerId,
		recency+ frequency+ monetary as rfm
	from rfm_scores) as rfm_ranks;