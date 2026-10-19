
/*
========================================================
Sales Data Warehouse & Analytics
Database Initialization Script
========================================================

Purpose:
    Initialize the Bronze, Silver, and Gold schemas
    for the Sales Data Warehouse project.

Database:
    sales_dw

Environment:
    PostgreSQL 17 | Docker | DBeaver

Prerequisites:
    - PostgreSQL Docker container must be running.
    - Database sales_dw must already exist.
    - Connect to sales_dw before executing this script.

Architecture:
    Bronze - Raw data ingestion
    Silver - Data cleaning and transformation
    Gold   - Business-ready analytical data

========================================================
*/

-- Verify current database
SELECT current_database();

-- Create Bronze Schema
CREATE SCHEMA IF NOT EXISTS bronze;

-- Create Silver Schema
CREATE SCHEMA IF NOT EXISTS silver;

-- Create Gold Schema
CREATE SCHEMA IF NOT EXISTS gold;
