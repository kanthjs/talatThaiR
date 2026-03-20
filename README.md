# talatThaiR <img src="man/figures/talatThaiR_hexlogo_nobg.png" align="right" height="139" alt="talatThaiR logo"/>

> **TalatThaiR** เป็น R package ที่จะพาคุณไปเดินสำรวจราคาของสินค้าเกษตรต่าง ๆ ซึี่งคุณสามารถทราบราคาสินค้าเกษตรและดัชนีเกษตรของไทย โดยแหล่งที่มาของข้อมูลนั้นมาจาก
> จาก API ของสำนักงานเศรษฐกิจการเกษตร (NABC)

<!-- badges: start -->

[![R-CMD-check](https://github.com/kanthjs/talatThaiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ksnthjs/talatThaiR/.github/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Codecov test coverage](https://codecov.io/gh/kanthjs/talatThaiR/graph/badge.svg)](https://app.codecov.io/gh/kanthjs/talatThaiR)
<!-- badges: end -->

## ภาพรวม

`talatThaiR` ช่วยให้ผู้สนใจสามารถดึงข้อมูลจาก
[agriapi.nabc.go.th](https://agriapi.nabc.go.th) เข้าสู่ R  ซึ่ง ใคร จะใช้ RStudio Positron หรือ จาก IDE ที่สามารถ ใช้ R ได้โดยตรง
โดยไม่ต้องจัดการ HTTP request หรือ pagination (page) ด้วยตนเอง ข้อมูลทั้งหมด
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

| Function                           | ข้อมูลที่ได้                                   |
| ---------------------------------- | ---------------------------------------------------------- |
| `get_daily_prices()`             | ราคาสินค้าเกษตรรายวัน                 |
| `get_weekly_prices()`            | ราคาสินค้าเกษตรรายสัปดาห์         |
| `get_monthly_prices()`           | ราคาสินค้าเกษตรรายเดือน             |
| `get_production_index_month()`   | ดัชนีผลผลิตการเกษตรรายเดือน     |
| `get_production_index_quarter()` | ดัชนีผลผลิตการเกษตรรายไตรมาส   |
| `get_production_index_year()`    | ดัชนีผลผลิตการเกษตรรายปี           |
| `get_price_index_month()`        | ดัชนีราคาสินค้าเกษตรรายเดือน   |
| `get_price_index_quarter()`      | ดัชนีราคาสินค้าเกษตรรายไตรมาส |
| `get_price_index_year()`         | ดัชนีราคาสินค้าเกษตรรายปี         |

**Helper functions** สำหรับดูรหัสที่ใช้ได้:

| Function                     | แสดงรหัสของ                                            |
| ---------------------------- | ----------------------------------------------------------------- |
| `show_daily_categories()`  | หมวดสินค้ารายวัน (13 หมวด)                    |
| `show_daily_products()`    | สินค้ารายวัน (27 รายการ)                        |
| `show_weekly_categories()` | หมวดสินค้ารายสัปดาห์/เดือน (15 หมวด) |
| `show_weekly_products()`   | สินค้ารายสัปดาห์/เดือน                       |
| `show_index_categories()`  | หมวดดัชนี (FISHERY / LIVESTOCK / MAJOR_CROP)             |
| `show_index_groups()`      | กลุ่มดัชนี (8 กลุ่ม)                               |
| `show_index_products()`    | สินค้าดัชนีรายเดือน                            |
| `show_quarter_products()`  | สินค้าดัชนีรายไตรมาส/ปี                     |

---

## รหัสสินค้าและหมวดหมู่

สำหรับการเรียกชื่อสินค้า `product_name` และ  `product_group` หรือ แม่แต่ `product_category` นั้น สำหรับฐานข้อมูลของ NABC นั้น พบว่ามีข้อจำกัดและเกิดความสับสนได้ไง ยกตัวอย่างเช่น `product_name` สำหรับราคาสินค้าเกษตร รายวัน เรียก น้ำยางพาราสด แต่ ราคาสินค้าเกษตร รายสัปดาห์ และ ราคาสินค้าเกษตรรายเดือน เรียก น้ำยางสด คละ (คิดว่าเป็นคนละสินค้ากัน แต่ก็ มีความคล้ายกัน) `product_name` ที่จะให้เป็นมาตราฐาน เรยก จึงไม่เหมือนกัน ดังนั้น จึงต้องมี list ของ รายการ แยกกันไป ดังนั้น เพื่อกันความสับสน ผู้ใช้ จึงควรดูก่อนว่า แต่ละรายการ นั้นเป็นอย่างไร และเพื่อให้ ป้องกันการสับสน หรือ พิมพ์(ภาษาไทย) ไม่ถูกต้อง จึงเหลีกเลี่ยงโดยการเรียก คำ(ภาษาอังกฤษ) แทน

### หมวดราคาสินค้า  (https://agriapi.nabc.go.th/home/production-api)

#### รายวัน

ขอให้ใช้ หรือ เลือก list รายการจาก `show_daily_categories()` และ `show_daily_products()`

#### รายสัปดาห์ และ รายเดือน

ขอให้ใช้ list รายการจาก `show_weekly_categories()` และ `show_weekly_products()`

### หมวดดัชนี (https://agriapi.nabc.go.th/home/index-api)

#### ดัชนีผลผลิตสินค้าเกษตร

- รายเดือน
ขอให้ใช้ หรือ เลือกจาก `show_index_products()` `show_index_categories()` และ `show_index_groups()`
- รายไตรมาส และ รายปี
ขอให้ใช้ หรือ เลือก จาก `show_quarter_products()` ส่วนอื่น เหมือนกัน `show_index_categories()` และ `show_index_groups()`

#### ดัชนีราคาสินค้าเกษตร
 ทั้ง รายเดือน รายไตรมาส และ รายปี 
ขอให้ใช้ หรือ เลือกจาก `show_index_products()` `show_index_categories()` และ `show_index_groups()`

| Code           | หมวด                     |
| -------------- | ---------------------------- |
| `FISHERY`    | หมวดประมง           |
| `LIVESTOCK`  | หมวดปศุสัตว์     |
| `MAJOR_CROP` | หมวดพืชผลสำคัญ |

### กลุ่มดัชนี (`show_index_groups()`)

| Code               | กลุ่ม                                   |
| ------------------ | -------------------------------------------- |
| `GRAIN_AND_FOOD` | กลุ่มธัญพืชและพืชอาหาร |
| `OIL_CROP`       | กลุ่มพืชน้ำมัน                 |
| `VEGETABLE`      | กลุ่มพืชผัก                       |
| `FLOWER`         | กลุ่มพืชไม้ดอก                 |
| `FRUIT`          | กลุ่มไม้ผล                         |
| `PERENNIAL`      | กลุ่มไม้ยืนต้น                 |
| `FISHERY`        | หมวดประมง                           |
| `LIVESTOCK`      | หมวดปศุสัตว์                     |

---

## หมายเหตุ

**Pagination:** `talatThaiR` ได้จัดการ pagination ให้อัตโนมัติ ผู้ใช้ได้รับข้อมูลครบทุก
record โดยไม่ต้องระบุ page ใด ๆ และ จะกำหนดจำนวนหน้า จากข้อมูลที่ต้องการ เช่น ระหว่างวันที่ จำนวนหน้าจะถูกคำนวน แล้วนำเข้าไปเรียก เพื่อให้ได้ข้อมูลตามที่ต้องการ

**API Key:** API ส่วนใหญ่ไม่ต้องการ key แต่หากต้องการสามารถระบุผ่าน
parameter `api_key` ได้ทุก function

**ปีพุทธศักราช:** parameter `year_th` ใช้ปี พ.ศ. เช่น `2568` (ไม่ใช่ ค.ศ.)

**Rate limiting:** `talatThaiR` จำกัดป้องกันการ request ที่ถี่เกินไป เมื่อผู้ใช้ดึงข้อมูลจำนวนหน้าเป็นจำนวนมาก จะทำการ sleep 0.3 วินาทีระหว่าง page ดังนั้นอาจใช้เวลาสักครู่

---

## แหล่งข้อมูล

- API: [agriapi.nabc.go.th](https://agriapi.nabc.go.th)
- ผู้ให้บริการข้อมูล: สำนักงานเศรษฐกิจการเกษตร (สศก.)

---

## License

MIT
