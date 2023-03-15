drop schema if exists premdb cascade;
create schema if not exists premdb;
grant all on schema premdb to public;
grant usage on schema premdb to public;
set schema 'premdb';

drop table if exists season, team, hometeam, awayteam, match;

drop external storage if exists premdbs3 cascade;
drop external format if exists premdbs3format;
drop external location if exists premdbs3data;

create table season(seasonid smallint, season_name character(9), numteams smallint, winners varchar(30)) distribute replicate;

create table team(teamid smallint, htid smallint, atid smallint, name varchar(30), nickname varchar(20), city varchar(20), stadium varchar(50), capacity int, avg_att dec(5,3)) distribute replicate;

create table hometeam(htid smallint, name varchar(30)) distribute replicate;

create table awayteam(atid smallint, name varchar(30)) distribute replicate;

create table match(seasonid smallint, matchday timestamp, htid smallint, atid smallint, ftscore char(3), htscore char(3)) distribute on(seasonid);

insert into season values
(1,'1992-1993',22,'Manchester United'),
(2,'1993-1994',22,'Manchester United'),
(3,'1994-1995',22,'Blackburn Rovers'),
(4,'1995-1996',20,'Manchester United'),
(5,'1996-1997',20,'Manchester United'),
(6,'1997-1998',20,'Arsenal'),
(7,'1998-1999',20,'Manchester United'),
(8,'1999-2000',20,'Manchester United'),
(9,'2000-2001',20,'Manchester United'),
(10,'2001-2002',20,'Arsenal'),
(11,'2002-2003',20,'Manchester United'),
(12,'2003-2004',20,'Arsenal'),
(13,'2004-2005',20,'Chelsea'),
(14,'2005-2006',20,'Chelsea'),
(15,'2006-2007',20,'Manchester United'),
(16,'2007-2008',20,'Manchester United'),
(17,'2008-2009',20,'Manchester United'),
(18,'2009-2010',20,'Chelsea'),
(19,'2010-2011',20,'Manchester United'),
(20,'2011-2012',20,'Manchester City'),
(21,'2012-2013',20,'Manchester United'),
(22,'2013-2014',20,'Manchester City'),
(23,'2014-2015',20,'Chelsea'),
(24,'2015-2016',20,'Leicester City'),
(25,'2016-2017',20,null);

create external storage premdbs3
type S3 
endpoint 'https://s3.us-west-2.amazonaws.com'
region 'us-west-2'
identity ''
credential '';

create external format premdbs3format 
type csv 
with (skip_blank_lines true, delimiter ',');

create external location premdbs3data 
path 'yb-sampledata-d4f1c23ea7'
external storage premdbs3
external format premdbs3format;

load table team 
from ('/premdb/newteam.csv') 
external location premdbs3data;

insert into awayteam select atid,name from team;

insert into hometeam select htid,name from team;

load table match 
from ('/premdb/match.csv') 
external location premdbs3data;

select count(*) from season;

select count(*) from team;

select count(*) from awayteam;

select count(*) from hometeam;

select count(*) from match;
