# NOAA GHCN-D

This dataset contains weather observations for over 200 years of a large number
of land-based weather measurement stations, with data provided by Amazon
from the [Registry of Open Data on AWS (RODA)](https://registry.opendata.aws/noaa-ghcn/);

### Source

 * Website: https://registry.opendata.aws/noaa-ghcn/
 * Readme: https://docs.opendata.aws/noaa-ghcn-pds/readme.html

### Tables

 1. **noaa_ghcn_pds.observations** Weather observations
 2. **noaa_ghcn_pds.stations** Weather stations
 3. **noaa_ghcn_pds.countries** Country locations for weather stations
 4. **noaa_ghcn_pds.states** State locations for weather stations


### References
 - https://medium.com/google-cloud/explore-visualize-200-years-of-global-temperature-using-apache-spark-bigquery-and-google-data-699ed8b3c67


### Samples

Here is a sample query that shows the days it snowed in virginia during the
last year by different observation points.

``` sql
select s.name, o.year_date, count(*)
from noaa_ghcn_pds.observations o
join noaa_ghcn_pds.stations s
on o.id = s.id
where o.year_date >= 10000 * extract(year from current_timestamp)::int
and o.element = 'SNOW'
and s.state = 'VA'
and o.data_value > 0
group by 1, 2
order by 1, 2
```

Another sample, inspired and derived from this [blog article](https://medium.com/google-cloud/explore-visualize-200-years-of-global-temperature-using-apache-spark-bigquery-and-google-data-699ed8b3c67),
showing the warmest days for each state for 2020:

``` sql
SELECT station_id, (((max_temp::float / 10) * 9 ) / 5) + 32 as max_temp_f, year_date, state, station_name
FROM (
  SELECT s.id AS station_id, max_temp, year_date, s.state, s.name AS station_name,
  ROW_NUMBER() OVER(PARTITION BY s.state ORDER BY max_temp DESC) rn
  FROM (
    -- max temp of each date
    SELECT id, year_date, MAX(data_value) as max_temp
    FROM noaa_ghcn_pds.observations
    WHERE element = 'TMAX'
    AND q_flag IS NULL
    GROUP BY 1, 2
  ) mt
  JOIN noaa_ghcn_pds.stations s
  ON mt.id = s.id
  WHERE s.state <> ''
  AND state IS NOT NULL
  AND SUBSTRING(s.id, 1, 2) = 'US'
  AND max_temp IS NOT NULL
  AND year_date >= 20200000
  AND year_date <  20210000
) sums
WHERE rn = 1
ORDER BY max_temp desc
```

| station_id  | max_temp_f | year_date | state |       station_name
|-------------|------------|-----------|-------|--------------------------
| USC00042319 |     129.92 |  20200816 | CA    | DEATH VALLEY NP
| USR0000AHAV |     123.08 |  20200815 | AZ    | HAVASU ARIZONA
| USC00264480 |     120.92 |  20200801 | NV    | LAUGHLIN
| USC00419191 |     116.96 |  20200715 | TX    | TURKEY
| USC00427516 |     114.98 |  20200817 | UT    | ST GEORGE
| USR0000ISLA |     114.08 |  20200731 | ID    | SLATE CREEK IDAHO
| USC00457015 |        113 |  20200730 | WA    | RICHLAND
| USC00344250 |        113 |  20200714 | OK    | HOLLIS 5E MESONET
| USC00291469 |     111.92 |  20200714 | NM    | CARLSBAD
| USC00353445 |     111.02 |  20200816 | OR    | GRANTS PASS
| USW00023067 |     107.96 |  20200906 | CO    | LA JUNTA MUNI AP
| USC00140365 |     107.96 |  20200701 | KS    | ASHLAND
| USW00024017 |     107.06 |  20200707 | NE    | CHADRON MUNI AP
| USR0000MTRY |     105.98 |  20200731 | MT    | TROY MONTANA
| USW00094039 |     105.98 |  20200707 | SD    | PINE RIDGE AP
| USC00115110 |        104 |  20200708 | IL    | LITTLE RED SCHOOL HSE
| USC00489770 |        104 |  20200713 | WY    | WORLAND
| USC00236791 |     102.92 |  20200712 | MO    | POPLAR BLUFF
| USW00013873 |     102.02 |  20200720 | GA    | ATHENS BEN EPPS AP
| USC00380490 |     102.02 |  20200729 | SC    | BARNWELL 5 ENE
| USC00165266 |     102.02 |  20200816 | LA    | LEESVILLE
| USC00213311 |     102.02 |  20200607 | MN    | GRANITE FALLS
| USC00443204 |     102.02 |  20200722 | VA    | FREDERICKSBURG SEWAGE
| USC00329430 |     102.02 |  20200818 | ND    | WILLISTON EXP FARM
| USC00366111 |     102.02 |  20200707 | PA    | MURRYSVILLE 2 SW
| USC00134561 |     102.02 |  20200603 | IA    | LAKE PARK
| USC00190860 |     102.02 |  20200728 | MA    | BROCKTON
| USR0000FSAN |     102.02 |  20200803 | FL    | SANBORN FLORIDA
| USW00053843 |     100.94 |  20200811 | AL    | ANDALUSIA OPP AP
| USR0000MH41 |     100.94 |  20200809 | MS    | HIGHWAY 41 MISSISSIPPI
| USC00332067 |     100.94 |  20200604 | OH    | DAYTON MCD
| USC00126711 |     100.94 |  20200705 | IN    | PATOKA LAKE
| USC00314987 |     100.94 |  20200720 | NC    | LILLINGTON
| USC00307842 |     100.04 |  20200710 | NY    | SODUS 1W
| USC00036506 |     100.04 |  20200810 | AR    | SEARCY
| USC00408886 |     100.04 |  20200717 | TN    | TELLICO PLAINS
| USC00464840 |     100.04 |  20200706 | WV    | KEYSER 2 SSW
| USW00003757 |     100.04 |  20200719 | MD    | ST INIGOES WEBSTER NOLF
| USC00371875 |     100.04 |  20200729 | RI    | COVENTRY 2
| USC00284987 |      98.96 |  20200721 | NJ    | LONG BRANCH-OAKHURST
| USC00205451 |      98.96 |  20200703 | MI    | MILAN WWTP
| USW00014740 |      98.96 |  20200719 | CT    | HARTFORD BRADLEY INTL AP
| USR0000AKAI |      98.96 |  20200825 | AK    | KAIYUH ALASKA
| USC00275703 |      98.06 |  20200720 | NH    | NASHUA CWSU
| USW00013764 |      98.06 |  20200720 | DE    | GEORGETOWN SUSSEX CO AP
| USC00155097 |      96.98 |  20200719 | KY    | MAMMOTH CAVE
| USC00435982 |      96.98 |  20200720 | VT    | N SPRINGFIELD LAKE
| USC00174745 |      96.98 |  20200621 | ME    | LIVERMORE FALLS 1 E
| USW00094994 |      96.98 |  20200827 | WI    | BOSCOBEL AP
| USW00022516 |      96.08 |  20201003 | HI    | KAHULUI AP


