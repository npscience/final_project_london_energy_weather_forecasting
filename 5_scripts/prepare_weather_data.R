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

# Additional cleaning steps ----

daily_weather_clean <- daily_weather_trim %>% 
  # add quality col to note the days where (1) mean_temp > max_temp 
  # and (2) min_temp > max_temp
  mutate(temp_qual = case_when(
    mean_temp > max_temp & min_temp > max_temp ~ "warning: max temp less than min temp and mean temp",
    mean_temp > max_temp ~ "warning: max temp less than mean temp",
    min_temp > max_temp ~ "warning: max temp less than min temp",
    .default = NA_character_
  )) %>% 
  # add var for snow yes/no
  mutate(snow_tf = if_else(snow_depth > 0, T, F), .before = snow_depth) %>% 
  # add var for precipitation yes/no
  mutate(precipitation_tf = if_else(precipitation > 0, T, F), .before = precipitation)
  
## Other potential cleaning steps (for later if doing)
# convert pressure to atm pressure units (i.e. / 101,325 Pa) - _no need, not using in this iteration_
# if not using season/month, could add temp_levels factor (low, medium, high - work out how) - _not doing in this iteration_

# Save cleaned data to new csv file ----
write_csv(daily_weather_clean, weather_output_filepath)

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

dim_weather_clean <- dim(daily_weather_clean)

print(str_c("Weather data preparation complete: cleaned data contains ",dim_weather_clean[1]," observations and ",dim_weather_clean[2]," attributes, and has been written to ",weather_output_filepath,"."))
