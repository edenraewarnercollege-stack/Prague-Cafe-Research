# Analysis

This folder contains the reproducible R workflow, source data, analysis outputs, and the LaTeX source for the report.

## Files and folders

- `01_cleaning.R`: reads `raw_data.csv` and creates `dataset.csv`.
- `02_descriptive.R`: creates descriptive tables/figures and the method-decision file.
- `03_analysis.R`: runs analyses A1–A10 and creates result tables/figures.
- `helpers.R`: shared functions used by the analysis scripts.
- `raw_data.csv`: original collected data.
- `dataset.csv`: cleaned analysis dataset.
- `tables/`: LaTeX tables and diagnostic check tables.
- `figures/`: PDF figures and diagnostic plots.
- `interim/`: intermediate files produced by the workflow, including `D_decisions.csv`.
- `main (1).tex`: LaTeX source for the report.

## Run the analysis

Run the scripts from the repository root, in this order:

```r
source("analysis/01_cleaning.R")
source("analysis/02_descriptive.R")
source("analysis/03_analysis.R")
```

The scripts expect the R packages used in the source files to be installed. The LaTeX report source should be compiled with the working directory set to this `analysis/` folder so its relative `tables/` and `figures/` paths resolve.

Generated outputs are saved inside this folder.