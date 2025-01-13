// Get HiTMaP run information
process run_info {
    debug = false
    tag "run_info"
    container "${params.hitmap_container}"
    time "5m"
    publishDir "results/${params.datetime}/run_info", mode: 'copy'

    input:
    path(config, stageAs: "config.R")

    output:
    path("config.R"), emit: config
    path("version.txt"), emit: version

    script:
    """
    grep -P "^RemoteRef:" /usr/local/lib/R/site-library/HiTMaP/DESCRIPTION | cut -d " " -f 2 > version.txt
    """

    stub:
    """
    grep -P "^RemoteRef:" /usr/local/lib/R/site-library/HiTMaP/DESCRIPTION | cut -d " " -f 2 > version.txt
    """
 }