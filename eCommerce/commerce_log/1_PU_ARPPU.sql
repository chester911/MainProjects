# 전체 유저 수, 결제 유저 수, 결제 유저 비율, ARPPU
select substr(event_time, 1, 7) as ym,
	count(distinct user_id) as total_user,
    count(distinct case when event_type= 'purchase' then user_id else null end) as paid_users,
    count(distinct case when event_type= 'purchase' then user_id else null end)/ count(distinct user_id)* 100 as pu_ratio,
    sum(case when event_type= 'purchase' then price else 0 end) as total_rev,
    sum(case when event_type= 'purchase' then price else 0 end)/ count(distinct case when event_type= 'purchase' then user_id else null end) as ARPPU
from commerce_log.event
where substr(event_time, 1, 7) in ('2020-10', '2020-11')
group by 1
order by 1;