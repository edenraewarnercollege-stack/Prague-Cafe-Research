# Prague Café Data Analytics Project

This repository contains the updated project on dine-in coffee prices and café characteristics in Prague.

## Final submission files

- **[Final written report (PDF)](report/An_Analysis_of_Coffee_Prices_and_Cafe_Characteristics_in_Prague__1_.pdf)**
- **[Final presentation (PDF)](presentation/final_presentation.pdf)**

## Supporting materials

- `analysis/dataset.csv` — analysis dataset.
- `analysis/raw_data.csv` — collected source data.
- `analysis/01_cleaning.R`, `analysis/02_descriptive.R`, and `analysis/03_analysis.R` — R scripts.
- `analysis/interim/helpers.R` — shared analysis functions used by scripts 02 and 03.
- `analysis/` — supporting statistical tables, figures, diagnostics, and LaTeX report source.

## Running the R scripts

For a one-click run in RStudio, open the repository folder as the working directory and run:

```r
source("run_all.R")
```

The runner executes the cleaning, descriptive, and research-analysis scripts in order. Missing packages are installed automatically when possible; an internet connection and permission to install packages are required on first use. The cleaning script creates `analysis/dataset.csv` from `analysis/raw_data.csv`; the later scripts use that dataset. The descriptive script creates `analysis/interim/D_decisions.csv`, which the research-analysis script then reads.

## Notes on reproducibility

The updated report and presentation PDFs are provided as the final reading copies. The R scripts and supporting analysis files are included for transparency and review. The latest partner-supplied workflow has not yet been independently rerun from a fresh clone, so it should not be described as fully runtime-verified until tested in R/RStudio.

The LaTeX source is included as supporting material.

## Repository structure

- `analysis/` — data, R scripts, statistical outputs, and report source.
- `report/` — final written report PDF and generated tables/figures.
- `presentation/` — final presentation PDF.
