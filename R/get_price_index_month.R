#' Get monthly agricultural price index
#'
#' @description
#' Fetches monthly price index data across five endpoints.
#'
#' **Primary search modes (choose one):**
#' - `sector = TRUE` - list all sectors
#' - `category_code` - search by product category
#' - `group_code` - search by product group
#' - `product_code` - search by product name
#' - `year_th` + `month` - fetch all commodities for a specific month (standalone)
#'
#' **Optional filters (combine with any primary mode):**
#' - `year_th` - filter by Thai Buddhist year (works with all endpoints including sector)
#' - `month` - filter by month 1-12 (works with category, group, product)
#' - `year_th` + `month` - filter by both year and month
#'
#' Note: `month` cannot be used without a primary mode (category/group/product).
#' For month-only filtering without a code, use `year_th` + `month` standalone mode.
#'
#' @param category_code Category code (see `show_index_categories()`, e.g. "LIVESTOCK")
#' @param group_code Group code (see `show_index_groups()`, e.g. "OIL_CROP")
#' @param product_code Product code (see `show_index_products()`, e.g. "GARLIC_DRY_MIX")
#' @param year_th Thai Buddhist year (e.g. 2567). Optional filter for any endpoint,
#'   or used with `month` for standalone `/all` mode.
#' @param month Month as integer 1-12 (e.g. 1 or "01"). Optional filter for
#'   category/group/product endpoints; required with `year_th` for standalone `/all` mode.
#' @param sector Logical. If `TRUE`, fetches the full sector reference list.
#'   Can be combined with `year_th`. Default: `FALSE`.
#' @param api_key API key (if required)
#'
#' @return A data.frame of monthly price index records
#' @export
#'
#' @examples
#' \dontrun{
#' # Get sector reference list
#' get_price_index_month(sector = TRUE)
#' get_price_index_month(sector = TRUE, year_th = 2567)
#'
#' # Get data by category
#' get_price_index_month(category_code = "LIVESTOCK")
#' get_price_index_month(group_code = "OIL_CROP")
#' get_price_index_month(product_code = "GARLIC_DRY_MIX")
#' get_price_index_month(year_th = 2568, month = 12)
#'
#' # Get data with year filter
#' get_price_index_month(category_code = "LIVESTOCK", year_th = 2567)
#' get_price_index_month(group_code = "OIL_CROP", year_th = 2567)
#'
#' # Get data with month filter
#' get_price_index_month(category_code = "LIVESTOCK", month = 1)
#' get_price_index_month(group_code = "OIL_CROP", month = 1)
#' get_price_index_month(product_code = "GARLIC_DRY_MIX", month = 1)
#'
#' # Get data with year and month filter
#' get_price_index_month(category_code = "LIVESTOCK", year_th = 2567, month = 1)
#' get_price_index_month(group_code = "OIL_CROP", year_th = 2567, month = 1)
#' get_price_index_month(product_code = "GARLIC_DRY_MIX", year_th = 2567, month = 1)
#'}
get_price_index_month <- function(
    category_code = NULL,
    group_code    = NULL,
    product_code  = NULL,
    year_th       = NULL,
    month         = NULL,
    sector        = FALSE,
    api_key       = NULL
) {

  has_cat   <- !is.null(category_code)
  has_group <- !is.null(group_code)
  has_prod  <- !is.null(product_code)
  has_year  <- !is.null(year_th)
  has_month <- !is.null(month)

  # --- primary modes: mutually exclusive ---
  primary_count <- sum(has_cat, has_group, has_prod)
  if (primary_count > 1) {
    stop("Please specify only one of: category_code, group_code, or product_code.")
  }

  # --- month without a primary mode requires year_th (-> /all standalone) ---
  if (has_month && primary_count == 0 && !isTRUE(sector)) {
    if (!has_year) {
      stop("'month' requires 'year_th' when used without category_code, group_code, or product_code.")
    }
  }

  # --- at least one mode required ---
  if (!isTRUE(sector) && primary_count == 0 && !has_year) {
    stop("Please specify at least one of: category_code, group_code, product_code, sector = TRUE, or (year_th + month).")
  }

  # --- year_th standalone (no month) is ambiguous without a primary mode ---
  if (has_year && !has_month && primary_count == 0 && !isTRUE(sector)) {
    stop("'year_th' alone requires 'month' for standalone mode, or combine with category_code, group_code, product_code, or sector = TRUE.")
  }

  # --- Validate codes ---
  if (has_cat && !(category_code %in% names(.INDEX_CATEGORY_MAP))) {
    stop(sprintf(
      "Category code '%s' not found. Use show_index_categories() to see available codes.",
      category_code
    ))
  }
  if (has_group && !(group_code %in% names(.INDEX_GROUP_MAP))) {
    stop(sprintf(
      "Group code '%s' not found. Use show_index_groups() to see available codes.",
      group_code
    ))
  }
  if (has_prod && !(product_code %in% names(.INDEX_PRODUCT_MAP))) {
    stop(sprintf(
      "Product code '%s' not found. Use show_index_products() to see available codes.",
      product_code
    ))
  }

  # --- Normalize ---
  if (has_month) month   <- sprintf("%02d", as.integer(month))
  if (has_year)  year_th <- as.character(year_th)

  # ---------------------------------------------------------------------------
  # Build path and params
  #
  # /sector   -> sector = TRUE       [+ optional year_th]
  # /category -> category_code       [+ optional year_th, month]
  # /group    -> group_code          [+ optional year_th, month]
  # /product  -> product_code        [+ optional year_th, month]
  # /all      -> year_th + month standalone
  # ---------------------------------------------------------------------------
  if (isTRUE(sector)) {
    path   <- "api/price-index-month/sector"
    params <- list()
    if (has_year) params$year_th <- year_th

  } else if (has_cat) {
    path   <- "api/price-index-month/category"
    params <- list(product_category = .INDEX_CATEGORY_MAP[[category_code]])
    if (has_year)  params$year_th <- year_th
    if (has_month) params$month   <- month

  } else if (has_group) {
    path   <- "api/price-index-month/group"
    params <- list(product_group = .INDEX_GROUP_MAP[[group_code]])
    if (has_year)  params$year_th <- year_th
    if (has_month) params$month   <- month

  } else if (has_prod) {
    path   <- "api/price-index-month/product"
    params <- list(product_name = .INDEX_PRODUCT_MAP[[product_code]])
    if (has_year)  params$year_th <- year_th
    if (has_month) params$month   <- month

  } else {
    # year_th + month standalone -> /all
    path   <- "api/price-index-month/all"
    params <- list(year_th = year_th, month = month)
  }

  .priceim_fetch_all(path, params, api_key)
}


# ---------------------------------------------------------------------------
# Internal: fetch all pages for a given path + base params
# ---------------------------------------------------------------------------
.priceim_fetch_all <- function(path, base_params, api_key) {

  .fetch_page <- function(page) {
    raw <- .nabc_fetch_data(
      path         = path,
      api_key      = api_key,
      query_params = c(base_params, list(page = page))
    )
    if (!isTRUE(raw$success)) {
      stop(sprintf("API returned success = FALSE (page %d).", page))
    }
    list(data = raw$data, pagination = raw$pagination)
  }

  page1  <- .fetch_page(page = 1)
  paging <- page1$pagination
  total  <- paging$total
  limit  <- paging$limit

  if (total == 0 || is.null(page1$data) || nrow(page1$data) == 0) {
    message("No data found.")
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

  result <- do.call(rbind, Filter(Negate(is.null), all_data))
  row.names(result) <- NULL
  message(sprintf("Done. %d records retrieved.", nrow(result)))
  result
}
