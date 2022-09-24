# 주간 현황
-- 가장 처음, 마지막 주는 제외
select *,
	round(rev/ wau, 1) as arpu,
    round(rev/ paid_user, 1) as arppu
from
	(select yearweek(event_time) as yearweek,
		count(distinct user_id) as WAU,
		count(distinct case when event_type= 'purchase' then user_id else null end) as paid_user,
		round(sum(case when event_type= 'purchase' then price else 0 end), 1) as rev
	from event
    where yearweek(event_time) not in ('202038', '202050')
	group by 1
	order by 1) as a;
-- 가장 최근인 2020년 49주차를 기준으로 시작
-- 전체 유저, 결제 유저, 총 매출은 감소함
-- 전체 유저 중 결제 유저의 비율도 감소함
-- 하지만 ARPPU는 증가함
-- 왜?

# 48주차와 49주차의 이벤트 유형 별 고객의 비율
select yearweek,
	round(cart_user/ view_user* 100, 1) as cart_ratio,
    round(paid_user/ view_user* 100, 1) as pay_ratio
from
	(select yearweek(event_time) as yearweek,
		count(distinct case when event_type= 'view' then user_id else null end) as view_user,
		count(distinct case when event_type= 'cart' then user_id else null end) as cart_user,
		count(distinct case when event_type= 'purchase' then user_id else null end) as paid_user
	from event
	where yearweek(event_time) in ('202048', '202049')
	group by 1) as a;