drop database premdb;

create database premdb;

\c premdb

drop table season;
drop table team;
drop table hometeam;
drop table awayteam;
drop table match;

create table season(seasonid smallint, season_name character(9), numteams smallint, winners varchar(30)) distribute replicate;

create table team(teamid smallint, htid smallint, atid smallint, name varchar(30), nickname varchar(20), city varchar(20), stadium varchar(50), capacity int, avg_att dec(5,3)) distribute replicate;

create table hometeam(htid smallint, name varchar(30)) distribute replicate;

create table awayteam(atid smallint, name varchar(30)) distribute replicate;

create table match(seasonid smallint, matchday timestamp, htid smallint, atid smallint, ftscore char(3), htscore char(3)) distribute on(seasonid);

\copy team from '/home/brumsby/newteam.csv' with delimiter ',' null '';

\copy season from '/home/brumsby/season.csv' with delimiter ',' null '';

insert into awayteam select atid,name from team;

insert into hometeam select htid,name from team;

\copy match from '/home/brumsby/match.csv' with delimiter ',' null '';

select count(*) from season;

select count(*) from team;

select count(*) from awayteam;

select count(*) from hometeam;

select count(*) from match;

drop user bobr;

create user bobr with password 'bobr';

grant select on match to bobr;

