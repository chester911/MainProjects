use retail_log;

select count(*)
from retail;

select *
from retail
limit 100;

# 월별 고객 수, 매출 증가율
select ym,
	cust_cnt,
    (cust_cnt- lag(cust_cnt, 1) over(order by ym))/ cust_cnt* 100 as cust_increase_ratio,
    rev,
    (rev- lag(rev, 1) over(order by ym))/ rev* 100 as rev_increase_ratio
from
	(select substr(invoiceDate, 1, 7) as ym,
		count(distinct customerId) as cust_cnt,
		sum(quantity* unitPrice) as rev
	from retail
	group by 1
	order by 1) as a;

# 2011년 7월 국가별 고객 수, 매출
select country,
	count(distinct customerId) as cust_cnt,
    count(distinct invoiceNo) as order_cnt,
    sum(quantity* unitPrice) as rev
from retail
where substr(invoiceDate, 1, 7)= '2011-07'
group by 1
order by 4 desc;

# 상품별 고객 수, 매출
select stockCode,
	description,
    count(distinct customerId) as cust_cnt,
    count(distinct invoiceNo) as order_cnt,
    sum(quantity* unitPrice) as rev
from retail
where substr(invoiceDate, 1, 7)= '2011-07'
group by 1
order by 5 desc;

select sum(quantity* unitPrice) as rev
from retail
where substr(invoiceDate, 1, 7)= '2011-07';

# 기존, 신규 고객
-- 고객 별 첫 구매 일자
with first_orders as
(select customerId,
	min(substr(invoiceDate, 1, 10)) as first_order
from retail
group by 1)
-- 기존 / 신규 고객 수, 매출 비율
select user_type,
	count(distinct customerId)/ (select count(distinct customerId)
								from retail
                                where substr(invoiceDate, 1, 7)= '2011-07')* 100 as user_ratio,
    sum(quantity* unitPrice)/ (select sum(quantity* unitPrice)
							from retail
                            where substr(invoiceDate, 1, 7)= '2011-07')* 100 as rev_ratio
from
	(select a.*,
		case when substr(a.invoiceDate, 1, 7)= substr(b.first_order, 1, 7) then 'new_user'
			else 'old_user'
		end as user_type
	from
		(select customerId,
			invoiceNo,
			invoiceDate,
			quantity,
			unitPrice
		from retail
		where substr(invoiceDate, 1, 7)= '2011-07') as a
		left join first_orders as b
			on a.customerId= b.customerId) as a
group by 1;

# 주요 국가들의 6~7월 매출 비교
select country_type,
	ym,
    (cust_cnt- lag(cust_cnt, 1) over(partition by country_type order by ym))/ cust_cnt* 100 as cust_increase_ratio,
    (rev- lag(rev, 1) over(partition by country_type order by ym))/ rev* 100 as rev_increase_ratio
from
	(select country_type,
		substr(invoiceDate, 1, 7) as ym,
		count(distinct customerId) as cust_cnt,
		sum(quantity* unitPrice) as rev
		from
			(select *,
				case when country in ('United Kingdom', 'Germany', 'France') then 'main_country'
					else 'other_country'
				end as country_type
			from retail
			where substr(invoiceDate, 1, 7) in ('2011-06', '2011-07')) as a
		group by 1, 2
		order by 1, 2) as a;