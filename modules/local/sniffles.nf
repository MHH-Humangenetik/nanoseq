process SNIFFLES {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::sniffles=2.0.7"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sniffles:2.0.7--pyhdfd78af_0' :
        'quay.io/biocontainers/sniffles:2.0.7--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(bam), path(bai)
    path fasta


    output:
    tuple val(meta), path("*_sniffles.vcf"), emit: sv_vcf
    tuple val(meta), path("*_sniffles.snf"), emit: sv_snf
    path "versions.yml"                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    sniffles \\
        --input $bam \\
        --vcf ${meta.id}_sniffles.vcf \\
        --snf ${meta.id}_sniffles.snf \\
        --reference $fasta \\
        -t $task.cpus \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sniffles: \$(sniffles --help 2>&1 | grep Version |sed 's/^.*Version: //')
    END_VERSIONS
    """
}

