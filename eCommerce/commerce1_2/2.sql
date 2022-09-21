use retail_log;
##### 영국, 프랑스, 독일의 매출을 상승시킬 방안 #####

# 6월 이후 1개월만에 재구매한 고객의 비율
-- 주요 국가 기존 고객 리스트 (고객ID)
with cust_list as
(select customerId
from
	(select distinct a.customerId,
		case when substr(a.invoiceDate, 1, 7)= substr(b.first_order, 1, 7) then 'new_user'
			else 'old_user'
		end as user_type
	from
		(select *
		from retail
		where substr(invoiceDate, 1, 7)= '2011-07') as a
		left join
			(select customerId,
				min(substr(invoiceDate, 1, 10)) as first_order
			from retail
			group by 1) as b
			on a.customerId= b.customerId) as a
where user_type= 'old_user')

select count(distinct b.customerId) as cust_june,
	count(distinct a.customerId) as cust_july,
    round(count(distinct b.customerId)/ count(distinct a.customerId)* 100, 1) as retention_rate
from
	(select *
	from retail
	where substr(invoiceDate, 1, 7)= '2011-07'
		and country in ('United Kingdom', 'France', 'Germany')
		and customerId in (select customerId
						from cust_list)) as a
	left join
		(select *
        from retail
        where substr(invoiceDate, 1, 7)= '2011-06'
			and country in ('United Kingdom', 'France', 'Germany')) as b
		on a.customerId= b.customerId;
        
# 1개월 이후 재구매 고객 vs 2개윌 이상 이후 재구매 고객 평균 매출
with cust_list as
(select customerId
from
	(select distinct a.customerId,
		case when substr(a.invoiceDate, 1, 7)= substr(b.first_order, 1, 7) then 'new_user'
			else 'old_user'
		end as user_type
	from
		(select *
		from retail
		where substr(invoiceDate, 1, 7)= '2011-07') as a
		left join
			(select customerId,
				min(substr(invoiceDate, 1, 10)) as first_order
			from retail
			group by 1) as b
			on a.customerId= b.customerId) as a
where user_type= 'old_user')

select user_type,
	round(sum(quantity* unitPrice)/ count(distinct customerId)* 100, 1) as arppu,
    round(sum(quantity* unitPrice)/ count(distinct invoiceNo)* 100, 1) as rev_per_order
from
	(select a.*,
    -- user_1 : 2개월 이상 지나고 재구매한 고객
    -- user_2 : 1개월 이후에 재구매한 고객
		case when b.customerId is null then 'user_1'
			else 'user_2'
		end as user_type
	from
		(select *
		from retail
		where substr(invoiceDate, 1, 7)= '2011-07'
			and country in ('United Kingdom', 'France', 'Germany')
			and customerId in (select customerId
							from cust_list)) as a
		left join
			(select *
			from retail
			where substr(invoiceDate, 1, 7)= '2011-06'
				and country in ('United Kingdom', 'France', 'Germany')) as b
			on a.customerId= b.customerId) as a
group by 1;

# 직전 월(6월) 구매자들의 7월 주간 방문 수 (평균)
with cust_list as
(select customerId
from
	(select distinct a.customerId,
		case when substr(a.invoiceDate, 1, 7)= substr(b.first_order, 1, 7) then 'new_user'
			else 'old_user'
		end as user_type
	from
		(select *
		from retail
		where substr(invoiceDate, 1, 7)= '2011-07') as a
		left join
			(select customerId,
				min(substr(invoiceDate, 1, 10)) as first_order
			from retail
			group by 1) as b
			on a.customerId= b.customerId) as a
where user_type= 'old_user')

select yearweek,
	count(distinct customerId) as cust_cnt
from
	(select yearweek(a.invoiceDate) as yearweek,
		a.customerId,
		count(distinct a.invoiceNo) as order_cnt
	from
		(select *
		from retail
		where substr(invoiceDate, 1, 7)= '2011-07'
			and country in ('United Kingdom', 'France', 'Germany')
			and customerId in (select customerId
							from cust_list)) as a
		left join
				(select *
				from retail
				where substr(invoiceDate, 1, 7)= '2011-06'
					and country in ('United Kingdom', 'France', 'Germany')) as b
			on a.customerId= b.customerId
	where b.customerId is not null
	group by 1, 2
	order by 1, 3 desc) as a
where order_cnt> 1
group by 1
order by 1;

# 직전 월 구매자들의 평균 매출
with cust_list as
(select customerId
from
	(select distinct a.customerId,
		case when substr(a.invoiceDate, 1, 7)= substr(b.first_order, 1, 7) then 'new_user'
			else 'old_user'
		end as user_type
	from
		(select *
		from retail
		where substr(invoiceDate, 1, 7)= '2011-07') as a
		left join
			(select customerId,
				min(substr(invoiceDate, 1, 10)) as first_order
			from retail
			group by 1) as b
			on a.customerId= b.customerId) as a
where user_type= 'old_user')

select round(sum(b.quantity* b.unitPrice)/ count(distinct b.customerId), 1) as arppu_june,
	round(sum(a.quantity* a.unitPrice)/ count(distinct a.customerId), 1) as arppu_july
from
	(select *
	from retail
	where substr(invoiceDate, 1, 7)= '2011-07'
		and country in ('United Kingdom', 'Germany', 'France')
		and customerId in (select customerId
						from cust_list)) as a
	left join
			(select *
            from retail
            where substr(invoiceDate, 1, 7)= '2011-06'
				and country in ('United Kingdom', 'Germany', 'France')) as b
		on a.customerId= b.customerId
where b.customerId is not null;

# 직전 월 구매자들이 구매한 상품들의 가격
select a.stockCode,
	a.description,
    round(avg(a.unitPrice), 1) as avg_price,
    count(distinct a.customerId) as cust_cnt,
    count(distinct a.invoiceNo) as order_cnt
from
(select *
from retail
where substr(invoiceDate, 1, 7)= '2011-07'
	and country in ('United Kingdom', 'France', 'Germany')
    and customerId in
-- 영국, 프랑스, 독일의 7월 고객 중 기존 고객들
			(select distinct a.customerId
			from
				(select customerId,
					invoiceDate
				from retail
				where substr(invoiceDate, 1, 7)= '2011-07'
					and country in ('United Kingdom', 'France', 'Germany')) as a
				left join
						(select customerId,
							min(substr(invoiceDate, 1, 10)) as first_order
						from retail
						group by 1) as b
					on a.customerId= b.customerId
			where substr(a.invoiceDate, 1, 7)!= substr(b.first_order, 1, 7))) as a
	left join
			(select *
            from retail
            where substr(invoiceDate, 1, 7)= '2011-06'
				and country in ('United Kingdom', 'France', 'Germany')) as b
		on a.customerId= b.customerId
where b.customerId is not null
group by 1
order by 4 desc, 5 desc;

# 상품 가격대 별 고객 수
with users_table as
(select a.*
from
(select *
from retail
where substr(invoiceDate, 1, 7)= '2011-07'
	and country in ('United Kingdom', 'France', 'Germany')
    and customerId in
-- 영국, 프랑스, 독일의 7월 고객 중 기존 고객들
			(select distinct a.customerId
			from
				(select customerId,
					invoiceDate
				from retail
				where substr(invoiceDate, 1, 7)= '2011-07'
					and country in ('United Kingdom', 'France', 'Germany')) as a
				left join
						(select customerId,
							min(substr(invoiceDate, 1, 10)) as first_order
						from retail
						group by 1) as b
					on a.customerId= b.customerId
			where substr(a.invoiceDate, 1, 7)!= substr(b.first_order, 1, 7))) as a
	left join
			(select *
            from retail
            where substr(invoiceDate, 1, 7)= '2011-06'
				and country in ('United Kingdom', 'France', 'Germany')) as b
		on a.customerId= b.customerId
where b.customerId is not null)
-- 0~10 : 저가 상품 / 11~50 : 중저가 상품 / 50~100 : 고가 상품 / 100~ : 최고가 상품
select case when unitPrice between 0 and 10 then 'low_price'
			when unitPrice between 11 and 50 then 'mid_low_price'
            when unitPrice between 51 and 100 then 'high_price'
			else 'max_price'
		end as price_bin,
        count(distinct customerId) as cust_cnt
from users_table
group by 1
order by field(price_bin, 'low_price', 'mid_low_price', 'high_price', 'max_price');

# 매출을 구간화해서 집계
with users_table as
(select a.*
from
(select *
from retail
where substr(invoiceDate, 1, 7)= '2011-07'
	and country in ('United Kingdom', 'France', 'Germany')
    and customerId in
-- 영국, 프랑스, 독일의 7월 고객 중 기존 고객들
			(select distinct a.customerId
			from
				(select customerId,
					invoiceDate
				from retail
				where substr(invoiceDate, 1, 7)= '2011-07'
					and country in ('United Kingdom', 'France', 'Germany')) as a
				left join
						(select customerId,
							min(substr(invoiceDate, 1, 10)) as first_order
						from retail
						group by 1) as b
					on a.customerId= b.customerId
			where substr(a.invoiceDate, 1, 7)!= substr(b.first_order, 1, 7))) as a
	left join
			(select *
            from retail
            where substr(invoiceDate, 1, 7)= '2011-06'
				and country in ('United Kingdom', 'France', 'Germany')) as b
		on a.customerId= b.customerId
where b.customerId is not null)
-- 0~10 / 11~50 / 51~100 / 100~500/ 501~1000/ 1001~
select case when quantity* unitPrice between 0 and 10 then 'cust_1'
			when quantity* unitPrice between 11 and 50 then 'cust_2'
            when quantity* unitPrice between 51 and 100 then 'cust_3'
            when quantity* unitPrice between 101 and 500 then 'cust_4'
            when quantity* unitPrice between 501 and 1000 then 'cust_5'
            else 'cust_6'
		end as rev_bin,
        count(distinct customerId) as cust_cnt
from users_table
group by 1;