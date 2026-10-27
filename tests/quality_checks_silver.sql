/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Script Purpose:
    This script performs quality checks for data consistency, accuracy,
    and standardization across the Silver Layer of the Data Warehouse.

    It includes checks for:
    - Null or duplicate identifiers.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and date orders.
    - Negative or missing numeric values.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after executing silver.load_silver().
    - Queries with "Expectation: No Results" should return zero rows.
    - Investigate and resolve any discrepancies found.
===============================================================================
*/


-- ====================================================================
-- 1. Checking 'silver.crm_cust_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Customer ID
-- Expectation: No Results

select
    cst_id,
    COUNT(*)
from silver.crm_cust_info
group by cst_id
having COUNT(*) > 1 or cst_id is null;


-- Check for Unwanted Spaces
-- Expectation: No Results

select
    *
from silver.crm_cust_info
where cst_key != TRIM(cst_key)
   or cst_firstname != TRIM(cst_firstname)
   or cst_lastname != TRIM(cst_lastname);


-- Data Standardization & Consistency
-- Expectation: Single, Married, n/a

select distinct
    cst_marital_status
from silver.crm_cust_info;


-- Data Standardization & Consistency
-- Expectation: Female, Male, n/a

select distinct
    cst_gndr
from silver.crm_cust_info;



-- ====================================================================
-- 2. Checking 'silver.crm_prd_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Product ID
-- Expectation: No Results

select
    prd_id,
    COUNT(*)
from silver.crm_prd_info
group by prd_id
having COUNT(*) > 1 or prd_id is null;


-- Check for Unwanted Spaces
-- Expectation: No Results

select
    *
from silver.crm_prd_info
where prd_nm != TRIM(prd_nm)
   or prd_key != TRIM(prd_key);


-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results

select
    prd_id,
    prd_cost
from silver.crm_prd_info
where prd_cost < 0
   or prd_cost is null;


-- Data Standardization & Consistency
-- Expectation: Mountain, Road, Other Sales, Touring, n/a

select distinct
    prd_line
from silver.crm_prd_info;


-- Check for Invalid Date Orders
-- Expectation: No Results

select
    *
from silver.crm_prd_info
where prd_end_dt < prd_start_dt;



-- ====================================================================
-- 3. Checking 'silver.crm_sales_details'
-- ====================================================================

-- Check for Invalid Dates in Bronze
-- Note: Silver stores these columns as DATE.
-- Expectation: Investigate any returned rows.

select
    sls_due_dt
from bronze.crm_sales_details
where sls_due_dt is not null
  and (
      sls_due_dt <= 0
      or LENGTH(sls_due_dt::TEXT) != 8
      or sls_due_dt > 20500101
      or sls_due_dt < 19000101
  );


-- Check for Invalid Date Orders
-- Expectation: No Results

select
    *
from silver.crm_sales_details
where sls_order_dt > sls_ship_dt
   or sls_order_dt > sls_due_dt;


-- Check for NULLs in Important Identifiers
-- Expectation: No Results

select
    *
from silver.crm_sales_details
where sls_ord_num is null
   or sls_prd_key is null
   or sls_cust_id is null;


-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results

select distinct
    sls_sales,
    sls_quantity,
    sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
   or sls_sales is null
   or sls_quantity is null
   or sls_price is null
   or sls_sales <= 0
   or sls_quantity <= 0
   or sls_price <= 0
order by sls_sales, sls_quantity, sls_price;



-- ====================================================================
-- 4. Checking 'silver.erp_cust_az12'
-- ====================================================================

-- Identify Out-of-Range Birthdates
-- Expectation: Birthdates between 1924-01-01 and Today

select distinct
    bdate
from silver.erp_cust_az12
where bdate < DATE '1924-01-01'
   or bdate > CURRENT_DATE;


-- Check for NULL Customer Identifiers
-- Expectation: No Results

select
    *
from silver.erp_cust_az12
where cid is null;


-- Data Standardization & Consistency
-- Expectation: Female, Male, n/a

select distinct
    gen
from silver.erp_cust_az12;



-- ====================================================================
-- 5. Checking 'silver.erp_loc_a101'
-- ====================================================================

-- Check for NULL Customer Identifiers
-- Expectation: No Results

select
    *
from silver.erp_loc_a101
where cid is null;


-- Check for Unwanted Spaces
-- Expectation: No Results

select
    *
from silver.erp_loc_a101
where cid != TRIM(cid)
   or cntry != TRIM(cntry);


-- Data Standardization & Consistency
-- Expectation: Standardized Country Names

select distinct
    cntry
from silver.erp_loc_a101
order by cntry;



-- ====================================================================
-- 6. Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- Check for NULLs or Duplicates in Category ID
-- Expectation: No Results

select
    id,
    COUNT(*)
from silver.erp_px_cat_g1v2
group by id
having COUNT(*) > 1 or id is null;


-- Check for Unwanted Spaces
-- Expectation: No Results

select
    *
from silver.erp_px_cat_g1v2
where cat != TRIM(cat)
   or subcat != TRIM(subcat)
   or maintenance != TRIM(maintenance);


-- Data Standardization & Consistency

select distinct
    maintenance
from silver.erp_px_cat_g1v2;


-- Check for NULL Values in Product Categories
-- Expectation: No Results

select
    *
from silver.erp_px_cat_g1v2
where id is null
   or cat is null
   or subcat is null;
