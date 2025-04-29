library(ggplot2)
library(patchwork)

## We start with simulating some data
set.seed(123) # for reproducibility

# Number of observations
n <- 500

# Simulate 10 Likert-scale variables (5 points + NA possibility)
likert_vars <- replicate(10, {
  sample(c(1:5, NA), n, replace = TRUE, prob = c(rep(0.19, 5), 0.05))
})

# Simulate age (interval scale 18–100)
age <- sample(18:100, n, replace = TRUE)

# Simulate gender (binary: 'm' or 'f')
gender <- sample(c("m", "f"), n, replace = TRUE)

# Simulate income (ordinal, 10 levels)
income <- sample(1:10, n, replace = TRUE)

# Simulate education (ordinal, 6 levels)
education <- sample(1:6, n, replace = TRUE)

# Combine into a data frame
data_sim <- data.frame(
  likert_vars,
  age = age,
  gender = gender,
  income = income,
  education = education
)

# Assign Likert variable names
colnames(data_sim)[1:10] <- paste0("likert_", 1:10)

# Quick check
str(data_sim)
head(data_sim)

## Looping and plotting

### First, we need to determine if something is a Likert-scale variable

# Option 1
is_likert <- function(x) {
  is.numeric(x) && all(na.omit(x) %in% 1:5)
}

# Option 2
likert_columns <- grepl("likert",names(data_sim)) 

### There are more options of course...

# Next, we want to loop through all variables in the dataframe

for(varnames in names(data_sim)) {
  if(is_likert(data_sim[[varnames]])) {
    print(paste(varnames,"is Likert-scaled",sep=" "))
  }
}

# Or: 

for(v in 1:14) {
  if(is_likert(data_sim[[v]])) {
    print(paste("Variable",v,"is Likert-scaled",sep=" "))
  }
}

# so far, so good. But we want to do different things in the loop (namely transform the right variables into a factor and then plot them)

# for one variable, the code would be:

## Turning likert variable into factor
data_sim$likert_1_factor <- factor(data_sim$likert_1,
                                   levels = 1:5,
                                   labels = c("Strongly disagree",
                                              "Disagree",
                                              "Neutral",
                                              "Agree",
                                              "Strongly agree"))


## Plotting the variable as a bar plot

ggplot(data=data_sim, 
       aes(x = likert_1_factor)) +
  geom_bar(fill = "steelblue") +
  labs(title = "likert_1",
       x = "",
       y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45,
                                   hjust = 1,
                                   size = 6))


# Now let's automate the process for all variables using a for loop

# Empty list to store plots
plot_list <- list()

# Loop through columns
for (varname in names(data_sim)) {
  
  # Check if the variable is Likert-type
  if (is_likert(data_sim[[varname]])) {
    
    # Transform to factor with labels
    data_sim[[paste0(varname,"_factor")]] <- factor(data_sim[[varname]],
                                                    levels = 1:5,
                                                    labels = c("Strongly disagree",
                                                               "Disagree",
                                                               "Neutral",
                                                               "Agree",
                                                               "Strongly agree"))
    
    # Create plot
    p <- ggplot(data=data_sim, 
                aes(x = .data[[paste0(varname,"_factor")]])) +
      geom_bar(fill = "steelblue") +
      labs(title = varname,
           x = "",
           y = "Count") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45,
                                       hjust = 1,
                                       size = 6))
    
    # Save plot into the list
    plot_list[[varname]] <- p
  }
}

# or:

plot_list <- list()

# Loop through columns
for (v in 1:ncol(data_sim)) {
  
  # Check if the variable is Likert-type
  if (is_likert(data_sim[[v]])) {
    
    # Transform to factor with labels
    data_sim[[paste0(v,"_factor")]] <- factor(data_sim[[v]],
                                              levels = 1:5,
                                              labels = c("Strongly disagree",
                                                         "Disagree",
                                                         "Neutral",
                                                         "Agree",
                                                         "Strongly agree"))
    
    # Create plot
    p <- ggplot(data=data_sim, 
                aes(x = .data[[paste0(v,"_factor")]])) +
      geom_bar(fill = "steelblue") +
      labs(title = names(data_sim)[v],
           x = "",
           y = "Count") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45,
                                       hjust = 1,
                                       size = 6))
    
    # Save plot into the list
    plot_list[[v]] <- p
  }
}


# Combine all plots with patchwork
combined_plot <- wrap_plots(plot_list) +
  plot_annotation(title = "Distributions of Likert-scale Variables")

# Show the combined plot
print(combined_plot)
