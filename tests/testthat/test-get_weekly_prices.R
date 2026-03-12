# test-get_weekly_prices.R
# Tests for R/get_weekly_prices.R
# All network calls are mocked.

describe("get_weekly_prices() — input validation", {

  it("errors when no search filter is provided", {
    expect_error(get_weekly_prices())
  })

  it("errors when more than one exclusive filter is provided", {
    expect_error(
      get_weekly_prices(category_code = "SHRIMP", product_code = "EGG_MIXED")
    )
  })

  it("errors for an unknown category_code", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) stop("should not be called"),
      .package = "talatThaiR"
    )
    expect_error(
      get_weekly_prices(category_code = "INVALID_CAT"),
      regexp = "INVALID_CAT"
    )
  })

  it("errors for an unknown product_code", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) stop("should not be called"),
      .package = "talatThaiR"
    )
    expect_error(
      get_weekly_prices(product_code = "INVALID_PROD"),
      regexp = "INVALID_PROD"
    )
  })
})

describe("get_weekly_prices() — successful responses", {

  it("returns a data.frame for a category search", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_weekly_response(5),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_weekly_prices(category_code = "SHRIMP"))
    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
  })

  it("returns a data.frame for a product search", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_weekly_response(3),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_weekly_prices(product_code = "EGG_MIXED"))
    expect_s3_class(result, "data.frame")
  })

  it("unwraps responses with a 'data' key", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) list(data = mock_weekly_response(2)),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_weekly_prices(category_code = "SHRIMP", page = 1))
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 2L)
  })

  it("unwraps responses with an 'items' key", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) list(items = mock_weekly_response(3)),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_weekly_prices(category_code = "SHRIMP", page = 1))
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 3L)
  })
})

describe("get_weekly_prices() — year_th + month mode", {

  it("returns a data.frame when year_th and month are provided", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_weekly_response(4),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_weekly_prices(year_th = "2568", month = "01"))
    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
  })

  it("errors when only year_th is provided without month", {
    expect_error(get_weekly_prices(year_th = "2568"))
  })

  it("errors when only month is provided without year_th", {
    expect_error(get_weekly_prices(month = "01"))
  })
})

describe("get_weekly_prices() — pagination sweep mode", {

  it("collects data from multiple pages until an empty page", {
    call_count <- 0L
    local_mocked_bindings(
      .nabc_fetch_data = function(...) {
        call_count <<- call_count + 1L
        if (call_count <= 2L) mock_weekly_response(3) else data.frame()
      },
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_weekly_prices(category_code = "SHRIMP"))
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 6L)
  })

  it("returns an empty data.frame when the first page has no data", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) data.frame(),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_weekly_prices(category_code = "SHRIMP"))
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 0L)
  })
})
