library(dplyr)
library(readr)
library(ggplot2)

summarise_fd <- function(fd_dir, threshold = 0.05) {
  fd_files <- list.files(fd_dir, pattern = "autobox_FD_file\\.csv$",
                         full.names = TRUE, recursive = TRUE)
  if (length(fd_files) == 0) stop("No autobox_FD_file.csv files found.")
  
  results <- lapply(fd_files, function(f) {
    dat <- read_csv(f, col_types = cols())
    fd_col <- names(dat)[grepl("mean", names(dat), ignore.case = TRUE)]
    if (length(fd_col) == 0) fd_col <- names(dat)[sapply(dat, is.numeric)][1]
    fd_values <- dat[[fd_col]]
    
    sub_match <- regmatches(f, regexpr("sub-[A-Za-z0-9]+", f))
    if (length(sub_match) == 0) sub_match <- regmatches(f, regexpr("subject_id[^/_]+", f))
    if (length(sub_match) == 0) sub_match <- basename(dirname(dirname(f)))
    
    tibble(
      rat_id = sub_match,
      n_frames = length(fd_values),
      mean_FD = mean(fd_values, na.rm = TRUE),
      median_FD = median(fd_values, na.rm = TRUE),
      max_FD = max(fd_values, na.rm = TRUE),
      sd_FD = sd(fd_values, na.rm = TRUE),
      n_frames_above_thresh = sum(fd_values > threshold, na.rm = TRUE),
      pct_frames_above_thresh = 100 * n_frames_above_thresh / n_frames
    )
  })
  
  summary_df <- bind_rows(results)
  
  # mean FD 
  p_mean <- ggplot(summary_df, aes(x = rat_id, y = mean_FD)) +
    geom_bar(stat = "identity", fill = "steelblue") +
    geom_hline(yintercept = threshold, linetype = "dashed", color = "red") +
    labs(x = "Rat ID", y = "Mean FD (mm)",
         title = sprintf("Mean FD per rat (threshold = %.2f mm)", threshold)) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  # frames above threshold 
  p_above <- ggplot(summary_df, aes(x = rat_id, y = n_frames_above_thresh)) +
    geom_bar(stat = "identity", fill = "dodgerblue", color = 'black') +
    geom_text(aes(label = sprintf("%.1f%%\n%d", 
                                  pct_frames_above_thresh, n_frames)),
              vjust = -0.5, size = 3.2) +
    labs(x = "Rat ID",
         y = sprintf("Frames > %.2f mm", threshold),
         title = "Number of frames above FD threshold (0.05 mm)") +
    expand_limits(y = max(summary_df$n_frames_above_thresh) * 1.2) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  list(summary = summary_df, plot_mean = p_mean, plot_above = p_above)
}

fd_result <- summarise_fd("/FD_csv", ## FINISH PATH HERE TO FD_CSV file
                          threshold = 0.05)

# summary table
print(fd_result$summary, n = 27)

# plots
print(fd_result$plot_mean)
print(fd_result$plot_above)
