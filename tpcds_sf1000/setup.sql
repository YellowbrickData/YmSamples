CREATE SCHEMA IF NOT EXISTS "tpcds_sf1000";
GRANT ALL ON SCHEMA "tpcds_sf1000" TO public;
SET SEARCH_PATH TO "tpcds_sf1000";

CREATE EXTERNAL STORAGE "tpcds_sf1000"."sample_tpcds_qa_es" TYPE S3 ENDPOINT 'https://s3.us-west-2.amazonaws.com/' REGION 'us-west-2' IDENTITY '' CREDENTIAL '';
CREATE EXTERNAL FORMAT IF NOT EXISTS "tpcds_sf1000"."sample_tpcds_qa_ef" TYPE CSV WITH (DELIMITER '|', ON_MISSING_FIELD 'SUPPLYNULL', ON_EXTRA_FIELD 'REMOVE');
CREATE EXTERNAL LOCATION "tpcds_sf1000"."sample_tpcds_qa_el" PATH 'yb-sampledata-d4f1c23ea7' EXTERNAL STORAGE "tpcds_sf1000"."sample_tpcds_qa_es" EXTERNAL FORMAT "tpcds_sf1000"."sample_tpcds_qa_ef";

GRANT ALL ON EXTERNAL STORAGE "tpcds_sf1000"."sample_tpcds_qa_es" TO public;
GRANT ALL ON EXTERNAL FORMAT "tpcds_sf1000"."sample_tpcds_qa_ef" TO public;
GRANT ALL ON EXTERNAL LOCATION "tpcds_sf1000"."sample_tpcds_qa_el" TO public;

CREATE TABLE date_dim (
    d_date_sk integer NOT NULL,
    d_date_id char(16) NOT NULL,
    d_date date,
    d_month_seq bigint,
    d_week_seq bigint,
    d_quarter_seq bigint,
    d_year bigint,
    d_dow bigint,
    d_moy bigint,
    d_dom bigint,
    d_qoy bigint,
    d_fy_year bigint,
    d_fy_quarter_seq bigint,
    d_fy_week_seq bigint,
    d_day_name char(9),
    d_quarter_name char(6),
    d_holiday char(1),
    d_weekend char(1),
    d_following_holiday char(1),
    d_first_dom bigint,
    d_last_dom bigint,
    d_same_day_ly bigint,
    d_same_day_lq bigint,
    d_current_day char(1),
    d_current_week char(1),
    d_current_month char(1),
    d_current_quarter char(1),
    d_current_year char(1)
) DISTRIBUTE REPLICATE;

ALTER TABLE date_dim
    ADD CONSTRAINT date_dim_pkey PRIMARY KEY (d_date_sk);

CREATE TABLE time_dim (
    t_time_sk integer NOT NULL,
    t_time_id char(16) NOT NULL,
    t_time bigint,
    t_hour bigint,
    t_minute bigint,
    t_second bigint,
    t_am_pm char(2),
    t_shift char(20),
    t_sub_shift char(20),
    t_meal_time char(20)
) DISTRIBUTE REPLICATE;

ALTER TABLE time_dim
    ADD CONSTRAINT time_dim_pkey PRIMARY KEY (t_time_sk);

CREATE TABLE call_center (
    cc_call_center_sk smallint NOT NULL,
    cc_call_center_id char(16) NOT NULL,
    cc_rec_start_date date,
    cc_rec_end_date date,
    cc_closed_date_sk bigint,
    cc_open_date_sk bigint,
    cc_name varchar(50),
    cc_class varchar(50),
    cc_employees bigint,
    cc_sq_ft bigint,
    cc_hours char(20),
    cc_manager varchar(40),
    cc_mkt_id bigint,
    cc_mkt_class char(50),
    cc_mkt_desc varchar(100),
    cc_market_manager varchar(40),
    cc_division bigint,
    cc_division_name varchar(50),
    cc_company bigint,
    cc_company_name char(50),
    cc_street_number char(10),
    cc_street_name varchar(60),
    cc_street_type char(15),
    cc_suite_number char(10),
    cc_city varchar(60),
    cc_county varchar(30),
    cc_state char(2),
    cc_zip char(10),
    cc_country varchar(20),
    cc_gmt_offset numeric(5,2),
    cc_tax_percentage numeric(5,2)
) DISTRIBUTE REPLICATE;

ALTER TABLE call_center
    ADD CONSTRAINT call_center_pkey PRIMARY KEY (cc_call_center_sk);

CREATE TABLE catalog_page (
    cp_catalog_page_sk integer NOT NULL,
    cp_catalog_page_id char(16) NOT NULL,
    cp_start_date_sk bigint,
    cp_end_date_sk bigint,
    cp_department varchar(50),
    cp_catalog_number bigint,
    cp_catalog_page_number bigint,
    cp_description varchar(100),
    cp_type varchar(100)
) DISTRIBUTE REPLICATE;

ALTER TABLE catalog_page
    ADD CONSTRAINT catalog_page_pkey PRIMARY KEY (cp_catalog_page_sk);

CREATE TABLE household_demographics
(
    hd_demo_sk bigint NOT NULL PRIMARY KEY,
    hd_income_band_sk bigint,
    hd_buy_potential char(15),
    hd_dep_count bigint,
    hd_vehicle_count bigint
) DISTRIBUTE REPLICATE;


CREATE TABLE customer_address (
    ca_address_sk bigint NOT NULL,
    ca_address_id char(16) NOT NULL,
    ca_street_number char(10),
    ca_street_name varchar(60),
    ca_street_type char(15),
    ca_suite_number char(10),
    ca_city varchar(60),
    ca_county varchar(30),
    ca_state char(2),
    ca_zip char(10),
    ca_country varchar(20),
    ca_gmt_offset numeric(5,2),
    ca_location_type char(20)
) DISTRIBUTE REPLICATE;

ALTER TABLE customer_address
    ADD CONSTRAINT customer_address_pkey PRIMARY KEY (ca_address_sk);

CREATE TABLE customer_demographics (
    cd_demo_sk bigint NOT NULL,
    cd_gender char(1),
    cd_marital_status char(1),
    cd_education_status char(20),
    cd_purchase_estimate bigint,
    cd_credit_rating char(10),
    cd_dep_count bigint,
    cd_dep_employed_count bigint,
    cd_dep_college_count bigint
) DISTRIBUTE REPLICATE;

ALTER TABLE customer_demographics
    ADD CONSTRAINT customer_demographics_pkey PRIMARY KEY (cd_demo_sk);

CREATE TABLE customer (
    c_customer_sk bigint NOT NULL,
    c_customer_id char(16) NOT NULL,
    c_current_cdemo_sk bigint,
    c_current_hdemo_sk bigint,
    c_current_addr_sk bigint,
    c_first_shipto_date_sk integer,
    c_first_sales_date_sk integer,
    c_salutation char(10),
    c_first_name char(20),
    c_last_name char(30),
    c_preferred_cust_flag char(1),
    c_birth_day integer,
    c_birth_month integer,
    c_birth_year integer,
    c_birth_country varchar(20),
    c_login char(13),
    c_email_address char(50),
    c_last_review_date char(10)
) DISTRIBUTE ON (c_customer_sk);

ALTER TABLE customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (c_customer_sk);

ALTER TABLE customer
    ADD CONSTRAINT customer_c_current_addr_sk_fkey FOREIGN KEY (c_current_addr_sk) REFERENCES customer_address(ca_address_sk);


ALTER TABLE customer
    ADD CONSTRAINT customer_c_current_cdemo_sk_fkey FOREIGN KEY (c_current_cdemo_sk) REFERENCES customer_demographics(cd_demo_sk);


ALTER TABLE customer ADD CONSTRAINT customer_c_current_hdemo_sk_fkey
    FOREIGN KEY (c_current_hdemo_sk) REFERENCES household_demographics(hd_demo_sk);


ALTER TABLE customer
    ADD CONSTRAINT customer_c_first_sales_date_sk_fkey FOREIGN KEY (c_first_sales_date_sk) REFERENCES date_dim(d_date_sk);


ALTER TABLE customer
    ADD CONSTRAINT customer_c_first_shipto_date_sk_fkey FOREIGN KEY (c_first_shipto_date_sk) REFERENCES date_dim(d_date_sk);


CREATE TABLE income_band (
    ib_income_band_sk bigint NOT NULL,
    ib_lower_bound bigint,
    ib_upper_bound bigint
) DISTRIBUTE REPLICATE;

ALTER TABLE income_band
    ADD CONSTRAINT income_band_pkey PRIMARY KEY (ib_income_band_sk);

CREATE TABLE item (
    i_item_sk integer NOT NULL,
    i_item_id char(16) NOT NULL,
    i_rec_start_date date,
    i_rec_end_date date,
    i_item_desc varchar(200),
    i_current_price numeric(7,2),
    i_wholesale_cost numeric(7,2),
    i_brand_id bigint,
    i_brand char(50),
    i_class_id bigint,
    i_class char(50),
    i_category_id bigint,
    i_category char(50),
    i_manufact_id bigint,
    i_manufact char(50),
    i_size char(20),
    i_formulation char(20),
    i_color char(20),
    i_units char(10),
    i_container char(10),
    i_manager_id bigint,
    i_product_name char(50)
) DISTRIBUTE REPLICATE;

ALTER TABLE item
    ADD CONSTRAINT item_pkey PRIMARY KEY (i_item_sk);

CREATE TABLE promotion (
    p_promo_sk smallint NOT NULL,
    p_promo_id char(16) NOT NULL,
    p_start_date_sk bigint,
    p_end_date_sk bigint,
    p_item_sk bigint,
    p_cost numeric(15,2),
    p_response_target bigint,
    p_promo_name char(50),
    p_channel_dmail char(1),
    p_channel_email char(1),
    p_channel_catalog char(1),
    p_channel_tv char(1),
    p_channel_radio char(1),
    p_channel_press char(1),
    p_channel_event char(1),
    p_channel_demo char(1),
    p_channel_details varchar(100),
    p_purpose char(15),
    p_discount_active char(1)
) DISTRIBUTE REPLICATE;

ALTER TABLE promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (p_promo_sk);

CREATE TABLE reason (
    r_reason_sk smallint NOT NULL,
    r_reason_id char(16) NOT NULL,
    r_reason_desc char(100)
) DISTRIBUTE REPLICATE;

ALTER TABLE reason
    ADD CONSTRAINT reason_pkey PRIMARY KEY (r_reason_sk);

CREATE TABLE ship_mode (
    sm_ship_mode_sk smallint NOT NULL,
    sm_ship_mode_id char(16) NOT NULL,
    sm_type char(30),
    sm_code char(10),
    sm_carrier char(20),
    sm_contract char(20)
) DISTRIBUTE REPLICATE;

ALTER TABLE ship_mode
    ADD CONSTRAINT ship_mode_pkey PRIMARY KEY (sm_ship_mode_sk);

CREATE TABLE store (
    s_store_sk smallint NOT NULL,
    s_store_id char(16) NOT NULL,
    s_rec_start_date date,
    s_rec_end_date date,
    s_closed_date_sk bigint,
    s_store_name varchar(50),
    s_number_employees bigint,
    s_floor_space bigint,
    s_hours char(20),
    s_manager varchar(40),
    s_market_id bigint,
    s_geography_class varchar(100),
    s_market_desc varchar(100),
    s_market_manager varchar(40),
    s_division_id bigint,
    s_division_name varchar(50),
    s_company_id bigint,
    s_company_name varchar(50),
    s_street_number varchar(10),
    s_street_name varchar(60),
    s_street_type char(15),
    s_suite_number char(10),
    s_city varchar(60),
    s_county varchar(30),
    s_state char(2),
    s_zip char(10),
    s_country varchar(20),
    s_gmt_offset numeric(5,2),
    s_tax_precentage numeric(5,2)
) DISTRIBUTE REPLICATE;

ALTER TABLE store
    ADD CONSTRAINT store_pkey PRIMARY KEY (s_store_sk);

CREATE TABLE web_page (
    wp_web_page_sk smallint NOT NULL,
    wp_web_page_id char(16) NOT NULL,
    wp_rec_start_date date,
    wp_rec_end_date date,
    wp_creation_date_sk bigint,
    wp_access_date_sk bigint,
    wp_autogen_flag char(1),
    wp_customer_sk bigint,
    wp_url varchar(100),
    wp_type char(50),
    wp_char_count bigint,
    wp_link_count bigint,
    wp_image_count bigint,
    wp_max_ad_count bigint
) DISTRIBUTE REPLICATE;

ALTER TABLE web_page
    ADD CONSTRAINT web_page_pkey PRIMARY KEY (wp_web_page_sk);

CREATE TABLE web_site (
    web_site_sk smallint NOT NULL,
    web_site_id char(16) NOT NULL,
    web_rec_start_date date,
    web_rec_end_date date,
    web_name varchar(50),
    web_open_date_sk integer,
    web_close_date_sk integer,
    web_class varchar(50),
    web_manager varchar(40),
    web_mkt_id bigint,
    web_mkt_class varchar(50),
    web_mkt_desc varchar(100),
    web_market_manager varchar(40),
    web_company_id bigint,
    web_company_name char(50),
    web_street_number char(10),
    web_street_name varchar(60),
    web_street_type char(15),
    web_suite_number char(10),
    web_city varchar(60),
    web_county varchar(30),
    web_state char(2),
    web_zip char(10),
    web_country varchar(20),
    web_gmt_offset numeric(5,2),
    web_tax_percentage numeric(5,2)
) DISTRIBUTE REPLICATE;

ALTER TABLE web_site
    ADD CONSTRAINT web_site_pkey PRIMARY KEY (web_site_sk);

ALTER TABLE web_site
    ADD CONSTRAINT web_site_web_close_date_sk_fkey FOREIGN KEY (web_close_date_sk) REFERENCES date_dim(d_date_sk);

ALTER TABLE web_site
    ADD CONSTRAINT web_site_web_open_date_sk_fkey FOREIGN KEY (web_open_date_sk) REFERENCES date_dim(d_date_sk);


CREATE TABLE warehouse (
    w_warehouse_sk smallint NOT NULL,
    w_warehouse_id char(16) NOT NULL,
    w_warehouse_name varchar(20),
    w_warehouse_sq_ft bigint,
    w_street_number char(10),
    w_street_name varchar(60),
    w_street_type char(15),
    w_suite_number char(10),
    w_city varchar(60),
    w_county varchar(30),
    w_state char(2),
    w_zip char(10),
    w_country varchar(20),
    w_gmt_offset numeric(5,2)
) DISTRIBUTE REPLICATE;

ALTER TABLE warehouse
    ADD CONSTRAINT warehouse_pkey PRIMARY KEY (w_warehouse_sk);

CREATE TABLE inventory (
    inv_date_sk integer NOT NULL,
    inv_item_sk integer NOT NULL,
    inv_warehouse_sk smallint NOT NULL,
    inv_quantity_on_hand bigint
) DISTRIBUTE ON (inv_item_sk);

ALTER TABLE inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (inv_date_sk, inv_item_sk, inv_warehouse_sk);

ALTER TABLE inventory
    ADD CONSTRAINT inventory_inv_date_sk_fkey FOREIGN KEY (inv_date_sk) REFERENCES date_dim(d_date_sk);

ALTER TABLE inventory
    ADD CONSTRAINT inventory_inv_item_sk_fkey FOREIGN KEY (inv_item_sk) REFERENCES item(i_item_sk);

ALTER TABLE inventory
    ADD CONSTRAINT inventory_inv_warehouse_sk_fkey FOREIGN KEY (inv_warehouse_sk) REFERENCES warehouse(w_warehouse_sk);



CREATE TABLE store_returns (
    sr_returned_date_sk integer,
    sr_return_time_sk integer,
    sr_item_sk integer NOT NULL,
    sr_customer_sk bigint,
    sr_cdemo_sk bigint,
    sr_hdemo_sk bigint,
    sr_addr_sk bigint,
    sr_store_sk smallint,
    sr_reason_sk smallint,
    sr_ticket_number bigint NOT NULL,
    sr_return_quantity bigint,
    sr_return_amt numeric(7,2),
    sr_return_tax numeric(7,2),
    sr_return_amt_inc_tax numeric(7,2),
    sr_fee numeric(7,2),
    sr_return_ship_cost numeric(7,2),
    sr_refunded_cash numeric(7,2),
    sr_reversed_charge numeric(7,2),
    sr_store_credit numeric(7,2),
    sr_net_loss numeric(7,2)
) DISTRIBUTE ON (sr_item_sk);

ALTER TABLE store_returns
    ADD CONSTRAINT store_returns_pkey PRIMARY KEY (sr_item_sk, sr_ticket_number);

ALTER TABLE store_returns
    ADD CONSTRAINT store_returns_sr_cdemo_sk_fkey FOREIGN KEY (sr_cdemo_sk) REFERENCES customer_demographics(cd_demo_sk);

ALTER TABLE store_returns
    ADD CONSTRAINT store_returns_sr_customer_sk_fkey FOREIGN KEY (sr_customer_sk) REFERENCES customer(c_customer_sk);

ALTER TABLE store_returns ADD CONSTRAINT store_returns_sr_hdemo_sk_fkey
    FOREIGN KEY (sr_hdemo_sk) REFERENCES household_demographics(hd_demo_sk);


ALTER TABLE store_returns
    ADD CONSTRAINT store_returns_sr_item_sk_fkey FOREIGN KEY (sr_item_sk) REFERENCES item(i_item_sk);

ALTER TABLE store_returns
    ADD CONSTRAINT store_returns_sr_reason_sk_fkey FOREIGN KEY (sr_reason_sk) REFERENCES reason(r_reason_sk);

ALTER TABLE store_returns
    ADD CONSTRAINT store_returns_sr_return_time_sk_fkey FOREIGN KEY (sr_return_time_sk) REFERENCES time_dim(t_time_sk);

ALTER TABLE store_returns
    ADD CONSTRAINT store_returns_sr_returned_date_sk_fkey FOREIGN KEY (sr_returned_date_sk) REFERENCES date_dim(d_date_sk);

ALTER TABLE store_returns
    ADD CONSTRAINT store_returns_sr_store_sk_fkey FOREIGN KEY (sr_store_sk) REFERENCES store(s_store_sk);


CREATE TABLE store_sales (
    ss_sold_date_sk integer,
    ss_sold_time_sk integer,
    ss_item_sk integer NOT NULL,
    ss_customer_sk bigint,
    ss_cdemo_sk bigint,
    ss_hdemo_sk bigint,
    ss_addr_sk bigint,
    ss_store_sk smallint,
    ss_promo_sk smallint,
    ss_ticket_number bigint NOT NULL,
    ss_quantity bigint,
    ss_wholesale_cost numeric(7,2),
    ss_list_price numeric(7,2),
    ss_sales_price numeric(7,2),
    ss_ext_discount_amt numeric(7,2),
    ss_ext_sales_price numeric(7,2),
    ss_ext_wholesale_cost numeric(7,2),
    ss_ext_list_price numeric(7,2),
    ss_ext_tax numeric(7,2),
    ss_coupon_amt numeric(7,2),
    ss_net_paid numeric(7,2),
    ss_net_paid_inc_tax numeric(7,2),
    ss_net_profit numeric(7,2)
)
DISTRIBUTE ON (ss_customer_sk) SORT ON (ss_sold_date_sk);

ALTER TABLE store_sales
    ADD CONSTRAINT store_sales_pkey PRIMARY KEY (ss_item_sk, ss_ticket_number);

ALTER TABLE store_returns
    ADD CONSTRAINT store_returns_sr_addr_sk_fkey FOREIGN KEY (sr_addr_sk) REFERENCES customer_address(ca_address_sk);

ALTER TABLE store_sales
    ADD CONSTRAINT store_sales_ss_addr_sk_fkey FOREIGN KEY (ss_addr_sk) REFERENCES customer_address(ca_address_sk);

ALTER TABLE store_sales
    ADD CONSTRAINT store_sales_ss_cdemo_sk_fkey FOREIGN KEY (ss_cdemo_sk) REFERENCES customer_demographics(cd_demo_sk);

ALTER TABLE store_sales
    ADD CONSTRAINT store_sales_ss_customer_sk_fkey FOREIGN KEY (ss_customer_sk) REFERENCES customer(c_customer_sk);

ALTER TABLE store_sales ADD CONSTRAINT store_sales_ss_hdemo_sk_fkey
    FOREIGN KEY (ss_hdemo_sk) REFERENCES household_demographics(hd_demo_sk);

ALTER TABLE store_sales
    ADD CONSTRAINT store_sales_ss_item_sk_fkey FOREIGN KEY (ss_item_sk) REFERENCES item(i_item_sk);

ALTER TABLE store_sales
    ADD CONSTRAINT store_sales_ss_promo_sk_fkey FOREIGN KEY (ss_promo_sk) REFERENCES promotion(p_promo_sk);

ALTER TABLE store_sales
    ADD CONSTRAINT store_sales_ss_sold_date_sk_fkey FOREIGN KEY (ss_sold_date_sk) REFERENCES date_dim(d_date_sk);

ALTER TABLE store_sales
    ADD CONSTRAINT store_sales_ss_sold_time_sk_fkey FOREIGN KEY (ss_sold_time_sk) REFERENCES time_dim(t_time_sk);

ALTER TABLE store_sales
    ADD CONSTRAINT store_sales_ss_store_sk_fkey FOREIGN KEY (ss_store_sk) REFERENCES store(s_store_sk);



CREATE TABLE web_returns (
    wr_returned_date_sk integer,
    wr_returned_time_sk integer,
    wr_item_sk integer NOT NULL,
    wr_refunded_customer_sk bigint,
    wr_refunded_cdemo_sk bigint,
    wr_refunded_hdemo_sk bigint,
    wr_refunded_addr_sk bigint,
    wr_returning_customer_sk bigint,
    wr_returning_cdemo_sk bigint,
    wr_returning_hdemo_sk bigint,
    wr_returning_addr_sk bigint,
    wr_web_page_sk smallint,
    wr_reason_sk smallint,
    wr_order_number bigint NOT NULL,
    wr_return_quantity bigint,
    wr_return_amt numeric(7,2),
    wr_return_tax numeric(7,2),
    wr_return_amt_inc_tax numeric(7,2),
    wr_fee numeric(7,2),
    wr_return_ship_cost numeric(7,2),
    wr_refunded_cash numeric(7,2),
    wr_reversed_charge numeric(7,2),
    wr_account_credit numeric(7,2),
    wr_net_loss numeric(7,2)
) DISTRIBUTE ON (wr_order_number);

ALTER TABLE web_returns
    ADD CONSTRAINT web_returns_pkey PRIMARY KEY (wr_item_sk, wr_order_number);

ALTER TABLE web_returns
    ADD CONSTRAINT web_returns_wr_item_sk_fkey FOREIGN KEY (wr_item_sk) REFERENCES item(i_item_sk);

ALTER TABLE web_returns
    ADD CONSTRAINT web_returns_wr_reason_sk_fkey FOREIGN KEY (wr_reason_sk) REFERENCES reason(r_reason_sk);

ALTER TABLE web_returns
    ADD CONSTRAINT web_returns_wr_refunded_addr_sk_fkey FOREIGN KEY (wr_refunded_addr_sk) REFERENCES customer_address(ca_address_sk);

ALTER TABLE web_returns
    ADD CONSTRAINT web_returns_wr_refunded_cdemo_sk_fkey FOREIGN KEY (wr_refunded_cdemo_sk) REFERENCES customer_demographics(cd_demo_sk);

ALTER TABLE web_returns
    ADD CONSTRAINT web_returns_wr_refunded_customer_sk_fkey FOREIGN KEY (wr_refunded_customer_sk) REFERENCES customer(c_customer_sk);

ALTER TABLE web_returns ADD CONSTRAINT web_returns_wr_refunded_hdemo_sk_fkey
    FOREIGN KEY (wr_refunded_hdemo_sk) REFERENCES household_demographics(hd_demo_sk);

ALTER TABLE web_returns
    ADD CONSTRAINT web_returns_wr_returned_date_sk_fkey FOREIGN KEY (wr_returned_date_sk) REFERENCES date_dim(d_date_sk);

ALTER TABLE web_returns
    ADD CONSTRAINT web_returns_wr_returned_time_sk_fkey FOREIGN KEY (wr_returned_time_sk) REFERENCES time_dim(t_time_sk);

ALTER TABLE web_returns
    ADD CONSTRAINT web_returns_wr_returning_addr_sk_fkey FOREIGN KEY (wr_returning_addr_sk) REFERENCES customer_address(ca_address_sk);

ALTER TABLE web_returns
    ADD CONSTRAINT web_returns_wr_returning_cdemo_sk_fkey FOREIGN KEY (wr_returning_cdemo_sk) REFERENCES customer_demographics(cd_demo_sk);

ALTER TABLE web_returns
    ADD CONSTRAINT web_returns_wr_returning_customer_sk_fkey FOREIGN KEY (wr_returning_customer_sk) REFERENCES customer(c_customer_sk);

ALTER TABLE web_returns ADD CONSTRAINT web_returns_wr_returning_hdemo_sk_fkey
    FOREIGN KEY (wr_returning_hdemo_sk) REFERENCES household_demographics(hd_demo_sk);

ALTER TABLE web_returns
    ADD CONSTRAINT web_returns_wr_web_page_sk_fkey FOREIGN KEY (wr_web_page_sk) REFERENCES web_page(wp_web_page_sk);


CREATE TABLE web_sales (
    ws_sold_date_sk integer,
    ws_sold_time_sk integer,
    ws_ship_date_sk integer,
    ws_item_sk integer NOT NULL,
    ws_bill_customer_sk bigint,
    ws_bill_cdemo_sk bigint,
    ws_bill_hdemo_sk bigint,
    ws_bill_addr_sk bigint,
    ws_ship_customer_sk bigint,
    ws_ship_cdemo_sk bigint,
    ws_ship_hdemo_sk bigint,
    ws_ship_addr_sk bigint,
    ws_web_page_sk smallint,
    ws_web_site_sk smallint,
    ws_ship_mode_sk smallint,
    ws_warehouse_sk smallint,
    ws_promo_sk smallint,
    ws_order_number bigint NOT NULL,
    ws_quantity bigint,
    ws_wholesale_cost numeric(7,2),
    ws_list_price numeric(7,2),
    ws_sales_price numeric(7,2),
    ws_ext_discount_amt numeric(7,2),
    ws_ext_sales_price numeric(7,2),
    ws_ext_wholesale_cost numeric(7,2),
    ws_ext_list_price numeric(7,2),
    ws_ext_tax numeric(7,2),
    ws_coupon_amt numeric(7,2),
    ws_ext_ship_cost numeric(7,2),
    ws_net_paid numeric(7,2),
    ws_net_paid_inc_tax numeric(7,2),
    ws_net_paid_inc_ship numeric(7,2),
    ws_net_paid_inc_ship_tax numeric(7,2),
    ws_net_profit numeric(7,2)
)
DISTRIBUTE ON (ws_bill_customer_sk) SORT ON (ws_sold_date_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_pkey PRIMARY KEY (ws_item_sk, ws_order_number);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_bill_addr_sk_fkey FOREIGN KEY (ws_bill_addr_sk) REFERENCES customer_address(ca_address_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_bill_cdemo_sk_fkey FOREIGN KEY (ws_bill_cdemo_sk) REFERENCES customer_demographics(cd_demo_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_bill_customer_sk_fkey FOREIGN KEY (ws_bill_customer_sk) REFERENCES customer(c_customer_sk);

ALTER TABLE web_sales ADD CONSTRAINT web_sales_ws_bill_hdemo_sk_fkey
    FOREIGN KEY (ws_bill_hdemo_sk) REFERENCES household_demographics(hd_demo_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_item_sk_fkey FOREIGN KEY (ws_item_sk) REFERENCES item(i_item_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_promo_sk_fkey FOREIGN KEY (ws_promo_sk) REFERENCES promotion(p_promo_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_ship_addr_sk_fkey FOREIGN KEY (ws_ship_addr_sk) REFERENCES customer_address(ca_address_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_ship_cdemo_sk_fkey FOREIGN KEY (ws_ship_cdemo_sk) REFERENCES customer_demographics(cd_demo_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_ship_customer_sk_fkey FOREIGN KEY (ws_ship_customer_sk) REFERENCES customer(c_customer_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_ship_date_sk_fkey FOREIGN KEY (ws_ship_date_sk) REFERENCES date_dim(d_date_sk);

ALTER TABLE web_sales ADD CONSTRAINT web_sales_ws_ship_hdemo_sk_fkey
    FOREIGN KEY (ws_ship_hdemo_sk) REFERENCES household_demographics(hd_demo_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_ship_mode_sk_fkey FOREIGN KEY (ws_ship_mode_sk) REFERENCES ship_mode(sm_ship_mode_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_sold_date_sk_fkey FOREIGN KEY (ws_sold_date_sk) REFERENCES date_dim(d_date_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_sold_time_sk_fkey FOREIGN KEY (ws_sold_time_sk) REFERENCES time_dim(t_time_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_warehouse_sk_fkey FOREIGN KEY (ws_warehouse_sk) REFERENCES warehouse(w_warehouse_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_web_page_sk_fkey FOREIGN KEY (ws_web_page_sk) REFERENCES web_page(wp_web_page_sk);

ALTER TABLE web_sales
    ADD CONSTRAINT web_sales_ws_web_site_sk_fkey FOREIGN KEY (ws_web_site_sk) REFERENCES web_site(web_site_sk);




CREATE TABLE catalog_returns (
    cr_returned_date_sk integer,
    cr_returned_time_sk integer,
    cr_item_sk integer NOT NULL,
    cr_refunded_customer_sk bigint,
    cr_refunded_cdemo_sk bigint,
    cr_refunded_hdemo_sk bigint,
    cr_refunded_addr_sk bigint,
    cr_returning_customer_sk bigint,
    cr_returning_cdemo_sk bigint,
    cr_returning_hdemo_sk bigint,
    cr_returning_addr_sk bigint,
    cr_call_center_sk smallint,
    cr_catalog_page_sk integer,
    cr_ship_mode_sk smallint,
    cr_warehouse_sk smallint,
    cr_reason_sk smallint,
    cr_order_number bigint NOT NULL,
    cr_return_quantity bigint,
    cr_return_amount numeric(7,2),
    cr_return_tax numeric(7,2),
    cr_return_amt_inc_tax numeric(7,2),
    cr_fee numeric(7,2),
    cr_return_ship_cost numeric(7,2),
    cr_refunded_cash numeric(7,2),
    cr_reversed_charge numeric(7,2),
    cr_store_credit numeric(7,2),
    cr_net_loss numeric(7,2)
) DISTRIBUTE ON (cr_returned_date_sk);

ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_pkey PRIMARY KEY (cr_item_sk, cr_order_number);

ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_call_center_sk_fkey FOREIGN KEY (cr_call_center_sk) REFERENCES call_center(cc_call_center_sk);


ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_catalog_page_sk_fkey FOREIGN KEY (cr_catalog_page_sk) REFERENCES catalog_page(cp_catalog_page_sk);


ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_item_sk_fkey FOREIGN KEY (cr_item_sk) REFERENCES item(i_item_sk);


ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_reason_sk_fkey FOREIGN KEY (cr_reason_sk) REFERENCES reason(r_reason_sk);


ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_refunded_addr_sk_fkey FOREIGN KEY (cr_refunded_addr_sk) REFERENCES customer_address(ca_address_sk);


ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_refunded_cdemo_sk_fkey FOREIGN KEY (cr_refunded_cdemo_sk) REFERENCES customer_demographics(cd_demo_sk);


ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_refunded_customer_sk_fkey FOREIGN KEY (cr_refunded_customer_sk) REFERENCES customer(c_customer_sk);


ALTER TABLE catalog_returns ADD CONSTRAINT catalog_returns_cr_refunded_hdemo_sk_fkey
    FOREIGN KEY (cr_refunded_hdemo_sk) REFERENCES household_demographics(hd_demo_sk);


ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_returned_date_sk_fkey FOREIGN KEY (cr_returned_date_sk) REFERENCES date_dim(d_date_sk);


ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_returned_time_sk_fkey FOREIGN KEY (cr_returned_time_sk) REFERENCES time_dim(t_time_sk);


ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_returning_addr_sk_fkey FOREIGN KEY (cr_returning_addr_sk) REFERENCES customer_address(ca_address_sk);


ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_returning_cdemo_sk_fkey FOREIGN KEY (cr_returning_cdemo_sk) REFERENCES customer_demographics(cd_demo_sk);


ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_returning_customer_sk_fkey FOREIGN KEY (cr_returning_customer_sk) REFERENCES customer(c_customer_sk);


ALTER TABLE catalog_returns ADD CONSTRAINT catalog_returns_cr_returning_hdemo_sk_fkey
    FOREIGN KEY (cr_returning_hdemo_sk) REFERENCES household_demographics(hd_demo_sk);


ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_ship_mode_sk_fkey FOREIGN KEY (cr_ship_mode_sk) REFERENCES ship_mode(sm_ship_mode_sk);


ALTER TABLE catalog_returns
    ADD CONSTRAINT catalog_returns_cr_warehouse_sk_fkey FOREIGN KEY (cr_warehouse_sk) REFERENCES warehouse(w_warehouse_sk);


CREATE TABLE catalog_sales (
    cs_sold_date_sk integer,
    cs_sold_time_sk integer,
    cs_ship_date_sk integer,
    cs_bill_customer_sk bigint,
    cs_bill_cdemo_sk bigint,
    cs_bill_hdemo_sk bigint,
    cs_bill_addr_sk bigint,
    cs_ship_customer_sk bigint,
    cs_ship_cdemo_sk bigint,
    cs_ship_hdemo_sk bigint,
    cs_ship_addr_sk bigint,
    cs_call_center_sk smallint,
    cs_catalog_page_sk integer,
    cs_ship_mode_sk smallint,
    cs_warehouse_sk smallint,
    cs_item_sk integer NOT NULL,
    cs_promo_sk smallint,
    cs_order_number bigint NOT NULL,
    cs_quantity bigint,
    cs_wholesale_cost numeric(7,2),
    cs_list_price numeric(7,2),
    cs_sales_price numeric(7,2),
    cs_ext_discount_amt numeric(7,2),
    cs_ext_sales_price numeric(7,2),
    cs_ext_wholesale_cost numeric(7,2),
    cs_ext_list_price numeric(7,2),
    cs_ext_tax numeric(7,2),
    cs_coupon_amt numeric(7,2),
    cs_ext_ship_cost numeric(7,2),
    cs_net_paid numeric(7,2),
    cs_net_paid_inc_tax numeric(7,2),
    cs_net_paid_inc_ship numeric(7,2),
    cs_net_paid_inc_ship_tax numeric(7,2),
    cs_net_profit numeric(7,2)
)
DISTRIBUTE ON (cs_bill_customer_sk) SORT ON (cs_sold_date_sk);

ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_pkey PRIMARY KEY (cs_item_sk, cs_order_number);

ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_bill_addr_sk_fkey FOREIGN KEY (cs_bill_addr_sk) REFERENCES customer_address(ca_address_sk);


ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_bill_cdemo_sk_fkey FOREIGN KEY (cs_bill_cdemo_sk) REFERENCES customer_demographics(cd_demo_sk);


ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_bill_customer_sk_fkey FOREIGN KEY (cs_bill_customer_sk) REFERENCES customer(c_customer_sk);


ALTER TABLE catalog_sales ADD CONSTRAINT catalog_sales_cs_bill_hdemo_sk_fkey
    FOREIGN KEY (cs_bill_hdemo_sk) REFERENCES household_demographics(hd_demo_sk);


ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_call_center_sk_fkey FOREIGN KEY (cs_call_center_sk) REFERENCES call_center(cc_call_center_sk);


ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_catalog_page_sk_fkey FOREIGN KEY (cs_catalog_page_sk) REFERENCES catalog_page(cp_catalog_page_sk);


ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_item_sk_fkey FOREIGN KEY (cs_item_sk) REFERENCES item(i_item_sk);


ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_promo_sk_fkey FOREIGN KEY (cs_promo_sk) REFERENCES promotion(p_promo_sk);


ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_ship_addr_sk_fkey FOREIGN KEY (cs_ship_addr_sk) REFERENCES customer_address(ca_address_sk);


ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_ship_cdemo_sk_fkey FOREIGN KEY (cs_ship_cdemo_sk) REFERENCES customer_demographics(cd_demo_sk);


ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_ship_customer_sk_fkey FOREIGN KEY (cs_ship_customer_sk) REFERENCES customer(c_customer_sk);


ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_ship_date_sk_fkey FOREIGN KEY (cs_ship_date_sk) REFERENCES date_dim(d_date_sk);


ALTER TABLE catalog_sales ADD CONSTRAINT catalog_sales_cs_ship_hdemo_sk_fkey
    FOREIGN KEY (cs_ship_hdemo_sk) REFERENCES household_demographics(hd_demo_sk);

ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_ship_mode_sk_fkey FOREIGN KEY (cs_ship_mode_sk) REFERENCES ship_mode(sm_ship_mode_sk);


ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_sold_date_sk_fkey FOREIGN KEY (cs_sold_date_sk) REFERENCES date_dim(d_date_sk);


ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_sold_time_sk_fkey FOREIGN KEY (cs_sold_time_sk) REFERENCES time_dim(t_time_sk);


ALTER TABLE catalog_sales
    ADD CONSTRAINT catalog_sales_cs_warehouse_sk_fkey FOREIGN KEY (cs_warehouse_sk) REFERENCES warehouse(w_warehouse_sk);





