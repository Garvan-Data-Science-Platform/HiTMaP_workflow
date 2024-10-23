// Run IMS analysis
process ims {
    debug = true
    tag "ims"
    // container "${params.container_dir}/hitmap.sif"

    input:
    path(candidate_list, stageAs: 'inputs/*')
    path(datafile, stageAs: 'workdir/*')
    path(ibdfile, stageAs: 'workdir/*')
    path(fasta, stageAs: 'workdir/*')
    path(rankfile, stageAs: 'workdir/rank.csv')
    path(rotationfile, stageAs: 'workdir/rotation.csv')
    path(config)
    val(threads)

    output:
    path("ims.tar"), emit: ims

    script:
    sample = datafile.baseName.replaceAll(/\.imzML$/, '')
    """
    mkdir -p workdir
    tar -xf ${candidate_list} -C workdir/
    ./run.R \
        --stage ims \
        --config ${config} \
        --datafile ${datafile} \
        --fasta ${fasta} \
        --rankfile ${rankfile} \
        --rotationfile ${rotationfile} \
        --threads ${threads}
    tar -cf ims.tar -C workdir/ "Summary folder/" "${sample} ID/"
    """

    stub:
    sample = datafile.baseName.replaceAll(/\.imzML$/, '')
    """
    echo mkdir -p workdir
    echo tar -xf ${candidate_list} -C workdir/
    echo ./run.R \
        --stage ims \
        --config ${config} \
        --datafile ${datafile} \
        --fasta ${fasta} \
        --rankfile ${rankfile} \
        --rotationfile ${rotationfile} \
        --threads ${threads}
    mkdir -p "workdir/Summary folder/"
    mkdir -p "workdir/${sample} ID/"
    touch "workdir/Summary folder/candidatelist.csv"
    touch "workdir/Summary folder/Region_feature_summary.csv"
    touch "workdir/${sample} ID/preprocessed_imdata.RDS"
    tar -cf ims.tar -C workdir/ "Summary folder/" "${sample} ID/"
    """
 }