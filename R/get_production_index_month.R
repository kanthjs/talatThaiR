#' Get monthly agricultural production index
#'
#' @description
#' Fetches monthly production index data across five endpoints.
#'
#' **Primary search modes (choose one):**
#' - `sector = TRUE` - list all sectors (no other parameters)
#' - `category_code` - search by product category
#' - `group_code` - search by product group
#' - `product_code` - search by product name
#' - `year_th` + `month` - fetch all commodities for a specific month (standalone)
#'
#' **Optional filter (combine with category_code, group_code, or product_code):**
#' - `month` - narrow results to a specific month (1-12)
#'
#' Note: `month` alone without a primary mode requires `year_th` as well.
#'
#' @param category_code Category code (see `show_index_categories()`, e.g. "LIVESTOCK")
#' @param group_code Group code (see `show_index_groups()`, e.g. "OIL_CROP")
#' @param product_code Product code (see `show_index_products()`, e.g. "BANANA_HOM_THONG")
#' @param year_th Thai Buddhist year (e.g. 2568). Used with `month` for the `/all` endpoint,
#'   or as part of a filter (not applicable for category/group/product - use `month` only).
#' @param month Month as integer 1-12 (e.g. 1 or "01"). Optional filter for category/group/product;
#'   required together with `year_th` for standalone `/all` mode.
#' @param sector Logical. If `TRUE`, fetches the full sector reference list. No other parameters
#'   should be specified. Default: `FALSE`.
#' @param api_key API key (if required)
#'
#' @return A data.frame of monthly production index records
#' @export
#'
#' @examples
#' # Get sector reference list
#' get_production_index_month(sector = TRUE)
#'
#' # Get data by category
#' get_production_index_month(category_code = "LIVESTOCK")
#' get_production_index_month(group_code = "OIL_CROP")
#' get_production_index_month(product_code = "BANANA_HOM_THONG")
#'
#' # Note: The NABC database has limitations - standalone mode may only fetch page 1
#' get_production_index_month(year_th = 2568, month = 12)
#'
#' # Get data with month filter
#' get_production_index_month(category_code = "LIVESTOCK", month = 1)
#' get_production_index_month(group_code = "OIL_CROP", month = 6)
#' get_production_index_month(product_code = "BANANA_HOM_THONG", month = 3)
#'
get_production_index_month <- function(
    category_code = NULL,
    group_code    = NULL,
    product_code  = NULL,
    year_th       = NULL,
    month         = NULL,
    sector        = FALSE,
    api_key       = NULL
) {

  has_cat    <- !is.null(category_code)
  has_group  <- !is.null(group_code)
  has_prod   <- !is.null(product_code)
  has_year   <- !is.null(year_th)
  has_month  <- !is.null(month)
  has_ym     <- has_year && has_month

  # --- sector mode: no other params allowed ---
  if (isTRUE(sector)) {
    if (has_cat || has_group || has_prod || has_year || has_month) {
      stop("When 'sector = TRUE', no other parameters should be specified.")
    }
    return(.pim_fetch_all("api/production-index-month/sector", list(), api_key))
  }

  # --- primary modes: category, group, product are mutually exclusive ---
  primary_count <- sum(has_cat, has_group, has_prod)
  if (primary_count > 1) {
    stop("Please specify only one of: category_code, group_code, or product_code.")
  }

  # --- month without a primary mode requires year_th (-> /all mode) ---
  if (!has_cat && !has_group && !has_prod) {
    if (has_month && !has_year) {
      stop("'month' requires 'year_th' when used without category_code, group_code, or product_code.")
    }
    if (!has_year) {
      stop("Please specify at least one of: category_code, group_code, product_code, sector = TRUE, or (year_th + month).")
    }
    # year_th standalone (without month) is ambiguous for /all - require month
    if (has_year && !has_month) {
      stop("'year_th' requires 'month' when used in standalone mode (without category_code, group_code, or product_code).")
    }
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

  # --- Normalize month ---
  if (has_month) {
    month <- sprintf("%02d", as.integer(month))
  }
  if (has_year) {
    year_th <- as.character(year_th)
  }

  # ---------------------------------------------------------------------------
  # Internal: resolve path and query params
  #
  # /all      -> year_th + month (standalone)
  # /category -> product_category [+ optional month]
  # /group    -> product_group    [+ optional month]
  # /product  -> product_name     [+ optional month]
  # ---------------------------------------------------------------------------
  if (has_cat) {
    path   <- "api/production-index-month/category"
    params <- list(product_category = .INDEX_CATEGORY_MAP[[category_code]])
    if (has_month) params$month <- month

  } else if (has_group) {
    path   <- "api/production-index-month/group"
    params <- list(product_group = .INDEX_GROUP_MAP[[group_code]])
    if (has_month) params$month <- month

  } else if (has_prod) {
    path   <- "api/production-index-month/product"
    params <- list(product_name = .INDEX_PRODUCT_MAP[[product_code]])
    if (has_month) params$month <- month

  } else {
    # year_th + month standalone -> /all
    path   <- "api/production-index-month/all"
    params <- list(year_th = year_th, month = month)
  }

  .pim_fetch_all(path, params, api_key)
}


# ---------------------------------------------------------------------------
# Internal: fetch all pages for a given path + base params
# ---------------------------------------------------------------------------
.pim_fetch_all <- function(path, base_params, api_key) {

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
