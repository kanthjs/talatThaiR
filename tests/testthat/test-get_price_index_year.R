# =============================================================================
# Tests: get_price_index_year()
# - sector=TRUE can combine with year_th
# - year_th alone → /all (standalone)
# - cat/group/prod can each combine with year_th (optional filter)
# - product_code uses .INDEX_PRODUCT_MAP
# =============================================================================

# --- Validation -------------------------------------------------------------

test_that("errors when no input given", {
  expect_error(get_price_index_year(), "Please specify at least one")
})

test_that("errors when multiple primary codes given", {
  expect_error(
    get_price_index_year(category_code = "LIVESTOCK", group_code = "OIL_CROP"),
    "only one of"
  )
  expect_error(
    get_price_index_year(group_code = "OIL_CROP", product_code = "GARLIC_DRY_MIX"),
    "only one of"
  )
})

test_that("errors on unknown codes", {
  expect_error(get_price_index_year(category_code = "UNKNOWN"),
               "Category code 'UNKNOWN' not found")
  expect_error(get_price_index_year(group_code = "UNKNOWN"),
               "Group code 'UNKNOWN' not found")
  # product uses .INDEX_PRODUCT_MAP — GARLIC is NOT in that map
  expect_error(get_price_index_year(product_code = "GARLIC"),
               "Product code 'GARLIC' not found")
})

# --- Routing: sector mode ---------------------------------------------------

test_that("sector=TRUE routes to /sector without year_th", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_year(sector = TRUE))
  expect_match(cap$path, "price-index-year/sector")
  expect_false("year_th" %in% names(cap$params))
})

test_that("sector=TRUE + year_th appends filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_year(sector = TRUE, year_th = 2567))
  expect_match(cap$path, "sector")
  expect_equal(cap$params$year_th, "2567")
})

# --- Routing: category mode -------------------------------------------------

test_that("category_code routes to /category without year_th", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_year(category_code = "LIVESTOCK"))
  expect_match(cap$path, "price-index-year/category")
  expect_true("product_category" %in% names(cap$params))
  expect_false("year_th" %in% names(cap$params))
})

test_that("category_code + year_th adds year_th filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_year(category_code = "LIVESTOCK", year_th = 2567))
  expect_equal(cap$params$year_th, "2567")
})

# --- Routing: group mode ----------------------------------------------------

test_that("group_code routes to /group", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_year(group_code = "OIL_CROP"))
  expect_match(cap$path, "price-index-year/group")
  expect_true("product_group" %in% names(cap$params))
})

test_that("group_code + year_th adds filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_year(group_code = "OIL_CROP", year_th = 2567))
  expect_equal(cap$params$year_th, "2567")
})

# --- Routing: product mode --------------------------------------------------

test_that("product_code routes to /product using .INDEX_PRODUCT_MAP", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_year(product_code = "GARLIC_DRY_MIX"))
  expect_match(cap$path, "price-index-year/product")
  expect_true("product_name" %in% names(cap$params))
})

test_that("product_code + year_th adds filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_year(product_code = "GARLIC_DRY_MIX", year_th = 2567))
  expect_equal(cap$params$year_th, "2567")
})

# --- Routing: year standalone -----------------------------------------------

test_that("year_th alone routes to /all", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_year(year_th = 2568))
  expect_match(cap$path, "price-index-year/all")
  expect_equal(cap$params$year_th, "2568")
})

# --- Return value -----------------------------------------------------------

test_that("returns data.frame", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_response(n = 7),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_price_index_year(category_code = "LIVESTOCK"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 7L)
})

test_that("returns empty data.frame when no data", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_empty(),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_price_index_year(year_th = 2568))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0L)
})
