// Run candidates generation
process candidates {
    debug = false
    tag "candidates"
    container "${params.hitmap_container}"

    input:
    path(datafile, stageAs: 'workdir/*')
    path(ibdfile, stageAs: 'workdir/*')
    path(fasta, stageAs: 'workdir/*')
    path(rankfile, stageAs: 'workdir/rank.csv')
    path(rotationfile, stageAs: 'workdir/rotation.csv')
    path(config)
    val(threads)

    output:
    path("candidates.tar"), emit: candidates

    script:
    """
    RANKFILE="--rankfile ${rankfile}"
    if [ -z "\$(head -c 1 ${rankfile})" ]; then RANKFILE=""; fi
    ROTATIONFILE="--rotationfile ${rotationfile}"
    if [ -z "\$(head -c 1 ${rotationfile})" ]; then ROTATIONFILE=""; fi

    run.R \
        --stage candidates \
        --config ${config} \
        --datafile ${datafile} \
        --fasta ${fasta} \
        \$RANKFILE \
        \$ROTATIONFILE \
        --threads ${threads}
    tar -cf candidates.tar -C workdir/ "Summary folder/"
    """

    stub:
    """
    echo ./run.R \
        --stage candidates \
        --config ${config} \
        --datafile ${datafile} \
        --fasta ${fasta} \
        --rankfile ${rankfile} \
        --rotationfile ${rotationfile} \
        --threads ${threads}
    mkdir -p "workdir/Summary folder/"
    touch "workdir/Summary folder/candidatelist.csv"
    tar -cf candidates.tar -C workdir/ "Summary folder/"
    """
 }