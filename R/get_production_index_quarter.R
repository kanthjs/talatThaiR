#' ดึงข้อมูลดัชนีผลผลิตสินค้าเกษตรรายไตรมาส (Quarterly Production Index)
#'
#' @param category_code รหัสหมวดหมู่สินค้า (อ้างอิง show_index_categories())
#' @param product_code รหัสสินค้า (อ้างอิง show_quarter_products())
#' @param group_code รหัสกลุ่มสินค้า (อ้างอิง show_index_groups())
#' @param date ค้นหาแบบระบุวันที่ (ระบบจะแปลงเป็นไตรมาสให้อัตโนมัติ เช่น "2026-10-01" = ไตรมาส 4)
#' @param start_date วันที่เริ่มต้นในการกวาดข้อมูล (รูปแบบ YYYY-MM-DD)
#' @param end_date วันที่สิ้นสุด (ค่าเริ่มต้นคือวันนี้)
#' @param page ระบุหน้าข้อมูล (ถ้าไม่ระบุ จะกวาดข้อมูลทุกหน้า)
#' @param api_key API Key (ถ้ามี)
#'
#' @return data.frame ข้อมูลดัชนีผลผลิตรายไตรมาส
#' @export
get_production_index_quarter <- function(
    category_code = NULL, 
    product_code = NULL, 
    group_code = NULL,
    date = NULL,
    start_date = NULL, 
    end_date = as.character(Sys.Date()), 
    page = NULL, 
    api_key = NULL
) {
  
  inputs_count <- sum(!is.null(category_code), !is.null(product_code), !is.null(group_code), !is.null(date))
  
  if (inputs_count == 0) {
    stop("\u0e01\u0e23\u0e38\u0e13\u0e32\u0e23\u0e30\u0e1a\u0e38 category_code, product_code, group_code \u0e2b\u0e23\u0e37\u0e2d date \u0e2d\u0e22\u0e48\u0e32\u0e07\u0e43\u0e14\u0e2d\u0e22\u0e48\u0e32\u0e07\u0e2b\u0e19\u0e36\u0e48\u0e07")
  } else if (inputs_count > 1) {
    stop("\u0e01\u0e23\u0e38\u0e13\u0e32\u0e23\u0e30\u0e1a\u0e38\u0e40\u0e07\u0e37\u0e48\u0e2d\u0e19\u0e44\u0e02\u0e01\u0e32\u0e23\u0e04\u0e49\u0e19\u0e2b\u0e32\u0e40\u0e1e\u0e35\u0e22\u0e07\u0e2d\u0e22\u0e48\u0e32\u0e07\u0e40\u0e14\u0e35\u0e22\u0e27\u0e40\u0e17\u0e48\u0e32\u0e19\u0e31\u0e49\u0e19")
  }
  
  if (!is.null(date) && !is.null(start_date)) {
    warning("\u0e04\u0e38\u0e13\u0e23\u0e30\u0e1a\u0e38\u0e17\u0e31\u0e49\u0e07 'date' \u0e41\u0e25\u0e30 'start_date' \u0e23\u0e30\u0e1a\u0e1a\u0e08\u0e30\u0e43\u0e0a\u0e49\u0e42\u0e2b\u0e21\u0e14\u0e04\u0e49\u0e19\u0e2b\u0e32\u0e40\u0e08\u0e32\u0e30\u0e08\u0e07 'date' \u0e40\u0e1b\u0e47\u0e19\u0e2b\u0e25\u0e31\u0e01")
    start_date <- NULL 
  }

  .fetch_single_page <- function(p_page, p_date) {
    query_params <- list(page = ifelse(is.null(p_page), 1, p_page))
    
    if (!is.null(p_date)) {
      path <- "api/production-index-quarter/all"
      d <- as.Date(p_date)
      query_params$year_th <- as.numeric(format(d, "%Y")) + 543
      query_params$quarter <- ceiling(as.numeric(format(d, "%m")) / 3) 
      
    } else if (!is.null(category_code)) {
      # ใช้ตาราง Category ร่วมกับรายเดือนได้เลย
      if (!(category_code %in% names(.INDEX_CATEGORY_MAP))) stop(sprintf("\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e23\u0e2b\u0e31\u0e2a\u0e2b\u0e21\u0e27\u0e14\u0e2b\u0e21\u0e39\u0e48: '%s'", category_code))
      path <- "api/production-index-quarter/category"
      query_params$product_category <- .INDEX_CATEGORY_MAP[[category_code]]
      
    } else if (!is.null(group_code)) {
      # ใช้ตาราง Group ร่วมกับรายเดือนได้เลย
      if (!(group_code %in% names(.INDEX_GROUP_MAP))) stop(sprintf("\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e23\u0e2b\u0e31\u0e2a\u0e01\u0e25\u0e38\u0e48\u0e21: '%s'", group_code))
      path <- "api/production-index-quarter/group"
      query_params$product_group <- .INDEX_GROUP_MAP[[group_code]]
      
    } else if (!is.null(product_code)) {
      # อัปเดต: เปลี่ยนมาใช้ตารางเฉพาะของรายไตรมาส (.QUARTER_PRODUCT_MAP)
      if (!(product_code %in% names(.QUARTER_PRODUCT_MAP))) stop(sprintf("\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e23\u0e2b\u0e31\u0e2a\u0e2a\u0e34\u0e19\u0e04\u0e49\u0e32: '%s' (\u0e25\u0e2d\u0e07\u0e43\u0e0a\u0e49 show_quarter_products())", product_code))
      path <- "api/production-index-quarter/product"
      query_params$product_name <- .QUARTER_PRODUCT_MAP[[product_code]]
    }
    
    return(.nabc_fetch_data(path = path, api_key = api_key, query_params = query_params))
  }

  if (!is.null(date) || !is.null(page)) {
    raw_res <- .fetch_single_page(p_page = page, p_date = date)
    if (!is.data.frame(raw_res) && "data" %in% names(raw_res)) return(raw_res$data)
    if (!is.data.frame(raw_res) && "items" %in% names(raw_res)) return(raw_res$items)
    return(raw_res)
  }
  
  start_dt <- if (is.null(start_date)) as.Date("1900-01-01") else as.Date(start_date)
  end_dt <- as.Date(end_date)
  
  if (start_dt > end_dt) stop("start_date \u0e15\u0e49\u0e2d\u0e07\u0e44\u0e21\u0e48\u0e21\u0e32\u0e01\u0e01\u0e27\u0e48\u0e32 end_date")
  
  all_data <- list()
  current_page <- 1
  keep_fetching <- TRUE
  
  if (is.null(start_date)) {
      message("\u0e01\u0e33\u0e25\u0e31\u0e07\u0e23\u0e27\u0e1a\u0e23\u0e27\u0e21\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e17\u0e31\u0e49\u0e07\u0e2b\u0e21\u0e14\u0e17\u0e35\u0e48\u0e21\u0e35\u0e43\u0e19\u0e23\u0e30\u0e1a\u0e1a... (\u0e2d\u0e32\u0e08\u0e43\u0e0a\u0e49\u0e40\u0e27\u0e25\u0e32\u0e2a\u0e31\u0e01\u0e04\u0e23\u0e39\u0e48)")
  } else {
      message(sprintf("\u0e01\u0e33\u0e25\u0e31\u0e07\u0e23\u0e27\u0e1a\u0e23\u0e27\u0e21\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e15\u0e31\u0e49\u0e07\u0e41\u0e15\u0e48 %s \u0e16\u0e36\u0e07 %s...", start_dt, end_dt))
  }
  
  while(keep_fetching) {
    message(sprintf("\u0e14\u0e36\u0e07\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e2b\u0e19\u0e49\u0e32\u0e17\u0e35\u0e48 %d...", current_page))
    
    temp_data <- tryCatch({
        .fetch_single_page(p_page = current_page, p_date = NULL)
    }, error = function(e) NULL)
    
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
    
    # แปลงไตรมาสเป็นวันที่ เพื่อใช้กวาด Loop ได้เนียนๆ
    if (!"date" %in% colnames(temp_data)) {
       if ("data_date" %in% colnames(temp_data)) {
           temp_data$date <- temp_data$data_date
       } else if ("year_th" %in% colnames(temp_data) && "quarter" %in% colnames(temp_data)) {
           calc_year <- as.numeric(temp_data$year_th) - 543
           calc_month <- (as.numeric(temp_data$quarter) - 1) * 3 + 1
           temp_data$date <- as.Date(paste0(calc_year, "-", sprintf("%02d", calc_month), "-01"))
       } else {
           stop("\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e04\u0e2d\u0e25\u0e31\u0e21\u0e19\u0e4c\u0e27\u0e31\u0e19\u0e17\u0e35\u0e48 (date/year_th/quarter) \u0e08\u0e32\u0e01 API")
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
  return(final_result)
}