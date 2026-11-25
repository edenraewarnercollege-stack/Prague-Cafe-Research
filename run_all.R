# ============================================================
# run_all.R - run the complete Prague Cafe analysis in one click
#
# Open the repository folder as the RStudio working directory,
# then run: source("run_all.R")
# Missing packages are installed automatically when possible.
# ============================================================

repo_root <- getwd()

required_files <- file.path("analysis", c(
  "01_cleaning.R",
  "02_descriptive.R",
  "03_analysis.R",
  "raw_data.csv",
  "dataset.csv"
))
missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files)) {
  stop(
    "Open the Prague Cafe Research repository folder as the working directory. ",
    "Missing: ", paste(missing_files, collapse = ", ")
  )
}

required_packages <- c("ggplot2", "sandwich", "lmtest")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages)) {
  message("Installing required packages: ", paste(missing_packages, collapse = ", "))
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

tryCatch({
  setwd(file.path(repo_root, "analysis"))

  message("\n===== STEP 1 OF 3: DATA CLEANING =====")
  source("01_cleaning.R")

  message("\n===== STEP 2 OF 3: DESCRIPTIVE ANALYSIS =====")
  source("02_descriptive.R")

  message("\n===== STEP 3 OF 3: RESEARCH ANALYSIS =====")
  source("03_analysis.R")

  message("\nALL DONE! See the report folder for generated tables and figures.")
}, finally = {
  setwd(repo_root)
})
