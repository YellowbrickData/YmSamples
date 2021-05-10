-- the last year's snowfall observations in Virginia
select s.name, o.year_date, count(*)
from noaa_ghcn_pds.observations o
join noaa_ghcn_pds.stations s
on o.id = s.id
where o.year_date >= 1000 * extract(year from current_timestamp)::int
and o.element = 'SNOW'
and s.state = 'VA'
and o.data_value > 0
group by 1, 2
order by 1, 2
