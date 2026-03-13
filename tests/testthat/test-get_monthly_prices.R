# =============================================================================
# Tests: get_monthly_prices()
# =============================================================================

# --- Validation -------------------------------------------------------------

test_that("errors when no input is given", {
  expect_error(get_monthly_prices(), "Please specify at least one")
})

test_that("errors when both category_code and product_code given", {
  expect_error(
    get_monthly_prices(category_code = "BUFFALO", product_code = "BUFFALO_M"),
    "not both"
  )
})

test_that("errors when month is given without year_th", {
  expect_error(
    get_monthly_prices(month = 6),
    "'month' cannot be used without 'year_th'"
  )
})

test_that("errors on unknown category_code", {
  expect_error(
    get_monthly_prices(category_code = "UNKNOWN"),
    "Category code 'UNKNOWN' not found"
  )
})

test_that("errors on unknown product_code", {
  expect_error(
    get_monthly_prices(product_code = "UNKNOWN"),
    "Product code 'UNKNOWN' not found"
  )
})

# NOTE: year_th alone (without month) is VALID — routes to /year-month
# with month=NULL. This is by design in the current implementation.
test_that("year_th alone does NOT error — routes to /year-month", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  expect_no_error(suppressMessages(get_monthly_prices(year_th = 2568)))
  expect_match(cap$path, "year-month")
})

# --- Routing: category mode -------------------------------------------------

test_that("category_code routes to /monthly-prices/commod", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_monthly_prices(category_code = "BUFFALO"))
  expect_match(cap$path, "monthly-prices/commod")
  expect_true("commod" %in% names(cap$params))
  expect_false("year_th" %in% names(cap$params))
  expect_false("month"   %in% names(cap$params))
})

test_that("category_code + year_th adds year_th filter only", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_monthly_prices(category_code = "BUFFALO", year_th = 2568))
  expect_match(cap$path, "commod")
  expect_equal(cap$params$year_th, "2568")
  expect_false("month" %in% names(cap$params))
})

test_that("category_code + year_th + month adds both filters", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_monthly_prices(category_code = "BUFFALO", year_th = 2568, month = 6))
  expect_equal(cap$params$year_th, "2568")
  expect_equal(cap$params$month,   "06")
})

# --- Routing: product mode --------------------------------------------------

test_that("product_code routes to /monthly-prices/product", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_monthly_prices(product_code = "BUFFALO_M"))
  expect_match(cap$path, "monthly-prices/product")
  expect_true("product_name" %in% names(cap$params))
})

test_that("product_code + year_th + month adds filters", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_monthly_prices(product_code = "BUFFALO_M", year_th = 2568, month = 3))
  expect_equal(cap$params$year_th, "2568")
  expect_equal(cap$params$month,   "03")
})

# --- Routing: year-month standalone mode ------------------------------------

test_that("year_th + month standalone routes to /monthly-prices/year-month", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_monthly_prices(year_th = 2568, month = 6))
  expect_match(cap$path, "monthly-prices/year-month")
  expect_equal(cap$params$year_th, "2568")
  expect_equal(cap$params$month,   "06")
})

test_that("month is zero-padded", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_monthly_prices(year_th = 2568, month = 2))
  expect_equal(cap$params$month, "02")
})

# --- Return value -----------------------------------------------------------

test_that("returns data.frame with correct rows", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_response(n = 8),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_monthly_prices(category_code = "BUFFALO"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 8L)
})

test_that("returns empty data.frame when no data", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_empty(),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_monthly_prices(category_code = "BUFFALO"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0L)
})
