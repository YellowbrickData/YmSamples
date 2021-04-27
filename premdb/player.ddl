
drop table player;

create table player(
playerid bigint not null,
teamid smallint not null,
seasonid smallint not null,
firstname varchar(30),
lastname varchar(30),
position char(1),
dob date,
weekly_wages integer,
avg_mins_per_match double precision,
matches_played real,
cob varchar(30));

insert into player values(1,2,27);

insert into player values(2,41,27,'Harry','Kane','F','07-28-1993',250000,84.1567,36.1,'England');

insert into player values(3,41,27,'Harry','Winks','M','02-02-1996',40000,72.3412,31.2,'England');

insert into player values(4,24,27,'Kevin','De Bruyne','M','06-28-1991',418000,86.0981,35.3,'Netherlands');

insert into player values(5,25,27,'Paul','Pogba','M','03-15-1993',378000,76.5341,29.4,'France');

insert into player values(6,25,27,'Alexis','Sanchez','F','12-19-1988',410000,71.2309,31.5,'Chile');

insert into player values(7,13,27,'Gonzalo','Higuain','F','12-10-1987',352000,61.9803,26.6,'Argentina');

insert into player values(8,1,27,'Mesut','Ozil','M','10-15-1988',350000,64.4561,32.7,'Germany');

insert into player values(9,13,27,'Eden','Hazard','M','01-07-1991',200000,81.2387,36.8,'Netherlands');

insert into player values(10,24,27,'Sergio','Aguero','F','06-02-1988',220000,80.0032,33.9,'Argentina');

insert into player values(11,25,27,'Romelu','Lukaku','M','05-13-1993',250000,85.1897,34.0,'Belgium');

insert into player values(12,25,27,'David','de Gea','G','11-07-1990',200000,88.5764,35.1,'Spain');

insert into player values(13,23,27,'Mo','Salah','F','06-15-1992',200000,82.2765,36.2,'Egypt');

insert into player values(14,24,27,'Riyad','Mahrez','M','02-21-1991',200000,55.1908,24.3,'Algeria');

insert into player values(15,23,27,'Virgil','Van Dijk','D','07-08-1991',180000,87.6345,37.4,'Netherlands');

insert into player values(16,24,27,'David','Silva','M','01-08-1986',250000,79.6723,30.5,'Spain');

insert into player values(17,22,27,'Jamie','Vardy','F','01-11-1987',80000,77.1986,31.6,'England');

insert into player values(18,41,27,'Dele','Alli','M','04-11-1996',100000,75.9013,30.7,'England');

insert into player values(19,41,27,'Marcus','Rashford','F','10-31-1997',250000,79.9912,32.8,'England');

insert into player values(20,47,27);


WITH 3 ENCRYPTED COLS:

drop table player;

create table player(
playerid bigint not null,
teamid smallint not null,
seasonid smallint not null,
firstname varchar(30),
lastname varchar(30),
position char(1),
dob varchar(10) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_128_OFB'),
weekly_wages varchar(8) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_128_OFB'),
avg_mins_per_match double precision,
matches_played real,
cob varchar(30) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_128_OFB'));

WITH DETERMINISTIC:

drop table player;

create table player(
playerid bigint not null,
teamid smallint not null,
seasonid smallint not null,
firstname varchar(30),
lastname varchar(30),
position char(1),
dob varchar(10) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=DETERMINISTIC,ALGORITHM = 'AES_128_OFB'),
weekly_wages varchar(8) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE= DETERMINISTIC,ALGORITHM = 'AES_128_OFB'),
avg_mins_per_match double precision,
matches_played real,
cob varchar(30) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE= DETERMINISTIC,ALGORITHM = 'AES_128_OFB'));


WITH DETERMINISTIC and larger VARCHARs:

drop table player;

create table player(
playerid bigint not null,
teamid smallint not null,
seasonid smallint not null,
firstname varchar(30),
lastname varchar(30),
position char(1),
dob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=DETERMINISTIC,ALGORITHM = 'AES_128_OFB'),
weekly_wages varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE= DETERMINISTIC,ALGORITHM = 'AES_128_OFB'),
avg_mins_per_match double precision,
matches_played real,
cob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE= DETERMINISTIC,ALGORITHM = 'AES_128_OFB'));

WITH DETERMINISTIC, AES_192_OFB, and larger VARCHARs:

drop table player;

create table player(
playerid bigint not null,
teamid smallint not null,
seasonid smallint not null,
firstname varchar(30),
lastname varchar(30),
position char(1),
dob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=DETERMINISTIC,ALGORITHM = 'AES_192_OFB'),
weekly_wages varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE= DETERMINISTIC,ALGORITHM = 'AES_192_OFB'),
avg_mins_per_match double precision,
matches_played real,
cob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE= DETERMINISTIC,ALGORITHM = 'AES_192_OFB'));

WITH DETERMINISTIC, AES_256_OFB, and larger VARCHARs:

drop table player;

create table player(
playerid bigint not null,
teamid smallint not null,
seasonid smallint not null,
firstname varchar(30),
lastname varchar(30),
position char(1),
dob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=DETERMINISTIC,ALGORITHM = 'AES_256_OFB'),
weekly_wages varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE= DETERMINISTIC,ALGORITHM = 'AES_256_OFB'),
avg_mins_per_match double precision,
matches_played real,
cob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE= DETERMINISTIC,ALGORITHM = 'AES_256_OFB'));


WITH RANDOMIZED and larger VARCHARs:

drop table player;

create table player(
playerid bigint not null,
teamid smallint not null,
seasonid smallint not null,
firstname varchar(30),
lastname varchar(30),
position char(1),
dob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_128_OFB'),
weekly_wages varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_128_OFB'),
avg_mins_per_match double precision,
matches_played real,
cob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_128_OFB'));

WITH RANDOMIZED, AES_192_OFB, and larger VARCHARs:

drop table player;

create table player(
playerid bigint not null,
teamid smallint not null,
seasonid smallint not null,
firstname varchar(30),
lastname varchar(30),
position char(1),
dob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_192_OFB'),
weekly_wages varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_192_OFB'),
avg_mins_per_match double precision,
matches_played real,
cob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_192_OFB'));

WITH RANDOMIZED, AES_256_OFB, and larger VARCHARs:

drop table player;

create table player(
playerid bigint not null,
teamid smallint not null,
seasonid smallint not null,
firstname varchar(30),
lastname varchar(30),
position char(1),
dob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_256_OFB'),
weekly_wages varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE= RANDOMIZED,ALGORITHM = 'AES_256_OFB'),
avg_mins_per_match double precision,
matches_played real,
cob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_256_OFB'));

MIX ALGORITHMS for the encrypted columns, include a default:

drop table player;

create table player(
playerid bigint not null,
teamid smallint not null,
seasonid smallint not null,
firstname varchar(30),
lastname varchar(30),
position char(1),
dob varchar(100) default '01-01-1990' encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_256_OFB'),
weekly_wages varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=DETERMINISTIC,ALGORITHM = 'AES_128_OFB'),
avg_mins_per_match double precision,
matches_played real,
cob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_192_OFB'));


create table newplayer(
playerid bigint not null,
teamid smallint not null,
seasonid smallint not null,
firstname varchar(30),
lastname varchar(30),
position char(1),
dob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_256_OFB'),
weekly_wages varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=DETERMINISTIC,ALGORITHM = 'AES_128_OFB'),
avg_mins_per_match double precision,
matches_played real,
cob varchar(100) encrypted with(COLUMN_ENCRYPTION_KEY=playerkey,ENCRYPTION_TYPE=RANDOMIZED,ALGORITHM = 'AES_192_OFB'));


5,25,27,Paul,Pogba,M,03-15-1993,378000,76.5341,29.4,France
6,25,27,Alexis,Sanchez,F,12-19-1988,410000,71.2309,31.5,Chile
7,13,27,Gonzalo,Higuain,F,12-10-1987,352000,61.9803,26.6,Argentina
8,1,27,Mesut,Ozil,M,10-15-1988,350000,64.4561,32.7,Germany
9,13,27,Eden,Hazard,M,01-07-1991,200000,81.2387,36.8,Netherlands
10,24,27,Sergio,Aguero,F,06-02-1988,220000,80.0032,33.9,Argentina
11,25,27,Romelu,Lukaku,M,05-13-1993,250000,85.1897,34.0,Belgium
12,25,27,David,de Gea,G,11-07-1990,200000,88.5764,35.1,Spain
13,23,27,Mo,Salah,F,06-15-1992,200000,82.2765,36.2,Egypt
14,24,27,Riyad,Mahrez,M,02-21-1991,200000,55.1908,24.3,Algeria
15,23,27,Virgil,Van Dijk,D,07-08-1991,180000,87.6345,37.4,Netherlands
16,24,27,David,Silva,M,01-08-1986,250000,79.6723,30.5,Spain
17,22,27,Jamie,Vardy,F,01-11-1987,80000,77.1986,31.6,England
18,41,27,Dele,Alli,M,04-11-1996,100000,75.9013,30.7,England
19,41,27,Marcus,Rashford,F,10-31-1997,250000,79.9912,32.8,England
20,47,27,,,,,,,,

