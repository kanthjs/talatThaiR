# =============================================================================
# Shared test helpers for talatThaiR
#
# Strategy: local_mocked_bindings(.nabc_fetch_data, .package = "talatThaiR")
# replaces the binding at namespace level — caught by ALL nested closures
# (.fetch_page, .fetch_all_pages, .pim_fetch_all, etc.) regardless of depth.
# =============================================================================

# ---------------------------------------------------------------------------
# make_response()
# Mimics what .nabc_fetch_data() returns from the real API.
# Includes data_date (Gregorian) for get_daily_prices date-range filtering.
# ---------------------------------------------------------------------------
make_response <- function(n = 5, total = NULL, date = "2025-06-01") {
  if (is.null(total)) total <- n
  df <- data.frame(
    data_date    = rep(date, n),
    year_th      = rep(2568L, n),
    month        = rep("01", n),
    product_name = paste0("item_", seq_len(n)),
    price        = seq_len(n) * 10.0,
    stringsAsFactors = FALSE
  )
  list(
    success    = TRUE,
    data       = df,
    pagination = list(
      total  = as.integer(total),
      limit  = 100L,
      offset = 0L,
      page   = 1L,
      count  = as.integer(n)
    )
  )
}

# ---------------------------------------------------------------------------
# make_empty()  — API returns zero records
# ---------------------------------------------------------------------------
make_empty <- function() {
  list(
    success    = TRUE,
    data       = data.frame(),
    pagination = list(total = 0L, limit = 100L, offset = 0L, page = 1L, count = 0L)
  )
}

# ---------------------------------------------------------------------------
# make_capture(response)
# Returns an environment with:
#   $fn    — function to pass to local_mocked_bindings
#   $path  — last path called
#   $params — last query_params called
#   $calls — number of times called
# ---------------------------------------------------------------------------
make_capture <- function(response = make_response()) {
  env <- new.env(parent = emptyenv())
  env$path   <- NULL
  env$params <- NULL
  env$calls  <- 0L
  env$fn <- function(path, api_key = NULL, query_params = list()) {
    env$path   <- path
    env$params <- query_params
    env$calls  <- env$calls + 1L
    response
  }
  env
}
