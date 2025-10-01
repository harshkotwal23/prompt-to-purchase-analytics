
### 1. Load Data ###
df <- read_csv("<file path to data file>")

### 2. Load Packages ###
library(readr)
library(ggplot2)
library(dplyr)

### 3. Sanity Check ###
df %>% 
    group_by(match_success) %>%   ## grouping for output (0, 1) ##
    summarise(imps = n(),   ## setting impressions as total records ## 
              ctr = mean(clicked),   ## CTR grouped by match success ##
              avg_ts = mean(time_spent_on_page_cleaned, na.rm=TRUE),   ## average time spent with potential null values removed ## 
              .groups="drop")   ## ensure that groups are dropped 

### 4. Chi-Squared Test ###
tab_rank <- with(df, table(clicked, match_rank))   ## assigning a variable with the clicked and match_rank columns ##
chisq.test(tab_rank)   ## executing the test ##

### 5. Independent T-Test ###
t.test(clicked ~ match_success, data = df)   ## using t-test function to compare means of clicked and match success from our data frame ##

### 6. ANOVA ###
df$log_ts <- log1p(df$time_spent_on_page_cleaned)   ## We need to transform TS into a log given that our data is skewed, has many outliers, and is a small sample size. This doesn't follow a normal distribution. A log normalizes the data for an ANOVA ##  
aov_fit <- aov(log_ts ~ factor(match_rank), data = df)   ## Run the ANOVA analysis for log(ts) and match rank and store it into a variable. Factor is used to let R know that rank is a categorical, not quantitative/continuous variable ##
summary(aov_fit)   ## Display a summary of the analysis ##

### 7. Logistic Regression ###
log_reg <- glm(   ## Store the model in a variable log_reg ##
	clicked ~ match_success + factor(match_rank) + price + rating + category + company,   ## Structuring the model with the dependent, independent, and confounding variables ##  
	data = df,   ## Providing the source dataframe ##
	family = binomial(link = "logit")   ## Specifying that the data has a binary outcome and that the predictor variables should be tied to probabilities between 0 and 1) ##
	)

exp(coef(log_reg))