# Financial services — dbt mesh demo

Banking, insurance, wealth and management accounting, joined on `party_key`.

Every directory below is its own dbt project. `group_analytics` reads only the public models of the
source projects via cross-project `ref()`. Every project installs `platform/` as a local package for
shared macros and generic tests.

| Directory | Platform project | Public models | Models (stg / int / marts) |
|---|---|---|---|
| `platform/` | `op_platform` | Shared macros and generic tests (installed as a local package by every project), `dim_calendar` | — |
| `banking/` | `op_banking` | `dim_banking_customers`, `dim_banking_accounts`, `fct_banking_holdings`, `fct_banking_account_monthly`, `fct_banking_loan_performance` | 6 / 4 / 5 |
| `insurance/` | `op_insurance` | `dim_insurance_customers`, `dim_insurance_policies`, `fct_insurance_holdings`, `fct_insurance_claims`, `fct_insurance_product_loss_ratio` | 3 / 3 / 5 |
| `wealth/` | `op_wealth` | `dim_wealth_customers`, `dim_wealth_portfolios`, `fct_wealth_holdings`, `fct_wealth_portfolio_monthly`, `fct_wealth_risk_allocation` | 3 / 3 / 5 |
| `financials/` | `op_financials` | `fct_customer_profitability_monthly`, `fct_customer_profitability_trailing`, `fct_customer_profitability_summary`, `fct_profitability_data_gaps`, `fct_customer_revenue_forecast` | 2 / 3 / 5 |
| `group_analytics/` | `op_group_analytics` | `dim_customer_360`, `fct_customer_monthly`, `dim_customer_segments`, `fct_customer_churn` | 0 / 7 / 5 |

## Raw data

Loaded into Snowflake `RAW_*` schemas by provisioning (not dbt seed). Reporting date is
`as_of_date` = 2026-03-31; history covers April 2025 to March 2026.

| Table | Rows | Contents |
|---|---:|---|
| `raw_banking.customers` | 26 | One row per banking customer. party_key is the group identifier shared with insurance and wealth. |
| `raw_banking.customer_exits` | 5 | Relationship exits recorded by the retention team, with reason. |
| `raw_banking.accounts` | 56 | One row per deposit or card account. Closed accounts stay in the book. |
| `raw_banking.transactions` | 2132 | One row per posted account transaction. |
| `raw_banking.loans` | 24 | One row per loan facility. |
| `raw_banking.loan_repayments` | 276 | Scheduled monthly instalments; paid_date is null when the instalment was missed. |
| `raw_insurance.customers` | 23 | One row per insurance customer. |
| `raw_insurance.policies` | 38 | One row per policy. Only active policies count toward holdings and premium. |
| `raw_insurance.claims` | 14 | One row per claim. Open claims have no settled_date or payment. |
| `raw_wealth.clients` | 18 | One row per wealth client. Client ids are not banking or insurance ids. |
| `raw_wealth.portfolios` | 31 | One row per portfolio. Open market value is assets under management. |
| `raw_wealth.trades` | 528 | One row per executed trade with its fee. |
| `raw_financials.revenue_transactions` | 345 | One row per revenue posting. Amount is null when the posting failed to price. |
| `raw_financials.allocated_costs` | 343 | One row per party per month. Cost is null when finance has not allocated yet. |

- 30 parties (people and businesses) across banking, insurance and wealth; not every party is in every book.
- Banking statuses are single letters; `F` (frozen) is deliberately unmapped for the workshop.
- Five parties exit during the year (`customer_exits`); this is the churn model's label.
- Three borrowers fall into arrears at the end of the year; about 6% of other instalments are paid late.
- Noah Keller has an unpriced February revenue posting and Amira Haddad is missing two cost allocations, so those months drop out of profitability (see `fct_profitability_data_gaps`).

## Layout

```text
financial_services/
  skeleton.json                      # projects, dependencies, raw data location (read by provisioning)
  raw_data/raw_<domain>/<table>.csv  # source data, loaded into RAW_* schemas
  platform/                          # macros, generic tests, dim_calendar
  <domain>/
    dependencies.yml                 # local package ../platform (+ upstream projects for group_analytics)
    models/staging/<source>/         # stg_<source>__<table>: rename, cast, decode; 1:1 with raw tables
    models/intermediate/             # int_<entity>__<verb>: joins and aggregation
    models/marts/                    # dim_* / fct_*: tables; public models carry enforced contracts
    tests/                           # assert_* singular tests (unit tests live next to the models)
  scripts/check_naming.py
```

## Conventions

- Only staging models select from sources. Marts never read staging directly when an intermediate exists.
- Shared logic lives in `platform` macros: `platform.money`, `platform.safe_divide`, `platform.month_start`,
  `platform.add_months`, `platform.days_between`, `platform.as_of_date`, `platform.anonymize`.
- Generic tests `platform.non_negative` and `platform.in_range` come from the same package.
- Public models have `access: public` and an enforced contract. Everything else stays `protected`.
- Names are snake_case with `stg_`, `int_`, `dim_`, `fct_`, `assert_` prefixes; CI runs `scripts/check_naming.py`.

## Testing

Every model has a grain test, every source table a key test, and every project has unit and singular
tests. `scripts/check_test_coverage.py` enforces this in CI; the counts below come from it.

| Project | Models | Built-in | Custom (platform) | Package (hub) | Source | Singular | Unit |
|---|---:|---:|---:|---:|---:|---:|---:|
| `platform` | 2 | 4 | 3 | 2 | 0 | 4 | 1 |
| `banking` | 15 | 51 | 6 | 8 | 12 | 2 | 1 |
| `insurance` | 11 | 36 | 3 | 3 | 6 | 2 | 1 |
| `wealth` | 11 | 36 | 3 | 3 | 6 | 2 | 1 |
| `financials` | 10 | 26 | 1 | 7 | 4 | 1 | 1 |
| `group_analytics` | 12 | 33 | 1 | 5 | 0 | 2 | 1 |

| Test type | What it shows | Where to look |
|---|---|---|
| Built-in generic | `unique`, `not_null`, `accepted_values`, `relationships` (also on sources) | `banking/models/marts/_banking__models.yml` |
| Custom generic | Tests written once as Jinja macros in `platform`: `platform.non_negative`, `platform.in_range`, `platform.not_after_as_of`, `platform.sums_match` (reconciles totals, also across projects) | `platform/macros/generic_tests/`, `group_analytics/models/marts/_group_analytics__models.yml` |
| Package (hub.getdbt.com) | `dbt_utils.unique_combination_of_columns` (grain), `expression_is_true`, `equal_rowcount`, `accepted_range` with `where`, `not_constant`, `at_least_one`; `dbt_expectations.expect_column_values_to_match_regex` (ID formats), `expect_table_row_count_to_be_between` | `dependencies.yml`, any `_*__models.yml` |
| Templated singular | One Jinja loop stamps the same check over every public model (`assert_public_models_not_empty`) | `<project>/tests/assert_public_models_not_empty.sql` |
| Singular | Hand-written SQL assertions for rules that do not fit a generic test | `<project>/tests/assert_*.sql` |
| Unit | Logic tested on fixed input rows, no warehouse data needed | `unit_tests:` blocks in `models/**/_*.yml` |
| Contracts | Enforced column names, types and `not_null` constraints on every public model | `config.contract.enforced` on public models |
| Thresholds | `severity` + `warn_if` / `error_if`: known data quality issues warn, a spike fails | `expression_is_true` with `config:` in the marts YAML |
| Source freshness | `loaded_at_field` + `warn_after` on the entity tables | `models/staging/<source>/_<source>__sources.yml` |

One threshold test per vertical is set to warn on the sample data on purpose, so a build shows what a
non-blocking data quality signal looks like.

---

## Workshop exercises

Start in **`op_banking`** Studio IDE (branch from `main`). Use Preview, Build, and Test — or the Command bar.

**Ask the data:** [Natural-language metric chat](https://ludwig-sewall.github.io/op_financial_services/) on GitHub Pages (Semantic Layer on `op_group_analytics`).

## 1. Find the customer warning

A Production test warns that a customer has an invalid status. Source data uses one-letter codes (`A`, `I`, `C`, `F`); the staging model’s `CASE` only maps three of them. Start with the wider lineage to understand where the model fits.

1. In Catalog, select **Production**. Explore the account-level lineage, then zoom into the `op_banking` project lineage.
2. Open `dim_banking_customers` and find the warning on its `customer_status` test. Valid values are `active`, `inactive`, `closed`, and `frozen`.
3. Open the test and click **Preview** to see the failing row (status `F`). Then choose **Edit in Studio** to open the model in Studio IDE.

**Done when:** You know which customer caused the warning and that the model returned the raw letter `F`.

---

## 2. Fix the warning in development

Your development schema is empty. Use deferral and a clone to bring the Production model into development, then extend the `CASE`. Leave the backend source data (`RAW_BANKING.customers`) unchanged.

1. In Studio IDE, enable the **Defer** toggle beside the Command bar and select **Production** as the environment to defer to.
2. Run the following command to clone `dim_banking_customers` into your development schema with fresh Production data:

   ```bash
   dbt clone --select dim_banking_customers
   ```

3. Preview the model or the failing test rows to find the same customer.
4. In `banking/models/staging/banking/stg_banking__customers.sql`, add a branch to the `CASE` that maps `F`:

   ```sql
   when customer_status = 'F' then 'frozen'
   ```

5. Click **Build** on the affected model, then Preview the corrected row and check the test result.

**Done when:** The customer shows `frozen` in development and the warning is gone.

---

## 3. See what happens when you open a PR

1. Commit and push your change from Studio IDE, then open a PR against `main`.
2. A dbt CI job runs automatically. Open it from the PR’s Checks to see which models and tests ran.
3. The Platform handles state selection and deferral using the Production state: CI runs the changed models and their downstream dependencies while reusing unchanged Production parents.
4. Review the dbt metadata written back to the PR, including the run result and any model or test failures.
5. To try the repository’s naming check, temporarily rename `models/marts/fct_banking_holdings.sql` to `models/marts/BankHoldings.sql` and push. Read the GitHub Actions `ci` failure, then restore the filename and push again.

**Done when:** The dbt CI and naming checks both pass on the PR.

---

## 4. Break a model contract

`dim_banking_customers` has an enforced contract. Try removing a required column and see the error before the change reaches Production.

1. In Studio IDE, remove `party_key` from the final select in `models/marts/dim_banking_customers.sql`. Leave the column declaration and `contract.enforced: true` in `models/marts/_banking__models.yml`.
2. Click **Build** on `dim_banking_customers` and open the contract error in the run results.
3. Restore `party_key` and build again.

**Done when:** You have seen the contract failure and restored a passing build.

---

## 5. Apply a shared standard across domains

When several domains publish customer data, shared macros help them apply the same transformation consistently. Every project in this repo installs the `platform` package, which owns those shared macros. Banking will use `platform.anonymize` to hash customer names.

1. In Studio IDE, inspect `dependencies.yml` (it installs `../platform`) and `platform/macros/anonymize.sql`. Run `dbt deps` in the Command bar.
2. Add these columns to `models/marts/dim_banking_customers.sql`:

   ```sql
   full_name::varchar as full_name,
   {{ platform.anonymize('full_name') }} as full_name_hash,
   ```

3. Add both columns to the enforced contract in `models/marts/_banking__models.yml` with `data_type: varchar`.
4. Click **Build**, then Preview `dim_banking_customers` to compare the clear name and its hash.

**Done when:** The build passes and `full_name_hash` contains a digest rather than the clear name.

---

## 6. Explore the mesh-fed customer 360

`op_group_analytics` is built from public models in banking, insurance, wealth, and financials — not from local seeds.

1. Open Catalog → Production → account lineage. Find `dim_customer_360` and confirm its parents are public models in the four domain projects (via the `int_customer_360__*` models).
2. Open `op_group_analytics` → Develop → Studio IDE. Preview `dim_customer_360`.
3. Pick one `customer_id` (`party_key`) and note which domains it appears in (`banking_customer_id`, `insurance_customer_id`, `wealth_customer_id`, `domain_count`) and its total profit.
4. Optional: add a simple derived column (for example a `case` on `domain_count` or `loan_balance`) directly in `models/marts/dim_customer_360.sql`, update the contract in `models/marts/_group_analytics__models.yml`, then Build and Preview.

**Done when:** You can explain how one party row is assembled from cross-project `ref()`s.

---

## 7. Query the Semantic Layer

`dim_customer_360` publishes a semantic model (`customers`, `total_revenue`, `total_profit`, `assets_under_management`) with dimensions like `banking_status`. `fct_customer_monthly` adds monthly metrics (`monthly_profit`, `monthly_claims_paid`). A protected `time_spine_daily` model lets the Semantic Layer resolve time.

1. In the Platform, open **Semantic Layer** for `op_group_analytics` (Production). Confirm warehouse credentials are set for the project if prompted.
2. Run metrics `customers` and `total_profit`, grouped by `customer__banking_status`.
3. You should see totals in this shape (counts can drift if source data changes):

   | banking_status | customers | total_profit |
   |---|---:|---:|
   | active | 21 | 796025 |
   | closed | 2 | 2740 |
   | frozen | 1 | 8400 |
   | inactive | 2 | -5880 |
   | *(null — no banking row)* | 4 | 122720 |

4. Confirm the same numbers with Preview / SQL on `dim_customer_360` (`count(*)`, `sum(total_profit)` by `banking_status`).

**Done when:** The Semantic Layer result matches the model.
