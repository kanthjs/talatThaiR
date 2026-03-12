# test-get_price_index_year.R
# Tests for R/get_price_index_year.R
# All network calls are mocked.

describe("get_price_index_year() — input validation", {

  it("errors when no filter is provided", {
    expect_error(get_price_index_year())
  })

  it("errors for an unknown product_code", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) stop("should not be called"),
      .package = "talatThaiR"
    )
    expect_error(
      get_price_index_year(product_code = "INVALID_YR_PROD")
    )
  })

  it("errors for an unknown group_code", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) stop("should not be called"),
      .package = "talatThaiR"
    )
    expect_error(
      get_price_index_year(group_code = "INVALID_YR_GROUP")
    )
  })

  it("errors when more than one filter is provided", {
    expect_error(
      get_price_index_year(product_code = "CASSAVA", group_code = "LIVESTOCK")
    )
  })
})

describe("get_price_index_year() — successful responses", {

  it("returns a data.frame for a valid product", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_index_response(5),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_price_index_year(product_code = "CASSAVA"))
    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
  })

  it("returns a data.frame for a valid group", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_index_response(3),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_price_index_year(group_code = "LIVESTOCK"))
    expect_s3_class(result, "data.frame")
  })
})
