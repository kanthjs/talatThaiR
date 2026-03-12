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

  # year_th ต้องใช้คู่กับ month เสมอ
  if (!is.null(year_th) && is.null(month)) {
    stop("กรุณาระบุ month ควบคู่กับ year_th")
  }

  inputs_count <- sum(has_cat, has_prod, has_ym)

  if (inputs_count == 0) {
    stop("กรุณาระบุเงื่อนไขอย่างน้อย 1 อย่าง: category_code, product_code หรือ (year_th คู่กับ month)")
  }
  if (inputs_count > 1) {
    stop("กรุณาระบุเงื่อนไขการค้นหาเพียงโหมดเดียวเท่านั้น (ห้ามใส่ซ้อนกัน)")
  }

  # Validate codes early, before any fetch attempts
  if (has_cat && !(category_code %in% names(.WEEKLY_CATEGORY_MAP))) {
    stop(sprintf("ไม่พบรหัสหมวดหมู่: '%s' (ใช้ร่วมกับ show_weekly_categories())", category_code))
  }

  if (has_prod && !(product_code %in% names(.WEEKLY_PRODUCT_MAP))) {
    stop(sprintf("ไม่พบรหัสสินค้า: '%s' (ใช้ร่วมกับ show_weekly_products())", product_code))
  }

  # 2. ฟังก์ชันย่อยสำหรับดึงข้อมูล 1 หน้า
  .fetch_single_page <- function(p_page) {
    query_params <- list(page = ifelse(is.null(p_page), 1, p_page))

    if (has_ym) {
      path <- "api/monthly-prices/year-month"
      query_params$year_th <- year_th
      query_params$month <- month

    } else if (has_cat) {
      path <- "api/monthly-prices/commod"
      query_params$commod <- .WEEKLY_CATEGORY_MAP[[category_code]]

    } else if (has_prod) {
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
  
  # ย้าย max_pages เข้ามาไว้ข้างในฟังก์ชันให้เรียกใช้ได้อย่างปลอดภัย
  max_pages <- getOption("talatThaiR.max_pages", 1000L)

  message("Monthly Prices")
  message("กำลังรวบรวมข้อมูลราคารายเดือนทั้งหมดที่ตรงกับเงื่อนไข... (อาจใช้เวลาสักครู่)")

  while (keep_fetching && current_page <= max_pages) {
    message(sprintf("ดึงข้อมูลหน้าที่ %d...", current_page))

    temp_data <- tryCatch({
      .fetch_single_page(p_page = current_page)
    }, error = function(e) NULL)
    
    # เช็คว่าเชื่อมต่อสำเร็จไหม
    if (is.null(temp_data)) {
      message("สุดทางข้อมูล หรือเกิดปัญหาการเชื่อมต่อ")
      break
    }

    # แกะกล่อง JSON
    if (!is.data.frame(temp_data)) {
      if ("data" %in% names(temp_data)) temp_data <- temp_data$data
      else if ("items" %in% names(temp_data)) temp_data <- temp_data$items
    }

    # ดักจับหน้าว่าง
    if (is.null(temp_data) || length(temp_data) == 0) {
      message("สุดขอบฐานข้อมูลแล้ว (ไม่พบข้อมูลเพิ่มเติม)")
      break
    }

    if (!is.data.frame(temp_data)) temp_data <- as.data.frame(temp_data)

    if (nrow(temp_data) == 0) {
      message("หมดข้อมูลในระบบแล้ว")
      break
    }

    all_data[[current_page]] <- temp_data
    current_page <- current_page + 1
    if (isTRUE(getOption("talatThaiR.sleep", TRUE))) Sys.sleep(1)
  }

  if (length(all_data) == 0) {
    message("ไม่พบข้อมูล")
    return(data.frame())
  }
  
  # ประกอบร่าง
  final_result <- do.call(rbind, all_data)
  row.names(final_result) <- NULL
  
  message("ดึงข้อมูลสำเร็จ!")
  return(final_result)
}