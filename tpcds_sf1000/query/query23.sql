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
