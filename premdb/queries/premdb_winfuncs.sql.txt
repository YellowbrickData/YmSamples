select s.winners, season_name, ftscore, SUM(SUBSTR(ftscore,3,1)::INT) over(partition by season_name, winners),
AVG(SUBSTR(ftscore,3,1)::INT) over(partition by season_name, winners),
COUNT(SUBSTR(ftscore,3,1)::INT) over(partition by season_name, winners)
from awayteam a, hometeam h, season s, match m, team t
where a.atid=m.atid and h.htid=m.htid and s.seasonid=m.seasonid and t.name=s.winners and 
m.ftscore in('0-0','1-1','2-2','3-3','4-4','5-5','6-6','7-7','8-8','9-9')
and s.season_name in(select season_name from season where numteams=20)
and m.matchday between '1996-12-31' and current_date
and a.atid>70
and h.htid<30
group by s.winners, season_name, ftscore
order by s.winners, season_name, ftscore;