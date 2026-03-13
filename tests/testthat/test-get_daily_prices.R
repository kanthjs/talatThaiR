# =============================================================================
# Tests: get_daily_prices()
# =============================================================================

# --- Validation (no API call needed) ----------------------------------------

test_that("errors when no input is given", {
  expect_error(get_daily_prices(), "Please specify one of")
})

test_that("errors when multiple primary modes are given", {
  expect_error(
    get_daily_prices(category_code = "SHRIMP", product_code = "LIME_XL"),
    "only one search mode"
  )
  expect_error(
    get_daily_prices(category_code = "SHRIMP", date = "2025-01-01"),
    "only one search mode"
  )
  expect_error(
    get_daily_prices(product_code = "LIME_XL", date = "2025-01-01"),
    "only one search mode"
  )
})

test_that("errors on unknown category_code", {
  expect_error(
    get_daily_prices(category_code = "UNKNOWN_CAT"),
    "Category code 'UNKNOWN_CAT' not found"
  )
})

test_that("errors on unknown product_code", {
  expect_error(
    get_daily_prices(product_code = "UNKNOWN_PROD"),
    "Product code 'UNKNOWN_PROD' not found"
  )
})

test_that("warns when both date and start_date are given", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  expect_warning(
    suppressMessages(get_daily_prices(date = "2025-01-15", start_date = "2025-01-01")),
    "'start_date' is ignored"
  )
})

# --- Routing: date mode -----------------------------------------------------

test_that("date mode routes to /daily-prices/date", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_daily_prices(date = "2025-06-01"))
  expect_match(cap$path, "daily-prices/date")
})

test_that("date mode sends date param", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_daily_prices(date = "2025-06-01"))
  expect_equal(cap$params$date, "2025-06-01")
})

# --- Routing: category mode -------------------------------------------------

test_that("category_code routes to /daily-prices/category", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_daily_prices(category_code = "SHRIMP"))
  expect_match(cap$path, "daily-prices/category")
})

test_that("category_code sends product_category param", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_daily_prices(category_code = "SHRIMP"))
  expect_true("product_category" %in% names(cap$params))
})

# --- Routing: product mode --------------------------------------------------

test_that("product_code routes to /daily-prices/product", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_daily_prices(product_code = "LIME_XL"))
  expect_match(cap$path, "daily-prices/product")
})

test_that("product_code sends product_name param", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_daily_prices(product_code = "LIME_XL"))
  expect_true("product_name" %in% names(cap$params))
})

# --- Return value -----------------------------------------------------------

test_that("returns data.frame with rows when data exists", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_response(n = 7),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_daily_prices(category_code = "SHRIMP"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 7L)
})

test_that("returns empty data.frame when API returns no data", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_empty(),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_daily_prices(category_code = "SHRIMP"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0L)
})

# --- Date range filter ------------------------------------------------------

test_that("start_date / end_date filters results post-fetch", {
  # Mock returns 5 rows with data_date "2025-06-01"
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_response(n = 5, date = "2025-06-01"),
    .package = "talatThaiR"
  )
  # start_date after the data date → all rows filtered out
  result <- suppressMessages(
    get_daily_prices(
      category_code = "SHRIMP",
      start_date    = "2025-07-01",
      end_date      = "2025-12-31"
    )
  )
  expect_equal(nrow(result), 0L)
})

test_that("rows within date range are kept", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_response(n = 5, date = "2025-06-01"),
    .package = "talatThaiR"
  )
  result <- suppressMessages(
    get_daily_prices(
      category_code = "SHRIMP",
      start_date    = "2025-01-01",
      end_date      = "2025-12-31"
    )
  )
  expect_equal(nrow(result), 5L)
})
