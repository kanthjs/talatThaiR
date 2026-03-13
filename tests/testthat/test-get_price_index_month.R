# =============================================================================
# Tests: get_price_index_month()
# - sector=TRUE can combine with year_th
# - cat/group/prod can combine with year_th and/or month
# - month alone (without primary mode or year_th) → error
# - year_th alone (without primary mode or sector) → error
# - product_code uses .INDEX_PRODUCT_MAP (keys: "GARLIC_DRY_MIX", ...)
# =============================================================================

# --- Validation -------------------------------------------------------------

test_that("errors when no input given", {
  expect_error(get_price_index_month(), "Please specify at least one")
})

test_that("errors when multiple primary codes given", {
  expect_error(
    get_price_index_month(category_code = "LIVESTOCK", group_code = "OIL_CROP"),
    "only one of"
  )
})

test_that("errors when month given without year_th in standalone mode", {
  expect_error(
    get_price_index_month(month = 1),
    "'month' requires 'year_th'"
  )
})

test_that("errors when year_th alone without primary mode or sector", {
  expect_error(
    get_price_index_month(year_th = 2568),
    "'year_th' alone requires 'month'"
  )
})

test_that("errors on unknown codes", {
  expect_error(get_price_index_month(category_code = "UNKNOWN"),
               "Category code 'UNKNOWN' not found")
  expect_error(get_price_index_month(group_code = "UNKNOWN"),
               "Group code 'UNKNOWN' not found")
  expect_error(get_price_index_month(product_code = "UNKNOWN"),
               "Product code 'UNKNOWN' not found")
})

# --- Routing: sector mode ---------------------------------------------------

test_that("sector=TRUE routes to /sector without filters", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_month(sector = TRUE))
  expect_match(cap$path, "price-index-month/sector")
  expect_false("year_th" %in% names(cap$params))
})

test_that("sector=TRUE + year_th appends year_th", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_month(sector = TRUE, year_th = 2567))
  expect_equal(cap$params$year_th, "2567")
})

# sector=TRUE + year_th is valid, but sector=TRUE + month alone requires year_th
test_that("sector=TRUE does not error when combined with year_th", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  expect_no_error(suppressMessages(get_price_index_month(sector = TRUE, year_th = 2567)))
})

# --- Routing: category mode -------------------------------------------------

test_that("category_code routes to /category with product_category", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_month(category_code = "LIVESTOCK"))
  expect_match(cap$path, "price-index-month/category")
  expect_true("product_category" %in% names(cap$params))
  expect_false("year_th" %in% names(cap$params))
  expect_false("month"   %in% names(cap$params))
})

test_that("category_code + year_th adds year_th filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_month(category_code = "LIVESTOCK", year_th = 2567))
  expect_equal(cap$params$year_th, "2567")
  expect_false("month" %in% names(cap$params))
})

test_that("category_code + month adds month filter", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_month(category_code = "LIVESTOCK", month = 1))
  expect_equal(cap$params$month, "01")
  expect_false("year_th" %in% names(cap$params))
})

test_that("category_code + year_th + month adds both filters", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_month(category_code = "LIVESTOCK", year_th = 2567, month = 6))
  expect_equal(cap$params$year_th, "2567")
  expect_equal(cap$params$month,   "06")
})

# --- Routing: group mode ----------------------------------------------------

test_that("group_code routes to /group", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_month(group_code = "OIL_CROP"))
  expect_match(cap$path, "price-index-month/group")
  expect_true("product_group" %in% names(cap$params))
})

test_that("group_code + year_th + month adds both filters", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_month(group_code = "OIL_CROP", year_th = 2567, month = 3))
  expect_equal(cap$params$year_th, "2567")
  expect_equal(cap$params$month,   "03")
})

# --- Routing: product mode --------------------------------------------------

test_that("product_code routes to /product using .INDEX_PRODUCT_MAP", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_month(product_code = "GARLIC_DRY_MIX"))
  expect_match(cap$path, "price-index-month/product")
  expect_true("product_name" %in% names(cap$params))
})

# --- Routing: year-month standalone -----------------------------------------

test_that("year_th + month standalone routes to /all", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_month(year_th = 2568, month = 12))
  expect_match(cap$path, "price-index-month/all")
  expect_equal(cap$params$year_th, "2568")
  expect_equal(cap$params$month,   "12")
})

test_that("month is zero-padded", {
  cap <- make_capture()
  local_mocked_bindings(.nabc_fetch_data = cap$fn, .package = "talatThaiR")
  suppressMessages(get_price_index_month(year_th = 2568, month = 3))
  expect_equal(cap$params$month, "03")
})

# --- Return value -----------------------------------------------------------

test_that("returns data.frame", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_response(n = 5),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_price_index_month(category_code = "LIVESTOCK"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 5L)
})

test_that("returns empty data.frame when no data", {
  local_mocked_bindings(
    .nabc_fetch_data = function(...) make_empty(),
    .package = "talatThaiR"
  )
  result <- suppressMessages(get_price_index_month(sector = TRUE))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0L)
})
