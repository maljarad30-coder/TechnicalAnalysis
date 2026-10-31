# TechnicalAnalysis / Assignment2

**Student:** Mohammad Aljarad  
**Course:** BDA400 – Data Science Tools and Techniques  
**Assignment:** 2 – Technical Analysis Using R, Preliminary Stage (5%)

## Folder contents

- `portfolio.txt` – stock symbols, one per line (AAPL, MSFT, GOOGL).
- `00_install_packages.R` – installs/verifies `quantmod`, `TTR`, `zoo`.
- `01_load_and_statistics.R` – imports each ticker's historical Yahoo Finance data into a separate data frame and calculates mean, median, mode, standard deviation and SMA(20).
- `02_display_and_visualize.R` – displays rows and statistics, exports CSVs and PNG plots.
- `screenshots/` – insert actual screenshots from the student's GitHub / RStudio execution.
- `outputs/` – created on running script 02; output depends on market data / run date.
- `Aljarad_Mohammad_CA_BDA400_A02.docx/.pdf` – report draft; insert real screenshots and repository link before final submission.

## How to execute in RStudio (Windows)

1. Unzip the project and open RStudio.
2. Change the working directory to this **Assignment2** folder: `Session > Set Working Directory > Choose Directory`. In RStudio, confirm `getwd()` and `file.exists("portfolio.txt")` (must be `TRUE`).
3. Open `00_install_packages.R` and click **Source** (or run `source("00_install_packages.R")` in Console).
4. Open `02_display_and_visualize.R` and click **Source** (or run `source("02_display_and_visualize.R")`). It automatically sources `01_load_and_statistics.R`.
5. Verify the Console reports `SUCCESS`, the summary table shows **all three** tickers, and the `outputs/` folder contains CSVs and charts.
6. Capture your own screenshots of the package installation, file structure, loaded data, statistics, plots, and GitHub repository.
7. Replace **EVIDENCE REQUIRED** fields in the Word report with your screenshots. Add your live GitHub link, then export the report PDF.

## Notes

- Uses **daily closing prices** in USD from Yahoo Finance via the `quantmod` package; internet access is needed. Prices change over time.
- The **mode** is computed after rounding closing prices to 2 decimals; it is blank (`NA`) if no rounded price repeats. Ties are shown separated by semicolons.
- `SMA20` is a simple moving average based on the **last 20 daily closing prices**; the first 19 values are unavailable by definition.
- If Yahoo Finance fails due to a network/API issue, no outputs are fabricated. Investigate the error in RStudio.
- All output files (and charts) should be committed to GitHub **after execution**.
- This prebuilt package is **not yet proof of actual execution**; screenshots and output data must come from your computer.

## References

- Course assignment PDF (provided by the instructor).
- GitHub creation help: https://docs.github.com/en/get-started/start-your-journey/creating-a-repository-for-your-project-on-github
- RStudio working directory: https://support.posit.co/hc/en-us/articles/200711843-Working-Directories-and-Workspaces-in-the-RStudio-IDE
- quantmod documentation: https://cran.r-project.org/package=quantmod
- TTR documentation: https://cran.r-project.org/package=TTR
