# btc_data_utils.R

library(httr)
library(jsonlite)
library(dplyr)
library(lubridate)

get_btc_data <- function(start_date = "2018-06-05") {
  start_ts <- as.numeric(as.POSIXct(start_date, tz = "UTC"))
  now_ts <- as.numeric(Sys.time())
  all_data <- list()
  to_ts <- now_ts
  
  repeat {
    print(as_datetime(to_ts))
    url <- paste0("https://data-api.coindesk.com/index/cc/v1/historical/minutes?",
                  "market=cadli&instrument=BTC-USD",
                  "&limit=400",
                  "&to_ts=", to_ts,
                  "&aggregate=5&fill=true&apply_mapping=true&response_format=JSON&api_key=36337c730b37348f3a6636b661f4ffef6b11663dfe31c468207afc71a4d28422")
    
    response <- GET(url)
    data <- fromJSON(content(response, "text"))$Data
    
    if (is.null(data) || length(data) == 0) break
    
    all_data[[length(all_data) + 1]] <- data
    earliest_ts <- suppressWarnings(min(data$TIMESTAMP, na.rm = TRUE))
    
    if (is.infinite(earliest_ts) || earliest_ts <= start_ts) break
    
    to_ts <- earliest_ts - 300  # Resta 60 segundos (es dato por minuto)
  }
  
  combined_data <- bind_rows(all_data)
  combined_data <- combined_data %>%
    filter(!is.na(TIMESTAMP), TIMESTAMP >= start_ts) %>%
    mutate(date = as_datetime(TIMESTAMP)) %>%
    arrange(date)
  
  return(combined_data)
}
