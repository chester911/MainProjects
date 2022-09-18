use retail_log;

# 최초, 최신 주문일
select min(invoiceDate), max(invoiceDate)
from retail;

# 월별 고객 수, 주문 건수, 총 매출, 1인당 평균 매출
select substr(invoiceDate, 1, 7) as ym,
	count(distinct customerId) as cust_cnt,
    count(distinct invoiceNo) as order_cnt,
    sum(quantity* unitPrice) as rev_total,
    sum(quantity* unitPrice)/ count(distinct customerId) as ARPPU
from retail
group by 1
order by 1;

# 월별 국가별 고객 수, 총 매출, 1인당 평균 매출
-- 평균 매출 내림차순 정렬
select substr(invoiceDate, 1, 7) as ym,
	country,
    count(distinct customerId) as cust_cnt,
    sum(quantity* unitPrice) as rev_total,
    sum(quantity* unitPrice)/ count(distinct customerId) as ARPPU
from retail
group by 1, 2
order by 1, 5 desc;

# 월별 상품별 주문 고객 수, 매출 순위
select substr(invoiceDate, 1, 7) as ym,
	stockCode,
	description,
    count(distinct customerId) as cust_cnt,
    sum(quantity* unitPrice) as rev_total
from retail
group by 1, 2
order by 1, 5 desc;

# 월별 매출 비교
select ym,
	rev_total/ rev_prev* 100 as rev_ratio,
    arppu/ arppu_prev* 100 as arppu_ratio
from
	(select ym,
		rev_total,
		lag(rev_total, 1) over(order by ym) as rev_prev,
		arppu,
		lag(arppu, 1) over(order by ym) as arppu_prev
	from
		(select substr(invoiceDate, 1, 7) as ym,
			sum(quantity* unitPrice) as rev_total,
			sum(quantity* unitPrice)/ count(distinct customerId) as ARPPU
		from retail
		group by 1
		order by 1) as a) as b;

# 2011년 5월 신규 고객 비율 (첫 구매일이 2011년 5월인 유저)
-- 고객별 첫 주문 일자
with first_orders as
(select customerId,
	min(invoiceDate) as first_order
from retail
group by 1
order by 2)
-- 신규 고객 수, 기존 고객 수
select count(distinct case when a.order_ym= substr(b.first_order, 1, 7) then a.customerId else null end) as new_user,
	count(distinct case when a.order_ym!= substr(b.first_order, 1, 7) then a.customerId else null end) as old_user
from
	(select customerId,
		substr(invoiceDate, 1, 7) as order_ym
	from retail
	where substr(invoiceDate, 1, 7)= '2011-05') as a
	left join first_orders as b
		on a.customerId= b.customerId;

# 2011년 5월 신규 / 기존 고객의 매출
-- 2011년 5월 고객 분류 (기존/ 신규)
with users as
(select distinct a.customerId,
	case when a.order_ym= substr(b.first_order, 1, 7) then 'new_user'
		else 'old_user'
	end as user_type
from
	(select customerId,
		substr(invoiceDate, 1, 7) as order_ym
	from retail
	where substr(invoiceDate, 1, 7)= '2011-05') as a
    left join
		(select customerId,
			min(invoiceDate) as first_order
		from retail
        group by 1) as b
		on a.customerId= b.customerId)

select b.user_type,
	sum(a.quantity* a.unitPrice)/ (select sum(quantity* unitPrice)
									from retail
                                    where substr(invoiceDate, 1, 7)= '2011-05')* 100 as rev
from retail as a
	left join users as b
		on a.customerId= b.customerId
where substr(a.invoiceDate, 1, 7)= '2011-05'
group by 1;

# 대시보드용
-- WAU 파악 가능
select substr(invoiceDate, 1, 7) as ym,
	yearweek(invoiceDate) as yearweek,
    count(distinct customerId) as cust_cnt,
    count(distinct invoiceNo) as order_cnt,
    round(sum(quantity* unitPrice), 1) as rev
from retail
group by 1, 2
order by 1, 2;

# 2011년 4월~5월 국가별 매출 비교
select a.*,
	coalesce(b.rev_may, 0) as rev_may,
    coalesce(round(b.rev_may- a.rev_apr, 1), 0) as rev_diff
from
	(select country,
		sum(quantity* unitPrice) as rev_apr
	from retail
	where substr(invoiceDate, 1, 7)= '2011-04'
	group by 1) as a
    left join
			(select country,
				sum(quantity* unitPrice) as rev_may
			from retail
            where substr(invoiceDate, 1, 7)= '2011-05'
            group by 1) as b
		on a.country= b.country
order by 2;

# 주력 / 비주력 상품들의 매출 비교
-- 1. 주력 상품부터 비교 (주력 상품 = 주문 건수 상위 20위 상품)
-- 4월 주력 상품
with order_rnk_apr as
(select stockCode,
	count(distinct invoiceNo) as order_cnt,
    rank() over(order by count(distinct invoiceNo) desc) as rnk
from retail
where substr(invoiceDate, 1, 7)= '2011-04'
group by 1)

select a.*,
	b.rev_may,
    b.rev_may- a.rev_apr as rev_diff
from
	(select stockCode,
		sum(quantity* unitPrice) as rev_apr
	from retail
	where substr(invoiceDate, 1, 7)= '2011-04'
		and stockCode in (select stockCode
						from order_rnk_apr
						where rnk<= 20)
	group by 1) as a
    left join
			(select stockCode,
				sum(quantity* unitPrice) as rev_may
			from retail
            where substr(invoiceDate, 1, 7)= '2011-05'
            group by 1) as b
		on a.stockCode= b.stockCode
order by 4 desc;

-- 2. 비주력 상품들 주문 고객 수 비교 (주문 건수 10회 미만 상품)
with order_rnk as
(select stockCode,
	count(distinct invoiceNo) as order_cnt
from retail
where substr(invoiceDate, 1, 7)= '2011-04'
group by 1)

select a.*,
	b.cust_may,
    b.cust_may- a.cust_apr as cust_diff
from
	(select stockCode,
		count(distinct customerId) as cust_apr
	from retail
	where substr(invoiceDate, 1, 7)= '2011-04'
		and stockCode in (select stockCode
						from order_rnk
						where order_cnt< 10)
	group by 1) as a
	left join
			(select stockCode,
				count(distinct customerId) as cust_may
			from retail
            where substr(invoiceDate, 1, 7)= '2011-05'
            group by 1) as b
	on a.stockCode= b.stockCode
order by 4 desc;

# 건당 주문 금액, 주문량(개수) 비교
select
	(select sum(quantity* unitPrice)/ count(distinct invoiceNo) as rev_per_order_apr
	from retail
	where substr(invoiceDate, 1, 7)= '2011-04')-
	(select sum(quantity* unitPrice)/ count(distinct invoiceNo) as rev_per_order_may
	from retail
	where substr(invoiceDate, 1, 7)= '2011-05') as rev_per_order_diff;