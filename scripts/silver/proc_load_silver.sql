/*
===================================================
Stored Procedure: Silver Layer Data Loading
===================================================

Script Purpose:
    This stored procedure performes the ETL (Extract, Tranform, Load) process
    to populate the 'silver' schema tables from the 'bronze' schema.

Actions Performed:
    - Truncate Silver Tables.
    - Insert transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or 
    return any values.

Usage Example:
    CALL silver.load_silver();

===================================================
*/

create or replace procedure silver.load_silver()
language plpgsql
as $$
declare
    start_time timestamp;
    end_time timestamp;
    batch_start_time timestamp;
    batch_end_time timestamp;

begin

    start_time := clock_timestamp();

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '==========================================';
    
    RAISE NOTICE '------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------';


    -- ========================================================
    -- 1. LOAD CRM CUSTOMER INFORMATION
    -- ========================================================

    batch_start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';
    truncate table silver.crm_cust_info;

    RAISE NOTICE '>> Inserting Data Into: silver.crm_cust_info';

    insert into silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    select
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),

        case
            when UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
            when UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
            else 'n/a'
        end,

        case
            when UPPER(TRIM(cst_gndr)) = 'F' then 'Female'
            when UPPER(TRIM(cst_gndr)) = 'M' then 'Male'
            else 'n/a'
        end,

        cst_create_date

    from (
        select
            *,
            ROW_NUMBER() over (
                partition by cst_id
                order by cst_create_date desc
            ) as flag_last
        from bronze.crm_cust_info
        where cst_id is not null
    ) as t

    where flag_last = 1;

    batch_end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));


    -- ========================================================
    -- 2. LOAD CRM SALES DETAILS
    -- ========================================================

    batch_start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';
    truncate table silver.crm_sales_details;

    RAISE NOTICE '>> Inserting Data Into: silver.crm_sales_details';

    insert into silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    select
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        case
            when sls_order_dt = 0
                 or LENGTH(sls_order_dt::TEXT) != 8
            then null
            else TO_DATE(sls_order_dt::TEXT, 'YYYYMMDD')
        end,

        case
            when sls_ship_dt = 0
                 or LENGTH(sls_ship_dt::TEXT) != 8
            then null
            else TO_DATE(sls_ship_dt::TEXT, 'YYYYMMDD')
        end,

        case
            when sls_due_dt = 0
                 or LENGTH(sls_due_dt::TEXT) != 8
            then null
            else TO_DATE(sls_due_dt::TEXT, 'YYYYMMDD')
        end,

        case
            when sls_sales is null
                 or sls_sales <= 0
                 or sls_sales != sls_quantity * ABS(sls_price)
            then sls_quantity * ABS(sls_price)
            else sls_sales
        end,

        sls_quantity,

        case
            when sls_price is null
                 or sls_price <= 0
            then sls_sales / NULLIF(sls_quantity, 0)
            else sls_price
        end

    from bronze.crm_sales_details;

    batch_end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));


    -- ========================================================
    -- 3. LOAD CRM PRODUCT INFORMATION
    -- ========================================================

    batch_start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.crm_prd_info';
    truncate table silver.crm_prd_info;

    RAISE NOTICE '>> Inserting Data Into: silver.crm_prd_info';

    insert into silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    select
        prd_id,

        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),

        SUBSTRING(prd_key from 7),

        prd_nm,

        COALESCE(prd_cost, 0),

        case UPPER(TRIM(prd_line))
            when 'M' then 'Mountain'
            when 'R' then 'Road'
            when 'S' then 'Other Sales'
            when 'T' then 'Touring'
            else 'n/a'
        end,

        CAST(prd_start_dt as date),

        CAST(
            LEAD(CAST(prd_start_dt as date)) over (
                partition by prd_key
                order by prd_start_dt
            ) - 1 as date
        )

    from bronze.crm_prd_info;

    batch_end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));
        
        
    RAISE NOTICE '------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------';


    -- ========================================================
    -- 4. LOAD ERP CUSTOMER INFORMATION
    -- ========================================================

    batch_start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';
    truncate table silver.erp_cust_az12;

    RAISE NOTICE '>> Inserting Data Into: silver.erp_cust_az12';

    insert into silver.erp_cust_az12 (
        cid,
        bdate,
        gen
    )
    select
        case
            when cid like 'NAS%'
            then SUBSTRING(cid, 4, LENGTH(cid))
            else cid
        end,

        case
            when bdate > CURRENT_DATE then null
            else bdate
        end,

        case
            when UPPER(TRIM(gen)) in ('F', 'FEMALE') then 'Female'
            when UPPER(TRIM(gen)) in ('M', 'MALE') then 'Male'
            else 'n/a'
        end

    from bronze.erp_cust_az12;

    batch_end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));


    -- ========================================================
    -- 5. LOAD ERP LOCATION INFORMATION
    -- ========================================================

    batch_start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';
    truncate table silver.erp_loc_a101;

    RAISE NOTICE '>> Inserting Data Into: silver.erp_loc_a101';

    insert into silver.erp_loc_a101 (
        cid,
        cntry
    )
    select
        REPLACE(cid, '-', ''),

        case
            when TRIM(cntry) = 'DE' then 'Germany'
            when TRIM(cntry) in ('US', 'USA') then 'United States'
            when TRIM(cntry) = '' or cntry is null then 'n/a'
            else TRIM(cntry)
        end

    from bronze.erp_loc_a101;

    batch_end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));


    -- ========================================================
    -- 6. LOAD ERP PRODUCT CATEGORY INFORMATION
    -- ========================================================

    batch_start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.erp_px_cat_g1v2';
    truncate table silver.erp_px_cat_g1v2;

    RAISE NOTICE '>> Inserting Data Into: silver.erp_px_cat_g1v2';

    insert into silver.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )
    select
        id,
        cat,
        subcat,
        maintenance

    from bronze.erp_px_cat_g1v2;

    batch_end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));


    -- ========================================================
    -- SILVER LAYER LOAD COMPLETED
    -- ========================================================

    end_time := clock_timestamp();

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Silver Layer Load Completed Successfully';
    RAISE NOTICE 'Total Load Duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE '==========================================';


-- ============================================================
-- ERROR HANDLING
-- ============================================================

exception
    when others then

        RAISE NOTICE '==========================================';
        RAISE NOTICE 'ERROR OCCURRED DURING SILVER LAYER LOAD';
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE 'Error Code: %', SQLSTATE;
        RAISE NOTICE '==========================================';

        raise;

end;
$$;
