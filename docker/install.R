install.packages(c(
  "remotes",
  "config",
  "textshaping",
  "ragg",
  "pkgdown",
  "devtools"
))
BiocManager::install(c(
  "EBImage",
  "ChemmineR",
  "XVector",
  "Biostrings",
  "KEGGREST",
  "cleaver"
))
remotes::install_github("sneumann/Rdisop")
remotes::install_github("kuwisdelu/Cardinal")
# Sys.setenv("R_REMOTES_NO_ERRORS_FROM_WARNINGS" = "true")
remotes::install_github(
  "MASHUOA/HiTMaP",
  force = TRUE,
  upgrade = "always",
  verbose = TRUE,
  build = FALSE
)
BiocManager::install(ask = FALSE)