----------------------------------------------------------------------
-- 01_setup_source_data.sql
-- Sets up the QUICKSTART_DB database, RAW schema, and seed tables
-- Run this file first to create the demo environment
----------------------------------------------------------------------

USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE APP_WH;

CREATE DATABASE IF NOT EXISTS QUICKSTART_DB;
CREATE SCHEMA IF NOT EXISTS QUICKSTART_DB.RAW;
CREATE SCHEMA IF NOT EXISTS QUICKSTART_DB.ANALYTICS;

----------------------------------------------------------------------
-- CUSTOMERS table
----------------------------------------------------------------------
CREATE OR REPLACE TABLE QUICKSTART_DB.RAW.CUSTOMERS (
    customer_id     INT,
    name            VARCHAR(100),
    email           VARCHAR(200),
    region          VARCHAR(50),
    signup_date     DATE
);

INSERT INTO QUICKSTART_DB.RAW.CUSTOMERS
SELECT
    SEQ4()                                                          AS customer_id,
    'Customer_' || SEQ4()::VARCHAR                                  AS name,
    'customer' || SEQ4()::VARCHAR || '@example.com'                 AS email,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'North America'
        WHEN 1 THEN 'Europe'
        WHEN 2 THEN 'Asia Pacific'
        WHEN 3 THEN 'Latin America'
    END                                                             AS region,
    DATEADD('day', -1 * UNIFORM(30, 730, RANDOM()), CURRENT_DATE()) AS signup_date
FROM TABLE(GENERATOR(ROWCOUNT => 500));

----------------------------------------------------------------------
-- ORDERS table
----------------------------------------------------------------------
CREATE OR REPLACE TABLE QUICKSTART_DB.RAW.ORDERS (
    order_id        INT,
    customer_id     INT,
    order_date      DATE,
    amount          DECIMAL(10,2),
    status          VARCHAR(20)
);

INSERT INTO QUICKSTART_DB.RAW.ORDERS
SELECT
    SEQ4()                                                           AS order_id,
    UNIFORM(0, 499, RANDOM())                                        AS customer_id,
    DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_DATE())   AS order_date,
    ROUND(UNIFORM(5.00, 500.00, RANDOM())::DECIMAL(10,2), 2)         AS amount,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'completed'
        WHEN 1 THEN 'completed'
        WHEN 2 THEN 'completed'
        WHEN 3 THEN 'pending'
        WHEN 4 THEN 'cancelled'
    END                                                              AS status
FROM TABLE(GENERATOR(ROWCOUNT => 2000));

----------------------------------------------------------------------
-- Quick verification
----------------------------------------------------------------------
SELECT 'CUSTOMERS' AS table_name, COUNT(*) AS row_count FROM QUICKSTART_DB.RAW.CUSTOMERS
UNION ALL
SELECT 'ORDERS',                  COUNT(*)              FROM QUICKSTART_DB.RAW.ORDERS;
