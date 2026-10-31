# BDA400 - Assignment 2 | Mohammad Aljarad
# 02_display_and_visualize.R
# Run from the Assignment2 folder in RStudio, after 00_install_packages.R.
# Produces console previews, summary CSV, stock CSVs, and three PNG charts.

if (!file.exists("01_load_and_statistics.R") || !file.exists("portfolio.txt")) {
  stop("Wrong working directory. Select the Assignment2 folder in RStudio first.")
}

source("01_load_and_statistics.R", local = TRUE)

# Run the functions and retain each separate per-stock data frame.
analysis <- run_analysis(portfolio_path = "portfolio.txt")

# Display the imported rows and statistics in RStudio's Console.
cat("\n===== DESCRIPTIVE STATISTICS =====\n")
print(analysis$summary, row.names = FALSE)

dir.create("outputs", showWarnings = FALSE)
utils::write.csv(analysis$summary,
                 file = file.path("outputs", "statistics_summary.csv"),
                 row.names = FALSE, na = "")

for (symbol in names(analysis$stocks)) {
  stock_frame <- analysis$stocks[[symbol]]$data
  cat("\n===== ", symbol, " : FIRST 6 ROWS =====\n", sep = "")
  print(utils::head(stock_frame, 6L), row.names = FALSE)
  cat("\n===== ", symbol, " : LAST 6 ROWS =====\n", sep = "")
  print(utils::tail(stock_frame, 6L), row.names = FALSE)

  utils::write.csv(stock_frame,
                   file = file.path("outputs", paste0(symbol, "_data.csv")),
                   row.names = FALSE)

  plot_file <- file.path("outputs", paste0(symbol, "_close_and_SMA20.png"))
  grDevices::png(plot_file, width = 1200, height = 700, res = 125)
  tryCatch({
    graphics::plot(stock_frame$Date, stock_frame$Close, type = "l", lwd = 2,
                   col = "#2463A7", xlab = "Trading date",
                   ylab = "Price (USD)",
                   main = paste0(symbol, " | Daily Closing Price and 20-Day SMA"))
    graphics::lines(stock_frame$Date, stock_frame$SMA20,
                    lwd = 2, col = "#D97A26")
    graphics::grid(col = "#D7DFE8")
    graphics::legend("topleft", legend = c("Daily close", "20-day SMA"),
                     col = c("#2463A7", "#D97A26"),
                     lty = 1, lwd = 2, bty = "n")
  }, finally = {
    grDevices::dev.off()
  })
  cat("Chart saved: ", plot_file, "\n", sep = "")
}

cat("\nSUCCESS: all portfolio symbols processed.\n")
cat("Saved the summary, stock data CSV files, and charts in the 'outputs' folder.\n")
