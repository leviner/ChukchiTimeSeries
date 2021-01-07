-- Export MBA integration results by interval by layer
select a.ship, a.survey, a.data_set_id, a.interval, b.start_time,b.start_latitude, b.start_longitude, b.end_time, b.end_latitude, b.end_longitude, b.mean_bottom_depth, a.layer, a.class, a.prc_nasc, a.sv_max 
from (select * from integration_results where ship = 175 ) a
join 
(select * from intervals where ship = 175) b
on a.ship = b.ship and a.survey = b.survey and a.interval = b.interval
