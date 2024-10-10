#!/usr/bin/env Rscript --vanilla
library(optparse)

check_args <- function() {
  # Get command line arguments
  option_list <- list(
    make_option(c("-s", "--stage"), default = "full"),
    make_option(c("-c", "--config"), default = NA),
    make_option(c("-s", "--candidatelist"), default = NA)
  )

  opt <- parse_args(OptionParser(option_list = option_list))

  # Check arguments
  opt$stage <- strsplit(opt$stage, ",")[[1]]
  valid_stages <- c("full", "gencandidates", "ims", "plot")
  invalid_stages <- !(opt$stage %in% valid_stages)
  if (any(invalid_stages)) {
    stop(paste("Error: Invalid stages supplied to --stage parameter:", paste(invalid_stages, collapse = ", ")))
  }
}