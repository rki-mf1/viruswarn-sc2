process REPORT {
    label 'report'

    publishDir "${params.output}/${params.report_dir}", mode: params.publish_dir_mode

    input:
        path variants_with_phenotypes
        path ecdc
        path bloom
        path lineages
        path rmd
        path input
        path mutation_table
        val metadata

    output:
        path "vocal-alerts-samples-all.csv",                emit: alerts_samples
        path "vocal-alerts-clusters-summaries-all.csv",     emit: alerts_clusters
        path "viruswarnsc2-report.html",                    emit: report

    script:
    """
    echo "Step 3: Detect and alert emerging variants"

    echo "Preparing csv for report..."
    
    Script_VOCAL_unified.R \
        -f ${variants_with_phenotypes} \
        -s "vocal-alerts-samples-all.csv" \
        -c "vocal-alerts-clusters-summaries-all.csv" \
        -a "${metadata}" \
        --ecdc ${ecdc} \
        --bloom ${bloom} \
        --lineages ${lineages}
    
    echo "Building HTML report..."

    Rscript --vanilla -e \
        "rmarkdown::render(input = \'${rmd}\', \\
        output_file = \'viruswarnsc2-report.html\', \\
        params = list(
            input = \'${input}\', \\
            metadata = \'${metadata}\', \\
            clusters = \'vocal-alerts-clusters-summaries-all.csv\', \\
            alert_samples = \'vocal-alerts-samples-all.csv\', \\
            moc = \'${mutation_table}\', \\
            strict = \'${params.strict}\', \\
            data = \'${params.data}\', \\
            version = \'${params.version}\')
        )"
    """

    stub:
    """
    touch vocal-alerts-samples-all.csv 
    touch vocal-alerts-clusters-summaries-all.csv 
    touch viruswarnsc2-report.html 
    """
}