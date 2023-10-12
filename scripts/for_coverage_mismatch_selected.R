library(dplyr)
library(argparse)
library(ggplot2) 

plot_and_write_bedfile <- function(input_dataframe, output_filename) {
  
  # Filter based on conditions
  filtered_data <- input_dataframe %>%
    filter(matchrate < 0.7, 
           (mismatches / reads_all) >= 0.10) 
  
  # Suppress scientific notation
  options(scipen=999)
  
  
  # Create the BED dataframe with three columns: chr, window_start, and end (window_start + 50)
  bed_data <- data.frame(
    chrom = filtered_data$chr,
    start = filtered_data$window_start,
    end = filtered_data$window_start + 50
  )
  
  # Write the BED dataframe to a file 
  write.table(bed_data, file = output_filename, sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)
  

# using plot_dataframe_2
  
  plot2 <- ggplot(input_dataframe, aes(x = window_start, y = matchrate, color = matchrate)) +
    geom_point(size = 0.6, color = "purple") +
    scale_y_continuous(breaks = seq(0, 1, by = 0.1)) +
    theme_minimal()
  

 # Save the plots
  ggsave(filename = "plot2.png", plot = plot2, width = 10, height = 6, units = "in")
  
}

# get the arguments from the command line
parser <- ArgumentParser()
parser$add_argument("input")
parser$add_argument("output")
args <- parser$parse_args()

# Assuming it's a TSV based on your filename. If it's a CSV or another format, adjust accordingly.
input_dataframe <- read.table(args$input, header = TRUE, stringsAsFactors = FALSE, sep = "\t")

# Call the main function using the read dataframe and provided output path
plot_and_write_bedfile(input_dataframe, args$output)