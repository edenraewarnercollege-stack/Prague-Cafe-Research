# =====================================================================
# 01_cleaning.R  --  raw data -> cleaned data set
# Run from the repository root. Raw file is never edited by hand.
# NOTE: starter version. Check every step against YOUR understanding;
# you must be able to explain each line at the defense.
# =====================================================================
library(tidyverse)
library(lubridate)

raw_path   <- "analysis/raw_data.csv"
clean_path <- "analysis/dataset.csv"

raw <- read_csv(raw_path, col_types = cols(.default = col_character()),
                na = c("", "NA"))

# We log every decision: what we did and how many cafes/cells it touched.
log_tbl <- tibble(step = character(), n_affected = integer())
log_step <- function(step, n) {
  log_tbl <<- add_row(log_tbl, step = step, n_affected = as.integer(n))
}
log_step("Rows in raw file", nrow(raw))

# ---- 1. Drop empty rows -------------------------------------------------
# The sheet has pre-filled formula columns (distance, lat, lon) in rows
# with no cafe, so "empty" = no cafe name.
df <- raw %>% filter(!is.na(`Cafe name`))
log_step("Empty rows dropped", nrow(raw) - nrow(df))

# ---- 2. Trim whitespace everywhere (e.g. "Prague 3 ", "Joseph Muchnick ")
df <- df %>% mutate(across(where(is.character), str_squish))

# ---- 3. Harmonise district number ("prague 1", "prauge 1", "Prage 7") ---
district_before <- df$`District (number)`
df <- df %>%
  mutate(district_num = str_extract(`District (number)`, "\\d+"),
         district     = paste("Prague", district_num))
log_step("District labels changed by harmonising",
         sum(district_before != df$district, na.rm = TRUE))

# ---- 4. Prices: several values in one cell -> FIRST listed price --------
# Rule (from the brief): "85, 95, 105", "65/40", "55,70" -> first number.
# "na"/"NA" -> missing. Anything else numeric stays.
first_price <- function(x) {
  x <- str_to_lower(x)
  x[x %in% c("na", "n/a")] <- NA
  as.numeric(str_extract(x, "\\d+(\\.\\d+)?"))
}
price_cols <- c(espresso   = "Espresso Price in CZK (dine-in)",
                cappuccino = "Cappuccino Price in CZK (normal milk, dine-in)",
                flat_white = "Flat White Price in CZK (normal milk, dine-in)",
                filter     = "Filter/Batch (in CZK, dine-in)")
for (nm in names(price_cols)) {
  orig <- df[[price_cols[[nm]]]]
  df[[nm]] <- first_price(orig)
  log_step(paste("Multi-value price cells -> first price:", nm),
           sum(str_detect(orig, "[,/]"), na.rm = TRUE))
}

# ---- 5. Number of ratings: remove thousands separator -------------------
nr_orig <- df$`Number of ratings (Google)`
df$n_ratings <- as.numeric(str_remove_all(nr_orig, ","))
log_step("Number of ratings: thousands separator removed",
         sum(str_detect(nr_orig, ","), na.rm = TRUE))

# ---- 6. Café type: blank -> missing, clean factor -----------------------
df <- df %>%
  mutate(cafe_type = factor(na_if(`Cafe Type`, ""),
                            levels = c("Independent", "Local Chain",
                                       "International Chain")))
log_step("Cafe type missing", sum(is.na(df$cafe_type)))

# ---- 7. Numeric columns -------------------------------------------------
df <- df %>%
  mutate(seats_in  = as.numeric(`Seating Places Inside`),
         seats_out = as.numeric(`Seating Places Outside`),
         rating    = as.numeric(`Rating (Google)`),
         roastery  = as.numeric(`Is Roastery (0/1)`),
         dist_km   = as.numeric(`Distance from Pražský Orloj`),
         lat       = as.numeric(Latitude),
         lon       = as.numeric(Longitude))
log_step("Roastery missing (kept as NA, not set to 0)", sum(is.na(df$roastery)))

# ---- 8. Visit date: mixed formats ("9/22/2026" and "9/22/26") -----------
df$visit <- parse_date_time(df$`Date and time of visit`,
                            orders = c("mdY HMS", "mdy HMS", "mdY HM", "mdy HM"))
log_step("Visit dates that failed to parse", sum(is.na(df$visit)))

# ---- 9. Derived variables (log(x+1) as required by the brief) -----------
df <- df %>%
  mutate(log_ratings   = log(n_ratings + 1),
         log_seats_in  = log(seats_in + 1),
         log_seats_out = log(seats_out + 1),
         prague1       = as.integer(district == "Prague 1"),
         chain         = as.integer(cafe_type != "Independent"),   # local + intl
         outdoor       = as.integer(seats_out >= 1),
         district_big  = district %in% paste("Prague", c(1, 2, 3, 5, 7, 8)))

# Duplicate check (the brief says duplicates do not count)
dups <- df %>% count(`Link to GMaps (Share -> Link to Share)`) %>% filter(n > 1)
log_step("Duplicate cafes (same Maps link) -- INVESTIGATE", nrow(dups))

# ---- 10. Keep only analysis columns and write ---------------------------
clean <- df %>%
  transmute(student = `Name`, visit, district, district_name = `District (name)`,
            cafe = `Cafe name`, lat, lon, dist_km,
            espresso, cappuccino, flat_white, filter,
            seats_in, seats_out, rating, n_ratings,
            cafe_type, roastery, note = Note,
            log_ratings, log_seats_in, log_seats_out,
            prague1, chain, outdoor, district_big)

write_csv(clean, clean_path)
dir.create("report/tables", recursive = TRUE, showWarnings = FALSE)
write_csv(log_tbl, "analysis/cleaning_log.csv")
print(log_tbl, n = Inf)
cat("Clean rows:", nrow(clean), "\n")

# =====================================================================
# 01_cleaning.R  --  raw data -> cleaned data set
# Run from the repository root. Raw file is never edited by hand.
# NOTE: starter version. Check every step against YOUR understanding;
# you must be able to explain each line at the defense.
# =====================================================================
library(tidyverse)
library(lubridate)

raw_path   <- "analysis/raw_data.csv"
clean_path <- "analysis/dataset.csv"

if (!file.exists(raw_path)) {
  stop("Raw file not found at '", raw_path, "'. Working directory is: ", getwd(),
       "\nPut the CSV in an 'analysis' folder and set the working directory ",
       "to the repository root (or edit raw_path).")
}

raw <- read_csv(raw_path, col_types = cols(.default = col_character()),
                na = c("", "NA"))

# Rename the column with accented letters so no accents appear in our code
# (accents in a script can break on Windows depending on file