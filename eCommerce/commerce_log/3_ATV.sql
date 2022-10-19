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