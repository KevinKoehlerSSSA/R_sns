### Code for exercises Session 7

library(tidyverse)
library(tidytext)
library(SnowballC)

## 1. most frequent words

# Load the books 
pandp <- read_csv("pride_and_prejudice.csv")
wotw <- read_csv("war_of_the_worlds.csv")

# Generate counts 
counts_pandp <- pandp %>%
  unnest_tokens(word, text) %>%
  count(word, sort=T) %>%
  mutate(book = "Pride and Prejudice")

counts_wotw <- wotw %>%
  unnest_tokens(word, text) %>%
  count(word, sort=T) %>%
  mutate(book = "War of the Worlds")

# Combine the counts
counts_combined <- bind_rows(counts_pandp, counts_wotw)

# Get top 10 words per book
top_counts <- counts_combined %>%
  group_by(book) %>%
  slice_max(n, n = 10) %>%
  ungroup()

# Reorder words within book for better facet display
top_counts <- top_counts %>%
  mutate(word = reorder_within(word, n, book))

# Plot
top_counts %>%
  ggplot(aes(x = word, y = n, fill = book)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ book, scales = "free") +
  scale_x_reordered() +
  coord_flip() +
  labs(
    title = "Top 10 Words in Pride and Prejudice and War of the Worlds",
    x = NULL,
    y = "Frequency"
  ) +
  theme_classic()

## 2. most frequent words, without stop words

# Load the books 
pandp <- read_csv("pride_and_prejudice.csv")
wotw <- read_csv("war_of_the_worlds.csv")

# Get stop words (included in tidytext)

data("stop_words")

# adding custom stop words (leave out this step and see why)
custom_stops <- tibble(
  word = c("gutenberg", "project"),
  lexicon = "custom"
)

stop_words <- bind_rows(stop_words, custom_stops)

# Generate counts, adding stop word removal with anti_join 
counts_pandp <- pandp %>%
  mutate(text=gsub("_","",text)) %>% # remove _ which are used for emphasis in PandP
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word") %>% # remove stop words
  filter(!grepl("[0-9]", word)) %>% # remove all numbers
  filter(!str_detect(word, "^[[:punct:]]+$")) %>% # remove all punctuation
  count(word, sort=T) %>%
  mutate(book = "Pride and Prejudice")

counts_wotw <- wotw %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word") %>% # remove stop words
  filter(!grepl("[0-9]", word)) %>% # remove all numbers
  filter(!str_detect(word, "^[[:punct:]]+$")) %>% # remove all punctuation
  count(word, sort=T) %>%
  mutate(book = "War of the Worlds")

# Combine the counts
counts_combined <- bind_rows(counts_pandp, counts_wotw)

# Get top 10 words per book
top_counts <- counts_combined %>%
  group_by(book) %>%
  slice_max(n, n = 10) %>%
  ungroup()

# Reorder words within book for better facet display
top_counts <- top_counts %>%
  mutate(word = reorder_within(word, n, book))

# Plot
top_counts %>%
  ggplot(aes(x = word, y = n, fill = book)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ book, scales = "free") +
  scale_x_reordered() +
  coord_flip() +
  labs(
    title = "Top 10 Words in Pride and Prejudice and War of the Worlds",
    x = NULL,
    y = "Frequency"
  ) +
  theme_classic()

## 3. Word significance in terms of TF-IDF

pandp <- read_csv("pride_and_prejudice.csv") 
wotw <- read_csv("war_of_the_worlds.csv") 

chapters <- rbind(pandp,wotw) 

# Get stop words 
data("stop_words")

# Add custom stop words
custom_stops <- tibble(
  word = c("gutenberg", "project"),
  lexicon = "custom"
)

# bind together
stop_words <- bind_rows(stop_words, custom_stops)
