#IQR:
#The IQR Method uses an innerquartile range of 25 the median. With the default alpha = 0.05, 
#the limits are established by expanding the 25/75 baseline by an IQR Factor of 3 (3X). 
#The IQR Factor = 0.15 / alpha (hense 3X with alpha = 0.05). To increase the IQR Factor controling the limits, 
#decrease the alpha, which makes it more difficult to be an outlier. Increase alpha to make it easier to be an outlier.
  
#GESD:
#The GESD Method (Generlized Extreme Studentized Deviate Test) progressively eliminates outliers using a 
#Student's T-Test comparing the test statistic to a critical value. Each time an outlier is removed, 
#the test statistic is updated. Once test statistic drops below the critical value, all outliers are considered removed. 
#Because this method involves continuous updating via a loop, it is slower than the IQR method. 
#However, it tends to be the best performing method for outlier removal.

###################################################################################################

#Instalando el paquete
install.packages('anomalize')
install.packages("devtools")
devtools::install_github("business-science/anomalize")
install.packages('coindeskr')

# Librerias
library(anomalize) #tidy anomaly detection
library(tidyverse) #tidyverse packages like dplyr, ggplot, tidyr
#library(coindeskr) #bitcoin price extraction from coindesk
source("get_btc_data.R")
source("save_dataframe_multiformat.R")
library(dplyr)

#https://www.coindesk.com/about

#btc <- get_historic_price(start = "2017-01-01")
#Alternativa
#btc <- GET("https://data-api.coindesk.com/index/cc/v1/historical/days?market=cadli&instrument=BTC-USD&limit=30&aggregate=1&fill=true&apply_mapping=true&response_format=JSON")
#btc <- fromJSON(content(btc, "text"))
#btc_data = btc$Data
btc_data <- get_btc_data()
delete_list_column = c("UNIT", "TYPE", "MARKET", "FIRST_MESSAGE_TIMESTAMP", 
                       "LAST_MESSAGE_TIMESTAMP", "FIRST_MESSAGE_VALUE", "HIGH_MESSAGE_VALUE", 
                       "HIGH_MESSAGE_TIMESTAMP", "LOW_MESSAGE_VALUE", "LOW_MESSAGE_TIMESTAMP",
                       "LAST_MESSAGE_VALUE", "TOTAL_INDEX_UPDATES", "QUOTE_VOLUME", "VOLUME_TOP_TIER", 
                       "QUOTE_VOLUME_TOP_TIER", "VOLUME_DIRECT", "QUOTE_VOLUME_DIRECT", "VOLUME_TOP_TIER_DIRECT", 
                       "QUOTE_VOLUME_TOP_TIER_DIRECT" )
btc_data <- btc_data %>% select(-all_of(delete_list_column))
save_data(btc_data)
head(btc_data)
diffs_time <- diff(btc_data$date)
table(diffs_time)
#btc_data$fecha <- as.POSIXct(btc_data$TIMESTAMP, origin = "1970-01-01", tz = "UTC")

column_studing = c("date", "CLOSE")
btc_ts = btc_data %>% select(all_of(column_studing))
#btc_ts <- btc_data %>% rownames_to_column() %>% as_tibble() %>% 
#  mutate(date = as.Date(rowname)) %>% select(-one_of('rowname'))

btc_ts <- btc_ts %>% rownames_to_column() %>% as_tibble() %>% select(-one_of('rowname'))


btc_ts %>% 
  time_decompose(CLOSE, method = "stl", frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "gesd", alpha = 0.05, max_anoms = 0.2) %>% 
  plot_anomaly_decomposition()


#method = "iqr"
#The anomaly detection method. One of "iqr" or "gesd". 
#The IQR method is faster at the expense of possibly not being quite as accurate. 
#The GESD method has the best properties for outlier detection, but is loop-based and therefore a bit slower.


btc_ts %>% 
  time_decompose(CLOSE) %>%
  anomalize(remainder) %>%
  time_recompose() %>%
  plot_anomalies(time_recomposed = TRUE, ncol = 3, alpha_dots = 0.5)


btc_ts %>% 
  time_decompose(CLOSE) %>%
  anomalize(remainder) %>%
  time_recompose() %>%
  filter(anomaly == 'Yes') 



######################################################################################################333


#SPX index

library(readr)
Index2020_parser <- read_csv("Index2020_parser.csv", 
                             col_types = cols(id = col_skip(), date = col_date(format = "%Y-%m-%d")))
View(Index2020_parser)

View(Index2020)

spx_price_ts <- Index2020_parser$spx %>% as_tibble() %>% 
  mutate(date = Index2020_parser$date)


########################## Ultimos datos desde Oct 2019

spx_price_ts_oct=spx_price_ts[6712:6888,]

spx_price_ts_oct %>% 
  time_decompose(value, method = "stl", frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "gesd", alpha = 0.05, max_anoms = 0.2) %>% 
  plot_anomaly_decomposition()



spx_price_ts_oct %>% 
  time_decompose(value) %>%
  anomalize(remainder) %>%
  time_recompose() %>%
  plot_anomalies(time_recomposed = TRUE, ncol = 3, alpha_dots = 0.5)


###################################################################################

library(readr)
test_detect_anoms <- read_csv("test_detect_anoms.csv", col_types = cols(timestamp = col_datetime(format = "%Y-%m-%d %H:%M:%S")))
View(test_detect_anoms)

  
test_da_ts <- test_detect_anoms$count %>% as_tibble() %>% 
  mutate(date = test_detect_anoms$timestamp)
  


test_da_ts %>% 
  time_decompose(value, method = "stl", frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "gesd", alpha = 0.05, max_anoms = 0.2) %>% 
  plot_anomaly_decomposition()



test_da_ts %>% 
  time_decompose(value) %>%
  anomalize(remainder) %>%
  time_recompose() %>%
  plot_anomalies(time_recomposed = TRUE, ncol = 3, alpha_dots = 0.5)

###################################################################################

btc_ts %>% 
  time_decompose(CLOSE, method = "stl", frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "gesd", alpha = 0.05, max_anoms = 0.2) %>% 
  plot_anomaly_decomposition()



