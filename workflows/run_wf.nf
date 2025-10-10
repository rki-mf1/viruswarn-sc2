include { PREPROCESS }      from '../modules/local/preprocess'
include { VOCAL }           from '../modules/local/vocal'
include { PSL }             from '../modules/local/psl'
include { ANNOTATION }      from '../modules/local/annotation'
include { COVSONAR }        from '../modules/local/covsonar'
include { REPORT }          from '../modules/local/report'

workflow RUN {
    take:
        ref_nt
        input
        mutation_table
        metadata
        variants
        bloom
        lineages
        rmd

    main:
        if (metadata != '' || params.covsonar){
            PREPROCESS ( metadata )
        }

        if (params.psl) {
            PSL ( ref_nt, input )

            ANNOTATION ( PSL.out.variant_table, mutation_table )
        } else if (params.covsonar) {
            COVSONAR ( input, mutation_table )
        } else {
            VOCAL ( input )

            ANNOTATION ( VOCAL.out.variant_table, mutation_table )
        }

        meta = (metadata != '' || params.covsonar) ? PREPROCESS.out.metadata : metadata
        annot = (params.covsonar) ? COVSONAR.out.variants_with_phenotypes : ANNOTATION.out.variants_with_phenotypes 

        REPORT ( 
            annot, variants, bloom, lineages,
            rmd, input, mutation_table, meta
        )

    emit:
        report = REPORT.out.report

}