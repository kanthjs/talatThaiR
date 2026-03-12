# test-utils.R
# Tests for R/utils.R (.nabc_fetch_data internal helper)
# Tests network-error handling and header logic via mocking.

describe(".nabc_fetch_data() — error handling", {

  it("stops with an informative message on HTTP errors", {
    # Create a minimal mock httr response that signals an HTTP error
    mock_response <- structure(
      list(status_code = 401L, url = "https://agriapi.nabc.go.th/api/test"),
      class = "response"
    )

    local_mocked_bindings(
      GET        = function(...) mock_response,
      http_error = function(x) TRUE,
      status_code = function(x) x$status_code,
      .package   = "httr"
    )

    expect_error(
      talatThaiR:::.nabc_fetch_data(path = "api/test"),
      regexp = "401"
    )
  })

  it("passes the Authorization header when api_key is provided", {
    captured_headers <- NULL

    local_mocked_bindings(
      GET = function(url, ...) {
        dots <- list(...)
        # httr::add_headers() result is stored in dots; capture it for inspection
        captured_headers <<- dots
        structure(
          list(status_code = 200L, content = chartr("","","{}"),
               headers = list(`content-type` = "application/json")),
          class = "response"
        )
      },
      http_error  = function(x) FALSE,
      status_code = function(x) x$status_code,
      content     = function(x, as, encoding) "{}",
      .package    = "httr"
    )

    local_mocked_bindings(
      fromJSON = function(txt, ...) list(),
      .package = "jsonlite"
    )

    # Should not error (API key flow)
    expect_no_error(
      talatThaiR:::.nabc_fetch_data(path = "api/test", api_key = "SECRET")
    )
  })
})
