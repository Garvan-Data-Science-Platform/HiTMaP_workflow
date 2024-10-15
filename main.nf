#!/usr/bin/env nextflow

nextflow.enable.dsl=2

log.info """\

========================
HiTMap Nextflow Workflow
========================

========================
Workflow parameters:
========================

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

    param        ARGUMENT        Description
    """.stripIndent()
}

workflow {

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
