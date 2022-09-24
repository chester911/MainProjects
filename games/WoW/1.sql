# 컬럼명 전처리
-- 앞 공백 제거
alter table wow.history change `char` `user_id` int;
alter table wow.history change ` level` `level` int;
alter table wow.history change ` race` `race` varchar(50);
alter table wow.history change ` charclass` `charclass` varchar(50);
alter table wow.history change ` zone` `zone` varchar(50);
alter table wow.history change ` guild` `guild` int;
alter table wow.history change ` timestamp` `timestamp` varchar(50);

-- 유저 최초, 최신 활동 일자 확인
select min(timestamp), max(timestamp)
from wow.history;
-- 2008년 1월 1일 ~ 2008년 12월 31일

# 시간 전처리
-- YYYY-MM-DD hh:mm
update wow.history set `timestamp`= str_to_date(timestamp, '%m/%d/%Y %H:%i:%s');

select *
from wow.history
limit 100;