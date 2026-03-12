# test-get_price_index_quarter.R
# Tests for R/get_price_index_quarter.R
# All network calls are mocked.

describe("get_price_index_quarter() — input validation", {

  it("errors when no filter is provided", {
    expect_error(get_price_index_quarter())
  })

  it("errors for an unknown product_code", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) stop("should not be called"),
      .package = "talatThaiR"
    )
    expect_error(
      get_price_index_quarter(product_code = "INVALID_QTR_PROD")
    )
  })

  it("errors for an unknown group_code", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) stop("should not be called"),
      .package = "talatThaiR"
    )
    expect_error(
      get_price_index_quarter(group_code = "INVALID_QTR_GROUP")
    )
  })

  it("errors when more than one filter is provided", {
    expect_error(
      get_price_index_quarter(product_code = "RUBBER", group_code = "FRUIT")
    )
  })
})

describe("get_price_index_quarter() — successful responses", {

  it("returns a data.frame for a valid product", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_index_response(4),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_price_index_quarter(product_code = "RUBBER"))
    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
  })

  it("returns a data.frame for a valid group", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_index_response(4),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_price_index_quarter(group_code = "FRUIT"))
    expect_s3_class(result, "data.frame")
  })
})
