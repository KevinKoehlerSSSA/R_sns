# Load required packages
library(plotly)

# Sample document-term matrix
docs <- data.frame(
  document = c("Doc A", "Doc B", "Doc C"),
  data = c(3, 1, 2),
  science = c(3, 3, 2),
  analysis = c(3, 2, 3)
)

# Function to compute cosine similarity
cosine_similarity <- function(a, b) {
  sum(a * b) / (sqrt(sum(a^2)) * sqrt(sum(b^2)))
}

# Choose two documents to compare
vecA <- as.numeric(docs[1, 2:4])  # Doc A
vecB <- as.numeric(docs[2, 2:4])  # Doc B

# Compute similarity
sim <- cosine_similarity(vecA, vecB)
sim_label <- paste0("Cosine similarity (A vs B): ", round(sim, 3))

# Plot: start with empty base
fig <- plot_ly(type = 'scatter3d', mode = 'markers+text')

# Add points for documents
fig <- fig %>% add_trace(
  x = docs$data,
  y = docs$science,
  z = docs$analysis,
  text = docs$document,
  mode = "markers+text",
  marker = list(size = 5),
  textposition = 'top center',
  showlegend = FALSE
)

# Add vectors from origin
for (i in 1:nrow(docs)) {
  fig <- fig %>% add_trace(
    x = c(0, docs$data[i]),
    y = c(0, docs$science[i]),
    z = c(0, docs$analysis[i]),
    type = 'scatter3d',
    mode = 'lines',
    line = list(width = 4),
    showlegend = FALSE
  )
}

# Add a line connecting Doc A and Doc B
fig <- fig %>% add_trace(
  x = c(docs$data[1], docs$data[2]),
  y = c(docs$science[1], docs$science[2]),
  z = c(docs$analysis[1], docs$analysis[2]),
  type = 'scatter3d',
  mode = 'lines',
  line = list(color = 'red', dash = 'dash'),
  showlegend = FALSE
)

# Annotate similarity value
fig <- fig %>% add_annotations(
  text = sim_label,
  x = 1.5, y = 3, z = 3,
  ax = 0, ay = 0,
  showarrow = FALSE
)

# Axis labels and layout
fig <- fig %>% layout(
  scene = list(
    xaxis = list(title = 'Term: data'),
    yaxis = list(title = 'Term: science'),
    zaxis = list(title = 'Term: analysis')
  ),
  title = "Document Vectors with Cosine Similarity"
)

# Show plot
fig
