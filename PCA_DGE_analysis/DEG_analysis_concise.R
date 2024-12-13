# Install required packages
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
BiocManager::install("devtools")
BiocManager::install("pachterlab/sleuth")
BiocManager::install("biomaRt")
BiocManager::install("data.table")
install.packages("ggplot2")
install.packages("FactoMineR")
install.packages("factoextra")
install.packages("lm.beta")
install.packages("tibble")

# Set working directory
setwd("~/Desktop/all_results")

# Load sample metadata
sample_info <- read.csv("sample_metadata_full_paths.csv")

# Specify directory containing Kallisto output folders
output_dir <- "/Users/umitakirmak/Desktop/all_results"

# List folders and extract sample IDs
folders <- list.files(output_dir, full.names = TRUE)
folder_df <- data.frame(
  sample_id = as.numeric(gsub(".*V([0-9]+).*", "\\1", basename(folders))),
  path = folders,
  stringsAsFactors = FALSE
)

# Merge sample_info with folder_df to assign paths
colnames(sample_info)[colnames(sample_info) == "sample"] <- "sample_id"
sample_info <- merge(sample_info, folder_df[10:nrow(folder_df),], by = "sample_id")

# Remove unnecessary column and rename another
sample_info <- sample_info %>%
  select(-path.x) %>%
  rename(path = path.y)

# Load target mapping data (assuming file exists)
target_mapping <- read.csv("target_mapping.csv", stringsAsFactors = FALSE)

# Clean target_mapping (add "transcript:" prefix if necessary)
target_mapping$target_id <- paste0("transcript:", target_mapping$target_id)

# Load TPM matrix (assuming file exists)
tpm_matrix <- read.csv("tpm_matrix_Nov19.csv", row.names = TRUE)
rownames(tpm_matrix) <- sub("^(gene:|transcript:)", "", rownames(tpm_matrix))

# ===========================================================================
# Sleuth Analysis
# ===========================================================================

# Prepare Sleuth analysis
so <- sleuth_prep(sample_info, ~ condition, target_mapping = target_mapping)
so <- sleuth_fit(so, ~ condition, 'full')
so <- sleuth_fit(so, ~ 1, 'reduced')
so <- sleuth_lrt(so, 'reduced', 'full')
dge_results <- sleuth_results(so, 'reduced:full', 'lrt', show_all = TRUE)

# Filter significant genes and extract TPM matrix for those genes
significant_genes <- dge_results %>% filter(pval < 0.05)
significant_gene_ids <- significant_genes$target_id
matching_ids <- significant_gene_ids[significant_gene_ids %in% rownames(tpm_matrix)]
tpm_subset <- tpm_matrix[matching_ids, ]

# PCA on the subset TPM matrix
pca_result <- PCA(t(tpm_subset), scale = TRUE, graph = FALSE)

# Select top 1000 transcripts based on variance (or other criteria)
top_transcripts <- names(sort(transcript_variances, decreasing = TRUE)[1:1000])
tpm_subset <- tpm_matrix[top_transcripts, ]
write.csv(tpm_subset, "top_1000_transcripts_raw.csv", row.names = FALSE)

# Perform PCA on the subset TPM matrix
pca_result <- PCA(t(tpm_subset), scale = TRUE, graph = FALSE)

# Select top 99 transcripts based on PCA contributions
contrib_matrix <- pca_result$var$contrib
top_dim1 <- rownames(contrib_matrix)[order(contrib_matrix[, 1], decreasing = TRUE)][1:80]
top_dim2 <- rownames(contrib_matrix)[order(contrib_matrix[, 2], decreasing = TRUE)][1:19]
selected_transcripts <- unique(c(top_dim1, top_dim2))

# Subset TPM matrix for selected transcripts
tpm_selected <- tpm_matrix[selected_transcripts, ]

# Adjust TPM values using linear regression on the first two principal components
lm_model <- lm(t(tpm_selected) ~ pca_selected$ind$coord[, 1:2])
adjusted_tpm_selected <- lm_model$residuals + matrixStats::rowMeans2(as.matrix(tpm_selected))
write.csv(adjusted_tpm_selected, "top_99_transcripts_sleuth.csv", row.names = FALSE)

# Perform PCA on the adjusted TPM matrix
pca_adjusted <- PCA(t(adjusted_tpm_selected), scale.unit = TRUE, graph = FALSE)

# Visualize the PCA results
fviz_pca_var(
  pca_adjusted,
  col.var = "cos2",
  gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
  repel = TRUE,
  title = "PCA - Top 99 Transcripts (Dim1 & Dim2) from Sleuth Analysis (Adjusted)"
)

# ===========================================================================
# Raw Transcript Analysis
# ===========================================================================

# Calculate variance for each transcript
transcript_variances <- apply(tpm_matrix, 1, var)
# Select the top 1197 transcripts based on variance
top_transcripts <- names(sort(transcript_variances, decreasing = TRUE)[1:1197])

# Subset the TPM matrix for these top transcripts
tpm_filtered <- tpm_matrix[top_transcripts, ]
write.csv(tpm_filtered, "top_1197_transcripts_raw.csv", row.names = FALSE)

# Perform PCA on the subset TPM matrix
pca_filtered <- PCA(t(tpm_filtered), scale.unit = TRUE, graph = FALSE)

# Select top transcripts based on PCA contributions
dim1_contributions <- pca_filtered$var$contrib[, 1]
dim2_contributions <- pca_filtered$var$contrib[, 2]
top_dim1 <- names(sort(dim1_contributions, decreasing = TRUE)[1:80])
top_dim2 <- names(sort(dim2_contributions, decreasing = TRUE)[1:19])
selected_transcripts <- unique(c(top_dim1, top_dim2))

# Subset adjusted TPM matrix for these transcripts
adjusted_tpm_selected <- tpm_filtered[selected_transcripts, ]

# Re-run PCA
pca_selected <- PCA(t(adjusted_tpm_selected), scale.unit = TRUE, graph = FALSE)
