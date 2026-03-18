# Get daily agricultural commodity prices

Get daily agricultural commodity prices

## Usage

``` r
get_daily_prices(
  category_code = NULL,
  product_code = NULL,
  date = NULL,
  start_date = NULL,
  end_date = as.character(Sys.Date()),
  api_key = NULL
)
```

## Arguments

- category_code:

  Category code (see
  [`show_daily_categories()`](https://kanthjs.github.io/talatThaiR/reference/show_daily_categories.md),
  e.g. "SHRIMP")

- product_code:

  Product code (see
  [`show_daily_products()`](https://kanthjs.github.io/talatThaiR/reference/show_daily_products.md),
  e.g. "LIME_XL")

- date:

  Fetch prices for a specific date (format: "YYYY-MM-DD")

- start_date:

  Filter results from this date onward (format: "YYYY-MM-DD"). Used with
  category_code or product_code.

- end_date:

  Filter results up to this date (default: today)

- api_key:

  API key (if required)

## Value

A data.frame of daily agricultural commodity prices

## Examples

``` r
if (FALSE) { # \dontrun{
# Select by product category
get_daily_prices(category_code = "RICE_MALI")

# Select by product name
get_daily_prices(product_code = "LIME_XL")

# Get all products for a specific date
get_daily_prices(date = "2025-06-01")

# Get a product from a specific date range
get_daily_prices(product_code = "LIME_XL", start_date = "2026-01-01")

# Get a category from a specific date range
get_daily_prices(category_code = "SHRIMP", start_date = "2026-01-01")
} # }
```
