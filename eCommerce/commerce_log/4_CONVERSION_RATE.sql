# 상품 조회-> 장바구니 추가-> 결제로 이어진 비율
-- 상품 조회 테이블
with view_table as
(select user_id,
	product_id,
    substr(event_time, 1, 10) as view_date
from commerce_log.event
where event_type= 'view'),
-- 장바구니 추가 테이블
cart_table as
(select user_id,
	product_id,
    substr(event_time, 1, 10) as cart_date
from commerce_log.event
where event_type= 'cart'),
-- 결제 테이블
purchase_table as
(select user_id,
	product_id,
    substr(event_time, 1, 10) as purchase_date
from commerce_log.event
where event_type= 'purchase')

select substr(a.view_date, 1, 7) as ym,
	count(distinct a.user_id) as view_user,
    count(distinct b.user_id) as cart_user,
    count(distinct c.user_id) as paid_user,
    count(distinct b.user_id)/ count(distinct a.user_id)* 100 as view_to_cart_ratio,
    count(distinct c.user_id)/ count(distinct b.user_id)* 100 as cart_to_purchase_ratio,
    count(distinct b.user_id)/ count(distinct a.user_id)
		* count(distinct c.user_id)/ count(distinct b.user_id)* 100 as view_cart_purchase_ratio
from view_table as a
	left join cart_table as b
		on a.user_id= b.user_id
			and a.product_id= b.product_id
	left join purchase_table as c
		on b.user_id= c.user_id
			and b.product_id= c.product_id
			and a.user_id= c.user_id
			and a.product_id= c.product_id
where substr(a.view_date, 1, 7) in ('2020-10', '2020-11')
group by 1
order by 1;