data <- data %>%
  mutate(cbcat = case_when(
    cbcount == 0 ~ "0",
    cbcount == 1 ~ "1",
    cbcount == 2 ~ "2",
    cbcount >= 3 ~ "3+"
  ))

row1 <- c(table(data$cbcat),
          table(data$newcb),
          sum(!is.na(data$attempt), na.rm=T))
row2 <- c(table(data$cbcat[data$attempt==0]),
          table(data$newcb[data$attempt==0]),
          sum(data$attempt==0, na.rm=T))
row3 <- paste0(round(((row1-row2)/row1)*100,0),"%")
row4 <- c(table(data$cbcat[data$attempt==1]),
          table(data$newcb[data$attempt==1]),
          sum(data$attempt==1, na.rm=T))
row5 <- c(table(data$cbcat[data$success==0]),
          table(data$newcb[data$success==0]),
          sum(data$success==0, na.rm=T))
row6 <- c(table(data$cbcat[data$success==1]),
          table(data$newcb[data$success==1]),
          sum(data$success==1, na.rm=T))
row7 <- paste0(round(((row5-row6)/row5)*100,0),"%")
