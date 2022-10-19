# 결제 유저 수, ARPPU
select substr(event_time, 1, 7) as ym,
	count(distinct user_id) as pu,
    sum(price)/ count(distinct user_id) as arppu
from commerce_log.event
where event_type= 'purchase'
	and substr(event_time, 1, 7) in ('2020-10', '2020-11')
group by 1
order by 1;