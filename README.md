# Classifying household electricity use with smart meter data

## Project description

In this project, I used exploratory data analysis and K-means clustering to understand and classify patterns of household energy use by season and weekday type, using openly available data from a research exercise in London in ~2014 (see 'Data sources' section below).

### Project context 

This was my final "capstone" project for CodeClan course, August 2023, completed in 7 days (over ~12 day period). The brief was to carry out an end-to-end data project addressing a business-relevant brief (fictional) and present insights back to the "client" - for which, this repo also contains the final project presentation slides.

For this project, I imagined the client was an energy company or related organisation, who were interested in better understanding how household customers were using energy, with the intention to use these insights to improve their products and services.

This repo contains R code; I am currently working to rewrite this in Python (repo URL tbc).

## Analysis brief

How can data be used by energy suppliers/related organisations to target energy advice and services?

I envisaged business problems include:

* Unpaid bills, including the issue of seasonal fluctuation of energy usage leading to more people unable to afford winter fuel bills
* Need to spread out electricity usage, to balance load on national grid and make better use of renewable sources
* Need to reduce electricity usage from non-renewable sources, by inefficient electrical appliances, and/or where unaffordable for customers (fuel poverty)

So I sought to understand:

* Which factors influence electricity use?
* How does electricity use vary across years, seasons, days? Is this predictable?
* How does electricity use vary between individual households? Is this predictable?

Understanding which features are good predictors for household energy use enables the business to:

* Model energy consumption in upcoming years (and seasons) with different weather scenarios (i.e. as climate changes)
* Predict times of high and low energy demand (low demand is important, because renewable sources are often turned down at this time to manage load in the grid)
* Calculate potential energy and cost savings from any improvements to domestic energy efficiency

I was also interested in ways to cluster households by their energy consumption patterns, which may be a useful way to segment domestic energy customers and provide more targeted information and services.

## Selected outputs and insights

**1. Electricity usage is seasonal**

The median electricity usage for these London households fluctuated between 7-10 kWh/day throughout the year, with peaks in Winter months.

![time series line graph of energy usage over time](/7_presentation/graph_images/all_hholds_median_ts.png)

Note that the typical household in England uses 75% energy (all types) on heating the home, and electric storage heaters and portable heaters are expensive (electricity is more expensive than gas) but they are the main heating method for a substantial minority - according to the [English Housing Survey](https://www.gov.uk/government/collections/english-housing-survey).

**2. Individual household energy usage patterns are different**

Households behave differently - in seasonality and also in weekday/weekend changes, as illustrated by these line graphs of energy use over time by three individual households:

![line graphs of energy consumption opver time for three individual households stacked horizontally](/7_presentation/graph_images/three_hholds.png)

**3. Energy consumption is typically higher at weekends**

The trend remaining after seasonal decomposition of the time series data shows that energy consumption is typically higher on weekend days. This weekday vs weekend difference was a feature I used in the clustering model.

![line graphs of energy usage over time split by weekday, Monday to Sunday from left to right, show higher average usage on Saturdays and Sundays](/7_presentation/graph_images/weekday_trend_energy.png)

**4. Clustering identifies three types of household according to their pattern of energy usage**

Based on the insights about seasonality and weekday, I generated a new datasets with features describing the change by season (Summer to Winter) and weekday type (Monday to Friday versus weekends), such that the resulting dataframe included one row per household with summary statistics for:

* (1) Mean daily energy consumption in Winter (as a baseline measure of "highest" energy consumption)
* Summer → Winter change in (2) mean kWh and (3) variability (sd)
* Weekend change in mean kWh in (4) Summer and (5) Winter separately

These statistics were generated from the most recent Summer and Winter periods in the data (June-August 2013, and December 2013 - February 2014, respecitvely). The resulting dataframe included data from 5,078 households, reduced from total n = 5,566 as these were the households with at least 45 days’ recorded energy data per season - chosen as a threshold in order to have sufficient / sensible amount of data to form summary statistics from.

After performing K-means clustering on a range of k from 1-10, and assessing model performance using the elbow and silhouette methods and also by visualising the clusters, the optimal number of clusters (k) was 3.

These three clusters seem to split households by 

(i) high/low changers in response to weekday type (Mon-Fri versus Sat/Sun):

![Scatterplot of energy change in Summer weekends against energy change in Winter weekends, such that households with high weekend to weekday change in both seasons are top right in this plot - with points coloured by cluster number (1-3)](/7_presentation/graph_images/k3_weekend_effect_scatterplot.png)

and (ii) high/low changers in response to season (Winter energy usage > Summer usage):

![Boxplot of fold change in energy usage from Summer to Winter, split by cluster number (1-3), showing cluster 3 has the highest change](/7_presentation/graph_images/k3_winter_effect_boxplot.png)

Resulting in three types of household, described by:

* **Cluster 1:** largest group (3,151 (62%) households) – low electricity users, small seasonal fluctuations
* **Cluster 2:** second-largest group (1,117 (22%) households) – similar to cluster 1 except use more energy at weekends
* **Cluster 3:** smallest group (810 (16%) households) – use more energy during winter

![line graphs of energy usage over time for each cluster, stacked vertically](/7_presentation/graph_images/three_clusters_ts.png)

**5. Energy usage correlates with weather**

Energy usage tends to be higher when temperature is lower:

![scatterplot of daily energy usage against daily temperature](/7_presentation/graph_images/energy_v_temperature_scatter.png)

I did not include this behaviour in the clustering model because daily temperature also correlates with season (see below), so this would not be an independent variable from the Winter/Summer change features. One way to include this feature in a new model could be to look at change in energy use according to temperature fluctuations within a single season (i.e. within Winter only).

![boxplots of energy usage data grouped by month of the year, from Jan to Dec along the x-axis](/7_presentation/graph_images/monthly_temp.png)

### Recommendations

The business/organisation could use these data insights to target advice and services according to the type of household, in particular:

* **Winter users** - households with higher-than-average consumption overall, especially during Winter (16% households in cluster 3), are a high priority group considering the issue of fuel poverty. These households may include non-working adults, people with higher heating needs and/or less energy-efficient homes. I recommend the business/organisation considers providing these customers with support to improve energy efficiency at home and to prepare for winter energy bills (for example: financial management tips and tools, signpost additional financial support schemes)
* **Weekend users** - for households with higher energy use over the weekend (22% households in cluster 2), which may include working adults and families, the business/organisation could encourage these customers to use appliances during off-peak times (cheaper pricing)

## Data sources and considerations

I used a secondary source of existing historic data from London households, in which the primary data had been aggregated into daily energy usage, which reduced the size and complexity of the data (original source is 167 million rows in total, with half-hourly measurements). Given the timeframe, I chose to work with the aggregated data (at least initially). This secondary source was also linked to matching weather observations, which were interesting potential features predicting energy usage. So, the datasets used in this project were:

* **Dataset 1: London Energy Data** - a single csv file with daily aggregated energy usage for 5,567 London households from November 2011 to February 2014 from the [UK Power Networks' SmartMeter Energy Consumption Data in London Households](https://data.london.gov.uk/dataset/smartmeter-energy-use-data-in-london-households) project, provided to the public domain (CC0) by Emmanuel F. Werr on Kaggle. URL: https://www.kaggle.com/datasets/emmanuelfwerr/london-homes-energy-data. (downloaded on August 19, 2023). This csv file contains 3 attributes (household id, date, total energy consumption (in kilowatt-hours, kWh)) and 3510433 observations, where one observation is one household's energy consumption on that date.
* **Dataset 2: London Weather Data** - a single csv file with daily historic weather observations in London from 1978 to 2021 sourced from the [European Climate Assessment & Dataset (ECAD)](https://www.ecad.eu/), provided to the public domain (CC0) by Emmanuel F. Werr on Kaggle. URL: https://www.kaggle.com/datasets/emmanuelfwerr/london-weather-data (downloaded on August 19, 2023). This csv file contains 10 attributes (date, and nine weather measurements, including min, max and mean temperature, number of hours of sunshine and total precipitation) and 15341 observations, where one observation is one day's weather. The weather measurements are a mix of totals, averages, minimums and maximums across the different measures, although it is not clear for some values whether they are totals or averages, since the original [element](https://www.ecad.eu/dailydata/datadictionaryelement.php) code and the cleaning script is not included.

The **primary data source** is from a UK Power Networks research project on [SmartMeter Energy Consumption Data in London Households](https://data.london.gov.uk/dataset/smartmeter-energy-use-data-in-london-households). The original data is provided openly online ([CC-BY license](https://opendefinition.org/licenses/cc-by/)) as half-hourly measurements of household electricity usage for 5,567 London households from November 2011 to February 2014, and including their pricing tariff group. Data source URL: https://data.london.gov.uk/dataset/smartmeter-energy-use-data-in-london-households (a zip file of low-carbon-london-data-168-files (758.86 MB) was downloaded on August 19, 2023 but not used in the final analysis here). More information about the original Low Carbon London project, including final reports, is available from https://innovation.ukpowernetworks.co.uk/projects/low-carbon-london/.

There are various data ethics considerations here:

* **Representativeness:** According to the original research project, "the customers in the trial were recruited as a balanced sample representative of the Greater London population" ([data.london.gov.uk](https://data.london.gov.uk/dataset/smartmeter-energy-use-data-in-london-households)). We should take care about extending any conclusions from this data beyond London, especially where demographics and energy needs may differ substantially.
* **Potential harm or misuse:** The primary data were collected as part of a research project, working with EDF customers with their consent (noted in an early progress report: [June 2011 six-month report](https://innovation.ukpowernetworks.co.uk/wp-content/uploads/2019/05/Six-Monthly-Project-Progress-Report-June-2011.pdf)). The data used does not contain any information about the household itself, other than an identifier value, so we do not know location or any personal information about the inhabitants. However, categorising households according to their energy consumption patterns may reveal personal information about how a house is used, including whether it is vacant (many days with low/no energy usage), or could be used to infer properties of the household (size, insulation, whether there are energy intensive devices being run). So the business requirements are not free from ethical implications, and we should consider how the resulting data or model may be used by the business or any others who see any public outputs. For example, burglars could target households with very low usage on predicted zero-energy days, with the assumption they may be unoccupied residences. However, I consider this unlikely, and overall I think the probability of any severe implications from misuse is low.
* **Confounding factor in this analysis:** Importantly, the original research project by UK Power Network included two groups of customers: one group (~1100 households) had dynamic energy pricing, and received warnings about higher and lower prices for the next day; the other set (~4,500 households) had fixed prices. The project aimed to understand how pricing warnings might affect energy consumption behaviour. While the primary data source includes the pricing group, the daily aggregated London energy dataset provided on Kaggle does not include this, therefore there is a missing variable in the analysis here that should be considered in future work.
* **Missing information in prior processing:** The processing scripts and details for the secondary data sources were not provided, therefore I assume the Kaggle dataset author did this correctly. Some assumptions have been made as to what the weather data variables mean, given the original source had multiple options for each of the variables inferred from the column names. 

## Process

1. **Exploration of data** - to:
  a. understand what's possible, with which data sources - see [brief data exploration notebook](../1_exploration_notes/brief_data_exploration.Rmd)
  b. analyse the data overall: summary statistics, correlations, patterns, working out how to clean/wrangle/transform data for clustering and what kinds of clustering splits to look out for - see notebooks for [data exploration](../6_analyses/data_exploration.Rmd), [weather data exploration](../6_analyses/weather_data_exploration.Rmd), [household energy stats](../6_analyses/household_energy_stats.nb.html) and [feature engineering for clustering](../6_analyses/feature_engineering_hhold_clustering.Rmd) (including first attempt at K-means clustering)
2. **Cleaning, preparing, joining data** - informed by the above exploration, see [scripts](../5_scripts/) to prepare household_energy_data (from London energy dataset), prepare weather data (from London weather dataset) and join the two datasets together.
  a. Steps for [cleaning household energy data](../5_scripts/prepare_household_energy_data.R) included (i) clean column names, (ii) trim dataframe dates to remove low-number early dates and unusual end date values and (iii - optional) remove some households due to insufficient data and/or high percentage 0 kWh days (the final joined data used in clustering did not include this data removal step, it included all households' data at first and households with insufficient data were removed during the clustering preparation process, see below)
  b. Steps for [cleaning weather data](../5_scripts/prepare_weather_data.R) included (i) trim to date range matching the energy data, (ii) factorise some weather observations (e.g. snow to TRUE/FALSE) nad (iii) add some data quality indicators where temperature variables do not make sense (e.g. min_temp > mean_temp for that day)
3. **Perform K-means clustering** - see [K-means clustering notebook](../6_analyses/K_means_clustering.Rmd), including data preparation for clustering, analysis of clustering model performance and visualisation of the resulting clusters. Step-by-step, the clustering process involved:
  a. Find features that summarise household energy use
  b. Select variables to cluster households by
  c. Prepare data (e.g. scale)
  d. Optimise for k in k-means clustering
  e. Interpret and visualise results
4. **Create visualisations to present** to the "client" (in a live 10-minute presentation to CodeClan instructors and fellow students, August 30th) - see [presentation graphs notebook](../7_presentation/presentation_graphs.Rmd)
5. **Create presentation** - see [PDF of slides](../7_presentation/CodeClan_finalproject_Aug2023.pdf)

### Reflections and next steps

This was a short project to complete the CodeClan course (~7 days) and it could be improved and extended in several ways.

* **1. Improve existing model**
  * Add more explanatory variables: within-season weather changes (using weather dataset), pricing tariff groups (from original data)
  * Try different clustering methods, e.g. DB-SCAN, PCA
* **2. Enable continuous updates**
  * Productionise model
  * Pipeline to add/update customer data, regenerate models to classify households, e.g. Reproducible Analytical Pipeline (RAP) in Python (for example, see NHS Digital resources on [Github](https://github.com/NHSDigital/data-analytics-services#rap-publication-repositories))
* **3. Perform additional analyses**
  * Probabilistic forecasting to predict future electricity usage (e.g. by cluster group)
  * Analyse within-day energy usage (original data has half-hourly measurements: at what time of day do households use most/least electricity?)
  * Enrich with information on solar panels, gas (and other energy source) consumption
  * Develop predictive model (e.g. to predict which "customer segment" to assign new households to according to recent energy consumption)
  * Compare to other means of customer segmentation - there may be easier, cheaper, more effective and accurate methods than machine learning!

## Toolstack

All analysis was conducted in R (version 4.3.1) using RStudio. 

The analysis notebooks used the following R packages:

* tidyverse - for wrangling and analysing
* lubridate - to work with datetime data
* ggplot2 - to visualise data and produce graphs to present
* tsibble - to work with time series data
* slider - to make a rolling average of energy usage, to show a smoother line on the plot
* GGally - for ggpairs to explore correlations
* psych - for pairplots to explore correlations
* cluster - for k-means clustering
* corrplot - for correlation plot
* broom - for k means optimisation stats
* ggsignif - for silhouette method
* rstatix - for silhouette method
* factoextra - for silhouette method
* feasts - to try time series forecasting (deprioritised in this project)

The presentation was made using Google Slides.
