# Getting Started with Cortex Code in Snowsight Workspaces

A hands-on quickstart that walks you through using **Cortex Code (CoCo)** as your AI pair-programmer inside a **Git-synced Snowflake Workspace**. By the end, you'll have built a small analytics pipeline entirely through natural language prompts — and pushed it all back to your Git repo.

---

## Prerequisites

| Requirement | Details |
|---|---|
| Snowflake account | Commercial (non-Gov/VPS) with [Cross-region inference](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-cross-region-inference) enabled |
| Roles & privileges | `SNOWFLAKE.COPILOT_USER` + `SNOWFLAKE.CORTEX_USER` (or `CORTEX_AGENT_USER`) database roles granted to your role |
| Git repository | A GitHub (or GitLab/Bitbucket) repo with **at least one commit** on a branch |
| API integration | A `git_https_api` API integration configured for your Git provider (OAuth2 recommended for GitHub) |
| Warehouse | A warehouse your role can use (e.g., `APP_WH`) |

> **Tip:** If your repo is empty, add a README via the GitHub UI first — Snowflake cannot connect to repos with zero branches.

---

## Architecture & Workflow

```
┌─────────────────────────────────────────────────────┐
│              Git Repository (GitHub/GitLab)          │
│                  main branch                         │
└──────────┬──────────────────────▲────────────────────┘
           │ clone/pull           │ push + PR merge
           ▼                     │
┌─────────────────────────────────────────────────────┐
│         Snowflake Workspace (Git-synced)             │
│                                                      │
│  ┌────────────┐    ┌──────────────────────────────┐  │
│  │ SQL files  │◄──►│    Cortex Code (CoCo)        │  │
│  │ Notebooks  │    │  - Generate / Edit code       │  │
│  │ .py files  │    │  - Diff view & review         │  │
│  └────────────┘    │  - Run SQL / dbt              │  │
│                    └──────────────────────────────┘  │
│                                                      │
│  Changes tab: track diffs, commit, push, pull        │
└─────────────────────────────────────────────────────┘
```

**Key principle:** Git is the source of truth. Workspaces is the development surface. Cortex Code is the AI pair-programmer inside it.

---

## Step 0 — Create a Git-Synced Workspace

1. In Snowsight, go to **Projects → Workspaces → From Git repository**
2. Paste your repository URL
3. Select your API integration and authenticate
4. Create a **feature branch** (e.g., `feature/quickstart-demo`) from the **Changes** tab

> You are now developing in a Workspace that syncs bidirectionally with your Git repo.

---

## Step 1 — Set Up Source Data

Open `01_setup_source_data.sql` and run it. This is the only pre-built file — it creates `QUICKSTART_DB` with two tables (`CUSTOMERS` and `ORDERS`) and populates them with synthetic data.

After running, verify you see 500 customers and 2,000 orders.

### Git Checkpoint
Go to the **Changes** tab — you'll see `01_setup_source_data.sql` tracked. Commit with message: `Seed source data` and **Push**.

---

## Step 2 — Explore Your Data

Create a **new SQL file** in the workspace (click **+** → SQL Worksheet). Name it `02_explore_data.sql`.

Open the Cortex Code panel (bottom-right icon) and try these prompts one at a time. After each, **review the diff**, accept it, and run the SQL:

> **Prompt 1 — Data profiling:**
> ```
> Write queries to profile the QUICKSTART_DB.RAW.CUSTOMERS and
> QUICKSTART_DB.RAW.ORDERS tables. Show row counts, null counts per
> column, and distinct value counts for key columns.
> ```

> **Prompt 2 — Business questions:**
> ```
> Write a query showing the top 10 customers by total order amount,
> including their region and number of orders.
> ```

> **Prompt 3 — Time series:**
> ```
> Write a query showing monthly revenue trends with a 3-month
> moving average.
> ```

### Git Checkpoint
Go to the **Changes** tab. You'll see `02_explore_data.sql` marked with **A** (added). Review the diff, commit: `Add data exploration queries`, and **Push**.

---

## Step 3 — Build a Transformation Pipeline

Create another new SQL file: `03_build_pipeline.sql`.

> **Prompt 1 — Staging layer:**
> ```
> Create a view called QUICKSTART_DB.ANALYTICS.STG_ORDERS that joins
> ORDERS with CUSTOMERS, adds the customer name and region, and filters
> out cancelled orders.
> ```

> **Prompt 2 — Aggregate model:**
> ```
> Create a table called QUICKSTART_DB.ANALYTICS.CUSTOMER_SUMMARY that
> contains one row per customer with: total_orders, total_revenue,
> avg_order_value, first_order_date, last_order_date, and
> days_since_last_order.
> ```

> **Prompt 3 — Optimize:**
> ```
> Review the SQL in this file. Suggest any performance optimizations
> or best practice improvements.
> ```

CoCo will show suggested edits in a diff view — review before accepting.

### Git Checkpoint
Commit and push: `Add staging views and customer summary table`

---

## Step 4 — Create a Semantic View

Create a new SQL file: `04_create_semantic_view.sql`.

> **Prompt:**
> ```
> Create a Cortex Analyst semantic view called
> QUICKSTART_DB.ANALYTICS.CUSTOMER_ANALYTICS_SV over the
> QUICKSTART_DB.ANALYTICS.CUSTOMER_SUMMARY table. Include meaningful
> descriptions for all columns and define common metrics like
> total_revenue and avg_order_value.
> ```

After creating the semantic view, test it:

> **Prompt:**
> ```
> Use the QUICKSTART_DB.ANALYTICS.CUSTOMER_ANALYTICS_SV semantic view
> to answer: "Which region has the highest average order value?"
> ```

### Git Checkpoint
Commit and push: `Add semantic view for customer analytics`

---

## Step 5 — Build a Streamlit Dashboard

> **Prompt:**
> ```
> Build a Streamlit in Snowflake app that visualizes data from
> QUICKSTART_DB.ANALYTICS.CUSTOMER_SUMMARY. Include:
> - A bar chart of revenue by region
> - A line chart of monthly order trends
> - A filter for region
> Deploy it to Snowflake.
> ```

### Git Checkpoint
Commit and push any generated files: `Add Streamlit dashboard`

---

## Step 6 — Explore Enhanced CoCo Capabilities

Open `02_enhanced_capabilities.sql`. This file contains pre-built SQL to demo advanced CoCo features:

### Fix Errors
Run the first query — it has intentional errors (typo + wrong function). Click the **Fix** button in the results grid and watch CoCo diagnose and fix it.

### Explain Code
Highlight the second query, right-click, and select **Explain** to get a plain-English walkthrough.

### Quick Edit
Highlight the second query and select **Quick Edit**, then try:
> ```
> Add a WHERE clause to filter for only the last 90 days
> ```

### Follow-Up Questions
After CoCo generates a result, ask follow-ups in the chat panel:
> ```
> Can you add a percent-of-total column to these results?
> ```
> ```
> Convert this into a CTE-based approach
> ```

---

## Recommended Git Workflow Summary

| Step | Where | Action |
|---|---|---|
| 1. Create feature branch | Workspaces → Changes tab | Branch off `main` |
| 2. Develop | Workspaces + CoCo | Generate, edit, run, iterate |
| 3. Review diffs | Workspaces → Changes tab | Verify all changes |
| 4. Commit & Push | Workspaces → Changes tab | Push to remote branch |
| 5. Open PR | GitHub/GitLab | Code review + CI checks |
| 6. Merge | GitHub/GitLab | Merge to `main` |
| 7. Pull | Workspaces → Changes tab | Get latest `main` |

> **Production best practice:** Never develop directly on `main`. Always use feature branches, push from Workspaces, and merge via Pull Request with code review.

---

## Files in This Repo

| File | Purpose |
|---|---|
| `README.md` | This quickstart guide |
| `AGENTS.md` | Custom CoCo instructions for this project |
| `01_setup_source_data.sql` | Seed data DDL and inserts (only pre-built SQL) |
| `02_enhanced_capabilities.sql` | Advanced CoCo feature demos (intentional errors for Fix demo) |

> All other SQL files (`02_explore_data.sql`, `03_build_pipeline.sql`, etc.) are created by **you** during the quickstart using CoCo prompts. That's the point!

---

## Learn More

- [Cortex Code in Snowsight](https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-snowsight)
- [Integrate Workspaces with Git](https://docs.snowflake.com/en/user-guide/ui-snowsight/workspaces-git)
- [Setting up Snowflake to use Git](https://docs.snowflake.com/en/developer-guide/git/git-setting-up)
- [Cortex Analyst Semantic Views](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
