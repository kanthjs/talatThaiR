#' Get yearly agricultural price index
#'
#' @description
#' Fetches yearly price index data across five endpoints.
#'
#' **Primary search modes (choose one):**
#' - `sector = TRUE` — list all sectors
#' - `category_code` — search by product category
#' - `group_code` — search by product group
#' - `product_code` — search by product name
#' - `year_th` alone — fetch all commodities for a specific year via `/all`
#'
#' **Optional filter (combine with any primary mode):**
#' - `year_th` — filter by Thai Buddhist year (works with all endpoints including sector)
#'
#' @param category_code Category code (see `show_index_categories()`, e.g. "LIVESTOCK")
#' @param group_code Group code (see `show_index_groups()`, e.g. "OIL_CROP")
#' @param product_code Product code (see `show_index_products()`, e.g. "BANANA_HOM_THONG")
#' @param year_th Thai Buddhist year (e.g. 2568). Standalone mode for the `/all` endpoint,
#'   or an optional filter combined with any other primary mode.
#' @param sector Logical. If `TRUE`, fetches the full sector reference list.
#'   Can be combined with `year_th`. Default: `FALSE`.
#' @param api_key API key (if required)
#'
#' @return A data.frame of yearly price index records
#' @export
#'
#' @examples
#' # Get sector reference list
#' get_price_index_year(sector = TRUE)
#' get_price_index_year(sector = TRUE, year_th = 2567)
#'
#' # Get data by category
#' get_price_index_year(category_code = "LIVESTOCK")
#' get_price_index_year(group_code = "OIL_CROP")
#' get_price_index_year(product_code = "GARLIC_DRY_MIX")
#' get_price_index_year(year_th = 2568)
#'
#' # Get data with year filter
#' get_price_index_year(category_code = "LIVESTOCK", year_th = 2567)
#' get_price_index_year(group_code = "OIL_CROP", year_th = 2567)
#' get_price_index_year(product_code = "GARLIC_DRY_MIX", year_th = 2567)
#'
get_price_index_year <- function(
    category_code = NULL,
    group_code    = NULL,
    product_code  = NULL,
    year_th       = NULL,
    sector        = FALSE,
    api_key       = NULL
) {

  has_cat   <- !is.null(category_code)
  has_group <- !is.null(group_code)
  has_prod  <- !is.null(product_code)
  has_year  <- !is.null(year_th)

  # --- primary modes: mutually exclusive ---
  primary_count <- sum(has_cat, has_group, has_prod)
  if (primary_count > 1) {
    stop("Please specify only one of: category_code, group_code, or product_code.")
  }

  # --- at least one mode required ---
  if (!isTRUE(sector) && primary_count == 0 && !has_year) {
    stop("Please specify at least one of: category_code, group_code, product_code, sector = TRUE, or year_th.")
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

  if (has_year) year_th <- as.character(year_th)

  # ---------------------------------------------------------------------------
  # Build path and params
  #
  # /sector   → sector = TRUE       [+ optional year_th]
  # /category → category_code       [+ optional year_th]
  # /group    → group_code          [+ optional year_th]
  # /product  → product_code        [+ optional year_th]
  # /all      → year_th standalone
  # ---------------------------------------------------------------------------
  if (isTRUE(sector)) {
    path   <- "api/price-index-year/sector"
    params <- list()
    if (has_year) params$year_th <- year_th

  } else if (has_cat) {
    path   <- "api/price-index-year/category"
    params <- list(product_category = .INDEX_CATEGORY_MAP[[category_code]])
    if (has_year) params$year_th <- year_th

  } else if (has_group) {
    path   <- "api/price-index-year/group"
    params <- list(product_group = .INDEX_GROUP_MAP[[group_code]])
    if (has_year) params$year_th <- year_th

  } else if (has_prod) {
    path   <- "api/price-index-year/product"
    params <- list(product_name = .INDEX_PRODUCT_MAP[[product_code]])
    if (has_year) params$year_th <- year_th

  } else {
    # year_th standalone → /all
    path   <- "api/price-index-year/all"
    params <- list(year_th = year_th)
  }

  .priceiy_fetch_all(path, params, api_key)
}


# ---------------------------------------------------------------------------
# Internal: fetch all pages for a given path + base params
# ---------------------------------------------------------------------------
.priceiy_fetch_all <- function(path, base_params, api_key) {

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

  result <- do.call(rbind, Filter(Negate(is.null), all_data))
  row.names(result) <- NULL
  message(sprintf("Done. %d records retrieved.", nrow(result)))
  result
}
