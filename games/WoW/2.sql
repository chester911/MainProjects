# 월간 사용자 수
select substr(timestamp, 1, 7) as ym,
	count(distinct user_id) as user_cnt
from
	(select timestamp,
		user_id
	from wow.history) as a
group by 1
order by 1;