# Script to prepare household energy dataframe from raw input data

## RUN BEFORE: (2) prepare_weather_data.R and (3) join_energy_weather_data.R

# About ----

# Input data: Household energy data

## Data: London Energy Data from Kaggle
### Source: https://www.kaggle.com/datasets/emmanuelfwerr/london-homes-energy-data. (downloaded on August 19, 2023)
### Contents: a single csv file with daily aggregated energy usage (kWh var) for 5,567 London households (id var: lc_lid) from November 2011 to February 2014 (date var)
### Credit: processed and provided to the public domain (CC0) by Emmanuel F. Werr
### Original source: UK Power Networks' SmartMeter Energy Consumption Data in London Households, see https://data.london.gov.uk/dataset/smartmeter-energy-use-data-in-london-households

## Cleaning process: 
### 1. clean column names
### 2. trim dataframe dates to remove low-number early dates and unusual end date values
### 3. remove X households due to insufficient data and/or high percentage 0 kWh days

## output: a tibble (dataframe) with daily energy consumption (kWh) observations for London households across specified timeframe (see input settings below)

# Required libraries ----

library(tidyverse)
library(ggplot2)
library(lubridate)

# Input settings ----

## Input data 1: Household energy data

### desired timeframe
# trim dates because of lack of data at start & unusual end value
# start in Winter 2011 (91 households by that point)
# and remove last date (2014-02-28) due to unusual (very low) median value
start_date = "2011-12-01"
end_date = "2014-02-27"

### rules for removing households
## zero values may be indicative of empty residences and/or
# households generating their own energy (e.g. via solar panels)
# rule: remove households with >= X % (pc_zero_threshold) values as 0 kWh
pc_zero_threshold <- 10 # set as 10% to include households with 0 energy days when away for short periods (normal holiday behaviour)

### missing values: households do not have data for every day in the timeframe 
# lower number households during initial on-ramp for research project
# rule: remove households with < X (_threshold) number of observations
obs_threshold <- 180 # set as 180 (days) to remove households with less than ~6 months' worth of data

### output filepath for household energy data
hhold_energy_output_filepath <- "4_cleaned_data/daily_energy_clean.csv"
hhold_all_energy_output_filepath <- "4_cleaned_data/daily_energy_all_hholds.csv"

# Load and describe dates of raw data ----
daily_energy <- read_csv("3_raw_data/london_energy.csv") %>% 
  janitor::clean_names() %>% 
  # add vars for month, season, weekday type
  mutate(month = month(date, label = TRUE), .after = date) %>% 
  mutate(wday = wday(date, label = TRUE), .after = month) %>% 
  mutate(weekend = if_else(wday %in% c("Sat", "Sun"), T, F), .after = wday) %>% 
  mutate(quarter = quarter(date, type = "date_first", fiscal_start = 12), .after = month) %>%
  mutate(yearseason = case_when(
    quarter == "2011-09-01" ~ "Autumn 2011",
    quarter == "2011-12-01" ~ "Winter 2011",
    quarter == "2012-03-01" ~ "Spring 2012",
    quarter == "2012-06-01" ~ "Summer 2012",
    quarter == "2012-09-01" ~ "Autumn 2012",
    quarter == "2012-12-01" ~ "Winter 2012",
    quarter == "2013-03-01" ~ "Spring 2013",
    quarter == "2013-06-01" ~ "Summer 2013",
    quarter == "2013-09-01" ~ "Autumn 2013",
    quarter == "2013-12-01" ~ "Winter 2013",
    .default = NA_character_
  ), .after = quarter) %>% 
  mutate(yearseason = factor(yearseason, levels = c(
    "Autumn 2011", "Winter 2011", "Spring 2012", "Summer 2012",
    "Autumn 2012", "Winter 2012", "Spring 2013", "Summer 2013",
    "Autumn 2013", "Winter 2013"
  ))) %>% 
  mutate(season = case_when(
    str_detect(yearseason, "Winter") ~ "Winter",
    str_detect(yearseason, "Summer") ~ "Summer",
    str_detect(yearseason, "Spring|Autumn") ~ "Spring/Autumn",
    .default = NA_character_
  ), .after = month)

# Trim dates according to input settings ----  
daily_energy_trim <- daily_energy %>% 
  filter(date >= start_date & date <= end_date)

start_date_trim <- min(daily_energy_trim$date)
end_date_trim <- max(daily_energy_trim$date)

# Clean households according to input settings ----
total_days <- as.numeric(max(daily_energy_trim$date) - min(daily_energy_trim$date) + 1)

## generate household data quality stats
hhold_stats <- daily_energy_trim %>% 
  mutate(zero_kwh = if_else(kwh == 0, T, F)) %>% 
  group_by(lc_lid) %>%
  summarise(num_values = n(),
            num_zeros = sum(zero_kwh),
            min_value = min(kwh),
            max_value = max(kwh),
            range = (max(kwh) - min(kwh)),
            median_kwh = median(kwh),
            iqr = IQR(kwh),
            mean_kwh = mean(kwh),
            sd = sd(kwh)
  ) %>% 
  mutate(pc_missing_days = (100 * (total_days - num_values) / total_days), .after = lc_lid) %>% 
  mutate(pc_zero_values = (100 * num_zeros / num_values), .after = pc_missing_days) %>% 
  ungroup()  

## list households with more than 10% of data as 0 kWh
hholds_pc_zero <- hhold_stats %>% 
  filter(pc_zero_values > pc_zero_threshold) %>% 
  pull(lc_lid) # 73 hholds

## list households with fewer than 180 observations (6 months) in dataset
hholds_num_obs <- hhold_stats %>% 
  filter(!lc_lid %in% hholds_pc_zero) %>% 
  filter(num_values < obs_threshold) %>% 
  pull(lc_lid) # 19 hholds

## create cleaned df by removing households with limited data or lots of zeros, trim dates)
daily_energy_clean <- daily_energy_trim %>% 
  filter(!lc_lid %in% hholds_pc_zero) %>% 
  filter(!lc_lid %in% hholds_num_obs)

## evaluate cleaning change
num_hholds_og <- length(unique(daily_energy_trim$lc_lid))
num_hholds_clean <- length(unique(daily_energy_clean$lc_lid))
num_hholds_removed <- num_hholds_og - num_hholds_clean
pc_hholds_removed <- 100 * num_hholds_removed / num_hholds_og

# Save cleaned data to new csv file
write_csv(daily_energy_clean, hhold_energy_output_filepath)

# also save trimmed data, before removing households, for further exploration
write_csv(daily_energy_trim, hhold_all_energy_output_filepath)

# Print messages about cleaning steps

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

## Print outcome of household cleaning step.
print(str_c("Cleaning step complete: ",num_hholds_removed," (",pc_hholds_removed,"%) households removed, ",num_hholds_clean," remaining households in cleaned data."))

dim_energy_clean <- dim(daily_energy_clean)

print(str_c("Household energy data preparation complete: cleaned data contains ",dim_energy_clean[1]," observations and ",dim_energy_clean[2]," attributes, and has been written to ",hhold_energy_output_filepath,". For data without removing any households, use ",hhold_all_energy_output_filepath,"."))
