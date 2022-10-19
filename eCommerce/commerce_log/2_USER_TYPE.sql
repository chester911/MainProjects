# 신규, 기존 고객의 수

-- 고객 별 첫 주문 월
with first_orders as
(select user_id,
	min(substr(event_time, 1, 7)) as first_order
from
	(select user_id,
		event_time
	from commerce_log.event
    where event_type= 'purchase') as a
group by 1
order by 2)

select order_ym,
	count(distinct case when user_type= 'new_user' then user_id else null end) as new_users,
    count(distinct case when user_type= 'old_user' then user_id else null end) as old_users
from
-- 주문 일자와 join
	(select a.user_id,
		a.order_ym,
		case when a.order_ym= b.first_order then 'new_user'
			else 'old_user'
		end as user_type
	from
		(select user_id,
			substr(event_time, 1, 7) as order_ym
		from commerce_log.event
		where event_type= 'purchase') as a
		left join first_orders as b
			on a.user_id= b.user_id) as user_types
where order_ym in ('2020-10', '2020-11')
group by 1
order by 1;