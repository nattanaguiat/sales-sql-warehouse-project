/*
===================================================
DDL Script: Create Silver Tables
===================================================
Script Purpose:
    This script creates the tables in the 'silver' schema, dropping existing
    tables if they already exist.
    Run this script to re-define the DDL structure of 'bronze' Tables
*/

DROP TABLE IF EXISTS silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info (
    cst_id INTEGER,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(10),
    cst_gndr VARCHAR(10),
    cst_create_date DATE,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
    prd_id INTEGER,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(255),
    prd_cost NUMERIC(10,2),
    prd_line VARCHAR(10),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
    sls_ord_num VARCHAR(20),
    sls_prd_key VARCHAR(50),
    sls_cust_id INTEGER,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INTEGER,
    sls_quantity INTEGER,
    sls_price INTEGER,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
    cid VARCHAR(20),
    bdate DATE,
    gen VARCHAR(10),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101 (
    cid VARCHAR(20),
    cntry VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2 (
    id VARCHAR(10),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(5),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
