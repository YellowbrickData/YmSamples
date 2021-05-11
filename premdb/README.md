# Premier League Data

This small data set contains 5 tables with actual scores from English Premier League football matches, spanning about twenty seasons from 1992-1993 to 2013-2014. These tables are used extensively in the main Yellowbrick documentation to provide simple, reproducible examples of SQL commands and functions.

### Source

 * S3 Bucket: https://s3.console.aws.amazon.com/s3/buckets/yb-sampledata-d4f1c23ea7

### Scripts

* `premdb_testdrive.ddl`: creates and loads five premdb tables
* `newmatchstats.ddl`: creates the newmatchstats table
* `queries/*.sql`: a few queries that you can run
* 
### Tables

 1. **match:** Full-time and half-time scores for matches with foreign keys for the season, home team, and away team values
 2. **season:** Season ID, season name, and league winners
 3. **team:** Team name, nickname, home stadium, and other details
 4. **hometeam:** Home team ID and team name, used for joins
 5. **awayteam:** Away team ID and team name, used for joins

An additional table, **newmatchstats**, is available but does not contain meaningful data. It is used in the tutorial to demonstrate a very simple load of 25 million rows. 

### Samples

After loading this sample data set, you can perform analytic queries on the match data. For example:

```sql
select t1.season_name, t1.winners, homegoals+awaygoals as total
from
(select season_name, winners, sum(substr(ftscore,1,1)::int) homegoals
from season, match
where season.seasonid=match.seasonid
group by season_name, winners) t1,
(select season_name, winners, sum(substr(ftscore,3,1)::int) awaygoals
from season, match
where season.seasonid=match.seasonid
group by season_name, winners) t2
where t1.season_name=t2.season_name
order by 1,2;

```
