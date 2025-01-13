// Get HiTMaP version
process version {
    debug = false
    tag "version"
    container "${params.hitmap_container}"
    time "5m"
    publishDir "results/${params.datetime}/version", mode: 'copy'

    input:

    output:
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