#' Get daily agricultural commodity prices
#'
#' @param category_code Category code (see `show_daily_categories()`, e.g. "SHRIMP")
#' @param product_code Product code (see `show_daily_products()`, e.g. "LIME_XL")
#' @param date Fetch prices for a specific date (format: "YYYY-MM-DD")
#' @param start_date Filter results from this date onward (format: "YYYY-MM-DD"). Used with category_code or product_code.
#' @param end_date Filter results up to this date (default: today)
#' @param api_key API key (if required)
#'
#' @return A data.frame of daily agricultural commodity prices
#' @export
#'
#' @examples
#' \dontrun{
#' # Select by product category
#' get_daily_prices(category_code = "RICE_MALI")
#'
#' # Select by product name
#' get_daily_prices(product_code = "LIME_XL")
#'
#' # Get all products for a specific date
#' get_daily_prices(date = "2025-06-01")
#'
#' # Get a product from a specific date range
#' get_daily_prices(product_code = "LIME_XL", start_date = "2026-01-01")
#'
#' # Get a category from a specific date range
#' get_daily_prices(category_code = "SHRIMP", start_date = "2026-01-01")
#' }
get_daily_prices <- function(
    category_code = NULL,
    product_code  = NULL,
    date          = NULL,
    start_date    = NULL,
    end_date      = as.character(Sys.Date()),
    api_key       = NULL
) {

  # --- Validate: exactly one search mode required ---
  inputs_count <- sum(!is.null(category_code), !is.null(product_code), !is.null(date))

  if (inputs_count == 0) {
    stop("Please specify one of: category_code, product_code, or date.")
  }
  if (inputs_count > 1) {
    stop("Please specify only one search mode at a time.")
  }

  # --- Validate: check codes before fetching ---
  if (!is.null(category_code) && !(category_code %in% names(.DAILY_CATEGORY_MAP))) {
    stop(sprintf(
      "Category code '%s' not found. Use show_daily_categories() to see available codes.",
      category_code
    ))
  }
  if (!is.null(product_code) && !(product_code %in% names(.DAILY_PRODUCT_MAP))) {
    stop(sprintf(
      "Product code '%s' not found. Use show_daily_products() to see available codes.",
      product_code
    ))
  }

  # --- date mode does not support date range ---
  if (!is.null(date) && !is.null(start_date)) {
    warning("'start_date' is ignored when 'date' is specified.")
  }

  # ---------------------------------------------------------------------------
  # Internal: build path and query params based on mode
  # ---------------------------------------------------------------------------
  .resolve_request <- function(page, target_date = NULL) {
    params <- list(page = page)

    if (!is.null(target_date)) {
      list(
        path   = "api/daily-prices/date",
        params = c(params, list(date = target_date))
      )
    } else if (!is.null(category_code)) {
      list(
        path   = "api/daily-prices/category",
        params = c(params, list(product_category = .DAILY_CATEGORY_MAP[[category_code]]))
      )
    } else {
      list(
        path   = "api/daily-prices/product",
        params = c(params, list(product_name = .DAILY_PRODUCT_MAP[[product_code]]))
      )
    }
  }

  # ---------------------------------------------------------------------------
  # Internal: fetch one page to return list(data, pagination)
  # ---------------------------------------------------------------------------
  .fetch_page <- function(page, target_date = NULL) {
    req <- .resolve_request(page, target_date)
    raw <- .nabc_fetch_data(path = req$path, api_key = api_key, query_params = req$params)

    if (!isTRUE(raw$success)) {
      stop(sprintf("API returned success = FALSE (page %d).", page))
    }

    list(data = raw$data, pagination = raw$pagination)
  }

  # ---------------------------------------------------------------------------
  # Internal: fetch all pages using pagination$total and pagination$limit
  # Pagination is an implementation detail - fully hidden from the caller
  # ---------------------------------------------------------------------------
  .fetch_all_pages <- function(target_date = NULL) {

    page1  <- .fetch_page(page = 1, target_date = target_date)
    paging <- page1$pagination
    total  <- paging$total
    limit  <- paging$limit

    if (total == 0 || is.null(page1$data) || nrow(page1$data) == 0) {
      return(data.frame())
    }

    total_pages <- ceiling(total / limit)
    message(sprintf("Found %d records (%d page(s)) - fetching...", total, total_pages))

    all_data      <- vector("list", total_pages)
    all_data[[1]] <- page1$data

    for (p in seq_len(total_pages)[-1]) {
      message(sprintf("  Fetching page %d / %d", p, total_pages))

      page_result <- tryCatch(
        .fetch_page(page = p, target_date = target_date),
        error = function(e) {
          warning(sprintf("Failed to fetch page %d: %s", p, conditionMessage(e)))
          NULL
        }
      )

      if (!is.null(page_result) && !is.null(page_result$data) && nrow(page_result$data) > 0) {
        all_data[[p]] <- page_result$data
      }

      Sys.sleep(0.3)
    }

    result <- do.call(rbind, Filter(Negate(is.null), all_data))
    result <- result[order(as.Date(result$data_date), decreasing = TRUE), ]
    row.names(result) <- NULL
    result
  }

  # ===========================================================================
  # date mode: fetch all pages for that date
  # ===========================================================================
  if (!is.null(date)) {
    result <- .fetch_all_pages(target_date = date)
    if (nrow(result) == 0) {
      message("No data found for the specified date.")
    } else {
      message(sprintf("Done. %d records retrieved.", nrow(result)))
    }
    return(result)
  }

  # ===========================================================================
  # category / product mode: fetch all pages, then filter by date range
  # ===========================================================================
  result <- .fetch_all_pages(target_date = NULL)

  if (nrow(result) == 0) {
    message("No data found.")
    return(data.frame())
  }

  # Apply date range filter if specified
  if (!is.null(start_date) || end_date != as.character(Sys.Date())) {
    start_dt    <- if (is.null(start_date)) as.Date("1900-01-01") else as.Date(start_date)
    end_dt      <- as.Date(end_date)
    result_date <- as.Date(result$data_date)
    result      <- result[result_date >= start_dt & result_date <= end_dt, ]
    row.names(result) <- NULL
  }

  if (nrow(result) == 0) {
    message("No data found within the specified date range.")
  } else {
    message(sprintf("Done. %d records retrieved.", nrow(result)))
  }

  result
}
