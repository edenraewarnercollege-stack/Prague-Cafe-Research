# Analysis materials

This folder contains the collected café data, R scripts and supporting outputs for the updated Prague café price project.

## Files

- `raw_data.csv` — collected source data.
- `dataset.csv` — cleaned dataset created by `01_cleaning.R` and used by scripts 02 and 03.
- `01_cleaning.R` — inspects and cleans `raw_data.csv`, then writes `dataset.csv`.
- `02_descriptive.R` — produces descriptive statistics, diagnostic plots and `interim/D_decisions.csv`.
- `03_analysis.R` — runs analyses A1–A10 using `dataset.csv` and the decisions file.
- `interim/helpers.R` — shared functions used by scripts 02 and 03.
- `main (1).tex` — LaTeX source for the written report.

## How to run

1. Install R (or RStudio) and open the repository folder as the working directory.
2. Run this command from the repository root:

```r
source("run_all.R")
```

The runner executes scripts 01, 02 and 03 in order. It checks for required packages and attempts to install missing packages from CRAN. An internet connection and permission to install packages are needed on first use. Script 02 creates `analysis/interim/D_decisions.csv`, which script 03 requires.

## Reproducibility note

The updated partner-supplied scripts have been uploaded and their file paths have been aligned in the repository. The complete latest workflow still needs a fresh end-to-end run in R/RStudio to confirm runtime reproducibility.
