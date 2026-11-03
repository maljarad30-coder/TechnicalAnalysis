# Assignment 6: Technical Analysis Using R
# Student: Mohammad Aljarad
# Data source: Yahoo Finance

library(shiny)
library(ggplot2)
library(quantmod)
library(TTR)

ui <- fluidPage(
  titlePanel("Technical Analysis Portfolio Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "symbol", "Select stock:",
        choices = c("Apple (AAPL)" = "AAPL",
                    "Microsoft (MSFT)" = "MSFT",
                    "Alphabet (GOOGL)" = "GOOGL")
      ),
      
      dateRangeInput(
        "date_range", "Select date range:",
        start = Sys.Date() - 365,
        end = Sys.Date(),
        min = Sys.Date() - 1825,
        max = Sys.Date()
      ),
      
      selectInput(
        "time_frame", "Select time frame:",
        choices = c("Daily", "Weekly", "Monthly")
      ),
      
      selectInput(
        "chart_type", "Select chart type:",
        choices = c("Line", "Area", "Candlestick")
      ),
      
      checkboxGroupInput(
        "indicators", "Technical indicators:",
        choices = c("SMA 20" = "SMA20",
                    "SMA 50" = "SMA50",
                    "RSI (14)" = "RSI",
                    "MACD" = "MACD"),
        selected = c("SMA20", "SMA50")
      ),
      
      numericInput("short_ma", "Short moving average:", 20, min = 2, max = 200),
      numericInput("long_ma", "Long moving average:", 50, min = 2, max = 300),
      
      helpText("The short moving-average period must be smaller than the long period.")
    ),
    
    mainPanel(
      h4(textOutput("signal_summary")),
      plotOutput("price_chart", height = "450px"),
      
      conditionalPanel(
        "input.indicators.indexOf('RSI') >= 0",
        h4("Relative Strength Index (RSI)"),
        plotOutput("rsi_chart", height = "220px")
      ),
      
      conditionalPanel(
        "input.indicators.indexOf('MACD') >= 0",
        h4("Moving Average Convergence Divergence (MACD)"),
        plotOutput("macd_chart", height = "220px")
      )
    )
  )
)

server <- function(input, output, session) {
  
  stock_data <- reactive({
    req(input$symbol, input$date_range)
    
    # Fetch extra history so moving averages have enough observations.
    fetch_from <- input$date_range[1] - 260
    fetch_to <- input$date_range[2] + 1
    
    tryCatch(
      getSymbols(
        input$symbol,
        src = "yahoo",
        from = fetch_from,
        to = fetch_to,
        auto.assign = FALSE
      ),
      error = function(e) NULL
    )
  })
  
  analysis_data <- reactive({
    validate(
      need(input$short_ma < input$long_ma,
           "The short moving-average period must be smaller than the long period.")
    )
    
    x <- stock_data()
    validate(need(!is.null(x), "Stock data could not be downloaded. Check your internet connection and try again."))
    
    if (input$time_frame == "Weekly") {
      x <- to.weekly(x, indexAt = "lastof", OHLC = TRUE)
    } else if (input$time_frame == "Monthly") {
      x <- to.monthly(x, indexAt = "lastof", OHLC = TRUE)
    }
    
    d <- data.frame(
      Date = as.Date(index(x)),
      Open = as.numeric(Op(x)),
      High = as.numeric(Hi(x)),
      Low = as.numeric(Lo(x)),
      Close = as.numeric(Cl(x)),
      Volume = as.numeric(Vo(x))
    )
    
    d$SMA20 <- as.numeric(SMA(d$Close, n = 20))
    d$SMA50 <- as.numeric(SMA(d$Close, n = 50))
    d$ShortMA <- as.numeric(SMA(d$Close, n = input$short_ma))
    d$LongMA <- as.numeric(SMA(d$Close, n = input$long_ma))
    
    rsi_values <- RSI(d$Close, n = 14)
    d$RSI <- as.numeric(rsi_values)
    
    macd_values <- MACD(d$Close, nFast = 12, nSlow = 26, nSig = 9)
    d$MACD <- as.numeric(macd_values[, 1])
    d$MACDSignal <- as.numeric(macd_values[, 2])
    d$MACDHistogram <- d$MACD - d$MACDSignal
    
    previous_short <- c(NA, head(d$ShortMA, -1))
    previous_long <- c(NA, head(d$LongMA, -1))
    
    d$Signal <- ifelse(
      is.na(d$ShortMA) | is.na(d$LongMA) |
        is.na(previous_short) | is.na(previous_long),
      NA,
      ifelse(
        d$ShortMA > d$LongMA & previous_short <= previous_long, "Buy",
        ifelse(
          d$ShortMA < d$LongMA & previous_short >= previous_long, "Sell",
          "Hold"
        )
      )
    )
    
    d
  })
  
  visible_data <- reactive({
    d <- analysis_data()
    d[d$Date >= input$date_range[1] & d$Date <= input$date_range[2], ]
  })
  
  output$signal_summary <- renderText({
    d <- visible_data()
    validate(need(nrow(d) > 0, "No data is available for the selected dates."))
    
    valid_signals <- d$Signal[!is.na(d$Signal)]
    if (length(valid_signals) == 0) {
      return("Trading signal: Not enough data to calculate a signal.")
    }
    
    paste("Latest trading signal:", tail(valid_signals, 1))
  })
  
  output$price_chart <- renderPlot({
    d <- visible_data()
    validate(need(nrow(d) > 0, "No data is available for the selected dates."))
    
    p <- ggplot(d, aes(x = Date))
    
    if (input$chart_type == "Candlestick") {
      candle_width <- if (input$time_frame == "Daily") 0.35 else
        if (input$time_frame == "Weekly") 2 else 7
      
      p <- p +
        geom_segment(aes(y = Low, yend = High), color = "gray35") +
        geom_rect(
          aes(
            xmin = Date - candle_width / 2,
            xmax = Date + candle_width / 2,
            ymin = pmin(Open, Close),
            ymax = pmax(Open, Close),
            fill = Close >= Open
          ),
          color = "gray35"
        ) +
        scale_fill_manual(
          values = c("TRUE" = "#16805D", "FALSE" = "#C44747"),
          guide = "none"
        )
    } else if (input$chart_type == "Area") {
      p <- p + geom_area(aes(y = Close), fill = "#8DB7D7", alpha = 0.65)
    } else {
      p <- p + geom_line(aes(y = Close), color = "#244A73", linewidth = 0.8)
    }
    
    if ("SMA20" %in% input$indicators) {
      p <- p + geom_line(aes(y = SMA20, color = "SMA 20"), linewidth = 0.8)
    }
    
    if ("SMA50" %in% input$indicators) {
      p <- p + geom_line(aes(y = SMA50, color = "SMA 50"), linewidth = 0.8)
    }
    
    signal_points <- d[!is.na(d$Signal) & d$Signal %in% c("Buy", "Sell"), ]
    
    p +
      geom_point(
        data = signal_points,
        aes(y = Close, color = Signal),
        size = 2.5
      ) +
      geom_text(
        data = signal_points,
        aes(y = Close, label = Signal, color = Signal),
        vjust = -0.9,
        size = 3.5,
        show.legend = FALSE
      ) +
      scale_color_manual(
        values = c("SMA 20" = "#E69F00",
                   "SMA 50" = "#7A5195",
                   "Buy" = "#16805D",
                   "Sell" = "#C44747")
      ) +
      labs(
        title = paste(input$symbol, "Stock Price and Trading Signals"),
        x = "Date",
        y = "Price (USD)",
        color = "Legend"
      ) +
      theme_minimal()
  })
  
  output$rsi_chart <- renderPlot({
    d <- visible_data()
    validate(need(nrow(d) > 0, "No data is available for the selected dates."))
    
    ggplot(d, aes(x = Date, y = RSI)) +
      geom_line(color = "#356A9A", linewidth = 0.8) +
      geom_hline(yintercept = c(30, 70), linetype = "dashed",
                 color = "#C44747") +
      coord_cartesian(ylim = c(0, 100)) +
      labs(x = "Date", y = "RSI") +
      theme_minimal()
  })
  
  output$macd_chart <- renderPlot({
    d <- visible_data()
    validate(need(nrow(d) > 0, "No data is available for the selected dates."))
    
    ggplot(d, aes(x = Date)) +
      geom_col(aes(y = MACDHistogram), fill = "#8DB7D7") +
      geom_line(aes(y = MACD), color = "#244A73", linewidth = 0.8) +
      geom_line(aes(y = MACDSignal), color = "#E69F00", linewidth = 0.8) +
      labs(x = "Date", y = "MACD", color = "Line") +
      theme_minimal()
  })
}

shinyApp(ui = ui, server = server)
