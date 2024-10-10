install.packages(c(
  "remotes",
  "config",
  "textshaping",
  "ragg",
  "pkgdown",
  "devtools",
  "ncdf4",
  "pryr",
  "pacman",
  "pls",
  "magick",
  "reticulate",
  "dplyr",
  "data.table",
  "doParallel",
  "iterators",
  "foreach",
  "protViz",
  "egg",
  "spdep",
  "zoo",
  "OrgMassSpecR",
  "enviPat",
  "rgl",
  "XML",
  "reshape2",
  "readr",
  "readxl",
  "rcdk",
  "OneR",
  "future",
  "BiocManager",
  "optparse"
), repos = "https://cran.csiro.au/")
BiocManager::install(c(
  "EBImage",
  "ChemmineR",
  "XVector",
  "Biostrings",
  "KEGGREST",
  "cleaver",
  "multtest",
  "Cardinal"
))
remotes::install_github("sneumann/Rdisop@3e66e6d")
remotes::install_github(
  "MASHUOA/HiTMaP@df20be1",
  force = TRUE,
  upgrade = "always",
  verbose = TRUE,
  build = FALSE
)