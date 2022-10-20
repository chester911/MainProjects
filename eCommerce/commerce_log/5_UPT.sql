# 주문 1회당 구매 제품 수량 (UPT)
-- user_session을 주문으로 간주

select substr(event_time, 1, 7) as ym,
	count(distinct user_session) as order_cnt,
    count(product_id) as products,
    count(product_id)/ count(distinct user_session) as upt
from commerce_log.event
where event_type= 'purchase'
	and substr(event_time, 1, 7) in ('2020-10', '2020-11')
group by 1
order by 1;

# 신규, 기존 유저 별 upt
with first_orders as
(select user_id,
	min(substr(event_time, 1, 7)) as first_order_ym
from commerce_log.event
where event_type= 'purchase'
group by 1)

select substr(a.order_date, 1, 7) as ym,
	count(case when substr(a.order_date, 1, 7)= b.first_order_ym then a.product_id else null end)
		/ count(distinct case when substr(a.order_date, 1, 7)= b.first_order_ym then a.user_id else null end) as new_user_upt,
	count(case when substr(a.order_date, 1, 7)!= b.first_order_ym then a.product_id else null end)
		/ count(distinct case when substr(a.order_date, 1, 7)!= b.first_order_ym then a.user_id else null end) as old_user_upt
from
	(select user_id,
		substr(event_time, 1, 10) as order_date,
		product_id,
		user_session
	from commerce_log.event
	where event_type= 'purchase') as a
    left join first_orders as b
		on a.user_id= b.user_id
where substr(a.order_date, 1, 7) in ('2020-10', '2020-11')
group by 1
order by 1
limit 100;