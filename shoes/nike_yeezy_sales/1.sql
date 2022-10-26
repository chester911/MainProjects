-- 나이키 : 1월 15일 ~ 1월 21일
select distinct order_date
from shoes_sales.history;

select count(distinct brand) as brands,
	count(distinct sneaker) as sneakers,
    count(distinct buyer_region) as regions
from shoes_sales.history;

select distinct brand
from shoes_sales.history;

select *
from shoes_sales.nike;

-- 이지 : 1월 15일 ~ 1월 22일
select distinct order_date
from shoes_sales.yeezy;

select *
from shoes_sales.history;

select *
from shoes_sales.yeezy;

(select date,
	brand,
    sneaker,
    sale,
    retail,
    profit,
    profitpercent
from shoes_sales.history)
union
(select order_date as date,
	brand,
    sneaker,
    sale,
    retail,
    sale- retail as profit,
    (sale- retail)/ retail* 100 as profitpercent
from shoes_sales.yeezy);

select count(*)
from shoes_sales.history;

select count(*)
from shoes_sales.yeezy;