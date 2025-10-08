process PREPROCESS {
    label 'preprocess'

    publishDir "${params.output}/${params.preprocess_dir}", mode: params.publish_dir_mode

    input:
        path metadata

    output:
        path "metadata.tsv",   emit: metadata

    script:
    """
    echo "Step 0: Preprocessing metadata file"

    file=${metadata}
    required_columns=("ID" "SAMPLING_DATE" "LINEAGE")

    header=\$(head -n 1 "\$file")

    IFS=\$'\t' read -r -a header_columns <<< "\$header"

    missing_columns=()
    for col in "\${required_columns[@]}"; do
        if [[ ! " \${header_columns[@]} " =~ " \${col} " ]]; then
            missing_columns+=("\$col")
        fi
    done

    expected_header="accession,description,lab,source,collection,technology,platform,chemistry,material,ct,software,software_version,gisaid,ena,zip,date,submission_date,lineage,seqhash,dna_profile,aa_profile,fs_profile" 

    if [ \${#missing_columns[@]} -eq 0 ]; then
        mv \$file metadata.tsv
        echo "All required columns of the metadata are present."
    elif [[ "\$header" == "\$expected_header" ]]; then
        awk -v FS=',' -v OFS='\t' \
            'NR==1 {print "ID", "PRIMARY_DIAGNOSTIC_LAB_PLZ", "SAMPLING_DATE", "LINEAGE"} NR>1 {print \$1, \$15, \$16, \$18}' \
            ${metadata} > metadata.tsv
        echo "The metadata from covSonar was adjusted to VirusWarn-SC2 format."
    else
        echo "ERROR: The columns \${missing_columns[*]} are missing in the metadata!"
        echo "Please check if the required columns are existing. You may need to rename them."
        exit 1
    fi
    """

    stub:
    """
    touch metadata.tsv
    """
}