# =============================================================================
# Tests: multi-page pagination
#
# Pattern ใช้ร่วมกันทุก function:
#   page1 → total=250, limit=100 → total_pages = 3
#   fn ถูกเรียก 3 ครั้ง (page 1, 2, 3)
#   ผลรวม nrow = 250
#
# Strategy: local_mocked_bindings กับ stateful counter
# เพราะ .nabc_fetch_data ถูกเรียกซ้ำหลายรอบ จึงต้องสร้าง fn ที่
# return response ที่แตกต่างกันตาม call count
# =============================================================================

# ---------------------------------------------------------------------------
# make_paged_fn(total, per_page)
# Returns a function that mimics .nabc_fetch_data across multiple pages.
# Call count is tracked via closure.
# ---------------------------------------------------------------------------
make_paged_fn <- function(total = 250L, per_page = 100L) {
  call_count <- 0L
  n_pages    <- ceiling(total / per_page)

  function(path, api_key = NULL, query_params = list()) {
    call_count <<- call_count + 1L
    p <- query_params$page
    if (is.null(p)) p <- call_count

    n_rows <- if (p < n_pages) per_page else (total - per_page * (n_pages - 1L))
    df     <- data.frame(
      data_date    = rep("2025-06-01", n_rows),
      year_th      = rep(2568L, n_rows),
      product_name = paste0("p", p, "_item", seq_len(n_rows)),
      price        = runif(n_rows),
      stringsAsFactors = FALSE
    )
    list(
      success    = TRUE,
      data       = df,
      pagination = list(
        total  = as.integer(total),
        limit  = as.integer(per_page),
        offset = as.integer((p - 1L) * per_page),
        page   = as.integer(p),
        count  = as.integer(n_rows)
      )
    )
  }
}

# ---------------------------------------------------------------------------
# Helpers that count how many times .nabc_fetch_data was called
# (attach counter to fn environment so we can inspect it)
# ---------------------------------------------------------------------------
make_counting_fn <- function(total = 250L, per_page = 100L) {
  env        <- new.env(parent = emptyenv())
  env$calls  <- 0L
  env$n_pages <- ceiling(total / per_page)
  base_fn    <- make_paged_fn(total, per_page)

  env$fn <- function(path, api_key = NULL, query_params = list()) {
    env$calls <- env$calls + 1L
    base_fn(path = path, api_key = api_key, query_params = query_params)
  }
  env
}

# =============================================================================
# get_daily_prices — uses .fetch_all_pages inside the function itself
# =============================================================================

test_that("get_daily_prices fetches all pages when total > limit", {
  env <- make_counting_fn(total = 250L)
  local_mocked_bindings(.nabc_fetch_data = env$fn, .package = "talatThaiR")
  result <- suppressMessages(get_daily_prices(category_code = "SHRIMP"))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 250L)
  expect_equal(env$calls, env$n_pages)   # 3 calls for 3 pages
})

test_that("get_daily_prices single-page result (total == limit)", {
  env <- make_counting_fn(total = 100L, per_page = 100L)
  local_mocked_bindings(.nabc_fetch_data = env$fn, .package = "talatThaiR")
  result <- suppressMessages(get_daily_prices(category_code = "SHRIMP"))
  expect_equal(nrow(result), 100L)
  expect_equal(env$calls, 1L)
})

# =============================================================================
# get_weekly_prices — uses .fetch_all_pages inside the function
# =============================================================================

test_that("get_weekly_prices fetches all pages when total > limit", {
  env <- make_counting_fn(total = 200L)
  local_mocked_bindings(.nabc_fetch_data = env$fn, .package = "talatThaiR")
  result <- suppressMessages(get_weekly_prices(category_code = "BUFFALO"))
  expect_equal(nrow(result), 200L)
  expect_equal(env$calls, 2L)
})

# =============================================================================
# get_monthly_prices — uses .fetch_all_pages inside the function
# =============================================================================

test_that("get_monthly_prices fetches all pages when total > limit", {
  env <- make_counting_fn(total = 320L)
  local_mocked_bindings(.nabc_fetch_data = env$fn, .package = "talatThaiR")
  result <- suppressMessages(get_monthly_prices(category_code = "BUFFALO"))
  expect_equal(nrow(result), 320L)
  expect_equal(env$calls, 4L)   # ceil(320/100) = 4 pages
})

# =============================================================================
# get_production_index_month — uses .pim_fetch_all (exported to namespace)
# =============================================================================

test_that("get_production_index_month fetches all pages when total > limit", {
  env <- make_counting_fn(total = 250L)
  local_mocked_bindings(.nabc_fetch_data = env$fn, .package = "talatThaiR")
  result <- suppressMessages(get_production_index_month(category_code = "LIVESTOCK"))
  expect_equal(nrow(result), 250L)
  expect_equal(env$calls, 3L)
})

# =============================================================================
# get_production_index_quarter — uses .piq_fetch_all
# =============================================================================

test_that("get_production_index_quarter fetches all pages when total > limit", {
  env <- make_counting_fn(total = 150L)
  local_mocked_bindings(.nabc_fetch_data = env$fn, .package = "talatThaiR")
  result <- suppressMessages(get_production_index_quarter(category_code = "LIVESTOCK"))
  expect_equal(nrow(result), 150L)
  expect_equal(env$calls, 2L)
})

# =============================================================================
# get_production_index_year — uses .piy_fetch_all
# =============================================================================

test_that("get_production_index_year fetches all pages when total > limit", {
  env <- make_counting_fn(total = 200L)
  local_mocked_bindings(.nabc_fetch_data = env$fn, .package = "talatThaiR")
  result <- suppressMessages(get_production_index_year(category_code = "LIVESTOCK"))
  expect_equal(nrow(result), 200L)
  expect_equal(env$calls, 2L)
})

# =============================================================================
# get_price_index_month — uses .priceim_fetch_all
# =============================================================================

test_that("get_price_index_month fetches all pages when total > limit", {
  env <- make_counting_fn(total = 250L)
  local_mocked_bindings(.nabc_fetch_data = env$fn, .package = "talatThaiR")
  result <- suppressMessages(get_price_index_month(category_code = "LIVESTOCK"))
  expect_equal(nrow(result), 250L)
  expect_equal(env$calls, 3L)
})

# =============================================================================
# get_price_index_quarter — uses .priceiq_fetch_all
# =============================================================================

test_that("get_price_index_quarter fetches all pages when total > limit", {
  env <- make_counting_fn(total = 130L)
  local_mocked_bindings(.nabc_fetch_data = env$fn, .package = "talatThaiR")
  result <- suppressMessages(get_price_index_quarter(category_code = "LIVESTOCK"))
  expect_equal(nrow(result), 130L)
  expect_equal(env$calls, 2L)
})

# =============================================================================
# get_price_index_year — uses .priceiy_fetch_all
# =============================================================================

test_that("get_price_index_year fetches all pages when total > limit", {
  env <- make_counting_fn(total = 100L, per_page = 100L)
  local_mocked_bindings(.nabc_fetch_data = env$fn, .package = "talatThaiR")
  result <- suppressMessages(get_price_index_year(category_code = "LIVESTOCK"))
  expect_equal(nrow(result), 100L)
  expect_equal(env$calls, 1L)   # exactly 1 page
})

# =============================================================================
# Partial failure: page 2 errors → warn + return partial data (page 1 only)
# This tests tryCatch inside all fetch_all helpers.
# =============================================================================

test_that("failed page 2 warns and returns partial data from page 1", {
  call_count <- 0L
  fail_fn <- function(path, api_key = NULL, query_params = list()) {
    call_count <<- call_count + 1L
    if (call_count == 1L) {
      # page 1: total=200 → signals 2 pages
      list(
        success    = TRUE,
        data       = data.frame(product_name = paste0("item_", 1:100), stringsAsFactors = FALSE),
        pagination = list(total = 200L, limit = 100L, offset = 0L, page = 1L, count = 100L)
      )
    } else {
      stop("simulated timeout on page 2")
    }
  }

  local_mocked_bindings(.nabc_fetch_data = fail_fn, .package = "talatThaiR")

  expect_warning(
    result <- suppressMessages(get_production_index_month(category_code = "LIVESTOCK")),
    "Failed to fetch page 2"
  )
  # Page 1 data should still be returned
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 100L)
})
