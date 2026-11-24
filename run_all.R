# ============================================================
# run_all.R - run the complete Prague Cafe analysis in one click
#
# Open the Prague Cafe Research RStudio project, then click
# the Source button while this file is open.
# Missing packages are installed automatically if internet access
# and permission to install R packages are available.
# ============================================================

# Confirm that the scripts and data are available from this folder.
required_files <- c(
  "analysis/01_cleaning.R",
  "analysis/02_descriptive.R",
  "analysis/03_analysis.R",
  "analysis/raw_data.csv",
  "analysis/dataset.csv"
)
missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files)) {
  stop(
    "Some project files could not be found. Open the Prague Cafe Research ",
    "RStudio project and run this file from the repository root. Missing: ",
    paste(missing_files, collapse = ", ")
  )
}

# Install all packages used by the three scripts and shared helpers.
required_packages <- c(
  "readr", "dplyr", "stringr", "lubridate",
  "ggplot2", "sandwich", "lmtest"
)
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages)) {
  message(
    "Installing required packages: ",
    paste(missing_packages, collapse = ", ")
  )
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}

still_missing <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(still_missing)) {
  stop(
    "These packages could not be installed: ",
    paste(still_missing, collapse = ", "),
    ". Check the internet connection and R package installation permissions."
  )
}

message("\n===== STEP 1 OF 3: DATA CLEANING =====")
source("analysis/01_cleaning.R")

message("\n===== STEP 2 OF 3: DESCRIPTIVE ANALYSIS =====")
source("analysis/02_descriptive.R")

message("\n===== STEP 3 OF 3: RESEARCH ANALYSIS =====")
source("analysis/03_analysis.R")

message(
  "\nALL DONE! The cleaning outputs, tables and figures have been generated. ",
  "See the analysis and report folders."
)
