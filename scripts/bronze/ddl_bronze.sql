/*
========================================================
Sales Data Warehouse & Analytics
Bronze Layer - DDL Script
========================================================

Purpose:
    Drop and recreate the six Bronze tables
    used to store raw CRM and ERP data.

Database:
    sales_dw

Environment:
    PostgreSQL 17 | Docker | DBeaver

Prerequisites:
    - PostgreSQL container must be running.
    - Database sales_dw must already exist.
    - Connect to sales_dw before execution.

WARNING:
    Running this script will delete all existing
    data in the six Bronze tables.

========================================================
*/


-- =====================================================
-- CRM: Customer Information
-- Source: cust_info.csv
-- =====================================================

DROP TABLE IF EXISTS bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
    cst_id INTEGER,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(10),
    cst_gndr VARCHAR(10),
    cst_create_date DATE
);


-- =====================================================
-- CRM: Product Information
-- Source: prd_info.csv
-- =====================================================

DROP TABLE IF EXISTS bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
    prd_id INTEGER,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(255),
    prd_cost NUMERIC(10,2),
    prd_line VARCHAR(10),
    prd_start_dt DATE,
    prd_end_dt DATE
);


-- =====================================================
-- CRM: Sales Details
-- Source: sales_details.csv
-- =====================================================

DROP TABLE IF EXISTS bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num VARCHAR(20),
    sls_prd_key VARCHAR(50),
    sls_cust_id INTEGER,
    sls_order_dt INTEGER,
    sls_ship_dt INTEGER,
    sls_due_dt INTEGER,
    sls_sales NUMERIC(12,2),
    sls_quantity INTEGER,
    sls_price NUMERIC(12,2)
);


-- =====================================================
-- ERP: Customer Additional Information
-- Source: CUST_AZ12.csv
-- =====================================================

DROP TABLE IF EXISTS bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
    cid VARCHAR(20),
    bdate DATE,
    gen VARCHAR(10)
);


-- =====================================================
-- ERP: Customer Location
-- Source: LOC_A101.csv
-- =====================================================

DROP TABLE IF EXISTS bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
    cid VARCHAR(20),
    cntry VARCHAR(50)
);


-- =====================================================
-- ERP: Product Categories
-- Source: PX_CAT_G1V2.csv
-- =====================================================

DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id VARCHAR(10),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(5)
);
