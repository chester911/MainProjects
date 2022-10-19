select substr(event_time, 1, 7) as ym,
	sum(price) as rev
from commerce_log.event
where event_type= 'purchase'
group by 1
order by 1;

select *,
	paid_users/ total_users* 100 as pu_ratio
from
(select substr(event_time, 1, 7) as ym,
	count(distinct user_id) as total_users,
    count(distinct case when event_type= 'purchase' then user_id else null end) as paid_users
from commerce_log.event
where substr(event_time, 1, 7) in ('2020-10', '2020-11')
group by 1
order by 1) as a;

select substr(event_time, 1, 7),
	count(distinct user_id)
from commerce_log.event
where event_type= 'purchase'
group by 1
order by 1;

with first_orders as
(select user_id,
	min(substr(event_time, 1, 7)) as first_order
from commerce_log.event
where event_type= 'purchase'
group by 1)

select substr(a.order_date, 1, 7) as ym,
	count(distinct a.user_id) as total_pu,
	count(distinct case when b.first_order= a.order_date then a.user_id else null end) as new_user,
    count(distinct case when b.first_order!= a.order_date then a.user_id else null end) as old_user
from
	(select user_id,
		substr(event_time, 1, 7) as order_date
	from commerce_log.event
	where event_type= 'purchase') as a
    left join first_orders as b
		on a.user_id= b.user_id
group by 1
order by 1;