# get-price

## Introduction

หัวข้อนี้จะเจาะลึกการใช้งานกลุ่มฟังก์ชัน `get_*_prices` ซึ่งประกอบด้วย
[`get_daily_prices()`](https://kanthanawit.github.io/talatThaiR/reference/get_daily_prices.md),
[`get_weekly_prices()`](https://kanthanawit.github.io/talatThaiR/reference/get_weekly_prices.md),
และ
[`get_monthly_prices()`](https://kanthanawit.github.io/talatThaiR/reference/get_monthly_prices.md)

## กฎข้อสำคัญ

**การค้นหาจะรับพารามิเตอร์หลักเพียงโหมดเดียวเท่านั้น** - คุณไม่สามารถใช้
`category_code` ร่วมกับ `product_code` ได้

ก่อนเริ่มต้นดึงข้อมูล คุณควรตรวจสอบรหัสที่ต้องการจากฟังก์ชัน `show_*()` ที่เหมาะสม: -
[`show_daily_categories()`](https://kanthanawit.github.io/talatThaiR/reference/show_daily_categories.md)
/
[`show_daily_products()`](https://kanthanawit.github.io/talatThaiR/reference/show_daily_products.md) -
สำหรับรายวัน -
[`show_weekly_categories()`](https://kanthanawit.github.io/talatThaiR/reference/show_weekly_categories.md)
/
[`show_weekly_products()`](https://kanthanawit.github.io/talatThaiR/reference/show_weekly_products.md) -
สำหรับรายสัปดาห์และรายเดือน

``` r

library(talatThaiR)
library(tidyverse)
#> ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
#> ✔ dplyr     1.2.0     ✔ readr     2.2.0
#> ✔ forcats   1.0.1     ✔ stringr   1.6.0
#> ✔ ggplot2   4.0.2     ✔ tibble    3.3.1
#> ✔ lubridate 1.9.5     ✔ tidyr     1.3.2
#> ✔ purrr     1.2.1     
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

# ตรวจสอบรหัสที่มี
show_daily_categories()
#>         Code          Name
#> 1     SHRIMP         กุ้งขาว
#> 2  PINEAPPLE  สับปะรดโรงงาน
#> 3       CORN ข้าวโพดเลี้ยงสัตว์
#> 4    CHICKEN            ไก่
#> 5     RUBBER       ยางพารา
#> 6  RICE_MALI     ข้าวหอมมะลิ
#> 7       COCO        มะพร้าว
#> 8        EGG          ไข่ไก่
#> 9       PALM      ปาล์มน้ำมัน
#> 10    LONGAN          ลำไย
#> 11   CASSAVA     มันสำปะหลัง
#> 12      LIME         มะนาว
#> 13      PORK           สุกร
show_weekly_products()
#>                  Code                          Name
#> 1           BUFFALO_M                กระบือ ขนาดกลาง
#> 2        SHRIMP_71_80     กุ้งขาวแวนนาไม 71-80 ตัว/กก.
#> 3      CHICK_MEAT_IND           ไก่รุ่นพันธุ์เนื้อ ฟาร์มอิสระ
#> 4       RICE_PADDY_15         ข้าวเปลือกเจ้า ความชื้น 15
#> 5  RICE_MALI_PADDY_15   ข้าวเปลือกเจ้าหอมมะลิ ความชื้น 15
#> 6      CORN_SEED_14_5 ข้าวโพดเลี้ยงสัตว์เมล็ด ความชื้น 14.5
#> 7           EGG_MIXED                    ไข่ไก่สด คละ
#> 8               EGG_3                 ไข่ไก่สด เบอร์ 3
#> 9            CATTLE_M           โคพันธุ์ลูกผสม ขนาดกลาง
#> 10  RUBBER_LIQUID_MIX                   น้ำยางสด คละ
#> 11         PALM_MIXED         ผลปาล์มน้ำมันทั้งทะลาย คละ
#> 12   PEPPER_BLACK_MIX                  พริกไทยดำ คละ
#> 13         COCO_DRY_L                 มะพร้าวแห้ง ใหญ่
#> 14  CASSAVA_FRESH_MIX               มันสำปะหลังสด คละ
#> 15   CASSAVA_CHIP_MIX                     มันเส้น คละ
#> 16    RUBBER_LUMP_MIX                    ยางก้อน คละ
#> 17     RUBBER_SHEET_3                 ยางแผ่นดิบ ชั้น 3
#> 18      LONGAN_EDOR_A       ลำไยสดทั้งช่อพันธุ์อีดอ เกรด A
#> 19     LONGAN_EDOR_AA      ลำไยสดทั้งช่อพันธุ์อีดอ เกรด AA
#> 20   RUBBER_SCRAP_MIX                    เศษยาง คละ
#> 21      PINEAPPLE_FAC                  สับปะรดโรงงาน
#> 22      PORK_LIVE_100      สุกรมีชีวิต น้ำหนักเกิน 100 กก.
```

------------------------------------------------------------------------

## ราคาสินค้ารายวัน (get_daily_prices)

ฟังก์ชันนี้มีความยืดหยุ่นสูง โดยรองรับโหมดการค้นหา 3 แบบ:

| โหมด     | พารามิเตอร์       | คำอธิบาย                     |
|----------|-----------------|-----------------------------|
| Category | `category_code` | ค้นหาตามหมวดหมู่               |
| Product  | `product_code`  | ค้นหาตามสินค้า                 |
| Date     | `date`          | ดึงข้อมูลสินค้าทุกชนิดที่มีในวันที่กำหนด |

### โหมดที่ 1: ค้นหาด้วย Category

ค้นหาราคาของสินค้าทั้งหมดในหมวดหมู่หนึ่ง

``` r

# ดึงข้อมูลราคาข้าวหอมมะลิทุกขนาด ทั้งหมดที่มี
rice_mali_all <- get_daily_prices(category_code = "RICE_MALI")
#> Found 1734 records (18 page(s)) — fetching...
#>   Fetching page 2 / 18
#>   Fetching page 3 / 18
#>   Fetching page 4 / 18
#>   Fetching page 5 / 18
#>   Fetching page 6 / 18
#>   Fetching page 7 / 18
#>   Fetching page 8 / 18
#>   Fetching page 9 / 18
#>   Fetching page 10 / 18
#>   Fetching page 11 / 18
#>   Fetching page 12 / 18
#>   Fetching page 13 / 18
#>   Fetching page 14 / 18
#>   Fetching page 15 / 18
#>   Fetching page 16 / 18
#>   Fetching page 17 / 18
#>   Fetching page 18 / 18
#> Done. 1734 records retrieved.
head(rice_mali_all)
#>    data_date day month year_th product_category          product_name
#> 1 2026-03-16  16     3    2569        ข้าวหอมมะลิ ข้าวเปลือกเจ้าหอมมะลิ 105
#> 2 2026-03-16  16     3    2569        ข้าวหอมมะลิ ข้าวเปลือกเจ้าหอมมะลิ 105
#> 3 2026-03-16  16     3    2569        ข้าวหอมมะลิ ข้าวเปลือกเจ้าหอมมะลิ 105
#> 4 2026-03-16  16     3    2569        ข้าวหอมมะลิ ข้าวเปลือกเจ้าหอมมะลิ 105
#> 5 2026-03-16  16     3    2569        ข้าวหอมมะลิ ข้าวเปลือกเจ้าหอมมะลิ 105
#> 6 2026-03-16  16     3    2569        ข้าวหอมมะลิ ข้าวเปลือกเจ้าหอมมะลิ 105
#>                market_name  province day_price   unit
#> 1        โรงสีไฟไทยเจริญวัฒนา อำนาจเจริญ     17500 บาท/ตัน
#> 2            โรงสีกิจทวียโสธร     ยโสธร     15400 บาท/ตัน
#> 3 โรงสีสหกรณ์การเกษตรสุวรรณภูมิ    ร้อยเอ็ด     16700 บาท/ตัน
#> 4               โรงสีสหพัฒนา     บุรีรัมย์     17300 บาท/ตัน
#> 5             ท่าข้าว ธ.ก.ส.    ขอนแก่น     17000 บาท/ตัน
#> 6      โรงสีราษีพาณิชย์ศรีสะเกษ   ศรีสะเกษ     16800 บาท/ตัน

# ดูสถิติพื้นฐาน
nrow(rice_mali_all)      # จำนวนระเบียน
#> [1] 1734
summary(rice_mali_all$day_price)  # สถิติราคา
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>   13560   15400   16000   15910   16500   17500
```

### โหมดที่ 2: ค้นหาด้วย Product

ค้นหาราคาของสินค้าระดับตัวเฉพาะ

``` r

# ดึงข้อมูลราคามะนาวขนาด XL
lime_xl <- get_daily_prices(product_code = "LIME_XL")
#> Found 290 records (3 page(s)) — fetching...
#>   Fetching page 2 / 3
#>   Fetching page 3 / 3
#> Done. 290 records retrieved.
head(lime_xl)
#>    data_date day month year_th product_category        product_name
#> 1 2026-03-16  16     3    2569            มะนาว มะนาว ผลขนาดใหญ่พิเศษ
#> 2 2026-03-13  13     3    2569            มะนาว มะนาว ผลขนาดใหญ่พิเศษ
#> 3 2026-03-12  12     3    2569            มะนาว มะนาว ผลขนาดใหญ่พิเศษ
#> 4 2026-03-11  11     3    2569            มะนาว มะนาว ผลขนาดใหญ่พิเศษ
#> 5 2026-03-10  10     3    2569            มะนาว มะนาว ผลขนาดใหญ่พิเศษ
#> 6 2026-03-09   9     3    2569            มะนาว มะนาว ผลขนาดใหญ่พิเศษ
#>       market_name province day_price      unit
#> 1 ตลาดกลางหนองบ้วย   เพชรบุรี       500 บาท/ร้อยผล
#> 2 ตลาดกลางหนองบ้วย   เพชรบุรี       350 บาท/ร้อยผล
#> 3 ตลาดกลางหนองบ้วย   เพชรบุรี       350 บาท/ร้อยผล
#> 4 ตลาดกลางหนองบ้วย   เพชรบุรี       350 บาท/ร้อยผล
#> 5 ตลาดกลางหนองบ้วย   เพชรบุรี       350 บาท/ร้อยผล
#> 6 ตลาดกลางหนองบ้วย   เพชรบุรี       350 บาท/ร้อยผล

# ดึงข้อมูลราคาไข่ไก่ (เบอร์ 3)
egg_3 <- get_daily_prices(product_code = "EGG_3")
#> Found 290 records (3 page(s)) — fetching...
#>   Fetching page 2 / 3
#>   Fetching page 3 / 3
#> Done. 290 records retrieved.
head(egg_3)
#>    data_date day month year_th product_category product_name  market_name
#> 1 2026-03-16  16     3    2569             ไข่ไก่  ไข่ไก่ เบอร์ 3 นายสมาน ทองดี
#> 2 2026-03-13  13     3    2569             ไข่ไก่  ไข่ไก่ เบอร์ 3 นายสมาน ทองดี
#> 3 2026-03-12  12     3    2569             ไข่ไก่  ไข่ไก่ เบอร์ 3 นายสมาน ทองดี
#> 4 2026-03-11  11     3    2569             ไข่ไก่  ไข่ไก่ เบอร์ 3 นายสมาน ทองดี
#> 5 2026-03-10  10     3    2569             ไข่ไก่  ไข่ไก่ เบอร์ 3 นายสมาน ทองดี
#> 6 2026-03-09   9     3    2569             ไข่ไก่  ไข่ไก่ เบอร์ 3 นายสมาน ทองดี
#>    province day_price       unit
#> 1 นครราชสีมา    353.33 บาท/ร้อยฟอง
#> 2 นครราชสีมา    353.33 บาท/ร้อยฟอง
#> 3 นครราชสีมา    353.33 บาท/ร้อยฟอง
#> 4 นครราชสีมา    353.33 บาท/ร้อยฟอง
#> 5 นครราชสีมา    353.33 บาท/ร้อยฟอง
#> 6 นครราชสีมา    353.33 บาท/ร้อยฟอง
```

### โหมดที่ 3: ดึงข้อมูลทุกอย่างในวันที่กำหนด

ดึงราคาของสินค้าทุกประเภทหลักในวันที่ระบุ

``` r

# ดึงข้อมูลราคาสินค้าทุกชนิดของวันนี้
all_prices_today <- get_daily_prices(date = as.character(Sys.Date()))
#> Found 56 records (1 page(s)) — fetching...
#> Done. 56 records retrieved.
head(all_prices_today)
#>    data_date day month year_th product_category                product_name
#> 1 2026-03-16  16     3    2569            กุ้งขาว กุ้งขาวแวนนาไม ขนาด 70 ตัว/กก.
#> 2 2026-03-16  16     3    2569            กุ้งขาว กุ้งขาวแวนนาไม ขนาด 70 ตัว/กก.
#> 3 2026-03-16  16     3    2569        ข้าวหอมมะลิ       ข้าวเปลือกเจ้าหอมมะลิ 105
#> 4 2026-03-16  16     3    2569        ข้าวหอมมะลิ       ข้าวเปลือกเจ้าหอมมะลิ 105
#> 5 2026-03-16  16     3    2569        ข้าวหอมมะลิ       ข้าวเปลือกเจ้าหอมมะลิ 105
#> 6 2026-03-16  16     3    2569        ข้าวหอมมะลิ       ข้าวเปลือกเจ้าหอมมะลิ 105
#>                market_name  province day_price    unit
#> 1       ตลาดกลางกุ้งสมุทรสาคร  สมุทรสาคร       135 บาท/กก.
#> 2              ร้านสินงอกงาม ฉะเชิงเทรา       140 บาท/กก.
#> 3             ท่าข้าว ธ.ก.ส.    ขอนแก่น     17000  บาท/ตัน
#> 4            โรงสีกิจทวียโสธร     ยโสธร     15400  บาท/ตัน
#> 5      โรงสีราษีพาณิชย์ศรีสะเกษ   ศรีสะเกษ     16800  บาท/ตัน
#> 6 โรงสีสหกรณ์การเกษตรสุวรรณภูมิ    ร้อยเอ็ด     16700  บาท/ตัน

# ดึงข้อมูลของวันที่เฉพาะ
all_prices_date <- get_daily_prices(date = "2026-01-15")
#> Found 58 records (1 page(s)) — fetching...
#> Done. 58 records retrieved.
head(all_prices_date)
#>    data_date day month year_th product_category                product_name
#> 1 2026-01-15  15     1    2569            กุ้งขาว กุ้งขาวแวนนาไม ขนาด 70 ตัว/กก.
#> 2 2026-01-15  15     1    2569            กุ้งขาว กุ้งขาวแวนนาไม ขนาด 70 ตัว/กก.
#> 3 2026-01-15  15     1    2569        ข้าวหอมมะลิ       ข้าวเปลือกเจ้าหอมมะลิ 105
#> 4 2026-01-15  15     1    2569        ข้าวหอมมะลิ       ข้าวเปลือกเจ้าหอมมะลิ 105
#> 5 2026-01-15  15     1    2569        ข้าวหอมมะลิ       ข้าวเปลือกเจ้าหอมมะลิ 105
#> 6 2026-01-15  15     1    2569        ข้าวหอมมะลิ       ข้าวเปลือกเจ้าหอมมะลิ 105
#>                market_name  province day_price    unit
#> 1       ตลาดกลางกุ้งสมุทรสาคร  สมุทรสาคร       160 บาท/กก.
#> 2              ร้านสินงอกงาม ฉะเชิงเทรา       165 บาท/กก.
#> 3             ท่าข้าว ธ.ก.ส.    ขอนแก่น     16000  บาท/ตัน
#> 4            โรงสีกิจทวียโสธร     ยโสธร     15400  บาท/ตัน
#> 5      โรงสีราษีพาณิชย์ศรีสะเกษ   ศรีสะเกษ     16000  บาท/ตัน
#> 6 โรงสีสหกรณ์การเกษตรสุวรรณภูมิ    ร้อยเอ็ด     16700  บาท/ตัน
```

### การกรองด้วยช่วงเวลา (Date Filtering)

หากคุณค้นหาด้วยรหัส (category_code หรือ product_code) คุณสามารถกำหนด
`start_date` และ `end_date` เพื่อจำกัดผลลัพธ์ได้

``` r

# ดึงข้อมูลราคาข้าวหอมมะลิ ตั้งแต่ 1 มค. 2026 เป็นต้นไป
rice_mali_2026 <- get_daily_prices(
  category_code = "RICE_MALI",
  start_date = "2026-01-01"
)
#> Found 1734 records (18 page(s)) — fetching...
#>   Fetching page 2 / 18
#>   Fetching page 3 / 18
#>   Fetching page 4 / 18
#>   Fetching page 5 / 18
#>   Fetching page 6 / 18
#>   Fetching page 7 / 18
#>   Fetching page 8 / 18
#>   Fetching page 9 / 18
#>   Fetching page 10 / 18
#>   Fetching page 11 / 18
#>   Fetching page 12 / 18
#>   Fetching page 13 / 18
#>   Fetching page 14 / 18
#>   Fetching page 15 / 18
#>   Fetching page 16 / 18
#>   Fetching page 17 / 18
#>   Fetching page 18 / 18
#> Done. 300 records retrieved.

# ดึงข้อมูลในช่วงเวลาที่ระบุ
lime_range <- get_daily_prices(
  product_code = "LIME_M",
  start_date = "2026-01-01",
  end_date = "2026-03-31"
)
#> Found 290 records (3 page(s)) — fetching...
#>   Fetching page 2 / 3
#>   Fetching page 3 / 3
#> Done. 50 records retrieved.

# end_date ค่าเริ่มต้นคือวันนี้ ถ้าไม่ระบุ
tomorrow_range <- get_daily_prices(
  category_code = "CHICKEN",
  start_date = "2026-01-01"
  # end_date จะเป็นวันนี้อัตโนมัติ
)
#> Found 570 records (6 page(s)) — fetching...
#>   Fetching page 2 / 6
#>   Fetching page 3 / 6
#>   Fetching page 4 / 6
#>   Fetching page 5 / 6
#>   Fetching page 6 / 6
#> Done. 96 records retrieved.
```

#### ตัวอย่าง: การวิเคราะห์แนวโน้ราคา

``` r

# ดึงข้อมูลและคำนวณแนวโน้
lime_daily <- get_daily_prices(
  product_code = "LIME_M",
  start_date = "2026-01-01",
  end_date = "2026-03-31"
)
#> Found 290 records (3 page(s)) — fetching...
#>   Fetching page 2 / 3
#>   Fetching page 3 / 3
#> Done. 50 records retrieved.

# วิเคราะห์แนวโน้ราคา

trend_analysis <- lime_daily |>
  dplyr::mutate(data_date = as.Date(data_date)) |>
  dplyr::arrange(data_date) |>
  dplyr::mutate(
    moving_avg_7 = stats::filter(day_price, rep(1/7, 7), sides = 2),
    price_diff   = day_price - dplyr::lag(day_price, 1)
  ) |>
  dplyr::select(data_date, day_price, moving_avg_7, price_diff)

head(trend_analysis)
#>    data_date day_price moving_avg_7 price_diff
#> 1 2026-01-05       130           NA         NA
#> 2 2026-01-06       130           NA          0
#> 3 2026-01-07       130           NA          0
#> 4 2026-01-08       130          130          0
#> 5 2026-01-09       130          130          0
#> 6 2026-01-12       130          130          0
```

------------------------------------------------------------------------

## ราคาสินค้ารายสัปดาห์ (get_weekly_prices)

สำหรับรายสัปดาห์ การระบุเวลาจะใช้**ปีพุทธศักราช (year_th)** และ**เดือน (month)**
แทนรูปแบบวันที่

| โหมด     | พารามิเตอร์           | คำอธิบาย                 |
|----------|---------------------|-------------------------|
| Category | `category_code`     | ค้นหาตามหมวดหมู่           |
| Product  | `product_code`      | ค้นหาตามสินค้า             |
| Date     | `year_th` + `month` | ค้นหาของทุกสินค้าในเดือนที่ระบุ |

### ข้อควรระวัง

1.  **`year_th` และ `month` ต้องระบุคู่กันเสมอ**
    เมื่อใช้ร่วมกันหรือใช้แยกเป็นโหมดสุดท้าย
2.  **`month` ไม่สามารถระบุเดี่ยวๆ ได้** ต้องมี `year_th` กำกับเสมอ

### ตัวอย่างการใช้งาน

#### โหมด Standalone: ดึงข้อมูลทุกสินค้าในเดือนหนึ่ง

``` r

# ดึงข้อมูลสัปดาห์ของสินค้าทั้งหมดในเดือน 2 ปี 2569
all_weekly_feb2569 <- get_weekly_prices(year_th = 2569, month = 2)
#> Found 88 records (1 page(s)) — fetching...
#> Done. 88 records retrieved.

# ดูว่ามีสินค้าอะไรบ้างในข้อมูล
unique(all_weekly_feb2569$product_name)
#>  [1] "ยางแผ่นดิบ ชั้น 3"                 "สับปะรดโรงงาน"                 
#>  [3] "พริกไทยดำ คละ"                  "สุกรมีชีวิต น้ำหนักเกิน 100 กก."     
#>  [5] "มะพร้าวแห้ง ใหญ่"                 "ยางก้อน คละ"                   
#>  [7] "มันสำปะหลังสด คละ"               "ข้าวเปลือกเจ้า ความชื้น 15"        
#>  [9] "มันเส้น คละ"                     "ข้าวเปลือกเจ้าหอมมะลิ ความชื้น 15"  
#> [11] "เศษยาง คละ"                    "ข้าวโพดเลี้ยงสัตว์เมล็ด ความชื้น 14.5"
#> [13] "กุ้งขาวแวนนาไม 71-80 ตัว/กก."     "ไข่ไก่สด คละ"                   
#> [15] "ลำไยสดทั้งช่อพันธุ์อีดอ เกรด AA"      "ไข่ไก่สด เบอร์ 3"                
#> [17] "กระบือ ขนาดกลาง"                "โคพันธุ์ลูกผสม ขนาดกลาง"          
#> [19] "ลำไยสดทั้งช่อพันธุ์อีดอ เกรด A"       "น้ำยางสด คละ"                  
#> [21] "ไก่รุ่นพันธุ์เนื้อ ฟาร์มอิสระ"           "ผลปาล์มน้ำมันทั้งทะลาย คละ"
```

#### โหมด Category: ค้นหาด้วยหมวดหมู่

``` r

# ดึงข้อมูลรายสัปดาห์ของหมวดกระบือ เฉพาะเดือน 2 ปี 2569
buffalo_weekly <- get_weekly_prices(
  category_code = "BUFFALO",
  year_th = 2569,
  month = 1
)
#> Found 4 records (1 page(s)) — fetching...
#> Done. 4 records retrieved.

# สถิติราคากระบือรายสัปดาห์
summary(buffalo_weekly)
#>     year_th         month        week      province_code     
#>  Min.   :2569   Min.   :1   Min.   :1.00   Length:4          
#>  1st Qu.:2569   1st Qu.:1   1st Qu.:1.75   Class :character  
#>  Median :2569   Median :1   Median :2.50   Mode  :character  
#>  Mean   :2569   Mean   :1   Mean   :2.50                     
#>  3rd Qu.:2569   3rd Qu.:1   3rd Qu.:3.25                     
#>  Max.   :2569   Max.   :1   Max.   :4.00                     
#>  province_name      product_name          commod           subcommod        
#>  Length:4           Length:4           Length:4           Length:4          
#>  Class :character   Class :character   Class :character   Class :character  
#>  Mode  :character   Mode  :character   Mode  :character   Mode  :character  
#>                                                                             
#>                                                                             
#>                                                                             
#>      value           unit          
#>  Min.   :25617   Length:4          
#>  1st Qu.:25673   Class :character  
#>  Median :25699   Mode  :character  
#>  Mean   :25781                     
#>  3rd Qu.:25806                     
#>  Max.   :26109
```

#### โหมด Product: ค้นหาด้วยสินค้า

``` r

# ดึงข้อมูลรายสัปดาห์ของสุกรมีชีวิต
pork_weekly <- get_weekly_prices(product_code = "PORK_LIVE_100")
#> Found 773 records (8 page(s)) — fetching...
#>   Fetching page 2 / 8
#>   Fetching page 3 / 8
#>   Fetching page 4 / 8
#>   Fetching page 5 / 8
#>   Fetching page 6 / 8
#>   Fetching page 7 / 8
#>   Fetching page 8 / 8
#> Done. 773 records retrieved.

# กรองเฉพาะปี 2569
pork_weekly_2569 <- pork_weekly |>
  dplyr::filter(year_th == "2569")

# ดูราคาเฉลี่ยในแต่ละเดือน
pork_monthly_avg <- pork_weekly_2569 |>
  dplyr::group_by(month) |>
  dplyr::summarise(
    avg_price = mean(value),
    min_price = min(value),
    max_price = max(value)
  )
print(pork_monthly_avg)
#> # A tibble: 3 × 4
#>   month avg_price min_price max_price
#>   <int>     <dbl>     <dbl>     <dbl>
#> 1     1      66.2      64.0      68.2
#> 2     2      58.9      57.0      61.8
#> 3     3      57.5      57.2      57.7
```

------------------------------------------------------------------------

## ราคาสินค้ารายเดือน (get_monthly_prices)

รายเดือนใช้โครงสร้างคล้ายกับรายสัปดาห์ แต่มีความแตกต่างที่สำคัญ:

| ความแตกต่าง | รายสัปดาห์ | รายเดือน |
|----|----|----|
| การระบุ `month` | ไม่สามารถระบุเดี่ยวๆ | ไม่สามารถระบุเดี่ยวๆ ต้องมี `year_th` กำกับ |
| ระดับต่ำสุด | ใช้ `year_th` + `month` แยกเป็นโหมดสุดท้าย | ใช้ `year_th` + `month` แยกเป็นโหมดสุดท้าย |

### ตัวอย่างการใช้งาน

#### ดึงข้อมูลรายเดือนของหมวดหมู่

``` r

# ดึงข้อมูลหมวดกระบือรายเดือน (ข้อมูลทั้งหมดที่มี)
buffalo_monthly_all <- get_monthly_prices(category_code = "BUFFALO")
#> Found 182 records (2 page(s)) — fetching...
#>   Fetching page 2 / 2
#> Done. 182 records retrieved.

# วิเคราะห์แนวโน้ราคาระยเดือน
buffalo_trend <- buffalo_monthly_all |>
  dplyr::arrange(month, year_th)

head(buffalo_trend)
#>   year_th month week province_code province_name   product_name commod
#> 1    2554     1    0          TH00     ประเทศไทย กระบือ ขนาดกลาง  กระบือ
#> 2    2555     1    0          TH00     ประเทศไทย กระบือ ขนาดกลาง  กระบือ
#> 3    2556     1    0          TH00     ประเทศไทย กระบือ ขนาดกลาง  กระบือ
#> 4    2557     1    0          TH00     ประเทศไทย กระบือ ขนาดกลาง  กระบือ
#> 5    2558     1    0          TH00     ประเทศไทย กระบือ ขนาดกลาง  กระบือ
#> 6    2559     1    0          TH00     ประเทศไทย กระบือ ขนาดกลาง  กระบือ
#>   subcommod    value   unit
#> 1     กระบือ 16573.63 บาท/ตัว
#> 2     กระบือ 23576.27 บาท/ตัว
#> 3     กระบือ 24945.10 บาท/ตัว
#> 4     กระบือ 27275.32 บาท/ตัว
#> 5     กระบือ 38871.35 บาท/ตัว
#> 6     กระบือ 41516.51 บาท/ตัว
```

#### ดึงข้อมูลรายเดือนพร้อมกรองปี

``` r

# ดึงข้อมูลสินค้ารายเดือน เฉพาะปี 2569
pork_monthly_2569 <- get_monthly_prices(
  product_code = "PORK_LIVE_100",
  year_th = 2569
)
#> Found 2 records (1 page(s)) — fetching...
#> Done. 2 records retrieved.

# เปรียบเทียบราคาเฉลี่ยเดือน
pork_monthly_2569 |>
  dplyr::arrange(month) |>
  dplyr::select(year_th, month, value)
#>   year_th month value
#> 1    2569     1 66.18
#> 2    2569     2 58.92
```

#### ดึงข้อมูลรายเดือนพร้อมกรองทั้งปีและเดือน

``` r

# กรองข้อมูลเฉพาะไตรมาสที่ 1 ของทุกปี
q1_cassava <- get_monthly_prices(
  category_code = "CASSAVA"
) |>
  dplyr::filter(month %in% 1:3)
#> Found 364 records (4 page(s)) — fetching...
#>   Fetching page 2 / 4
#>   Fetching page 3 / 4
#>   Fetching page 4 / 4
#> Done. 364 records retrieved.

# คำนวณราคาเฉลี่ยไตรมาส
q1_avg <- q1_cassava |>
  dplyr::group_by(year_th) |>
  dplyr::summarise(
    q1_avg = mean(value, na.rm = TRUE),
    q1_min = min(value, na.rm = TRUE),
    q1_max = max(value, na.rm = TRUE)
  )
print(q1_avg)
#> # A tibble: 16 × 4
#>    year_th q1_avg q1_min q1_max
#>      <int>  <dbl>  <dbl>  <dbl>
#>  1    2554   4.08   2.82   5.59
#>  2    2555   3.36   1.75   5.19
#>  3    2556   3.52   2.01   5.04
#>  4    2557   3.66   2.13   5.23
#>  5    2558   3.75   2.15   5.51
#>  6    2559   3.36   1.76   4.99
#>  7    2560   2.88   1.48   4.28
#>  8    2561   3.60   2.01   5.22
#>  9    2562   3.78   2.15   5.63
#> 10    2563   3.48   1.89   5.16
#> 11    2564   4.00   2.03   5.97
#> 12    2565   4.36   2.28   6.6 
#> 13    2566   5.14   2.7    7.46
#> 14    2567   5.25   3.01   7.56
#> 15    2568   3.68   1.72   5.7 
#> 16    2569   4.09   2.26   5.94
```

------------------------------------------------------------------------

## Advanced Use Cases

### เปรียบเทียบราคาระหว่างสินค้า

``` r

# ดึงข้อมูลราคาข้าวหอมมะลิและข้าวเปลือกเจ้า ในช่วงเวลาเดียวกัน
cassava_prices_20260101_20260201 <- get_daily_prices(
  category_code = "CASSAVA",
  start_date = "2026-01-01",
  end_date = "2026-02-01"
)
#> Found 1944 records (20 page(s)) — fetching...
#>   Fetching page 2 / 20
#>   Fetching page 3 / 20
#>   Fetching page 4 / 20
#>   Fetching page 5 / 20
#>   Fetching page 6 / 20
#>   Fetching page 7 / 20
#>   Fetching page 8 / 20
#>   Fetching page 9 / 20
#>   Fetching page 10 / 20
#>   Fetching page 11 / 20
#>   Fetching page 12 / 20
#>   Fetching page 13 / 20
#>   Fetching page 14 / 20
#>   Fetching page 15 / 20
#>   Fetching page 16 / 20
#>   Fetching page 17 / 20
#>   Fetching page 18 / 20
#>   Fetching page 19 / 20
#>   Fetching page 20 / 20
#> Done. 135 records retrieved.

# เรียกชื่อข้าวทุกชนิดในหมวด
cassava_names <- show_daily_products() |>
  dplyr::filter(grepl("^CASSAVA", Code)) |>
  dplyr::pull(Name)

cassava_prices_20260101_20260201 |> 
  dplyr::summarise(avg_price = mean(day_price, na.rm = TRUE), .by = product_name)
#>              product_name avg_price
#> 1 หัวมันสำปะหลังสด (แป้ง 30%)  2.689091
#> 2 หัวมันสำปะหลังสด (แป้ง 25%)  2.425316
#> 3       หัวมันสำปะหลังสด คละ  2.200000
```

### การติดตามราคาสินค้าหลายชนิด

``` r

# สร้างฟังก์ชันสำหรับติดตามราคา
track_prices <- function(product_code, start_date, end_date) {
  get_daily_prices(
    product_code = product_code,
    start_date = start_date,
    end_date = end_date
  ) |>
    dplyr::mutate(
      product_code = product_code,
      data_date = as.Date(data_date)
    ) |>
    dplyr::select(product_code, data_date, day_price, year_th, month)
}

# ติดตามราคามะนาวหลายขนาด พร้อมกัน
products_to_track <- c("LIME_XL", "LIME_S")

XL_vs_S_lime_prices <- purrr::map_dfr(
  products_to_track,
  track_prices,
  start_date = "2026-01-01",
  end_date   = "2026-02-01"
)
#> Found 290 records (3 page(s)) — fetching...
#>   Fetching page 2 / 3
#>   Fetching page 3 / 3
#> Done. 20 records retrieved.
#> Found 290 records (3 page(s)) — fetching...
#>   Fetching page 2 / 3
#>   Fetching page 3 / 3
#> Done. 20 records retrieved.
```

------------------------------------------------------------------------

## Tips and Best Practices

1.  **เริ่มจาก `show_*()` เสมอ** - ตรวจสอบรหัสที่มีก่อนดึงข้อมูล
2.  **ใช้ `start_date` และ `end_date` สำหรับช่วงเวลา** -
    ดึงเฉพาะข้อมูลที่ต้องการเพื่อประหบเวลาและประหบเครือขาง
3.  **ตรวจสอบปีพุทธศักราช** - รายสัปดาห์และรายเดือนใช้ `year_th` (พ.ศ.)
4.  **สังเกตปัญหาของ Pagination** - ข้อมูลจำนวนมากจะดึงช้ากว่าปกติ
5.  **จัดเก็บข้อมูล** - ถ้าดึงข้อมูลบ่อย ควรจัดเก็บลงไฟล์เพื่อไม่ต้องดึงซ้ำ
