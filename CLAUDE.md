# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`talatThaiR` is an R package that provides access to Thai agricultural statistics from the National Agricultural Big Data Center (NABC) API. It supports daily, weekly, and monthly commodity prices as well as production and price indices at monthly, quarterly, and yearly frequencies.

## Common Development Commands

```r
# Run tests
devtools::test()

# Run a specific test file
devtools::test(filter = "test-get_daily_prices")

# Check package (linting, documentation, etc.)
devtools::check()

# Generate/roxygen2 documentation
devtools::document()

# Install the package locally
devtools::install()

# Load package with devtools (automatically loads library(devtools))
library(talatThaiR)
```

## Architecture

### Core API Layer

- **`R/utils.R`** - Contains `.nabc_fetch_data()`, the single HTTP client used by all functions. Makes requests to `https://agriapi.nabc.go.th/` using httr and jsonlite. This is the only place that directly interacts with the API.

### Code Mappings

- **`R/mappings.R`** - Contains internal mapping vectors (`.DAILY_*_MAP`, `.WEEKLY_*_MAP`, `.INDEX_*_MAP`, `.QUARTER_PRODUCT_MAP`) that map English codes to Thai product/category names. Also exports `show_*()` helper functions for users to browse available codes. All mapping objects are internal (prefixed with `.`).

### Data Fetching Functions

All `get_*_prices()` and `get_*_index()` functions follow a consistent pattern:
1. **Validation** - Exactly one primary search mode required (category_code, product_code, or date/year_month)
2. **Code Mapping** - English codes are mapped to Thai names via internal mappings
3. **Endpoint Resolution** - Builds API path and query parameters based on mode
4. **Pagination** - Fetches all pages (using pagination$total and pagination$limit), concatenates into single data.frame
5. **Return** - Sorted data.frame with meaningful progress messages

### API Endpoint Patterns

- Daily prices: `api/daily-prices/{date,category,product}`
- Weekly prices: `api/weekly-prices/{commod,product,year-month}`
- Monthly prices: `api/monthly-prices/{commod,product,year-month}`
- Price/Production indices (month/quarter/year): `api/{price,production}-index-{freq}/{sector,category,group,product,all}`

## Testing Strategy

The package uses testthat 3+ with a specific mocking pattern to avoid real API calls.

### Mocking Pattern

Tests use `local_mocked_bindings(.nabc_fetch_data, .package = "talatThaiR")` to replace the API client at the namespace level. This is critical: `.nabc_fetch_data()` may be called from deeply nested closures (`.fetch_page`, `.fetch_all_pages`), and namespace-level mocking ensures all calls are intercepted regardless of depth.

### Test Helpers

Located in `tests/testthat/helper-tests.R`:
- `make_response(n, total, date)` - Simulates a successful API response with pagination metadata
- `make_empty()` - Simulates an empty result set
- `make_capture(response)` - Returns an environment with a mock function that tracks calls (path, params, call count)
- `make_paged_fn(total, per_page)` - Returns a function that simulates multi-page responses with call count tracking

### Test File Structure

- `test-utils.R` - Tests for `.nabc_fetch_data` and HTTP error handling
- `test-mappings.R` - Tests that `show_*()` functions return valid mappings
- `test-pagination.R` - Tests multi-page fetching across all get_* functions
- `test-get_*.R` - Individual function tests for code validation, endpoint routing, and date filtering

### Key Test Patterns

When writing tests for new get_* functions:
1. Use `local_mocked_bindings()` to mock `.nabc_fetch_data`
2. Use `make_capture()` to verify correct endpoint path and query parameters
3. Use `make_paged_fn()` for pagination tests
4. Use `suppressMessages()` to hide progress messages in assertions
5. Always test invalid codes produce helpful error messages referencing the appropriate `show_*()` function

## Thai Buddhist Calendar

The package uses Thai Buddhist year (BE = CE + 543) for year-based filtering (e.g., year_th = 2569 for 2026). When adding new year-based filters, follow this convention.

## Date Formats

- Gregorian dates (YYYY-MM-DD) used for daily prices (`date`, `start_date`, `end_date`)
- Thai Buddhist year (integer or character) used for weekly/monthly/index functions
- Month integers 1-12 are normalized to two-character strings (e.g., sprintf("%02d", as.integer(month)))
