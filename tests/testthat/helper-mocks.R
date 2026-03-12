# helper-mocks.R
# Custom helper functions and mock factories for talatThaiR tests.
# This file is automatically sourced by testthat before running any tests.

# Disable Sys.sleep() and limit pagination to 1 page during tests
options(talatThaiR.sleep = FALSE)
options(talatThaiR.max_pages = 1L)

# ---------------------------------------------------------------------------
# Mock API response factories
# ---------------------------------------------------------------------------

#' Build a minimal mock data.frame that looks like a NABC daily-price response
mock_daily_response <- function(n = 3) {
  data.frame(
    date        = as.character(seq(Sys.Date() - (n - 1), Sys.Date(), by = "day")),
    product_name = paste0("Product", seq_len(n)),
    price       = seq(10, by = 5, length.out = n),
    unit        = rep("baht/kg", n),
    stringsAsFactors = FALSE
  )
}

#' Build a minimal mock data.frame that looks like a NABC weekly-price response
mock_weekly_response <- function(n = 3) {
  data.frame(
    data_date   = as.character(seq(Sys.Date() - (n - 1) * 7, Sys.Date(), by = "week")),
    product_name = paste0("Product", seq_len(n)),
    price       = seq(20, by = 10, length.out = n),
    unit        = rep("baht/kg", n),
    stringsAsFactors = FALSE
  )
}

#' Build a minimal mock data.frame that looks like a NABC monthly-price response
mock_monthly_response <- function(n = 3) {
  data.frame(
    month        = seq_len(n),
    year         = rep(2025L, n),
    product_name = paste0("Product", seq_len(n)),
    price        = seq(100, by = 50, length.out = n),
    stringsAsFactors = FALSE
  )
}

#' Build a minimal mock data.frame that looks like a NABC price/production index response
mock_index_response <- function(n = 3) {
  data.frame(
    month        = seq_len(n),
    year         = rep(2025L, n),
    product_name = paste0("Commodity", seq_len(n)),
    index        = seq(90, by = 5, length.out = n),
    stringsAsFactors = FALSE
  )
}

# ---------------------------------------------------------------------------
# Convenience: silently wrap a call that is expected to emit messages
# ---------------------------------------------------------------------------
suppress_msgs <- function(expr) suppressMessages(expr)
