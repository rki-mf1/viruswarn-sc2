process COVSONAR {
    label 'biopython'

    publishDir "${params.output}/${params.annot_dir}", mode: params.publish_dir_mode

    input:
        path covsonar_match
        path mutation_table

    output:
        path "variants_with_phenotypes.tsv",   emit: variants_with_phenotypes

    script:
    """
    echo "Mutations given through covSonar file, skipping Step 1"
    echo "Step 2: Annotate mutation phenotypes from covSonar csv"

    Selector.py convert-covSonar \
        -i ${covsonar_match} \
        -a ${mutation_table} \
        -o "variants_with_phenotypes.tsv"
    """

    stub:
    """
    touch variants_with_phenotypes.tsv 
    """
}