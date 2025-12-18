library(dplyr)
library(readr)
library(ggplot2)
library(reshape2)
library(pheatmap)

# map labels 
load_label_mapping <- function(mapping_file) {
  if (is.null(mapping_file) || !file.exists(mapping_file)) return(NULL)
  mapping <- read_csv(mapping_file, show_col_types = FALSE)
  idx_col <- names(mapping)[sapply(mapping, is.numeric)][1]
  name_col <- names(mapping)[sapply(mapping, is.character)][1]
  mapping <- mapping %>% select(index = !!idx_col, region = !!name_col)
  mapping
}


read_fc_matrix <- function(file) {
  df <- read_csv(file, col_names = FALSE, show_col_types = FALSE)
  
  # Drop the header row and index column 
  df <- df[-1, -1]
  
  # make all numeric and empty cells na 
  mat <- as.matrix(sapply(df, function(col) as.numeric(as.character(col))))
  return(mat)
}

# summary metrics FC matrix
summarise_fc_matrix <- function(mat, thresholds = c(0.1, 0.2)) {
  off_diag <- mat[lower.tri(mat)]
  finite_vals <- off_diag[is.finite(off_diag)]
  metrics <- tibble(
    n_regions        = nrow(mat),
    mean_cor         = mean(finite_vals, na.rm = TRUE),
    median_cor       = median(finite_vals, na.rm = TRUE),
    mean_abs_cor     = mean(abs(finite_vals), na.rm = TRUE),
    sd_cor           = sd(finite_vals, na.rm = TRUE),
    max_cor          = max(finite_vals, na.rm = TRUE),
    min_cor          = min(finite_vals, na.rm = TRUE)
  )
  for (th in thresholds) {
    n_edge  <- sum(abs(finite_vals) > th, na.rm = TRUE)
    pct_edge <- 100 * n_edge / length(finite_vals)
    metrics[[paste0("n_edges_gt_", th)]]  <- n_edge
    metrics[[paste0("pct_edges_gt_", th)]] <- pct_edge
  }
  metrics
}

# main qc
qc_fc_matrices <- function(matrix_dir,
                           mapping_file = NULL,
                           cor_thresholds = c(0.1, 0.2),
                           out_dir = NULL,
                           plot_limits = c(-0.3, 0.3)) {
  matrix_files <- list.files(matrix_dir,
                             pattern = "_FC_matrix\\.csv$",
                             full.names = TRUE, recursive = TRUE)
  if (length(matrix_files) == 0) {
    stop("No *_FC_matrix.csv files found in ", matrix_dir)
  }
  
  mapping <- load_label_mapping(mapping_file)
  qc_list <- list()
  
  for (f in matrix_files) {
    sub_id <- regmatches(f, regexpr("sub-[A-Za-z0-9]+", f))
    if (length(sub_id) == 0) sub_id <- sub("_.*", "", basename(f))
    
    mat <- read_fc_matrix(f)
    
    # region assignment
    if (!is.null(mapping) && nrow(mapping) >= nrow(mat)) {
      region_names <- mapping$region[1:nrow(mat)]
      rownames(mat) <- region_names
      colnames(mat) <- region_names
    }
    
    # compute cor metrics
    metrics <- summarise_fc_matrix(mat, thresholds = cor_thresholds)
    metrics$rat_id <- sub_id
    
    #  plots
    if (!is.null(out_dir)) {
      dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
      
      # replace non‑finite values with zero for heatmap
      mat_plot <- mat
      mat_plot[!is.finite(mat_plot)] <- 0
      
      heatmap_file <- file.path(out_dir, paste0(sub_id, "_FC_heatmap.png"))
      png(heatmap_file, width = 6, height = 6, units = "in", res = 300)
      pheatmap(mat_plot,
               cluster_rows = FALSE, cluster_cols = FALSE,
               color = colorRampPalette(c("blue", "white", "red"))(100),
               breaks = seq(plot_limits[1], plot_limits[2], length.out = 101),
               main   = paste0("FC matrix: ", sub_id),
               border_color = NA,
               legend_breaks = c(plot_limits[1], 0, plot_limits[2]))
      dev.off()
      
      # histogram
      off_diag <- mat[lower.tri(mat)]
      finite_vals <- off_diag[is.finite(off_diag)]
      hist_df <- data.frame(corr = finite_vals)
      p_hist <- ggplot(hist_df, aes(x = corr)) +
        geom_histogram(bins = 50, fill = "grey70", colour = "black") +
        geom_vline(xintercept = 0, linetype = "dashed", colour = "red") +
        labs(title = paste0("Distribution of correlations: ", sub_id),
             x = "Pearson r", y = "Count") +
        theme_bw()
      hist_file <- file.path(out_dir, paste0(sub_id, "_FC_hist.png"))
      ggsave(hist_file, p_hist, width = 6, height = 4)
    }
    
    qc_list[[sub_id]] <- metrics
  }
  
  qc_df <- bind_rows(qc_list)
  qc_df <- qc_df %>% select(rat_id, everything())
  
  if (!is.null(out_dir)) {
    write_csv(qc_df, file.path(out_dir, "FC_matrix_QC_summary.csv"))
  }
  
  qc_df
}


qc_results <- qc_fc_matrices(
  matrix_dir   = "path/to/directory/for/matrix_data_file",
  mapping_file = "/path/to/DSURQE_40micron_R_mapping.csv",
  cor_thresholds = c(0.1, 0.2),
  out_dir     = "where/to/output/QC_FunctionalMatrix"
)

print(qc_results, n= nrow(qc_results))
