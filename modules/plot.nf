// Run ploting
process plot {
    debug = true
    tag "plot"
    // container "${params.container_dir}/hitmap.sif"

    input:
    path(candidate_list_and_ims_outs, stageAs: 'inputs/*')
    path(datafile, stageAs: 'workdir/*')
    path(ibdfile, stageAs: 'workdir/*')
    path(fasta, stageAs: 'workdir/*')
    path(rankfile, stageAs: 'workdir/rank.csv')
    path(rotationfile, stageAs: 'workdir/rotation.csv')
    path(config)
    val(threads)

    output:
    path("plot.tar"), emit: plot

    script:
    sample = datafile.baseName.replaceAll(/\.imzML$/, '')
    """
    mkdir -p workdir
    tar -xf ${candidate_list_and_ims_outs} -C workdir/
    ./run.R \
        --stage plot \
        --config ${config} \
        --datafile ${datafile} \
        --fasta ${fasta} \
        --rankfile ${rankfile} \
        --rotationfile ${rotationfile} \
        --threads ${threads}
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
        --threads ${threads}
    mkdir -p "workdir/Summary folder/"
    mkdir -p "workdir/${sample} ID/"
    touch "workdir/Summary folder/plot_outputs"
    touch "workdir/${sample} ID/plot_outputs"
    tar -cf plot.tar -C workdir/ "Summary folder/" "${sample} ID/"
    """
 }