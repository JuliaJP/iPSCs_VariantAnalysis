#!/bin/sh

export anv_path=~/Downloads/annovar/
export f_dir=/data/PD22-02to07_WXS/f_iPSCs/


task(){
	perl $anv_path'convert2annovar.pl' \
		-format vcf4old $f_dir$id'_ALL_filtered.vcf.gz' > $f_dir$id'_ALL.AVInput';

	#perl $anv_path'annotate_variation.pl' -buildver hg38 -downdb -webfrom annovar refGene humandb;
	#perl $anv_path'annotate_variation.pl' -buildver hg38 -downdb -webfrom annovar avsnp147 humandb;
	#perl $anv_path'annotate_variation.pl' -buildver hg38 -downdb -webfrom annovar dbnsfp42a humandb;

	#perl $anv_path'table_annovar.pl' $f_dir$id'_ALL.AVInput' $anv_path'humandb/' -protocol dbnsfp42a -operation f -build hg38 -nastring .;
	#perl $anv_path'annotate_variation.pl' $f_dir$id'_ALL.AVInput' $anv_path'humandb/' -filter -build hg38 -dbtype avsnp147;
	#perl $anv_path'annotate_variation.pl' $f_dir$id'_ALL.AVInput' $anv_path'humandb/' -filter -build hg38 -dbtype clinvar_20221231;
	#perl $anv_path'annotate_variation.pl' -filter -dbtype exac03 -build hg38 $f_dir$id'_ALL.AVInput' $anv_path'humandb/';
	#perl $anv_path'annotate_variation.pl' -geneanno -dbtype refGene -build hg38 $f_dir$id'_ALL.AVInput' $anv_path'humandb/';

	perl $anv_path'table_annovar.pl' $f_dir$id'_ALL.AVInput' $anv_path'humandb/' -build hg38 -remove -protocol refGene,dbnsfp42a,avsnp147,clinvar_20221231,exac03 -operation g,f,f,f,f -nastring .;

}

N=2
(
for id in `cat iPSC_ids_add.txt`; do
        ((i=i%N)); ((i++==0)) && wait
        task "$id" &
done
)
~
