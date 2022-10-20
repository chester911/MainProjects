# 주문 빈도(1인 당 몇 번의 주문을 하는지), 주문 당 결제 금액(한 번 주문할 때 얼마나 구매하는지)
-- 한 개의 세션을 한 번의 주문으로 간주
select substr(event_time, 1, 7) as ym,
	count(distinct user_session)/ count(distinct user_id) as order_per_user,
    sum(price)/ count(distinct user_session) as atv
from commerce_log.event
where substr(event_time, 1, 7) in ('2020-10', '2020-11')
	and event_type= 'purchase'
group by 1
order by 1;

# 신규, 기존 고객별 주문 빈도 및 ATV
with first_orders as
(select user_id,
	min(substr(event_time, 1, 7)) as first_order_ym
from commerce_log.event
where event_type= 'purchase'
group by 1)

select substr(a.order_date, 1, 7) as ym,
	count(distinct a.user_session)/ count(distinct a.user_id) as total_order_freq,
    sum(price)/ count(distinct a.user_session) as total_ATV,
    -- 고객 유형 별 주문 빈도
    count(distinct case when substr(a.order_date, 1, 7)= b.first_order_ym then a.user_session else null end)
		/ count(distinct case when substr(a.order_date, 1, 7)= b.first_order_ym then a.user_id else null end) as new_user_order_freq,
	count(distinct case when substr(a.order_date, 1, 7)!= b.first_order_ym then a.user_session else null end)
		/ count(distinct case when substr(a.order_date, 1, 7)!= b.first_order_ym then a.user_id else null end) as old_user_order_freq,
	-- 고객 유형 별 ATV
	sum(distinct case when substr(a.order_date, 1, 7)= b.first_order_ym then a.price else 0 end)
		/ count(distinct case when substr(a.order_date, 1, 7)= b.first_order_ym then a.user_session else null end) as new_user_ATV,
	sum(distinct case when substr(a.order_date, 1, 7)!= b.first_order_ym then a.price else 0 end)
		/ count(distinct case when substr(a.order_date, 1, 7)!= b.first_order_ym then a.user_session else null end) as old_user_ATV
from
	-- 주문 일자, 결제 금액 테이블
	(select user_id,
		substr(event_time, 1, 10) as order_date,
		price,
        user_session
	from commerce_log.event
	where event_type= 'purchase') as a
	left join first_orders as b
		on a.user_id= b.user_id
where substr(a.order_date, 1, 7) in ('2020-10', '2020-11')
group by 1
order by 1;