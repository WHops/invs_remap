# Define your samples here
SAMPLES = ['NA12878']  # Add your sample names here

rule all:
    input:
        expand("sorted_{sample}.bam.bai", sample=SAMPLES),
        expand("{sample}.vcf", sample=SAMPLES),
        expand("filtered_{sample}.vcf", sample=SAMPLES)


rule generate_tsv_with_mismatches_all:
    input:
        bam="{sample}.bam",
        ref="/g/impont/ref/hg38.fa"  
    output:
        tsv="{sample}_WITH_MISMATCHALL_COL.tsv"
    shell: 
        """
        # Add the bash script code here to generate the TSV file
        # For example:
        pysamstats --pad --fasta {input.ref} --type variation --fields chrom,pos,reads_all,matches,deletions,mismatches {input.bam} -u | \
        awk 'BEGIN{{OFS="\t"; window=50; count=0; total_reads=0; total_matches=0; total_deletions=0; total_mismatches=0;}}
        !/^#/ {{
            count++;
            total_reads+=$3;
            total_matches+=$4;
            total_deletions+=$5;
            total_mismatches+=$6;
            if(count==window){{
                mismatches_all = total_reads - total_matches;
                matchrate = (total_reads>0 ? total_matches/total_reads : 0);
                print $1, $2-window+1, total_reads, total_matches, total_deletions, total_mismatches, matchrate, mismatches_all;
                count=0; total_reads=0; total_matches=0; total_deletions=0; total_mismatches=0;
            }}
        }}
        END{{
            if(count>0){{
                mismatches_all = total_reads - total_matches;
                matchrate = (total_reads>0 ? total_matches/total_reads : 0);
                print $1, $2-count+1, total_reads, total_matches, total_deletions, total_mismatches, matchrate, mismatches_all;
            }}
        }}' > {output.tsv}
        """
    
rule filter_tsv_to_bed:  
    input:
        tsv="{sample}_WITH_MISMATCHALL_COL.tsv"
    output:
        bed="{sample}.bed"
    shell:
        """
        awk 'BEGIN {{FS=OFS="\t"}}
        NR==1 {{next}} # skip header
        $7 < 0.8 && $7 != 0 && ($6 / $8) >= 0.10 {{
            print $1, $2, $2+50
        }}' {input.tsv} > {output.bed}
        """

rule make_bed_tab_delimited:
    input:
        "{sample}.bed"
    output:
        "{sample}_tab.bed"
    shell:
        "awk '{{print $1\"\t\"$2\"\t\"$3}}' {input} > {output}"

rule filter_invalid_bed_instances:
    input:
        "{sample}_tab.bed"
    output:
        "{sample}_tab_filtered.bed"
    shell:
        "awk '$2 >= 0' {input} > {output}"

rule sort_bed:
    input:
        "{sample}_tab_filtered.bed"
    output:
        "{sample}_sorted.bed"
    shell:
        "bedtools sort -i {input} > {output}"

rule merge_bed:
    input:
        "{sample}_sorted.bed"
    output:
        "{sample}_merged.bed"
    shell:
        "bedtools merge -i {input} -d 500 > {output}"

rule subtract_duplications:
    input:
        bed="{sample}_merged.bed",
        genomic_super_dup="data/GRCh38GenomicSuperDup.bed"
    output:
        "{sample}_no_duplications.bed"
    shell:
        "bedtools subtract -a {input.bed} -b {input.genomic_super_dup} > {output}"

rule subtract_centromeres:
    input:
        bed="{sample}_no_duplications.bed",
        centromeres="data/centromer_hg38_2.bed"
    output:
        "{sample}_no_duplications_no_centromeres.bed"
    shell:
        "bedtools subtract -a {input.bed} -b {input.centromeres} > {output}"

rule filter_small_regions:
    input:
        bed="{sample}_no_duplications_no_centromeres.bed"
    output:
        "{sample}_no_50.bed"
    shell:
        "awk '($3 - $2) > 50' {input.bed} > {output}"
 
### Below this line are the steps for processing the BAM files and subsequent analyses

rule bam_to_fasta:
    input:
        bam="{sample}.bam",
        bed="{sample}_no_50.bed"
    output:
        fasta="{sample}.fasta"
    shell:
        "samtools view -b -L {input.bed} {input.bam} | samtools fasta - > {output.fasta}"

rule ngmlr_mapping:
    input:
        fasta="{sample}.fasta",
        ref="/g/impont/ref/hg38.fa"
    output:
        sam="{sample}.sam"
    threads: 4
    shell:
        "/g/korbel2/tsapalou/SURVIVOR-master/Debug/ngmlr-0.2.7/ngmlr -t {threads} -r {input.ref} -q {input.fasta} -o {output.sam} -x ont"

rule correct_negative_quality_values:
    input:
        sam="{sample}.sam"
    output:
        corrected_sam="{sample}_filt.sam"
    shell:
        "awk '{{ if ($5 < 0) $5 = -$5; print }}' {input.sam} > {output.corrected_sam}"

rule sam_to_sorted_bam:
    input:
        corrected_sam="{sample}_filt.sam"
    output:
        sorted_bam="sorted_{sample}.bam"
    shell:
        "samtools view -bS {input.corrected_sam} | samtools sort -o {output.sorted_bam}"

rule index_bam:
    input:
        bam="sorted_{sample}.bam"
    output:
        bai="sorted_{sample}.bam.bai"
    shell:
        "samtools index {input.bam}"

rule delly_run:
    input:
        bam="sorted_{sample}.bam",
        ref="/g/impont/ref/hg38.fa"
    output:
        vcf="{sample}.vcf"
    shell:
        "/g/korbel/shared/software/delly/bin/delly lr -g {input.ref} {input.bam} > {output.vcf}"

rule filter_inversions:
    input:
        vcf="{sample}.vcf"
    output:
        filtered_vcf="filtered_{sample}.vcf"
    shell:
        "~/mambaforge/bin/python scripts/delly_inv.py {input.vcf} > {output.filtered_vcf}"