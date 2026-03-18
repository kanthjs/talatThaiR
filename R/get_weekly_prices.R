#' Get weekly agricultural commodity prices
#'
#' @description
#' Fetches weekly price data using one primary search mode,
#' with an optional \code{year_th}/\code{month} filter.
#'
#' **Primary search modes (choose one):**
#' - \code{category_code} - search by commodity category
#' - \code{product_code}  - search by product name
#' - \code{year_th} + \code{month} - search by Thai year and month (when used alone)
#'
#' **Optional filter (combine with category_code or product_code):**
#' - \code{year_th} + \code{month} - narrow results to a specific month
#'
#' @param category_code Category code (see `show_weekly_categories()`, e.g. "BUFFALO")
#' @param product_code Product code (see `show_weekly_products()`, e.g. "PORK_LIVE_100")
#' @param year_th Thai Buddhist year (e.g. 2569). Must be used together with \code{month}.
#' @param month Month as integer 1-12 (e.g. 2 or "02"). Must be used together with \code{year_th}.
#' @param api_key API key (if required)
#'
#' @return A data.frame of weekly agricultural commodity prices
#' @export
#'
#' @examples
#' # Get data by category
#' get_weekly_prices(category_code = "BUFFALO")
#'
#' # Get data by product
#' get_weekly_prices(product_code = "PORK_LIVE_100")
#'
#' # Get all products for a specific month
#' get_weekly_prices(year_th = 2569, month = 2)
#'
#' # Get category for a specific month
#' get_weekly_prices(category_code = "BUFFALO", year_th = 2569, month = 2)
#'
#' # Get product for a specific month
#' get_weekly_prices(product_code = "PORK_LIVE_100", year_th = 2569, month = 2)
get_weekly_prices <- function(
    category_code = NULL,
    product_code  = NULL,
    year_th       = NULL,
    month         = NULL,
    api_key       = NULL
) {

  # --- year_th and month must always be paired ---
  has_year  <- !is.null(year_th)
  has_month <- !is.null(month)

  if (xor(has_year, has_month)) {
    stop("'year_th' and 'month' must be specified together.")
  }

  has_cat  <- !is.null(category_code)
  has_prod <- !is.null(product_code)
  has_ym   <- has_year && has_month

  # --- category and product are mutually exclusive ---
  if (has_cat && has_prod) {
    stop("Please specify either 'category_code' or 'product_code', not both.")
  }

  # --- at least one search mode required ---
  if (!has_cat && !has_prod && !has_ym) {
    stop("Please specify at least one of: category_code, product_code, or (year_th + month).")
  }

  # --- Validate codes ---
  if (has_cat && !(category_code %in% names(.WEEKLY_CATEGORY_MAP))) {
    stop(sprintf(
      "Category code '%s' not found. Use show_weekly_categories() to see available codes.",
      category_code
    ))
  }
  if (has_prod && !(product_code %in% names(.WEEKLY_PRODUCT_MAP))) {
    stop(sprintf(
      "Product code '%s' not found. Use show_weekly_products() to see available codes.",
      product_code
    ))
  }

  # --- Normalize month to "02" format ---
  if (has_ym) {
    month   <- sprintf("%02d", as.integer(month))
    year_th <- as.character(year_th)
  }

  # ---------------------------------------------------------------------------
  # Internal: build path and query params based on mode + optional filter
  #
  # Logic:
  #   has_cat  -> /commod  + commod=...       [+ year_th, month if provided]
  #   has_prod -> /product + product_name=... [+ year_th, month if provided]
  #   has_ym only -> /year-month + year_th=... + month=...
  # ---------------------------------------------------------------------------
  .resolve_request <- function(page) {
    params <- list(page = page)

    if (has_cat) {
      path          <- "api/weekly-prices/commod"
      params$commod <- .WEEKLY_CATEGORY_MAP[[category_code]]
      if (has_ym) {
        params$year_th <- year_th
        params$month   <- month
      }

    } else if (has_prod) {
      path                <- "api/weekly-prices/product"
      params$product_name <- .WEEKLY_PRODUCT_MAP[[product_code]]
      if (has_ym) {
        params$year_th <- year_th
        params$month   <- month
      }

    } else {
      path           <- "api/weekly-prices/year-month"
      params$year_th <- year_th
      params$month   <- month
    }

    list(path = path, params = params)
  }

  # ---------------------------------------------------------------------------
  # Internal: fetch one page -> return list(data, pagination)
  # ---------------------------------------------------------------------------
  .fetch_page <- function(page) {
    req <- .resolve_request(page)
    raw <- .nabc_fetch_data(path = req$path, api_key = api_key, query_params = req$params)

    if (!isTRUE(raw$success)) {
      stop(sprintf("API returned success = FALSE (page %d).", page))
    }

    list(data = raw$data, pagination = raw$pagination)
  }

  # ---------------------------------------------------------------------------
  # Internal: fetch all pages using pagination$total and pagination$limit
  # ---------------------------------------------------------------------------
  .fetch_all_pages <- function() {

    page1  <- .fetch_page(page = 1)
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
        .fetch_page(page = p),
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

    do.call(rbind, Filter(Negate(is.null), all_data))
  }

  # ===========================================================================
  # Fetch data
  # ===========================================================================
  result <- .fetch_all_pages()

  if (is.null(result) || nrow(result) == 0) {
    message("No data found.")
    return(data.frame())
  }

  row.names(result) <- NULL
  message(sprintf("Done. %d records retrieved.", nrow(result)))
  result
}
