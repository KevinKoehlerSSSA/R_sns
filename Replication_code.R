install.packages("haven")


library(tidyverse)
library(haven)
library(stargazer)
library(psych)
library(knitr)
library(kableExtra)

data <- read_dta("data_2011-07-26.dta")

sumstats <- data %>%
  select(-country, -iso3166) %>%
  describe() %>%
  select(n, mean, sd, min, max) %>%
  mutate(mean=round(mean,2),
         sd=round(sd,2),
         min=round(min,2),
         max=round(max,2))

summary_table <- kable(sumstats, 
      format = "html", 
      longtable = TRUE, 
      booktabs = TRUE,
      caption = "Summary statistics", label = "tab:sum_stats") %>%
  kable_styling(latex_options = c("repeat_header", 
                                  "striped",
                                  "condensed"))

write_lines(summary_table, "summary_table.html")
