#' ดึงข้อมูลราคาสินค้าเกษตรรายเดือน (Monthly Prices)
#'
#' @param category_code รหัสหมวดหมู่สินค้า (ใช้ตารางร่วมกับรายสัปดาห์ อ้างอิง show_weekly_categories())
#' @param product_code รหัสสินค้า (ใช้ตารางร่วมกับรายสัปดาห์ อ้างอิง show_weekly_products())
#' @param year_th ปี พ.ศ. (เช่น "2569") ต้องใช้คู่กับ month
#' @param month เดือน (เช่น "02") ต้องใช้คู่กับ year_th
#' @param page ระบุหน้าข้อมูล (ถ้าไม่ระบุ หรือให้เป็น NULL ระบบจะกวาดข้อมูลทุกหน้าอัตโนมัติ)
#' @param api_key API Key (ถ้ามี)
#'
#' @return data.frame ข้อมูลราคาสินค้าเกษตรรายเดือน
#' @export
get_monthly_prices <- function(
    category_code = NULL, 
    product_code = NULL, 
    year_th = NULL,
    month = NULL,
    page = NULL, 
    api_key = NULL
) {
  
  # 1. เช็คเงื่อนไขการค้นหา
  has_cat <- !is.null(category_code)
  has_prod <- !is.null(product_code)
  has_ym <- !is.null(year_th) && !is.null(month)
  
  inputs_count <- sum(has_cat, has_prod, has_ym)
  
  if (inputs_count == 0) {
    stop("\u0e01\u0e23\u0e38\u0e13\u0e32\u0e23\u0e30\u0e1a\u0e38\u0e40\u0e07\u0e37\u0e48\u0e2d\u0e19\u0e44\u0e02\u0e2d\u0e22\u0e48\u0e32\u0e07\u0e19\u0e49\u0e2d\u0e22 1 \u0e2d\u0e22\u0e48\u0e32\u0e07: category_code, product_code \u0e2b\u0e23\u0e37\u0e2d (year_th \u0e04\u0e39\u0e48\u0e01\u0e31\u0e1a month)")
  }
  if (inputs_count > 1) {
    stop("\u0e01\u0e23\u0e38\u0e13\u0e32\u0e23\u0e30\u0e1a\u0e38\u0e40\u0e07\u0e37\u0e48\u0e2d\u0e19\u0e44\u0e02\u0e01\u0e32\u0e23\u0e04\u0e49\u0e19\u0e2b\u0e32\u0e40\u0e1e\u0e35\u0e22\u0e07\u0e42\u0e2b\u0e21\u0e14\u0e40\u0e14\u0e35\u0e22\u0e27\u0e40\u0e17\u0e48\u0e32\u0e19\u0e31\u0e49\u0e19 (\u0e2b\u0e49\u0e32\u0e21\u0e43\u0e2a\u0e48\u0e0b\u0e49\u0e2d\u0e19\u0e01\u0e31\u0e19)")
  }

  # 2. ฟังก์ชันย่อยสำหรับดึงข้อมูล 1 หน้า (เปลี่ยน Path เป็น monthly-prices)
  .fetch_single_page <- function(p_page) {
    query_params <- list(page = ifelse(is.null(p_page), 1, p_page))
    
    if (has_ym) {
      path <- "api/monthly-prices/year-month"
      query_params$year_th <- year_th
      query_params$month <- month
      
    } else if (has_cat) {
      if (!(category_code %in% names(.WEEKLY_CATEGORY_MAP))) {
          stop(sprintf("\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e23\u0e2b\u0e31\u0e2a\u0e2b\u0e21\u0e27\u0e14\u0e2b\u0e21\u0e39\u0e48: '%s' (\u0e43\u0e0a\u0e49\u0e23\u0e48\u0e27\u0e21\u0e01\u0e31\u0e1a show_weekly_categories())", category_code))
      }
      path <- "api/monthly-prices/commod"
      query_params$commod <- .WEEKLY_CATEGORY_MAP[[category_code]] 
      
    } else if (has_prod) {
      if (!(product_code %in% names(.WEEKLY_PRODUCT_MAP))) {
          stop(sprintf("\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e23\u0e2b\u0e31\u0e2a\u0e2a\u0e34\u0e19\u0e04\u0e49\u0e32: '%s' (\u0e43\u0e0a\u0e49\u0e23\u0e48\u0e27\u0e21\u0e01\u0e31\u0e1a show_weekly_products())", product_code))
      }
      path <- "api/monthly-prices/product"
      query_params$product_name <- .WEEKLY_PRODUCT_MAP[[product_code]]
    }
    
    return(.nabc_fetch_data(path = path, api_key = api_key, query_params = query_params))
  }

  # --- โหมด 1: ดึงหน้าเดียว ---
  if (!is.null(page)) {
    raw_res <- .fetch_single_page(p_page = page)
    if (!is.data.frame(raw_res) && "data" %in% names(raw_res)) return(raw_res$data)
    if (!is.data.frame(raw_res) && "items" %in% names(raw_res)) return(raw_res$items)
    return(raw_res)
  }
  
  # --- โหมด 2: กวาดข้อมูลทั้งหมด (Loop ทะลุทุกหน้า) ---
  all_data <- list()
  current_page <- 1
  keep_fetching <- TRUE
  
  message("\u0e01\u0e33\u0e25\u0e31\u0e07\u0e23\u0e27\u0e1a\u0e23\u0e27\u0e21\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e23\u0e32\u0e04\u0e32\u0e23\u0e32\u0e22\u0e40\u0e14\u0e37\u0e2d\u0e19\u0e17\u0e31\u0e49\u0e07\u0e2b\u0e21\u0e14\u0e17\u0e35\u0e48\u0e15\u0e23\u0e07\u0e01\u0e31\u0e1a\u0e40\u0e07\u0e37\u0e48\u0e2d\u0e19\u0e44\u0e02... (\u0e2d\u0e32\u0e08\u0e43\u0e0a\u0e49\u0e40\u0e27\u0e25\u0e32\u0e2a\u0e31\u0e01\u0e04\u0e23\u0e39\u0e48)")
  
  while(keep_fetching) {
    message(sprintf("\u0e14\u0e36\u0e07\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e2b\u0e19\u0e49\u0e32\u0e17\u0e35\u0e48 %d...", current_page))
    
    temp_data <- tryCatch({
        .fetch_single_page(p_page = current_page)
    }, error = function(e) NULL)
    
    # เช็คว่าเชื่อมต่อสำเร็จไหม
    if (is.null(temp_data)) {
      message("\u0e2a\u0e38\u0e14\u0e17\u0e32\u0e07\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25 \u0e2b\u0e23\u0e37\u0e2d\u0e40\u0e01\u0e34\u0e14\u0e1b\u0e31\u0e0d\u0e2b\u0e32\u0e01\u0e32\u0e23\u0e40\u0e0a\u0e37\u0e48\u0e2d\u0e21\u0e15\u0e48\u0e2d")
      break
    }
    
    # แกะกล่อง JSON
    if (!is.data.frame(temp_data)) {
      if ("data" %in% names(temp_data)) temp_data <- temp_data$data
      else if ("items" %in% names(temp_data)) temp_data <- temp_data$items
    }
    
    # ดักจับหน้าว่าง
    if (is.null(temp_data) || length(temp_data) == 0) {
      message("\u0e2a\u0e38\u0e14\u0e02\u0e2d\u0e1a\u0e10\u0e32\u0e19\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e41\u0e25\u0e49\u0e27 (\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e40\u0e1e\u0e34\u0e48\u0e21\u0e40\u0e15\u0e34\u0e21)")
      break
    }
    
    if (!is.data.frame(temp_data)) temp_data <- as.data.frame(temp_data)
    
    if (nrow(temp_data) == 0) {
      message("\u0e2b\u0e21\u0e14\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e43\u0e19\u0e23\u0e30\u0e1a\u0e1a\u0e41\u0e25\u0e49\u0e27")
      break
    }
    
    all_data[[current_page]] <- temp_data
    current_page <- current_page + 1
    Sys.sleep(1) # หน่วงเวลา
  }
  
  if (length(all_data) == 0) {
    message("\u0e44\u0e21\u0e48\u0e1e\u0e1a\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25")
    return(data.frame()) 
  }
  
  # ประกอบร่าง
  final_result <- do.call(rbind, all_data)
  row.names(final_result) <- NULL
  
  message("\u0e14\u0e36\u0e07\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e2a\u0e33\u0e40\u0e23\u0e47\u0e08!")
  return(final_result)
}