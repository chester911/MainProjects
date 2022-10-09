# DAU
select date,
	count(distinct user_id) as user_cnt
from
	(select user_id,
		substr(timestamp, 1, 10) as date
	from wow.history) as a
group by 1
order by 1;

# WAU
select yearweek,
	count(distinct user_id) as user_cnt
from
	(select user_id,
		yearweek(timestamp) as yearweek
	from wow.history) as a
group by 1
order by 1;

# 유저별 주간 평균 접속 횟수
select yearweek,
	sum(enter_cnt)/ count(distinct user_id) as avg_enter_cnt
from
	(select user_id,
		yearweek(date) as yearweek,
		count(distinct date) as enter_cnt
	from
		(select user_id,
			substr(timestamp, 1, 10) as date
		from wow.history) as a
	group by 1, 2) as b
group by 1
order by 1;

# 레벨대 별 1주당 평균 접속 일수
select yearweek,
	level_bin,
    sum(enter_cnt)/ count(distinct user_id) as avg_enter_cnt
from
	(select user_id,
		yearweek(date) as yearweek,
		level_bin,
		count(distinct date) as enter_cnt
	from
		(select user_id,
			substr(timestamp, 1, 10) as date,
			case when level between 1 and 9 then '~10'
					when level between 10 and 19 then '10~19'
					when level between 20 and 29 then '20~29'
					when level between 30 and 39 then '30~39'
					when level between 40 and 49 then '40~49'
					when level between 50 and 59 then '50~59'
					when level between 60 and 69 then '60~69'
					when level between 70 and 79 then '70~79'
					else '80~'
				end as level_bin
		from wow.history) as a
	group by 1, 2, 3) as b
group by 1, 2
order by 1, 2;

# 주간 신규 유저 유입
select yearweek(a.date) as yearweek,
	count(distinct a.user_id) as WAU,
	count(distinct case when a.level= 1 and a.date= b.join_date then a.user_id else null end) as new_user_cnt
from
	(select user_id,
		level,
		substr(timestamp, 1, 10) as date
	from wow.history) as a
    left join
    -- 유저 별 첫 접속 일자(가입일)
			(select user_id,
				min(substr(timestamp, 1, 10)) as join_date
			from wow.history
			group by 1) as b
		on a.user_id= b.user_id
group by 1
order by 1;

# 유저 폐사 구간
select case when level between 1 and 9 then '~10'
			when level between 10 and 19 then '10~19'
            when level between 20 and 29 then '20~29'
            when level between 30 and 39 then '30~39'
            when level between 40 and 49 then '40~49'
            when level between 50 and 59 then '50~59'
            when level between 60 and 69 then '60~69'
            when level between 70 and 79 then '70~79'
            else '80~'
		end as level_bin,
        count(distinct user_id) as user_cnt
from wow.history
where user_id in (select user_id
				from wow.history
                where level= 1)
group by 1
order by 2 desc;

-- select case when max_lv between 1 and 9 then '~10'
-- 			when max_lv between 10 and 19 then '10~19'
--             when max_lv between 20 and 29 then '20~29'
--             when max_lv between 30 and 39 then '30~39'
--             when max_lv between 40 and 49 then '40~49'
--             when max_lv between 50 and 59 then '50~59'
--             when max_lv between 60 and 69 then '60~69'
--             when max_lv between 70 and 79 then '70~79'
--             else '80~'
-- 		end as level_bin,
--         count(distinct user_id) as user_cnt
-- from
-- -- 유저 별 최대 레벨
-- 	(select user_id,
-- 		max(level) as max_lv
-- 	from
-- 		(select user_id,
-- 			level
-- 		from wow.history) as a
-- 	group by 1
-- 	order by 2) as a
-- group by 1
-- order by 1;

# 이탈?
-- 첫 접속 이후 한 달 이상 접속하지 않은 유저들
select month_since_join,
	count(distinct user_id) as user_cnt
from
	(select user_id,
		min(substr(timestamp, 1, 10)) as first_enter,
		max(substr(timestamp, 1, 10)) as last_enter,
		timestampdiff(month, min(substr(timestamp, 1, 10)), max(substr(timestamp, 1, 10))) as month_since_join
	from wow.history
	group by 1) as a
group by 1
order by 1;
-- 1개월 이내에 그만둔 사람들의 평균 레벨
select avg(max_level) as quit_level
from
	(select user_id,
		max(level) as max_level
	from
		(select user_id,
			level
		from wow.history) as a
	where user_id in (select user_id
					from
						(select user_id,
								timestampdiff(month, min(substr(timestamp, 1, 10)), max(substr(timestamp, 1, 10))) as month_since_join
						from wow.history
						group by 1) as a
					where month_since_join= 0)
	group by 1) as b;

# 게임을 한 기간 별 종족 선호도
with rnk as
(select month_since_join,
	race,
    charclass,
    count(distinct user_id) as user_cnt,
    rank() over(partition by month_since_join
				order by count(distinct user_id) desc) as rnk
from
	(select user_id,
		race,
        charclass,
		timestampdiff(month, min(timestamp), max(timestamp)) as month_since_join
	from
		(select user_id,
			timestamp,
			race,
            charclass
		from wow.history) as a
	group by 1, 2, 3) as b
group by 1, 2, 3)

select month_since_join,
	race,
    charclass
from rnk
where rnk= 1;
-- 1개월 이내에 그만 둔 사람들이 한 직업
select race,
	charclass,
    count(distinct user_id) as user_cnt
from
	(select user_id,
		race,
		charclass,
		timestampdiff(month, min(timestamp), max(timestamp)) as month_since_join
	from
		(select user_id,
			race,
			charclass,
			substr(timestamp, 1, 10) as timestamp
		from wow.history) as a
	group by 1, 2, 3) as b
where month_since_join= 0
group by 1, 2
order by 3 desc;