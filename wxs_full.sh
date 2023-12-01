#!/bin/sh

export REF=/data/reference/
export PICARD=/home/ctx_jh/picard/build/libs/
#export fib_dir=/data/PD22-02to07_WXS/Fib_7s/
export fib_dir=./Fib_7s/
export sample_dir=/data/PD22-02to07_WXS/f_iPSCs/

task(){
	echo '*****Sample id : '$id; 
	echo '-----1'; echo '-----Alignment';
	bwa mem -t 8 -R '@RG\tID:'$id'\tPL:illumina\tLB:'$id'\tSM:'$id \
	$REF'resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta' \
	$sample_dir$id"_1.fastq.gz" $sample_dir$id"_2.fastq.gz" > $sample_dir$id".sam";

	echo '-----2'; echo '-----Converting';
	samtools view -Shb $sample_dir$id'.sam' > $sample_dir$id'.bam';
	
	echo '-----3'; echo '-----Markduplicates';
	gatk --java-options "-Xmx8G" MarkDuplicatesSpark -I $sample_dir$id'.bam' \
	-O $sample_dir$id'_marked_duplicates.bam';

	echo '-----4'; echo '-----BaseRecalibration';
	gatk --java-options "-Xmx8G" BaseRecalibrator -I $sample_dir$id'_marked_duplicates.bam' \
	-R $REF'resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta' \
	--known-sites $REF'resources_broad_hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf' \
	-O $sample_dir$id'_recal_data.table';
	
	echo '-----5'; echo '-----Basequalityscore recalibration';
	gatk --java-options '-Xmx8G' ApplyBQSR \
	-R $REF'resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta' \
	-I $sample_dir$id'_marked_duplicates.bam' \
	--bqsr-recal-file $sample_dir$id'_recal_data.table' \
	-O $sample_dir$id'_marked_dup_recal.bam';

	echo '-----6'; echo '-----Variant calling';
	echo ${id:0:1}
	echo $id
	echo $fib_dir'PD-00'${id:0:1}'-fibroblast_marked_dup_recal.bam'
	gatk --java-options '-Xmx32G' Mutect2 \
		-R $REF'resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta' \
		-I $fib_dir'PD-00'${id:0:1}'-fibroblast_marked_dup_recal.bam' \
		-I $sample_dir$id'_marked_dup_recal.bam' -normal $fib_dir'PD-00'${id:0:1}'-fibroblast' \
		--germline-resource $REF'af-only-gnomad.hg38.vcf.gz' \
		--panel-of-normals $REF'somatic-hg38_1000g_pon.hg38.vcf.gz' \
		-O $sample_dir$id'_all.vcf.gz';

	echo '-----7.1'; echo '-----VarCall-SNV';
	gatk --java-options '-Xmx32G' SelectVariants \
		-R $REF'resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta' \
		-V $sample_dir$id'_all.vcf.gz' \
		--select-type-to-include SNP \
		-O $sample_dir$id'_SNV.vcf.gz';

	echo '-----7.2'; echo '-----VarCall-INDEL';
	gatk --java-options '-Xmx32G' SelectVariants \
		-R $REF'resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta' \
		-V $sample_dir$id'_all.vcf.gz' \
		--select-type-to-include INDEL \
		-O $sample_dir$id'_IND.vcf.gz';

	echo '-----8.1'; echo '-----Filtering';
	gatk --java-options '-Xmx8G' VariantFiltration \
		-R $REF'resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta' \
		-V $sample_dir$id'_SNV.vcf.gz' \
		-O $sample_dir$id'_SNV_filtered.vcf.gz';
	
	echo '-----8.2'; echo '-----Filtering';
	gatk --java-options '-Xmx8G' VariantFiltration \
		-R $REF'resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta' \
		-V $sample_dir$id'_IND.vcf.gz' \
		-O $sample_dir$id'_IND_filtered.vcf.gz';

	echo '-----9'; echo '-----merge';
	gatk --java-options '-Xmx8G' MergeVcfs \
		-I $sample_dir$id'_SNV_filtered.vcf.gz' \
		-I $sample_dir$id'_IND_filtered.vcf.gz' \
		-O $sample_dir$id'_ALL_filtered.vcf.gz';

}

N=2
(
#for id in `cat iPSC_ids.txt`; do
#for id in `cat fib_ids.txt`; do
for id in `cat iPSC_ids_add.txt`; do
	((i=i%N)); ((i++==0)) && wait
	task "$id" &
done
)
