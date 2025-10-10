#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// help message
if (params.help) { exit 0, helpMSG() }

// Parameters sanity checking
Set valid_params = ['cores', 'max_cores', 'memory', 
                    'version', 'help', 'profile', 'update_data',
                    'input', 'metadata', 'data', 'psl', 'covsonar', 'strict',
                    'output', 'preprocess_dir', 'vocal_dir', 
                    'annot_dir', 'report_dir', 'runinfo_dir',
                    'publish_dir_mode', 'conda_cache_dir', 'singularity_cache_dir',
                    'cloudProcess', 'cloud-process']

def parameter_diff = params.keySet() - valid_params
if (parameter_diff.size() != 0) {
    exit 1, 
    "ERROR: Parameter(s) $parameter_diff is/are not valid in the pipeline!\n"
}

// error codes
if (params.profile) { 
    exit 1, 
    "ERROR: --profile is wrong please use -profile!\n" 
}

if (params.psl && params.covsonar) {
    exit 1,
    "ERROR: --psl and --covsonar can't be used together, please check your input and choose one.\n For a FASTA file, keep --psl. For a covSonar CSV, keep --covsonar.\n"
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { RUN } from './workflows/run_wf'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    ref_nt = Channel.fromPath( file("data/ref.fna", checkIfExists: true) )

    input = Channel.fromPath( file("${params.input}", checkIfExists: true) )

    rmd = Channel.fromPath( file("bin/report.Rmd", checkIfExists: true) )

    if (params.data == 2022) {
        log.info"INFO: VirusWarn-SC2 uses mutation, lineage and VOC/VOI/VUM information from November 2022"
        mutation_table = Channel.fromPath( file("data/2022-11/table_cov2_mutations_annotation.tsv", checkIfExists: true) )
        variants = Channel.fromPath( file("data/2022-11/ECDC_assigned_variants.csv", checkIfExists: true) )
        lineages = Channel.fromPath( file("data/2022-11/lineage.all.tsv", checkIfExists: true) )
    } else if (params.data == 2021) {
        log.info"INFO: VirusWarn-SC2 uses mutation, lineage and VOC/VOI/VUM information from September 2021"
        mutation_table = Channel.fromPath( file("data/2021-09/table_cov2_mutations_annotation.tsv", checkIfExists: true) )
        variants = Channel.fromPath( file("data/2021-09/ECDC_assigned_variants.csv", checkIfExists: true) )
        lineages = Channel.fromPath( file("data/2021-09/lineage.all.tsv", checkIfExists: true) )
    } else if (params.data instanceof String) {
        log.info"INFO: VirusWarn-SC2 uses mutation, lineage and VOC/VOI/VUM information from a personalized dataset"
        mutation_table = Channel.fromPath( file(params.data + "/table_cov2_mutations_annotation.tsv", checkIfExists: true) )
        variants = Channel.fromPath( file(params.data + "/assigned_variants.csv", checkIfExists: true) )
        lineages = Channel.fromPath( file(params.data + "/lineage.all.tsv", checkIfExists: true) )
    } else {
        exit 1,
        "ERROR: $params.data is an invalid input for the parameter data!\n"
    }

    if (params.metadata != '') {
        metadata = Channel.fromPath( file("${params.metadata}", checkIfExists: true) )
    } else if (params.covsonar) {
        metadata = Channel.fromPath( file("${params.input}", checkIfExists: true) )
    } else {
        log.warn"WARNING! No metadata file was given. This can lead to problems, like not correctly identifying pink alerts or lineage defining mutations!\n"
        metadata = params.metadata
    }

    bloom = Channel.fromPath( file("data/escape_data_bloom_lab.csv", checkIfExists: true) )

    RUN ( 
        ref_nt, input, mutation_table, metadata,
        variants, bloom, lineages, rmd
    )

}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    HELP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_red = "\u001B[31m";
    c_dim = "\033[2m";
    log.info """
    ____________________________________________________________________________________________
    
    ${c_blue}Robert Koch Institute, MF1 Bioinformatics${c_reset}

    Workflow: VirusWarn-SC2

    ${c_yellow}Usage examples:${c_reset}
    nextflow run rki-mf1/viruswarn-sc2 -r <version> -profile conda,local --input 'test/sample-test.fasta'

    ${c_yellow}Input options for runs:${c_reset}
    ${c_green} --input ${c_reset}           REQUIRED! Path to the input file. Fasta file or covSonar csv, which 
                        needs to be specified with the parameter `--covsonar`.
                        [ default: $params.fasta ]
    ${c_green} --metadata ${c_reset}        Path to the metadata file.
                        [ default: $params.metadata ]
    ${c_green} --data ${c_reset}            Specify the data from which the information should 
                        be used for the ranking. The options are 2021, 2022 and 2025.
                        Alternatively, a path to a personal dataset can be entered. Please make sure a 
                        table_cov2_mutations_annotation.tsv, assigned_variants.csv and lineage.all.tsv are present.
                        [ default: $params.data ]
    ${c_green} --psl ${c_reset}             RECOMMENDED FOR FAST PROCESSING! Run process with pblat alignment.
                        [ default: $params.psl ]
    ${c_green} --covsonar ${c_reset}        Use if the input is not a fasta file but a csv from covSonar.
                        [ default: $params.covsonar ]
    ${c_green} --strict ${c_reset}          Run process with strict alert levels (without orange).
                        [ default: $params.strict ]

    ${c_yellow}Computing options:${c_reset}
    ${c_green} --cores ${c_reset}           Max cores per process for local use 
                        [ default: $params.cores ]
    ${c_green} --max_cores ${c_reset}       Max cores used on the machine for local use 
                        [ default: $params.max_cores ]
    ${c_green} --memory ${c_reset}          Max memory in GB for local use
                        [ default: $params.memory ]
    
    ${c_yellow}Output options:${c_reset}
    ${c_green} --output ${c_reset}                  Name of the result folder 
                                [ default: $params.output ]
    ${c_green} --publish_dir_mode ${c_reset}        Mode of output publishing: 'copy', 'symlink' 
                                [ default: $params.publish_dir_mode ]
                                ${c_dim}With 'symlink' results are lost when removing the work directory.${c_reset}
    
    ${c_yellow}Caching:${c_reset}
    ${c_green} --conda_cache_dir ${c_reset}         Location for storing the conda environments 
                                [ default: $params.conda_cache_dir ]
    ${c_green} --singularity_cache_dir ${c_reset}   Location for storing the Singularity images 
                                [ default: $params.singularity_cache_dir ]
    
    ${c_yellow}Execution/Engine profiles:${c_reset}
    The pipeline supports profiles to run via different ${c_green}Executors${c_reset} and ${c_blue}Engines${c_reset} e.g.: -profile ${c_green}local${c_reset},${c_blue}conda${c_reset}
    
    ${c_green}Executor${c_reset} (choose one):
        local
        slurm
    
    ${c_blue}Engines${c_reset} (choose one):
        conda
        mamba
        docker
        singularity
    """
}