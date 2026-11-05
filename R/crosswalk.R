# ---------------------------------------------------------
# Crosswalk: product codes across frequencies
# ---------------------------------------------------------
# NABC product names are not consistent across daily / weekly / index datasets.
# For example, fresh rubber latex is "น้ำยางพาราสด" in daily data but
# "น้ำยางสด คละ" in weekly/monthly data.  This table maps the same commodity
# across frequencies so users can link the datasets.

.CROSSWALK <- data.frame(
  commodity    = c(
    "rubber_latex",   "rubber_latex",
    "rubber_sheet3",  "rubber_sheet3",
    "rubber_lump",
    "cassava_fresh",  "cassava_fresh",   "cassava_fresh",
    "cassava_chip",
    "corn_14_5",      "corn_14_5",       "corn_14_5",
    "corn_30",
    "shrimp_vannamei","shrimp_vannamei", "shrimp_vannamei",
    "longan_edor_aa", "longan_edor_aa",
    "longan_edor_a",  "longan_edor_a",
    "pineapple_fac",  "pineapple_fac",   "pineapple_fac",
    "palm_mixed",     "palm_mixed",      "palm_mixed",
    "coconut_dry_l",  "coconut_dry_l",   "coconut_dry_l",
    "egg_mixed",      "egg_mixed",
    "egg_no3",        "egg_no3",
    "pork_100",       "pork_100",
    "broiler",        "broiler",
    "rice_mali_paddy","rice_mali_paddy"
  ),
  frequency    = c(
    "daily",    "weekly",
    "daily",    "weekly",
    "weekly",
    "daily",    "daily",    "weekly",
    "weekly",
    "daily",    "weekly",   "index_month",
    "daily",
    "daily",    "weekly",   "index_month",
    "daily",    "weekly",
    "daily",    "weekly",
    "daily",    "weekly",   "index_month",
    "daily",    "weekly",   "index_month",
    "daily",    "weekly",   "index_month",
    "weekly",   "index_month",
    "daily",    "weekly",
    "daily",    "weekly",
    "weekly",   "index_month",
    "weekly",   "index_month"
  ),
  code         = c(
    "RUBBER_LIQUID",    "RUBBER_LIQUID_MIX",
    "RUBBER_SHEET3",    "RUBBER_SHEET_3",
    "RUBBER_LUMP_MIX",
    "CASSAVA_30",       "CASSAVA_25",       "CASSAVA_FRESH_MIX",
    "CASSAVA_CHIP_MIX",
    "CORN_M14_5",       "CORN_SEED_14_5",   "CORN_14_5",
    "CORN_M30",
    "SHRIMP_70",        "SHRIMP_71_80",     "SHRIMP_70",
    "LONGAN_E_AA",      "LONGAN_EDOR_AA",
    "LONGAN_AA",        "LONGAN_EDOR_A",
    "PINEAPPLE_FAC",    "PINEAPPLE_FAC",    "PINEAPPLE_PAT_FAC",
    "PALM_15",          "PALM_MIXED",       "PALM_MIXED",
    "COCO_L",           "COCO_DRY_L",       "COCO_MATURE_L",
    "EGG_MIXED",        "EGG_MIXED",
    "EGG_3",            "EGG_3",
    "PORK_100",         "PORK_LIVE_100",
    "CHICK_MEAT_IND",   "CHICK_MEAT",
    "RICE_MALI_PADDY_15", "RICE_MALI_IN_SEASON"
  ),
  name_th      = c(
    "น้ำยางพาราสด",
    "น้ำยางสด คละ",
    "ยางพาราแผ่นดิบ ชั้น 3",
    "ยางแผ่นดิบ ชั้น 3",
    "ยางก้อน คละ",
    "หัวมันสำปะหลังสด (แป้ง 30%)",
    "หัวมันสำปะหลังสด (แป้ง 25%)",
    "มันสำปะหลังสด คละ",
    "มันเส้น คละ",
    "ข้าวโพดเลี้ยงสัตว์ ความชื้น 14.5%",
    "ข้าวโพดเลี้ยงสัตว์เมล็ด ความชื้น 14.5",
    "ข้าวโพดเลี้ยงสัตว์ ความชื้น 14.5",
    "ข้าวโพดเลี้ยงสัตว์ ความชื้น 30%",
    "กุ้งขาวแวนนาไม ขนาด 70 ตัว/กก.",
    "กุ้งขาวแวนนาไม 71-80 ตัว/กก.",
    "กุ้งขาวแวนนาไม (70 ตัว/กก.)",
    "ลำไยทั้งช่อพันธุ์อีดอ เกรด AA",
    "ลำไยสดทั้งช่อพันธุ์อีดอ เกรด AA",
    "ลำไยร่วง เกรด AA",
    "ลำไยสดทั้งช่อพันธุ์อีดอ เกรด A",
    "สับปะรดปัตตาเวียส่งโรงงาน",
    "สับปะรดโรงงาน",
    "สับปะรดปัตตาเวียส่งโรงงาน",
    "ผลปาล์มน้ำมันทั้งทะลาย นน. > 15 กก.",
    "ผลปาล์มน้ำมันทั้งทะลาย คละ",
    "ปาล์มน้ำมันทั้งทะลาย คละ",
    "มะพร้าวผลแห้ง ขนาดใหญ่",
    "มะพร้าวแห้ง ใหญ่",
    "มะพร้าวผลแก่ ขนาดใหญ่",
    "ไข่ไก่สด คละ",
    "ไข่ไก่สด คละ",
    "ไข่ไก่ เบอร์ 3",
    "ไข่ไก่สด เบอร์ 3",
    "สุกรพันธุ์ผสม น้ำหนัก 100 กก. ขึ้นไป",
    "สุกรมีชีวิต น้ำหนักเกิน 100 กก.",
    "ไก่รุ่นพันธุ์เนื้อ ฟาร์มอิสระ",
    "ไก่รุ่นพันธุ์เนื้อ",
    "ข้าวเปลือกเจ้าหอมมะลิ ความชื้น 15",
    "ข้าวเปลือกเจ้านาปีหอมมะลิ"
  ),
  note = c(
    NA, "mixed grade",
    NA, NA,
    "mixed grade",
    "starch 30%", "starch 25%", "mixed grade",
    "dried chips, mixed grade",
    "14.5% moisture", "14.5% moisture (seed)", "14.5% moisture",
    "30% moisture",
    "70 pcs/kg", "71-80 pcs/kg", "70 pcs/kg",
    NA, NA,
    "loose fruit, grade AA", NA,
    NA, "shorter name in weekly", NA,
    ">15 kg bunches", "mixed grade bunches", "mixed grade bunches",
    "dry, large", "dry, large", "mature, large",
    NA, NA,
    NA, NA,
    NA, NA,
    "farm gate", NA,
    "15% moisture", "in-season"
  ),
  stringsAsFactors = FALSE
)

#' Cross-frequency product code reference
#'
#' Returns a data frame mapping the same commodity across daily, weekly/monthly,
#' and index datasets. NABC uses different product names for the same commodity
#' depending on the data frequency; this table shows which codes correspond to
#' each other so you can align series across datasets.
#'
#' @return A data frame with columns:
#'   \describe{
#'     \item{commodity}{Canonical commodity slug (e.g. `"rubber_latex"`)}
#'     \item{frequency}{Which dataset: `"daily"`, `"weekly"`, or `"index_month"`}
#'     \item{code}{Product code to pass to the relevant `get_*()` function}
#'     \item{name_th}{Thai product name as it appears in the API}
#'     \item{note}{Grade, moisture level, or size specification}
#'   }
#' @examples
#' cw <- crosswalk_products()
#' # Find all rubber codes across frequencies
#' cw[grepl("rubber", cw$commodity), ]
#' @export
crosswalk_products <- function() {
  .CROSSWALK
}
