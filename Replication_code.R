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


data <- data %>%
  mutate(
    positive=rowMeans(cbind(pos1, pos2, pos3), na.rm = T),
    negative=rowMeans(cbind(neg1, neg2, neg3), na.rm = T),
    fp_views=(positive-negative)/100,
    iraq_dummy=ifelse(troops_iraq>0,1,0),
    afg_dummy=ifelse(troops_afgh>0,1,0),
    fh=pr+cl,
    nonnat=ifelse(nonnat1+nonnat2+nonnat3>0,1,0)
  )

model1 <- lm(unvoting~fp_views, data=data)
summary(model1)

model2 <- lm(unvoting~
               fp_views +
               afg_dummy +
               icc +
               s_lead +
               nato +
               aid_m +
               aid_e +
               lntrade +
               lngdppc +
               fh +
               muslimpct +
               europe,
             data=data)

stargazer(model1, model2,
          dep.var.caption = "",
          dep.var.labels = "UN Voting with US in 2003",
          title = "Regression Results (OLS only)",
          covariate.labels = c("Opinion on US FP",
                               "Troops in AFG",
                               "ICC member",
                               "Alliance portfolio",
                               "NATO",
                               "US military aid",
                               "US economic aid",
                               "Trade with US",
                               "GDP per capita",
                               "Democracy score",
                               "Muslim population",
                               "Europe",
                               "Constant"),
          type = "latex",
          no.space = T,
          header = F, 
          digits=2,
          table.placement = "H")
