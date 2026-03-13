# =============================================================================
# Tests: get_production_index_year()
# - sector=TRUE can combine with year_th (filter)
# - year_th can combine with any primary mode (filter)
# - year_th alone → /all (standalone)
# - product_code uses .QUARTER_PRODUCT_MAP
# =============================================================================

# --- Validation -------------------------------------------------------------

test_that("errors when no input given", {
  expect_error(get_production_index_year(), "Please specify at least one")
})

test_that("errors when multiple primary modes given", {
  expect_error(
    get_production_index_year(category_code = "LIVESTOCK", group_code = "OIL_CROP"),
    "only one of"
  )
  expect_error(
    get_production_index_year(category_code = "LIVESTOCK", product_code = "GARLIC"),
    "only one of"
  )
})

test_that("errors on unknown codes", {
  expect_error(get_production_index_year(category_code = "UNKNOWN"),
               "Category code 'UNKNOWN' not found")
  expect_error(get_production_index_year(group_code = "UNKNOWN"),
               "Group code 'UNKNOWN' not found")
  # product_code uses .QUARTER_PRODUCT_MAP
  expect_error(get_production_index_year(product_code = "BANANA_HOM_THONG"),
               "Product code 'BANANA_HOM_THONG' not found")
})

# --- Routing: sector mode ---------------------------------------------------

test_that("sector=TRUE routes to /sector without year_th", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_year(sector = TRUE))
  expect_match(cap$path, "production-index-year/sector")
  expect_false("year_th" %in% names(cap$params))
})

test_that("sector=TRUE + year_th appends year_th filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_year(sector = TRUE, year_th = 2567))
  expect_match(cap$path, "sector")
  expect_equal(cap$params$year_th, "2567")
})

# --- Routing: primary modes -------------------------------------------------

test_that("category_code routes to /category", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_year(category_code = "LIVESTOCK"))
  expect_match(cap$path, "production-index-year/category")
  expect_true("product_category" %in% names(cap$params))
  expect_false("year_th" %in% names(cap$params))
})

test_that("category_code + year_th adds year_th filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_year(category_code = "LIVESTOCK", year_th = 2567))
  expect_equal(cap$params$year_th, "2567")
})

test_that("group_code routes to /group", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_year(group_code = "OIL_CROP"))
  expect_match(cap$path, "production-index-year/group")
  expect_true("product_group" %in% names(cap$params))
})

test_that("group_code + year_th adds filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_year(group_code = "OIL_CROP", year_th = 2567))
  expect_equal(cap$params$year_th, "2567")
})

test_that("product_code routes to /product using .QUARTER_PRODUCT_MAP", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_year(product_code = "GARLIC"))
  expect_match(cap$path, "production-index-year/product")
  expect_true("product_name" %in% names(cap$params))
})

test_that("product_code + year_th adds filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_year(product_code = "GARLIC", year_th = 2567))
  expect_equal(cap$params$year_th, "2567")
})

test_that("year_th alone routes to /all", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_production_index_year(year_th = 2568))
  expect_match(cap$path, "production-index-year/all")
  expect_equal(cap$params$year_th, "2568")
})

# --- Return value -----------------------------------------------------------

test_that("returns data.frame", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_response(n = 4),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_production_index_year(category_code = "LIVESTOCK"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 4L)
})

test_that("returns empty data.frame when no data", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_empty(),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_production_index_year(year_th = 2568))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0L)
})
