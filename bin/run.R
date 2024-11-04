#!/usr/bin/env -S Rscript --vanilla
library(optparse)
library(HiTMaP)

check_args <- function() {
  # Get command line arguments
  option_list <- list(
    make_option(c("-s", "--stage"), default = NA_character_),
    make_option(c("-c", "--config"), default = NA_character_),
    make_option(c("-d", "--datafile"), default = NA_character_),
    make_option(c("-f", "--fasta"), default = NA_character_),
    make_option(c("-n", "--rankfile"), default = NA_character_),
    make_option(c("-r", "--rotationfile"), default = NA_character_),
    make_option(c("-t", "--threads", default = 1))
  )

  opt <- parse_args(OptionParser(option_list = option_list))

  # Check stage argument - required
  if (is.na(opt$stage) || !is.character(opt$stage)) {
    stop(paste("Error: Invalid argument to --stage:", opt$stage))
  }
  valid_stages <- c("candidates", "ims", "plot")
  if (!(opt$stage %in% valid_stages)) {
    stop(paste("Error: Invalid stage supplied to --stage parameter:", opt$stage))
  }

  # Check config argument - required
  if (is.na(opt$config) || !is.character(opt$config)) {
    stop(paste("Error: Invalid argument to --config:", opt$config))
  }
  if (!file.exists(opt$config)) {
    stop(paste("Error: Config file", opt$config, "doesn't exist."))
  }
  if (!endsWith(opt$config, ".R")) {
    stop("Error: Config file is not an R file.")
  }

  # Check datafile argument - required
  if (is.na(opt$datafile) || !is.character(opt$datafile)) {
    stop(paste("Error: Invalid argument to --datafile:", opt$datafile))
  }
  # Convert to absolute path
  opt$datafile <- path.expand(opt$datafile)
  if (!startsWith(opt$datafile, "/")) {
    opt$datafile <- file.path(getwd(), opt$datafile)
  }
  if (!file.exists(opt$datafile)) {
    stop(paste("Error: Data file", opt$datafile, "doesn't exist."))
  }
  if (!endsWith(opt$datafile, ".imzML")) {
    stop("Error: Data file is not a .imzML file.")
  }
  ibdfile <- gsub("\\.imzML$", ".ibd", opt$datafile, perl = TRUE)
  if (!file.exists(ibdfile)) {
    stop(paste("Error: IBD file", ibdfile, "doesn't exist."))
  }

  # Check fasta argument - required
  if (is.na(opt$fasta) || !is.character(opt$fasta)) {
    stop(paste("Error: Invalid argument to --fasta:", opt$fasta))
  }
  if (!file.exists(opt$fasta)) {
    stop(paste("Error: FASTA file", opt$fasta, "doesn't exist."))
  }
  if (!endsWith(opt$fasta, ".fasta") && !endsWith(opt$fasta, ".fa")) {
    stop("Error: FASTA file is not a .fasta or .fa file.")
  }

  # Check rankfile argument - optional
  if (!is.na(opt$rankfile) && !is.character(opt$rankfile)) {
    stop(paste("Error: Invalid argument to --rankfile:", opt$rankfile))
  }
  if (!is.na(opt$rankfile) && !file.exists(opt$rankfile)) {
    stop(paste("Error: Rank file", opt$rankfile, "doesn't exist."))
  }
  if (!is.na(opt$rankfile) && !endsWith(opt$rankfile, "csv")) {
    stop("Error: Rank file is not a csv file.")
  }

  # Check rotationfile argument - optional
  if (!is.na(opt$rotationfile) && !is.character(opt$rotationfile)) {
    stop(paste("Error: Invalid argument to --rotationfile:", opt$rotationfile))
  }
  if (!is.na(opt$rotationfile) && !file.exists(opt$rotationfile)) {
    stop(paste("Error: Rotation file", opt$rotationfile, "doesn't exist."))
  }
  if (!is.na(opt$rotationfile) && !endsWith(opt$rotationfile, "csv")) {
    stop("Error: Rotation file is not a csv file.")
  }

  # Check threads argument - default is 1
  if (is.na(opt$threads) || (!is.numeric(opt$threads) && !is.character(opt$threads))) {
    stop(paste("Error: Invalid argument to --threads:", opt$threads))
  }
  opt$threads <- as.integer(opt$threads)

  return(opt)
}

opt <- check_args()

# Read in config file
source(opt$config)

config$datafile <- opt$datafile
config$Fastadatabase <- basename(opt$fasta)
config$Load_candidatelist <- TRUE
config$use_previous_candidates <- TRUE
config$output_candidatelist <- TRUE
config$IMS_analysis <- (opt$stage == "ims")
config$Protein_feature_summary <- config$IMS_analysis
config$Peptide_feature_summary <- config$IMS_analysis
config$Region_feature_summary <- config$IMS_analysis
config$plot_cluster_image_grid <- (opt$stage == "plot")
config$Thread <- opt$threads
if (is.na(opt$rankfile)) {
  config$Virtual_segmentation_rankfile <- NULL
} else {
  config$Virtual_segmentation_rankfile <- basename(opt$rankfile)
  config$Segmentation <- "Virtual_segmentation"
}
if (is.na(opt$rotationfile)) {
  config$Rotate_IMG <- NULL
} else {
  config$Rotate_IMG <- basename(opt$rotationfile)
}

# Run HiTMaP
do.call(imaging_identification, config)