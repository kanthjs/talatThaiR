# test-get_monthly_prices.R
# Tests for R/get_monthly_prices.R
# All network calls are mocked.

describe("get_monthly_prices() — input validation", {

  it("errors when no search filter is provided", {
    expect_error(get_monthly_prices())
  })

  it("errors when more than one exclusive filter is provided", {
    expect_error(
      get_monthly_prices(category_code = "SHRIMP", product_code = "RUBBER_LIQUID")
    )
  })

  it("errors for an unknown category_code", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) stop("should not be called"),
      .package = "talatThaiR"
    )
    expect_error(
      get_monthly_prices(category_code = "INVALID_MONTHLY_CAT")
    )
  })

  it("errors for an unknown product_code", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) stop("should not be called"),
      .package = "talatThaiR"
    )
    expect_error(
      get_monthly_prices(product_code = "INVALID_MONTHLY_PROD")
    )
  })

  it("errors when only year_th is provided without month", {
    expect_error(get_monthly_prices(year_th = "2568"))
  })
})

describe("get_monthly_prices() — year_th + month mode", {

  it("returns a data.frame when year_th and month are provided", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_monthly_response(3),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_monthly_prices(year_th = "2568", month = "06"))
    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
  })
})

describe("get_monthly_prices() — single-page mode (page =)", {

  it("returns a data.frame when page is specified", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_monthly_response(6),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_monthly_prices(category_code = "SHRIMP", page = 1))
    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
  })

  it("unwraps responses with a 'data' key", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) list(data = mock_monthly_response(4)),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_monthly_prices(product_code = "RUBBER_LIQUID_MIX", page = 1))
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 4L)
  })

  it("unwraps responses with an 'items' key", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) list(items = mock_monthly_response(2)),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_monthly_prices(category_code = "SHRIMP", page = 1))
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 2L)
  })
})

describe("get_monthly_prices() — pagination sweep mode", {

  it("returns a data.frame for a valid category", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_monthly_response(6),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_monthly_prices(category_code = "SHRIMP"))
    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
  })

  it("returns a data.frame for a valid product", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_monthly_response(4),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_monthly_prices(product_code = "RUBBER_LIQUID"))
    expect_s3_class(result, "data.frame")
  })

  it("collects data from multiple pages until an empty page", {
    call_count <- 0L
    withr::local_options(talatThaiR.max_pages = 10L)
    local_mocked_bindings(
      .nabc_fetch_data = function(...) {
        call_count <<- call_count + 1L
        if (call_count <= 2L) mock_monthly_response(3) else data.frame()
      },
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_monthly_prices(category_code = "SHRIMP"))
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 6L)
  })

  it("returns an empty data.frame when no data is found", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) data.frame(),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_monthly_prices(category_code = "SHRIMP"))
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 0L)
  })
})
