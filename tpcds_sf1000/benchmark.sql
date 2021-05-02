SET SEARCH_PATH TO 'tpcds_sf1000';

-- TPCDS query 1:
-- query1
WITH customer_total_return
     AS (SELECT sr_customer_sk     AS ctr_customer_sk,
                sr_store_sk        AS ctr_store_sk,
                Sum(sr_return_amt) AS ctr_total_return
         FROM   store_returns,
                date_dim
         WHERE  sr_returned_date_sk = d_date_sk
                AND d_year = 2001
         GROUP  BY sr_customer_sk,
                   sr_store_sk),
high_return AS (
    SELECT ctr_store_sk, Avg(ctr_total_return) * 1.2 AS return_limit
    FROM   customer_total_return ctr2
    GROUP BY ctr_store_sk
)
SELECT c_customer_id
FROM   customer_total_return ctr1,
       store,
       customer,
       high_return
WHERE  ctr1.ctr_total_return > high_return.return_limit
       AND s_store_sk = ctr1.ctr_store_sk
       AND s_state = 'TN'
       AND ctr1.ctr_customer_sk = c_customer_sk
       AND ctr1.ctr_store_sk = high_return.ctr_store_sk
ORDER  BY c_customer_id
LIMIT 100;

-- TPCDS query 2:
WITH wscs AS
  (SELECT sold_date_sk ,
          sales_price
   FROM
     (
      SELECT ws_sold_date_sk sold_date_sk ,
             sum(ws_ext_sales_price) sales_price
      FROM web_sales  GROUP BY 1
      UNION ALL
      SELECT cs_sold_date_sk sold_date_sk ,
           sum(cs_ext_sales_price) sales_price
      FROM catalog_sales GROUP BY 1

     ) AS x),
     wswscs AS
  (SELECT d_week_seq,
          sum(CASE
                  WHEN (d_day_name='Sunday') THEN sales_price
                  ELSE NULL
              END) sun_sales,
          sum(CASE
                  WHEN (d_day_name='Monday') THEN sales_price
                  ELSE NULL
              END) mon_sales,
          sum(CASE
                  WHEN (d_day_name='Tuesday') THEN sales_price
                  ELSE NULL
              END) tue_sales,
          sum(CASE
                  WHEN (d_day_name='Wednesday') THEN sales_price
                  ELSE NULL
              END) wed_sales,
          sum(CASE
                  WHEN (d_day_name='Thursday') THEN sales_price
                  ELSE NULL
              END) thu_sales,
          sum(CASE
                  WHEN (d_day_name='Friday') THEN sales_price
                  ELSE NULL
              END) fri_sales,
          sum(CASE
                  WHEN (d_day_name='Saturday') THEN sales_price
                  ELSE NULL
              END) sat_sales
   FROM wscs ,
        date_dim
   WHERE d_date_sk = sold_date_sk
   GROUP BY d_week_seq)
SELECT d_week_seq1 ,
       round(sun_sales1/sun_sales2, 2) ,
       round(mon_sales1/mon_sales2, 2) ,
       round(tue_sales1/tue_sales2, 2) ,
       round(wed_sales1/wed_sales2, 2) ,
       round(thu_sales1/thu_sales2, 2) ,
       round(fri_sales1/fri_sales2, 2) ,
       round(sat_sales1/sat_sales2, 2)
FROM
  (SELECT wswscs.d_week_seq d_week_seq1 ,
          sun_sales sun_sales1 ,
          mon_sales mon_sales1 ,
          tue_sales tue_sales1 ,
          wed_sales wed_sales1 ,
          thu_sales thu_sales1 ,
          fri_sales fri_sales1 ,
          sat_sales sat_sales1
   FROM wswscs,
        date_dim
   WHERE date_dim.d_week_seq = wswscs.d_week_seq
     AND d_year = 1998) y,

  (SELECT wswscs.d_week_seq d_week_seq2 ,
          sun_sales sun_sales2 ,
          mon_sales mon_sales2 ,
          tue_sales tue_sales2 ,
          wed_sales wed_sales2 ,
          thu_sales thu_sales2 ,
          fri_sales fri_sales2 ,
          sat_sales sat_sales2
   FROM wswscs ,
        date_dim
   WHERE date_dim.d_week_seq = wswscs.d_week_seq
     AND d_year = 1998+1) z
WHERE d_week_seq1=d_week_seq2-53::INT
ORDER BY d_week_seq1
LIMIT 100 ;


-- TPCDS query 3:
-- query3
SELECT dt.d_year,
               item.i_brand_id          brand_id,
               item.i_brand             brand,
               Sum(ss_ext_discount_amt) sum_agg
FROM   date_dim dt,
       store_sales,
       item
WHERE  dt.d_date_sk = store_sales.ss_sold_date_sk
       AND store_sales.ss_item_sk = item.i_item_sk
       AND item.i_manufact_id = 427
       AND dt.d_moy = 11
GROUP  BY dt.d_year,
          item.i_brand,
          item.i_brand_id
ORDER  BY dt.d_year,
          sum_agg DESC,
          brand_id
LIMIT 100;

-- TPCDS query 4:
-- query4
WITH year_total
     AS (SELECT c_customer_id                       customer_id,
                d_year                              dyear,
                Sum(( ( ss_ext_list_price - ss_ext_wholesale_cost
                        - ss_ext_discount_amt
                      )
                      +
                          ss_ext_sales_price ) / 2) year_total,
                's'                                 sale_type
         FROM   customer,
                store_sales,
                date_dim
         WHERE  c_customer_sk = ss_customer_sk
                AND ss_sold_date_sk = d_date_sk
         GROUP  BY c_customer_id,
                   d_year
         UNION ALL
         SELECT c_customer_id                             customer_id,
                d_year                                    dyear,
                Sum(( ( ( cs_ext_list_price
                          - cs_ext_wholesale_cost
                          - cs_ext_discount_amt
                        ) +
                              cs_ext_sales_price ) / 2 )) year_total,
                'c'                                       sale_type
         FROM   customer,
                catalog_sales,
                date_dim
         WHERE  c_customer_sk = cs_bill_customer_sk
                AND cs_sold_date_sk = d_date_sk
         GROUP  BY c_customer_id,
                   d_year
         UNION ALL
         SELECT c_customer_id                             customer_id,
                d_year                                    dyear,
                Sum(( ( ( ws_ext_list_price
                          - ws_ext_wholesale_cost
                          - ws_ext_discount_amt
                        ) +
                              ws_ext_sales_price ) / 2 )) year_total,
                'w'                                       sale_type
         FROM   customer,
                web_sales,
                date_dim
         WHERE  c_customer_sk = ws_bill_customer_sk
                AND ws_sold_date_sk = d_date_sk
         GROUP  BY c_customer_id,
                   d_year)
SELECT t_s_secyear.customer_id,
               customer.c_first_name,
               customer.c_last_name,
               customer.c_preferred_cust_flag
FROM   year_total t_s_firstyear,
       year_total t_s_secyear,
       year_total t_c_firstyear,
       year_total t_c_secyear,
       year_total t_w_firstyear,
       year_total t_w_secyear,
       customer
WHERE  t_s_secyear.customer_id = t_s_firstyear.customer_id
       AND t_s_firstyear.customer_id = t_c_secyear.customer_id
       AND t_s_firstyear.customer_id = t_c_firstyear.customer_id
       AND t_s_firstyear.customer_id = t_w_firstyear.customer_id
       AND t_s_firstyear.customer_id = t_w_secyear.customer_id
       AND t_s_secyear.customer_id = customer.c_customer_id
       AND t_s_firstyear.sale_type = 's'
       AND t_c_firstyear.sale_type = 'c'
       AND t_w_firstyear.sale_type = 'w'
       AND t_s_secyear.sale_type = 's'
       AND t_c_secyear.sale_type = 'c'
       AND t_w_secyear.sale_type = 'w'
       AND t_s_firstyear.dyear = 2001
       AND t_s_secyear.dyear = 2001 + 1
       AND t_c_firstyear.dyear = 2001
       AND t_c_secyear.dyear = 2001 + 1
       AND t_w_firstyear.dyear = 2001
       AND t_w_secyear.dyear = 2001 + 1
       AND t_s_firstyear.year_total > 0
       AND t_c_firstyear.year_total > 0
       AND t_w_firstyear.year_total > 0
       AND CASE
             WHEN t_c_firstyear.year_total > 0 THEN t_c_secyear.year_total /
                                                    t_c_firstyear.year_total
             ELSE NULL
           END > CASE
                   WHEN t_s_firstyear.year_total > 0 THEN
                   t_s_secyear.year_total /
                   t_s_firstyear.year_total
                   ELSE NULL
                 END
       AND CASE
             WHEN t_c_firstyear.year_total > 0 THEN t_c_secyear.year_total /
                                                    t_c_firstyear.year_total
             ELSE NULL
           END > CASE
                   WHEN t_w_firstyear.year_total > 0 THEN
                   t_w_secyear.year_total /
                   t_w_firstyear.year_total
                   ELSE NULL
                 END
ORDER  BY t_s_secyear.customer_id
LIMIT 100;

-- TPCDS query 5:
-- query5
WITH ssr AS
(
         SELECT   s_store_id,
                  Sum(sales_price) AS sales,
                  Sum(profit)      AS profit,
                  Sum(return_amt)  AS returns1,
                  Sum(net_loss)    AS profit_loss
         FROM     (
                         SELECT ss_store_sk             AS store_sk,
                                ss_sold_date_sk         AS date_sk,
                                ss_ext_sales_price      AS sales_price,
                                ss_net_profit           AS profit,
                                0 AS return_amt,
                                0 AS net_loss
                         FROM   store_sales
                         UNION ALL
                         SELECT sr_store_sk             AS store_sk,
                                sr_returned_date_sk     AS date_sk,
                                0 AS sales_price,
                                0 AS profit,
                                sr_return_amt           AS return_amt,
                                sr_net_loss             AS net_loss
                         FROM   store_returns ) salesreturns,
                  date_dim,
                  store
         WHERE    date_sk = d_date_sk
         AND      Cast(d_date AS DATE) BETWEEN Cast('2002-08-22' AS DATE) AND      (
                           Cast('2002-09-05' AS DATE))
         AND      store_sk = s_store_sk
         GROUP BY s_store_id) , csr AS
(
         SELECT   cp_catalog_page_id,
                  sum(sales_price) AS sales,
                  sum(profit)      AS profit,
                  sum(return_amt)  AS returns1,
                  sum(net_loss)    AS profit_loss
         FROM     (
                         SELECT cs_catalog_page_sk      AS page_sk,
                                cs_sold_date_sk         AS date_sk,
                                cs_ext_sales_price      AS sales_price,
                                cs_net_profit           AS profit,
                                0 AS return_amt,
                                0 AS net_loss
                         FROM   catalog_sales
                         UNION ALL
                         SELECT cr_catalog_page_sk      AS page_sk,
                                cr_returned_date_sk     AS date_sk,
                                0 AS sales_price,
                                0 AS profit,
                                cr_return_amount        AS return_amt,
                                cr_net_loss             AS net_loss
                         FROM   catalog_returns ) salesreturns,
                  date_dim,
                  catalog_page
         WHERE    date_sk = d_date_sk
         AND      Cast(d_date AS DATE) BETWEEN cast('2002-08-22' AS date) AND      (
                           Cast('2002-09-05' AS DATE))
         AND      page_sk = cp_catalog_page_sk
         GROUP BY cp_catalog_page_id) , wsr AS
(
         SELECT   web_site_id,
                  sum(sales_price) AS sales,
                  sum(profit)      AS profit,
                  sum(return_amt)  AS returns1,
                  sum(net_loss)    AS profit_loss
         FROM     (
                         SELECT ws_web_site_sk          AS wsr_web_site_sk,
                                ws_sold_date_sk         AS date_sk,
                                ws_ext_sales_price      AS sales_price,
                                ws_net_profit           AS profit,
                                0 AS return_amt,
                                0 AS net_loss
                         FROM   web_sales
                         UNION ALL
                         SELECT          ws_web_site_sk          AS wsr_web_site_sk,
                                         wr_returned_date_sk     AS date_sk,
                                         0 AS sales_price,
                                         0 AS profit,
                                         wr_return_amt           AS return_amt,
                                         wr_net_loss             AS net_loss
                         FROM            web_returns
                         LEFT OUTER JOIN web_sales
                         ON              (
                                                         wr_item_sk = ws_item_sk
                                         AND             wr_order_number = ws_order_number) ) salesreturns,
                  date_dim,
                  web_site
         WHERE    date_sk = d_date_sk
         AND      Cast(d_date AS DATE) BETWEEN cast('2002-08-22' AS date) AND      (
                           Cast('2002-09-05' AS DATE))
         AND      wsr_web_site_sk = web_site_sk
         GROUP BY web_site_id)
SELECT
         channel ,
         id ,
         sum(sales)   AS sales ,
         sum(returns1) AS returns1 ,
         sum(profit)  AS profit
FROM     (
                SELECT 'store channel' AS channel ,
                       Concat('store', s_store_id) AS id ,
                       sales ,
                       returns1 ,
                       (profit - profit_loss) AS profit
                FROM   ssr
                UNION ALL
                SELECT 'catalog channel' AS channel ,
                       Concat('catalog_page', cp_catalog_page_id) AS id ,
                       sales ,
                       returns1 ,
                       (profit - profit_loss) AS profit
                FROM   csr
                UNION ALL
                SELECT 'web channel' AS channel ,
                       Concat('web_site', web_site_id) AS id ,
                       sales ,
                       returns1 ,
                       (profit - profit_loss) AS profit
                FROM   wsr ) x
GROUP BY channel, id
ORDER BY channel ,
         id
LIMIT 100;


-- TPCDS query 6:
-- query6
SELECT a.ca_state state,
               Count(*)   cnt
FROM   customer_address a,
       customer c,
       store_sales s,
       date_dim d,
       item i
WHERE  a.ca_address_sk = c.c_current_addr_sk
       AND c.c_customer_sk = s.ss_customer_sk
       AND s.ss_sold_date_sk = d.d_date_sk
       AND s.ss_item_sk = i.i_item_sk
       AND d.d_month_seq = (SELECT DISTINCT ( d_month_seq )
                            FROM   date_dim
                            WHERE  d_year = 1998
                                   AND d_moy = 7)
       AND i.i_current_price > 1.2 * (SELECT Avg(j.i_current_price)
                                      FROM   item j
                                      WHERE  j.i_category = i.i_category)
GROUP  BY a.ca_state
HAVING Count(*) >= 10
ORDER  BY cnt
LIMIT 100;

-- TPCDS query 7:
-- query7
SELECT i_item_id,
               Avg(ss_quantity)    agg1,
               Avg(ss_list_price)  agg2,
               Avg(ss_coupon_amt)  agg3,
               Avg(ss_sales_price) agg4
FROM   store_sales,
       customer_demographics,
       date_dim,
       item,
       promotion
WHERE  ss_sold_date_sk = d_date_sk
       AND ss_item_sk = i_item_sk
       AND ss_cdemo_sk = cd_demo_sk
       AND ss_promo_sk = p_promo_sk
       AND cd_gender = 'F'
       AND cd_marital_status = 'W'
       AND cd_education_status = '2 yr Degree'
       AND ( p_channel_email = 'N'
              OR p_channel_event = 'N' )
       AND d_year = 1998
GROUP  BY i_item_id
ORDER  BY i_item_id
LIMIT 100;

-- TPCDS query 8:
-- query8
WITH ca_zips AS (
        SELECT Substr(ca_zip, 1, 5) AS ca_zip
                FROM   customer_address
                WHERE  Substr(ca_zip, 1, 5) IN ( '67436', '26121', '38443',
                                                 '63157',
                                                 '68856', '19485', '86425',
                                                 '26741',
                                                 '70991', '60899', '63573',
                                                 '47556',
                                                 '56193', '93314', '87827',
                                                 '62017',
                                                 '85067', '95390', '48091',
                                                 '10261',
                                                 '81845', '41790', '42853',
                                                 '24675',
                                                 '12840', '60065', '84430',
                                                 '57451',
                                                 '24021', '91735', '75335',
                                                 '71935',
                                                 '34482', '56943', '70695',
                                                 '52147',
                                                 '56251', '28411', '86653',
                                                 '23005',
                                                 '22478', '29031', '34398',
                                                 '15365',
                                                 '42460', '33337', '59433',
                                                 '73943',
                                                 '72477', '74081', '74430',
                                                 '64605',
                                                 '39006', '11226', '49057',
                                                 '97308',
                                                 '42663', '18187', '19768',
                                                 '43454',
                                                 '32147', '76637', '51975',
                                                 '11181',
                                                 '45630', '33129', '45995',
                                                 '64386',
                                                 '55522', '26697', '20963',
                                                 '35154',
                                                 '64587', '49752', '66386',
                                                 '30586',
                                                 '59286', '13177', '66646',
                                                 '84195',
                                                 '74316', '36853', '32927',
                                                 '12469',
                                                 '11904', '36269', '17724',
                                                 '55346',
                                                 '12595', '53988', '65439',
                                                 '28015',
                                                 '63268', '73590', '29216',
                                                 '82575',
                                                 '69267', '13805', '91678',
                                                 '79460',
                                                 '94152', '14961', '15419',
                                                 '48277',
                                                 '62588', '55493', '28360',
                                                 '14152',
                                                 '55225', '18007', '53705',
                                                 '56573',
                                                 '80245', '71769', '57348',
                                                 '36845',
                                                 '13039', '17270', '22363',
                                                 '83474',
                                                 '25294', '43269', '77666',
                                                 '15488',
                                                 '99146', '64441', '43338',
                                                 '38736',
                                                 '62754', '48556', '86057',
                                                 '23090',
                                                 '38114', '66061', '18910',
                                                 '84385',
                                                 '23600', '19975', '27883',
                                                 '65719',
                                                 '19933', '32085', '49731',
                                                 '40473',
                                                 '27190', '46192', '23949',
                                                 '44738',
                                                 '12436', '64794', '68741',
                                                 '15333',
                                                 '24282', '49085', '31844',
                                                 '71156',
                                                 '48441', '17100', '98207',
                                                 '44982',
                                                 '20277', '71496', '96299',
                                                 '37583',
                                                 '22206', '89174', '30589',
                                                 '61924',
                                                 '53079', '10976', '13104',
                                                 '42794',
                                                 '54772', '15809', '56434',
                                                 '39975',
                                                 '13874', '30753', '77598',
                                                 '78229',
                                                 '59478', '12345', '55547',
                                                 '57422',
                                                 '42600', '79444', '29074',
                                                 '29752',
                                                 '21676', '32096', '43044',
                                                 '39383',
                                                 '37296', '36295', '63077',
                                                 '16572',
                                                 '31275', '18701', '40197',
                                                 '48242',
                                                 '27219', '49865', '84175',
                                                 '30446',
                                                 '25165', '13807', '72142',
                                                 '70499',
                                                 '70464', '71429', '18111',
                                                 '70857',
                                                 '29545', '36425', '52706',
                                                 '36194',
                                                 '42963', '75068', '47921',
                                                 '74763',
                                                 '90990', '89456', '62073',
                                                 '88397',
                                                 '73963', '75885', '62657',
                                                 '12530',
                                                 '81146', '57434', '25099',
                                                 '41429',
                                                 '98441', '48713', '52552',
                                                 '31667',
                                                 '14072', '13903', '44709',
                                                 '85429',
                                                 '58017', '38295', '44875',
                                                 '73541',
                                                 '30091', '12707', '23762',
                                                 '62258',
                                                 '33247', '78722', '77431',
                                                 '14510',
                                                 '35656', '72428', '92082',
                                                 '35267',
                                                 '43759', '24354', '90952',
                                                 '11512',
                                                 '21242', '22579', '56114',
                                                 '32339',
                                                 '52282', '41791', '24484',
                                                 '95020',
                                                 '28408', '99710', '11899',
                                                 '43344',
                                                 '72915', '27644', '62708',
                                                 '74479',
                                                 '17177', '32619', '12351',
                                                 '91339',
                                                 '31169', '57081', '53522',
                                                 '16712',
                                                 '34419', '71779', '44187',
                                                 '46206',
                                                 '96099', '61910', '53664',
                                                 '12295',
                                                 '31837', '33096', '10813',
                                                 '63048',
                                                 '31732', '79118', '73084',
                                                 '72783',
                                                 '84952', '46965', '77956',
                                                 '39815',
                                                 '32311', '75329', '48156',
                                                 '30826',
                                                 '49661', '13736', '92076',
                                                 '74865',
                                                 '88149', '92397', '52777',
                                                 '68453',
                                                 '32012', '21222', '52721',
                                                 '24626',
                                                 '18210', '42177', '91791',
                                                 '75251',
                                                 '82075', '44372', '45542',
                                                 '20609',
                                                 '60115', '17362', '22750',
                                                 '90434',
                                                 '31852', '54071', '33762',
                                                 '14705',
                                                 '40718', '56433', '30996',
                                                 '40657',
                                                 '49056', '23585', '66455',
                                                 '41021',
                                                 '74736', '72151', '37007',
                                                 '21729',
                                                 '60177', '84558', '59027',
                                                 '93855',
                                                 '60022', '86443', '19541',
                                                 '86886',
                                                 '30532', '39062', '48532',
                                                 '34713',
                                                 '52077', '22564', '64638',
                                                 '15273',
                                                 '31677', '36138', '62367',
                                                 '60261',
                                                 '80213', '42818', '25113',
                                                 '72378',
                                                 '69802', '69096', '55443',
                                                 '28820',
                                                 '13848', '78258', '37490',
                                                 '30556',
                                                 '77380', '28447', '44550',
                                                 '26791',
                                                 '70609', '82182', '33306',
                                                 '43224',
                                                 '22322', '86959', '68519',
                                                 '14308',
                                                 '46501', '81131', '34056',
                                                 '61991',
                                                 '19896', '87804', '65774',
                                                 '92564' )
), common_zips AS (
        SELECT ca_zip
                FROM   (SELECT Substr(ca_zip, 1, 5) ca_zip,
                               Count(*)             cnt
                        FROM   customer_address,
                               customer
                        WHERE  ca_address_sk = c_current_addr_sk
                               AND c_preferred_cust_flag = 'Y'
                        GROUP  BY ca_zip
                        HAVING Count(*) > 10) as aa
),
chosen_zips AS (
        SELECT ca_zip
        FROM ca_zips
        WHERE ca_zip IN (SELECT ca_zip FROM common_zips)
)
SELECT s_store_name,
       Sum(ss_net_profit)
FROM   store_sales,
       date_dim,
       store,
       common_zips
WHERE  ss_store_sk = s_store_sk
       AND ss_sold_date_sk = d_date_sk
       AND d_qoy = 2
       AND d_year = 2000
       AND ( Substr(s_zip, 1, 2) = Substr(ca_zip, 1, 2) )
GROUP  BY s_store_name
ORDER  BY s_store_name
LIMIT 100;

-- TPCDS query 9:
-- query9
SELECT CASE
         WHEN (SELECT Count(*)
               FROM   store_sales
               WHERE  ss_quantity BETWEEN 1 AND 20) > 3672 THEN
         (SELECT Avg(ss_ext_list_price)
          FROM   store_sales
          WHERE
         ss_quantity BETWEEN 1 AND 20)
         ELSE (SELECT Avg(ss_net_profit)
               FROM   store_sales
               WHERE  ss_quantity BETWEEN 1 AND 20)
       END bucket1,
       CASE
         WHEN (SELECT Count(*)
               FROM   store_sales
               WHERE  ss_quantity BETWEEN 21 AND 40) > 3392 THEN
         (SELECT Avg(ss_ext_list_price)
          FROM   store_sales
          WHERE
         ss_quantity BETWEEN 21 AND 40)
         ELSE (SELECT Avg(ss_net_profit)
               FROM   store_sales
               WHERE  ss_quantity BETWEEN 21 AND 40)
       END bucket2,
       CASE
         WHEN (SELECT Count(*)
               FROM   store_sales
               WHERE  ss_quantity BETWEEN 41 AND 60) > 32784 THEN
         (SELECT Avg(ss_ext_list_price)
          FROM   store_sales
          WHERE
         ss_quantity BETWEEN 41 AND 60)
         ELSE (SELECT Avg(ss_net_profit)
               FROM   store_sales
               WHERE  ss_quantity BETWEEN 41 AND 60)
       END bucket3,
       CASE
         WHEN (SELECT Count(*)
               FROM   store_sales
               WHERE  ss_quantity BETWEEN 61 AND 80) > 26032 THEN
         (SELECT Avg(ss_ext_list_price)
          FROM   store_sales
          WHERE
         ss_quantity BETWEEN 61 AND 80)
         ELSE (SELECT Avg(ss_net_profit)
               FROM   store_sales
               WHERE  ss_quantity BETWEEN 61 AND 80)
       END bucket4,
       CASE
         WHEN (SELECT Count(*)
               FROM   store_sales
               WHERE  ss_quantity BETWEEN 81 AND 100) > 23982 THEN
         (SELECT Avg(ss_ext_list_price)
          FROM   store_sales
          WHERE
         ss_quantity BETWEEN 81 AND 100)
         ELSE (SELECT Avg(ss_net_profit)
               FROM   store_sales
               WHERE  ss_quantity BETWEEN 81 AND 100)
       END bucket5
FROM   reason
WHERE  r_reason_sk = 1;

-- TPCDS query 10:
-- start query 1 in stream 0 using template query10a.tpl
select
  cd_gender,
  cd_marital_status,
  cd_education_status,
  count(*) cnt1,
  cd_purchase_estimate,
  count(*) cnt2,
  cd_credit_rating,
  count(*) cnt3,
  cd_dep_count,
  count(*) cnt4,
  cd_dep_employed_count,
  count(*) cnt5,
  cd_dep_college_count,
  count(*) cnt6
 from
  customer c,customer_address ca,customer_demographics
 where
  c.c_current_addr_sk = ca.ca_address_sk and
  ca_county IN ( 'Lycoming County', 'Sheridan County',
                          'Kandiyohi County',
                          'Pike County',
                                           'Greene County' )
  and
  cd_demo_sk = c.c_current_cdemo_sk and
  exists (select *
          from store_sales,date_dim
          where c.c_customer_sk = ss_customer_sk and
                ss_sold_date_sk = d_date_sk and
                d_year = 2002 and
                d_moy between 4 and 4+3) and
   exists (select *
          from (
             select ws_bill_customer_sk as customer_sk, d_year,d_moy
             from web_sales, date_dim where ws_sold_date_sk = d_date_sk
              and d_year = 2002 and
                  d_moy between 4 and 4+3
             union all
             select cs_ship_customer_sk as customer_sk, d_year, d_moy
             from catalog_sales, date_dim where cs_sold_date_sk = d_date_sk
              and d_year = 2002 and
                  d_moy between 4 and 4+3
	     ) x
            where c.c_customer_sk = customer_sk)
 group by cd_gender,
          cd_marital_status,
          cd_education_status,
          cd_purchase_estimate,
          cd_credit_rating,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
 order by cd_gender,
          cd_marital_status,
          cd_education_status,
          cd_purchase_estimate,
          cd_credit_rating,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
limit 100;



-- TPCDS query 11:
-- query11
WITH year_total
     AS (SELECT c_customer_id                                customer_id,
                c_first_name                                 customer_first_name
                ,
                c_last_name
                customer_last_name,
                c_preferred_cust_flag
                   customer_preferred_cust_flag
                    ,
                c_birth_country
                    customer_birth_country,
                c_login                                      customer_login,
                c_email_address
                customer_email_address,
                d_year                                       dyear,
                Sum(ss_ext_list_price - ss_ext_discount_amt) year_total,
                's'                                          sale_type
         FROM   customer,
                store_sales,
                date_dim
         WHERE  c_customer_sk = ss_customer_sk
                AND ss_sold_date_sk = d_date_sk
         GROUP  BY c_customer_id,
                   c_first_name,
                   c_last_name,
                   c_preferred_cust_flag,
                   c_birth_country,
                   c_login,
                   c_email_address,
                   d_year
         UNION ALL
         SELECT c_customer_id                                customer_id,
                c_first_name                                 customer_first_name
                ,
                c_last_name
                customer_last_name,
                c_preferred_cust_flag
                customer_preferred_cust_flag
                ,
                c_birth_country
                customer_birth_country,
                c_login                                      customer_login,
                c_email_address
                customer_email_address,
                d_year                                       dyear,
                Sum(ws_ext_list_price - ws_ext_discount_amt) year_total,
                'w'                                          sale_type
         FROM   customer,
                web_sales,
                date_dim
         WHERE  c_customer_sk = ws_bill_customer_sk
                AND ws_sold_date_sk = d_date_sk
         GROUP  BY c_customer_id,
                   c_first_name,
                   c_last_name,
                   c_preferred_cust_flag,
                   c_birth_country,
                   c_login,
                   c_email_address,
                   d_year)
SELECT t_s_secyear.customer_id,
               t_s_secyear.customer_first_name,
               t_s_secyear.customer_last_name,
               t_s_secyear.customer_birth_country
FROM   year_total t_s_firstyear,
       year_total t_s_secyear,
       year_total t_w_firstyear,
       year_total t_w_secyear
WHERE  t_s_secyear.customer_id = t_s_firstyear.customer_id
       AND t_s_firstyear.customer_id = t_w_secyear.customer_id
       AND t_s_firstyear.customer_id = t_w_firstyear.customer_id
       AND t_s_firstyear.sale_type = 's'
       AND t_w_firstyear.sale_type = 'w'
       AND t_s_secyear.sale_type = 's'
       AND t_w_secyear.sale_type = 'w'
       AND t_s_firstyear.dyear = 2001
       AND t_s_secyear.dyear = 2001 + 1
       AND t_w_firstyear.dyear = 2001
       AND t_w_secyear.dyear = 2001 + 1
       AND t_s_firstyear.year_total > 0
       AND t_w_firstyear.year_total > 0
       AND CASE
             WHEN t_w_firstyear.year_total > 0 THEN t_w_secyear.year_total /
                                                    t_w_firstyear.year_total
             ELSE 0.0
           END > CASE
                   WHEN t_s_firstyear.year_total > 0 THEN
                   t_s_secyear.year_total /
                   t_s_firstyear.year_total
                   ELSE 0.0
                 END
ORDER  BY t_s_secyear.customer_id,
          t_s_secyear.customer_first_name,
          t_s_secyear.customer_last_name,
          t_s_secyear.customer_birth_country
LIMIT 100;

-- TPCDS query 12:
-- query12
SELECT
         i_item_id ,
         i_item_desc ,
         i_category ,
         i_class ,
         i_current_price ,
         Sum(ws_ext_sales_price)                                                              AS itemrevenue ,
         Sum(ws_ext_sales_price)*100/Sum(Sum(ws_ext_sales_price)) OVER (partition BY i_class) AS revenueratio
FROM     web_sales ,
         item ,
         date_dim
WHERE    ws_item_sk = i_item_sk
AND      i_category IN ('Home',
                        'Men',
                        'Women')
AND      ws_sold_date_sk = d_date_sk
AND      Cast(d_date AS DATE) BETWEEN Cast('2000-05-11' AS DATE) AND      (
                  Cast('2000-06-11' AS DATE))
GROUP BY i_item_id ,
         i_item_desc ,
         i_category ,
         i_class ,
         i_current_price
ORDER BY i_category ,
         i_class ,
         i_item_id ,
         i_item_desc ,
         revenueratio
LIMIT 100;


-- TPCDS query 13:
-- query13
SELECT Avg(ss_quantity),
       Avg(ss_ext_sales_price),
       Avg(ss_ext_wholesale_cost),
       Sum(ss_ext_wholesale_cost)
FROM   store_sales,
       store,
       customer_demographics,
       household_demographics,
       customer_address,
       date_dim
WHERE  s_store_sk = ss_store_sk
       AND ss_sold_date_sk = d_date_sk
       AND d_year = 2001
       AND ( ( ss_hdemo_sk = hd_demo_sk
               AND cd_demo_sk = ss_cdemo_sk
               AND cd_marital_status = 'U'
               AND cd_education_status = 'Advanced Degree'
               AND ss_sales_price BETWEEN 100.00 AND 150.00
               AND hd_dep_count = 3 )
              OR ( ss_hdemo_sk = hd_demo_sk
                   AND cd_demo_sk = ss_cdemo_sk
                   AND cd_marital_status = 'M'
                   AND cd_education_status = 'Primary'
                   AND ss_sales_price BETWEEN 50.00 AND 100.00
                   AND hd_dep_count = 1 )
              OR ( ss_hdemo_sk = hd_demo_sk
                   AND cd_demo_sk = ss_cdemo_sk
                   AND cd_marital_status = 'D'
                   AND cd_education_status = 'Secondary'
                   AND ss_sales_price BETWEEN 150.00 AND 200.00
                   AND hd_dep_count = 1 ) )
       AND ( ( ss_addr_sk = ca_address_sk
               AND ca_country = 'United States'
               AND ca_state IN ( 'AZ', 'NE', 'IA' )
               AND ss_net_profit BETWEEN 100 AND 200 )
              OR ( ss_addr_sk = ca_address_sk
                   AND ca_country = 'United States'
                   AND ca_state IN ( 'MS', 'CA', 'NV' )
                   AND ss_net_profit BETWEEN 150 AND 300 )
              OR ( ss_addr_sk = ca_address_sk
                   AND ca_country = 'United States'
                   AND ca_state IN ( 'GA', 'TX', 'NJ' )
                   AND ss_net_profit BETWEEN 50 AND 250 ) );

-- TPCDS query 14:
-- query14
WITH item_ss AS (
    SELECT DISTINCT
        iss.i_brand_id,
        iss.i_class_id,
        iss.i_category_id
    FROM   store_sales,
        item iss,
        date_dim d1
    WHERE  ss_item_sk = iss.i_item_sk
        AND ss_sold_date_sk = d1.d_date_sk
        AND d1.d_year BETWEEN 1999 AND 1999 + 2
), item_cs AS (
    SELECT DISTINCT
        ics.i_brand_id,
        ics.i_class_id,
        ics.i_category_id
    FROM   catalog_sales,
        item ics,
        date_dim d2
    WHERE  cs_item_sk = ics.i_item_sk
        AND cs_sold_date_sk = d2.d_date_sk
        AND d2.d_year BETWEEN 1999 AND 1999 + 2
), item_ws AS (
    SELECT DISTINCT
        iws.i_brand_id,
        iws.i_class_id,
        iws.i_category_id
    FROM   web_sales,
        item iws,
        date_dim d3
    WHERE  ws_item_sk = iws.i_item_sk
        AND ws_sold_date_sk = d3.d_date_sk
        AND d3.d_year BETWEEN 1999 AND 1999 + 2
), item_intersect AS (
    SELECT
        item_ss.i_brand_id    brand_id,
        item_ss.i_class_id    class_id,
        item_ss.i_category_id category_id
    FROM item_ss
    JOIN item_ws ON item_ss.i_brand_id = item_ws.i_brand_id
        AND item_ss.i_class_id = item_ws.i_class_id
        AND item_ss.i_category_id = item_ws.i_category_id
    JOIN item_cs ON item_ss.i_brand_id = item_cs.i_brand_id
        AND item_ss.i_class_id = item_cs.i_class_id
        AND item_ss.i_category_id = item_cs.i_category_id
), cross_items AS (
         SELECT i_item_sk ss_item_sk
         FROM   item,
                item_intersect
         WHERE  i_brand_id = brand_id
                AND i_class_id = class_id
                AND i_category_id = category_id),
     avg_sales
     AS (SELECT Avg(quantity * list_price) average_sales
         FROM   (SELECT ss_quantity   quantity,
                        ss_list_price list_price
                 FROM   store_sales,
                        date_dim
                 WHERE  ss_sold_date_sk = d_date_sk
                        AND d_year BETWEEN 1999 AND 1999 + 2
                 UNION ALL
                 SELECT cs_quantity   quantity,
                        cs_list_price list_price
                 FROM   catalog_sales,
                        date_dim
                 WHERE  cs_sold_date_sk = d_date_sk
                        AND d_year BETWEEN 1999 AND 1999 + 2
                 UNION ALL
                 SELECT ws_quantity   quantity,
                        ws_list_price list_price
                 FROM   web_sales,
                        date_dim
                 WHERE  ws_sold_date_sk = d_date_sk
                        AND d_year BETWEEN 1999 AND 1999 + 2) x)
SELECT channel,
               i_brand_id,
               i_class_id,
               i_category_id,
               Sum(sales),
               Sum(number_sales)
FROM  (SELECT 'store'                          channel,
              i_brand_id,
              i_class_id,
              i_category_id,
              Sum(ss_quantity * ss_list_price) sales,
              Count(*)                         number_sales
       FROM   store_sales,
              item,
              date_dim
       WHERE  ss_item_sk IN (SELECT ss_item_sk
                             FROM   cross_items)
              AND ss_item_sk = i_item_sk
              AND ss_sold_date_sk = d_date_sk
              AND d_year = 1999 + 2
              AND d_moy = 11
       GROUP  BY i_brand_id,
                 i_class_id,
                 i_category_id
       HAVING Sum(ss_quantity * ss_list_price) > (SELECT average_sales
                                                  FROM   avg_sales)
       UNION ALL
       SELECT 'catalog'                        channel,
              i_brand_id,
              i_class_id,
              i_category_id,
              Sum(cs_quantity * cs_list_price) sales,
              Count(*)                         number_sales
       FROM   catalog_sales,
              item,
              date_dim
       WHERE  cs_item_sk IN (SELECT ss_item_sk
                             FROM   cross_items)
              AND cs_item_sk = i_item_sk
              AND cs_sold_date_sk = d_date_sk
              AND d_year = 1999 + 2
              AND d_moy = 11
       GROUP  BY i_brand_id,
                 i_class_id,
                 i_category_id
       HAVING Sum(cs_quantity * cs_list_price) > (SELECT average_sales
                                                  FROM   avg_sales)
       UNION ALL
       SELECT 'web'                            channel,
              i_brand_id,
              i_class_id,
              i_category_id,
              Sum(ws_quantity * ws_list_price) sales,
              Count(*)                         number_sales
       FROM   web_sales,
              item,
              date_dim
       WHERE  ws_item_sk IN (SELECT ss_item_sk
                             FROM   cross_items)
              AND ws_item_sk = i_item_sk
              AND ws_sold_date_sk = d_date_sk
              AND d_year = 1999 + 2
              AND d_moy = 11
       GROUP  BY i_brand_id,
                 i_class_id,
                 i_category_id
       HAVING Sum(ws_quantity * ws_list_price) > (SELECT average_sales
                                                  FROM   avg_sales)) y
GROUP  BY channel, i_brand_id, i_class_id, i_category_id
ORDER  BY channel,
          i_brand_id,
          i_class_id,
          i_category_id
LIMIT 100;

-- TPCDS query 15:
-- query15
SELECT ca_zip,
               Sum(cs_sales_price)
FROM   catalog_sales,
       customer,
       customer_address,
       date_dim
WHERE  cs_bill_customer_sk = c_customer_sk
       AND c_current_addr_sk = ca_address_sk
       AND ( Substr(ca_zip, 1, 5) IN ( '85669', '86197', '88274', '83405',
                                       '86475', '85392', '85460', '80348',
                                       '81792' )
              OR ca_state IN ( 'CA', 'WA', 'GA' )
              OR cs_sales_price > 500 )
       AND cs_sold_date_sk = d_date_sk
       AND d_qoy = 1
       AND d_year = 1998
GROUP  BY ca_zip
ORDER  BY ca_zip
LIMIT 100;

-- TPCDS query 16:
-- query16
SELECT
         Count(DISTINCT cs_order_number) AS order_count ,
         Sum(cs_ext_ship_cost)           AS total_shipping_cost ,
         Sum(cs_net_profit)              AS total_net_profit
FROM     catalog_sales cs1 ,
         date_dim ,
         customer_address ,
         call_center
WHERE    Cast(d_date AS DATE) BETWEEN Cast('2002-3-01' AS DATE) AND (
                  Cast('2002-5-01' AS DATE))
AND      cs1.cs_ship_date_sk = d_date_sk
AND      cs1.cs_ship_addr_sk = ca_address_sk
AND      ca_state = 'IA'
AND      cs1.cs_call_center_sk = cc_call_center_sk
AND      cc_county IN ('Williamson County',
                       'Williamson County',
                       'Williamson County',
                       'Williamson County',
                       'Williamson County' )
AND      EXISTS
         (
                SELECT *
                FROM   catalog_sales cs2
                WHERE  cs1.cs_order_number = cs2.cs_order_number
                AND    cs1.cs_warehouse_sk <> cs2.cs_warehouse_sk)
AND      NOT EXISTS
         (
                SELECT *
                FROM   catalog_returns cr1
                WHERE  cs1.cs_order_number = cr1.cr_order_number)
ORDER BY count(DISTINCT cs_order_number)
LIMIT 100;


-- TPCDS query 17:
-- query17
SELECT i_item_id,
               i_item_desc,
               s_state,
               Count(ss_quantity)                                        AS
               store_sales_quantitycount,
               Avg(ss_quantity)                                          AS
               store_sales_quantityave,
               Stddev_samp(ss_quantity)                                  AS
               store_sales_quantitystdev,
               Stddev_samp(ss_quantity) / Avg(ss_quantity)               AS
               store_sales_quantitycov,
               Count(sr_return_quantity)                                 AS
               store_returns_quantitycount,
               Avg(sr_return_quantity)                                   AS
               store_returns_quantityave,
               Stddev_samp(sr_return_quantity)                           AS
               store_returns_quantitystdev,
               Stddev_samp(sr_return_quantity) / Avg(sr_return_quantity) AS
               store_returns_quantitycov,
               Count(cs_quantity)                                        AS
               catalog_sales_quantitycount,
               Avg(cs_quantity)                                          AS
               catalog_sales_quantityave,
               Stddev_samp(cs_quantity) / Avg(cs_quantity)               AS
               catalog_sales_quantitystdev,
               Stddev_samp(cs_quantity) / Avg(cs_quantity)               AS
               catalog_sales_quantitycov
FROM   store_sales,
       store_returns,
       catalog_sales,
       date_dim d1,
       date_dim d2,
       date_dim d3,
       store,
       item
WHERE  d1.d_quarter_name = '1999Q1'
       AND d1.d_date_sk = ss_sold_date_sk
       AND i_item_sk = ss_item_sk
       AND s_store_sk = ss_store_sk
       AND ss_customer_sk = sr_customer_sk
       AND ss_item_sk = sr_item_sk
       AND ss_ticket_number = sr_ticket_number
       AND sr_returned_date_sk = d2.d_date_sk
       AND d2.d_quarter_name IN ( '1999Q1', '1999Q2', '1999Q3' )
       AND sr_customer_sk = cs_bill_customer_sk
       AND sr_item_sk = cs_item_sk
       AND cs_sold_date_sk = d3.d_date_sk
       AND d3.d_quarter_name IN ( '1999Q1', '1999Q2', '1999Q3' )
GROUP  BY i_item_id,
          i_item_desc,
          s_state
ORDER  BY i_item_id,
          i_item_desc,
          s_state
LIMIT 100;

-- TPCDS query 18:
-- query18
SELECT i_item_id,
               ca_country,
               ca_state,
               ca_county,
               Avg(cs_quantity)      agg1,
               Avg(cs_list_price)    agg2,
               Avg(cs_coupon_amt)    agg3,
               Avg(cs_sales_price)   agg4,
               Avg(cs_net_profit)    agg5,
               Avg(c_birth_year)     agg6,
               Avg(cd1.cd_dep_count) agg7
FROM   catalog_sales,
       customer_demographics cd1,
       customer_demographics cd2,
       customer,
       customer_address,
       date_dim,
       item
WHERE  cs_sold_date_sk = d_date_sk
       AND cs_item_sk = i_item_sk
       AND cs_bill_cdemo_sk = cd1.cd_demo_sk
       AND cs_bill_customer_sk = c_customer_sk
       AND cd1.cd_gender = 'F'
       AND cd1.cd_education_status = 'Secondary'
       AND c_current_cdemo_sk = cd2.cd_demo_sk
       AND c_current_addr_sk = ca_address_sk
       AND c_birth_month IN ( 8, 4, 2, 5,
                              11, 9 )
       AND d_year = 2001
       AND ca_state IN ( 'KS', 'IA', 'AL', 'UT',
                         'VA', 'NC', 'TX' )
GROUP  BY i_item_id, ca_country, ca_state, ca_county
ORDER  BY ca_country,
          ca_state,
          ca_county,
          i_item_id
LIMIT 100;

-- TPCDS query 19:
-- query19
SELECT i_brand_id              brand_id,
               i_brand                 brand,
               i_manufact_id,
               i_manufact,
               Sum(ss_ext_sales_price) ext_price
FROM   date_dim,
       store_sales,
       item,
       customer,
       customer_address,
       store
WHERE  d_date_sk = ss_sold_date_sk
       AND ss_item_sk = i_item_sk
       AND i_manager_id = 38
       AND d_moy = 12
       AND d_year = 1998
       AND ss_customer_sk = c_customer_sk
       AND c_current_addr_sk = ca_address_sk
       AND Substr(ca_zip, 1, 5) <> Substr(s_zip, 1, 5)
       AND ss_store_sk = s_store_sk
GROUP  BY i_brand,
          i_brand_id,
          i_manufact_id,
          i_manufact
ORDER  BY ext_price DESC,
          i_brand,
          i_brand_id,
          i_manufact_id,
          i_manufact
LIMIT 100;

-- TPCDS query 20:
-- query20
SELECT
         i_item_id ,
         i_item_desc ,
         i_category ,
         i_class ,
         i_current_price ,
         Sum(cs_ext_sales_price)                                                              AS itemrevenue ,
         Sum(cs_ext_sales_price)*100/Sum(Sum(cs_ext_sales_price)) OVER (partition BY i_class) AS revenueratio
FROM     catalog_sales ,
         item ,
         date_dim
WHERE    cs_item_sk = i_item_sk
AND      i_category IN ('Children',
                        'Women',
                        'Electronics')
AND      cs_sold_date_sk = d_date_sk
AND      Cast(d_date AS DATE) BETWEEN Cast('2001-02-03' AS DATE) AND      (
                  Cast('2001-03-03' AS DATE))
GROUP BY i_item_id ,
         i_item_desc ,
         i_category ,
         i_class ,
         i_current_price
ORDER BY i_category ,
         i_class ,
         i_item_id ,
         i_item_desc ,
         revenueratio
LIMIT 100;


-- TPCDS query 21:
-- query21
SELECT
         *
FROM    (
                  SELECT   w_warehouse_name ,
                           i_item_id ,
                           Sum(
                           CASE
                                    WHEN (
                                                      Cast(d_date AS DATE) < Cast ('2000-05-13' AS DATE)) THEN inv_quantity_on_hand
                                    ELSE 0
                           END) AS inv_before ,
                           Sum(
                           CASE
                                    WHEN (
                                                      Cast(d_date AS DATE) >= Cast ('2000-05-13' AS DATE)) THEN inv_quantity_on_hand
                                    ELSE 0
                           END) AS inv_after
                  FROM     inventory ,
                           warehouse ,
                           item ,
                           date_dim
                  WHERE    i_current_price BETWEEN 0.99 AND      1.49
                  AND      i_item_sk = inv_item_sk
                  AND      inv_warehouse_sk = w_warehouse_sk
                  AND      inv_date_sk = d_date_sk
                  AND      Cast(d_date AS DATE) BETWEEN (Cast ('2000-04-13' AS DATE)) AND      (
                                    cast ('2000-06-13' AS        date))
                  GROUP BY w_warehouse_name,
                           i_item_id) x
WHERE    (
                  CASE
                           WHEN inv_before > 0 THEN inv_after / inv_before
                           ELSE NULL
                  END) BETWEEN 2.0/3.0 AND      3.0/2.0
ORDER BY w_warehouse_name ,
         i_item_id
LIMIT 100;


-- TPCDS query 22:
-- query22
SELECT i_product_name,
               i_brand,
               i_class,
               i_category,
               Avg(inv_quantity_on_hand) qoh
FROM   inventory,
       date_dim,
       item,
       warehouse
WHERE  inv_date_sk = d_date_sk
       AND inv_item_sk = i_item_sk
       AND inv_warehouse_sk = w_warehouse_sk
       AND d_month_seq BETWEEN 1205 AND 1205 + 11
GROUP  BY i_product_name, i_brand, i_class, i_category
ORDER  BY qoh,
          i_product_name,
          i_brand,
          i_class,
          i_category
LIMIT 100;

-- TPCDS query 23:
with frequent_ss_items as
 (select substr(i_item_desc,1,30) itemdesc
      ,i_item_sk item_sk
      ,d_date solddate
      ,count(*) cnt
  from store_sales
      ,date_dim
      ,item
  where ss_sold_date_sk = d_date_sk
    and ss_item_sk = i_item_sk
    and d_year in (1998,1998+1,1998+2,1998+3)
  group by substr(i_item_desc,1,30),i_item_sk,d_date
  having count(*) >4)

, max_store_sales as
 (select max(csales) tpcds_cmax
  from (select ss_customer_sk,sum(ss_quantity*ss_sales_price) csales
        from store_sales
            -- ,customer
            ,date_dim
        where --ss_customer_sk = c_customer_sk
            ss_customer_sk IS NOT NULL
         and ss_sold_date_sk = d_date_sk
         and d_year in (1998,1998+1,1998+2,1998+3)
        group by ss_customer_sk) x)

, best_ss_customer as
 (select ss_customer_sk as customer_sk
      , sum(ss_quantity*ss_sales_price) ssales
  from store_sales
      -- ,customer
  where -- ss_customer_sk = c_customer_sk
    ss_customer_sk IS NOT NULL
  group by ss_customer_sk
  having sum(ss_quantity*ss_sales_price)
             > (95/100.0) * (select * from max_store_sales))
  select  sum(sales)
 from (select cs_quantity*cs_list_price sales
            , cs_item_sk AS item_sk
            , cs_bill_customer_sk AS customer_sk
       from catalog_sales
           ,date_dim
       where d_year = 1998
         and d_moy = 6
         and cs_sold_date_sk = d_date_sk
      union all
      select ws_quantity*ws_list_price sales
            , ws_item_sk
            , ws_bill_customer_sk
       from web_sales
           ,date_dim
       where d_year = 1998
         and d_moy = 6
         and ws_sold_date_sk = d_date_sk
     ) as x
    JOIN (select DISTINCT item_sk from frequent_ss_items) AS i ON i.item_sk = x.item_sk
    JOIN (select customer_sk from best_ss_customer) AS c ON c.customer_sk = x.customer_sk
limit 100
;

-- TPCDS query 24:
-- query24
WITH ssales
     AS (SELECT c_last_name,
                c_first_name,
                s_store_name,
                ca_state,
                s_state,
                i_color,
                i_current_price,
                i_manager_id,
                i_units,
                i_size,
                Sum(ss_net_profit) netpaid
         FROM   store_sales,
                store_returns,
                store,
                item,
                customer,
                customer_address
         WHERE  ss_ticket_number = sr_ticket_number
                AND ss_item_sk = sr_item_sk
                AND ss_customer_sk = c_customer_sk
                AND ss_item_sk = i_item_sk
                AND ss_store_sk = s_store_sk
                AND c_birth_country = Upper(ca_country)
                AND s_zip = ca_zip
                AND s_market_id = 6
         GROUP  BY c_last_name,
                   c_first_name,
                   s_store_name,
                   ca_state,
                   s_state,
                   i_color,
                   i_current_price,
                   i_manager_id,
                   i_units,
                   i_size)
SELECT c_last_name,
       c_first_name,
       s_store_name,
       Sum(netpaid) paid
FROM   ssales
WHERE  i_color = 'papaya'
GROUP  BY c_last_name,
          c_first_name,
          s_store_name
HAVING Sum(netpaid) > (SELECT 0.05 * Avg(netpaid)
                       FROM   ssales);

-- TPCDS query 25:
-- query25
SELECT i_item_id,
               i_item_desc,
               s_store_id,
               s_store_name,
               Max(ss_net_profit) AS store_sales_profit,
               Max(sr_net_loss)   AS store_returns_loss,
               Max(cs_net_profit) AS catalog_sales_profit
FROM   store_sales,
       store_returns,
       catalog_sales,
       date_dim d1,
       date_dim d2,
       date_dim d3,
       store,
       item
WHERE  d1.d_moy = 4
       AND d1.d_year = 2001
       AND d1.d_date_sk = ss_sold_date_sk
       AND i_item_sk = ss_item_sk
       AND s_store_sk = ss_store_sk
       AND ss_customer_sk = sr_customer_sk
       AND ss_item_sk = sr_item_sk
       AND ss_ticket_number = sr_ticket_number
       AND sr_returned_date_sk = d2.d_date_sk
       AND d2.d_moy BETWEEN 4 AND 10
       AND d2.d_year = 2001
       AND sr_customer_sk = cs_bill_customer_sk
       AND sr_item_sk = cs_item_sk
       AND cs_sold_date_sk = d3.d_date_sk
       AND d3.d_moy BETWEEN 4 AND 10
       AND d3.d_year = 2001
GROUP  BY i_item_id,
          i_item_desc,
          s_store_id,
          s_store_name
ORDER  BY i_item_id,
          i_item_desc,
          s_store_id,
          s_store_name
LIMIT 100;

-- TPCDS query 26:
-- query26
SELECT i_item_id,
               Avg(cs_quantity)    agg1,
               Avg(cs_list_price)  agg2,
               Avg(cs_coupon_amt)  agg3,
               Avg(cs_sales_price) agg4
FROM   catalog_sales,
       customer_demographics,
       date_dim,
       item,
       promotion
WHERE  cs_sold_date_sk = d_date_sk
       AND cs_item_sk = i_item_sk
       AND cs_bill_cdemo_sk = cd_demo_sk
       AND cs_promo_sk = p_promo_sk
       AND cd_gender = 'F'
       AND cd_marital_status = 'W'
       AND cd_education_status = 'Secondary'
       AND ( p_channel_email = 'N'
              OR p_channel_event = 'N' )
       AND d_year = 2000
GROUP  BY i_item_id
ORDER  BY i_item_id
LIMIT 100;

-- TPCDS query 27:
-- query27
SELECT i_item_id,
               s_state,
               Avg(ss_quantity)    agg1,
               Avg(ss_list_price)  agg2,
               Avg(ss_coupon_amt)  agg3,
               Avg(ss_sales_price) agg4
FROM   store_sales,
       customer_demographics,
       date_dim,
       store,
       item
WHERE  ss_sold_date_sk = d_date_sk
       AND ss_item_sk = i_item_sk
       AND ss_store_sk = s_store_sk
       AND ss_cdemo_sk = cd_demo_sk
       AND cd_gender = 'M'
       AND cd_marital_status = 'D'
       AND cd_education_status = 'College'
       AND d_year = 2000
       AND s_state IN ( 'TN', 'TN', 'TN', 'TN',
                        'TN', 'TN' )
GROUP  BY i_item_id, s_state
ORDER  BY i_item_id,
          s_state
LIMIT 100;

-- TPCDS query 28:
-- query28
SELECT *
FROM   (SELECT Avg(ss_list_price)            B1_LP,
               Count(ss_list_price)          B1_CNT,
               Count(DISTINCT ss_list_price) B1_CNTD
        FROM   store_sales
        WHERE  ss_quantity BETWEEN 0 AND 5
               AND ( ss_list_price BETWEEN 18 AND 18 + 10
                      OR ss_coupon_amt BETWEEN 1939 AND 1939 + 1000
                      OR ss_wholesale_cost BETWEEN 34 AND 34 + 20 )) B1,
       (SELECT Avg(ss_list_price)            B2_LP,
               Count(ss_list_price)          B2_CNT,
               Count(DISTINCT ss_list_price) B2_CNTD
        FROM   store_sales
        WHERE  ss_quantity BETWEEN 6 AND 10
               AND ( ss_list_price BETWEEN 1 AND 1 + 10
                      OR ss_coupon_amt BETWEEN 35 AND 35 + 1000
                      OR ss_wholesale_cost BETWEEN 50 AND 50 + 20 )) B2,
       (SELECT Avg(ss_list_price)            B3_LP,
               Count(ss_list_price)          B3_CNT,
               Count(DISTINCT ss_list_price) B3_CNTD
        FROM   store_sales
        WHERE  ss_quantity BETWEEN 11 AND 15
               AND ( ss_list_price BETWEEN 91 AND 91 + 10
                      OR ss_coupon_amt BETWEEN 1412 AND 1412 + 1000
                      OR ss_wholesale_cost BETWEEN 17 AND 17 + 20 )) B3,
       (SELECT Avg(ss_list_price)            B4_LP,
               Count(ss_list_price)          B4_CNT,
               Count(DISTINCT ss_list_price) B4_CNTD
        FROM   store_sales
        WHERE  ss_quantity BETWEEN 16 AND 20
               AND ( ss_list_price BETWEEN 9 AND 9 + 10
                      OR ss_coupon_amt BETWEEN 5270 AND 5270 + 1000
                      OR ss_wholesale_cost BETWEEN 29 AND 29 + 20 )) B4,
       (SELECT Avg(ss_list_price)            B5_LP,
               Count(ss_list_price)          B5_CNT,
               Count(DISTINCT ss_list_price) B5_CNTD
        FROM   store_sales
        WHERE  ss_quantity BETWEEN 21 AND 25
               AND ( ss_list_price BETWEEN 45 AND 45 + 10
                      OR ss_coupon_amt BETWEEN 826 AND 826 + 1000
                      OR ss_wholesale_cost BETWEEN 5 AND 5 + 20 )) B5,
       (SELECT Avg(ss_list_price)            B6_LP,
               Count(ss_list_price)          B6_CNT,
               Count(DISTINCT ss_list_price) B6_CNTD
        FROM   store_sales
        WHERE  ss_quantity BETWEEN 26 AND 30
               AND ( ss_list_price BETWEEN 174 AND 174 + 10
                      OR ss_coupon_amt BETWEEN 5548 AND 5548 + 1000
                      OR ss_wholesale_cost BETWEEN 42 AND 42 + 20 )) B6
LIMIT 100;

-- TPCDS query 29:
-- query29
SELECT i_item_id,
               i_item_desc,
               s_store_id,
               s_store_name,
               Avg(ss_quantity)        AS store_sales_quantity,
               Avg(sr_return_quantity) AS store_returns_quantity,
               Avg(cs_quantity)        AS catalog_sales_quantity
FROM   store_sales,
       store_returns,
       catalog_sales,
       date_dim d1,
       date_dim d2,
       date_dim d3,
       store,
       item
WHERE  d1.d_moy = 4
       AND d1.d_year = 1998
       AND d1.d_date_sk = ss_sold_date_sk
       AND i_item_sk = ss_item_sk
       AND s_store_sk = ss_store_sk
       AND ss_customer_sk = sr_customer_sk
       AND ss_item_sk = sr_item_sk
       AND ss_ticket_number = sr_ticket_number
       AND sr_returned_date_sk = d2.d_date_sk
       AND d2.d_moy BETWEEN 4 AND 4 + 3
       AND d2.d_year = 1998
       AND sr_customer_sk = cs_bill_customer_sk
       AND sr_item_sk = cs_item_sk
       AND cs_sold_date_sk = d3.d_date_sk
       AND d3.d_year IN ( 1998, 1998 + 1, 1998 + 2 )
GROUP  BY i_item_id,
          i_item_desc,
          s_store_id,
          s_store_name
ORDER  BY i_item_id,
          i_item_desc,
          s_store_id,
          s_store_name
LIMIT 100;

-- TPCDS query 30:
-- query30
WITH customer_total_return
     AS (SELECT wr_returning_customer_sk AS ctr_customer_sk,
                ca_state                 AS ctr_state,
                Sum(wr_return_amt)       AS ctr_total_return
         FROM   web_returns,
                date_dim,
                customer_address
         WHERE  wr_returned_date_sk = d_date_sk
                AND d_year = 2000
                AND wr_returning_addr_sk = ca_address_sk
         GROUP  BY wr_returning_customer_sk,
                   ca_state)
SELECT c_customer_id,
               c_salutation,
               c_first_name,
               c_last_name,
               c_preferred_cust_flag,
               c_birth_day,
               c_birth_month,
               c_birth_year,
               c_birth_country,
               c_login,
               c_email_address,
               c_last_review_date,
               ctr_total_return
FROM   customer_total_return ctr1,
       customer_address,
       customer
WHERE  ctr1.ctr_total_return > (SELECT Avg(ctr_total_return) * 1.2
                                FROM   customer_total_return ctr2
                                WHERE  ctr1.ctr_state = ctr2.ctr_state)
       AND ca_address_sk = c_current_addr_sk
       AND ca_state = 'IN'
       AND ctr1.ctr_customer_sk = c_customer_sk
ORDER  BY c_customer_id,
          c_salutation,
          c_first_name,
          c_last_name,
          c_preferred_cust_flag,
          c_birth_day,
          c_birth_month,
          c_birth_year,
          c_birth_country,
          c_login,
          c_email_address,
          c_last_review_date,
          ctr_total_return
LIMIT 100;

-- TPCDS query 31:
-- query31
WITH ss
     AS (SELECT ca_county,
                d_qoy,
                d_year,
                Sum(ss_ext_sales_price) AS store_sales
         FROM   store_sales,
                date_dim,
                customer_address
         WHERE  ss_sold_date_sk = d_date_sk
                AND ss_addr_sk = ca_address_sk
         GROUP  BY ca_county,
                   d_qoy,
                   d_year),
     ws
     AS (SELECT ca_county,
                d_qoy,
                d_year,
                Sum(ws_ext_sales_price) AS web_sales
         FROM   web_sales,
                date_dim,
                customer_address
         WHERE  ws_sold_date_sk = d_date_sk
                AND ws_bill_addr_sk = ca_address_sk
         GROUP  BY ca_county,
                   d_qoy,
                   d_year)
SELECT ss1.ca_county,
       ss1.d_year,
       ws2.web_sales / ws1.web_sales     web_q1_q2_increase,
       ss2.store_sales / ss1.store_sales store_q1_q2_increase,
       ws3.web_sales / ws2.web_sales     web_q2_q3_increase,
       ss3.store_sales / ss2.store_sales store_q2_q3_increase
FROM   ss ss1,
       ss ss2,
       ss ss3,
       ws ws1,
       ws ws2,
       ws ws3
WHERE  ss1.d_qoy = 1
       AND ss1.d_year = 2001
       AND ss1.ca_county = ss2.ca_county
       AND ss2.d_qoy = 2
       AND ss2.d_year = 2001
       AND ss2.ca_county = ss3.ca_county
       AND ss3.d_qoy = 3
       AND ss3.d_year = 2001
       AND ss1.ca_county = ws1.ca_county
       AND ws1.d_qoy = 1
       AND ws1.d_year = 2001
       AND ws1.ca_county = ws2.ca_county
       AND ws2.d_qoy = 2
       AND ws2.d_year = 2001
       AND ws1.ca_county = ws3.ca_county
       AND ws3.d_qoy = 3
       AND ws3.d_year = 2001
       AND CASE
             WHEN ws1.web_sales > 0 THEN ws2.web_sales / ws1.web_sales
             ELSE NULL
           END > CASE
                   WHEN ss1.store_sales > 0 THEN
                   ss2.store_sales / ss1.store_sales
                   ELSE NULL
                 END
       AND CASE
             WHEN ws2.web_sales > 0 THEN ws3.web_sales / ws2.web_sales
             ELSE NULL
           END > CASE
                   WHEN ss2.store_sales > 0 THEN
                   ss3.store_sales / ss2.store_sales
                   ELSE NULL
                 END
ORDER  BY ss1.d_year;

-- TPCDS query 32:
-- query32
SELECT
       Sum(cs_ext_discount_amt) AS excess_discount_amount
FROM   catalog_sales ,
       item ,
       date_dim
WHERE  i_manufact_id = 610
AND    i_item_sk = cs_item_sk
AND    Cast(d_date AS DATE) BETWEEN Cast('2001-03-04' AS DATE) AND    (
              Cast('2001-06-03' AS DATE))
AND    d_date_sk = cs_sold_date_sk
AND    cs_ext_discount_amt >
       (
              SELECT 1.3 * avg(cs_ext_discount_amt)
              FROM   catalog_sales ,
                     date_dim
              WHERE  cs_item_sk = i_item_sk
              AND    Cast(d_date AS DATE) BETWEEN Cast('2001-03-04' AS DATE) AND    (
                            Cast('2001-06-03' AS DATE))
              AND    d_date_sk = cs_sold_date_sk )
LIMIT 100;


-- TPCDS query 33:
-- query33
WITH ss
     AS (SELECT i_manufact_id,
                Sum(ss_ext_sales_price) total_sales
         FROM   store_sales,
                date_dim,
                customer_address,
                item
         WHERE  i_manufact_id IN (SELECT i_manufact_id
                                  FROM   item
                                  WHERE  i_category IN ( 'Books' ))
                AND ss_item_sk = i_item_sk
                AND ss_sold_date_sk = d_date_sk
                AND d_year = 1999
                AND d_moy = 3
                AND ss_addr_sk = ca_address_sk
                AND ca_gmt_offset = -5
         GROUP  BY i_manufact_id),
     cs
     AS (SELECT i_manufact_id,
                Sum(cs_ext_sales_price) total_sales
         FROM   catalog_sales,
                date_dim,
                customer_address,
                item
         WHERE  i_manufact_id IN (SELECT i_manufact_id
                                  FROM   item
                                  WHERE  i_category IN ( 'Books' ))
                AND cs_item_sk = i_item_sk
                AND cs_sold_date_sk = d_date_sk
                AND d_year = 1999
                AND d_moy = 3
                AND cs_bill_addr_sk = ca_address_sk
                AND ca_gmt_offset = -5
         GROUP  BY i_manufact_id),
     ws
     AS (SELECT i_manufact_id,
                Sum(ws_ext_sales_price) total_sales
         FROM   web_sales,
                date_dim,
                customer_address,
                item
         WHERE  i_manufact_id IN (SELECT i_manufact_id
                                  FROM   item
                                  WHERE  i_category IN ( 'Books' ))
                AND ws_item_sk = i_item_sk
                AND ws_sold_date_sk = d_date_sk
                AND d_year = 1999
                AND d_moy = 3
                AND ws_bill_addr_sk = ca_address_sk
                AND ca_gmt_offset = -5
         GROUP  BY i_manufact_id)
SELECT i_manufact_id,
               Sum(total_sales) total_sales
FROM   (SELECT *
        FROM   ss
        UNION ALL
        SELECT *
        FROM   cs
        UNION ALL
        SELECT *
        FROM   ws) tmp1
GROUP  BY i_manufact_id
ORDER  BY total_sales
LIMIT 100;

-- TPCDS query 34:
-- query34
SELECT c_last_name,
       c_first_name,
       c_salutation,
       c_preferred_cust_flag,
       ss_ticket_number,
       cnt
FROM   (SELECT ss_ticket_number,
               ss_customer_sk,
               Count(*) cnt
        FROM   store_sales,
               date_dim,
               store,
               household_demographics
        WHERE  store_sales.ss_sold_date_sk = date_dim.d_date_sk
               AND store_sales.ss_store_sk = store.s_store_sk
               AND store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
               AND ( date_dim.d_dom BETWEEN 1 AND 3
                      OR date_dim.d_dom BETWEEN 25 AND 28 )
               AND ( household_demographics.hd_buy_potential = '>10000'
                      OR household_demographics.hd_buy_potential = 'unknown' )
               AND household_demographics.hd_vehicle_count > 0
               AND ( CASE
                       WHEN household_demographics.hd_vehicle_count > 0 THEN
                       household_demographics.hd_dep_count /
                       household_demographics.hd_vehicle_count
                       ELSE NULL
                     END ) > 1.2
               AND date_dim.d_year IN ( 1999, 1999 + 1, 1999 + 2 )
               AND store.s_county IN ( 'Williamson County', 'Williamson County',
                                       'Williamson County',
                                                             'Williamson County'
                                       ,
                                       'Williamson County', 'Williamson County',
                                           'Williamson County',
                                                             'Williamson County'
                                     )
        GROUP  BY ss_ticket_number,
                  ss_customer_sk) dn,
       customer
WHERE  ss_customer_sk = c_customer_sk
       AND cnt BETWEEN 15 AND 20
ORDER  BY c_last_name,
          c_first_name,
          c_salutation,
          c_preferred_cust_flag DESC;

-- TPCDS query 35:
-- start query 1 in stream 0 using template query35a.tpl
select
  ca_state,
  cd_gender,
  cd_marital_status,
  cd_dep_count,
  count(*) cnt1,
  avg(cd_dep_count),
  max(cd_dep_count),
  sum(cd_dep_count),
  cd_dep_employed_count,
  count(*) cnt2,
  avg(cd_dep_employed_count),
  max(cd_dep_employed_count),
  sum(cd_dep_employed_count),
  cd_dep_college_count,
  count(*) cnt3,
  avg(cd_dep_college_count),
  max(cd_dep_college_count),
  sum(cd_dep_college_count)
 from
  customer c,customer_address ca,customer_demographics
 where
  c.c_current_addr_sk = ca.ca_address_sk and
  cd_demo_sk = c.c_current_cdemo_sk and
  exists (select *
          from store_sales,date_dim
          where c.c_customer_sk = ss_customer_sk and
                ss_sold_date_sk = d_date_sk and
                d_year = 2001 and
                d_qoy < 4) and
   exists (select * from
	   (select ws_bill_customer_sk customsk
            from web_sales,date_dim
            where
                  ws_sold_date_sk = d_date_sk and
                  d_year = 2001 and
                  d_qoy < 4
	    union all
    	    select cs_ship_customer_sk customsk
            from catalog_sales,date_dim
            where
                  cs_sold_date_sk = d_date_sk and
                  d_year = 2001 and
                  d_qoy < 4)x
           where x.customsk = c.c_customer_sk)
 group by ca_state,
          cd_gender,
          cd_marital_status,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
 order by ca_state,
          cd_gender,
          cd_marital_status,
          cd_dep_count,
          cd_dep_employed_count,
          cd_dep_college_count
 limit 100;



-- TPCDS query 36:
-- query36
SELECT Sum(ss_net_profit) / Sum(ss_ext_sales_price)                 AS
               gross_margin,
               i_category,
               i_class,
               Rank()
                 OVER (
                   PARTITION BY i_category, i_class
                   ORDER BY Sum(ss_net_profit)/Sum(ss_ext_sales_price) ASC) AS
               rank_within_parent
FROM   store_sales,
       date_dim d1,
       item,
       store
WHERE  d1.d_year = 2000
       AND d1.d_date_sk = ss_sold_date_sk
       AND i_item_sk = ss_item_sk
       AND s_store_sk = ss_store_sk
       AND s_state IN ( 'TN', 'TN', 'TN', 'TN',
                        'TN', 'TN', 'TN', 'TN' )
GROUP  BY i_category, i_class
ORDER  BY i_category,
          rank_within_parent
LIMIT 100;

-- TPCDS query 37:
-- query37
SELECT
         i_item_id ,
         i_item_desc ,
         i_current_price
FROM     item,
         inventory,
         date_dim,
         catalog_sales
WHERE    i_current_price BETWEEN 20 AND      20 + 30
AND      inv_item_sk = i_item_sk
AND      d_date_sk=inv_date_sk
AND      Cast(d_date AS DATE) BETWEEN Cast('1999-03-06' AS DATE) AND Cast('1999-05-06' AS DATE)
AND      i_manufact_id IN (843,815,850,840)
AND      inv_quantity_on_hand BETWEEN 100 AND      500
AND      cs_item_sk = i_item_sk
GROUP BY i_item_id,
         i_item_desc,
         i_current_price
ORDER BY i_item_id
LIMIT 100;


-- TPCDS query 38:
-- query38
WITH g1 AS (
        SELECT DISTINCT c_last_name,
                        c_first_name,
                        d_date
        FROM   store_sales,
               date_dim,
               customer
        WHERE  store_sales.ss_sold_date_sk = date_dim.d_date_sk
               AND store_sales.ss_customer_sk = customer.c_customer_sk
               AND d_month_seq BETWEEN 1188 AND 1188 + 11
), g2 AS (
        SELECT DISTINCT c_last_name,
                        c_first_name,
                        d_date
        FROM   catalog_sales,
               date_dim,
               customer
        WHERE  catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
               AND catalog_sales.cs_bill_customer_sk = customer.c_customer_sk
               AND d_month_seq BETWEEN 1188 AND 1188 + 11
), g3 AS (
        SELECT DISTINCT c_last_name,
                        c_first_name,
                        d_date
        FROM   web_sales,
               date_dim,
               customer
        WHERE  web_sales.ws_sold_date_sk = date_dim.d_date_sk
               AND web_sales.ws_bill_customer_sk = customer.c_customer_sk
               AND d_month_seq BETWEEN 1188 AND 1188 + 11
)
SELECT Count(*)
FROM   g1
JOIN g2 ON g1.c_last_name = g2.c_last_name AND g1.c_first_name = g2.c_first_name AND g1.d_date = g2.d_date
JOIN g3 ON g1.c_last_name = g3.c_last_name AND g1.c_first_name = g3.c_first_name AND g1.d_date = g3.d_date
LIMIT 100;

-- TPCDS query 39:
-- query39
WITH inv
     AS (SELECT w_warehouse_name,
                w_warehouse_sk,
                i_item_sk,
                d_moy,
                stdev,
                mean,
                CASE mean
                  WHEN 0 THEN NULL
                  ELSE stdev / mean
                END cov
         FROM  (SELECT w_warehouse_name,
                       w_warehouse_sk,
                       i_item_sk,
                       d_moy,
                       Stddev_samp(inv_quantity_on_hand) stdev,
                       Avg(inv_quantity_on_hand)         mean
                FROM   inventory,
                       item,
                       warehouse,
                       date_dim
                WHERE  inv_item_sk = i_item_sk
                       AND inv_warehouse_sk = w_warehouse_sk
                       AND inv_date_sk = d_date_sk
                       AND d_year = 2002
                GROUP  BY w_warehouse_name,
                          w_warehouse_sk,
                          i_item_sk,
                          d_moy) foo
         WHERE  CASE mean
                  WHEN 0 THEN 0
                  ELSE stdev / mean
                END > 1)
SELECT inv1.w_warehouse_sk,
       inv1.i_item_sk,
       inv1.d_moy,
       inv1.mean,
       inv1.cov,
       inv2.w_warehouse_sk AS w_warehouse_sk_2,
       inv2.i_item_sk AS i_item_sk_2,
       inv2.d_moy AS d_moy_2,
       inv2.mean AS mean_2,
       inv2.cov AS cov_2
FROM   inv inv1,
       inv inv2
WHERE  inv1.i_item_sk = inv2.i_item_sk
       AND inv1.w_warehouse_sk = inv2.w_warehouse_sk
       AND inv1.d_moy = 1
       AND inv2.d_moy = 1 + 1
ORDER  BY inv1.w_warehouse_sk,
          inv1.i_item_sk,
          inv1.d_moy,
          inv1.mean,
          inv1.cov,
          inv2.d_moy,
          inv2.mean,
          inv2.cov;
-- TPCDS query 40:
-- query40
SELECT
                w_state ,
                i_item_id ,
                Sum(
                CASE
                                WHEN (
                                                                Cast(d_date AS DATE) < Cast ('2002-06-01' AS DATE)) THEN cs_sales_price - COALESCE(cr_refunded_cash,0)
                                ELSE 0
                END) AS sales_before ,
                Sum(
                CASE
                                WHEN (
                                                                Cast(d_date AS DATE) >= Cast ('2002-06-01' AS DATE)) THEN cs_sales_price - COALESCE(cr_refunded_cash,0)
                                ELSE 0
                END) AS sales_after
FROM            catalog_sales
LEFT OUTER JOIN catalog_returns
ON              (
                                cs_order_number = cr_order_number
                AND             cs_item_sk = cr_item_sk) ,
                warehouse ,
                item ,
                date_dim
WHERE           i_current_price BETWEEN 0.99 AND             1.49
AND             i_item_sk = cs_item_sk
AND             cs_warehouse_sk = w_warehouse_sk
AND             cs_sold_date_sk = d_date_sk
AND             Cast(d_date AS DATE) BETWEEN (Cast ('2002-05-01' AS DATE)) AND cast ('2002-07-01' AS date)
GROUP BY        w_state,
                i_item_id
ORDER BY        w_state,
                i_item_id
LIMIT 100;


-- TPCDS query 41:
-- start query 1 in stream 0 using template query41.tpl
-- (bcm) alternative form of query41 to get around the aggregation in correlated subquery issue

select i0.i_product_name, i0.i_manufact_id, count(*)
from item i0, item i1
where
      i0.i_manufact_id between 765 and 765+40
  and i0.i_manufact = i1.i_manufact and
        ((i1.i_category = 'Women' and
        (i1.i_color = 'dim' or i1.i_color = 'green') and
        (i1.i_units = 'Gross' or i1.i_units = 'Dozen') and
        (i1.i_size = 'economy' or i1.i_size = 'petite')
        ) or
        (i1.i_category = 'Women' and
        (i1.i_color = 'navajo' or i1.i_color = 'aquamarine') and
        (i1.i_units = 'Case' or i1.i_units = 'Unknown') and
        (i1.i_size = 'N/A' or i1.i_size = 'large')
        ) or
        (i1.i_category = 'Men' and
        (i1.i_color = 'indian' or i1.i_color = 'dark') and
        (i1.i_units = 'Oz' or i1.i_units = 'Lb') and
        (i1.i_size = 'extra large' or i1.i_size = 'small')
        ) or
        (i1.i_category = 'Men' and
        (i1.i_color = 'peach' or i1.i_color = 'purple') and
        (i1.i_units = 'Tbl' or i1.i_units = 'Bunch') and
        (i1.i_size = 'economy' or i1.i_size = 'petite')
        )) or
       (i0.i_manufact = i1.i_manufact and
        ((i1.i_category = 'Women' and
        (i1.i_color = 'orchid' or i1.i_color = 'peru') and
        (i1.i_units = 'Carton' or i1.i_units = 'Cup') and
        (i1.i_size = 'economy' or i1.i_size = 'petite')
        ) or
        (i1.i_category = 'Women' and
        (i1.i_color = 'violet' or i1.i_color = 'papaya') and
        (i1.i_units = 'Ounce' or i1.i_units = 'Box') and
        (i1.i_size = 'large' or i1.i_size = 'N/A')
        ) or
        (i1.i_category = 'Men' and
        (i1.i_color = 'drab' or i1.i_color = 'grey') and
        (i1.i_units = 'Each' or i1.i_units = 'N/A') and
        (i1.i_size = 'extra large' or i1.i_size = 'small')
        ) or
        (i1.i_category = 'Men' and
        (i1.i_color = 'chocolate' or i1.i_color = 'antique') and
        (i1.i_units = 'Dram' or i1.i_units = 'Gram') and
        (i1.i_size = 'economy' or i1.i_size = 'petite')
        )))
group by i0.i_product_name, i0.i_manufact_id
having count(*) > 0
order by i0.i_product_name
limit 100
;

-- end query 1 in stream 0 using template query41.tpl

-- TPCDS query 42:
-- query42
SELECT dt.d_year,
               item.i_category_id,
               item.i_category,
               Sum(ss_ext_sales_price)
FROM   date_dim dt,
       store_sales,
       item
WHERE  dt.d_date_sk = store_sales.ss_sold_date_sk
       AND store_sales.ss_item_sk = item.i_item_sk
       AND item.i_manager_id = 1
       AND dt.d_moy = 12
       AND dt.d_year = 2000
GROUP  BY dt.d_year,
          item.i_category_id,
          item.i_category
ORDER  BY Sum(ss_ext_sales_price) DESC,
          dt.d_year,
          item.i_category_id,
          item.i_category
LIMIT 100;

-- TPCDS query 43:
-- query43
SELECT s_store_name,
               s_store_id,
               Sum(CASE
                     WHEN ( d_day_name = 'Sunday' ) THEN ss_sales_price
                     ELSE NULL
                   END) sun_sales,
               Sum(CASE
                     WHEN ( d_day_name = 'Monday' ) THEN ss_sales_price
                     ELSE NULL
                   END) mon_sales,
               Sum(CASE
                     WHEN ( d_day_name = 'Tuesday' ) THEN ss_sales_price
                     ELSE NULL
                   END) tue_sales,
               Sum(CASE
                     WHEN ( d_day_name = 'Wednesday' ) THEN ss_sales_price
                     ELSE NULL
                   END) wed_sales,
               Sum(CASE
                     WHEN ( d_day_name = 'Thursday' ) THEN ss_sales_price
                     ELSE NULL
                   END) thu_sales,
               Sum(CASE
                     WHEN ( d_day_name = 'Friday' ) THEN ss_sales_price
                     ELSE NULL
                   END) fri_sales,
               Sum(CASE
                     WHEN ( d_day_name = 'Saturday' ) THEN ss_sales_price
                     ELSE NULL
                   END) sat_sales
FROM   date_dim,
       store_sales,
       store
WHERE  d_date_sk = ss_sold_date_sk
       AND s_store_sk = ss_store_sk
       AND s_gmt_offset = -5
       AND d_year = 2002
GROUP  BY s_store_name,
          s_store_id
ORDER  BY s_store_name,
          s_store_id,
          sun_sales,
          mon_sales,
          tue_sales,
          wed_sales,
          thu_sales,
          fri_sales,
          sat_sales
LIMIT 100;

-- TPCDS query 44:
-- query44
SELECT asceding.rnk,
               i1.i_product_name best_performing,
               i2.i_product_name worst_performing
FROM  (SELECT *
       FROM   (SELECT item_sk,
                      Rank()
                        OVER (
                          ORDER BY rank_col ASC) rnk
               FROM   (SELECT ss_item_sk         item_sk,
                              Avg(ss_net_profit) rank_col
                       FROM   store_sales ss1
                       WHERE  ss_store_sk = 4
                       GROUP  BY ss_item_sk
                       HAVING Avg(ss_net_profit) > 0.9 *
                              (SELECT Avg(ss_net_profit)
                                      rank_col
                               FROM   store_sales
                               WHERE  ss_store_sk = 4
                                      AND ss_cdemo_sk IS
                                          NULL
                               GROUP  BY ss_store_sk))V1)
              V11
       WHERE  rnk < 11) asceding,
      (SELECT *
       FROM   (SELECT item_sk,
                      Rank()
                        OVER (
                          ORDER BY rank_col DESC) rnk
               FROM   (SELECT ss_item_sk         item_sk,
                              Avg(ss_net_profit) rank_col
                       FROM   store_sales ss1
                       WHERE  ss_store_sk = 4
                       GROUP  BY ss_item_sk
                       HAVING Avg(ss_net_profit) > 0.9 *
                              (SELECT Avg(ss_net_profit)
                                      rank_col
                               FROM   store_sales
                               WHERE  ss_store_sk = 4
                                      AND ss_cdemo_sk IS
                                          NULL
                               GROUP  BY ss_store_sk))V2)
              V21
       WHERE  rnk < 11) descending,
      item i1,
      item i2
WHERE  asceding.rnk = descending.rnk
       AND i1.i_item_sk = asceding.item_sk
       AND i2.i_item_sk = descending.item_sk
ORDER  BY asceding.rnk
LIMIT 100;

-- TPCDS query 45:
-- query45
SELECT ca_zip,
               ca_state,
               Sum(ws_sales_price)
FROM   web_sales,
       customer,
       customer_address,
       date_dim,
       item
WHERE  ws_bill_customer_sk = c_customer_sk
       AND c_current_addr_sk = ca_address_sk
       AND ws_item_sk = i_item_sk
       AND ( Substr(ca_zip, 1, 5) IN ( '85669', '86197', '88274', '83405',
                                       '86475', '85392', '85460', '80348',
                                       '81792' )
              OR i_item_id IN (SELECT i_item_id
                               FROM   item
                               WHERE  i_item_sk IN ( 2, 3, 5, 7,
                                                     11, 13, 17, 19,
                                                     23, 29 )) )
       AND ws_sold_date_sk = d_date_sk
       AND d_qoy = 1
       AND d_year = 2000
GROUP  BY ca_zip,
          ca_state
ORDER  BY ca_zip,
          ca_state
LIMIT 100;

-- TPCDS query 46:
-- query46
SELECT c_last_name,
               c_first_name,
               ca_city,
               bought_city,
               ss_ticket_number,
               amt,
               profit
FROM   (SELECT ss_ticket_number,
               ss_customer_sk,
               ca_city            bought_city,
               Sum(ss_coupon_amt) amt,
               Sum(ss_net_profit) profit
        FROM   store_sales,
               date_dim,
               store,
               household_demographics,
               customer_address
        WHERE  store_sales.ss_sold_date_sk = date_dim.d_date_sk
               AND store_sales.ss_store_sk = store.s_store_sk
               AND store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
               AND store_sales.ss_addr_sk = customer_address.ca_address_sk
               AND ( household_demographics.hd_dep_count = 6
                      OR household_demographics.hd_vehicle_count = 0 )
               AND date_dim.d_dow IN ( 6, 0 )
               AND date_dim.d_year IN ( 2000, 2000 + 1, 2000 + 2 )
               AND store.s_city IN ( 'Midway', 'Fairview', 'Fairview',
                                     'Fairview',
                                     'Fairview' )
        GROUP  BY ss_ticket_number,
                  ss_customer_sk,
                  ss_addr_sk,
                  ca_city) dn,
       customer,
       customer_address current_addr
WHERE  ss_customer_sk = c_customer_sk
       AND customer.c_current_addr_sk = current_addr.ca_address_sk
       AND current_addr.ca_city <> bought_city
ORDER  BY c_last_name,
          c_first_name,
          ca_city,
          bought_city,
          ss_ticket_number
LIMIT 100;

-- TPCDS query 47:
-- query47
WITH v1
     AS (SELECT i_category,
                i_brand,
                s_store_name,
                s_company_name,
                d_year,
                d_moy,
                Sum(ss_sales_price)         sum_sales,
                Avg(Sum(ss_sales_price))
                  OVER (
                    partition BY i_category, i_brand, s_store_name,
                  s_company_name,
                  d_year)
                                            avg_monthly_sales,
                Rank()
                  OVER (
                    partition BY i_category, i_brand, s_store_name,
                  s_company_name
                    ORDER BY d_year, d_moy) rn
         FROM   item,
                store_sales,
                date_dim,
                store
         WHERE  ss_item_sk = i_item_sk
                AND ss_sold_date_sk = d_date_sk
                AND ss_store_sk = s_store_sk
                AND ( d_year = 1999
                       OR ( d_year = 1999 - 1
                            AND d_moy = 12 )
                       OR ( d_year = 1999 + 1
                            AND d_moy = 1 ) )
         GROUP  BY i_category,
                   i_brand,
                   s_store_name,
                   s_company_name,
                   d_year,
                   d_moy),
     v2
     AS (SELECT v1.i_category,
                v1.d_year,
                v1.d_moy,
                v1.avg_monthly_sales,
                v1.sum_sales,
                v1_lag.sum_sales  psum,
                v1_lead.sum_sales nsum
         FROM   v1,
                v1 v1_lag,
                v1 v1_lead
         WHERE  v1.i_category = v1_lag.i_category
                AND v1.i_category = v1_lead.i_category
                AND v1.i_brand = v1_lag.i_brand
                AND v1.i_brand = v1_lead.i_brand
                AND v1.s_store_name = v1_lag.s_store_name
                AND v1.s_store_name = v1_lead.s_store_name
                AND v1.s_company_name = v1_lag.s_company_name
                AND v1.s_company_name = v1_lead.s_company_name
                AND v1.rn = v1_lag.rn + 1
                AND v1.rn = v1_lead.rn - 1)
SELECT *
FROM   v2
WHERE  d_year = 1999
       AND avg_monthly_sales > 0
       AND CASE
             WHEN avg_monthly_sales > 0 THEN Abs(sum_sales - avg_monthly_sales)
                                             /
                                             avg_monthly_sales
             ELSE NULL
           END > 0.1
ORDER  BY sum_sales - avg_monthly_sales,
          3
LIMIT 100;

-- TPCDS query 48:
-- query48
SELECT Sum (ss_quantity)
FROM   store_sales,
       store,
       customer_demographics,
       customer_address,
       date_dim
WHERE  s_store_sk = ss_store_sk
       AND ss_sold_date_sk = d_date_sk
       AND d_year = 1999
       AND ( ( cd_demo_sk = ss_cdemo_sk
               AND cd_marital_status = 'W'
               AND cd_education_status = 'Secondary'
               AND ss_sales_price BETWEEN 100.00 AND 150.00 )
              OR ( cd_demo_sk = ss_cdemo_sk
                   AND cd_marital_status = 'M'
                   AND cd_education_status = 'Advanced Degree'
                   AND ss_sales_price BETWEEN 50.00 AND 100.00 )
              OR ( cd_demo_sk = ss_cdemo_sk
                   AND cd_marital_status = 'D'
                   AND cd_education_status = '2 yr Degree'
                   AND ss_sales_price BETWEEN 150.00 AND 200.00 ) )
       AND ( ( ss_addr_sk = ca_address_sk
               AND ca_country = 'United States'
               AND ca_state IN ( 'TX', 'NE', 'MO' )
               AND ss_net_profit BETWEEN 0 AND 2000 )
              OR ( ss_addr_sk = ca_address_sk
                   AND ca_country = 'United States'
                   AND ca_state IN ( 'CO', 'TN', 'ND' )
                   AND ss_net_profit BETWEEN 150 AND 3000 )
              OR ( ss_addr_sk = ca_address_sk
                   AND ca_country = 'United States'
                   AND ca_state IN ( 'OK', 'PA', 'CA' )
                   AND ss_net_profit BETWEEN 50 AND 25000 ) );

-- TPCDS query 49:
-- query49
SELECT 'web' AS channel,
               web.item,
               web.return_ratio,
               web.return_rank,
               web.currency_rank
FROM   (SELECT item,
               return_ratio,
               currency_ratio,
               Rank()
                 OVER (
                   ORDER BY return_ratio)   AS return_rank,
               Rank()
                 OVER (
                   ORDER BY currency_ratio) AS currency_rank
        FROM   (SELECT ws.ws_item_sk AS item,
                       ( Sum(COALESCE(wr.wr_return_quantity, 0)) /
                         Sum(COALESCE(ws.ws_quantity, 0)) ) AS
                       return_ratio,
                       ( Sum(COALESCE(wr.wr_return_amt, 0)) /
                         Sum(COALESCE(ws.ws_net_paid, 0)) ) AS currency_ratio
                FROM   web_sales ws
                       LEFT OUTER JOIN web_returns wr
                                    ON ( ws.ws_order_number = wr.wr_order_number
                                         AND ws.ws_item_sk = wr.wr_item_sk ),
                       date_dim
                WHERE  wr.wr_return_amt > 10000
                       AND ws.ws_net_profit > 1
                       AND ws.ws_net_paid > 0
                       AND ws.ws_quantity > 0
                       AND ws_sold_date_sk = d_date_sk
                       AND d_year = 1999
                       AND d_moy = 12
                GROUP  BY ws.ws_item_sk) in_web) web
WHERE  ( web.return_rank <= 10
          OR web.currency_rank <= 10 )
UNION ALL
SELECT 'catalog' AS channel,
       catalog.item,
       catalog.return_ratio,
       catalog.return_rank,
       catalog.currency_rank
FROM   (SELECT item,
               return_ratio,
               currency_ratio,
               Rank()
                 OVER (
                   ORDER BY return_ratio)   AS return_rank,
               Rank()
                 OVER (
                   ORDER BY currency_ratio) AS currency_rank
        FROM   (SELECT cs.cs_item_sk AS
                       item,
                       ( Sum(COALESCE(cr.cr_return_quantity, 0)) /
                         Sum(COALESCE(cs.cs_quantity, 0)) ) AS
                       return_ratio,
                       ( Sum(COALESCE(cr.cr_return_amount, 0)) /
                         Sum(COALESCE(cs.cs_net_paid, 0)) ) AS
                       currency_ratio
                FROM   catalog_sales cs
                       LEFT OUTER JOIN catalog_returns cr
                                    ON ( cs.cs_order_number = cr.cr_order_number
                                         AND cs.cs_item_sk = cr.cr_item_sk ),
                       date_dim
                WHERE  cr.cr_return_amount > 10000
                       AND cs.cs_net_profit > 1
                       AND cs.cs_net_paid > 0
                       AND cs.cs_quantity > 0
                       AND cs_sold_date_sk = d_date_sk
                       AND d_year = 1999
                       AND d_moy = 12
                GROUP  BY cs.cs_item_sk) in_cat) catalog
WHERE  ( catalog.return_rank <= 10
          OR catalog.currency_rank <= 10 )
UNION ALL
SELECT 'store' AS channel,
       store.item,
       store.return_ratio,
       store.return_rank,
       store.currency_rank
FROM   (SELECT item,
               return_ratio,
               currency_ratio,
               Rank()
                 OVER (
                   ORDER BY return_ratio)   AS return_rank,
               Rank()
                 OVER (
                   ORDER BY currency_ratio) AS currency_rank
        FROM   (SELECT sts.ss_item_sk AS
                       item,
                       ( Sum(COALESCE(sr.sr_return_quantity, 0)) /
                         Sum(COALESCE(sts.ss_quantity, 0)) ) AS
                       return_ratio,
                       ( Sum(COALESCE(sr.sr_return_amt, 0))
                         / Sum(COALESCE(sts.ss_net_paid, 0)) ) AS
                       currency_ratio
                FROM   store_sales sts
                       LEFT OUTER JOIN store_returns sr
                                    ON ( sts.ss_ticket_number =
                                         sr.sr_ticket_number
                                         AND sts.ss_item_sk = sr.sr_item_sk ),
                       date_dim
                WHERE  sr.sr_return_amt > 10000
                       AND sts.ss_net_profit > 1
                       AND sts.ss_net_paid > 0
                       AND sts.ss_quantity > 0
                       AND ss_sold_date_sk = d_date_sk
                       AND d_year = 1999
                       AND d_moy = 12
                GROUP  BY sts.ss_item_sk) in_store) store
WHERE  ( store.return_rank <= 10
          OR store.currency_rank <= 10 )
ORDER  BY 1,
          4,
          5
LIMIT 100;

-- TPCDS query 50:
-- query50
SELECT s_store_name,
               s_company_id,
               s_street_number,
               s_street_name,
               s_street_type,
               s_suite_number,
               s_city,
               s_county,
               s_state,
               s_zip,
               Sum(CASE
                     WHEN ( sr_returned_date_sk - ss_sold_date_sk <= 30 ) THEN 1
                     ELSE 0
                   END) AS days_30,
               Sum(CASE
                     WHEN ( sr_returned_date_sk - ss_sold_date_sk > 30 )
                          AND ( sr_returned_date_sk - ss_sold_date_sk <= 60 )
                   THEN 1
                     ELSE 0
                   END) AS days_31_60,
               Sum(CASE
                     WHEN ( sr_returned_date_sk - ss_sold_date_sk > 60 )
                          AND ( sr_returned_date_sk - ss_sold_date_sk <= 90 )
                   THEN 1
                     ELSE 0
                   END) AS days_61_90,
               Sum(CASE
                     WHEN ( sr_returned_date_sk - ss_sold_date_sk > 90 )
                          AND ( sr_returned_date_sk - ss_sold_date_sk <= 120 )
                   THEN 1
                     ELSE 0
                   END) AS days_91_120,
               Sum(CASE
                     WHEN ( sr_returned_date_sk - ss_sold_date_sk > 120 ) THEN 1
                     ELSE 0
                   END) AS days_over_120
FROM   store_sales,
       store_returns,
       store,
       date_dim d1,
       date_dim d2
WHERE  d2.d_year = 2002
       AND d2.d_moy = 9
       AND ss_ticket_number = sr_ticket_number
       AND ss_item_sk = sr_item_sk
       AND ss_sold_date_sk = d1.d_date_sk
       AND sr_returned_date_sk = d2.d_date_sk
       AND ss_customer_sk = sr_customer_sk
       AND ss_store_sk = s_store_sk
GROUP  BY s_store_name,
          s_company_id,
          s_street_number,
          s_street_name,
          s_street_type,
          s_suite_number,
          s_city,
          s_county,
          s_state,
          s_zip
ORDER  BY s_store_name,
          s_company_id,
          s_street_number,
          s_street_name,
          s_street_type,
          s_suite_number,
          s_city,
          s_county,
          s_state,
          s_zip
LIMIT 100;

-- TPCDS query 51:
-- query51
WITH web_v1 AS
(
         SELECT   ws_item_sk item_sk,
                  d_date,
                  sum(Sum(ws_sales_price)) OVER (partition BY ws_item_sk ORDER BY d_date rows BETWEEN UNBOUNDED PRECEDING AND      CURRENT row) cume_sales
         FROM     web_sales ,
                  date_dim
         WHERE    ws_sold_date_sk=d_date_sk
         AND      d_month_seq BETWEEN 1192 AND      1192+11
         AND      ws_item_sk IS NOT NULL
         GROUP BY ws_item_sk,
                  d_date), store_v1 AS
(
         SELECT   ss_item_sk item_sk,
                  d_date,
                  sum(sum(ss_sales_price)) OVER (partition BY ss_item_sk ORDER BY d_date rows BETWEEN UNBOUNDED PRECEDING AND      CURRENT row) cume_sales
         FROM     store_sales ,
                  date_dim
         WHERE    ss_sold_date_sk=d_date_sk
         AND      d_month_seq BETWEEN 1192 AND      1192+11
         AND      ss_item_sk IS NOT NULL
         GROUP BY ss_item_sk,
                  d_date)
SELECT
         *
FROM     (
                  SELECT   item_sk ,
                           d_date ,
                           web_sales ,
                           store_sales ,
                           max(web_sales) OVER (partition BY item_sk ORDER BY d_date rows BETWEEN UNBOUNDED PRECEDING AND      CURRENT row)   web_cumulative ,
                           max(store_sales) OVER (partition BY item_sk ORDER BY d_date rows BETWEEN UNBOUNDED PRECEDING AND      CURRENT row) store_cumulative
                  FROM     (
                                           SELECT
                                                           CASE
                                                                           WHEN web.item_sk IS NOT NULL THEN web.item_sk
                                                                           ELSE store.item_sk
                                                           END item_sk ,
                                                           CASE
                                                                           WHEN web.d_date IS NOT NULL THEN web.d_date
                                                                           ELSE store.d_date
                                                           END              d_date ,
                                                           web.cume_sales   web_sales ,
                                                           store.cume_sales store_sales
                                           FROM            web_v1 web
                                           FULL OUTER JOIN store_v1 store
                                           ON              (
                                                                           web.item_sk = store.item_sk
                                                           AND             web.d_date = store.d_date) )x )y
WHERE    web_cumulative > store_cumulative
ORDER BY item_sk ,
         d_date
LIMIT 100;


-- TPCDS query 52:
-- query52
SELECT dt.d_year,
               item.i_brand_id         brand_id,
               item.i_brand            brand,
               Sum(ss_ext_sales_price) ext_price
FROM   date_dim dt,
       store_sales,
       item
WHERE  dt.d_date_sk = store_sales.ss_sold_date_sk
       AND store_sales.ss_item_sk = item.i_item_sk
       AND item.i_manager_id = 1
       AND dt.d_moy = 11
       AND dt.d_year = 1999
GROUP  BY dt.d_year,
          item.i_brand,
          item.i_brand_id
ORDER  BY dt.d_year,
          ext_price DESC,
          brand_id
LIMIT 100;

-- TPCDS query 53:
-- query53
SELECT *
FROM   (SELECT i_manufact_id,
               Sum(ss_sales_price)             sum_sales,
               Avg(Sum(ss_sales_price))
                 OVER (
                   partition BY i_manufact_id) avg_quarterly_sales
        FROM   item,
               store_sales,
               date_dim,
               store
        WHERE  ss_item_sk = i_item_sk
               AND ss_sold_date_sk = d_date_sk
               AND ss_store_sk = s_store_sk
               AND d_month_seq IN ( 1199, 1199 + 1, 1199 + 2, 1199 + 3,
                                    1199 + 4, 1199 + 5, 1199 + 6, 1199 + 7,
                                    1199 + 8, 1199 + 9, 1199 + 10, 1199 + 11 )
               AND ( ( i_category IN ( 'Books', 'Children', 'Electronics' )
                       AND i_class IN ( 'personal', 'portable', 'reference',
                                        'self-help' )
                       AND i_brand IN ( 'scholaramalgamalg #14',
                                        'scholaramalgamalg #7'
                                        ,
                                        'exportiunivamalg #9',
                                                       'scholaramalgamalg #9' )
                     )
                      OR ( i_category IN ( 'Women', 'Music', 'Men' )
                           AND i_class IN ( 'accessories', 'classical',
                                            'fragrances',
                                            'pants' )
                           AND i_brand IN ( 'amalgimporto #1',
                                            'edu packscholar #1',
                                            'exportiimporto #1',
                                                'importoamalg #1' ) ) )
        GROUP  BY i_manufact_id,
                  d_qoy) tmp1
WHERE  CASE
         WHEN avg_quarterly_sales > 0 THEN Abs (sum_sales - avg_quarterly_sales)
                                           /
                                           avg_quarterly_sales
         ELSE NULL
       END > 0.1
ORDER  BY avg_quarterly_sales,
          sum_sales,
          i_manufact_id
LIMIT 100;

-- TPCDS query 54:
-- query54
WITH my_customers
     AS (SELECT DISTINCT c_customer_sk,
                         c_current_addr_sk
         FROM   (SELECT cs_sold_date_sk     sold_date_sk,
                        cs_bill_customer_sk customer_sk,
                        cs_item_sk          item_sk
                 FROM   catalog_sales
                 UNION ALL
                 SELECT ws_sold_date_sk     sold_date_sk,
                        ws_bill_customer_sk customer_sk,
                        ws_item_sk          item_sk
                 FROM   web_sales) cs_or_ws_sales,
                item,
                date_dim,
                customer
         WHERE  sold_date_sk = d_date_sk
                AND item_sk = i_item_sk
                AND i_category = 'Sports'
                AND i_class = 'fitness'
                AND c_customer_sk = cs_or_ws_sales.customer_sk
                AND d_moy = 5
                AND d_year = 2000),
     my_revenue
     AS (SELECT c_customer_sk,
                Sum(ss_ext_sales_price) AS revenue
         FROM   my_customers,
                store_sales,
                customer_address,
                store,
                date_dim
         WHERE  c_current_addr_sk = ca_address_sk
                AND ca_county = s_county
                AND ca_state = s_state
                AND ss_sold_date_sk = d_date_sk
                AND c_customer_sk = ss_customer_sk
                AND d_month_seq BETWEEN (SELECT DISTINCT d_month_seq + 1
                                         FROM   date_dim
                                         WHERE  d_year = 2000
                                                AND d_moy = 5) AND
                                        (SELECT DISTINCT
                                        d_month_seq + 3
                                         FROM   date_dim
                                         WHERE  d_year = 2000
                                                AND d_moy = 5)
         GROUP  BY c_customer_sk),
     segments
     AS (SELECT Floor(revenue / 50) AS segment
         FROM   my_revenue)
SELECT segment,
               Count(*)     AS num_customers,
               segment * 50 AS segment_base
FROM   segments
GROUP  BY segment
ORDER  BY segment,
          num_customers
LIMIT 100;

-- TPCDS query 55:
-- query55
SELECT i_brand_id              brand_id,
               i_brand                 brand,
               Sum(ss_ext_sales_price) ext_price
FROM   date_dim,
       store_sales,
       item
WHERE  d_date_sk = ss_sold_date_sk
       AND ss_item_sk = i_item_sk
       AND i_manager_id = 33
       AND d_moy = 12
       AND d_year = 1998
GROUP  BY i_brand,
          i_brand_id
ORDER  BY ext_price DESC,
          i_brand_id
LIMIT 100;

-- TPCDS query 56:
-- query56
WITH ss
     AS (SELECT i_item_id,
                Sum(ss_ext_sales_price) total_sales
         FROM   store_sales,
                date_dim,
                customer_address,
                item
         WHERE  i_item_id IN (SELECT i_item_id
                              FROM   item
                              WHERE  i_color IN ( 'firebrick', 'rosy', 'white' )
                             )
                AND ss_item_sk = i_item_sk
                AND ss_sold_date_sk = d_date_sk
                AND d_year = 1998
                AND d_moy = 3
                AND ss_addr_sk = ca_address_sk
                AND ca_gmt_offset = -6
         GROUP  BY i_item_id),
     cs
     AS (SELECT i_item_id,
                Sum(cs_ext_sales_price) total_sales
         FROM   catalog_sales,
                date_dim,
                customer_address,
                item
         WHERE  i_item_id IN (SELECT i_item_id
                              FROM   item
                              WHERE  i_color IN ( 'firebrick', 'rosy', 'white' )
                             )
                AND cs_item_sk = i_item_sk
                AND cs_sold_date_sk = d_date_sk
                AND d_year = 1998
                AND d_moy = 3
                AND cs_bill_addr_sk = ca_address_sk
                AND ca_gmt_offset = -6
         GROUP  BY i_item_id),
     ws
     AS (SELECT i_item_id,
                Sum(ws_ext_sales_price) total_sales
         FROM   web_sales,
                date_dim,
                customer_address,
                item
         WHERE  i_item_id IN (SELECT i_item_id
                              FROM   item
                              WHERE  i_color IN ( 'firebrick', 'rosy', 'white' )
                             )
                AND ws_item_sk = i_item_sk
                AND ws_sold_date_sk = d_date_sk
                AND d_year = 1998
                AND d_moy = 3
                AND ws_bill_addr_sk = ca_address_sk
                AND ca_gmt_offset = -6
         GROUP  BY i_item_id)
SELECT i_item_id,
               Sum(total_sales) total_sales
FROM   (SELECT *
        FROM   ss
        UNION ALL
        SELECT *
        FROM   cs
        UNION ALL
        SELECT *
        FROM   ws) tmp1
GROUP  BY i_item_id
ORDER  BY total_sales
LIMIT 100;

-- TPCDS query 57:
-- query57
WITH v1
     AS (SELECT i_category,
                i_brand,
                cc_name,
                d_year,
                d_moy,
                Sum(cs_sales_price)                                    sum_sales
                ,
                Avg(Sum(cs_sales_price))
                  OVER (
                    partition BY i_category, i_brand, cc_name, d_year)
                avg_monthly_sales
                   ,
                Rank()
                  OVER (
                    partition BY i_category, i_brand, cc_name
                    ORDER BY d_year, d_moy)                            rn
         FROM   item,
                catalog_sales,
                date_dim,
                call_center
         WHERE  cs_item_sk = i_item_sk
                AND cs_sold_date_sk = d_date_sk
                AND cc_call_center_sk = cs_call_center_sk
                AND ( d_year = 2000
                       OR ( d_year = 2000 - 1
                            AND d_moy = 12 )
                       OR ( d_year = 2000 + 1
                            AND d_moy = 1 ) )
         GROUP  BY i_category,
                   i_brand,
                   cc_name,
                   d_year,
                   d_moy),
     v2
     AS (SELECT v1.i_brand,
                v1.d_year,
                v1.avg_monthly_sales,
                v1.sum_sales,
                v1_lag.sum_sales  psum,
                v1_lead.sum_sales nsum
         FROM   v1,
                v1 v1_lag,
                v1 v1_lead
         WHERE  v1.i_category = v1_lag.i_category
                AND v1.i_category = v1_lead.i_category
                AND v1.i_brand = v1_lag.i_brand
                AND v1.i_brand = v1_lead.i_brand
                AND v1. cc_name = v1_lag. cc_name
                AND v1. cc_name = v1_lead. cc_name
                AND v1.rn = v1_lag.rn + 1
                AND v1.rn = v1_lead.rn - 1)
SELECT *
FROM   v2
WHERE  d_year = 2000
       AND avg_monthly_sales > 0
       AND CASE
             WHEN avg_monthly_sales > 0 THEN Abs(sum_sales - avg_monthly_sales)
                                             /
                                             avg_monthly_sales
             ELSE NULL
           END > 0.1
ORDER  BY sum_sales - avg_monthly_sales,
          3
LIMIT 100;

-- TPCDS query 58:
-- query58
WITH ss_items
     AS (SELECT i_item_id               item_id,
                Sum(ss_ext_sales_price) ss_item_rev
         FROM   store_sales,
                item,
                date_dim
         WHERE  ss_item_sk = i_item_sk
                AND d_date IN (SELECT d_date
                               FROM   date_dim
                               WHERE  d_week_seq = (SELECT d_week_seq
                                                    FROM   date_dim
                                                    WHERE  d_date = '2002-02-25'
                                                   ))
                AND ss_sold_date_sk = d_date_sk
         GROUP  BY i_item_id),
     cs_items
     AS (SELECT i_item_id               item_id,
                Sum(cs_ext_sales_price) cs_item_rev
         FROM   catalog_sales,
                item,
                date_dim
         WHERE  cs_item_sk = i_item_sk
                AND d_date IN (SELECT d_date
                               FROM   date_dim
                               WHERE  d_week_seq = (SELECT d_week_seq
                                                    FROM   date_dim
                                                    WHERE  d_date = '2002-02-25'
                                                   ))
                AND cs_sold_date_sk = d_date_sk
         GROUP  BY i_item_id),
     ws_items
     AS (SELECT i_item_id               item_id,
                Sum(ws_ext_sales_price) ws_item_rev
         FROM   web_sales,
                item,
                date_dim
         WHERE  ws_item_sk = i_item_sk
                AND d_date IN (SELECT d_date
                               FROM   date_dim
                               WHERE  d_week_seq = (SELECT d_week_seq
                                                    FROM   date_dim
                                                    WHERE  d_date = '2002-02-25'
                                                   ))
                AND ws_sold_date_sk = d_date_sk
         GROUP  BY i_item_id)
SELECT ss_items.item_id,
               ss_item_rev,
               ss_item_rev / ( ss_item_rev + cs_item_rev + ws_item_rev ) / 3 *
               100 ss_dev,
               cs_item_rev,
               cs_item_rev / ( ss_item_rev + cs_item_rev + ws_item_rev ) / 3 *
               100 cs_dev,
               ws_item_rev,
               ws_item_rev / ( ss_item_rev + cs_item_rev + ws_item_rev ) / 3 *
               100 ws_dev,
               ( ss_item_rev + cs_item_rev + ws_item_rev ) / 3
               average
FROM   ss_items,
       cs_items,
       ws_items
WHERE  ss_items.item_id = cs_items.item_id
       AND ss_items.item_id = ws_items.item_id
       AND ss_item_rev BETWEEN 0.9 * cs_item_rev AND 1.1 * cs_item_rev
       AND ss_item_rev BETWEEN 0.9 * ws_item_rev AND 1.1 * ws_item_rev
       AND cs_item_rev BETWEEN 0.9 * ss_item_rev AND 1.1 * ss_item_rev
       AND cs_item_rev BETWEEN 0.9 * ws_item_rev AND 1.1 * ws_item_rev
       AND ws_item_rev BETWEEN 0.9 * ss_item_rev AND 1.1 * ss_item_rev
       AND ws_item_rev BETWEEN 0.9 * cs_item_rev AND 1.1 * cs_item_rev
ORDER  BY item_id,
          ss_item_rev
LIMIT 100;

-- TPCDS query 59:
-- query59
WITH wss
     AS (SELECT d_week_seq,
                ss_store_sk,
                Sum(CASE
                      WHEN ( d_day_name = 'Sunday' ) THEN ss_sales_price
                      ELSE NULL
                    END) sun_sales,
                Sum(CASE
                      WHEN ( d_day_name = 'Monday' ) THEN ss_sales_price
                      ELSE NULL
                    END) mon_sales,
                Sum(CASE
                      WHEN ( d_day_name = 'Tuesday' ) THEN ss_sales_price
                      ELSE NULL
                    END) tue_sales,
                Sum(CASE
                      WHEN ( d_day_name = 'Wednesday' ) THEN ss_sales_price
                      ELSE NULL
                    END) wed_sales,
                Sum(CASE
                      WHEN ( d_day_name = 'Thursday' ) THEN ss_sales_price
                      ELSE NULL
                    END) thu_sales,
                Sum(CASE
                      WHEN ( d_day_name = 'Friday' ) THEN ss_sales_price
                      ELSE NULL
                    END) fri_sales,
                Sum(CASE
                      WHEN ( d_day_name = 'Saturday' ) THEN ss_sales_price
                      ELSE NULL
                    END) sat_sales
         FROM   store_sales,
                date_dim
         WHERE  d_date_sk = ss_sold_date_sk
         GROUP  BY d_week_seq,
                   ss_store_sk)
SELECT s_store_name1,
               s_store_id1,
               d_week_seq1,
               sun_sales1 / sun_sales2,
               mon_sales1 / mon_sales2,
               tue_sales1 / tue_sales2,
               wed_sales1 / wed_sales2,
               thu_sales1 / thu_sales2,
               fri_sales1 / fri_sales2,
               sat_sales1 / sat_sales2
FROM   (SELECT s_store_name   s_store_name1,
               wss.d_week_seq d_week_seq1,
               s_store_id     s_store_id1,
               sun_sales      sun_sales1,
               mon_sales      mon_sales1,
               tue_sales      tue_sales1,
               wed_sales      wed_sales1,
               thu_sales      thu_sales1,
               fri_sales      fri_sales1,
               sat_sales      sat_sales1
        FROM   wss,
               store,
               date_dim d
        WHERE  d.d_week_seq = wss.d_week_seq
               AND ss_store_sk = s_store_sk
               AND d_month_seq BETWEEN 1196 AND 1196 + 11) y,
       (SELECT s_store_name   s_store_name2,
               wss.d_week_seq d_week_seq2,
               s_store_id     s_store_id2,
               sun_sales      sun_sales2,
               mon_sales      mon_sales2,
               tue_sales      tue_sales2,
               wed_sales      wed_sales2,
               thu_sales      thu_sales2,
               fri_sales      fri_sales2,
               sat_sales      sat_sales2
        FROM   wss,
               store,
               date_dim d
        WHERE  d.d_week_seq = wss.d_week_seq
               AND ss_store_sk = s_store_sk
               AND d_month_seq BETWEEN 1196 + 12 AND 1196 + 23) x
WHERE  s_store_id1 = s_store_id2
       AND d_week_seq1 = d_week_seq2 - 52
ORDER  BY s_store_name1,
          s_store_id1,
          d_week_seq1
LIMIT 100;

-- TPCDS query 60:
-- query60
WITH ss
     AS (SELECT i_item_id,
                Sum(ss_ext_sales_price) total_sales
         FROM   store_sales,
                date_dim,
                customer_address,
                item
         WHERE  i_item_id IN (SELECT i_item_id
                              FROM   item
                              WHERE  i_category IN ( 'Jewelry' ))
                AND ss_item_sk = i_item_sk
                AND ss_sold_date_sk = d_date_sk
                AND d_year = 1999
                AND d_moy = 8
                AND ss_addr_sk = ca_address_sk
                AND ca_gmt_offset = -6
         GROUP  BY i_item_id),
     cs
     AS (SELECT i_item_id,
                Sum(cs_ext_sales_price) total_sales
         FROM   catalog_sales,
                date_dim,
                customer_address,
                item
         WHERE  i_item_id IN (SELECT i_item_id
                              FROM   item
                              WHERE  i_category IN ( 'Jewelry' ))
                AND cs_item_sk = i_item_sk
                AND cs_sold_date_sk = d_date_sk
                AND d_year = 1999
                AND d_moy = 8
                AND cs_bill_addr_sk = ca_address_sk
                AND ca_gmt_offset = -6
         GROUP  BY i_item_id),
     ws
     AS (SELECT i_item_id,
                Sum(ws_ext_sales_price) total_sales
         FROM   web_sales,
                date_dim,
                customer_address,
                item
         WHERE  i_item_id IN (SELECT i_item_id
                              FROM   item
                              WHERE  i_category IN ( 'Jewelry' ))
                AND ws_item_sk = i_item_sk
                AND ws_sold_date_sk = d_date_sk
                AND d_year = 1999
                AND d_moy = 8
                AND ws_bill_addr_sk = ca_address_sk
                AND ca_gmt_offset = -6
         GROUP  BY i_item_id)
SELECT i_item_id,
               Sum(total_sales) total_sales
FROM   (SELECT *
        FROM   ss
        UNION ALL
        SELECT *
        FROM   cs
        UNION ALL
        SELECT *
        FROM   ws) tmp1
GROUP  BY i_item_id
ORDER  BY i_item_id,
          total_sales
LIMIT 100;

-- TPCDS query 61:
-- query61
SELECT promotions,
               total,
               promotions /
               total * 100
FROM   (SELECT Sum(ss_ext_sales_price) promotions
        FROM   store_sales,
               store,
               promotion,
               date_dim,
               customer,
               customer_address,
               item
        WHERE  ss_sold_date_sk = d_date_sk
               AND ss_store_sk = s_store_sk
               AND ss_promo_sk = p_promo_sk
               AND ss_customer_sk = c_customer_sk
               AND ca_address_sk = c_current_addr_sk
               AND ss_item_sk = i_item_sk
               AND ca_gmt_offset = -7
               AND i_category = 'Books'
               AND ( p_channel_dmail = 'Y'
                      OR p_channel_email = 'Y'
                      OR p_channel_tv = 'Y' )
               AND s_gmt_offset = -7
               AND d_year = 2001
               AND d_moy = 12) promotional_sales,
       (SELECT Sum(ss_ext_sales_price) total
        FROM   store_sales,
               store,
               date_dim,
               customer,
               customer_address,
               item
        WHERE  ss_sold_date_sk = d_date_sk
               AND ss_store_sk = s_store_sk
               AND ss_customer_sk = c_customer_sk
               AND ca_address_sk = c_current_addr_sk
               AND ss_item_sk = i_item_sk
               AND ca_gmt_offset = -7
               AND i_category = 'Books'
               AND s_gmt_offset = -7
               AND d_year = 2001
               AND d_moy = 12) all_sales
ORDER  BY promotions,
          total
LIMIT 100;

-- TPCDS query 62:
-- query62
SELECT Substr(w_warehouse_name, 1, 20),
               sm_type,
               web_name,
               Sum(CASE
                     WHEN ( ws_ship_date_sk - ws_sold_date_sk <= 30 ) THEN 1
                     ELSE 0
                   END) AS days_30,
               Sum(CASE
                     WHEN ( ws_ship_date_sk - ws_sold_date_sk > 30 )
                          AND ( ws_ship_date_sk - ws_sold_date_sk <= 60 ) THEN 1
                     ELSE 0
                   END) AS days_31_60,
               Sum(CASE
                     WHEN ( ws_ship_date_sk - ws_sold_date_sk > 60 )
                          AND ( ws_ship_date_sk - ws_sold_date_sk <= 90 ) THEN 1
                     ELSE 0
                   END) AS days_61_90,
               Sum(CASE
                     WHEN ( ws_ship_date_sk - ws_sold_date_sk > 90 )
                          AND ( ws_ship_date_sk - ws_sold_date_sk <= 120 ) THEN
                     1
                     ELSE 0
                   END) AS days_91_120,
               Sum(CASE
                     WHEN ( ws_ship_date_sk - ws_sold_date_sk > 120 ) THEN 1
                     ELSE 0
                   END) AS days_over_120
FROM   web_sales,
       warehouse,
       ship_mode,
       web_site,
       date_dim
WHERE  d_month_seq BETWEEN 1222 AND 1222 + 11
       AND ws_ship_date_sk = d_date_sk
       AND ws_warehouse_sk = w_warehouse_sk
       AND ws_ship_mode_sk = sm_ship_mode_sk
       AND ws_web_site_sk = web_site_sk
GROUP  BY 1,
          sm_type,
          web_name
ORDER  BY 1,
          sm_type,
          web_name
LIMIT 100;

-- TPCDS query 63:
-- query63
SELECT *
FROM   (SELECT i_manager_id,
               Sum(ss_sales_price)            sum_sales,
               Avg(Sum(ss_sales_price))
                 OVER (
                   partition BY i_manager_id) avg_monthly_sales
        FROM   item,
               store_sales,
               date_dim,
               store
        WHERE  ss_item_sk = i_item_sk
               AND ss_sold_date_sk = d_date_sk
               AND ss_store_sk = s_store_sk
               AND d_month_seq IN ( 1200, 1200 + 1, 1200 + 2, 1200 + 3,
                                    1200 + 4, 1200 + 5, 1200 + 6, 1200 + 7,
                                    1200 + 8, 1200 + 9, 1200 + 10, 1200 + 11 )
               AND ( ( i_category IN ( 'Books', 'Children', 'Electronics' )
                       AND i_class IN ( 'personal', 'portable', 'reference',
                                        'self-help' )
                       AND i_brand IN ( 'scholaramalgamalg #14',
                                        'scholaramalgamalg #7'
                                        ,
                                        'exportiunivamalg #9',
                                                       'scholaramalgamalg #9' )
                     )
                      OR ( i_category IN ( 'Women', 'Music', 'Men' )
                           AND i_class IN ( 'accessories', 'classical',
                                            'fragrances',
                                            'pants' )
                           AND i_brand IN ( 'amalgimporto #1',
                                            'edu packscholar #1',
                                            'exportiimporto #1',
                                                'importoamalg #1' ) ) )
        GROUP  BY i_manager_id,
                  d_moy) tmp1
WHERE  CASE
         WHEN avg_monthly_sales > 0 THEN Abs (sum_sales - avg_monthly_sales) /
                                         avg_monthly_sales
         ELSE NULL
       END > 0.1
ORDER  BY i_manager_id,
          avg_monthly_sales,
          sum_sales
LIMIT 100;

-- TPCDS query 64:
-- query64
WITH cs_ui
     AS (SELECT cs_item_sk,
                Sum(cs_ext_list_price) AS sale,
                Sum(cr_refunded_cash + cr_reversed_charge
                    + cr_store_credit) AS refund
         FROM   catalog_sales,
                catalog_returns
         WHERE  cs_item_sk = cr_item_sk
                AND cs_order_number = cr_order_number
         GROUP  BY cs_item_sk
         HAVING Sum(cs_ext_list_price) > 2 * Sum(
                cr_refunded_cash + cr_reversed_charge
                + cr_store_credit)),
     cross_sales
     AS (SELECT i_product_name         product_name,
                i_item_sk              item_sk,
                s_store_name           store_name,
                s_zip                  store_zip,
                ad1.ca_street_number   b_street_number,
                ad1.ca_street_name     b_streen_name,
                ad1.ca_city            b_city,
                ad1.ca_zip             b_zip,
                ad2.ca_street_number   c_street_number,
                ad2.ca_street_name     c_street_name,
                ad2.ca_city            c_city,
                ad2.ca_zip             c_zip,
                d1.d_year              AS syear,
                d2.d_year              AS fsyear,
                d3.d_year              s2year,
                Count(*)               cnt,
                Sum(ss_wholesale_cost) s1,
                Sum(ss_list_price)     s2,
                Sum(ss_coupon_amt)     s3
         FROM   store_sales,
                store_returns,
                cs_ui,
                date_dim d1,
                date_dim d2,
                date_dim d3,
                store,
                customer,
                customer_demographics cd1,
                customer_demographics cd2,
                promotion,
                household_demographics hd1,
                household_demographics hd2,
                customer_address ad1,
                customer_address ad2,
                income_band ib1,
                income_band ib2,
                item
         WHERE  ss_store_sk = s_store_sk
                AND ss_sold_date_sk = d1.d_date_sk
                AND ss_customer_sk = c_customer_sk
                AND ss_cdemo_sk = cd1.cd_demo_sk
                AND ss_hdemo_sk = hd1.hd_demo_sk
                AND ss_addr_sk = ad1.ca_address_sk
                AND ss_item_sk = i_item_sk
                AND ss_item_sk = sr_item_sk
                AND ss_ticket_number = sr_ticket_number
                AND ss_item_sk = cs_ui.cs_item_sk
                AND c_current_cdemo_sk = cd2.cd_demo_sk
                AND c_current_hdemo_sk = hd2.hd_demo_sk
                AND c_current_addr_sk = ad2.ca_address_sk
                AND c_first_sales_date_sk = d2.d_date_sk
                AND c_first_shipto_date_sk = d3.d_date_sk
                AND ss_promo_sk = p_promo_sk
                AND hd1.hd_income_band_sk = ib1.ib_income_band_sk
                AND hd2.hd_income_band_sk = ib2.ib_income_band_sk
                AND cd1.cd_marital_status <> cd2.cd_marital_status
                AND i_color IN ( 'cyan', 'peach', 'blush', 'frosted',
                                 'powder', 'orange' )
                AND i_current_price BETWEEN 58 AND 58 + 10
                AND i_current_price BETWEEN 58 + 1 AND 58 + 15
         GROUP  BY i_product_name,
                   i_item_sk,
                   s_store_name,
                   s_zip,
                   ad1.ca_street_number,
                   ad1.ca_street_name,
                   ad1.ca_city,
                   ad1.ca_zip,
                   ad2.ca_street_number,
                   ad2.ca_street_name,
                   ad2.ca_city,
                   ad2.ca_zip,
                   d1.d_year,
                   d2.d_year,
                   d3.d_year)
SELECT cs1.product_name,
       cs1.store_name,
       cs1.store_zip,
       cs1.b_street_number,
       cs1.b_streen_name,
       cs1.b_city,
       cs1.b_zip,
       cs1.c_street_number,
       cs1.c_street_name,
       cs1.c_city,
       cs1.c_zip,
       cs1.syear,
       cs1.cnt,
       cs1.s1,
       cs1.s2,
       cs1.s3,
       cs2.s1 AS s1_,
       cs2.s2 AS s2_,
       cs2.s3 AS s3_,
       cs2.syear AS syear_,
       cs2.cnt AS cnt_
FROM   cross_sales cs1,
       cross_sales cs2
WHERE  cs1.item_sk = cs2.item_sk
       AND cs1.syear = 2001
       AND cs2.syear = 2001 + 1
       AND cs2.cnt <= cs1.cnt
       AND cs1.store_name = cs2.store_name
       AND cs1.store_zip = cs2.store_zip
ORDER  BY cs1.product_name,
          cs1.store_name,
          cs2.cnt;

-- TPCDS query 65:
-- query65
SELECT s_store_name,
               i_item_desc,
               sc.revenue,
               i_current_price,
               i_wholesale_cost,
               i_brand
FROM   store,
       item,
       (SELECT ss_store_sk,
               Avg(revenue) AS ave
        FROM   (SELECT ss_store_sk,
                       ss_item_sk,
                       Sum(ss_sales_price) AS revenue
                FROM   store_sales,
                       date_dim
                WHERE  ss_sold_date_sk = d_date_sk
                       AND d_month_seq BETWEEN 1199 AND 1199 + 11
                GROUP  BY ss_store_sk,
                          ss_item_sk) sa
        GROUP  BY ss_store_sk) sb,
       (SELECT ss_store_sk,
               ss_item_sk,
               Sum(ss_sales_price) AS revenue
        FROM   store_sales,
               date_dim
        WHERE  ss_sold_date_sk = d_date_sk
               AND d_month_seq BETWEEN 1199 AND 1199 + 11
        GROUP  BY ss_store_sk,
                  ss_item_sk) sc
WHERE  sb.ss_store_sk = sc.ss_store_sk
       AND sc.revenue <= 0.1 * sb.ave
       AND s_store_sk = sc.ss_store_sk
       AND i_item_sk = sc.ss_item_sk
ORDER  BY s_store_name,
          i_item_desc
LIMIT 100;

-- TPCDS query 66:
-- query66
SELECT w_warehouse_name,
               w_warehouse_sq_ft,
               w_city,
               w_county,
               w_state,
               w_country,
               ship_carriers,
               year1,
               Sum(jan_sales)                     AS jan_sales,
               Sum(feb_sales)                     AS feb_sales,
               Sum(mar_sales)                     AS mar_sales,
               Sum(apr_sales)                     AS apr_sales,
               Sum(may_sales)                     AS may_sales,
               Sum(jun_sales)                     AS jun_sales,
               Sum(jul_sales)                     AS jul_sales,
               Sum(aug_sales)                     AS aug_sales,
               Sum(sep_sales)                     AS sep_sales,
               Sum(oct_sales)                     AS oct_sales,
               Sum(nov_sales)                     AS nov_sales,
               Sum(dec_sales)                     AS dec_sales,
               Sum(jan_sales / w_warehouse_sq_ft) AS jan_sales_per_sq_foot,
               Sum(feb_sales / w_warehouse_sq_ft) AS feb_sales_per_sq_foot,
               Sum(mar_sales / w_warehouse_sq_ft) AS mar_sales_per_sq_foot,
               Sum(apr_sales / w_warehouse_sq_ft) AS apr_sales_per_sq_foot,
               Sum(may_sales / w_warehouse_sq_ft) AS may_sales_per_sq_foot,
               Sum(jun_sales / w_warehouse_sq_ft) AS jun_sales_per_sq_foot,
               Sum(jul_sales / w_warehouse_sq_ft) AS jul_sales_per_sq_foot,
               Sum(aug_sales / w_warehouse_sq_ft) AS aug_sales_per_sq_foot,
               Sum(sep_sales / w_warehouse_sq_ft) AS sep_sales_per_sq_foot,
               Sum(oct_sales / w_warehouse_sq_ft) AS oct_sales_per_sq_foot,
               Sum(nov_sales / w_warehouse_sq_ft) AS nov_sales_per_sq_foot,
               Sum(dec_sales / w_warehouse_sq_ft) AS dec_sales_per_sq_foot,
               Sum(jan_net)                       AS jan_net,
               Sum(feb_net)                       AS feb_net,
               Sum(mar_net)                       AS mar_net,
               Sum(apr_net)                       AS apr_net,
               Sum(may_net)                       AS may_net,
               Sum(jun_net)                       AS jun_net,
               Sum(jul_net)                       AS jul_net,
               Sum(aug_net)                       AS aug_net,
               Sum(sep_net)                       AS sep_net,
               Sum(oct_net)                       AS oct_net,
               Sum(nov_net)                       AS nov_net,
               Sum(dec_net)                       AS dec_net
FROM   (SELECT w_warehouse_name,
               w_warehouse_sq_ft,
               w_city,
               w_county,
               w_state,
               w_country,
               'ZOUROS,ZHOU' AS ship_carriers,
               d_year    AS year1,
               Sum(CASE
                     WHEN d_moy = 1 THEN ws_ext_sales_price * ws_quantity
                     ELSE 0
                   END)  AS jan_sales,
               Sum(CASE
                     WHEN d_moy = 2 THEN ws_ext_sales_price * ws_quantity
                     ELSE 0
                   END)  AS feb_sales,
               Sum(CASE
                     WHEN d_moy = 3 THEN ws_ext_sales_price * ws_quantity
                     ELSE 0
                   END)  AS mar_sales,
               Sum(CASE
                     WHEN d_moy = 4 THEN ws_ext_sales_price * ws_quantity
                     ELSE 0
                   END)  AS apr_sales,
               Sum(CASE
                     WHEN d_moy = 5 THEN ws_ext_sales_price * ws_quantity
                     ELSE 0
                   END)  AS may_sales,
               Sum(CASE
                     WHEN d_moy = 6 THEN ws_ext_sales_price * ws_quantity
                     ELSE 0
                   END)  AS jun_sales,
               Sum(CASE
                     WHEN d_moy = 7 THEN ws_ext_sales_price * ws_quantity
                     ELSE 0
                   END)  AS jul_sales,
               Sum(CASE
                     WHEN d_moy = 8 THEN ws_ext_sales_price * ws_quantity
                     ELSE 0
                   END)  AS aug_sales,
               Sum(CASE
                     WHEN d_moy = 9 THEN ws_ext_sales_price * ws_quantity
                     ELSE 0
                   END)  AS sep_sales,
               Sum(CASE
                     WHEN d_moy = 10 THEN ws_ext_sales_price * ws_quantity
                     ELSE 0
                   END)  AS oct_sales,
               Sum(CASE
                     WHEN d_moy = 11 THEN ws_ext_sales_price * ws_quantity
                     ELSE 0
                   END)  AS nov_sales,
               Sum(CASE
                     WHEN d_moy = 12 THEN ws_ext_sales_price * ws_quantity
                     ELSE 0
                   END)  AS dec_sales,
               Sum(CASE
                     WHEN d_moy = 1 THEN ws_net_paid_inc_ship * ws_quantity
                     ELSE 0
                   END)  AS jan_net,
               Sum(CASE
                     WHEN d_moy = 2 THEN ws_net_paid_inc_ship * ws_quantity
                     ELSE 0
                   END)  AS feb_net,
               Sum(CASE
                     WHEN d_moy = 3 THEN ws_net_paid_inc_ship * ws_quantity
                     ELSE 0
                   END)  AS mar_net,
               Sum(CASE
                     WHEN d_moy = 4 THEN ws_net_paid_inc_ship * ws_quantity
                     ELSE 0
                   END)  AS apr_net,
               Sum(CASE
                     WHEN d_moy = 5 THEN ws_net_paid_inc_ship * ws_quantity
                     ELSE 0
                   END)  AS may_net,
               Sum(CASE
                     WHEN d_moy = 6 THEN ws_net_paid_inc_ship * ws_quantity
                     ELSE 0
                   END)  AS jun_net,
               Sum(CASE
                     WHEN d_moy = 7 THEN ws_net_paid_inc_ship * ws_quantity
                     ELSE 0
                   END)  AS jul_net,
               Sum(CASE
                     WHEN d_moy = 8 THEN ws_net_paid_inc_ship * ws_quantity
                     ELSE 0
                   END)  AS aug_net,
               Sum(CASE
                     WHEN d_moy = 9 THEN ws_net_paid_inc_ship * ws_quantity
                     ELSE 0
                   END)  AS sep_net,
               Sum(CASE
                     WHEN d_moy = 10 THEN ws_net_paid_inc_ship * ws_quantity
                     ELSE 0
                   END)  AS oct_net,
               Sum(CASE
                     WHEN d_moy = 11 THEN ws_net_paid_inc_ship * ws_quantity
                     ELSE 0
                   END)  AS nov_net,
               Sum(CASE
                     WHEN d_moy = 12 THEN ws_net_paid_inc_ship * ws_quantity
                     ELSE 0
                   END)  AS dec_net
        FROM   web_sales,
               warehouse,
               date_dim,
               time_dim,
               ship_mode
        WHERE  ws_warehouse_sk = w_warehouse_sk
               AND ws_sold_date_sk = d_date_sk
               AND ws_sold_time_sk = t_time_sk
               AND ws_ship_mode_sk = sm_ship_mode_sk
               AND d_year = 1998
               AND t_time BETWEEN 7249 AND 7249 + 28800
               AND sm_carrier IN ( 'ZOUROS', 'ZHOU' )
        GROUP  BY w_warehouse_name,
                  w_warehouse_sq_ft,
                  w_city,
                  w_county,
                  w_state,
                  w_country,
                  d_year
        UNION ALL
        SELECT w_warehouse_name,
               w_warehouse_sq_ft,
               w_city,
               w_county,
               w_state,
               w_country,
               'ZOUROS,ZHOU' AS ship_carriers,
               d_year    AS year1,
               Sum(CASE
                     WHEN d_moy = 1 THEN cs_ext_sales_price * cs_quantity
                     ELSE 0
                   END)  AS jan_sales,
               Sum(CASE
                     WHEN d_moy = 2 THEN cs_ext_sales_price * cs_quantity
                     ELSE 0
                   END)  AS feb_sales,
               Sum(CASE
                     WHEN d_moy = 3 THEN cs_ext_sales_price * cs_quantity
                     ELSE 0
                   END)  AS mar_sales,
               Sum(CASE
                     WHEN d_moy = 4 THEN cs_ext_sales_price * cs_quantity
                     ELSE 0
                   END)  AS apr_sales,
               Sum(CASE
                     WHEN d_moy = 5 THEN cs_ext_sales_price * cs_quantity
                     ELSE 0
                   END)  AS may_sales,
               Sum(CASE
                     WHEN d_moy = 6 THEN cs_ext_sales_price * cs_quantity
                     ELSE 0
                   END)  AS jun_sales,
               Sum(CASE
                     WHEN d_moy = 7 THEN cs_ext_sales_price * cs_quantity
                     ELSE 0
                   END)  AS jul_sales,
               Sum(CASE
                     WHEN d_moy = 8 THEN cs_ext_sales_price * cs_quantity
                     ELSE 0
                   END)  AS aug_sales,
               Sum(CASE
                     WHEN d_moy = 9 THEN cs_ext_sales_price * cs_quantity
                     ELSE 0
                   END)  AS sep_sales,
               Sum(CASE
                     WHEN d_moy = 10 THEN cs_ext_sales_price * cs_quantity
                     ELSE 0
                   END)  AS oct_sales,
               Sum(CASE
                     WHEN d_moy = 11 THEN cs_ext_sales_price * cs_quantity
                     ELSE 0
                   END)  AS nov_sales,
               Sum(CASE
                     WHEN d_moy = 12 THEN cs_ext_sales_price * cs_quantity
                     ELSE 0
                   END)  AS dec_sales,
               Sum(CASE
                     WHEN d_moy = 1 THEN cs_net_paid * cs_quantity
                     ELSE 0
                   END)  AS jan_net,
               Sum(CASE
                     WHEN d_moy = 2 THEN cs_net_paid * cs_quantity
                     ELSE 0
                   END)  AS feb_net,
               Sum(CASE
                     WHEN d_moy = 3 THEN cs_net_paid * cs_quantity
                     ELSE 0
                   END)  AS mar_net,
               Sum(CASE
                     WHEN d_moy = 4 THEN cs_net_paid * cs_quantity
                     ELSE 0
                   END)  AS apr_net,
               Sum(CASE
                     WHEN d_moy = 5 THEN cs_net_paid * cs_quantity
                     ELSE 0
                   END)  AS may_net,
               Sum(CASE
                     WHEN d_moy = 6 THEN cs_net_paid * cs_quantity
                     ELSE 0
                   END)  AS jun_net,
               Sum(CASE
                     WHEN d_moy = 7 THEN cs_net_paid * cs_quantity
                     ELSE 0
                   END)  AS jul_net,
               Sum(CASE
                     WHEN d_moy = 8 THEN cs_net_paid * cs_quantity
                     ELSE 0
                   END)  AS aug_net,
               Sum(CASE
                     WHEN d_moy = 9 THEN cs_net_paid * cs_quantity
                     ELSE 0
                   END)  AS sep_net,
               Sum(CASE
                     WHEN d_moy = 10 THEN cs_net_paid * cs_quantity
                     ELSE 0
                   END)  AS oct_net,
               Sum(CASE
                     WHEN d_moy = 11 THEN cs_net_paid * cs_quantity
                     ELSE 0
                   END)  AS nov_net,
               Sum(CASE
                     WHEN d_moy = 12 THEN cs_net_paid * cs_quantity
                     ELSE 0
                   END)  AS dec_net
        FROM   catalog_sales,
               warehouse,
               date_dim,
               time_dim,
               ship_mode
        WHERE  cs_warehouse_sk = w_warehouse_sk
               AND cs_sold_date_sk = d_date_sk
               AND cs_sold_time_sk = t_time_sk
               AND cs_ship_mode_sk = sm_ship_mode_sk
               AND d_year = 1998
               AND t_time BETWEEN 7249 AND 7249 + 28800
               AND sm_carrier IN ( 'ZOUROS', 'ZHOU' )
        GROUP  BY w_warehouse_name,
                  w_warehouse_sq_ft,
                  w_city,
                  w_county,
                  w_state,
                  w_country,
                  d_year) x
GROUP  BY w_warehouse_name,
          w_warehouse_sq_ft,
          w_city,
          w_county,
          w_state,
          w_country,
          ship_carriers,
          year1
ORDER  BY w_warehouse_name
LIMIT 100;

-- TPCDS query 67:
-- query67
with dw1 as (
      select i_category
            ,i_class
            ,i_brand
            ,i_product_name
            ,d_year
            ,d_qoy
            ,d_moy
            ,s_store_id
            ,sum(coalesce(ss_sales_price*ss_quantity,0)) sumsales
      from store_sales
            ,date_dim
            ,store
            ,item
      where  ss_sold_date_sk=d_date_sk
      and ss_item_sk=i_item_sk
      and ss_store_sk = s_store_sk
      and d_month_seq between 1181 and 1181+11
      group by i_category, i_class, i_brand, i_product_name, d_year, d_qoy, d_moy,s_store_id
), dw2 as (
      select i_category
            ,i_class
            ,i_brand
            ,i_product_name
            ,d_year
            ,d_qoy
            ,d_moy
            ,s_store_id
            ,sumsales
            ,rank() over (partition by i_category, i_class, i_brand, i_product_name order by sumsales desc) rk
      from dw1
), dw3 as (
      select i_category
            ,i_class
            ,i_brand
            ,i_product_name
            ,d_year
            ,d_qoy
            ,d_moy
            ,s_store_id
            ,sumsales
            ,rank() over (partition by i_category order by sumsales desc) rk
      from dw2
      where rk <= 100
)
select *
from dw2
where rk <= 100
order by i_category
        ,i_class
        ,i_brand
        ,i_product_name
        ,d_year
        ,d_qoy
        ,d_moy
        ,s_store_id
        ,sumsales
        ,rk
limit 100
;


-- TPCDS query 68:
-- query68
SELECT c_last_name,
               c_first_name,
               ca_city,
               bought_city,
               ss_ticket_number,
               extended_price,
               extended_tax,
               list_price
FROM   (SELECT ss_ticket_number,
               ss_customer_sk,
               ca_city                 bought_city,
               Sum(ss_ext_sales_price) extended_price,
               Sum(ss_ext_list_price)  list_price,
               Sum(ss_ext_tax)         extended_tax
        FROM   store_sales,
               date_dim,
               store,
               household_demographics,
               customer_address
        WHERE  store_sales.ss_sold_date_sk = date_dim.d_date_sk
               AND store_sales.ss_store_sk = store.s_store_sk
               AND store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
               AND store_sales.ss_addr_sk = customer_address.ca_address_sk
               AND date_dim.d_dom BETWEEN 1 AND 2
               AND ( household_demographics.hd_dep_count = 8
                      OR household_demographics.hd_vehicle_count = 3 )
               AND date_dim.d_year IN ( 1998, 1998 + 1, 1998 + 2 )
               AND store.s_city IN ( 'Fairview', 'Midway' )
        GROUP  BY ss_ticket_number,
                  ss_customer_sk,
                  ss_addr_sk,
                  ca_city) dn,
       customer,
       customer_address current_addr
WHERE  ss_customer_sk = c_customer_sk
       AND customer.c_current_addr_sk = current_addr.ca_address_sk
       AND current_addr.ca_city <> bought_city
ORDER  BY c_last_name,
          ss_ticket_number
LIMIT 100;

-- TPCDS query 69:
-- query69
SELECT cd_gender,
               cd_marital_status,
               cd_education_status,
               Count(*) cnt1,
               cd_purchase_estimate,
               Count(*) cnt2,
               cd_credit_rating,
               Count(*) cnt3
FROM   customer c,
       customer_address ca,
       customer_demographics
WHERE  c.c_current_addr_sk = ca.ca_address_sk
       AND ca_state IN ( 'KS', 'AZ', 'NE' )
       AND cd_demo_sk = c.c_current_cdemo_sk
       AND EXISTS (SELECT *
                   FROM   store_sales,
                          date_dim
                   WHERE  c.c_customer_sk = ss_customer_sk
                          AND ss_sold_date_sk = d_date_sk
                          AND d_year = 2004
                          AND d_moy BETWEEN 3 AND 3 + 2)
       AND ( NOT EXISTS (SELECT *
                         FROM   web_sales,
                                date_dim
                         WHERE  c.c_customer_sk = ws_bill_customer_sk
                                AND ws_sold_date_sk = d_date_sk
                                AND d_year = 2004
                                AND d_moy BETWEEN 3 AND 3 + 2)
             AND NOT EXISTS (SELECT *
                             FROM   catalog_sales,
                                    date_dim
                             WHERE  c.c_customer_sk = cs_ship_customer_sk
                                    AND cs_sold_date_sk = d_date_sk
                                    AND d_year = 2004
                                    AND d_moy BETWEEN 3 AND 3 + 2) )
GROUP  BY cd_gender,
          cd_marital_status,
          cd_education_status,
          cd_purchase_estimate,
          cd_credit_rating
ORDER  BY cd_gender,
          cd_marital_status,
          cd_education_status,
          cd_purchase_estimate,
          cd_credit_rating
LIMIT 100;

-- TPCDS query 70:
-- query70
SELECT Sum(ss_net_profit)                     AS total_sum,
               s_state,
               s_county,
               Rank()
                 OVER (
                   PARTITION BY s_state, s_county
                   ORDER BY Sum(ss_net_profit) DESC)  AS rank_within_parent
FROM   store_sales,
       date_dim d1,
       store
WHERE  d1.d_month_seq BETWEEN 1200 AND 1200 + 11
       AND d1.d_date_sk = ss_sold_date_sk
       AND s_store_sk = ss_store_sk
       AND s_state IN (SELECT s_state
                       FROM   (SELECT s_state                               AS
                                      s_state,
                                      Rank()
                                        OVER (
                                          partition BY s_state
                                          ORDER BY Sum(ss_net_profit) DESC) AS
                                      ranking
                               FROM   store_sales,
                                      store,
                                      date_dim
                               WHERE  d_month_seq BETWEEN 1200 AND 1200 + 11
                                      AND d_date_sk = ss_sold_date_sk
                                      AND s_store_sk = ss_store_sk
                               GROUP  BY s_state) tmp1
                       WHERE  ranking <= 5)
GROUP  BY s_state, s_county
ORDER  BY s_state,
          rank_within_parent
LIMIT 100;

-- TPCDS query 71:
-- query71
SELECT i_brand_id     brand_id,
       i_brand        brand,
       t_hour,
       t_minute,
       Sum(ext_price) ext_price
FROM   item,
       (SELECT ws_ext_sales_price AS ext_price,
               ws_sold_date_sk    AS sold_date_sk,
               ws_item_sk         AS sold_item_sk,
               ws_sold_time_sk    AS time_sk
        FROM   web_sales,
               date_dim
        WHERE  d_date_sk = ws_sold_date_sk
               AND d_moy = 11
               AND d_year = 2001
        UNION ALL
        SELECT cs_ext_sales_price AS ext_price,
               cs_sold_date_sk    AS sold_date_sk,
               cs_item_sk         AS sold_item_sk,
               cs_sold_time_sk    AS time_sk
        FROM   catalog_sales,
               date_dim
        WHERE  d_date_sk = cs_sold_date_sk
               AND d_moy = 11
               AND d_year = 2001
        UNION ALL
        SELECT ss_ext_sales_price AS ext_price,
               ss_sold_date_sk    AS sold_date_sk,
               ss_item_sk         AS sold_item_sk,
               ss_sold_time_sk    AS time_sk
        FROM   store_sales,
               date_dim
        WHERE  d_date_sk = ss_sold_date_sk
               AND d_moy = 11
               AND d_year = 2001) AS tmp,
       time_dim
WHERE  sold_item_sk = i_item_sk
       AND i_manager_id = 1
       AND time_sk = t_time_sk
       AND ( t_meal_time = 'breakfast'
              OR t_meal_time = 'dinner' )
GROUP  BY i_brand,
          i_brand_id,
          t_hour,
          t_minute
ORDER  BY ext_price DESC,
          i_brand_id;

-- TPCDS query 72:
-- query72
WITH top_items AS (
  SELECT cs_item_sk,
                cs_warehouse_sk,
                d1.d_week_seq,
                Sum(CASE
                      WHEN p_promo_sk IS NULL THEN 1
                      ELSE 0
                    END) no_promo,
                Sum(CASE
                      WHEN p_promo_sk IS NOT NULL THEN 1
                      ELSE 0
                    END) promo,
                Count(*) total_cnt
  FROM   catalog_sales
        JOIN inventory
          ON ( cs_item_sk = inv_item_sk and cs_sold_date_sk = inv_date_sk and cs_warehouse_sk = inv_warehouse_sk )
        JOIN customer_demographics
          ON ( cs_bill_cdemo_sk = cd_demo_sk )
        JOIN household_demographics
          ON ( cs_bill_hdemo_sk = hd_demo_sk )
        JOIN date_dim d1
          ON ( cs_sold_date_sk = d1.d_date_sk )
        LEFT OUTER JOIN promotion
                      ON ( cs_promo_sk = p_promo_sk )
        LEFT OUTER JOIN catalog_returns
                      ON ( cr_item_sk = cs_item_sk
                          AND cr_order_number = cs_order_number )
  WHERE inv_quantity_on_hand < cs_quantity
        AND hd_buy_potential = '501-1000'
        AND d1.d_year = 2002
        AND cd_marital_status = 'M'
  GROUP  BY 1, 2, 3
)
SELECT i_item_desc,
       w_warehouse_name,
       d_week_seq,
       no_promo,
       promo,
       total_cnt
FROM top_items
JOIN warehouse
  ON ( w_warehouse_sk = cs_warehouse_sk )
JOIN item
  ON ( i_item_sk = cs_item_sk )
ORDER  BY total_cnt DESC,
          1, 2, 3
LIMIT 100;

-- TPCDS query 73:
-- query73
SELECT c_last_name,
       c_first_name,
       c_salutation,
       c_preferred_cust_flag,
       ss_ticket_number,
       cnt
FROM   (SELECT ss_ticket_number,
               ss_customer_sk,
               Count(*) cnt
        FROM   store_sales,
               date_dim,
               store,
               household_demographics
        WHERE  store_sales.ss_sold_date_sk = date_dim.d_date_sk
               AND store_sales.ss_store_sk = store.s_store_sk
               AND store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
               AND date_dim.d_dom BETWEEN 1 AND 2
               AND ( household_demographics.hd_buy_potential = '>10000'
                      OR household_demographics.hd_buy_potential = '0-500' )
               AND household_demographics.hd_vehicle_count > 0
               AND CASE
                     WHEN household_demographics.hd_vehicle_count > 0 THEN
                     household_demographics.hd_dep_count /
                     household_demographics.hd_vehicle_count
                     ELSE NULL
                   END > 1
               AND date_dim.d_year IN ( 2000, 2000 + 1, 2000 + 2 )
               AND store.s_county IN ( 'Williamson County', 'Williamson County',
                                       'Williamson County',
                                                             'Williamson County'
                                     )
        GROUP  BY ss_ticket_number,
                  ss_customer_sk) dj,
       customer
WHERE  ss_customer_sk = c_customer_sk
       AND cnt BETWEEN 1 AND 5
ORDER  BY cnt DESC,
          c_last_name ASC;

-- TPCDS query 74:
-- query74
WITH year_total
     AS (SELECT c_customer_id    customer_id,
                c_first_name     customer_first_name,
                c_last_name      customer_last_name,
                d_year           AS year1,
                Sum(ss_net_paid) year_total,
                's'              sale_type
         FROM   customer,
                store_sales,
                date_dim
         WHERE  c_customer_sk = ss_customer_sk
                AND ss_sold_date_sk = d_date_sk
                AND d_year IN ( 1999, 1999 + 1 )
         GROUP  BY c_customer_id,
                   c_first_name,
                   c_last_name,
                   d_year
         UNION ALL
         SELECT c_customer_id    customer_id,
                c_first_name     customer_first_name,
                c_last_name      customer_last_name,
                d_year           AS year1,
                Sum(ws_net_paid) year_total,
                'w'              sale_type
         FROM   customer,
                web_sales,
                date_dim
         WHERE  c_customer_sk = ws_bill_customer_sk
                AND ws_sold_date_sk = d_date_sk
                AND d_year IN ( 1999, 1999 + 1 )
         GROUP  BY c_customer_id,
                   c_first_name,
                   c_last_name,
                   d_year)
SELECT t_s_secyear.customer_id,
               t_s_secyear.customer_first_name,
               t_s_secyear.customer_last_name
FROM   year_total t_s_firstyear,
       year_total t_s_secyear,
       year_total t_w_firstyear,
       year_total t_w_secyear
WHERE  t_s_secyear.customer_id = t_s_firstyear.customer_id
       AND t_s_firstyear.customer_id = t_w_secyear.customer_id
       AND t_s_firstyear.customer_id = t_w_firstyear.customer_id
       AND t_s_firstyear.sale_type = 's'
       AND t_w_firstyear.sale_type = 'w'
       AND t_s_secyear.sale_type = 's'
       AND t_w_secyear.sale_type = 'w'
       AND t_s_firstyear.year1 = 1999
       AND t_s_secyear.year1 = 1999 + 1
       AND t_w_firstyear.year1 = 1999
       AND t_w_secyear.year1 = 1999 + 1
       AND t_s_firstyear.year_total > 0
       AND t_w_firstyear.year_total > 0
       AND CASE
             WHEN t_w_firstyear.year_total > 0 THEN t_w_secyear.year_total /
                                                    t_w_firstyear.year_total
             ELSE NULL
           END > CASE
                   WHEN t_s_firstyear.year_total > 0 THEN
                   t_s_secyear.year_total /
                   t_s_firstyear.year_total
                   ELSE NULL
                 END
ORDER  BY 1,
          2,
          3
LIMIT 100;

-- TPCDS query 75:
-- query75
WITH all_sales
     AS (SELECT d_year,
                i_brand_id,
                i_class_id,
                i_category_id,
                i_manufact_id,
                Sum(sales_cnt) AS sales_cnt,
                Sum(sales_amt) AS sales_amt
         FROM   (SELECT d_year,
                        i_brand_id,
                        i_class_id,
                        i_category_id,
                        i_manufact_id,
                        cs_quantity - COALESCE(cr_return_quantity, 0)        AS
                        sales_cnt,
                        cs_ext_sales_price - COALESCE(cr_return_amount, 0.0) AS
                        sales_amt
                 FROM   catalog_sales
                        JOIN item
                          ON i_item_sk = cs_item_sk
                        JOIN date_dim
                          ON d_date_sk = cs_sold_date_sk
                        LEFT JOIN catalog_returns
                               ON ( cs_order_number = cr_order_number
                                    AND cs_item_sk = cr_item_sk )
                 WHERE  i_category = 'Men'
                 UNION ALL
                 SELECT d_year,
                        i_brand_id,
                        i_class_id,
                        i_category_id,
                        i_manufact_id,
                        ss_quantity - COALESCE(sr_return_quantity, 0)     AS
                        sales_cnt,
                        ss_ext_sales_price - COALESCE(sr_return_amt, 0.0) AS
                        sales_amt
                 FROM   store_sales
                        JOIN item
                          ON i_item_sk = ss_item_sk
                        JOIN date_dim
                          ON d_date_sk = ss_sold_date_sk
                        LEFT JOIN store_returns
                               ON ( ss_ticket_number = sr_ticket_number
                                    AND ss_item_sk = sr_item_sk )
                 WHERE  i_category = 'Men'
                 UNION ALL
                 SELECT d_year,
                        i_brand_id,
                        i_class_id,
                        i_category_id,
                        i_manufact_id,
                        ws_quantity - COALESCE(wr_return_quantity, 0)     AS
                        sales_cnt,
                        ws_ext_sales_price - COALESCE(wr_return_amt, 0.0) AS
                        sales_amt
                 FROM   web_sales
                        JOIN item
                          ON i_item_sk = ws_item_sk
                        JOIN date_dim
                          ON d_date_sk = ws_sold_date_sk
                        LEFT JOIN web_returns
                               ON ( ws_order_number = wr_order_number
                                    AND ws_item_sk = wr_item_sk )
                 WHERE  i_category = 'Men') sales_detail
         GROUP  BY d_year,
                   i_brand_id,
                   i_class_id,
                   i_category_id,
                   i_manufact_id)
SELECT prev_yr.d_year                        AS prev_year,
               curr_yr.d_year                        AS year1,
               curr_yr.i_brand_id,
               curr_yr.i_class_id,
               curr_yr.i_category_id,
               curr_yr.i_manufact_id,
               prev_yr.sales_cnt                     AS prev_yr_cnt,
               curr_yr.sales_cnt                     AS curr_yr_cnt,
               curr_yr.sales_cnt - prev_yr.sales_cnt AS sales_cnt_diff,
               curr_yr.sales_amt - prev_yr.sales_amt AS sales_amt_diff
FROM   all_sales curr_yr,
       all_sales prev_yr
WHERE  curr_yr.i_brand_id = prev_yr.i_brand_id
       AND curr_yr.i_class_id = prev_yr.i_class_id
       AND curr_yr.i_category_id = prev_yr.i_category_id
       AND curr_yr.i_manufact_id = prev_yr.i_manufact_id
       AND curr_yr.d_year = 2002
       AND prev_yr.d_year = 2002 - 1
       AND curr_yr.sales_cnt / prev_yr.sales_cnt
           < 0.9
ORDER  BY sales_cnt_diff
LIMIT 100;

-- TPCDS query 76:
-- query76
SELECT channel,
               col_name,
               d_year,
               d_qoy,
               i_category,
               Count(*)             sales_cnt,
               Sum(ext_sales_price) sales_amt
FROM   (SELECT 'store'            AS channel,
               'ss_hdemo_sk'      col_name,
               d_year,
               d_qoy,
               i_category,
               ss_ext_sales_price ext_sales_price
        FROM   store_sales,
               item,
               date_dim
        WHERE  ss_hdemo_sk IS NULL
               AND ss_sold_date_sk = d_date_sk
               AND ss_item_sk = i_item_sk
        UNION ALL
        SELECT 'web'              AS channel,
               'ws_ship_hdemo_sk' col_name,
               d_year,
               d_qoy,
               i_category,
               ws_ext_sales_price ext_sales_price
        FROM   web_sales,
               item,
               date_dim
        WHERE  ws_ship_hdemo_sk IS NULL
               AND ws_sold_date_sk = d_date_sk
               AND ws_item_sk = i_item_sk
        UNION ALL
        SELECT 'catalog'          AS channel,
               'cs_warehouse_sk'  col_name,
               d_year,
               d_qoy,
               i_category,
               cs_ext_sales_price ext_sales_price
        FROM   catalog_sales,
               item,
               date_dim
        WHERE  cs_warehouse_sk IS NULL
               AND cs_sold_date_sk = d_date_sk
               AND cs_item_sk = i_item_sk) foo
GROUP  BY channel,
          col_name,
          d_year,
          d_qoy,
          i_category
ORDER  BY channel,
          col_name,
          d_year,
          d_qoy,
          i_category
LIMIT 100;

-- TPCDS query 77:

-- query77
WITH ss AS
(
         SELECT   s_store_sk,
                  Sum(ss_ext_sales_price) AS sales,
                  Sum(ss_net_profit)      AS profit
         FROM     store_sales,
                  date_dim,
                  store
         WHERE    ss_sold_date_sk = d_date_sk
         AND      Cast(d_date AS DATE) BETWEEN Cast('2001-08-16' AS DATE) AND      (
                           Cast('2001-09-15' AS DATE))
         AND      ss_store_sk = s_store_sk
         GROUP BY s_store_sk) , sr AS
(
         SELECT   s_store_sk,
                  sum(sr_return_amt) AS returns1,
                  sum(sr_net_loss)   AS profit_loss
         FROM     store_returns,
                  date_dim,
                  store
         WHERE    sr_returned_date_sk = d_date_sk
         AND      Cast(d_date AS DATE) BETWEEN cast('2001-08-16' AS date) AND      (
                           Cast('2001-09-15' AS DATE))
         AND      sr_store_sk = s_store_sk
         GROUP BY s_store_sk), cs AS
(
         SELECT   cs_call_center_sk,
                  sum(cs_ext_sales_price) AS sales,
                  sum(cs_net_profit)      AS profit
         FROM     catalog_sales,
                  date_dim
         WHERE    cs_sold_date_sk = d_date_sk
         AND      Cast(d_date AS DATE) BETWEEN cast('2001-08-16' AS date) AND      (
                           Cast('2001-09-15' AS DATE))
         GROUP BY cs_call_center_sk ), cr AS
(
         SELECT   cr_call_center_sk,
                  sum(cr_return_amount) AS returns1,
                  sum(cr_net_loss)      AS profit_loss
         FROM     catalog_returns,
                  date_dim
         WHERE    cr_returned_date_sk = d_date_sk
         AND      Cast(d_date AS DATE) BETWEEN cast('2001-08-16' AS date) AND      (
                           Cast('2001-09-15' AS DATE))
         GROUP BY cr_call_center_sk ), ws AS
(
         SELECT   wp_web_page_sk,
                  sum(ws_ext_sales_price) AS sales,
                  sum(ws_net_profit)      AS profit
         FROM     web_sales,
                  date_dim,
                  web_page
         WHERE    ws_sold_date_sk = d_date_sk
         AND      Cast(d_date AS DATE) BETWEEN cast('2001-08-16' AS date) AND      (
                           Cast('2001-09-15' AS DATE))
         AND      ws_web_page_sk = wp_web_page_sk
         GROUP BY wp_web_page_sk), wr AS
(
         SELECT   wp_web_page_sk,
                  sum(wr_return_amt) AS returns1,
                  sum(wr_net_loss)   AS profit_loss
         FROM     web_returns,
                  date_dim,
                  web_page
         WHERE    wr_returned_date_sk = d_date_sk
         AND      Cast(d_date AS DATE) BETWEEN cast('2001-08-16' AS date) AND      (
                           Cast('2001-09-15' AS DATE))
         AND      wr_web_page_sk = wp_web_page_sk
         GROUP BY wp_web_page_sk)
SELECT
         channel ,
         id ,
         sum(sales)   AS sales ,
         sum(returns1) AS returns1 ,
         sum(profit)  AS profit
FROM     (
                   SELECT    'store channel' AS channel ,
                             ss.s_store_sk   AS id ,
                             sales ,
                             COALESCE(returns1, 0)               AS returns1 ,
                             (profit - COALESCE(profit_loss,0)) AS profit
                   FROM      ss
                   LEFT JOIN sr
                   ON        ss.s_store_sk = sr.s_store_sk
                   UNION ALL
                   SELECT 'catalog channel' AS channel ,
                          cs_call_center_sk AS id ,
                          sales ,
                          returns1 ,
                          (profit - profit_loss) AS profit
                   FROM   cs ,
                          cr
                   UNION ALL
                   SELECT    'web channel'     AS channel ,
                             ws.wp_web_page_sk AS id ,
                             sales ,
                             COALESCE(returns1, 0)                  returns1 ,
                             (profit - COALESCE(profit_loss,0)) AS profit
                   FROM      ws
                   LEFT JOIN wr
                   ON        ws.wp_web_page_sk = wr.wp_web_page_sk ) x
GROUP BY channel, id
ORDER BY channel ,
         id
LIMIT 100;


-- TPCDS query 78:
-- query78
WITH ws
     AS (SELECT d_year                 AS ws_sold_year,
                ws_item_sk,
                ws_bill_customer_sk    ws_customer_sk,
                Sum(ws_quantity)       ws_qty,
                Sum(ws_wholesale_cost) ws_wc,
                Sum(ws_sales_price)    ws_sp
         FROM   web_sales
                LEFT JOIN web_returns
                       ON wr_order_number = ws_order_number
                          AND ws_item_sk = wr_item_sk
                JOIN date_dim
                  ON ws_sold_date_sk = d_date_sk
         WHERE  wr_order_number IS NULL
         GROUP  BY d_year,
                   ws_item_sk,
                   ws_bill_customer_sk),
     cs
     AS (SELECT d_year                 AS cs_sold_year,
                cs_item_sk,
                cs_bill_customer_sk    cs_customer_sk,
                Sum(cs_quantity)       cs_qty,
                Sum(cs_wholesale_cost) cs_wc,
                Sum(cs_sales_price)    cs_sp
         FROM   catalog_sales
                LEFT JOIN catalog_returns
                       ON cr_order_number = cs_order_number
                          AND cs_item_sk = cr_item_sk
                JOIN date_dim
                  ON cs_sold_date_sk = d_date_sk
         WHERE  cr_order_number IS NULL
         GROUP  BY d_year,
                   cs_item_sk,
                   cs_bill_customer_sk),
     ss
     AS (SELECT d_year                 AS ss_sold_year,
                ss_item_sk,
                ss_customer_sk,
                Sum(ss_quantity)       ss_qty,
                Sum(ss_wholesale_cost) ss_wc,
                Sum(ss_sales_price)    ss_sp
         FROM   store_sales
                LEFT JOIN store_returns
                       ON sr_ticket_number = ss_ticket_number
                          AND ss_item_sk = sr_item_sk
                JOIN date_dim
                  ON ss_sold_date_sk = d_date_sk
         WHERE  sr_ticket_number IS NULL
         GROUP  BY d_year,
                   ss_item_sk,
                   ss_customer_sk)
SELECT ss_item_sk,
               Round(ss_qty / ( COALESCE(ws_qty + cs_qty, 1) ), 2) ratio,
               ss_qty                                              store_qty,
               ss_wc
               store_wholesale_cost,
               ss_sp
               store_sales_price,
               COALESCE(ws_qty, 0) + COALESCE(cs_qty, 0)
               other_chan_qty,
               COALESCE(ws_wc, 0) + COALESCE(cs_wc, 0)
               other_chan_wholesale_cost,
               COALESCE(ws_sp, 0) + COALESCE(cs_sp, 0)
               other_chan_sales_price
FROM   ss
       LEFT JOIN ws
              ON ( ws_sold_year = ss_sold_year
                   AND ws_item_sk = ss_item_sk
                   AND ws_customer_sk = ss_customer_sk )
       LEFT JOIN cs
              ON ( cs_sold_year = ss_sold_year
                   AND cs_item_sk = cs_item_sk
                   AND cs_customer_sk = ss_customer_sk )
WHERE  COALESCE(ws_qty, 0) > 0
       AND COALESCE(cs_qty, 0) > 0
       AND ss_sold_year = 1999
ORDER  BY ss_item_sk,
          ss_qty DESC,
          ss_wc DESC,
          ss_sp DESC,
          other_chan_qty,
          other_chan_wholesale_cost,
          other_chan_sales_price,
          Round(ss_qty / ( COALESCE(ws_qty + cs_qty, 1) ), 2)
LIMIT 100;

-- TPCDS query 79:
-- query79
SELECT c_last_name,
               c_first_name,
               Substr(s_city, 1, 30),
               ss_ticket_number,
               amt,
               profit
FROM   (SELECT ss_ticket_number,
               ss_customer_sk,
               store.s_city,
               Sum(ss_coupon_amt) amt,
               Sum(ss_net_profit) profit
        FROM   store_sales,
               date_dim,
               store,
               household_demographics
        WHERE  store_sales.ss_sold_date_sk = date_dim.d_date_sk
               AND store_sales.ss_store_sk = store.s_store_sk
               AND store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
               AND ( household_demographics.hd_dep_count = 8
                      OR household_demographics.hd_vehicle_count > 4 )
               AND date_dim.d_dow = 1
               AND date_dim.d_year IN ( 2000, 2000 + 1, 2000 + 2 )
               AND store.s_number_employees BETWEEN 200 AND 295
        GROUP  BY ss_ticket_number,
                  ss_customer_sk,
                  ss_addr_sk,
                  store.s_city) ms,
       customer
WHERE  ss_customer_sk = c_customer_sk
ORDER  BY c_last_name,
          c_first_name,
          Substr(s_city, 1, 30),
          profit
LIMIT 100;

-- TPCDS query 80:
-- query80
WITH ssr AS
(
                SELECT          s_store_id                                    AS store_id,
                                Sum(ss_ext_sales_price)                       AS sales,
                                Sum(COALESCE(sr_return_amt, 0))               AS returns1,
                                Sum(ss_net_profit - COALESCE(sr_net_loss, 0)) AS profit
                FROM            store_sales
                LEFT OUTER JOIN store_returns
                ON              (
                                                ss_item_sk = sr_item_sk
                                AND             ss_ticket_number = sr_ticket_number),
                                date_dim,
                                store,
                                item,
                                promotion
                WHERE           ss_sold_date_sk = d_date_sk
                AND             Cast(d_date AS DATE) BETWEEN Cast('2000-08-26' AS DATE) AND             (
                                                Cast('2001-09-25' AS DATE))
                AND             ss_store_sk = s_store_sk
                AND             ss_item_sk = i_item_sk
                AND             i_current_price > 50
                AND             ss_promo_sk = p_promo_sk
                AND             p_channel_tv = 'N'
                GROUP BY        s_store_id) , csr AS
(
                SELECT          cp_catalog_page_id                            AS catalog_page_id,
                                sum(cs_ext_sales_price)                       AS sales,
                                sum(COALESCE(cr_return_amount, 0))            AS returns1,
                                sum(cs_net_profit - COALESCE(cr_net_loss, 0)) AS profit
                FROM            catalog_sales
                LEFT OUTER JOIN catalog_returns
                ON              (
                                                cs_item_sk = cr_item_sk
                                AND             cs_order_number = cr_order_number),
                                date_dim,
                                catalog_page,
                                item,
                                promotion
                WHERE           cs_sold_date_sk = d_date_sk
                AND             Cast(d_date AS DATE) BETWEEN cast('2000-08-26' AS date) AND             (
                                                Cast('2001-09-25' AS DATE))
                AND             cs_catalog_page_sk = cp_catalog_page_sk
                AND             cs_item_sk = i_item_sk
                AND             i_current_price > 50
                AND             cs_promo_sk = p_promo_sk
                AND             p_channel_tv = 'N'
                GROUP BY        cp_catalog_page_id) , wsr AS
(
                SELECT          web_site_id,
                                sum(ws_ext_sales_price)                       AS sales,
                                sum(COALESCE(wr_return_amt, 0))               AS returns1,
                                sum(ws_net_profit - COALESCE(wr_net_loss, 0)) AS profit
                FROM            web_sales
                LEFT OUTER JOIN web_returns
                ON              (
                                                ws_item_sk = wr_item_sk
                                AND             ws_order_number = wr_order_number),
                                date_dim,
                                web_site,
                                item,
                                promotion
                WHERE           ws_sold_date_sk = d_date_sk
                AND             Cast(d_date AS DATE) BETWEEN cast('2000-08-26' AS date) AND             (
                                                Cast('2001-09-25' AS DATE))
                AND             ws_web_site_sk = web_site_sk
                AND             ws_item_sk = i_item_sk
                AND             i_current_price > 50
                AND             ws_promo_sk = p_promo_sk
                AND             p_channel_tv = 'N'
                GROUP BY        web_site_id)
SELECT
         channel ,
         id ,
         sum(sales)   AS sales ,
         sum(returns1) AS returns1 ,
         sum(profit)  AS profit
FROM     (
                SELECT 'store channel' AS channel ,
                       Concat('store', store_id) AS id ,
                       sales ,
                       returns1 ,
                       profit
                FROM   ssr
                UNION ALL
                SELECT 'catalog channel' AS channel ,
                       Concat('catalog_page', catalog_page_id) AS id ,
                       sales ,
                       returns1 ,
                       profit
                FROM   csr
                UNION ALL
                SELECT 'web channel' AS channel ,
                       Concat('web_site', web_site_id) AS id ,
                       sales ,
                       returns1 ,
                       profit
                FROM   wsr ) x
GROUP BY channel, id
ORDER BY channel ,
         id
LIMIT 100;


-- TPCDS query 81:

-- query81
WITH customer_total_return
     AS (SELECT cr_returning_customer_sk   AS ctr_customer_sk,
                ca_state                   AS ctr_state,
                Sum(cr_return_amt_inc_tax) AS ctr_total_return
         FROM   catalog_returns,
                date_dim,
                customer_address
         WHERE  cr_returned_date_sk = d_date_sk
                AND d_year = 1999
                AND cr_returning_addr_sk = ca_address_sk
         GROUP  BY cr_returning_customer_sk,
                   ca_state),
high_return AS (
    SELECT ctr_state AS hr_state, Avg(ctr_total_return) * 1.2 AS hr_limit
    FROM   customer_total_return
    GROUP BY ctr_state
)
SELECT c_customer_id,
               c_salutation,
               c_first_name,
               c_last_name,
               ca_street_number,
               ca_street_name,
               ca_street_type,
               ca_suite_number,
               ca_city,
               ca_county,
               ca_state,
               ca_zip,
               ca_country,
               ca_gmt_offset,
               ca_location_type,
               ctr_total_return
FROM   customer_total_return,
       high_return,
       customer_address,
       customer
WHERE  ctr_state = hr_state
       AND ctr_customer_sk = c_customer_sk
       AND ca_address_sk = c_current_addr_sk
       AND ca_state = 'TX'
       AND ctr_total_return > hr_limit
ORDER  BY c_customer_id,
          c_salutation,
          c_first_name,
          c_last_name,
          ca_street_number,
          ca_street_name,
          ca_street_type,
          ca_suite_number,
          ca_city,
          ca_county,
          ca_state,
          ca_zip,
          ca_country,
          ca_gmt_offset,
          ca_location_type,
          ctr_total_return
LIMIT 100;

-- TPCDS query 82:

-- query82
SELECT
         i_item_id ,
         i_item_desc ,
         i_current_price
FROM     item,
         inventory,
         date_dim,
         store_sales
WHERE    i_current_price BETWEEN 63 AND      63+30
AND      inv_item_sk = i_item_sk
AND      d_date_sk=inv_date_sk
AND      Cast(d_date AS DATE) BETWEEN Cast('1998-04-27' AS DATE) AND      (
                  Cast('1998-06-27' AS DATE))
AND      i_manufact_id IN (57,293,427,320)
AND      inv_quantity_on_hand BETWEEN 100 AND      500
AND      ss_item_sk = i_item_sk
GROUP BY i_item_id,
         i_item_desc,
         i_current_price
ORDER BY i_item_id
LIMIT 100;


-- TPCDS query 83:
-- query83
WITH sr_items
     AS (SELECT i_item_id               item_id,
                Sum(sr_return_quantity) sr_item_qty
         FROM   store_returns,
                item,
                date_dim
         WHERE  sr_item_sk = i_item_sk
                AND d_date IN (SELECT d_date
                               FROM   date_dim
                               WHERE  d_week_seq IN (SELECT d_week_seq
                                                     FROM   date_dim
                                                     WHERE
                                      d_date IN ( '1999-06-30',
                                                  '1999-08-28',
                                                  '1999-11-18'
                                                )))
                AND sr_returned_date_sk = d_date_sk
         GROUP  BY i_item_id),
     cr_items
     AS (SELECT i_item_id               item_id,
                Sum(cr_return_quantity) cr_item_qty
         FROM   catalog_returns,
                item,
                date_dim
         WHERE  cr_item_sk = i_item_sk
                AND d_date IN (SELECT d_date
                               FROM   date_dim
                               WHERE  d_week_seq IN (SELECT d_week_seq
                                                     FROM   date_dim
                                                     WHERE
                                      d_date IN ( '1999-06-30',
                                                  '1999-08-28',
                                                  '1999-11-18'
                                                )))
                AND cr_returned_date_sk = d_date_sk
         GROUP  BY i_item_id),
     wr_items
     AS (SELECT i_item_id               item_id,
                Sum(wr_return_quantity) wr_item_qty
         FROM   web_returns,
                item,
                date_dim
         WHERE  wr_item_sk = i_item_sk
                AND d_date IN (SELECT d_date
                               FROM   date_dim
                               WHERE  d_week_seq IN (SELECT d_week_seq
                                                     FROM   date_dim
                                                     WHERE
                                      d_date IN ( '1999-06-30',
                                                  '1999-08-28',
                                                  '1999-11-18'
                                                )))
                AND wr_returned_date_sk = d_date_sk
         GROUP  BY i_item_id)
SELECT sr_items.item_id,
               sr_item_qty,
               sr_item_qty / ( sr_item_qty + cr_item_qty + wr_item_qty ) / 3.0 *
               100 sr_dev,
               cr_item_qty,
               cr_item_qty / ( sr_item_qty + cr_item_qty + wr_item_qty ) / 3.0 *
               100 cr_dev,
               wr_item_qty,
               wr_item_qty / ( sr_item_qty + cr_item_qty + wr_item_qty ) / 3.0 *
               100 wr_dev,
               ( sr_item_qty + cr_item_qty + wr_item_qty ) / 3.0
               average
FROM   sr_items,
       cr_items,
       wr_items
WHERE  sr_items.item_id = cr_items.item_id
       AND sr_items.item_id = wr_items.item_id
ORDER  BY sr_items.item_id,
          sr_item_qty
LIMIT 100;

-- TPCDS query 84:
-- query84
SELECT c_customer_id   AS customer_id,
       Concat(c_last_name, Concat(', ', c_first_name))  AS customername
FROM   customer,
       customer_address,
       customer_demographics,
       household_demographics,
       income_band,
       store_returns
WHERE  ca_city = 'Green Acres'
       AND c_current_addr_sk = ca_address_sk
       AND ib_lower_bound >= 54986
       AND ib_upper_bound <= 54986 + 50000
       AND ib_income_band_sk = hd_income_band_sk
       AND cd_demo_sk = c_current_cdemo_sk
       AND hd_demo_sk = c_current_hdemo_sk
       AND sr_cdemo_sk = cd_demo_sk
ORDER  BY c_customer_id
LIMIT 100;

-- TPCDS query 85:
-- query85
SELECT Substr(r_reason_desc, 1, 20),
               Avg(ws_quantity),
               Avg(wr_refunded_cash),
               Avg(wr_fee)
FROM   web_sales,
       web_returns,
       web_page,
       customer_demographics cd1,
       customer_demographics cd2,
       customer_address,
       date_dim,
       reason
WHERE  ws_web_page_sk = wp_web_page_sk
       AND ws_item_sk = wr_item_sk
       AND ws_order_number = wr_order_number
       AND ws_sold_date_sk = d_date_sk
       AND d_year = 2001
       AND cd1.cd_demo_sk = wr_refunded_cdemo_sk
       AND cd2.cd_demo_sk = wr_returning_cdemo_sk
       AND ca_address_sk = wr_refunded_addr_sk
       AND r_reason_sk = wr_reason_sk
       AND ( ( cd1.cd_marital_status = 'W'
               AND cd1.cd_marital_status = cd2.cd_marital_status
               AND cd1.cd_education_status = 'Primary'
               AND cd1.cd_education_status = cd2.cd_education_status
               AND ws_sales_price BETWEEN 100.00 AND 150.00 )
              OR ( cd1.cd_marital_status = 'D'
                   AND cd1.cd_marital_status = cd2.cd_marital_status
                   AND cd1.cd_education_status = 'Secondary'
                   AND cd1.cd_education_status = cd2.cd_education_status
                   AND ws_sales_price BETWEEN 50.00 AND 100.00 )
              OR ( cd1.cd_marital_status = 'M'
                   AND cd1.cd_marital_status = cd2.cd_marital_status
                   AND cd1.cd_education_status = 'Advanced Degree'
                   AND cd1.cd_education_status = cd2.cd_education_status
                   AND ws_sales_price BETWEEN 150.00 AND 200.00 ) )
       AND ( ( ca_country = 'United States'
               AND ca_state IN ( 'KY', 'ME', 'IL' )
               AND ws_net_profit BETWEEN 100 AND 200 )
              OR ( ca_country = 'United States'
                   AND ca_state IN ( 'OK', 'NE', 'MN' )
                   AND ws_net_profit BETWEEN 150 AND 300 )
              OR ( ca_country = 'United States'
                   AND ca_state IN ( 'FL', 'WI', 'KS' )
                   AND ws_net_profit BETWEEN 50 AND 250 ) )
GROUP  BY r_reason_desc
ORDER  BY Substr(r_reason_desc, 1, 20),
          Avg(ws_quantity),
          Avg(wr_refunded_cash),
          Avg(wr_fee)
LIMIT 100;

-- TPCDS query 86:
-- query86
SELECT Sum(ws_net_paid)                         AS total_sum,
               i_category,
               i_class,
               Rank()
                 OVER (
                   PARTITION BY i_category, i_class
                   ORDER BY Sum(ws_net_paid) DESC)      AS rank_within_parent
FROM   web_sales,
       date_dim d1,
       item
WHERE  d1.d_month_seq BETWEEN 1183 AND 1183 + 11
       AND d1.d_date_sk = ws_sold_date_sk
       AND i_item_sk = ws_item_sk
GROUP  BY i_category, i_class
ORDER  BY i_category,
          rank_within_parent
LIMIT 100;

-- TPCDS query 87:
-- query87
with store_customers as (
  select distinct c_last_name as sc_last, c_first_name as sc_first, d_date as sc_date
  from store_sales, date_dim, customer
  where store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_customer_sk = customer.c_customer_sk
    and d_month_seq between 1188 and 1188+11
),
catalog_customers as (
  select distinct c_last_name as cc_last, c_first_name as cc_first, d_date as cc_date
  from catalog_sales, date_dim, customer
  where catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
    and catalog_sales.cs_bill_customer_sk = customer.c_customer_sk
    and d_month_seq between 1188 and 1188+11
),
web_customers as (
  select distinct c_last_name as wc_last, c_first_name as wc_first, d_date as wc_date
  from web_sales, date_dim, customer
  where web_sales.ws_sold_date_sk = date_dim.d_date_sk
    and web_sales.ws_bill_customer_sk = customer.c_customer_sk
    and d_month_seq between 1188 and 1188+11
)
select count(1)
from store_customers
where not exists (
  select 1 from catalog_customers
  where sc_last = cc_last and sc_first = cc_first and sc_date = cc_date
)
and not exists (
  select 1 from web_customers
  where sc_last = wc_last and sc_first = wc_first and sc_date = wc_date
);


-- TPCDS query 88:
-- query88
select  *
from
 (select count(*) h8_30_to_9
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 8
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = -1 and household_demographics.hd_vehicle_count<=-1+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2))
     and store.s_store_name = 'ese') s1,
 (select count(*) h9_to_9_30
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 9
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = -1 and household_demographics.hd_vehicle_count<=-1+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2))
     and store.s_store_name = 'ese') s2,
 (select count(*) h9_30_to_10
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 9
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = -1 and household_demographics.hd_vehicle_count<=-1+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2))
     and store.s_store_name = 'ese') s3,
 (select count(*) h10_to_10_30
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 10
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = -1 and household_demographics.hd_vehicle_count<=-1+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2))
     and store.s_store_name = 'ese') s4,
 (select count(*) h10_30_to_11
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 10
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = -1 and household_demographics.hd_vehicle_count<=-1+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2))
     and store.s_store_name = 'ese') s5,
 (select count(*) h11_to_11_30
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 11
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = -1 and household_demographics.hd_vehicle_count<=-1+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2))
     and store.s_store_name = 'ese') s6,
 (select count(*) h11_30_to_12
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 11
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = -1 and household_demographics.hd_vehicle_count<=-1+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2))
     and store.s_store_name = 'ese') s7,
 (select count(*) h12_to_12_30
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 12
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = -1 and household_demographics.hd_vehicle_count<=-1+2) or
          (household_demographics.hd_dep_count = 2 and household_demographics.hd_vehicle_count<=2+2) or
          (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2))
     and store.s_store_name = 'ese') s8
;


-- TPCDS query 89:
-- query89
SELECT  *
FROM  (SELECT i_category,
              i_class,
              i_brand,
              s_store_name,
              s_company_name,
              d_moy,
              Sum(ss_sales_price) sum_sales,
              Avg(Sum(ss_sales_price))
                OVER (
                  partition BY i_category, i_brand, s_store_name, s_company_name
                )
                                  avg_monthly_sales
       FROM   item,
              store_sales,
              date_dim,
              store
       WHERE  ss_item_sk = i_item_sk
              AND ss_sold_date_sk = d_date_sk
              AND ss_store_sk = s_store_sk
              AND d_year IN ( 2002 )
              AND ( ( i_category IN ( 'Home', 'Men', 'Sports' )
                      AND i_class IN ( 'paint', 'accessories', 'fitness' ) )
                     OR ( i_category IN ( 'Shoes', 'Jewelry', 'Women' )
                          AND i_class IN ( 'mens', 'pendants', 'swimwear' ) ) )
       GROUP  BY i_category,
                 i_class,
                 i_brand,
                 s_store_name,
                 s_company_name,
                 d_moy) tmp1
WHERE  CASE
         WHEN ( avg_monthly_sales <> 0 ) THEN (
         Abs(sum_sales - avg_monthly_sales) / avg_monthly_sales )
         ELSE NULL
       END > 0.1
ORDER  BY sum_sales - avg_monthly_sales,
          s_store_name
LIMIT 100;

-- TPCDS query 90:

-- query90
SELECT amc / pmc AS am_pm_ratio
FROM   (SELECT Count(*) amc
        FROM   web_sales,
               household_demographics,
               time_dim,
               web_page
        WHERE  ws_sold_time_sk = time_dim.t_time_sk
               AND ws_ship_hdemo_sk = household_demographics.hd_demo_sk
               AND ws_web_page_sk = web_page.wp_web_page_sk
               AND time_dim.t_hour BETWEEN 12 AND 12 + 1
               AND household_demographics.hd_dep_count = 8
               AND web_page.wp_char_count BETWEEN 5000 AND 5200) at1,
       (SELECT Count(*) pmc
        FROM   web_sales,
               household_demographics,
               time_dim,
               web_page
        WHERE  ws_sold_time_sk = time_dim.t_time_sk
               AND ws_ship_hdemo_sk = household_demographics.hd_demo_sk
               AND ws_web_page_sk = web_page.wp_web_page_sk
               AND time_dim.t_hour BETWEEN 20 AND 20 + 1
               AND household_demographics.hd_dep_count = 8
               AND web_page.wp_char_count BETWEEN 5000 AND 5200) pt
ORDER  BY am_pm_ratio
LIMIT 100;

-- TPCDS query 91:
-- query91

SELECT cc_call_center_id Call_Center,
       cc_name           Call_Center_Name,
       cc_manager        Manager,
       Sum(cr_net_loss)  Returns_Loss
FROM   call_center,
       catalog_returns,
       date_dim,
       customer,
       customer_address,
       customer_demographics,
       household_demographics
WHERE  cr_call_center_sk = cc_call_center_sk
       AND cr_returned_date_sk = d_date_sk
       AND cr_returning_customer_sk = c_customer_sk
       AND cd_demo_sk = c_current_cdemo_sk
       AND hd_demo_sk = c_current_hdemo_sk
       AND ca_address_sk = c_current_addr_sk
       AND d_year = 1999
       AND d_moy = 12
       AND ( ( cd_marital_status = 'M'
               AND cd_education_status = 'Unknown' )
              OR ( cd_marital_status = 'W'
                   AND cd_education_status = 'Advanced Degree' ) )
       AND hd_buy_potential LIKE 'Unknown%%'
       AND ca_gmt_offset = -7
GROUP  BY cc_call_center_id,
          cc_name,
          cc_manager,
          cd_marital_status,
          cd_education_status
ORDER  BY Sum(cr_net_loss) DESC;


-- TPCDS query 92:
-- query92
SELECT
         Sum(ws_ext_discount_amt) AS excess_discount_amount
FROM     web_sales ,
         item ,
         date_dim
WHERE    i_manufact_id = 718
AND      i_item_sk = ws_item_sk
AND      Cast(d_date AS DATE) BETWEEN Cast('2002-03-29' AS DATE) AND      (
                  Cast('2002-06-28' AS DATE))
AND      d_date_sk = ws_sold_date_sk
AND      ws_ext_discount_amt >
         (
                SELECT 1.3 * avg(ws_ext_discount_amt)
                FROM   web_sales ,
                       date_dim
                WHERE  ws_item_sk = i_item_sk
                AND    Cast(d_date AS DATE) BETWEEN Cast('2002-03-29' AS DATE) AND    (
                              cast('2002-06-28' AS date))
                AND    d_date_sk = ws_sold_date_sk )
ORDER BY sum(ws_ext_discount_amt)
LIMIT 100;


-- TPCDS query 93:
-- query93
SELECT ss_customer_sk,
               Sum(act_sales) sumsales
FROM   (SELECT ss_item_sk,
               ss_ticket_number,
               ss_customer_sk,
               CASE
                 WHEN sr_return_quantity IS NOT NULL THEN
                 ( ss_quantity - sr_return_quantity ) * ss_sales_price
                 ELSE ( ss_quantity * ss_sales_price )
               END act_sales
        FROM   store_sales
               LEFT OUTER JOIN store_returns
                            ON ( sr_item_sk = ss_item_sk
                                 AND sr_ticket_number = ss_ticket_number ),
               reason
        WHERE  sr_reason_sk = r_reason_sk
               AND r_reason_desc = 'reason 38') t
GROUP  BY ss_customer_sk
ORDER  BY sumsales,
          ss_customer_sk
LIMIT 100;

-- TPCDS query 94:
-- query94
SELECT
         Count(DISTINCT ws_order_number) AS order_count,
         Sum(ws_ext_ship_cost)           AS total_shipping_cost ,
         Sum(ws_net_profit)              AS total_net_profit
FROM     web_sales ws1 ,
         date_dim ,
         customer_address ,
         web_site
WHERE    Cast(d_date AS DATE) BETWEEN Cast('2000-3-01' AS DATE) AND      (
                  Cast('2000-5-01' AS DATE))
AND      ws1.ws_ship_date_sk = d_date_sk
AND      ws1.ws_ship_addr_sk = ca_address_sk
AND      ca_state = 'MT'
AND      ws1.ws_web_site_sk = web_site_sk
AND      web_company_name = 'pri'
AND      EXISTS
         (
                SELECT *
                FROM   web_sales ws2
                WHERE  ws1.ws_order_number = ws2.ws_order_number
                AND    ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk)
AND      NOT EXISTS
         (
                SELECT *
                FROM   web_returns wr1
                WHERE  ws1.ws_order_number = wr1.wr_order_number)
ORDER BY count(DISTINCT ws_order_number)
LIMIT 100;


-- TPCDS query 95:
-- query95
WITH ws_wh AS
(
       SELECT ws1.ws_order_number,
              ws1.ws_warehouse_sk wh1,
              ws2.ws_warehouse_sk wh2
       FROM   web_sales ws1,
              web_sales ws2
       WHERE  ws1.ws_order_number = ws2.ws_order_number
       AND    ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk)
SELECT
         Count(DISTINCT ws_order_number) AS order_count,
         Sum(ws_ext_ship_cost)           AS total_shipping_cost,
         Sum(ws_net_profit)              AS total_net_profit
FROM     web_sales ws1 ,
         date_dim ,
         customer_address ,
         web_site
WHERE    Cast(d_date AS DATE) BETWEEN Cast('2000-4-01' AS DATE) AND      (
                  Cast('2000-6-01' AS DATE))
AND      ws1.ws_ship_date_sk = d_date_sk
AND      ws1.ws_ship_addr_sk = ca_address_sk
AND      ca_state = 'IN'
AND      ws1.ws_web_site_sk = web_site_sk
AND      web_company_name = 'pri'
AND      ws1.ws_order_number IN
         (
                SELECT ws_order_number
                FROM   ws_wh)
AND      ws1.ws_order_number IN
         (
                SELECT wr_order_number
                FROM   web_returns,
                       ws_wh
                WHERE  wr_order_number = ws_wh.ws_order_number)
ORDER BY count(DISTINCT ws_order_number)
LIMIT 100;


-- TPCDS query 96:
-- query96
SELECT Count(*)
FROM   store_sales,
       household_demographics,
       time_dim,
       store
WHERE  ss_sold_time_sk = time_dim.t_time_sk
       AND ss_hdemo_sk = household_demographics.hd_demo_sk
       AND ss_store_sk = s_store_sk
       AND time_dim.t_hour = 15
       AND time_dim.t_minute >= 30
       AND household_demographics.hd_dep_count = 7
       AND store.s_store_name = 'ese'
ORDER  BY Count(*)
LIMIT 100;

-- TPCDS query 97:

-- query97
WITH ssci
     AS (SELECT ss_customer_sk customer_sk,
                ss_item_sk     item_sk
         FROM   store_sales,
                date_dim
         WHERE  ss_sold_date_sk = d_date_sk
                AND d_month_seq BETWEEN 1196 AND 1196 + 11
         GROUP  BY ss_customer_sk,
                   ss_item_sk),
     csci
     AS (SELECT cs_bill_customer_sk customer_sk,
                cs_item_sk          item_sk
         FROM   catalog_sales,
                date_dim
         WHERE  cs_sold_date_sk = d_date_sk
                AND d_month_seq BETWEEN 1196 AND 1196 + 11
         GROUP  BY cs_bill_customer_sk,
                   cs_item_sk)
SELECT Sum(CASE
                     WHEN ssci.customer_sk IS NOT NULL
                          AND csci.customer_sk IS NULL THEN 1
                     ELSE 0
                   END) store_only,
               Sum(CASE
                     WHEN ssci.customer_sk IS NULL
                          AND csci.customer_sk IS NOT NULL THEN 1
                     ELSE 0
                   END) catalog_only,
               Sum(CASE
                     WHEN ssci.customer_sk IS NOT NULL
                          AND csci.customer_sk IS NOT NULL THEN 1
                     ELSE 0
                   END) store_and_catalog
FROM   ssci
       FULL OUTER JOIN csci
                    ON ( ssci.customer_sk = csci.customer_sk
                         AND ssci.item_sk = csci.item_sk )
LIMIT 100;

-- TPCDS query 98:

-- query98
SELECT i_item_id,
       i_item_desc,
       i_category,
       i_class,
       i_current_price,
       Sum(ss_ext_sales_price)                                   AS itemrevenue,
       Sum(ss_ext_sales_price) * 100 / Sum(Sum(ss_ext_sales_price))
                                         OVER (
                                           PARTITION BY i_class) AS revenueratio
FROM   store_sales,
       item,
       date_dim
WHERE  ss_item_sk = i_item_sk
       AND i_category IN ( 'Men', 'Home', 'Electronics' )
       AND ss_sold_date_sk = d_date_sk
       AND Cast(d_date AS DATE) BETWEEN CAST('2000-05-18' AS DATE) AND (
                          CAST('2000-06-18' AS DATE) )
GROUP  BY i_item_id,
          i_item_desc,
          i_category,
          i_class,
          i_current_price
ORDER  BY i_category,
          i_class,
          i_item_id,
          i_item_desc,
          revenueratio;

-- TPCDS query 99:


-- query99
SELECT Substr(w_warehouse_name, 1, 20),
               sm_type,
               cc_name,
               Sum(CASE
                     WHEN ( cs_ship_date_sk - cs_sold_date_sk <= 30 ) THEN 1
                     ELSE 0
                   END) AS days_30,
               Sum(CASE
                     WHEN ( cs_ship_date_sk - cs_sold_date_sk > 30 )
                          AND ( cs_ship_date_sk - cs_sold_date_sk <= 60 ) THEN 1
                     ELSE 0
                   END) AS days_31_60,
               Sum(CASE
                     WHEN ( cs_ship_date_sk - cs_sold_date_sk > 60 )
                          AND ( cs_ship_date_sk - cs_sold_date_sk <= 90 ) THEN 1
                     ELSE 0
                   END) AS days_61_90,
               Sum(CASE
                     WHEN ( cs_ship_date_sk - cs_sold_date_sk > 90 )
                          AND ( cs_ship_date_sk - cs_sold_date_sk <= 120 ) THEN
                     1
                     ELSE 0
                   END) AS days_91_120,
               Sum(CASE
                     WHEN ( cs_ship_date_sk - cs_sold_date_sk > 120 ) THEN 1
                     ELSE 0
                   END) AS days_over_120
FROM   catalog_sales,
       warehouse,
       ship_mode,
       call_center,
       date_dim
WHERE  d_month_seq BETWEEN 1200 AND 1200 + 11
       AND cs_ship_date_sk = d_date_sk
       AND cs_warehouse_sk = w_warehouse_sk
       AND cs_ship_mode_sk = sm_ship_mode_sk
       AND cs_call_center_sk = cc_call_center_sk
GROUP  BY 1, 2, 3
ORDER  BY 1, 2, 3
LIMIT 100;

