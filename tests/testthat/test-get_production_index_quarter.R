# =============================================================================
# Tests: get_production_index_quarter()
# Note: product_code uses .QUARTER_PRODUCT_MAP (keys: "GARLIC", "ORCHID", ...)
# =============================================================================

# --- Validation: sector mode ------------------------------------------------

test_that("sector=TRUE with other params errors", {
  expect_error(
    get_production_index_quarter(sector = TRUE, category_code = "LIVESTOCK"),
    "sector = TRUE"
  )
  expect_error(
    get_production_index_quarter(sector = TRUE, year_th = 2568),
    "sector = TRUE"
  )
  expect_error(
    get_production_index_quarter(sector = TRUE, quarter = 1),
    "sector = TRUE"
  )
})

# --- Validation: primary mode -----------------------------------------------

test_that("errors when no input given", {
  expect_error(get_production_index_quarter(), "Please specify at least one")
})

test_that("errors when multiple primary modes given", {
  expect_error(
    get_production_index_quarter(category_code = "LIVESTOCK", group_code = "OIL_CROP"),
    "only one of"
  )
})

test_that("errors when quarter given without year_th in standalone mode", {
  expect_error(
    get_production_index_quarter(quarter = 1),
    "'quarter' requires 'year_th'"
  )
})

test_that("errors when year_th given without quarter in standalone mode", {
  expect_error(
    get_production_index_quarter(year_th = 2568),
    "'year_th' requires 'quarter'"
  )
})

test_that("errors on quarter out of range", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  expect_error(
    get_production_index_quarter(category_code = "LIVESTOCK", quarter = 0),
    "between 1 and 4"
  )
  expect_error(
    get_production_index_quarter(category_code = "LIVESTOCK", quarter = 5),
    "between 1 and 4"
  )
})

# --- Validation: code lookup ------------------------------------------------

test_that("errors on unknown codes", {
  expect_error(get_production_index_quarter(category_code = "UNKNOWN"),
               "Category code 'UNKNOWN' not found")
  expect_error(get_production_index_quarter(group_code = "UNKNOWN"),
               "Group code 'UNKNOWN' not found")
  # product_code uses .QUARTER_PRODUCT_MAP
  expect_error(get_production_index_quarter(product_code = "BANANA_HOM_THONG"),
               "Product code 'BANANA_HOM_THONG' not found")
})

# --- Routing ----------------------------------------------------------------

test_that("sector=TRUE routes to /sector", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_quarter(sector = TRUE))
  expect_match(cap$path, "production-index-quarter/sector")
  expect_false("quarter" %in% names(cap$params))
})

test_that("category_code routes to /category without quarter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_quarter(category_code = "LIVESTOCK"))
  expect_match(cap$path, "production-index-quarter/category")
  expect_true("product_category" %in% names(cap$params))
  expect_false("quarter" %in% names(cap$params))
})

test_that("category_code + quarter adds quarter filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_quarter(category_code = "LIVESTOCK", quarter = 2))
  expect_equal(cap$params$quarter, 2L)
})

test_that("group_code routes to /group", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_quarter(group_code = "OIL_CROP"))
  expect_match(cap$path, "production-index-quarter/group")
  expect_true("product_group" %in% names(cap$params))
})

test_that("group_code + quarter adds filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_quarter(group_code = "OIL_CROP", quarter = 3))
  expect_equal(cap$params$quarter, 3L)
})

test_that("product_code routes to /product using .QUARTER_PRODUCT_MAP", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_quarter(product_code = "GARLIC"))
  expect_match(cap$path, "production-index-quarter/product")
  expect_true("product_name" %in% names(cap$params))
})

test_that("year_th + quarter standalone routes to /all", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_quarter(year_th = 2568, quarter = 4))
  expect_match(cap$path, "production-index-quarter/all")
  expect_equal(cap$params$year_th, "2568")
  expect_equal(cap$params$quarter, 4L)
})

# --- Return value -----------------------------------------------------------

test_that("returns data.frame", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_response(n = 6),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_production_index_quarter(category_code = "LIVESTOCK"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 6L)
})

test_that("returns empty data.frame when no data", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_empty(),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_production_index_quarter(category_code = "LIVESTOCK"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0L)
})
