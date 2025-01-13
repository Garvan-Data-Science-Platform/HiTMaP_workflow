// Run ploting
process plot {
    debug = false
    tag "plot"
    container "${params.hitmap_container}"
    time params.time.plot
    publishDir "results/${params.datetime}/plot", mode: 'copy'

    input:
    path(candidate_list_and_ims_outs, stageAs: 'inputs/*')
    path(datafile, stageAs: 'workdir/*')
    path(ibdfile, stageAs: 'workdir/*')
    path(fasta, stageAs: 'workdir/*')
    path(rankfile, stageAs: 'workdir/rank.csv')
    path(rotationfile, stageAs: 'workdir/rotation.csv')
    path(config)

    output:
    path("plot.tar"), emit: plot

    script:
    sample = datafile.baseName.replaceAll(/\.imzML$/, '')
    """
    RANKFILE="--rankfile ${rankfile}"
    if [ -z "\$(head -c 1 ${rankfile})" ]; then RANKFILE=""; echo "No rank file provided"; else echo "Rank file provided: ${rankfile}"; fi
    ROTATIONFILE="--rotationfile ${rotationfile}"
    if [ -z "\$(head -c 1 ${rotationfile})" ]; then ROTATIONFILE=""; echo "No rotation file provided"; else echo "Rotation file provided: ${rotationfile}"; fi

    mkdir -p workdir
    tar -xf ${candidate_list_and_ims_outs} -C workdir/
    run.R \
        --stage plot \
        --config ${config} \
        --datafile ${datafile} \
        --fasta ${fasta} \
        \$RANKFILE \
        \$ROTATIONFILE \
        --threads ${task.cpus}
    tar -cf plot.tar -C workdir/ "Summary folder/" "${sample} ID/"
    """

    stub:
    sample = datafile.baseName.replaceAll(/\.imzML$/, '')
    """
    echo mkdir -p workdir
    echo tar -xf ${candidate_list_and_ims_outs} -C workdir/
    echo ./run.R \
        --stage plot \
        --config ${config} \
        --datafile ${datafile} \
        --fasta ${fasta} \
        --rankfile ${rankfile} \
        --rotationfile ${rotationfile} \
        --threads ${task.cpus}
    mkdir -p "workdir/Summary folder/"
    mkdir -p "workdir/${sample} ID/"
    touch "workdir/Summary folder/plot_outputs"
    touch "workdir/${sample} ID/plot_outputs"
    tar -cf plot.tar -C workdir/ "Summary folder/" "${sample} ID/"
    """
 }