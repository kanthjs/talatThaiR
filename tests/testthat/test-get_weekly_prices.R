# =============================================================================
# Tests: get_weekly_prices()
# =============================================================================

# --- Validation -------------------------------------------------------------

test_that("errors when no input is given", {
  expect_error(get_weekly_prices(), "Please specify at least one")
})

test_that("errors when both category_code and product_code given", {
  expect_error(
    get_weekly_prices(category_code = "BUFFALO", product_code = "BUFFALO_M"),
    "not both"
  )
})

test_that("errors when year_th given without month", {
  expect_error(get_weekly_prices(year_th = 2568), "must be specified together")
})

test_that("errors when month given without year_th", {
  expect_error(get_weekly_prices(month = 6), "must be specified together")
})

test_that("errors on unknown category_code", {
  expect_error(
    get_weekly_prices(category_code = "UNKNOWN"),
    "Category code 'UNKNOWN' not found"
  )
})

test_that("errors on unknown product_code", {
  expect_error(
    get_weekly_prices(product_code = "UNKNOWN"),
    "Product code 'UNKNOWN' not found"
  )
})

# --- Routing: category mode -------------------------------------------------

test_that("category_code routes to /weekly-prices/commod", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_weekly_prices(category_code = "BUFFALO"))
  expect_match(cap$path, "weekly-prices/commod")
  expect_true("commod" %in% names(cap$params))
  expect_false("year_th" %in% names(cap$params))
})

test_that("category_code + year_th + month adds filter params to /commod", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_weekly_prices(category_code = "BUFFALO", year_th = 2568, month = 6))
  expect_match(cap$path, "commod")
  expect_equal(cap$params$year_th, "2568")
  expect_equal(cap$params$month,   "06")
})

# --- Routing: product mode --------------------------------------------------

test_that("product_code routes to /weekly-prices/product", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_weekly_prices(product_code = "BUFFALO_M"))
  expect_match(cap$path, "weekly-prices/product")
  expect_true("product_name" %in% names(cap$params))
  expect_false("year_th" %in% names(cap$params))
})

test_that("product_code + year_th + month adds filter params", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_weekly_prices(product_code = "BUFFALO_M", year_th = 2568, month = 3))
  expect_equal(cap$params$year_th, "2568")
  expect_equal(cap$params$month,   "03")
})

# --- Routing: year-month mode -----------------------------------------------

test_that("year_th + month routes to /weekly-prices/year-month", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_weekly_prices(year_th = 2568, month = 6))
  expect_match(cap$path, "weekly-prices/year-month")
  expect_equal(cap$params$year_th, "2568")
  expect_equal(cap$params$month,   "06")
})

test_that("month is zero-padded to two digits", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_weekly_prices(year_th = 2568, month = 1))
  expect_equal(cap$params$month, "01")
})

# --- Return value -----------------------------------------------------------

test_that("returns data.frame with correct row count", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_response(n = 6),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_weekly_prices(category_code = "BUFFALO"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 6L)
})

test_that("returns empty data.frame when no data", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_empty(),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_weekly_prices(category_code = "BUFFALO"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0L)
})
