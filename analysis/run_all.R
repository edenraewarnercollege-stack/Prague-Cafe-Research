# ============================================================
# run_all.R - one-click entry point for the Prague cafe project
#
# In RStudio, open the repository folder as the project/working
# directory, then run:
#   source("analysis/run_all.R")
#
# Missing R packages are installed automatically when possible.
# An internet connection is required for first-time installation.
# ============================================================

if (file.exists(file.path("analysis", "01_cleaning.R"))) {
  repo_root <- getwd()
} else if (basename(getwd()) == "analysis" && file.exists("01_cleaning.R")) {
  repo_root <- dirname(getwd())
  setwd(repo_root)
} else {
  stop("Open the Prague-Cafe-Research repository folder as the working directory, then run source('analysis/run_all.R').")
}

source(file.path("analysis", "01_cleaning.R"))
source(file.path("analysis", "02_descriptive.R"))
source(file.path("analysis", "03_analysis.R"))

setwd(repo_root)
message("All three project scripts have finished.")
