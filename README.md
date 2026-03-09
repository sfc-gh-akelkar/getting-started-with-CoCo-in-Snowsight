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

Open the file `01_setup_source_data.sql` in your workspace.

### Run the SQL directly
This file contains the DDL and sample data to create a demo `ORDERS` and `CUSTOMERS` table. Execute it in the worksheet to seed your environment.

### Or, ask CoCo to help

Open the Cortex Code panel (icon in the bottom-right) and try:

> **Prompt:**
> ```
> Create a database called QUICKSTART_DB with a schema called RAW.
> Then create two tables:
> - CUSTOMERS (customer_id, name, email, region, signup_date)
> - ORDERS (order_id, customer_id, order_date, amount, status)
> Populate each with 500 rows of realistic synthetic data.
> ```

CoCo will generate the SQL, show you a diff, and you can review + apply it.

---

## Step 2 — Explore Your Data

Open `02_explore_data.sql`. This file starts empty — you'll fill it using CoCo.

### Suggested CoCo Prompts

Try these prompts one at a time. After each, **review the diff**, apply it, and run the SQL:

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
After building out your exploration queries:
1. Go to the **Changes** tab
2. You'll see `02_explore_data.sql` marked with **M** (modified)
3. Review the diff, write a commit message (e.g., `Add data exploration queries`), and click **Push**

---

## Step 3 — Build a Transformation Pipeline

Open `03_build_pipeline.sql`. We'll use CoCo to build staging and aggregate models.

### Suggested CoCo Prompts

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

CoCo will show suggested changes in a diff view — review before accepting.

### Git Checkpoint
Commit and push: `Add staging views and customer summary table`

---

## Step 4 — Create a Semantic View

Open `04_create_semantic_view.sql`.

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
Commit and push: `Add Streamlit dashboard`

---

## Step 6 — Explore Enhanced CoCo Capabilities

Open `06_enhanced_capabilities.sql` to try these advanced features:

### Fix Errors
Intentionally run a broken query, then click the **Fix** button in the results grid — CoCo will diagnose and suggest a fix.

### Explain Code
Highlight any SQL block, right-click (or use quick actions), and select **Explain** to get a plain-English walkthrough.

### Quick Edit
Highlight a SQL block and select **Quick Edit** from the quick actions menu to make targeted changes via natural language.

### Ask Follow-Up Questions
After CoCo generates a result, ask follow-up questions in the chat panel to iterate:

> ```
> Can you add a WHERE clause to filter for only the last 90 days?
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
| `01_setup_source_data.sql` | Seed data DDL and inserts |
| `02_explore_data.sql` | Data exploration queries (CoCo-generated) |
| `03_build_pipeline.sql` | Staging views and aggregate tables |
| `04_create_semantic_view.sql` | Cortex Analyst semantic view |
| `05_build_dashboard.sql` | Streamlit app reference |
| `06_enhanced_capabilities.sql` | Advanced CoCo feature demos |

---

## Learn More

- [Cortex Code in Snowsight](https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-snowsight)
- [Integrate Workspaces with Git](https://docs.snowflake.com/en/user-guide/ui-snowsight/workspaces-git)
- [Setting up Snowflake to use Git](https://docs.snowflake.com/en/developer-guide/git/git-setting-up)
- [Cortex Analyst Semantic Views](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
