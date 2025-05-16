data <- data %>%
  mutate(cbcat = case_when(
    cbcount == 0 ~ "0",
    cbcount == 1 ~ "1",
    cbcount == 2 ~ "2",
    cbcount >= 3 ~ "3+"
  ))
