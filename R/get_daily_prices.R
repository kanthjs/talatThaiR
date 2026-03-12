#' ดึงข้อมูลราคาสินค้าเกษตรรายวัน (Daily Prices)
#'
#' @param category_code รหัสหมวดหมู่สินค้า (อ้างอิง `show_daily_categories()` เช่น "RICE_MALI")
#' @param product_code รหัสสินค้า (อ้างอิง `show_daily_product()` เช่น "LIME_XL")
#' @param date ค้นหาแบบระบุวันที่ (รูปแบบ YYYY-MM-DD เช่น "2026-01-15")
#' @param start_date วันที่เริ่มต้นในการกวาดข้อมูล (รูปแบบ YYYY-MM-DD)
#' @param end_date วันที่สิ้นสุด (ค่าเริ่มต้นคือวันนี้)
#' @param page ระบุหน้าข้อมูล (ถ้าไม่ระบุ จะกวาดข้อมูลทุกหน้า)
#' @param api_key API Key (ถ้ามี)
#'
#' @return data.frame ข้อมูลราคาสินค้าเกษตรรายวัน
#' @export
get_daily_prices <- function(
    category_code = NULL,
    product_code = NULL,
    date = NULL,
    start_date = NULL,
    end_date = as.character(Sys.Date()),
    page = NULL,
    api_key = NULL
) {

  inputs_count <- sum(!is.null(category_code), !is.null(product_code), !is.null(date))

  if (inputs_count == 0) {
    stop("\u0e01\u0e23\u0e38\u0e13\u0e32\u0e23\u0e30\u0e1a\u0e38 category_code, product_code \u0e2b\u0e23\u0e37\u0e2d date \u0e2d\u0e22\u0e48\u0e32\u0e07\u0e43\u0e14\u0e2d\u0e22\u0e48\u0e32\u0e07\u0e2b\u0e19\u0e36\u0e48\u0e07")
  } else if (inputs_count > 1) {
    stop("\u0e01\u0e23\u0e38\u0e13\u0e32\u0e23\u0e30\u0e1a\u0e38\u0e40\u0e07\u0e37\u0e48\u0e2d\u0e19\u0e44\u0e02\u0e01\u0e32\u0e23\u0e04\u0e49\u0e19\u0e2b\u0e32\u0e40\u0e1e\u0e35\u0e22\u0e07\u0e2d\u0e22\u0e48\u0e32\u0e07\u0e40\u0e14\u0e35\u0e22\u0e27\u0e40\u0e17\u0e48\u0e32\u0e19\u0e31\u0e49\u0e19")
  }

  # Validate codes early, before any fetch attempts
  if (!is.null(category_code) && !(category_code %in% names(.DAILY_CATEGORY_MAP))) {
    stop(sprintf("\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e23\u0e2b\u0e31\u0e2a\u0e2b\u0e21\u0e27\u0e14\u0e2b\u0e21\u0e39\u0e48: '%s' (\u0e25\u0e2d\u0e07\u0e43\u0e0a\u0e49 show_daily_categories() \u0e40\u0e1e\u0e37\u0e48\u0e2d\u0e14\u0e39\u0e23\u0e2b\u0e31\u0e2a)", category_code))
  }

  if (!is.null(product_code) && !(product_code %in% names(.DAILY_PRODUCT_MAP))) {
    stop(sprintf("\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e23\u0e2b\u0e31\u0e2a\u0e2a\u0e34\u0e19\u0e04\u0e49\u0e32: '%s' (\u0e25\u0e2d\u0e07\u0e43\u0e0a\u0e49 show_daily_product() \u0e40\u0e1e\u0e37\u0e48\u0e2d\u0e14\u0e39\u0e23\u0e2b\u0e31\u0e2a)", product_code))
  }

  if (!is.null(date) && !is.null(start_date)) {
    warning("\u0e04\u0e38\u0e13\u0e23\u0e30\u0e1a\u0e38\u0e17\u0e31\u0e49\u0e07 'date' \u0e41\u0e25\u0e30 'start_date' \u0e23\u0e30\u0e1a\u0e1a\u0e08\u0e30\u0e43\u0e0a\u0e49\u0e42\u0e2b\u0e21\u0e14\u0e04\u0e49\u0e19\u0e2b\u0e32\u0e40\u0e08\u0e32\u0e30\u0e08\u0e07 'date' \u0e40\u0e1b\u0e47\u0e19\u0e2b\u0e25\u0e31\u0e01")
    start_date <- NULL
  }

  .fetch_single_page <- function(p_page, p_date) {
    query_params <- list(page = ifelse(is.null(p_page), 1, p_page))

    if (!is.null(p_date)) {
      path <- "api/daily-prices/date"
      query_params$date <- p_date

    } else if (!is.null(category_code)) {
      path <- "api/daily-prices/category"
      query_params$category <- .DAILY_CATEGORY_MAP[[category_code]]

    } else if (!is.null(product_code)) {
      path <- "api/daily-prices/product"
      query_params$product_name <- .DAILY_PRODUCT_MAP[[product_code]]
    }

    .nabc_fetch_data(path = path, api_key = api_key, query_params = query_params)
  }

  # --- โหมดหน้าเดียว ---
  if (!is.null(date) || !is.null(page)) {
    raw_res <- .fetch_single_page(p_page = page, p_date = date)
    if (!is.data.frame(raw_res) && "data" %in% names(raw_res)) return(raw_res$data)
    if (!is.data.frame(raw_res) && "items" %in% names(raw_res)) return(raw_res$items)
    return(raw_res)
  }

  # --- โหมดช่วงเวลา (Loop กวาดข้อมูล) ---
  start_dt <- if (is.null(start_date)) as.Date("1900-01-01") else as.Date(start_date)
  end_dt <- as.Date(end_date)

  if (start_dt > end_dt) stop("start_date \u0e15\u0e49\u0e2d\u0e07\u0e44\u0e21\u0e48\u0e21\u0e32\u0e01\u0e01\u0e27\u0e48\u0e32 end_date")

  all_data <- list()
  current_page <- 1
  keep_fetching <- TRUE
  max_pages <- getOption("talatThaiR.max_pages", 1000L)

  if (is.null(start_date)) {
    message("\u0e01\u0e33\u0e25\u0e31\u0e07\u0e23\u0e27\u0e1a\u0e23\u0e27\u0e21\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e23\u0e32\u0e04\u0e32\u0e23\u0e32\u0e22\u0e27\u0e31\u0e19\u0e17\u0e31\u0e49\u0e07\u0e2b\u0e21\u0e14\u0e17\u0e35\u0e48\u0e15\u0e23\u0e07\u0e01\u0e31\u0e1a\u0e40\u0e07\u0e37\u0e48\u0e2d\u0e19\u0e44\u0e02... (\u0e2d\u0e32\u0e08\u0e43\u0e0a\u0e49\u0e40\u0e27\u0e25\u0e32\u0e2a\u0e31\u0e01\u0e04\u0e23\u0e39\u0e48)")
  } else {
    message(sprintf("\u0e01\u0e33\u0e25\u0e31\u0e07\u0e23\u0e27\u0e1a\u0e23\u0e27\u0e21\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e15\u0e31\u0e49\u0e07\u0e41\u0e15\u0e48 %s \u0e16\u0e36\u0e07 %s...", start_dt, end_dt))
  }

  while (keep_fetching) {
    message(sprintf("\u0e14\u0e36\u0e07\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e2b\u0e19\u0e49\u0e32\u0e17\u0e35\u0e48 %d...", current_page))

    temp_data <- tryCatch(
      .fetch_single_page(p_page = current_page, p_date = NULL),
      error = function(e) NULL
    )

    if (is.null(temp_data)) {
      message("\u0e2a\u0e38\u0e14\u0e17\u0e32\u0e07\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25 \u0e2b\u0e23\u0e37\u0e2d\u0e40\u0e01\u0e34\u0e14\u0e1b\u0e31\u0e0d\u0e2b\u0e32\u0e01\u0e32\u0e23\u0e40\u0e0a\u0e37\u0e48\u0e2d\u0e21\u0e15\u0e48\u0e2d")
      break
    }

    if (!is.data.frame(temp_data)) {
      if ("data" %in% names(temp_data)) temp_data <- temp_data$data
      else if ("items" %in% names(temp_data)) temp_data <- temp_data$items
    }

    if (is.null(temp_data) || length(temp_data) == 0) {
      message("\u0e2a\u0e38\u0e14\u0e02\u0e2d\u0e1a\u0e10\u0e32\u0e19\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e41\u0e25\u0e49\u0e27 (\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e40\u0e1e\u0e34\u0e48\u0e21\u0e40\u0e15\u0e34\u0e21)")
      break
    }

    if (!is.data.frame(temp_data)) temp_data <- as.data.frame(temp_data)

    if (nrow(temp_data) == 0) {
      message("\u0e2b\u0e21\u0e14\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e43\u0e19\u0e23\u0e30\u0e1a\u0e1a\u0e41\u0e25\u0e49\u0e27")
      break
    }

    # จัดการคอลัมน์วันที่
    if (!"date" %in% colnames(temp_data)) {
      if ("data_date" %in% colnames(temp_data)) {
        temp_data$date <- temp_data$data_date
      } else {
        stop("\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e04\u0e2d\u0e25\u0e31\u0e21\u0e19\u0e4c\u0e27\u0e31\u0e19\u0e17\u0e35\u0e48 (date/data_date) \u0e08\u0e32\u0e01 API")
      }
    }

    temp_data$temp_calc_date <- as.Date(temp_data$date)
    valid_data <- temp_data[temp_data$temp_calc_date >= start_dt & temp_data$temp_calc_date <= end_dt, ]

    if (nrow(valid_data) > 0) all_data[[current_page]] <- valid_data

    if (min(temp_data$temp_calc_date, na.rm = TRUE) < start_dt) {
      keep_fetching <- FALSE
    } else {
      current_page <- current_page + 1
      Sys.sleep(1)
    }
  }

  if (length(all_data) == 0) {
    message("\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e43\u0e19\u0e0a\u0e48\u0e27\u0e07\u0e40\u0e27\u0e25\u0e32\u0e17\u0e35\u0e48\u0e23\u0e30\u0e1a\u0e38")
    return(data.frame())
  }

  final_result <- do.call(rbind, all_data)
  final_result$temp_calc_date <- NULL
  final_result <- final_result[order(as.Date(final_result$date), decreasing = TRUE), ]
  row.names(final_result) <- NULL

  message("\u0e14\u0e36\u0e07\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e2a\u0e33\u0e40\u0e23\u0e47\u0e08!")
  final_result
}
