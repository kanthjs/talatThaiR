# talatThaiR <img src="man/figures/talatThaiR_hexlogo_nobg.png" align="right" height="139" alt="" />

> R package สำหรับดึงข้อมูลราคาสินค้าเกษตรและดัชนีเกษตรของไทย  
> จาก API ของสำนักงานเศรษฐกิจการเกษตร (NABC)

<!-- badges: start -->
[![R-CMD-check](https://github.com/your-username/talatThaiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/your-username/talatThaiR/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## ภาพรวม

`talatThaiR` ช่วยให้นักวิจัยและนักวิเคราะห์ข้อมูลเกษตรสามารถดึงข้อมูลจาก
[agriapi.nabc.go.th](https://agriapi.nabc.go.th) เข้าสู่ R ได้โดยตรง
โดยไม่ต้องจัดการ HTTP request หรือ pagination ด้วยตนเอง ข้อมูลทั้งหมด
return กลับมาเป็น `data.frame` พร้อมใช้งาน

**ข้อมูลที่รองรับ:**

- ราคาสินค้าเกษตร รายวัน / รายสัปดาห์ / รายเดือน
- ดัชนีผลผลิตการเกษตร รายเดือน / รายไตรมาส / รายปี
- ดัชนีราคาสินค้าเกษตร รายเดือน / รายไตรมาส / รายปี

---

## การติดตั้ง

```r
# ติดตั้งจาก GitHub
# install.packages("remotes")
remotes::install_github("kanthjs/talatThaiR")
```

---

## Functions

| Function | ข้อมูลที่ได้ |
|---|---|
| `get_daily_prices()` | ราคาสินค้าเกษตรรายวัน |
| `get_weekly_prices()` | ราคาสินค้าเกษตรรายสัปดาห์ |
| `get_monthly_prices()` | ราคาสินค้าเกษตรรายเดือน |
| `get_production_index_month()` | ดัชนีผลผลิตการเกษตรรายเดือน |
| `get_production_index_quarter()` | ดัชนีผลผลิตการเกษตรรายไตรมาส |
| `get_production_index_year()` | ดัชนีผลผลิตการเกษตรรายปี |
| `get_price_index_month()` | ดัชนีราคาสินค้าเกษตรรายเดือน |
| `get_price_index_quarter()` | ดัชนีราคาสินค้าเกษตรรายไตรมาส |
| `get_price_index_year()` | ดัชนีราคาสินค้าเกษตรรายปี |

**Helper functions** สำหรับดูรหัสที่ใช้ได้:

| Function | แสดงรหัสของ |
|---|---|
| `show_daily_categories()` | หมวดสินค้ารายวัน (13 หมวด) |
| `show_daily_products()` | สินค้ารายวัน (27 รายการ) |
| `show_weekly_categories()` | หมวดสินค้ารายสัปดาห์/เดือน (15 หมวด) |
| `show_weekly_products()` | สินค้ารายสัปดาห์/เดือน |
| `show_index_categories()` | หมวดดัชนี (FISHERY / LIVESTOCK / MAJOR_CROP) |
| `show_index_groups()` | กลุ่มดัชนี (8 กลุ่ม) |
| `show_index_products()` | สินค้าดัชนีรายเดือน |
| `show_quarter_products()` | สินค้าดัชนีรายไตรมาส/ปี |

---

## การใช้งาน

### ราคาสินค้าเกษตรรายวัน

```r
library(talatThaiR)

# ดูว่ามีหมวดสินค้าอะไรบ้าง
show_daily_categories()

# ดึงราคากุ้งทุกรายการ
get_daily_prices(category_code = "SHRIMP")

# ดึงราคามะนาวผลขนาดใหญ่พิเศษ
get_daily_prices(product_code = "LIME_XL")

# ดึงราคาสินค้าทุกชนิดของวันที่กำหนด
get_daily_prices(date = "2025-06-01")

# ดึงราคาข้าวหอมมะลิ ช่วง 1 ม.ค. 2569 ถึงปัจจุบัน
get_daily_prices(category_code = "RICE_MALI", start_date = "2026-01-01")
```

**หมายเหตุ:** ระบุได้เพียงหนึ่งโหมดต่อการเรียก (`category_code`, `product_code`, หรือ `date`)

---

### ราคาสินค้าเกษตรรายสัปดาห์

```r
# ดูรหัสสินค้าที่มี
show_weekly_categories()
show_weekly_products()

# ดึงราคากระบือทุกรายการ
get_weekly_prices(category_code = "BUFFALO")

# ดึงราคาสุกรมีชีวิต > 100 กก.
get_weekly_prices(product_code = "PORK_LIVE_100")

# ดึงราคาทุกชนิดของเดือนกุมภาพันธ์ พ.ศ. 2569
get_weekly_prices(year_th = 2569, month = 2)

# ดึงราคายางพาราเฉพาะเดือน มิ.ย. 2568
get_weekly_prices(category_code = "RUBBER", year_th = 2568, month = 6)
```

**หมายเหตุ:** `year_th` และ `month` ต้องระบุคู่กันเสมอ

---

### ราคาสินค้าเกษตรรายเดือน

```r
# โหมดหลัก: ค้นด้วย category หรือ product
get_monthly_prices(category_code = "BUFFALO")
get_monthly_prices(product_code = "PORK_LIVE_100")

# ค้นด้วยปีและเดือน
get_monthly_prices(year_th = 2569, month = 2)

# กรองเพิ่มเติม: เฉพาะปี หรือ ปี+เดือน
get_monthly_prices(product_code = "PORK_LIVE_100", year_th = 2569)
get_monthly_prices(category_code = "BUFFALO", year_th = 2569, month = 2)
```

---

### ดัชนีผลผลิตการเกษตรรายเดือน

```r
# ดูรหัสหมวด กลุ่ม และสินค้า
show_index_categories()
show_index_groups()
show_index_products()

# ดึงดัชนีทุกรายการในหมวดปศุสัตว์
get_production_index_month(category_code = "LIVESTOCK")

# ดึงดัชนีกลุ่มพืชน้ำมัน เฉพาะเดือน มิ.ย.
get_production_index_month(group_code = "OIL_CROP", month = 6)

# ดึงดัชนีกล้วยหอมทอง เฉพาะเดือน มี.ค.
get_production_index_month(product_code = "BANANA_HOM_THONG", month = 3)

# ดึงดัชนีทุกสินค้าของเดือน ธ.ค. 2568
get_production_index_month(year_th = 2568, month = 12)

# ดึงรายชื่อ sector ทั้งหมด
get_production_index_month(sector = TRUE)
```

---

### ดัชนีผลผลิตการเกษตรรายไตรมาส

```r
# หมายเหตุ: product_code ใช้รหัสจาก show_quarter_products()
show_quarter_products()

get_production_index_quarter(category_code = "LIVESTOCK")
get_production_index_quarter(group_code = "OIL_CROP", quarter = 3)
get_production_index_quarter(product_code = "GARLIC", quarter = 2)

# ดึงทุกสินค้าของไตรมาส 4 ปี 2568
get_production_index_quarter(year_th = 2568, quarter = 4)

get_production_index_quarter(sector = TRUE)
```

---

### ดัชนีผลผลิตการเกษตรรายปี

```r
get_production_index_year(category_code = "LIVESTOCK")
get_production_index_year(group_code = "OIL_CROP", year_th = 2567)
get_production_index_year(product_code = "GARLIC")   # ใช้ .QUARTER_PRODUCT_MAP

# ดึงทุกสินค้าของปี 2568
get_production_index_year(year_th = 2568)

# sector + กรองปี
get_production_index_year(sector = TRUE)
get_production_index_year(sector = TRUE, year_th = 2567)
```

---

### ดัชนีราคาสินค้าเกษตรรายเดือน

```r
# หมายเหตุ: product_code ใช้รหัสจาก show_index_products()

get_price_index_month(category_code = "LIVESTOCK")
get_price_index_month(group_code = "OIL_CROP", year_th = 2567, month = 1)
get_price_index_month(product_code = "GARLIC_DRY_MIX", month = 1)

# ดึงทุกสินค้าของเดือน ธ.ค. 2568
get_price_index_month(year_th = 2568, month = 12)

# sector สามารถกรองด้วย year_th ได้
get_price_index_month(sector = TRUE)
get_price_index_month(sector = TRUE, year_th = 2567)
```

---

### ดัชนีราคาสินค้าเกษตรรายไตรมาสและรายปี

```r
# รายไตรมาส — product_code ใช้ show_index_products()
get_price_index_quarter(category_code = "LIVESTOCK", quarter = 1)
get_price_index_quarter(product_code = "GARLIC_DRY_MIX", year_th = 2567, quarter = 3)
get_price_index_quarter(year_th = 2568, quarter = 4)

# รายปี
get_price_index_year(category_code = "LIVESTOCK", year_th = 2567)
get_price_index_year(product_code = "GARLIC_DRY_MIX")
get_price_index_year(year_th = 2568)
```

---

## รหัสสินค้าและหมวดหมู่

### หมวดสินค้ารายวัน (`show_daily_categories()`)

| Code | สินค้า |
|---|---|
| `SHRIMP` | กุ้งขาว |
| `PINEAPPLE` | สับปะรดโรงงาน |
| `CORN` | ข้าวโพดเลี้ยงสัตว์ |
| `CHICKEN` | ไก่ |
| `RUBBER` | ยางพารา |
| `RICE_MALI` | ข้าวหอมมะลิ |
| `COCO` | มะพร้าว |
| `EGG` | ไข่ไก่ |
| `PALM` | ปาล์มน้ำมัน |
| `LONGAN` | ลำไย |
| `CASSAVA` | มันสำปะหลัง |
| `LIME` | มะนาว |
| `PORK` | สุกร |

### หมวดดัชนี (`show_index_categories()`)

| Code | หมวด |
|---|---|
| `FISHERY` | หมวดประมง |
| `LIVESTOCK` | หมวดปศุสัตว์ |
| `MAJOR_CROP` | หมวดพืชผลสำคัญ |

### กลุ่มดัชนี (`show_index_groups()`)

| Code | กลุ่ม |
|---|---|
| `GRAIN_AND_FOOD` | กลุ่มธัญพืชและพืชอาหาร |
| `OIL_CROP` | กลุ่มพืชน้ำมัน |
| `VEGETABLE` | กลุ่มพืชผัก |
| `FLOWER` | กลุ่มพืชไม้ดอก |
| `FRUIT` | กลุ่มไม้ผล |
| `PERENNIAL` | กลุ่มไม้ยืนต้น |
| `FISHERY` | หมวดประมง |
| `LIVESTOCK` | หมวดปศุสัตว์ |

> สำหรับรายการสินค้าทั้งหมด ใช้ `show_daily_products()`, `show_weekly_products()`,
> `show_index_products()`, และ `show_quarter_products()`

---

## ตัวอย่างการใช้งานจริง

```r
library(talatThaiR)
library(dplyr)
library(ggplot2)

# วิเคราะห์แนวโน้มราคายางพาราปี 2569
rubber <- get_daily_prices(
  category_code = "RUBBER",
  start_date    = "2026-01-01",
  end_date      = "2026-03-31"
)

rubber |>
  mutate(data_date = as.Date(data_date)) |>
  ggplot(aes(x = data_date, y = price, color = product_name)) +
  geom_line() +
  labs(title = "ราคายางพาราปี 2569", x = "วันที่", y = "ราคา (บาท/กก.)")
```

```r
# เปรียบเทียบดัชนีผลผลิตปศุสัตว์ รายไตรมาส
livestock_q <- get_production_index_quarter(
  category_code = "LIVESTOCK"
)

livestock_q |>
  filter(year_th >= 2565) |>
  group_by(year_th, quarter) |>
  summarise(mean_index = mean(production_index, na.rm = TRUE))
```

---

## หมายเหตุการใช้งาน

**Pagination:** package จัดการ pagination ให้อัตโนมัติ ผู้ใช้ได้รับข้อมูลครบทุก
record โดยไม่ต้องระบุ page ใด ๆ

**API Key:** API ส่วนใหญ่ไม่ต้องการ key แต่หากต้องการสามารถระบุผ่าน
parameter `api_key` ได้ทุก function

**ปีพุทธศักราช:** parameter `year_th` ใช้ปี พ.ศ. เช่น `2568` (ไม่ใช่ ค.ศ.)

**Rate limiting:** package มีการ sleep 0.3 วินาทีระหว่าง page เพื่อไม่ให้
request ถี่เกินไป หากข้อมูลมีจำนวนมากการดึงอาจใช้เวลาสักครู่

---

## แหล่งข้อมูล

- API: [agriapi.nabc.go.th](https://agriapi.nabc.go.th)
- ผู้ให้บริการข้อมูล: สำนักงานเศรษฐกิจการเกษตร (สศก.)

---

## License

MIT