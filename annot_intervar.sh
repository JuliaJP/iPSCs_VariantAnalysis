#!/bin/sh

export anv_path=~/Downloads/annovar/
export intv_path=/home/ctx_jh/InterVar/
export f_dir=/data/PD22-02to07_WXS/f_iPSCs/
task(){

        perl $anv_path'convert2annovar.pl' -format vcf4old $f_dir$id'_ALL_filtered.vcf.gz' > $f_dir$id'_ALL.AVInput';
	python $intv_path'Intervar.py' -b hg38 -i $f_dir$id'_ALL.AVInput' \
		--input_type=AVinput -o $f_dir$id;

}

N=2

(
for id in `cat iPSC_ids_add.txt`; do
        ((i=i%N)); ((i++==0)) && wait
        task "$id" &
done
)
