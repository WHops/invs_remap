library(ggplot2)
library(dplyr)
data2 <- read.table("/Users/tsapalou/Downloads/output_cov_mismatch_50250.tsv", header=T)

plot_and_write_bedfile <- function(input_dataframe, output_filename) {
  
  # Subset data based on the matchrate condition
  subset_data <- subset(input_dataframe, matchrate < 0.75)
  
  # Create the BED dataframe with three columns: chr, window_start, and end (window_start + 50)
  bed_data <- data.frame(
    chrom = subset_data$chr,
    start = subset_data$window_start,
    end = subset_data$window_start + 50
  )
  
  # Write the BED dataframe to a file without row names and header
  write.table(bed_data, file = output_filename, sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)
  
  # First Plot using plot_dataframe_big
  plot1 <- ggplot(input_dataframe, aes(x = window_start)) +
    geom_line(aes(y = reads_all, color = "reads_all"), linewidth = 0.4) +
    geom_line(aes(y = matches, color = "matches"), linewidth = 0.4) +
    scale_y_continuous(breaks = seq(0, 1500, by = 100)) +
    geom_line(aes(y = matchrate * 1000, color = "matchrate"), linewidth = 0.2) +
    labs(y = "Value", x = "Chromosome region (window start)", color = "Metric") +
    theme_minimal()
  
  # Display the first plot
  print(plot1)
  
# Second Plot using plot_dataframe_2
  
  plot2 <- ggplot(input_dataframe, aes(x = window_start, y = matchrate, color = matchrate)) +
    geom_point(size = 0.6, color = "purple") +
    scale_y_continuous(breaks = seq(0, 1, by = 0.1)) +
    theme_minimal()
  
  # Display the second plot
  print(plot2)
}

# Call the function
plot_and_write_bedfile(data2, "/Users/tsapalou/Downloads/output.bed")
