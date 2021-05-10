select s.name, (o.year_date / 10000)::int, sum(data_value)
from noaa_ghcn_pds.observations o
join noaa_ghcn_pds.stations s
on o.id = s.id
where o.element = 'SNOW'
and s.state = 'UT'
and o.data_value > 0
and (
 s.name like 'COTTONWOOD%'
 or
 s.name like 'PARK CITY%'
)
group by 1, 2
order by 1, 2
