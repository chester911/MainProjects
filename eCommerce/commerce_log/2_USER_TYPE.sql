# 신규, 기존 고객의 수

-- 고객 별 첫 주문 일자(월)
with first_orders as
(select user_id,
	min(substr(event_time, 1, 7)) as first_order_ym
from commerce_log.event
where event_type= 'purchase'
group by 1)

select *,
	new_users/ (new_users+ old_users)* 100 as new_user_ratio,
    old_users/ (new_users+ old_users)* 100 as old_user_ratio
from
-- 신규, 기존 고객의 수
	(select substr(order_date, 1, 7) as ym,
		count(distinct case when substr(order_date, 1, 7)= first_order_ym then user_id else null end) as new_users,
		count(distinct case when substr(order_date, 1, 7)!= first_order_ym then user_id else null end) as old_users
	from
		(select a.*,
			b.first_order_ym,
			case when substr(a.order_date, 1, 7)= b.first_order_ym then 'new_user'
				else 'old_user'
			end as user_type
		from
		-- 고객id, 주문 일자
			(select user_id,
				substr(event_time, 1, 10) as order_date
			from commerce_log.event
			where event_type= 'purchase') as a
			left join first_orders as b
				on a.user_id= b.user_id) as user_types
	where substr(order_date, 1, 7) in ('2020-10', '2020-11')
	group by 1
	order by 1) as user_types;