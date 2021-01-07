-- Export MBA catch results by species by length
select a.ship, a.survey, a.data_set_id, a.interval, b.start_time,b.start_latitude, b.start_longitude, b.end_time, b.end_latitude, b.end_longitude, b.mean_bottom_depth, a.layer, a.class, a.species_code, a.length, a.numbers, a.numbers_nm2 
from (select * from analysis_results_by_length where ship = 175 ) a
join 
(select * from intervals where ship = 175) b
on a.ship = b.ship and a.survey = b.survey and a.interval = b.interval