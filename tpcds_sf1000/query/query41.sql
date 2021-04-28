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
