##### 날짜 수가 적은 9월, 12월 데이터는 제외 #####

# 1. 사용자 수와 매출은 매 월 증가하고 있나?
select substr(date, 1, 7) as ym,
	count(distinct user_id) as mau,
    count(distinct case when event_type= 'purchase' then user_id else null end) as paid_users,
    sum(case when event_type= 'purchase' then price else 0 end) as rev_total
from
	(select substr(event_time, 1, 10) as date,
		event_type,
        price,
        user_id
	from commerce_log.event
    where month(event_time) not in (9, 12)) as a
group by 1
order by 1;
-- 전체 고객 수, 구매 고객 수, 매출 모두 증가함

# 2. 상품 조회 -> 장바구니 추가 -> 구매로 이어진 비율은 증가했을까?
with user_events as
(select *
from
	(select date(event_time) as date,
		event_type,
        user_id
	from commerce_log.event
    where month(event_time) not in (9, 12)) as a)
    
select substr(a.date, 1, 7) as ym,
    round(count(distinct b.user_id)/ count(distinct a.user_id)* 100, 1) as view_to_cart_ratio,
    round(count(distinct c.user_id)/ count(distinct b.user_id)* 100, 1) as cart_to_pay_ratio
from
	-- 상품을 조회한 고객
	(select *
    from user_events
    where event_type= 'view') as a
    -- 상품을 장바구니에 추가한 고객
    left join
			(select *
            from user_events
            where event_type= 'cart') as b
		on a.user_id= b.user_id
	-- 상품을 구매한 고객
	left join
			(select *
			from user_events
			where event_type= 'purchase') as c
		on b.user_id= c.user_id
			and a.user_id= c.user_id
group by 1
order by 1;
-- 상품 조회 이후 장바구니에 추가하는 고객은 10% 미만으로 매우 적음
-- 상품을 장바구니에 추가한 고객 중 절반 이상은 결제함
-- 조회 -> 장바구니, 장바구니 -> 결제에 이르는 고객의 비율 모두 증가함

# 2-1. 조회 후 바로 결제하는 고객의 비율은?
with user_events as
(select *
from
	(select date(event_time) as date,
		event_type,
        user_id
	from commerce_log.event
    where month(event_time) not in (9, 12)) as a)

select substr(a.date, 1, 7) as ym,
	round(count(distinct b.user_id)/ count(distinct a.user_id)* 100, 1) as view_to_pay_ratio
from
	(select *
    from user_events
    where event_type= 'view') as a
    left join
			(select *
			from user_events
			where event_type= 'purchase') as b
		on a.user_id= b.user_id
group by 1
order by 1;
-- 상품 조회 후 바로 결제하는 고개의 비율은 매우 낮음
-- 바로 구매하는 고객의 비율 역시 증가함