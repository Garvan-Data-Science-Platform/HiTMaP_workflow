#!/usr/bin/env Rscript --vanilla
library(optparse)
library(HiTMaP)

check_args <- function() {
  # Get command line arguments
  option_list <- list(
    make_option(c("-i", "--input"), default = NA),
    make_option(c("-s", "--stage"), default = "full"),
    make_option(c("-c", "--config"), default = NA),
    make_option(c("-s", "--candidatelist"), default = NA),
    make_option(c("-f", "--fasta"), default = NA),
    make_option(c("-t", "--threads", default = 1))
  )

  opt <- parse_args(OptionParser(option_list = option_list))

  # Check input argument
  if (is.na(opt$input) || !is.character(opt$input) || !file.exists(opt$input)) {
    stop(paste("Error: Invalid input data file:", opt$input))
  }

  # Check stage argument
  if (is.na(opt$stage) || !is.character(opt$stage)) {
    stop(paste("Error: Invalid argument to --stage:", opt$stage))
  }
  opt$stage <- strsplit(opt$stage, ",")[[1]]
  valid_stages <- c("full", "gencandidates", "ims", "plot")
  invalid_stages <- !(opt$stage %in% valid_stages)
  if (any(invalid_stages)) {
    stop(paste("Error: Invalid stages supplied to --stage parameter:", paste(invalid_stages, collapse = ", ")))
  }
  if ("full" %in% opt$stage) {
    opt$stage <- c("gencandidates", "ims", "plot")
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

  # Check candidatelist argument
  if (!is.na(opt$candidatelist) && !is.character(opt$candidatelist)) {
    stop(paste("Error: Invalid argument to --candidatelist:", opt$candidatelist))
  }
  if (!is.na(opt$candidatelist) && !file.exists(opt$candidatelist)) {
    stop(paste("Candidate list file", opt$candidatelist, "doesn't exist."))
  }
  if (!is.na(opt$candidatelist) && "gencandidates" %in% opt$stage) {
    warning("The candidate list generation stage has been specified, so the supplied candidate list will not be used.")
    opt$candidatelist <- NA
  }

  # Check fasta argument
  if (is.na(opt$fasta) || !is.character(opt$fasta)) {
    stop(paste("Error: Invalid argument to --fasta:", opt$fasta))
  }
  if (!file.exists(opt$fasta)) {
    stop(paste("Error: FASTA file", opt$fasta, "doesn't exist."))
  }
  if (!endsWith(opt$fasta, ".fa") && !endsWith(opt$fasta, ".fasta")) {
    stop("Error: FASTA file does not have the expected '.fa', or '.fasta' extension.")
  }

  if (is.na(opt$threads) || (!is.numeric(opt$threads) && !is.character(opt$threads))) {
    stop(paste("Error: Invalid argument to --threads:", opt$threads))
  }
  opt$threads <- as.integer(opt$threads)

  return(opt)
}

opt <- check_args()

# Read in config file
source(opt$config)

config$Fastadatabase <- opt$fasta  # TODO: Get correct path
config$IMS_analysis <- "ims" %in% opt$stage
config$Load_candidatelist <- TRUE
config$use_previous_candidates <- !is.na(opt$candidatelist) && !("gencandidates" %in% opt$stage)
config$output_candidatelist <- TRUE
config$Protein_feature_summary <- TRUE
config$Peptide_feature_summary <- TRUE
config$Region_feature_summary <- TRUE
config$plot_cluster_image_grid <- "plot" %in% opt$stage
config$Thread <- opt$threads

# Run HiTMaP
do.call(imaging_identification, config)