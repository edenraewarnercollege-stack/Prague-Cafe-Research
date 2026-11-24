# ============================================================
# 01_cleaning.R - clean the collected raw CSV
# Run from the repository root:
#   source("analysis/01_cleaning.R")
#
# This creates cafes_clean.csv as a cleaned source-data export.
# The A1-A10 analyses use the supplied analysis/dataset.csv, which
# contains the project's prepared analysis variables.
# ============================================================

required_packages <- c("readr", "dplyr", "stringr", "lubridate")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages)) {
  message("Installing missing packages: ", paste(missing_packages, collapse = ", "))
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}
still_missing <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(still_missing)) {
  stop("Could not install required packages: ", paste(still_missing, collapse = ", "))
}

library(dplyr)
library(stringr)
library(readr)
library(lubridate)

raw_path <- file.path("analysis", "raw_data.csv")
clean_path <- file.path("analysis", "cafes_clean.csv")

if (!file.exists(raw_path)) {
  stop("Cannot find ", raw_path,
       ". Run this script from the repository root directory.")
}

raw <- read_csv(
  raw_path,
  col_types = cols(.default = col_character()),
  na = c("", "NA", "N/A"),
  show_col_types = FALSE
)

required_columns <- c(
  "Name", "Date and time of visit", "District (number)", "District (name)",
  "Cafe name", "Link to GMaps (Share -> Link to Share)",
  "Espresso Price in CZK (dine-in)",
  "Cappuccino Price in CZK (normal milk, dine-in)",
  "Flat White Price in CZK (normal milk, dine-in)",
  "Filter/Batch (in CZK, dine-in)", "Seating Places Inside",
  "Seating Places Outside", "Rating (Google)",
  "Number of ratings (Google)", "Cafe Type", "Is Roastery (0/1)",
  "Distance from Pražský Orloj", "Latitude", "Longitude", "Note"
)
missing_columns <- setdiff(required_columns, names(raw))
if (length(missing_columns)) {
  stop("The raw CSV is missing expected column(s): ",
       paste(missing_columns, collapse = ", "))
}

# Remove rows without a cafe name and trim text fields.
df <- raw %>%
  filter(!is.na(`Cafe name`), str_squish(`Cafe name`) != "") %>%
  mutate(across(where(is.character), str_squish))

# Convert a price cell to its first listed numeric price.
first_price <- function(x) {
  x <- str_to_lower(x)
  x[x %in% c("na", "n/a", "")] <- NA_character_
  suppressWarnings(as.numeric(str_extract(x, "[0-9]+(?:\\.[0-9]+)?")))
}

df <- df %>%
  mutate(
    district_num = str_extract(`District (number)`, "[0-9]+"),
    district = if_else(
      is.na(district_num), NA_character_, paste("Prague", district_num)
    ),
    espresso = first_price(`Espresso Price in CZK (dine-in)`),
    cappuccino = first_price(`Cappuccino Price in CZK (normal milk, dine-in)`),
    flat_white = first_price(`Flat White Price in CZK (normal milk, dine-in)`),
    filter_price = first_price(`Filter/Batch (in CZK, dine-in)`),
    n_ratings = suppressWarnings(as.numeric(
      str_remove_all(`Number of ratings (Google)`, ",")
    )),
    seats_in = suppressWarnings(as.numeric(`Seating Places Inside`)),
    seats_out = suppressWarnings(as.numeric(`Seating Places Outside`)),
    rating = suppressWarnings(as.numeric(`Rating (Google)`)),
    roastery = suppressWarnings(as.numeric(`Is Roastery (0/1)`)),
    dist_km = suppressWarnings(as.numeric(`Distance from Pražský Orloj`)),
    lat = suppressWarnings(as.numeric(Latitude)),
    lon = suppressWarnings(as.numeric(Longitude)),
    visit = parse_date_time(
      `Date and time of visit`,
      orders = c("mdY HMS", "mdy HMS", "mdY HM", "mdy HM"),
      quiet = TRUE
    ),
    cafe_type = na_if(`Cafe Type`, "")
  ) %>%
  mutate(
    cafe_type = factor(
      cafe_type,
      levels = c("Independent", "Local Chain", "International Chain")
    ),
    log_ratings = log(n_ratings + 1),
    log_seats_in = log(seats_in + 1),
    log_seats_out = log(seats_out + 1),
    prague1 = if_else(is.na(district), NA_integer_,
                      as.integer(district == "Prague 1")),
    chain = if_else(is.na(cafe_type), NA_integer_,
                    as.integer(cafe_type != "Independent")),
    outdoor = if_else(is.na(seats_out), NA_integer_,
                      as.integer(seats_out >= 1)),
    district_big = district %in% paste("Prague", c(1, 2, 3, 5, 7, 8))
  )

# Flag repeated Google Maps links for review; do not silently delete rows.
duplicate_links <- df %>%
  filter(linked) %>%
  count(`Link to GMaps (Share -> Link to Share)`) %>%
  filter(n > 1)

clean <- df %>%
  transmute(
    student = Name, visit, district, district_name = `District (name)`,
    cafe = `Cafe name`, lat, lon, dist_km,
    espresso, cappuccino, flat_white, filter = filter_price,
    seats_in, seats_out, rating, n_ratings,
    cafe_type, roastery, note = Note,
    log_ratings, log_seats_in, log_seats_out,
    prague1, chain, outdoor, district_big
  )

write_csv(clean, clean_path, na = "")
dir.create("analysis", showWarnings = FALSE, recursive = TRUE)
cleaning_log <- tibble(
  item = c("Rows in raw CSV", "Rows without cafe name removed",
           "Rows in cleaned export", "Unique duplicate Maps links flagged",
           "Visit dates that failed to parse"),
  value = c(
    nrow(raw),
    nrow(raw) - nrow(df),
    nrow(clean),
    nrow(duplicate_links),
    sum(is.na(df$visit))
  )
)
write_csv(cleaning_log, "analysis/cleaning_log.csv", na = "")

cat("Cleaned export written to:", clean_path, "\n")
cat("Rows in cleaned export:", nrow(clean), "\n")
cat("Potential duplicate Maps links flagged:", nrow(duplicate_links), "\n")
cat("Cleaning log written to: analysis/cleaning_log.csv\n")
