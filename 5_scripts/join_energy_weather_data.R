# Join energy and weather data
## RUN AFTER: (1) prepare_household_energy_data.R and (2) prepare_weather_data.R

library(tidyverse)

# input settings
join_output_filepath <- "4_cleaned_data/daily_energy_weather_clean.csv" # specify

# read in cleaned data files
daily_energy <- read_csv("4_cleaned_data/daily_energy_clean.csv")
daily_weather <- read_csv("4_cleaned_data/daily_weather_clean.csv")

# join dataframes
daily_energy_weather <- left_join(x = daily_energy_clean, y = daily_weather_trim, by = join_by(date))

# write to new file
write_csv(daily_energy_weather, join_output_filepath)

# message to user
dim_join <- dim(daily_energy_weather)

print(str_c("Energy and weather data joined: joined data contains ",dim_join[1]," observations and ",dim_join[2]," attributes, and has been written to ",join_output_filepath,"."))
