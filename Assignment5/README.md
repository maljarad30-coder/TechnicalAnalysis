# BDA400 Assignment 5 — Technical Analysis Using R (Development Stage)

**Student:** Mohammad Aljarad  
**Course:** BDA400 — Data Science Tools and Techniques  
**Repository:** https://github.com/maljarad30-coder/TechnicalAnalysis

## Project contents

- `functions/01_sma.R` through `functions/09_crossunder.R`: the nine required indicator functions, each in its own R script.
- `functions/10_filters_and_trading_rules.R`: date and indicator filters plus a moving-average crossover position rule.
- `00_run_assignment5.R`: loads the functions, reads the Assignment 2 OHLCV CSV files, calculates indicators, filters recent observations, and writes output CSV files.
- `outputs/`: generated technical-analysis and filtered-signal CSV files.
- `Aljarad_Mohammad_CA_BDA400_A05.pdf`: assignment explanation and run instructions (cover page includes repository URL).

All indicator calculations in Assignment 5 use base R. The `SMA20` column already present in the Assignment 2 input CSVs was calculated with TTR; the Assignment 5 script ignores that column and recalculates SMA using `sma()`.

## Run in RStudio

1. Open this repository in RStudio and set the working directory to the `Assignment5` folder.
2. Run `99_validate_functions.R` by selecting **Source** or entering `source("99_validate_functions.R")`. It should print a passed message after checking the indicators, filters, and trading rule.
3. Open `00_run_assignment5.R` and select **Source**, or run `source("00_run_assignment5.R")` in the Console.
4. Review the summary printed in the Console and the CSV files created in `Assignment5/outputs`.

No indicator packages are required. The source data are the daily OHLCV CSV files in `../Assignment2/outputs` for AAPL, MSFT, and GOOGL.

## Calculation notes

- SMA returns one value per complete window; the runner pads earlier rows with `NA` to preserve date alignment.
- EMA uses the assignment's recursive formula and seeds the first EMA value with the first observation.
- `stdev()` uses population standard deviation (division by *n*), as shown in the assignment pseudocode.
- RSI uses Wilder smoothing and returns `NA` until its first complete period. When average gain and loss are both zero, RSI is defined as 50; when only losses are zero it is 100, and when only gains are zero it is 0.
- StochRSI normalizes RSI against rolling extrema over `period`, smooths %K with `k_period`, and smooths %D with `d_period`.
- Crossover returns `Up`, `Down`, or `None`; crossunder returns `True`, `False`, or `None` to match the supplied pseudocode.
- The example filter keeps the latest 90 calendar days where closing price is above the base-R SMA20. The trading rule enters a long position at an upward SMA20/SMA50 cross and returns to flat at a downward cross.

## Submission checklist

- Upload the final PDF to the LMS using the requested filename: `Aljarad_Mohammad_CA_BDA400_A05.pdf`.
- Keep this Assignment 5 folder and its separate R scripts in the project repository.
- Confirm the repository URL on the PDF cover page is accessible to the evaluator.
