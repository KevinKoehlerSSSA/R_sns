### Code for exercises Session 7

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

# Tokenize and clean
tf_idf <- chapters %>%
  mutate(text=gsub("_","",text)) %>% # removing _ from PandP
  unnest_tokens(word, text) %>%
  filter(!grepl("[0-9]", word)) %>%
  filter(!str_detect(word, "^[[:punct:]]+$")) %>%
  anti_join(stop_words, by = "word") %>%
  mutate(word = wordStem(word)) %>%   
  count(title, word, sort = TRUE) %>%
  bind_tf_idf(term = word, document = title, n=n) %>%
  group_by(title) %>%
  slice_max(n, n = 10) %>%
  ungroup()

tf_idf <- tf_idf %>%
  arrange(title, -tf_idf)

tf_idf %>%
  ggplot(aes(x = reorder(word,tf_idf), y = tf_idf, fill = title)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ title, scales = "free") +
  scale_x_reordered() +
  coord_flip() +
  labs(
    title = "Top 10 Words in Pride and Prejudice and War of the Worlds",
    x = NULL,
    y = "TF-IDF"
  ) +
  theme_classic()

## 4. Cosine similarity

pandp <- read_csv("pride_and_prejudice.csv") 
wotw <- read_csv("war_of_the_worlds.csv") 

chapters <- rbind(pandp,wotw)

# Comparing PandP, chapter 2 to WotW, Chapter 1 

# Filter relevant chapters and adapt doc ID
chapters <- chapters %>%
  filter((title=="Pride and Prejudice" & doc=="Chapter 2") |
           (title=="War of the Worlds" & doc=="Chapter 1")) %>%
  mutate(doc=paste(title,doc,sep="_"))

# Get stop words 
data("stop_words")

# Add custom stop words
custom_stops <- tibble(
  word = c("gutenberg", "project"),
  lexicon = "custom"
)

# bind together
stop_words <- bind_rows(stop_words, custom_stops)

# Tokenize and clean
counts <- chapters %>%
  mutate(text=gsub("_","",text)) %>% # removing _ from PandP
  unnest_tokens(word, text) %>%
  filter(!grepl("[0-9]", word)) %>%
  filter(!str_detect(word, "^[[:punct:]]+$")) %>%
  anti_join(stop_words, by = "word") %>%
  mutate(word = wordStem(word)) %>%   
  count(doc, word) 

dtm <- counts %>%
  cast_dtm(document = doc, term = word, value = n)

dtm_matrix <- as.matrix(dtm)

cosine_sim <- function(a, b) {
  sum(a * b) / (sqrt(sum(a^2)) * sqrt(sum(b^2)))
}

similarity <- cosine_sim(dtm_matrix[1, ], dtm_matrix[2, ])
similarity

# WotW, Chapter 1 to WotW, Chapter 2
chapters <- rbind(pandp,wotw)

# Filter relevant chapters and adapt doc ID
chapters <- chapters %>%
  filter((title=="War of the Worlds" & doc=="Chapter 1") |
           (title=="War of the Worlds" & doc=="Chapter 2")) %>%
  mutate(doc=paste(title,doc,sep="_"))

# Get stop words 
data("stop_words")

# Add custom stop words
custom_stops <- tibble(
  word = c("gutenberg", "project"),
  lexicon = "custom"
)

# bind together
stop_words <- bind_rows(stop_words, custom_stops)

# Tokenize and clean
counts <- chapters %>%
  mutate(text=gsub("_","",text)) %>% # removing _ from PandP
  unnest_tokens(word, text) %>%
  filter(!grepl("[0-9]", word)) %>%
  filter(!str_detect(word, "^[[:punct:]]+$")) %>%
  anti_join(stop_words, by = "word") %>%
  mutate(word = wordStem(word)) %>%   
  count(doc, word) 

dtm <- counts %>%
  cast_dtm(document = doc, term = word, value = n)

dtm_matrix <- as.matrix(dtm)

cosine_sim <- function(a, b) {
  sum(a * b) / (sqrt(sum(a^2)) * sqrt(sum(b^2)))
}

similarity <- cosine_sim(dtm_matrix[1, ], dtm_matrix[2, ])
similarity

## 5. Sentiment analysis

wotw <- read_csv("war_of_the_worlds.csv") 
sentiment <- get_sentiments()

chapters_sent <- wotw %>%
  unnest_tokens(word, text) %>%
  left_join(sentiment, by="word") %>%
  group_by(doc) %>%
  summarize(sentiment=(sum(sentiment=="positive", na.rm=T)/n())-(sum(sentiment=="negative", na.rm = T)/n()))

ggplot(chapters_sent,
       aes(x=reorder(doc,sentiment), y=sentiment)) +
  geom_col() +
  theme_classic() +
  coord_flip() +
  labs(
    x="",
    y="Sentiment (proportion of positive-proportion of negative words)",
    title="Chapters of War of the Worlds by Sentiment"
  )

## 6. Topic model

wotw <- read_csv("war_of_the_worlds.csv") 

custom_stops <- tibble(
  word = c("gutenberg", "project"),
  lexicon = "custom"
)

data("stop_words")

stop_words <- bind_rows(stop_words, custom_stops)

tokens <- wotw %>%
  unnest_tokens(word, text) %>%
  filter(!grepl("[0-9]", word)) %>%
  filter(!str_detect(word, "^[[:punct:]]+$")) %>%
  anti_join(stop_words, by = "word") %>%
  count(doc, word, sort = TRUE) %>%
  ungroup

dtm <- tokens %>%
  cast_dtm(doc, word, n)

lda_model <- LDA(dtm, k = 4,
                 method = "Gibbs",
                 control = list(
                   seed = 1234),
                 alpha = 0.01,
                 delta = 0.01)

topics <- tidy(lda_model, matrix = "beta")

# View top terms per topic
top_terms <- topics %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms %>%
  mutate(term = reorder_within(term, 
                               beta, 
                               topic)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_x_reordered() +
  coord_flip() +
  labs(title = "Top 10 terms per topic", 
       x = NULL, 
       y = "beta") +
  theme_classic()
