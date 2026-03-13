#' Get monthly agricultural commodity prices
#'
#' @description
#' Fetches monthly price data using one primary search mode,
#' with optional \code{year_th} and/or \code{month} filters.
#'
#' **Primary search modes (choose one):**
#' - \code{category_code} — search by commodity category
#' - \code{product_code}  — search by product name
#' - \code{year_th} + \code{month} — search by Thai year and month (when used alone)
#'
#' **Optional filters (combine with category_code or product_code):**
#' - \code{year_th} — filter by Thai Buddhist year only
#' - \code{year_th} + \code{month} — filter by year and month
#'
#' Note: \code{month} cannot be used without \code{year_th}.
#'
#' @param category_code Category code (see `show_weekly_categories()`, e.g. "BUFFALO").
#'   Monthly prices share the same category map as weekly prices.
#' @param product_code Product code (see `show_weekly_products()`, e.g. "PORK_LIVE_100").
#'   Monthly prices share the same product map as weekly prices.
#' @param year_th Thai Buddhist year (e.g. 2569). Can be used alone or with \code{month}.
#' @param month Month as integer 1-12 (e.g. 2 or "02"). Must be used together with \code{year_th}.
#' @param api_key API key (if required)
#'
#' @return A data.frame of monthly agricultural commodity prices
#' @export
#'
#' @examples
#' # Primary mode only
#' get_monthly_prices(category_code = "BUFFALO")
#' get_monthly_prices(product_code = "PORK_LIVE_100")
#' get_monthly_prices(year_th = 2569, month = 2)
#'
#' # Primary mode + year filter
#' get_monthly_prices(product_code = "PORK_LIVE_100", year_th = 2569)
#'
#' # Primary mode + year and month filter
#' get_monthly_prices(category_code = "BUFFALO", year_th = 2569, month = 2)
#' get_monthly_prices(product_code = "BUFFALO_M", year_th = 2569, month = 2)
#'
get_monthly_prices <- function(
    category_code = NULL,
    product_code  = NULL,
    year_th       = NULL,
    month         = NULL,
    api_key       = NULL
) {

  # --- month cannot be used without year_th ---
  if (is.null(year_th) && !is.null(month)) {
    stop("'month' cannot be used without 'year_th'.")
  }

  has_cat  <- !is.null(category_code)
  has_prod <- !is.null(product_code)
  has_year <- !is.null(year_th)
  has_ym   <- has_year && !is.null(month)  # year + month together

  # --- category and product are mutually exclusive ---
  if (has_cat && has_prod) {
    stop("Please specify either 'category_code' or 'product_code', not both.")
  }

  # year-month standalone mode counts as a primary mode
  has_ym_standalone <- has_ym && !has_cat && !has_prod

  # --- at least one primary mode required ---
  if (!has_cat && !has_prod && !has_year) {
    stop("Please specify at least one of: category_code, product_code, or year_th (+ optional month).")
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
  if (!is.null(month)) {
    month <- sprintf("%02d", as.integer(month))
  }
  if (has_year) {
    year_th <- as.character(year_th)
  }

  # ---------------------------------------------------------------------------
  # Internal: build path and query params based on mode + optional filters
  #
  # Logic:
  #   has_cat  → /commod  + commod=...       [+ year_th and/or month if provided]
  #   has_prod → /product + product_name=... [+ year_th and/or month if provided]
  #   has_ym standalone → /year-month + year_th=... + month=...
  # ---------------------------------------------------------------------------
  .resolve_request <- function(page) {
    params <- list(page = page)

    if (has_cat) {
      path          <- "api/monthly-prices/commod"
      params$commod <- .WEEKLY_CATEGORY_MAP[[category_code]]
      if (has_year)  params$year_th <- year_th
      if (!is.null(month)) params$month <- month

    } else if (has_prod) {
      path                <- "api/monthly-prices/product"
      params$product_name <- .WEEKLY_PRODUCT_MAP[[product_code]]
      if (has_year)  params$year_th <- year_th
      if (!is.null(month)) params$month <- month

    } else {
      # year-month standalone mode
      path           <- "api/monthly-prices/year-month"
      params$year_th <- year_th
      params$month   <- month
    }

    list(path = path, params = params)
  }

  # ---------------------------------------------------------------------------
  # Internal: fetch one page → return list(data, pagination)
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
    message(sprintf("Found %d records (%d page(s)) — fetching...", total, total_pages))

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
