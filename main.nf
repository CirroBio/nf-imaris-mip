#!/usr/bin/env nextflow

process make_mip {
    container "${params.container}"
    containerOptions '--entrypoint ""'
    publishDir "${params.outdir}", mode: 'copy', overwrite: true

    input:
    path "inputs/"
    path macro

    output:
    path "*.tif"
    path "*.jpg"

    script:
    template "make_mip.sh"
}


workflow {

    if (!params.inputs) {
        exit 1, "Missing input files"
    }
    if (!params.outdir) {
        exit 1, "Missing output directory"
    }
    if (!params.container) {
        exit 1, "Missing container"
    }

    // Get the macro file
    macro = file("$projectDir/macros/${params.macro}", checkIfExists: true)

    Channel
        .fromPath("${params.inputs}".split(',').toList())
        .toSortedList()
        .set { input_ch }

    

    make_mip(
        input_ch,
        macro
    )
}