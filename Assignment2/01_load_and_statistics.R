# BDA400 - Assignment 2 | Mohammad Aljarad
# 01_load_and_statistics.R
# Functions for reading symbols, loading Yahoo Finance stock data,
# and calculating descriptive statistics on the daily closing price.
# This is sourced by 02_display_and_visualize.R.

read_portfolio <- function(path = "portfolio.txt") {
  if (!file.exists(path)) stop("Missing portfolio file: ", path)

  symbols <- readLines(path, warn = FALSE, encoding = "UTF-8")
  symbols <- trimws(symbols)
  symbols <- unique(toupper(symbols[nzchar(symbols)]))

  if (length(symbols) == 0L) stop("portfolio.txt has no stock symbols.")
  if (any(!grepl("^[A-Z0-9.^_-]+$", symbols))) {
    stop("portfolio.txt contains invalid stock ticker symbols.")
  }
  return(symbols)
}

load_stock_data <- function(portfolio_path = "portfolio.txt",
                            from = Sys.Date() - 365,
                            to = Sys.Date() + 1) {
  if (!requireNamespace("quantmod", quietly = TRUE)) {
    stop("quantmod is missing; first run 00_install_packages.R")
  }
  if (!requireNamespace("zoo", quietly = TRUE)) {
    stop("zoo is missing; first run 00_install_packages.R")
  }
  symbols <- read_portfolio(portfolio_path)
  results <- list()
  errors <- character()

  for (symbol in symbols) {
    cat("Downloading ", symbol, "...\n", sep = "")
    tryCatch({
      prices <- quantmod::getSymbols(Symbols = symbol, src = "yahoo",
                                     from = from, to = to,
                                     auto.assign = FALSE)
      if (NROW(prices) < 20L) {
        stop("fewer than 20 daily observations available")
      }
      stock_frame <- data.frame(
        Date = as.Date(zoo::index(prices)),
        Open = as.numeric(quantmod::Op(prices)),
        High = as.numeric(quantmod::Hi(prices)),
        Low = as.numeric(quantmod::Lo(prices)),
        Close = as.numeric(quantmod::Cl(prices)),
        Volume = as.numeric(quantmod::Vo(prices))
      )
      stock_frame <- stock_frame[order(stock_frame$Date), , drop = FALSE]
      rownames(stock_frame) <- NULL
      results[[symbol]] <- stock_frame
      cat("Loaded ", nrow(stock_frame), " rows for ", symbol, ".\n", sep = "")
    }, error = function(e) {
      errors <<- c(errors, paste0(symbol, ": ", conditionMessage(e)))
    })
  }

  if (length(errors) > 0L) {
    stop("Some stocks could not be loaded. Check internet/Yahoo access:\n",
         paste(errors, collapse = "\n"))
  }
  return(results)
}

# A numerical mode is the most frequently occurring price rounded to cents.
# If each rounded value occurs only once, there is no unique observed mode.
rounded_price_mode <- function(x, digits = 2L) {
  values <- round(x[is.finite(x)], digits)
  if (length(values) == 0L) return(NA_character_)
  counts <- table(values)
  if (max(counts) == 1L) return(NA_character_)
  modes <- names(counts)[counts == max(counts)]
  return(paste(modes, collapse = "; "))
}

calculate_statistics <- function(stock_data, symbol, ma_window = 20L) {
  if (!requireNamespace("TTR", quietly = TRUE)) {
    stop("TTR is missing; first run 00_install_packages.R")
  }
  close_prices <- as.numeric(stock_data$Close)
  valid <- close_prices[is.finite(close_prices)]
  if (length(valid) < ma_window) {
    stop(symbol, " has too few observations for the moving average.")
  }

  stock_data$SMA20 <- as.numeric(TTR::SMA(close_prices, n = ma_window))
  non_missing_ma <- stock_data$SMA20[is.finite(stock_data$SMA20)]

  summary_row <- data.frame(
    Symbol = symbol,
    Observations = length(valid),
    FirstDate = as.character(min(stock_data$Date)),
    LastDate = as.character(max(stock_data$Date)),
    LatestClose = round(tail(valid, 1), 2),
    MeanClose = round(mean(valid), 2),
    MedianClose = round(stats::median(valid), 2),
    ModeClose = rounded_price_mode(valid),
    StdDevClose = round(stats::sd(valid), 2),
    SMA20Latest = round(tail(non_missing_ma, 1), 2),
    stringsAsFactors = FALSE
  )
  return(list(data = stock_data, summary = summary_row))
}

run_analysis <- function(portfolio_path = "portfolio.txt",
                         from = Sys.Date() - 365,
                         to = Sys.Date() + 1) {
  stocks <- load_stock_data(portfolio_path, from, to)
  results <- lapply(names(stocks), function(sym) {
    calculate_statistics(stocks[[sym]], sym)
  })
  names(results) <- names(stocks)
  summary_table <- do.call(rbind, lapply(results, function(x) x$summary))
  rownames(summary_table) <- NULL
  return(list(stocks = results, summary = summary_table))
}
