FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
        tcl-dev \
        tk-dev \
        r-cran-ncdf4 \
        libz-dev \
        libxml2-dev \
        libssl-dev \
        libcurl4-openssl-dev \
        libnss-winbind \
        winbind \
        dirmngr \
        gnupg \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
        r-base-core="4.2.2.20221110-2" \
        libmagick++-dev \
        r-base-dev \
        texlive-full \
        libudunits2-dev \
        libgdal-dev \
    && rm -r /var/lib/apt/lists/* \
    && rm -r /var/cache/apt/*

RUN apt-get update && apt-get install -y \
        libharfbuzz-dev \
        libfribidi-dev \
    && rm -r /var/lib/apt/lists/* \
    && rm -r /var/cache/apt/*

COPY install.R /tmp/R/install.R

RUN Rscript --vanilla /tmp/R/install.R
