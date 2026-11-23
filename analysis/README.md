# Analysis materials

This folder contains the collected café data, the prepared analysis dataset, R scripts and supporting outputs for the Prague café price project.

## Files

- `raw_data.csv` — collected source data.
- `dataset.csv` — prepared analysis dataset used by the A1–A10 scripts.
- `01_cleaning.R` — cleans `raw_data.csv` and writes `cafes_clean.csv` plus `cleaning_log.csv`.
- `02_descriptive.R` — produces descriptive statistics, diagnostic plots and the method-decision file.
- `03_analysis.R` — runs analyses A1–A10 using the prepared `dataset.csv`.
- `helpers.R` — shared functions used by scripts 02 and 03.
- `main (1).tex` — LaTeX source for the written report.

## How to run

1. Install R and the packages used by the scripts. Script 01 checks for `readr`, `dplyr`, `stringr` and `lubridate`. Script 02 uses `ggplot2` (and its dependencies). Script 03 additionally requires `sandwich` and `lmtest`.
2. Open the repository folder as the working directory in R or RStudio.
3. Run the scripts in this order:

```r
source("analysis/01_cleaning.R")
source("analysis/02_descriptive.R")
source("analysis/03_analysis.R")
```

Scripts 02 and 03 also support being run from inside the `analysis` folder. Script 02 creates `analysis/interim/D_decisions.csv`, which script 03 requires.

## Important dataset note

The A1–A10 analyses use the supplied `dataset.csv`, which contains prepared variables used by the report (for example, adjusted ratings and analysis indicators). Script 01 produces a separate cleaned export from the raw collection sheet; it does not overwrite `dataset.csv`. This avoids replacing the prepared analysis dataset with a differently structured file.

The scripts have been edited to correct the raw CSV filename, remove duplicated cleaning code, and make helper/data/output paths consistent. However, this environment does not have an R runtime, so the scripts have **not yet been executed end-to-end**. Runtime reproducibility still needs confirmation in R/RStudio.
