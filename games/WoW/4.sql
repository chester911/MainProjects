# 일 평균 접속 시간
with daily_enter_exit as
(select user_id,
	case when level between 1 and 9 then '~10'
		when level between 10 and 19 then '10~19'
		when level between 20 and 29 then '20~29'
		when level between 30 and 39 then '30~39'
		when level between 40 and 49 then '40~49'
		when level between 50 and 59 then '50~59'
		when level between 60 and 69 then '60~69'
		when level between 70 and 79 then '70~79'
		else '80~'
	end as level_bin,
	date(timestamp) as date,
    min(hour(timestamp)) as enter,
    max(hour(timestamp)) as 'exit'
from
	(select user_id,
		level,
		timestamp
	from wow.history) as a
group by 1, 3
order by 3)

select user_id,
	level_bin,
    date,
    `exit`- enter as play_time
from daily_enter_exit;