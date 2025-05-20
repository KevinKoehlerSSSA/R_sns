url <- "https://en.wikipedia.org/wiki/List_of_presidents_of_the_United_States"
html <- read_html(url)



us_table <- html %>% html_elements("table.wikitable") %>%
  html_table() %>%
  as.data.frame()

names(us_table) <- c("var1",
                     "var2",
                     "var3",
                     "var4",
                     "var5",
                     "var6",
                     "var7",
                     "var8")

us_table <- us_table %>%
  select(var3, var4, var6) %>%
  rename(name=var3,
         term=var4,
         party=var6) 


str_extract("George Washington(1732–1799)[19]","")

## Regex 1: Everything until you hit an opening bracket: .+(?=\\()
## Regex 2: Everything until you hat a dash .+(?=–)
## Regex 3: Everything following a dash (?<=–).+

us_table <- us_table %>%
  mutate(name=str_extract(name,".+(?=\\()"),
         start_term=str_extract(term,".+(?=–)"),
         end_term=str_extract(term,"(?<=–).+"))

us_table <- us_table %>%
  mutate(start_term=str_replace(start_term,"\\[.*",""),
         end_term=str_replace(end_term,"\\[.*",""),
         party=str_replace(party,"\\[.*","")) %>%
  select(-term) 
