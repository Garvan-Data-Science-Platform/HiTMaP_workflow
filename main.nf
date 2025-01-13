#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { run_info } from './modules/run_info'
include { candidates } from './modules/candidates'
include { ims } from './modules/ims'
include { plot } from './modules/plot'

log.info """\

========================
HiTMap Nextflow Workflow
========================

========================
Workflow parameters:
========================
mode              : ${params.mode}
config            : ${params.config}
datafile          : ${params.datafile}
ibdfile           : ${params.ibdfile}
fasta             : ${params.fasta}
rotationfile      : ${params.rotationfile}
rankfile          : ${params.rankfile}
candidates        : ${params.candidates}
imsdata           : ${params.imsdata}
threads           : ${params.threads}
hitmap_container  : ${params.hitmap_container}
outdir            : ${params.outdir}
========================

"""

// Define valid run modes
modes = ['full', 'candidates', 'ims', 'plot']
modes_str = "[ " + modes.join(" | ") + " ]"

// Help function
def helpMessage() {
    log.info """
    HiTMaP workflow

    Usage: nextflow main.nf [ params... ]

    Parameter description:

    mode              RUNMODE  Specify the run mode. $modes_str ('full').
    config            PATH     Path to the config R file. Required.
    datafile          PATH     Path to the data .imzML file. Required.
    ibdfile           PATH     Path to the data .ibd file. Required.
    fasta             PATH     Path to the FASTA file. Required.
    rotationfile      PATH     Path to a roation CSV file. Optional.
    rankfile          PATH     Path to a rank CSV file. Optional.
    candidates        PATH     Path to a tar file containing the outputs of a previous run of the candidates mode. Optional.
    imsdata           PATH     Path to a tar file containing the joint outputs of a previous run of the candidates and IMS analysis modes. Optional.
    threads           PATH     Number of threads to use (1).
    hitmap_container  PATH     false
    outdir            PATH     Output directory ('results/').
    """.stripIndent()
}

workflow {
    // Check for valid parameters
    if ( params.help || !modes.contains(params.mode) || params.hitmap_container == false ){   
        helpMessage()
        exit 1
    }
    // Check threads parameter
    threads = params.threads.toString().toInteger()
    if ( threads < 1 ) {
        threads = 1
    }
    // Check required input files
    if ( params.datafile == false || params.ibdfile == false || params.fasta == false || params.config == false ) {
        helpMessage()
        exit 1
    } else {
        datafile = Channel.fromPath( params.datafile, checkIfExists: true )
        fasta = Channel.fromPath( params.fasta, checkIfExists: true )
        ibdfile = Channel.fromPath( params.ibdfile, checkIfExists: true )
        config = Channel.fromPath( params.config, checkIfExists: true )
    }
    // Check optional input files
    if ( params.rankfile == false ) {
        rankfile = Channel.fromPath( 'assets/empty.csv', checkIfExists: true )
    } else {
        rankfile = Channel.fromPath( params.rankfile, checkIfExists: true )
    }
    if ( params.rotationfile == false ) {
        rotationfile = Channel.fromPath( 'assets/empty.csv', checkIfExists: true )
    } else {
        rotationfile = Channel.fromPath( params.rotationfile, checkIfExists: true )
    }
    // Determine which stages need to run
    run_candidates = false
    run_ims = false
    run_plot = false
    if ( params.mode == 'full' ) {
        run_candidates = true
        run_ims = true
        run_plot = true
    } else if ( params.mode == 'candidates' ) {
        run_candidates = true
    } else if ( params.mode == 'ims' ) {
        run_candidates = (params.candidates == false)
        run_ims = true
    } else if ( params.mode == 'plot' ) {
        run_candidates = (params.candidates == false && params.imsdata == false)
        run_ims = (params.imsdata == false)
        run_plot = true
    } else {
        helpMessage()
        exit 1
    }

    // Print which stages are to be run
    run_candidates_str = run_candidates ? 'RUNNING' : 'USING SUPPLIED CANDIDATES LIST'
    run_ims_str = run_ims ? 'RUNNING' : ( run_plot ? 'USING SUPPLIED IMS ANALYSIS' : 'NOT RUNNING' )
    run_plot_str = run_plot ? 'RUNNING' : 'NOT RUNNING'
    log.info """
    ========================
    Workflow overview
    ========================

    Candidate list generation:  $run_candidates_str
    IMS analysis:               $run_ims_str
    Plotting:                   $run_plot_str

    ========================
    """.stripIndent()

    // Grab HiTMaP run info
    run_info(config)

    // Exit now if this is a dry run
    if ( params.dryrun ) {
        log.info """
        *** THIS WAS A DRY RUN ***
        """.stripIndent()
        exit 0
    }

    // Run stages
    if ( run_candidates ) {
        candidates(datafile, ibdfile, fasta, rankfile, rotationfile, config)
        candidate_list = candidates.out.candidates
    } else {
        candidate_list = Channel.fromPath( params.candidates, checkIfExists: true )
    }

    if ( run_ims ) {
        ims(candidate_list, datafile, ibdfile, fasta, rankfile, rotationfile, config)
        ims_outs = ims.out.ims
    } else if ( run_plot ) {
        ims_outs = Channel.fromPath( params.imsdata, checkIfExists: true )
    }

    if ( run_plot ) {
        plot(ims_outs, datafile, ibdfile, fasta, rankfile, rotationfile, config)
        plot_outs = plot.out.plot
    }
}

// Print workflow execution summary 
workflow.onComplete {
    summary = """
    =======================================================================================
    Workflow execution summary
    =======================================================================================
    
    Duration    : ${workflow.duration}
    Success     : ${workflow.success}
    workDir     : ${workflow.workDir}
    Exit status : ${workflow.exitStatus}
    results     : ${params.outdir}
    
    =======================================================================================
    """.stripIndent()
    println summary
}
