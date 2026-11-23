# Prague Café Data Analytics Project

This repository contains the submitted project on dine-in coffee prices and café characteristics in Prague.

## Final submission files

- **[Final written report (PDF)](report/ERDW%20-%20FINAL_DATA_ANALYTICS_PROJECT.pdf)**
- **[Final presentation (PDF)](presentation/DATA_ANALYSIS_PRESENTATION.pdf)**

## Supporting materials

- `analysis/dataset.csv` — analysis dataset.
- `analysis/raw_data.csv` — collected source data.
- `analysis/01_cleaning.R`, `analysis/02_descriptive.R`, and `analysis/03_analysis.R` — R scripts.
- `analysis/helpers.R` — shared analysis functions.
- `analysis/` — supporting statistical tables, figures, diagnostics, and LaTeX report source.

## Running the R scripts

From the repository root in RStudio, run the scripts in this order:

```r
source("analysis/01_cleaning.R")
source("analysis/02_descriptive.R")
source("analysis/03_analysis.R")
```

The scripts use the files and helper functions in `analysis/`. See [`analysis/README.md`](analysis/README.md) for package requirements and details about the inputs and outputs. The cleaning script writes a separate cleaned export (`analysis/cafes_clean.csv`); the A1–A10 analysis scripts use the prepared `analysis/dataset.csv`.

## Notes on reproducibility

The submitted report and presentation PDFs are provided as the final reading copies. The R scripts and supporting analysis files are included for transparency and review. The full R workflow has not been independently rerun from a fresh clone, so the scripts should not be treated as runtime-verified.

The LaTeX source is included as supporting material; the final report PDF above is the submitted version.

## Repository structure

- `analysis/` — data, R scripts, statistical outputs, and report source.
- `report/` — final written report PDF.
- `presentation/` — final presentation PDF.

