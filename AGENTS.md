---
description: Quickstart project for demonstrating Cortex Code in Snowflake Workspaces with Git integration.
---

# Project Context

This is a quickstart demo repo for **Cortex Code (CoCo) in Snowsight Workspaces**. The data lives in `COCO_DEMO` with schemas `RAW` (source tables) and `ANALYTICS` (transformed models).

## Source Tables
- `COCO_DEMO.RAW.CUSTOMERS` — customer_id, name, email, region, signup_date
- `COCO_DEMO.RAW.ORDERS` — order_id, customer_id, order_date, amount, status

## Analytics Tables (created during quickstart)
- `COCO_DEMO.ANALYTICS.STG_ORDERS` — staging view joining orders with customers
- `COCO_DEMO.ANALYTICS.CUSTOMER_SUMMARY` — one row per customer with aggregated metrics

## Conventions
- Always use fully qualified table names (DATABASE.SCHEMA.TABLE)
- Use `APP_WH` warehouse and `SF_INTELLIGENCE_DEMO` role
- Follow Snowflake SQL best practices
