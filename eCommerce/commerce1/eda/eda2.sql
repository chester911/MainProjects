###	문제	###

# 1. 기존 고객을 유지하기 위한 방안은?

-- 월별 기존 / 신규 고객

-- 고객별 첫 주문 일자
with first_orders as
(select customerId,
	min(substr(invoiceDate, 1, 10)) as first_order
from retail
group by 1),
-- 월별 기존, 신규 고객 수
user_type_cnt as
(select substr(a.order_date, 1, 7) as ym,
	count(distinct case when substr(a.order_date, 1, 7)= substr(b.first_order, 1, 7) then a.customerId else null end) as new_users,
    count(distinct case when substr(a.order_date, 1, 7)!= substr(b.first_order, 1, 7) then a.customerId else null end) as old_users
from
	(select customerId,
		substr(invoiceDate, 1, 10) as order_date
	from retail) as a
    left join first_orders as b
		on a.customerId= b.customerId
group by 1
order by 1)
-- 월별 기존 고객 증가율
select ym,
	(old_users-
    lag(old_users, 1) over(order by ym))/ old_users* 100 as increase_ratio
from user_type_cnt;
-- 2011년 5월의 기존 고객을 중심으로 추출

# 5월 기존 고객들이 구매한 상품들
-- 2011년 5월 기존 고객
with cust_may as
(select *
from retail
where substr(invoiceDate, 1, 7)= '2011-05'
	and customerId not in (select customerId
						from
							(select customerId,
								min(substr(invoiceDate, 1, 10)) as first_order
							from retail
                            group by 1) as a
						where substr(first_order, 1, 7)= '2011-05')),

-- 기존 고객들이 주문한 상품
-- 고객 수, 주문 건수 집계
-- 상위 10개 상품들
product_status as
(select stockCode,
	count(distinct customerId) as cust_cnt,
    count(distinct invoiceNo) as order_cnt,
    count(distinct invoiceNo)/ count(distinct customerId) as order_per_cust
from cust_may
group by 1
order by 2 desc
limit 10)

-- 이 상품들의 가격
select distinct stockCode,
	description,
	unitPrice
from cust_may
where stockCode in (select stockCode
				from product_status)
order by 3 desc;
-- 2만원 이하의 제품을 많이 구매함
-- 케이크 스탠드, 깃발 등 장식품을 주로 구매함

# 기존 고객들의 주문 1회당 평균 결제 금액?
-- 1주일 단위로 집계
select yearweek(invoiceDate) as yearweek,
	count(distinct customerId) as old_user_cnt,
    count(distinct invoiceNo) as order_cnt,
    round(sum(quantity* unitPrice), 1) as rev_total,
    round(sum(quantity* unitPrice)/ count(distinct customerId), 1) as ARPPU,
    round(sum(quantity* unitPrice)/ count(distinct invoiceNo), 1) as rev_per_order
from
	(select *
	from retail
	where substr(invoiceDate, 1, 7)= '2011-05'
		and customerId not in (select customerId
							from
								(select customerId,
									min(substr(invoiceDate, 1, 10)) as first_order
								from retail
								group by 1) as a
							where substr(first_order, 1, 7)= '2011-05')) as a
group by 1
order by 1;

# 2011년 20주차 고객들
-- 구매 횟수가 많은 고객
-- 구매 횟수 3회 이상 고객들이 많이 찾은 상품 (상품별 구매 고객수, 주문 건수)
select stockCode,
	description,
    count(distinct customerId) as cust_cnt,
    count(distinct invoiceNo) as order_cnt,
    round(count(distinct invoiceNo)/ count(distinct customerId), 1) as order_per_cust
from retail
where yearweek(invoiceDate)= '201120'
	and customerId in (select customerId
					from
                    -- 구매 횟수 3회 이상 고객들
						(select distinct customerId,
							count(distinct invoiceNo) as order_cnt
						from retail
						where yearweek(invoiceDate)= '201120'
							and customerId not in (select customerId
												from
													(select customerId,
														min(invoiceDate) as first_order
													from retail
													group by 1) as a
												where substr(first_order, 1, 7)= '2011-05')
						group by 1) as a
                        where order_cnt>= 3)
group by 1
order by 3 desc;

# 2. 신규 고객을 유치하기 위한 방안은?

# 3. 구매가 저조한 국가의 구매를 늘리기 위한 방안은?