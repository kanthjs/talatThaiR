# test-get_price_index_month.R
# Tests for R/get_price_index_month.R
# All network calls are mocked.

describe("get_price_index_month() — input validation", {

  it("errors when no filter is provided", {
    expect_error(get_price_index_month())
  })

  it("errors for an unknown product_code", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) stop("should not be called"),
      .package = "talatThaiR"
    )
    expect_error(
      get_price_index_month(product_code = "INVALID_IDX_PROD")
    )
  })

  it("errors for an unknown group_code", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) stop("should not be called"),
      .package = "talatThaiR"
    )
    expect_error(
      get_price_index_month(group_code = "INVALID_GROUP")
    )
  })

  it("errors for an unknown category_code", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) stop("should not be called"),
      .package = "talatThaiR"
    )
    expect_error(
      get_price_index_month(category_code = "INVALID_CAT")
    )
  })

  it("errors when more than one filter is provided", {
    expect_error(
      get_price_index_month(product_code = "SHRIMP_70", group_code = "FISHERY")
    )
  })
})

describe("get_price_index_month() — successful responses", {

  it("returns a data.frame for a valid product", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_index_response(4),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_price_index_month(product_code = "SHRIMP_70"))
    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
  })

  it("returns a data.frame for a valid group", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_index_response(3),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_price_index_month(group_code = "FISHERY"))
    expect_s3_class(result, "data.frame")
  })

  it("returns a data.frame for a valid category", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_index_response(3),
      .package = "talatThaiR"
    )
    result <- suppress_msgs(get_price_index_month(category_code = "FISHERY"))
    expect_s3_class(result, "data.frame")
  })
})
