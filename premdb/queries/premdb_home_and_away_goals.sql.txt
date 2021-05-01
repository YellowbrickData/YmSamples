select a.name, homegoals, awaygoals, 
homegoals+awaygoals as goals_for
from 
(select t1.name, sum(substr(ftscore,1,1)::int) 
from match m1, team t1, season s1
where (m1.htid=t1.htid and m1.seasonid=s1.seasonid)
and season_name='2003-2004'
group by t1.name order by 2 desc) as a(name,homegoals),
(select t2.name, sum(substr(ftscore,3,1)::int) 
from match m2, team t2, season s2
where (m2.atid=t2.atid and m2.seasonid=s2.seasonid)
and season_name='2003-2004'
group by t2.name) as b(name,awaygoals)
where a.name=b.name
order by 4 desc;