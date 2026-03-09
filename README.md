# Getting Started with Cortex Code in Snowsight Workspaces

A hands-on quickstart that walks you through using **Cortex Code (CoCo)** as your AI pair-programmer inside a **Git-synced Snowflake Workspace**. By the end, you'll have built a small analytics pipeline entirely through natural language prompts — and pushed it all back to your Git repo.

---

## Prerequisites

| Requirement | Details |
|---|---|
| Snowflake account | Commercial (non-Gov/VPS) with [Cross-region inference](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-cross-region-inference) enabled |
| Roles & privileges | `SNOWFLAKE.COPILOT_USER` + `SNOWFLAKE.CORTEX_USER` (or `CORTEX_AGENT_USER`) database roles granted to your role |
| GitHub account | With permissions to create new repositories |
| Snowflake Git API integration | A `git_https_api` API integration configured for GitHub ([setup guide](https://docs.snowflake.com/en/developer-guide/git/git-setting-up)) |
| Warehouse | A warehouse your role can use (e.g., `APP_WH`) |

---

## Architecture & Workflow

```
┌─────────────────────────────────────────────────────┐
│              Git Repository (GitHub)                 │
│           coco-quickstart / main branch              │
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

## Step 0 — Create a GitHub Repo

> Snowflake Workspaces cannot connect to an empty repository. You must have at least one commit on a branch before creating a Workspace.

1. Go to [github.com/new](https://github.com/new)
2. Set the following:
   - **Repository name:** `coco-quickstart`
   - **Visibility:** Private (or Public — your choice)
   - **Check** "Add a README file"
3. Click **Create repository**

You now have a repo at `https://github.com/<your-username>/coco-quickstart` with a `main` branch and one commit.

---

## Step 1 — Create a Git-Synced Workspace

1. In Snowsight, go to **Projects → Workspaces**
2. Click **+ → From Git repository**
3. Fill in the form:
   - **Repository URL:** `https://github.com/<your-username>/coco-quickstart.git`
   - **Workspace name:** `coco-quickstart`
   - **API integration:** Select your configured Git API integration
   - **Authentication:** Personal access token (select your stored secret) or OAuth
4. Click **Create**

Once the workspace opens:

5. Click the **Changes** tab (left sidebar, branch icon)
6. Click the branch dropdown and select **Create branch**
7. Name it: `feature/build-pipeline`
8. Click **Create**

> You are now on a feature branch in a Git-synced Workspace. Everything you create here will be tracked, diffed, and pushed back to GitHub.

---

## Step 2 — Set Up the AGENTS.md File

> ### Best Practice: Why AGENTS.md?
>
> Without `AGENTS.md`, every new CoCo conversation starts from zero. You'd have to re-explain your database names, table schemas, naming conventions, and project context every single time.
>
> With `AGENTS.md`, CoCo **automatically reads it at the start of every conversation** in the Workspace. This means:
>
> - **No repetition** — CoCo already knows your database is `COCO_DEMO`, your tables, and their columns
> - **Consistent output** — CoCo follows your conventions (fully qualified names, correct warehouse/role) without being told
> - **Team alignment** — Every developer on the project gets the same CoCo behavior because `AGENTS.md` is committed to Git
> - **Better prompts** — You can write shorter, simpler prompts (e.g., "show top customers by revenue") and CoCo fills in the details
>
> Think of it as a **project-level system prompt** for your AI pair-programmer. It's checked into Git and shared across the team — just like a `.editorconfig` or `CONTRIBUTING.md` standardizes human developer behavior.

Open the Cortex Code panel (bottom-right icon) and prompt:

> **Prompt:**
> ```
> Create a new file called AGENTS.md with the following content:
>
> This is a quickstart demo for Cortex Code in Snowsight Workspaces.
> The data lives in database COCO_DEMO with schemas RAW and ANALYTICS.
>
> Source tables:
> - COCO_DEMO.RAW.CUSTOMERS (customer_id INT, name VARCHAR, email VARCHAR, region VARCHAR, signup_date DATE)
> - COCO_DEMO.RAW.ORDERS (order_id INT, customer_id INT, order_date DATE, amount DECIMAL, status VARCHAR)
>
> Conventions:
> - Always use fully qualified table names (DATABASE.SCHEMA.TABLE)
> - Use APP_WH warehouse and SF_INTELLIGENCE_DEMO role
> - Follow Snowflake SQL best practices
> ```

Review the diff and accept it.

### Git Checkpoint
Go to the **Changes** tab. You'll see `AGENTS.md` marked with **A** (added). Write the commit message: `Add AGENTS.md for CoCo project context` and click **Push**.

---

## Step 3 — Set Up Source Data

Open the Cortex Code panel and prompt:

> **Prompt:**
> ```
> Create a new SQL file called 01_setup_source_data.sql.
> In it, create a database called COCO_DEMO with a schema called RAW
> and a schema called ANALYTICS. Then create two tables in RAW:
> - CUSTOMERS (customer_id, name, email, region, signup_date)
> - ORDERS (order_id, customer_id, order_date, amount, status)
> Populate CUSTOMERS with 500 rows and ORDERS with 2000 rows of
> realistic synthetic data. Use GENERATOR() for the inserts.
> Add a verification query at the end showing row counts.
> ```

Review the diff, accept it, and run the SQL. Verify you see 500 customers and 2,000 orders.

### Git Checkpoint
Go to the **Changes** tab — you'll see `01_setup_source_data.sql` marked with **A** (added). Commit with message: `Seed source data` and **Push**.

---

## Step 4 — Explore Your Data

Open the Cortex Code panel and try these prompts one at a time. After each, **review the diff**, accept it, and run the SQL:

> **Prompt 1 — Data profiling:**
> ```
> Create a new SQL file called 02_explore_data.sql.
> Write queries to profile the COCO_DEMO.RAW.CUSTOMERS and
> COCO_DEMO.RAW.ORDERS tables. Show row counts, null counts per
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

## Step 5 — Build a Transformation Pipeline

> **Prompt 1 — Staging layer:**
> ```
> Create a new SQL file called 03_build_pipeline.sql.
> Create a view called COCO_DEMO.ANALYTICS.STG_ORDERS that joins
> ORDERS with CUSTOMERS, adds the customer name and region, and filters
> out cancelled orders.
> ```

> **Prompt 2 — Aggregate model:**
> ```
> Create a table called COCO_DEMO.ANALYTICS.CUSTOMER_SUMMARY that
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

## Step 6 — Create a Semantic View

> **Prompt:**
> ```
> Create a new SQL file called 04_create_semantic_view.sql.
> Create a Cortex Analyst semantic view called
> COCO_DEMO.ANALYTICS.CUSTOMER_ANALYTICS_SV over the
> COCO_DEMO.ANALYTICS.CUSTOMER_SUMMARY table. Include meaningful
> descriptions for all columns and define common metrics like
> total_revenue and avg_order_value.
> ```

After creating the semantic view, test it:

> **Prompt:**
> ```
> Use the COCO_DEMO.ANALYTICS.CUSTOMER_ANALYTICS_SV semantic view
> to answer: "Which region has the highest average order value?"
> ```

### Git Checkpoint
Commit and push: `Add semantic view for customer analytics`

---

## Step 7 — Build a Streamlit Dashboard

> **Prompt:**
> ```
> Build a Streamlit in Snowflake app that visualizes data from
> COCO_DEMO.ANALYTICS.CUSTOMER_SUMMARY. Include:
> - A bar chart of revenue by region
> - A line chart of monthly order trends
> - A filter for region
> Deploy it to Snowflake.
> ```

### Git Checkpoint
Commit and push any generated files: `Add Streamlit dashboard`

---

## Step 8 — Explore Enhanced CoCo Capabilities

Now let's see what CoCo can do beyond generating code from scratch.

### Fix Errors

Open any SQL file and paste this intentionally broken query:

```sql
SELECT
    customer_id,
    nama,                          -- typo: should be "name"
    TOTAL(amount) AS total_spent   -- wrong function: should be SUM
FROM COCO_DEMO.RAW.CUSTOMERS c
JOIN COCO_DEMO.RAW.ORDERS o USING (customer_id)
GROUP BY 1, 2;
```

Run it. It will fail. Click the **Fix** button in the results grid — CoCo will diagnose both errors and suggest the corrected SQL.

### Explain Code

Highlight any complex SQL block in your workspace, right-click, and select **Explain** to get a plain-English walkthrough of what the query does.

### Quick Edit

Highlight a SQL block and select **Quick Edit** from the quick actions menu, then try:
> ```
> Add a WHERE clause to filter for only the last 90 days
> ```

### Follow-Up Questions

After CoCo generates a result, ask follow-ups directly in the chat panel to iterate:
> ```
> Can you add a percent-of-total column to these results?
> ```
> ```
> Convert this into a CTE-based approach
> ```
> ```
> Add window functions to rank customers within each region
> ```

---

## Step 9 — Merge Back to Main

Now that your feature branch has all the work, merge it back using your standard Git workflow:

1. Go to **GitHub** → your `coco-quickstart` repo
2. You'll see a banner: **"feature/build-pipeline had recent pushes"** → click **Compare & pull request**
3. Set the following:
   - **Title:** `Build analytics pipeline with Cortex Code`
   - **Base branch:** `main`
   - **Compare branch:** `feature/build-pipeline`
4. Review the diff — you'll see every file CoCo generated
5. Click **Create pull request**
6. After review, click **Merge pull request** → **Confirm merge**

Back in Snowsight:

7. Go to the **Changes** tab in your Workspace
8. Switch to the `main` branch
9. Click **Pull** to get the merged code

> Your Git repo now contains the full pipeline — every file was generated by CoCo, committed from the Workspace, and merged via PR. This is the production workflow.

---

## Recommended Git Workflow Summary

| Step | Where | Action |
|---|---|---|
| 1. Create feature branch | Workspaces → Changes tab | Branch off `main` |
| 2. Develop | Workspaces + CoCo | Generate, edit, run, iterate |
| 3. Review diffs | Workspaces → Changes tab | Verify all changes |
| 4. Commit & Push | Workspaces → Changes tab | Push to remote branch |
| 5. Open PR | GitHub | Code review + CI checks |
| 6. Merge | GitHub | Merge to `main` |
| 7. Pull | Workspaces → Changes tab | Get latest `main` |

> **Production best practice:** Never develop directly on `main`. Always use feature branches, push from Workspaces, and merge via Pull Request with code review.

---

## What You Built

| File | How it was created |
|---|---|
| `AGENTS.md` | CoCo prompt (Step 2) |
| `01_setup_source_data.sql` | CoCo prompt (Step 3) |
| `02_explore_data.sql` | CoCo prompt (Step 4) |
| `03_build_pipeline.sql` | CoCo prompt (Step 5) |
| `04_create_semantic_view.sql` | CoCo prompt (Step 6) |
| Streamlit app | CoCo prompt (Step 7) |

> Every file was generated by Cortex Code, committed from the Workspace, and merged to `main` via Pull Request. Nothing was written by hand.

---

## Learn More

- [Cortex Code in Snowsight](https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-snowsight)
- [Integrate Workspaces with Git](https://docs.snowflake.com/en/user-guide/ui-snowsight/workspaces-git)
- [Setting up Snowflake to use Git](https://docs.snowflake.com/en/developer-guide/git/git-setting-up)
- [Cortex Analyst Semantic Views](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
