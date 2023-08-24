# Script to prepare household energy dataframe from raw input data

## RUN AFTER: (1) prepare_household_energy_data.R
## RUN BEFORE: (3) join_energy_weather_data.R

# About ----

# Input data: London weather data

## Data: London Weather Data from Kaggle
### Source: https://www.kaggle.com/datasets/emmanuelfwerr/london-weather-data (downloaded on August 19, 2023)
### Contents: a single csv file with daily historic weather observations in London from 1978 to 2021 with 10 attributes (date, and nine weather measurements, including min, max and mean temperature, number of hours of sunshine and total precipitation) and 15341 observations, where one observation is one day's weather. The weather measurements are a mix of totals, averages, minimums and maximums across the different measures, although it is not clear for some values whether they are totals or averages, since the original [element](https://www.ecad.eu/dailydata/datadictionaryelement.php) code and the cleaning script is not included.
### Credit: processed and provided to the public domain (CC0) by Emmanuel F. Werr
### Original source(s): sourced from the European Climate Assessment & Dataset (ECAD): https://www.ecad.eu/

# Required libraries ----

library(tidyverse)
library(ggplot2)
library(lubridate)

# Input settings ----

### desired timeframe
# trim dates to match start & end of energy dataframe
energy_data <- read_csv("4_cleaned_data/daily_energy_clean.csv") %>% 
  janitor::clean_names()

start_date = min(energy_data$date)
end_date = max(energy_data$date)

### output filepath for weather data
weather_output_filepath <- "4_cleaned_data/daily_weather_clean.csv"

# Load and trim dates of raw data ----
daily_weather_trim <- read_csv("3_raw_data/london_weather.csv") %>% 
  janitor::clean_names() %>% 
  mutate(date = ymd(date)) %>% 
  filter(as_date(date) >= start_date & as_date(date) <= end_date)

start_date_trim <- min(daily_weather_trim$date)
end_date_trim <- max(daily_weather_trim$date)

# Additional cleaning steps (if any) ----

# Save cleaned data to new csv file ----
write_csv(daily_weather_trim, weather_output_filepath)

# Print messages about cleaning steps ----

## Statement / warning about start and end date settings
if (start_date_trim == start_date & end_date_trim == end_date) {
  print(str_c("Data loaded and dates trimmed to start on ",start_date_trim," and end on ",end_date_trim,", as specified in input settings."))
} else if (start_date_trim != start_date){
  if (end_date_trim == end_date) {
    print(str_c("Data loaded and dates trimmed. Warning: start date of trimmed data (",start_date_trim,") does not match input settings (",start_date,"). Please check data.")) 
  } else { # if (end_date_trim != end_date)
    print(str_c("Data loaded and dates trimmed. Warning: start and end dates of trimmed data do not match input settings. Please check data."))
  }
} else { # start == but end !=
  print(str_c("Data loaded and dates trimmed. Warning: end date of trimmed data (",end_date_trim,") does not match input settings (",end_date,"). Please check data."))
}

## Print outcome of cleaning steps (if any)
##print(str_c("Cleaning step complete: ",num_hholds_removed," (",pc_hholds_removed,"%) households removed, ",num_hholds_clean," remaining households in cleaned data."))

dim_weather_clean <- dim(daily_weather_trim)

print(str_c("Weather data preparation complete: cleaned data contains ",dim_weather_clean[1]," observations and ",dim_weather_clean[2]," attributes, and has been written to ",weather_output_filepath,"."))
