select *
from shoes_sales.history
limit 100;

select *
from shoes_sales.nike;

select *
from shoes_sales.yeezy;

alter table shoes_sales.history change `癤풭rder Date` `Order_Date` text;
alter table shoes_sales.history change `Buyer Region` `Buyer_Region` text;

alter table shoes_sales.nike change `癤풺rand` `Brand` text;

alter table shoes_sales.yeezy change `癤풟rand` `Brand` text;

# datetime format
update shoes_sales.history set order_date= str_to_date(order_date, '%m/%d/%Y');

update shoes_sales.yeezy set `Order`= substr(str_to_date(`Order`, '%d-%M'), 6, 10);
alter table shoes_sales.yeezy change `Order` `Order_Date` text;

# sale, retail
update shoes_sales.history set `Sale`= replace(sale, ',', '');

update shoes_sales.yeezy set `Sale`= replace(sale, '$', '');
update shoes_sales.yeezy set `Retail`= replace(retail, '$', '');

# nike sales : add date column
alter table shoes_sales.history add `date` text;
update shoes_sales.history set `date`= substr(order_date, 6, 10);

select *
from shoes_sales.yeezy;

select *
from shoes_sales.history;