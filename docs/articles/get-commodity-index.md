# get-commodity-index

## Introduction

talatThaiR มีกลุ่มฟังก์ชันสำหรับดึงข้อมูลดัชนีชี้วัด 2 ประเภทหลัก ได้แก่ **Price Index
(ดัชนีราคา)** และ **Production Index (ดัชนีผลผลิต)**
โดยแบ่งความละเอียดออกเป็นรายเดือน (\_month), รายไตรมาส (\_quarter), และรายปี
(\_year)

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
```

------------------------------------------------------------------------

## ลำดับชั้นของดัชนี (Index Hierarchy)

โหมดการค้นหาของดัชนีถูกแบ่งออกเป็น 4 ระดับ (Endpoints) ซึ่งคุณต้องเลือกใช้เพียง 1
โหมดเท่านั้น:

| ระดับ | พารามิเตอร์ | คำอธิบาย | ตัวอย่าง |
|----|----|----|----|
| Sector | `sector = TRUE` | ภาพรวมระดับมหภาค (ใหญ่ที่สุด) | `LIVESTOCK`, `FISHERY`, `MAJOR_CROP` |
| Category | `category_code` | หมวดสินค้า | `LIVESTOCK`, `FISHERY`, `MAJOR_CROP` |
| Group | `group_code` | กลุ่มสินค้าย่อย | `OIL_CROP`, `VEGETABLE`, `FRUIT` |
| Product | `product_code` | สินค้าระดับตัว | `BANANA_HOM_THONG`, `GARLIC_DRY_MIX` |

นอกจากนี้ ยังมีโหมด **Standalone Date** ซึ่งใช้ `year_th` คู่กับ `month` หรือ
`quarter` เพื่อดึงดัชนีของสินค้าทุกตัวในช่วงเวลาที่ระบุ

------------------------------------------------------------------------

## ตรวจสอบรหัสดัชนี

ก่อนใช้ฟังก์ชันดัชนี คุณสามารถตรวจสอบรหัสที่มี:

``` r

# สำหรับดัชนีรายเดือน/รายปี
show_index_categories()   # หมวด: LIVESTOCK, FISHERY, MAJOR_CROP
#>         Code         Name
#> 1    FISHERY    หมวดประมง
#> 2  LIVESTOCK    หมวดปศุสัตว์
#> 3 MAJOR_CROP หมวดพืชผลสำคัญ
show_index_groups()       # กลุ่ม: OIL_CROP, VEGETABLE, FRUIT, etc.
#>             Code              Name
#> 1 GRAIN_AND_FOOD กลุ่มธัญพืชและพืชอาหาร
#> 2       OIL_CROP         กลุ่มพืชน้ำมัน
#> 3      VEGETABLE           กลุ่มพืชผัก
#> 4         FLOWER        กลุ่มพืชไม้ดอก
#> 5          FRUIT           กลุ่มไม้ผล
#> 6      PERENNIAL         กลุ่มไม้ยืนต้น
#> 7        FISHERY         หมวดประมง
#> 8      LIVESTOCK         หมวดปศุสัตว์
show_index_products()     # สินค้ารายเดือน/ปี: BANANA_HOM_THONG, GARLIC_DRY_MIX, etc.
#>                   Code                         Name
#> 1       GARLIC_DRY_MIX               กระเทียมแห้ง คละ
#> 2         ORCHID_45_54 กล้วยไม้ ก้านช่อดอกยาว 45-54 ซม.
#> 3     BANANA_HOM_THONG                   กล้วยหอมทอง
#> 4            SHRIMP_70     กุ้งขาวแวนนาไม (70 ตัว/กก.)
#> 5           CHICK_MEAT                   ไก่รุ่นพันธุ์เนื้อ
#> 6           RICE_PADDY                     ข้าวเปลือก
#> 7        RICE_PADDY_15        ข้าวเปลือกเจ้า ความชื้น 15
#> 8  RICE_MALI_IN_SEASON         ข้าวเปลือกเจ้านาปีหอมมะลิ
#> 9     RICE_STICKY_LONG      ข้าวเปลือกเหนียวนาปีเมล็ดยาว
#> 10           CORN_14_5    ข้าวโพดเลี้ยงสัตว์ ความชื้น 14.5
#> 11           EGG_MIXED                   ไข่ไก่สด คละ
#> 12            CATTLE_M        โคพันธุ์ลูกผสม (ขนาดกลาง)
#> 13     RAMBUTAN_SCHOOL                  เงาะโรงเรียน
#> 14    MUNG_BEAN_GLOSSY                   ถั่วเขียวผิวมัน
#> 15          PEANUT_DRY               ถั่วลิสงเปลือก แห้ง
#> 16         SOYBEAN_MIX                  ถั่วเหลือง คละ
#> 17 DURIAN_MONTHONG_MIX              ทุเรียนหมอนทองคละ
#> 18          PALM_MIXED          ปาล์มน้ำมันทั้งทะลาย คละ
#> 19    PEPPER_BLACK_MIX                  พริกไทยดำคละ
#> 20       COCO_MATURE_L           มะพร้าวผลแก่ ขนาดใหญ่
#> 21     MANGO_NAMDOKMAI                 มะม่วงน้ำดอกไม้
#> 22      MANGOSTEEN_MIX                     มังคุด คละ
#> 23          POTATO_FAC                  มันฝรั่งโรงงาน
#> 24             CASSAVA                    มันสำปะหลัง
#> 25      RUBBER_SHEET_3                 ยางแผ่นดิบชั้น 3
#> 26          LONGKONG_1                ลองกอง เบอร์ 1
#> 27       LONGAN_EDOR_A      ลำไยสดทั้งช่อพันธุ์อีดอ เกรด A
#> 28   LYCHEE_HONGHUAY_A           ลิ้นจี่พันธุ์ฮงฮวย เกรด A
#> 29           TANGERINE                   ส้มเขียวหวาน
#> 30   PINEAPPLE_PAT_FAC        สับปะรดปัตตาเวียส่งโรงงาน
#> 31      COFFEE_ROBUSTA             สารกาแฟ (โรบัสต้า)
#> 32            PORK_100            สุกร (เกิน 100 กก.)
#> 33           SHALLOT_M                หอมแดง หัวกลาง
#> 34             ONION_1              หอมหัวใหญ่ เบอร์ 1
#> 35       SUGARCANE_FAC                    อ้อยโรงงาน

# สำหรับดัชนีรายไตรมาส (ใช้แยกต่างจากดัชนีรายเดือน/ปี)
show_quarter_products()   # สินค้ารายไตรมาส: GARLIC, ORCHID, COFFEE, etc.
#>                   Code                    Name
#> 1               GARLIC                 กระเทียม
#> 2               ORCHID                  กล้วยไม้
#> 3           BANANA_HOM                 กล้วยหอม
#> 4               COFFEE                    กาแฟ
#> 5      SHRIMP_VANNAMEI            กุ้งขาวแวนนาไม
#> 6              BROILER                   ไก่เนื้อ
#> 7           RICE_PADDY                ข้าวเปลือก
#> 8  RICE_PADDY_NON_GLUT             ข้าวเปลือกเจ้า
#> 9  RICE_MALI_IN_SEASON    ข้าวเปลือกเจ้านาปีหอมมะลิ
#> 10    RICE_STICKY_LONG ข้าวเปลือกเหนียวนาปีเมล็ดยาว
#> 11                CORN           ข้าวโพดเลี้ยงสัตว์
#> 12                 EGG                    ไข่ไก่
#> 13         BEEF_CATTLE                   โคเนื้อ
#> 14            RAMBUTAN                    เงาะ
#> 15           MUNG_BEAN              ถั่วเขียวผิวมัน
#> 16              PEANUT                   ถั่วลิสง
#> 17             SOYBEAN                 ถั่วเหลือง
#> 18              DURIAN                   ทุเรียน
#> 19            OIL_PALM                ปาล์มน้ำมัน
#> 20              PEPPER                  พริกไทย
#> 21             COCONUT                  มะพร้าว
#> 22               MANGO                   มะม่วง
#> 23          MANGOSTEEN                    มังคุด
#> 24              POTATO                   มันฝรั่ง
#> 25             CASSAVA               มันสำปะหลัง
#> 26              RUBBER                 ยางพารา
#> 27            LONGKONG                  ลองกอง
#> 28              LONGAN                    ลำไย
#> 29              LYCHEE                     ลิ้นจี่
#> 30              ORANGE                      ส้ม
#> 31           PINEAPPLE                  สับปะรด
#> 32                PORK                     สุกร
#> 33             SHALLOT                  หอมแดง
#> 34               ONION                หอมหัวใหญ่
#> 35           SUGARCANE                     อ้อย
```

------------------------------------------------------------------------

## ดัชนีราคา (Price Index Functions)

| ฟังก์ชัน | ช่วงเวลา | Endpoints ที่ใช้ |
|----|----|----|
| [`get_price_index_month()`](https://kanthjs.github.io/talatThaiR/reference/get_price_index_month.md) | รายเดือน | 5 (sector, category, group, product, all) |
| [`get_price_index_quarter()`](https://kanthjs.github.io/talatThaiR/reference/get_price_index_quarter.md) | รายไตรมาส | 5 (sector, category, group, product, all) |
| [`get_price_index_year()`](https://kanthjs.github.io/talatThaiR/reference/get_price_index_year.md) | รายปี | 5 (sector, category, group, product, all) |

### 1. การดึงข้อมูลระดับ Sector

เมื่อกำหนด `sector = TRUE` คุณจะได้รายชื่อสินค้าทั้งหมดในระบบ สามารถกรองด้วย
`year_th` (ยกเว้นรายปี)

``` r

# ดัชนีผลผลิตระดับ Sector รายเดือน
prod_sector_m <- get_production_index_month(sector = TRUE)
#> Found 252 records (3 page(s)) — fetching...
#>   Fetching page 2 / 3
#>   Fetching page 3 / 3
#> Done. 252 records retrieved.
head(prod_sector_m)
#>   year_th month product_sector product_category product_group       commod
#> 1    2568    12   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#> 2    2568    11   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#> 3    2568    10   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#> 4    2568     9   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#> 5    2568     8   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#> 6    2568     7   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#>   product_name production_index                data_date
#> 1 ภาคเกษตรกรรม         158.1943 2026-01-06T17:00:00.000Z
#> 2 ภาคเกษตรกรรม         319.9278 2026-01-06T17:00:00.000Z
#> 3 ภาคเกษตรกรรม         148.1487 2026-01-06T17:00:00.000Z
#> 4 ภาคเกษตรกรรม         130.6661 2026-01-06T17:00:00.000Z
#> 5 ภาคเกษตรกรรม         143.3562 2026-01-06T17:00:00.000Z
#> 6 ภาคเกษตรกรรม         128.7556 2026-01-06T17:00:00.000Z

# ดัชนีราคาระดับ Sector รายปี เฉพาะปี 2567
price_sector_y <- get_price_index_year(sector = TRUE, year_th = 2567)
#> Found 1 records (1 page(s)) — fetching...
#> Done. 1 records retrieved.
head(price_sector_y)
#>   year_th product_sector product_category product_group       commod
#> 1    2567   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#>   product_name price_index                data_date
#> 1 ภาคเกษตรกรรม    165.5918 2026-01-06T17:00:00.000Z

# ดัชนีราคาระดับ Sector รายปี ทุกปี
price_sector_all <- get_price_index_year(sector = TRUE)
#> Found 21 records (1 page(s)) — fetching...
#> Done. 21 records retrieved.
head(price_sector_all)
#>   year_th product_sector product_category product_group       commod
#> 1    2568   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#> 2    2567   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#> 3    2566   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#> 4    2565   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#> 5    2564   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#> 6    2563   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#>   product_name price_index                data_date
#> 1 ภาคเกษตรกรรม    149.2721 2026-01-06T17:00:00.000Z
#> 2 ภาคเกษตรกรรม    165.5918 2026-01-06T17:00:00.000Z
#> 3 ภาคเกษตรกรรม    153.6757 2026-01-06T17:00:00.000Z
#> 4 ภาคเกษตรกรรม    156.9453 2026-01-06T17:00:00.000Z
#> 5 ภาคเกษตรกรรม    140.5800 2026-01-06T17:00:00.000Z
#> 6 ภาคเกษตรกรรม    136.8270 2026-01-06T17:00:00.000Z
```

**หมายเหตุ:** - `get_production_index_year(sector = TRUE)`
ดึงได้เฉพาะหน้าแรกเท่านั้น (เนื่องจากข้อจำกัดของฐานข้อมูล) - หากต้องการดัชนีผลผลิตรายปี
แนะนำให้ใช้ `category_code` หรือ `group_code` แทน

### 2. การค้นหาตาม Category, Group, หรือ Product

คุณสามารถเลือกระดับความละเอียดที่ต้องการและกรองข้อมูลเพิ่มเติมด้วย `year_th`,
`month`, หรือ `quarter`

#### ดัชนีราคารายไตรมาส

``` r

# ค้นหาด้วย Category
idx_category <- get_price_index_quarter(
  category_code = "LIVESTOCK",
  quarter = 1
)
#> Found 21 records (1 page(s)) — fetching...
#> Done. 21 records retrieved.

# ค้นหาด้วย Group
idx_group <- get_production_index_month(
  group_code = "OIL_CROP",
  month = 6
)
#> Found 252 records (3 page(s)) — fetching...
#>   Fetching page 2 / 3
#>   Fetching page 3 / 3
#> Done. 252 records retrieved.

# ค้นหาด้วย Product
idx_product <- get_price_index_year(
  product_code = "GARLIC_DRY_MIX",
  year_th = 2568
)
#> Found 1 records (1 page(s)) — fetching...
#> Done. 1 records retrieved.
```

#### ดัชนีผลผลิตรายเดือน

``` r

# ค้นหาด้วย Category + month filter
prod_idx_cat_month <- get_production_index_month(
  category_code = "LIVESTOCK",
  month = 1
)
#> Found 252 records (3 page(s)) — fetching...
#>   Fetching page 2 / 3
#>   Fetching page 3 / 3
#> Done. 252 records retrieved.

# ค้นหาด้วย Group + month filter
prod_idx_group_month <- get_production_index_month(
  group_code = "OIL_CROP",
  month = 6
)
#> Found 252 records (3 page(s)) — fetching...
#>   Fetching page 2 / 3
#>   Fetching page 3 / 3
#> Done. 252 records retrieved.

# ค้นหาด้วย Product + month filter
prod_idx_prod_month <- get_production_index_month(
  product_code = "BANANA_HOM_THONG",
  month = 3
)
#> Found 252 records (3 page(s)) — fetching...
#>   Fetching page 2 / 3
#>   Fetching page 3 / 3
#> Done. 252 records retrieved.
```

### 3. โหมด Standalone Date (/all endpoint)

หากคุณไม่ใส่ Code หรือ Sector เลย แต่ระบุข้อมูลเวลา (เช่น ใส่แค่ `year_th` คู่กับ
`month` หรือ `quarter`) ระบบจะเปลี่ยนเป็นโหมดค้นหาดัชนีของสินค้าทุกตัวในช่วงเวลานั้นๆ

``` r

# ดึงดัชนีราคาของสินค้าทุกตัวในไตรมาสที่ 4 ปี 2568
all_price_q4 <- get_price_index_quarter(year_th = 2568, quarter = 4)
#> Found 45 records (1 page(s)) — fetching...
#> Done. 45 records retrieved.

# ดึงดัชนีราคาของสินค้าทุกตัว ประจำปี 2568
all_price_2568 <- get_price_index_year(year_th = 2568)
#> Found 35 records (1 page(s)) — fetching...
#> Done. 35 records retrieved.
```

**หมายเหตุ:** การดึงดัชนีผลผลิตรายเดือนด้วยโหมด standalone (year_th + month)
อาจเกิด database error จากฝั่ง API

------------------------------------------------------------------------

## Advanced Examples

### เปรียบเทียบดัชนีระหวดสินค้า

``` r

# ดึงดัชนีผลผลิตรายปีของหมวดปศุสัตว์
livestock_prod_idx <- get_production_index_year(
  category_code = "LIVESTOCK"
)
#> Found 21 records (1 page(s)) — fetching...
#> Done. 21 records retrieved.

livestock_prod_idx |> head()
#>   year_th product_sector product_category product_group    commod product_name
#> 1    2568   ภาคเกษตรกรรม        หมวดปศุสัตว์     หมวดปศุสัตว์ หมวดปศุสัตว์    หมวดปศุสัตว์
#> 2    2567   ภาคเกษตรกรรม        หมวดปศุสัตว์     หมวดปศุสัตว์ หมวดปศุสัตว์    หมวดปศุสัตว์
#> 3    2566   ภาคเกษตรกรรม        หมวดปศุสัตว์     หมวดปศุสัตว์ หมวดปศุสัตว์    หมวดปศุสัตว์
#> 4    2565   ภาคเกษตรกรรม        หมวดปศุสัตว์     หมวดปศุสัตว์ หมวดปศุสัตว์    หมวดปศุสัตว์
#> 5    2564   ภาคเกษตรกรรม        หมวดปศุสัตว์     หมวดปศุสัตว์ หมวดปศุสัตว์    หมวดปศุสัตว์
#> 6    2563   ภาคเกษตรกรรม        หมวดปศุสัตว์     หมวดปศุสัตว์ หมวดปศุสัตว์    หมวดปศุสัตว์
#>   production_index                data_date
#> 1         203.8079 2026-01-06T17:00:00.000Z
#> 2         202.9411 2026-01-06T17:00:00.000Z
#> 3         190.3634 2026-01-06T17:00:00.000Z
#> 4         172.9103 2026-01-06T17:00:00.000Z
#> 5         171.2122 2026-01-06T17:00:00.000Z
#> 6         179.6520 2026-01-06T17:00:00.000Z
```

**หมายเหตุ:** เกิด database error จากฝั่ง API -
ข้อมูลดังกล่าวอาจไม่สามารถดึงได้ในขณะนี้

### การสร้าง Heatmap ของดัชนีราคาระหวดสินค้า

``` r

# ดึงข้อมูลดัชนีราคารายไตรมาสของหมวดปศุสัตว์
livestock_q_idx <- get_price_index_quarter(
  category_code = "LIVESTOCK"
)

# สร้าง pivot table
livestock_pivot <- livestock_q_idx |>
  dplyr::filter(!is.na(price_index)) |>
  tidyr::pivot_wider(
    names_from = quarter,
    values_from = price_index,
    values_fill = NA
  ) |>
  dplyr::arrange(product_name, year_th)

# วาด heatmap (ต้องการ ggplot2)
library(ggplot2)

livestock_pivot |>
  tidyr::pivot_longer(
    cols = c("1", "2", "3", "4"),
    names_to = "quarter",
    values_to = "price_index"
  ) |>
  ggplot(aes(x = year_th, y = product_name, fill = price_index)) +
  geom_tile() +
  scale_fill_viridis_c() +
  labs(
    title = "Price Index Heatmap - Livestock",
    x = "Year (Thai Buddhist)",
    y = "Product",
    fill = "Price Index"
  )
```

------------------------------------------------------------------------

## Known Limitations

เนื่องจากข้อจำกัดของฐานข้อมูล NABC มีข้อควรระวังดังนี้:

1.  **ดัชนีผลผลิตรายปี (Production Index Year)** - เมื่อใช้ `sector = TRUE`
    จะดึงได้เฉพาะหน้าแรกเท่านั้น (pagination ไม่ทำงาน)
    - **แนะนำ:** ใช้ `category_code` หรือ `group_code` แทน `sector = TRUE`
2.  **ดัชนีราคาและผลผลิตรายเดือน (Month Index)** - เมื่อใช้โหมด
    `year_th + month` (standalone /all endpoint) อาจดึงได้เฉพาะหน้าแรกเท่านั้น
    - **แนะนำ:** ใช้ `category_code`, `group_code`, หรือ `product_code`
      แทน

## Tips and Best Practices

1.  **เริ่มจาก `sector = TRUE`** - เพื่อดูว่ามีหมวด/กลุ่ม/สินค้าอะไรบ้างในระบบ
2.  **ใช้ระดับที่แคบกว่าที่จำเป็น** - category → group → product
    เพื่อจำกัดผลลัพธ์ที่เหมาะสม
3.  **ตรวจสอบสินค้ารายไตรมาส** - รายไตรมาสใช้รหัสสินค้าแยกต่างจากรายเดือน/ปี (ใช้
    [`show_quarter_products()`](https://kanthjs.github.io/talatThaiR/reference/show_quarter_products.md))
4.  **กรองช่วงเวลา** - ระบุ `month` หรือ `quarter` กับ `category_code`,
    `group_code`, `product_code` เพื่อลดปริมาณการดึง
5.  **จัดเก็บข้อมูล** - ดัชนีเป็นข้อมูลที่มีคุณค่าสำหรับการวิเคราะห์ ควรจัดเก็บให้ดี
