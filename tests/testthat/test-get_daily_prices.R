# test-get_daily_prices.R
# Tests for R/get_daily_prices.R
# All network calls are mocked via local_mocked_bindings() so these tests
# never touch the real NABC API.

describe("get_daily_prices() — input validation", {

  it("errors when no search filter is provided", {
    expect_error(
      get_daily_prices(),
      regexp = NULL   # Any error is acceptable
    )
  })

  it("errors when more than one exclusive filter is provided", {
    expect_error(
      get_daily_prices(category_code = "RICE_MALI", product_code = "LIME_XL")
    )
  })

  it("errors for an unknown category_code", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) stop("should not be called"),
      .package = "talatThaiR"
    )
    expect_error(
      get_daily_prices(category_code = "NOT_A_REAL_CODE"),
      regexp = "NOT_A_REAL_CODE"
    )
  })

  it("errors for an unknown product_code", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) stop("should not be called"),
      .package = "talatThaiR"
    )
    expect_error(
      get_daily_prices(product_code = "NOT_A_REAL_PRODUCT"),
      regexp = "NOT_A_REAL_PRODUCT"
    )
  })

  it("warns and ignores start_date when date is also provided", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_daily_response(2),
      .package = "talatThaiR"
    )
    expect_warning(
      suppress_msgs(
        get_daily_prices(date = "2025-01-15", start_date = "2025-01-01")
      )
    )
  })

  it("errors when start_date is after end_date", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_daily_response(2),
      .package = "talatThaiR"
    )
    expect_error(
      suppress_msgs(
        get_daily_prices(
          category_code = "RICE_MALI",
          start_date = "2025-12-31",
          end_date   = "2025-01-01"
        )
      )
    )
  })
})

describe("get_daily_prices() — single-page mode (date =)", {

  it("returns a data.frame when given a specific date", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_daily_response(3),
      .package = "talatThaiR"
    )
    result <- get_daily_prices(date = "2025-06-01")
    expect_s3_class(result, "data.frame")
  })

  it("returns a data.frame when given a specific page", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) mock_daily_response(3),
      .package = "talatThaiR"
    )
    result <- get_daily_prices(category_code = "RICE_MALI", page = 1)
    expect_s3_class(result, "data.frame")
  })

  it("unwraps list responses that have a 'data' key", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) list(data = mock_daily_response(2)),
      .package = "talatThaiR"
    )
    result <- get_daily_prices(date = "2025-06-01")
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 2L)
  })

  it("unwraps list responses that have an 'items' key", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) list(items = mock_daily_response(4)),
      .package = "talatThaiR"
    )
    result <- get_daily_prices(date = "2025-06-01")
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 4L)
  })
})

describe("get_daily_prices() — date-range / pagination mode", {

  it("returns a data.frame for a valid date range", {
    call_count <- 0L
    local_mocked_bindings(
      .nabc_fetch_data = function(...) {
        call_count <<- call_count + 1L
        # Second call returns an old date so the loop stops
        if (call_count == 1L) {
          mock_daily_response(3)
        } else {
          data.frame(
            date         = as.character(as.Date("2024-12-01")),
            product_name = "Old",
            price        = 5,
            unit         = "baht/kg",
            stringsAsFactors = FALSE
          )
        }
      },
      .package = "talatThaiR"
    )

    result <- suppress_msgs(
      get_daily_prices(
        category_code = "RICE_MALI",
        start_date    = format(Sys.Date() - 5),
        end_date      = format(Sys.Date())
      )
    )

    expect_s3_class(result, "data.frame")
  })

  it("returns an empty data.frame when no data falls in the range", {
    local_mocked_bindings(
      .nabc_fetch_data = function(...) {
        data.frame(
          date         = as.character(as.Date("2024-01-01")),
          product_name = "Old",
          price        = 5,
          unit         = "baht/kg",
          stringsAsFactors = FALSE
        )
      },
      .package = "talatThaiR"
    )
    result <- suppress_msgs(
      get_daily_prices(
        category_code = "RICE_MALI",
        start_date    = "2025-06-01",
        end_date      = "2025-06-30"
      )
    )
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 0L)
  })
})
