# test-mappings.R
# Tests for R/mappings.R
# Covers: internal map objects and all show_*() helpers.

# ---------------------------------------------------------------------------
# Internal map objects
# ---------------------------------------------------------------------------

describe(".DAILY_CATEGORY_MAP", {
  it("is a named character vector", {
    expect_type(talatThaiR:::.DAILY_CATEGORY_MAP, "character")
    expect_true(length(names(talatThaiR:::.DAILY_CATEGORY_MAP)) > 0)
  })

  it("contains expected category codes", {
    codes <- names(talatThaiR:::.DAILY_CATEGORY_MAP)
    expect_in("RICE_MALI", codes)
    expect_in("RUBBER",    codes)
    expect_in("PALM",      codes)
  })

  it("has no NA names or values", {
    map <- talatThaiR:::.DAILY_CATEGORY_MAP
    expect_false(anyNA(names(map)))
    expect_false(anyNA(map))
  })
})

describe(".DAILY_PRODUCT_MAP", {
  it("is a named character vector", {
    expect_type(talatThaiR:::.DAILY_PRODUCT_MAP, "character")
  })

  it("contains expected product codes", {
    codes <- names(talatThaiR:::.DAILY_PRODUCT_MAP)
    expect_in("LIME_XL", codes)
    expect_in("CORN_M30", codes)
    expect_in("EGG_3",   codes)
  })

  it("has no duplicate codes", {
    codes <- names(talatThaiR:::.DAILY_PRODUCT_MAP)
    expect_equal(length(codes), length(unique(codes)))
  })
})

describe(".WEEKLY_CATEGORY_MAP", {
  it("is a named character vector with no NAs", {
    map <- talatThaiR:::.WEEKLY_CATEGORY_MAP
    expect_type(map, "character")
    expect_false(anyNA(names(map)))
    expect_false(anyNA(map))
  })

  it("contains expected weekly categories", {
    codes <- names(talatThaiR:::.WEEKLY_CATEGORY_MAP)
    expect_in("SHRIMP", codes)
    expect_in("RUBBER", codes)
    expect_in("PORK",   codes)
  })
})

describe(".INDEX_PRODUCT_MAP", {
  it("is a named character vector", {
    expect_type(talatThaiR:::.INDEX_PRODUCT_MAP, "character")
    expect_true(length(talatThaiR:::.INDEX_PRODUCT_MAP) > 0)
  })
})

describe(".INDEX_GROUP_MAP", {
  it("has no duplicate codes", {
    codes <- names(talatThaiR:::.INDEX_GROUP_MAP)
    expect_equal(length(codes), length(unique(codes)))
  })
})

describe(".INDEX_CATEGORY_MAP", {
  it("contains exactly the three sector codes", {
    expect_setequal(
      names(talatThaiR:::.INDEX_CATEGORY_MAP),
      c("FISHERY", "LIVESTOCK", "MAJOR_CROP")
    )
  })
})

# ---------------------------------------------------------------------------
# show_*() helper functions
# ---------------------------------------------------------------------------

describe("show_daily_products()", {
  it("returns a data.frame", {
    result <- show_daily_products()
    expect_s3_class(result, "data.frame")
  })

  it("has exactly the columns Code and Name", {
    result <- show_daily_products()
    expect_named(result, c("Code", "Name"))
  })

  it("Code column contains only character strings", {
    expect_type(show_daily_products()$Code, "character")
  })

  it("has no NA values", {
    result <- show_daily_products()
    expect_false(anyNA(result$Code))
    expect_false(anyNA(result$Name))
  })

  it("matches the underlying map length", {
    expect_equal(
      nrow(show_daily_products()),
      length(talatThaiR:::.DAILY_PRODUCT_MAP)
    )
  })
})

describe("show_daily_categories()", {
  it("returns a data.frame with Code and Name columns", {
    result <- show_daily_categories()
    expect_s3_class(result, "data.frame")
    expect_named(result, c("Code", "Name"))
  })

  it("contains RICE_MALI code", {
    expect_in("RICE_MALI", show_daily_categories()$Code)
  })
})

describe("show_weekly_products()", {
  it("returns a data.frame with Code and Name columns", {
    result <- show_weekly_products()
    expect_s3_class(result, "data.frame")
    expect_named(result, c("Code", "Name"))
  })

  it("has no duplicate Code values", {
    result <- show_weekly_products()
    expect_equal(nrow(result), length(unique(result$Code)))
  })
})

describe("show_weekly_categories()", {
  it("returns a data.frame with Code and Name columns", {
    result <- show_weekly_categories()
    expect_s3_class(result, "data.frame")
    expect_named(result, c("Code", "Name"))
  })
})

describe("show_index_products()", {
  it("returns a data.frame with Code and Name columns", {
    result <- show_index_products()
    expect_s3_class(result, "data.frame")
    expect_named(result, c("Code", "Name"))
  })
})

describe("show_quarter_products()", {
  it("returns a data.frame with Code and Name columns", {
    result <- show_quarter_products()
    expect_s3_class(result, "data.frame")
    expect_named(result, c("Code", "Name"))
  })
})

describe("show_index_groups()", {
  it("returns a data.frame with Code and Name columns", {
    result <- show_index_groups()
    expect_s3_class(result, "data.frame")
    expect_named(result, c("Code", "Name"))
  })

  it("contains expected group codes", {
    codes <- show_index_groups()$Code
    expect_in("FISHERY",   codes)
    expect_in("LIVESTOCK", codes)
    expect_in("FRUIT",     codes)
  })
})

describe("show_index_categories()", {
  it("returns a data.frame with Code and Name columns", {
    result <- show_index_categories()
    expect_s3_class(result, "data.frame")
    expect_named(result, c("Code", "Name"))
  })

  it("has exactly 3 rows", {
    expect_equal(nrow(show_index_categories()), 3L)
  })
})
