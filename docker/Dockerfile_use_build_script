FROM r-base:4.4.1 AS build

RUN apt-get update && apt-get install -y \
        libz-dev \
        libxml2-dev \
        libssl-dev \
        libcurl4-openssl-dev \
        libudunits2-dev \
        libgdal-dev \
        libharfbuzz-dev \
        libfribidi-dev \
        libfftw3-dev \
        libmagick++-dev \
        libnss-winbind \
        dirmngr \
        gnupg \
        tcl-dev \
        tk-dev \
        winbind \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
        texlive \
        default-jdk-headless \
    && rm -r /var/lib/apt/lists/* \
    && rm -r /var/cache/apt/*

COPY install.R /tmp/R/install.R

RUN Rscript --vanilla /tmp/R/install.R \
    && rm -r /tmp/R/install.R

FROM r-base:4.4.1

COPY --from=build /usr/local/lib/R/site-library /usr/local/lib/R/site-library
COPY --from=build /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu

RUN apt-get update && apt-get install -y \
        default-jdk-headless \
        texlive \
        libnss-winbind \
        dirmngr \
        gnupg \
        winbind \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
        procps \
    && rm -r /var/lib/apt/lists/* \
    && rm -r /var/cache/apt/*

CMD [ "bash" ]