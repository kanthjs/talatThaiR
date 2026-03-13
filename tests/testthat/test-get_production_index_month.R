# =============================================================================
# Tests: get_production_index_month()
# =============================================================================

# --- Validation: sector mode ------------------------------------------------

test_that("sector=TRUE with any other param errors", {
  expect_error(
    get_production_index_month(sector = TRUE, category_code = "LIVESTOCK"),
    "sector = TRUE"
  )
  expect_error(
    get_production_index_month(sector = TRUE, group_code = "OIL_CROP"),
    "sector = TRUE"
  )
  expect_error(
    get_production_index_month(sector = TRUE, product_code = "GARLIC_DRY_MIX"),
    "sector = TRUE"
  )
  expect_error(
    get_production_index_month(sector = TRUE, year_th = 2568),
    "sector = TRUE"
  )
  expect_error(
    get_production_index_month(sector = TRUE, month = 1),
    "sector = TRUE"
  )
})

# --- Validation: primary mode -----------------------------------------------

test_that("errors when no input given", {
  expect_error(
    get_production_index_month(),
    "Please specify at least one"
  )
})

test_that("errors when multiple primary modes given", {
  expect_error(
    get_production_index_month(category_code = "LIVESTOCK", group_code = "OIL_CROP"),
    "only one of"
  )
  expect_error(
    get_production_index_month(category_code = "LIVESTOCK", product_code = "GARLIC_DRY_MIX"),
    "only one of"
  )
  expect_error(
    get_production_index_month(group_code = "OIL_CROP", product_code = "GARLIC_DRY_MIX"),
    "only one of"
  )
})

test_that("errors when month given without year_th in standalone mode", {
  expect_error(
    get_production_index_month(month = 1),
    "'month' requires 'year_th'"
  )
})

test_that("errors when year_th given without month in standalone mode", {
  expect_error(
    get_production_index_month(year_th = 2568),
    "'year_th' requires 'month'"
  )
})

# --- Validation: code lookup ------------------------------------------------

test_that("errors on unknown category_code", {
  expect_error(
    get_production_index_month(category_code = "UNKNOWN"),
    "Category code 'UNKNOWN' not found"
  )
})

test_that("errors on unknown group_code", {
  expect_error(
    get_production_index_month(group_code = "UNKNOWN"),
    "Group code 'UNKNOWN' not found"
  )
})

test_that("errors on unknown product_code", {
  expect_error(
    get_production_index_month(product_code = "UNKNOWN"),
    "Product code 'UNKNOWN' not found"
  )
})

# --- Routing ----------------------------------------------------------------

test_that("sector=TRUE routes to /sector", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_month(sector = TRUE))
  expect_match(cap$path, "production-index-month/sector")
})

test_that("category_code routes to /category with product_category param", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_month(category_code = "LIVESTOCK"))
  expect_match(cap$path, "production-index-month/category")
  expect_true("product_category" %in% names(cap$params))
  expect_false("month" %in% names(cap$params))
})

test_that("category_code + month adds month filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_month(category_code = "LIVESTOCK", month = 3))
  expect_match(cap$path, "category")
  expect_equal(cap$params$month, "03")
})

test_that("group_code routes to /group with product_group param", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_month(group_code = "OIL_CROP"))
  expect_match(cap$path, "production-index-month/group")
  expect_true("product_group" %in% names(cap$params))
})

test_that("group_code + month adds month filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_month(group_code = "OIL_CROP", month = 6))
  expect_equal(cap$params$month, "06")
})

test_that("product_code routes to /product using .INDEX_PRODUCT_MAP", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_month(product_code = "GARLIC_DRY_MIX"))
  expect_match(cap$path, "production-index-month/product")
  expect_true("product_name" %in% names(cap$params))
})

test_that("year_th + month standalone routes to /all", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_month(year_th = 2568, month = 12))
  expect_match(cap$path, "production-index-month/all")
  expect_equal(cap$params$year_th, "2568")
  expect_equal(cap$params$month,   "12")
})

test_that("month is zero-padded to two digits", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_month(category_code = "LIVESTOCK", month = 1))
  expect_equal(cap$params$month, "01")
})

# --- Return value -----------------------------------------------------------

test_that("returns data.frame", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_response(n = 5),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_production_index_month(category_code = "LIVESTOCK"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 5L)
})

test_that("returns empty data.frame when no data", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_empty(),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_production_index_month(category_code = "LIVESTOCK"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0L)
})