select *, (total_goals/380.00)::dec(3,2) as goals_per_match
from (
select season_name, 
sum(substr(ftscore,1,1)::int)+sum(substr(ftscore,3,1)::int) total_goals
from season, match 
where season.seasonid=match.seasonid and season.seasonid>=4
group by season_name
) t1 
order by 1;