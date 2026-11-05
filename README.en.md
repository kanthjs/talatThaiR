# talatThaiR <img src="man/figures/talatThaiR_hexlogo_nobg.png" align="right" height="139" alt="talatThaiR logo"/>

> **Thai README:** [README.md](README.md)

<!-- badges: start -->
[![R-CMD-check](https://github.com/kanthjs/talatThaiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/kanthjs/talatThaiR/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![Codecov test coverage](https://codecov.io/gh/kanthjs/talatThaiR/graph/badge.svg)](https://app.codecov.io/gh/kanthjs/talatThaiR)
<!-- badges: end -->

## Overview

`talatThaiR` provides a tidy R interface to the Thai agricultural price and
index data served by the [National Agricultural Big Data Center (NABC)](https://agriapi.nabc.go.th)
of the Office of Agricultural Economics (OAE / สศก.), Thailand.

The package handles:

- **HTTP + pagination** — multi-page requests are merged transparently; callers
  receive a single `data.frame`.
- **Product code mappings** — the NABC API accepts Thai product names; `talatThaiR`
  exposes English codes (`"RUBBER_LIQUID"`, `"RICE_MALI105"`, …) and translates
  internally.
- **Cross-frequency crosswalk** — the same commodity often carries a different
  name at daily vs. weekly/monthly resolution (e.g. fresh rubber latex is
  `"น้ำยางพาราสด"` in daily data and `"น้ำยางสด คละ"` in weekly data).
  `crosswalk_products()` returns a reference table mapping codes across datasets.
- **Buddhist-era years** — all date parameters accept Buddhist Era (พ.ศ.) years,
  matching the API convention.

**Data supported:**

| Type | Frequencies |
|---|---|
| Commodity prices | Daily, Weekly, Monthly |
| Agricultural production index | Monthly, Quarterly, Yearly |
| Agricultural price index | Monthly, Quarterly, Yearly |

**Covered commodities include:** rice (Jasmine, glutinous, non-glutinous),
rubber (latex, sheet, lump), cassava, palm oil, sugarcane, corn, pineapple,
coconut, longan, shrimp, chicken, pork, eggs, and more.

---

## Installation

```r
# install.packages("remotes")
remotes::install_github("kanthjs/talatThaiR")
```

---

## Basic usage

```r
library(talatThaiR)

# Daily prices for all rubber products
get_daily_prices(category_code = "RUBBER")

# Weekly prices for a specific product, date range
get_weekly_prices(
  product_code = "RUBBER_LIQUID_MIX",
  start_date   = "2024-01-01",
  end_date     = "2024-12-31"
)

# Monthly agricultural price index — Jasmine rice, 2024
get_price_index_month(
  product_code = "RICE_MALI_IN_SEASON",
  year_th      = 2567          # Buddhist Era year (2024 CE)
)

# See all available daily product codes
show_daily_products()

# Cross-frequency product reference
crosswalk_products()
```

---

## Motivation and scope

Thai agricultural price data from สศก. is publicly accessible via API but
requires knowledge of Thai product nomenclature, understanding of pagination,
and manual reconciliation of commodity names across data frequencies.
`talatThaiR` resolves all three so that researchers can focus on analysis
rather than data wrangling.

**Potential use cases:**

- Tracking seasonal commodity price cycles for staple crops
- Economic damage estimation: multiplying crop loss estimates (e.g. disease
  outbreak models) by market prices to derive monetary impact
- Input for regional computable general equilibrium (CGE) models
- Teaching material for time-series analysis courses using real Thai data

---

## API functions

| Function | Data |
|---|---|
| `get_daily_prices()` | Daily commodity prices |
| `get_weekly_prices()` | Weekly commodity prices |
| `get_monthly_prices()` | Monthly commodity prices |
| `get_production_index_month()` | Monthly agricultural production index |
| `get_production_index_quarter()` | Quarterly agricultural production index |
| `get_production_index_year()` | Yearly agricultural production index |
| `get_price_index_month()` | Monthly agricultural price index |
| `get_price_index_quarter()` | Quarterly agricultural price index |
| `get_price_index_year()` | Yearly agricultural price index |

**Helper functions:**

| Function | Returns |
|---|---|
| `show_daily_products()` | Daily product codes (27 items) |
| `show_daily_categories()` | Daily category codes (13 categories) |
| `show_weekly_products()` | Weekly/monthly product codes |
| `show_weekly_categories()` | Weekly/monthly category codes (15 categories) |
| `show_index_products()` | Monthly index product codes |
| `show_quarter_products()` | Quarterly/yearly index product codes |
| `show_index_categories()` | Index category codes |
| `show_index_groups()` | Index group codes (8 groups) |
| `crosswalk_products()` | Cross-frequency product name reference |

---

## Notes on the NABC API

**Buddhist Era years:** The `year_th` parameter uses พ.ศ. (e.g. `2568` = 2025 CE).

**Product naming inconsistency:** NABC product names differ across frequencies.
Use `crosswalk_products()` to identify matching codes when linking daily and
weekly/monthly series. See the
[product reference vignette](https://kanthjs.github.io/talatThaiR/) for the
full mapping table.

**Rate limiting:** `talatThaiR` sleeps 0.3 s between paginated requests to
avoid overloading the API.

**API key:** Most endpoints are public; an `api_key` parameter is available on
all functions if the API requires one in the future.

---

## Related packages

There are no other R packages known to the authors that wrap the NABC
agricultural price API. For Thai economic data more broadly:

- [`tradestatistics`](https://docs.ropensci.org/tradestatistics/) — UN Comtrade
  data including Thai trade flows (rOpenSci-reviewed)
- [`FAOSTAT`](https://cran.r-project.org/package=FAOSTAT) — FAO agricultural
  statistics including Thailand

---

## Data source and terms of use

Data are served by the Office of Agricultural Economics (OAE / สำนักงานเศรษฐกิจ
การเกษตร) via the NABC API at [agriapi.nabc.go.th](https://agriapi.nabc.go.th).
Users should consult OAE's terms of service before redistributing raw data
obtained through this package.

---

## License

MIT © Kanthanawit Jaisong
