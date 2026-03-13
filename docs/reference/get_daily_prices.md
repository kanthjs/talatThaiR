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
  [`show_daily_categories()`](https://kanthanawit.github.io/talatThaiR/reference/show_daily_categories.md),
  e.g. "SHRIMP")

- product_code:

  Product code (see
  [`show_daily_products()`](https://kanthanawit.github.io/talatThaiR/reference/show_daily_products.md),
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
