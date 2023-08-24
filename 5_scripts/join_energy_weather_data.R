# Join energy and weather data
## RUN AFTER: (1) prepare_household_energy_data.R and (2) prepare_weather_data.R

library(tidyverse)

# input settings
join_output_filepath <- "../4_cleaned_data/daily_energy_weather_clean.csv" # specify
join_all_output_filepath <- "../4_cleaned_data/daily_energy_weather_all.csv" # specify

# read in cleaned data files
daily_energy <- read_csv("../4_cleaned_data/daily_energy_clean.csv")
daily_energy_all_hholds <- read_csv("../4_cleaned_data/daily_energy_all_hholds.csv") # includes all hholds, ## i.e. without removing those with missing data and lots of zero values removed (in case of solar panels)
daily_weather <- read_csv("../4_cleaned_data/daily_weather_clean.csv")

# join dataframes
daily_energy_weather <- left_join(x = daily_energy, y = daily_weather, by = join_by(date))
daily_energy_weather_all_hholds <- left_join(x = daily_energy_all_hholds, y = daily_weather, by = join_by(date))

# write to new file
write_csv(daily_energy_weather, join_output_filepath)
write_csv(daily_energy_weather_all_hholds, join_all_output_filepath)

# message to user
dim_join <- dim(daily_energy_weather)
dim_join_all <- dim(daily_energy_weather_all_hholds)

print(str_c("Energy and weather data joined: joined data contains ",dim_join[1]," observations and ",dim_join[2]," attributes, and has been written to ",join_output_filepath,". Note another file also written (",join_all_output_filepath,") that joins weather with all households' data (before removing those with missing values and 10%+ days with 0 kWh values) in case these missing/0 values are to do with the household(s) having solar panels."))
