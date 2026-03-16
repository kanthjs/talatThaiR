# getting-started

## Introduction

**talatThaiR** เป็น R Package ที่ออกแบบมาเพื่อให้นักวิเคราะห์ข้อมูล (Data Analyst),
นักวิทยาศาสตร์ข้อมูล (Data Scientist) และนักวิจัย
สามารถดึงข้อมูลสถิติการเกษตรของประเทศไทย จาก **ศูนย์ข้อมูลเกษตรแห่งชาติ (National
Agricultural Big Data Center - NABC)** ได้อย่างง่ายดาย รวดเร็ว และเป็นระบบ

``` r

library(talatThaiR)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

## Data Structure

ข้อมูลใน talatThaiR ถูกจัดเก็บและเรียกดูผ่าน “รหัส” (Code)
ซึ่งแบ่งออกเป็นหลายระดับได้แก่ ระดับหมวดหมู่ (Category), ระดับกลุ่ม (Group),
และระดับสินค้า (Product)

การใช้รหัสแทนการพิมพ์ชื่อภาษาไทย ช่วยลดปัญหาจาก: - การพิมพ์ชื่อผิด -
การเว้นวรรคไม่ตรงกับฐานข้อมูล - ความสับสนไม่ชัดเจนของชื่อภาษาไทย

## Browsing Available Codes

ก่อนเริ่มต้นดึงข้อมูล คุณสามารถตรวจสอบรหัสที่รองรับได้ผ่านฟังก์ชันกลุ่ม `show_*()`:

### สำหรับข้อมูลราคาสินค้าเกษตร (Commodity Prices)

``` r

# ดูรหัสหมวดสินค้ารายวัน (เช่น "SHRIMP", "PORK", "RICE_MALI")
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

# ดูรหัสสินค้ารายวัน (เช่น "LIME_XL", "LIME_L", "LIME_M")
show_daily_products()
#>             Code                                Name
#> 1        LIME_XL                 มะนาว ผลขนาดใหญ่พิเศษ
#> 2         LIME_L                     มะนาว ผลขนาดใหญ่
#> 3         LIME_M                    มะนาว ผลขนาดกลาง
#> 4         LIME_S                     มะนาว ผลขนาดเล็ก
#> 5       CORN_M30            ข้าวโพดเลี้ยงสัตว์ ความชื้น 30%
#> 6     CORN_M14_5          ข้าวโพดเลี้ยงสัตว์ ความชื้น 14.5%
#> 7     CASSAVA_30             หัวมันสำปะหลังสด (แป้ง 30%)
#> 8     CASSAVA_25             หัวมันสำปะหลังสด (แป้ง 25%)
#> 9    CASSAVA_MIX                   หัวมันสำปะหลังสด คละ
#> 10        COCO_L                 มะพร้าวผลแห้ง ขนาดใหญ่
#> 11        COCO_M                มะพร้าวผลแห้ง ขนาดกลาง
#> 12        COCO_S                 มะพร้าวผลแห้ง ขนาดเล็ก
#> 13      COCO_MIX                 มะพร้าวผลแห้ง ขนาดคละ
#> 14     LONGAN_AA                     ลำไยร่วง เกรด AA
#> 15      LONGAN_A                      ลำไยร่วง เกรด A
#> 16      LONGAN_B                      ลำไยร่วง เกรด B
#> 17   LONGAN_E_AA              ลำไยทั้งช่อพันธุ์อีดอ เกรด AA
#> 18         EGG_3                         ไข่ไก่ เบอร์ 3
#> 19         EGG_4                         ไข่ไก่ เบอร์ 4
#> 20     EGG_FRESH                              ไข่ไก่สด
#> 21      PORK_100        สุกรพันธุ์ผสม น้ำหนัก 100 กก. ขึ้นไป
#> 22    CHICK_MEAT                          ไก่รุ่นพันธุ์เนื้อ
#> 23 PINEAPPLE_FAC               สับปะรดปัตตาเวียส่งโรงงาน
#> 24     SHRIMP_70         กุ้งขาวแวนนาไม ขนาด 70 ตัว/กก.
#> 25 RUBBER_LIQUID                         น้ำยางพาราสด
#> 26 RUBBER_SHEET3                   ยางพาราแผ่นดิบ ชั้น 3
#> 27       PALM_15 ผลปาล์มน้ำมันทั้งทะลาย นน. > 15 กก. ขึ้นไป
#> 28  RICE_MALI105               ข้าวเปลือกเจ้าหอมมะลิ 105

# ดูรหัสหมวดสินค้ารายสัปดาห์/รายเดือน
show_weekly_categories()
#>         Code          Name
#> 1    BUFFALO         กระบือ
#> 2     SHRIMP            กุ้ง
#> 3    BROILER         ไก่เนื้อ
#> 4       RICE           ข้าว
#> 5       CORN ข้าวโพดเลี้ยงสัตว์
#> 6        EGG          ไข่ไก่
#> 7     CATTLE         โคเนื้อ
#> 8       PALM      ปาล์มน้ำมัน
#> 9     PEPPER        พริกไทย
#> 10      COCO        มะพร้าว
#> 11   CASSAVA     มันสำปะหลัง
#> 12    RUBBER       ยางพารา
#> 13    LONGAN          ลำไย
#> 14 PINEAPPLE        สับปะรด
#> 15      PORK           สุกร

# ดูรหัสสินค้ารายสัปดาห์/รายเดือน
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

### สำหรับข้อมูลดัชนี (Indices)

``` r

# ดูรหัสหมวดสินค้าดัชนี (เช่น "LIVESTOCK", "FISHERY", "MAJOR_CROP")
show_index_categories()
#>         Code         Name
#> 1    FISHERY    หมวดประมง
#> 2  LIVESTOCK    หมวดปศุสัตว์
#> 3 MAJOR_CROP หมวดพืชผลสำคัญ

# ดูรหัสกลุ่มสินค้าดัชนี (เช่น "OIL_CROP", "VEGETABLE", "FRUIT")
show_index_groups()
#>             Code              Name
#> 1 GRAIN_AND_FOOD กลุ่มธัญพืชและพืชอาหาร
#> 2       OIL_CROP         กลุ่มพืชน้ำมัน
#> 3      VEGETABLE           กลุ่มพืชผัก
#> 4         FLOWER        กลุ่มพืชไม้ดอก
#> 5          FRUIT           กลุ่มไม้ผล
#> 6      PERENNIAL         กลุ่มไม้ยืนต้น
#> 7        FISHERY         หมวดประมง
#> 8      LIVESTOCK         หมวดปศุสัตว์

# ดูรหัสสินค้าดัชนีรายเดือน/รายปี
show_index_products()
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

# ดูรหัสสินค้าดัชนีรายไตรมาส (ใช้แยกต่างจากดัชนีรายเดือน/ปี)
show_quarter_products()
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

**Tip:** แต่ละฟังก์ชัน `show_*()` จะคืนค่าเป็น `data.frame` ที่มีคอลัมน์ `Code` และ
`Name` คุณสามารถดู หรือค้นหาได้ง่าย

``` r

# ค้นหาสินค้าที่มีคำว่า "LIME" ในรหัส
lime_products <- show_daily_products()
lime_products[grepl("LIME", lime_products$Code), ]
#>      Code                Name
#> 1 LIME_XL มะนาว ผลขนาดใหญ่พิเศษ
#> 2  LIME_L     มะนาว ผลขนาดใหญ่
#> 3  LIME_M    มะนาว ผลขนาดกลาง
#> 4  LIME_S     มะนาว ผลขนาดเล็ก
```

## Basic Data Fetching

### ดึงข้อมูลราคาสินค้า (Commodity Prices)

คุณสามารถใช้ฟังก์ชัน `get_*_prices()` เพื่อดึงข้อมูลราคา โดยต้องเลือกใช้รหัสหมวดหมู่
(category_code) หรือรหัสสินค้า (product_code) อย่างใดอย่างหนึ่งเท่านั้น

``` r

# ดึงข้อมูลราคากุ้งขาวรายวัน (หมวดกุ้ง)
daily_shrimp <- get_daily_prices(category_code = "SHRIMP")
#> Found 535 records (6 page(s)) — fetching...
#>   Fetching page 2 / 6
#>   Fetching page 3 / 6
#>   Fetching page 4 / 6
#>   Fetching page 5 / 6
#>   Fetching page 6 / 6
#> Done. 535 records retrieved.
head(daily_shrimp)
#>    data_date day month year_th product_category                product_name
#> 1 2026-03-16  16     3    2569            กุ้งขาว กุ้งขาวแวนนาไม ขนาด 70 ตัว/กก.
#> 2 2026-03-16  16     3    2569            กุ้งขาว กุ้งขาวแวนนาไม ขนาด 70 ตัว/กก.
#> 3 2026-03-13  13     3    2569            กุ้งขาว กุ้งขาวแวนนาไม ขนาด 70 ตัว/กก.
#> 4 2026-03-13  13     3    2569            กุ้งขาว กุ้งขาวแวนนาไม ขนาด 70 ตัว/กก.
#> 5 2026-03-12  12     3    2569            กุ้งขาว กุ้งขาวแวนนาไม ขนาด 70 ตัว/กก.
#> 6 2026-03-12  12     3    2569            กุ้งขาว กุ้งขาวแวนนาไม ขนาด 70 ตัว/กก.
#>          market_name  province day_price    unit
#> 1        ร้านสินงอกงาม ฉะเชิงเทรา       140 บาท/กก.
#> 2 ตลาดกลางกุ้งสมุทรสาคร  สมุทรสาคร       135 บาท/กก.
#> 3 ตลาดกลางกุ้งสมุทรสาคร  สมุทรสาคร       135 บาท/กก.
#> 4        ร้านสินงอกงาม ฉะเชิงเทรา       135 บาท/กก.
#> 5 ตลาดกลางกุ้งสมุทรสาคร  สมุทรสาคร       135 บาท/กก.
#> 6        ร้านสินงอกงาม ฉะเชิงเทรา       135 บาท/กก.

# ดึงข้อมูลราคามะนาวขนาด XL รายวัน
daily_lime_xl <- get_daily_prices(product_code = "LIME_XL")
#> Found 290 records (3 page(s)) — fetching...
#>   Fetching page 2 / 3
#>   Fetching page 3 / 3
#> Done. 290 records retrieved.
head(daily_lime_xl)
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

# ดึงข้อมูลราคาสุกรีชีวิตรายสัปดาห์ ในปี พ.ศ. 2569 เดือน 2
weekly_pork <- get_weekly_prices(product_code = "PORK_LIVE_100", year_th = 2569, month = 2)
#> Found 4 records (1 page(s)) — fetching...
#> Done. 4 records retrieved.
head(weekly_pork)
#>   year_th month week province_code province_name             product_name
#> 1    2569     2    4          TH00     ประเทศไทย สุกรมีชีวิต น้ำหนักเกิน 100 กก.
#> 2    2569     2    3          TH00     ประเทศไทย สุกรมีชีวิต น้ำหนักเกิน 100 กก.
#> 3    2569     2    2          TH00     ประเทศไทย สุกรมีชีวิต น้ำหนักเกิน 100 กก.
#> 4    2569     2    1          TH00     ประเทศไทย สุกรมีชีวิต น้ำหนักเกิน 100 กก.
#>   commod subcommod value    unit
#> 1    สุกร       สุกร 56.95 บาท/กก.
#> 2    สุกร       สุกร 57.94 บาท/กก.
#> 3    สุกร       สุกร 58.97 บาท/กก.
#> 4    สุกร       สุกร 61.81 บาท/กก.
```

### ดึงข้อมูลดัชนี (Indices)

talatThaiR รองรับการดึงดัชนีราคา (Price Index) และดัชนีผลผลิต (Production
Index) โดยมีอาร์กิวเมนต์ที่ใช้งานคล้ายคลึงกัน

``` r

# ดึงภาพรวมดัชนีราคาระดับ Sector ทั้งหมดประจำปี พ.ศ. 2567
sector_price_idx <- get_price_index_year(sector = TRUE, year_th = 2567)
#> Found 1 records (1 page(s)) — fetching...
#> Done. 1 records retrieved.
head(sector_price_idx)
#>   year_th product_sector product_category product_group       commod
#> 1    2567   ภาคเกษตรกรรม     ภาคเกษตรกรรม  ภาคเกษตรกรรม ภาคเกษตรกรรม
#>   product_name price_index                data_date
#> 1 ภาคเกษตรกรรม    165.5918 2026-01-06T17:00:00.000Z

# ดึงดัชนีผลผลิตรายไตรมาส ของหมวดปศุสัตว์ ในไตรมาสที่ 1
livestock_prod_idx <- get_production_index_quarter(category_code = "LIVESTOCK", quarter = 1)
#> Found 84 records (1 page(s)) — fetching...
#> Done. 84 records retrieved.
head(livestock_prod_idx)
#>   year_th quarter product_sector product_category product_group    commod
#> 1    2568       4   ภาคเกษตรกรรม        หมวดปศุสัตว์     หมวดปศุสัตว์ หมวดปศุสัตว์
#> 2    2568       3   ภาคเกษตรกรรม        หมวดปศุสัตว์     หมวดปศุสัตว์ หมวดปศุสัตว์
#> 3    2568       2   ภาคเกษตรกรรม        หมวดปศุสัตว์     หมวดปศุสัตว์ หมวดปศุสัตว์
#> 4    2568       1   ภาคเกษตรกรรม        หมวดปศุสัตว์     หมวดปศุสัตว์ หมวดปศุสัตว์
#> 5    2567       4   ภาคเกษตรกรรม        หมวดปศุสัตว์     หมวดปศุสัตว์ หมวดปศุสัตว์
#> 6    2567       3   ภาคเกษตรกรรม        หมวดปศุสัตว์     หมวดปศุสัตว์ หมวดปศุสัตว์
#>   product_name production_index                data_date
#> 1    หมวดปศุสัตว์         209.2958 2026-01-06T17:00:00.000Z
#> 2    หมวดปศุสัตว์         203.6209 2026-01-06T17:00:00.000Z
#> 3    หมวดปศุสัตว์         197.7165 2026-01-06T17:00:00.000Z
#> 4    หมวดปศุสัตว์         204.5982 2026-01-06T17:00:00.000Z
#> 5    หมวดปศุสัตว์         208.6025 2026-01-06T17:00:00.000Z
#> 6    หมวดปศุสัตว์         202.9587 2026-01-06T17:00:00.000Z
```

## Understanding Returned Data

ข้อมูลที่คืนกลับมาจากทุกฟังก์ชันจะอยู่ในรูปแบบ `data.frame`
ซึ่งสามารถนำไปวิเคราะห์ต่อได้ทันที

### ตัวอย่าง: การวิเคราะห์ข้อมูลราคารายวัน

``` r

# ดึงข้อมูลราคามะนาวขนาด L ในช่วงเวลา 1 เดือน
daily_lime <- get_daily_prices(
  product_code = "LIME_L",
  start_date = "2026-01-01",
  end_date = "2026-01-31"
)
#> Found 290 records (3 page(s)) — fetching...
#>   Fetching page 2 / 3
#>   Fetching page 3 / 3
#> Done. 20 records retrieved.

# ดูสถิติพื้นฐานของราคา
summary(daily_lime$day_price)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>     130     130     140     140     150     150

# หาราคาเฉลี่ยในแต่ละวัน
daily_avg <- daily_lime |>
  dplyr::group_by(data_date) |>
  dplyr::summarise(
    avg_price = mean(day_price),
    min_price = min(day_price),
    max_price = max(day_price),
    n_observations = n()
  )
head(daily_avg)
#> # A tibble: 6 × 5
#>   data_date  avg_price min_price max_price n_observations
#>   <chr>          <dbl>     <int>     <int>          <int>
#> 1 2026-01-05       150       150       150              1
#> 2 2026-01-06       150       150       150              1
#> 3 2026-01-07       150       150       150              1
#> 4 2026-01-08       150       150       150              1
#> 5 2026-01-09       150       150       150              1
#> 6 2026-01-12       150       150       150              1
```

### ตัวอย่าง: การเปรียบเทียบดัชนีราคาระหระดับ

``` r

# ดึงดัชนีราคารายเดือนของหมวดปศุสัตว์ ในปี 2567
livestock_idx <- get_price_index_month(
  category_code = "LIVESTOCK",
  year_th = 2567
)
#> Found 12 records (1 page(s)) — fetching...
#> Done. 12 records retrieved.

# สรุปข้อมูลตามกลุ่มสินค้า
summary_by_group <- livestock_idx |>
  dplyr::group_by(product_group) |>
  dplyr::summarise(
    avg_index = mean(price_index, na.rm = TRUE),
    max_index = max(price_index, na.rm = TRUE),
    min_index = min(price_index, na.rm = TRUE),
    n_records = n()
  )
print(summary_by_group)
#> # A tibble: 1 × 5
#>   product_group avg_index max_index min_index n_records
#>   <chr>             <dbl>     <dbl>     <dbl>     <int>
#> 1 หมวดปศุสัตว์          140.      142.      136.        12
```

## Important Notes

### การจัดการ Pagination

บางฟังก์ชันอาจมีข้อมูลจำนวนมาก ระบบจะทำการดึงข้อมูลแบบ Pagination (แบ่งหน้า) อัตโนมัติ
และรวมข้อมูลทุกหน้ากลับมาเป็น data.frame ก้อนเดียวให้คุณ

คุณจะเห็นข้อความแสดงความคืบหน้า (progress messages) ขณะดึงข้อมูล:

    Found 250 records (3 page(s)) — fetching...
      Fetching page 2 / 3
      Fetching page 3 / 3
    Done. 250 records retrieved.

### การใช้งานกับปีไทย (Thai Buddhist Calendar)

สำหรับฟังก์ชันที่ใช้ `year_th` (เช่น รายสัปดาห์, รายเดือน, และดัชนี): - ใช้ปีพุทธศักราช
(Thai Buddhist Era = ค.ศ.) - สูตรแปลง: ค.ศ. = ค.ศ. + 543

ตัวอย่าง: - 2026 (ค.ศ.) = 2569 (พ.ศ.) - 2025 (ค.ศ.) = 2568 (พ.ศ.)

### Error Handling

หากคุณระบุรหัสไม่ถูกต้อง ฟังก์ชันจะแสดงข้อความแจ้งเตือนที่ชัดเจน
พร้อมชี้นให้ตรวจสอบด้วยฟังก์ชัน `show_*()` ที่เหมาะสม:

``` r

# ตัวอย่างรหัสผิด - จะเกิด Error
# get_daily_prices(category_code = "WRONG_CODE")
# Error: Category code 'WRONG_CODE' not found. Use show_daily_categories() to see available codes.
```

## Next Steps

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับ: - **ราคาสินค้ารายวัน/สัปดาห์/เดือน**: ดู vignette
`commodity-prices` - **ดัชนีราคาและผลผลิต**: ดู vignette
`agricultural-indices`
