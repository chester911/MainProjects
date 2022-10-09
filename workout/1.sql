select *
from weight_lifting.workout_1
limit 100;

select yearweek(substr(date, 1, 10)) as yearweek,
	count(distinct substr(date, 1, 10)) as workout_days,
    count(distinct `Exercise Name`) as workouts
from weight_lifting.workout_1
group by 1
order by 1;