#!/usr/bin/env Rscript --vanilla
library(optparse)
library(HiTMaP)

check_args <- function() {
  # Get command line arguments
  option_list <- list(
    make_option(c("-s", "--stage"), default = NA),
    make_option(c("-c", "--config"), default = NA),
    make_option(c("-t", "--threads", default = 1))
  )

  opt <- parse_args(OptionParser(option_list = option_list))

  # Check stage argument
  if (is.na(opt$stage) || !is.character(opt$stage)) {
    stop(paste("Error: Invalid argument to --stage:", opt$stage))
  }
  valid_stages <- c("candidates", "ims", "plot")
  if (!(opt$stage %in% valid_stages)) {
    stop(paste("Error: Invalid stage supplied to --stage parameter:", opt$stage))
  }

  # Check config argument
  if (is.na(opt$config) || !is.character(opt$config)) {
    stop(paste("Error: Invalid argument to --config:", opt$config))
  }
  if (!file.exists(opt$config)) {
    stop(paste("Error: Config file", opt$config, "doesn't exist."))
  }
  if (!endsWith(opt$config, ".R")) {
    stop("Error: Config file is not an R file.")
  }

  # Check threads argument
  if (is.na(opt$threads) || (!is.numeric(opt$threads) && !is.character(opt$threads))) {
    stop(paste("Error: Invalid argument to --threads:", opt$threads))
  }
  opt$threads <- as.integer(opt$threads)

  return(opt)
}

opt <- check_args()

# Read in config file
source(opt$config)

config$Load_candidatelist <- TRUE
config$use_previous_candidates <- TRUE
config$output_candidatelist <- TRUE
config$IMS_analysis <- opt$stage == "ims"
config$Protein_feature_summary <- config$ims_analysis
config$Peptide_feature_summary <- config$ims_analysis
config$Region_feature_summary <- config$ims_analysis
config$plot_cluster_image_grid <- opt$stage == "plot"
config$Thread <- opt$threads

# Run HiTMaP
do.call(imaging_identification, config)