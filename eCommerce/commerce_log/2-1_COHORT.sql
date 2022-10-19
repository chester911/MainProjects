# 기존 고객들은 몇 달 만에 재구매를 하는지?
-- 코호트 분석을 통해 파악 (월 단위)

-- 고객 별 첫 구매 일자
with first_orders as
(select user_id,
	min(substr(event_time, 1, 10)) as first_order
from commerce_log.event
where event_type= 'purchase'
group by 1),

-- 주문 일자 테이블 (전체기간)
order_dates as
(select user_id,
	substr(event_time, 1, 10) as order_date
from commerce_log.event
where event_type= 'purchase')

select substr(first_order, 1, 7) as first_order_ym,
	month_diff,
    count(distinct user_id) as user_cnt
from
	(select a.*,
		b.first_order,
        -- 첫 구매일부터 몇 달 뒤에 구매했는지?
		timestampdiff(month, b.first_order, a.order_date) as month_diff
	from order_dates as a
		left join first_orders as b
			on a.user_id= b.user_id) as cohort_table
group by 1, 2
order by 1, 2;