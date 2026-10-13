# platform

Shared macros and generic tests. Every other project in this repo installs this folder as a local
package (`dependencies.yml` → `local: ../platform`) and calls macros with the `platform.` prefix.

| Macro | Use |
|---|---|
| `platform.money(expr)` | Round to 2 decimals as `numeric(18,2)` |
| `platform.safe_divide(num, den, scale=4)` | Ratio, null when the denominator is 0 or null |
| `platform.decode_status(expr, {'A': 'active'})` | Map raw codes, pass unknown codes through |
| `platform.month_start(expr)` | First day of the month as a date |
| `platform.add_months(expr, n)` | Cross-database month arithmetic |
| `platform.days_between(a, b)` / `platform.minutes_between(a, b)` | Cross-database differences |
| `platform.date_spine(start, end)` | One row per day (`date_day`) |
| `platform.as_of_date()` | Shared reporting date from `var('as_of_date')` |
| `platform.anonymize(expr)` | One-way hash (sha2 on Snowflake) |

Generic tests: `platform.non_negative`, `platform.in_range` (min_value / max_value),
`platform.not_after_as_of`.

The project also builds `dim_calendar` and runs `tests/` against the macros in its own CI.
Consumers disable those models and tests (`platform: +enabled: false` in their `dbt_project.yml`).
