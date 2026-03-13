# =============================================================================
# Tests: get_price_index_quarter()
# - sector=TRUE can combine with year_th
# - cat/group/prod can combine with year_th and/or quarter
# - quarter alone (without primary mode or year_th) → error
# - year_th alone (without primary mode or sector) → error
# - product_code uses .INDEX_PRODUCT_MAP (NOT .QUARTER_PRODUCT_MAP)
# =============================================================================

# --- Validation -------------------------------------------------------------

test_that("errors when no input given", {
  expect_error(get_price_index_quarter(), "Please specify at least one")
})

test_that("errors when multiple primary codes given", {
  expect_error(
    get_price_index_quarter(category_code = "LIVESTOCK", group_code = "OIL_CROP"),
    "only one of"
  )
})

test_that("errors when quarter given without year_th in standalone mode", {
  expect_error(
    get_price_index_quarter(quarter = 1),
    "'quarter' requires 'year_th'"
  )
})

test_that("errors when year_th alone without primary mode or sector", {
  expect_error(
    get_price_index_quarter(year_th = 2568),
    "'year_th' alone requires 'quarter'"
  )
})

test_that("errors on quarter out of range", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  expect_error(
    get_price_index_quarter(category_code = "LIVESTOCK", quarter = 0),
    "between 1 and 4"
  )
  expect_error(
    get_price_index_quarter(category_code = "LIVESTOCK", quarter = 5),
    "between 1 and 4"
  )
})

test_that("errors on unknown codes", {
  expect_error(get_price_index_quarter(category_code = "UNKNOWN"),
               "Category code 'UNKNOWN' not found")
  expect_error(get_price_index_quarter(group_code = "UNKNOWN"),
               "Group code 'UNKNOWN' not found")
  # product_code uses .INDEX_PRODUCT_MAP — GARLIC is NOT in that map
  expect_error(get_price_index_quarter(product_code = "GARLIC"),
               "Product code 'GARLIC' not found")
})

# --- Routing: sector mode ---------------------------------------------------

test_that("sector=TRUE routes to /sector", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_quarter(sector = TRUE))
  expect_match(cap$path, "price-index-quarter/sector")
  expect_false("year_th" %in% names(cap$params))
})

test_that("sector=TRUE + year_th appends year_th", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_quarter(sector = TRUE, year_th = 2567))
  expect_equal(cap$params$year_th, "2567")
})

# --- Routing: category mode -------------------------------------------------

test_that("category_code routes to /category without filters", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_quarter(category_code = "LIVESTOCK"))
  expect_match(cap$path, "price-index-quarter/category")
  expect_false("year_th" %in% names(cap$params))
  expect_false("quarter" %in% names(cap$params))
})

test_that("category_code + year_th adds year_th", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_quarter(category_code = "LIVESTOCK", year_th = 2567))
  expect_equal(cap$params$year_th, "2567")
  expect_false("quarter" %in% names(cap$params))
})

test_that("category_code + quarter adds quarter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_quarter(category_code = "LIVESTOCK", quarter = 2))
  expect_equal(cap$params$quarter, 2L)
  expect_false("year_th" %in% names(cap$params))
})

test_that("category_code + year_th + quarter adds both", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_quarter(category_code = "LIVESTOCK", year_th = 2567, quarter = 1))
  expect_equal(cap$params$year_th, "2567")
  expect_equal(cap$params$quarter, 1L)
})

# --- Routing: group mode ----------------------------------------------------

test_that("group_code routes to /group", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_quarter(group_code = "OIL_CROP"))
  expect_match(cap$path, "price-index-quarter/group")
  expect_true("product_group" %in% names(cap$params))
})

# --- Routing: product mode --------------------------------------------------

test_that("product_code routes to /product using .INDEX_PRODUCT_MAP", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_quarter(product_code = "GARLIC_DRY_MIX"))
  expect_match(cap$path, "price-index-quarter/product")
  expect_true("product_name" %in% names(cap$params))
})

# --- Routing: year-quarter standalone ---------------------------------------

test_that("year_th + quarter standalone routes to /all", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_quarter(year_th = 2568, quarter = 4))
  expect_match(cap$path, "price-index-quarter/all")
  expect_equal(cap$params$year_th, "2568")
  expect_equal(cap$params$quarter, 4L)
})

# --- Return value -----------------------------------------------------------

test_that("returns data.frame", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_response(n = 5),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_price_index_quarter(category_code = "LIVESTOCK"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 5L)
})

test_that("returns empty data.frame when no data", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_empty(),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_price_index_quarter(category_code = "LIVESTOCK"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0L)
})
