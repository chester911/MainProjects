# 장기간 미결제 유저

-- 기준일로부터 2주 이상 차이나면 이탈 유저로 취급
-- 기준일 : 2011-08-01

-- 가장 최근일과 기준일의 차이 (일)
with date_diff as
(select *,
	timestampdiff(week, recent_order, '2011-08-01') as week_diff
from
-- 유저별 최신 주문일
	(select customerId,
		max(substr(invoiceDate, 1, 10)) as recent_order
	from retail_log.retail
	group by 1) as recent_orders),

-- 이탈 고객들
churn_users as
(select distinct customerId
from
-- 이탈, 비이탈 고객 분류
	(select *,
		case when week_diff>= 2 then 'churn'
			else 'non_churn'
		end as churn_type
	from date_diff) as churn_types
where churn_type= 'churn')

-- 유저 코호트별 분포
-- 최초 결제월을 코호트 인덱스로 설정

-- 첫 구매일부터 구매가 얼마나 이어지는지?
select substr(first_order, 1, 7) as ym,
	week_diff,
    count(distinct customerId) as user_cnt
from
-- 첫 주문일과 주문일의 차이 (주)
(select a.customerId,
	b.first_order,
	timestampdiff(week, b.first_order, substr(a.invoiceDate, 1, 10)) as week_diff
from
	(select *
	from retail_log.retail
	where customerId in (select distinct customerId
						from churn_users)) as a
	left join
    -- 이탈 유저의 첫 구매 일자
			(select customerId,
				min(substr(invoiceDate, 1, 10)) as first_order
			from retail_log.retail
            where customerId in (select distinct customerId
								from churn_users)
			group by 1) as b
		on a.customerId= b.customerId) as cohort
group by 1, 2
order by 1, 2;