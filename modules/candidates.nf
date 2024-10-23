// Run candidates generation
process candidates {
    debug = true
    tag "candidates"
    // container "${params.container_dir}/hitmap.sif"
    container "hitmap:latest"

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
    ./run.R \
        --stage candidates \
        --config ${config} \
        --datafile ${datafile} \
        --fasta ${fasta} \
        --rankfile ${rankfile} \
        --rotationfile ${rotationfile} \
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