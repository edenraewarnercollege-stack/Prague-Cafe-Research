# Analysis materials

This folder contains the collected café data, the prepared analysis dataset, R scripts and supporting outputs for the Prague café price project.

## Files

- `raw_data.csv` — collected source data.
- `dataset.csv` — prepared analysis dataset used by the A1–A10 scripts.
- `01_cleaning.R` — cleans `raw_data.csv` and writes `cafes_clean.csv` plus `cleaning_log.csv`.
- `02_descriptive.R` — produces descriptive statistics, diagnostic plots and the method-decision file.
- `03_analysis.R` — runs analyses A1–A10 using the prepared `dataset.csv`.
- `run_all.R` — one-click entry point that runs scripts 01–03 in order.
- `helpers.R` — shared functions used by scripts 02 and 03.
- `main (1).tex` — LaTeX source for the written report.

## How to run

1. Install R (or RStudio) and open the repository folder as the working directory.
2. Run this single command:

```r
source("analysis/run_all.R")
```

The runner executes scripts 01, 02 and 03 in order. Each script checks for its required packages and attempts to install any that are missing from CRAN. An internet connection and permission to install packages are needed on first use. Script 02 creates `analysis/interim/D_decisions.csv`, which script 03 requires.

## Important dataset note

The A1–A10 analyses use the supplied `dataset.csv`, which contains prepared variables used by the report (for example, adjusted ratings and analysis indicators). Script 01 produces a separate cleaned export from the raw collection sheet; it does not overwrite `dataset.csv`. This avoids replacing the prepared analysis dataset with a differently structured file.

The scripts have been edited to correct the raw CSV filename, remove duplicated cleaning code, and make helper/data/output paths consistent. However, this environment does not have an R runtime, so the scripts have **not yet been executed end-to-end**. Runtime reproducibility still needs confirmation in R/RStudio.
