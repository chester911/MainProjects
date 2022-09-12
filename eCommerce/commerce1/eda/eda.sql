use onlineretail;

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
	rev_total/ rev_prev* 100 as rev_increased,
    arppu/ arppu_prev* 100 as arppu_increased
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