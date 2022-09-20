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