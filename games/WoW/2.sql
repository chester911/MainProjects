# 월간 사용자 수
select substr(timestamp, 1, 7) as ym,
	count(distinct user_id) as user_cnt
from
	(select timestamp,
		user_id
	from wow.history) as a
group by 1
order by 1;

# 레벨대 별 유저 분포
-- 10단위
-- 월별 집계
select substr(date, 1, 7) as ym,
	case when level between 1 and 10 then '01s'
		when level between 11 and 20 then '10s'
        when level between 21 and 30 then '20s'
        when level between 31 and 40 then '30s'
        when level between 41 and 50 then '40s'
        when level between 51 and 60 then '50s'
        when level between 61 and 70 then '60s'
        when level between 71 and 80 then '70s'
		else '80s'
	end as level_bin,
    count(distinct user_id) as user_cnt
from
	(select user_id,
		level,
		substr(timestamp, 1, 10) as date
	from wow.history) as a
group by 1, 2
order by 1, 2;

# 지역, 레벨대 별 유저 수
select ym,
	zone,
    case when level between 1 and 10 then '01s'
		when level between 11 and 20 then '10s'
        when level between 21 and 30 then '20s'
        when level between 31 and 40 then '30s'
        when level between 41 and 50 then '40s'
        when level between 51 and 60 then '50s'
        when level between 61 and 70 then '60s'
        when level between 71 and 80 then '70s'
		else '80s'
	end as level_bin,
    count(distinct user_id) as user_cnt
from
	(select user_id,
		substr(timestamp, 1, 7) as ym,
		level,
		zone
	from wow.history) as a
group by 1, 2, 3
order by 1, 2, 3;