# 한 달 이내에 그만 둔 사람들이 찾은 지역
with users_duration as
(select user_id,
	timestampdiff(month, min(timestamp), max(timestamp)) as month_since_join
from
	(select user_id,
		substr(timestamp, 1, 10) as timestamp
	from wow.history) as a
group by 1)

select a.zone,
	b.type,
    b.controlled,
    b.max_rec_level,
    b.max_bot_level,
	count(distinct user_id) as user_cnt,
    avg(a.level) as user_lv_avg
from
	(select *
	from
		(select user_id,
			level,
			zone
		from wow.history) as a
	where user_id in (select user_id
					from users_duration
					where month_since_join= 0)) as a
	left join
			(select zone_name,
				type,
                controlled,
                max_rec_level,
                max_bot_level
			from wow.zones) as b
		on a.zone= b.zone_name
group by 1
having count(distinct user_id)>= 1000
order by 6 desc;