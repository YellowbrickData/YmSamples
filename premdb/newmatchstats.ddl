drop table newmatchstats;

create table newmatchstats as select seasonid, matchday::date, htid, atid from match order by 1,2,3,4;

alter table newmatchstats add column moment varchar(5);

update newmatchstats set moment='01:00';

deallocate moment;

prepare moment(varchar(5)) as insert into newmatchstats select seasonid,matchday,htid,atid,$1 from match;

execute moment('02:00');

execute moment('03:00');

execute moment('04:00');

execute moment('05:00');

execute moment('06:00');

execute moment('07:00');

execute moment('08:00');

execute moment('09:00');

execute moment('10:00');

execute moment('11:00');

execute moment('12:00');

execute moment('13:00');

execute moment('14:00');

execute moment('15:00');

execute moment('16:00');

execute moment('17:00');

execute moment('18:00');

execute moment('19:00');

execute moment('20:00');

execute moment('21:00');

execute moment('22:00');

execute moment('23:00');

execute moment('24:00');

execute moment('25:00');

execute moment('26:00');

execute moment('27:00');

execute moment('28:00');

execute moment('29:00');

execute moment('30:00');

execute moment('31:00');

execute moment('32:00');

execute moment('33:00');

execute moment('34:00');

execute moment('35:00');

execute moment('36:00');

execute moment('37:00');

execute moment('38:00');

execute moment('39:00');

execute moment('40:00');

execute moment('41:00');

execute moment('42:00');

execute moment('43:00');

execute moment('44:00');

execute moment('45:00');

execute moment('46:00');

execute moment('47:00');

execute moment('48:00');

execute moment('49:00');

execute moment('50:00');

execute moment('51:00');

execute moment('52:00');

execute moment('53:00');

execute moment('54:00');

execute moment('55:00');

execute moment('56:00');

execute moment('57:00');

execute moment('58:00');

execute moment('59:00');

execute moment('60:00');

execute moment('61:00');

execute moment('62:00');

execute moment('63:00');

execute moment('64:00');

execute moment('65:00');

execute moment('66:00');

execute moment('67:00');

execute moment('68:00');

execute moment('69:00');

execute moment('70:00');

execute moment('71:00');

execute moment('72:00');

execute moment('73:00');

execute moment('74:00');

execute moment('75:00');

execute moment('76:00');

execute moment('77:00');

execute moment('78:00');

execute moment('79:00');

execute moment('80:00');

execute moment('81:00');

execute moment('82:00');

execute moment('83:00');

execute moment('84:00');

execute moment('85:00');

execute moment('86:00');

execute moment('87:00');

execute moment('88:00');

execute moment('89:00');

execute moment('90:00');

grant select on newmatchstats to bobr;

grant insert on newmatchstats to bobr;


