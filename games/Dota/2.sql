# 영웅 역할군 별 유저 수
select substring_index(b.roles, ':', 1) as position,
	count(distinct a.user_id) as user_cnt,
    sum(a.num_games) as game_cnt,
    sum(a.num_wins) as win_cnt,
    sum(a.num_wins)/ sum(a.num_games)* 100 as win_ratio
from dota.user_data as a
	left join dota.hero_data as b
		on a.hero_id= b.hero_id
group by 1
order by 2 desc;
-- 확실히 메인 딜러 포지션인 캐리 영웅 선호도가 높음

select *
from dota.hero_data
where substring_index(roles, ':', 1)= 'Nuker'
limit 100;