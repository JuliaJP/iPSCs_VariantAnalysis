#2023.07.13
#extract pathogenic variants in target genes

import glob

conf = ['nonsynonymous SNV', 'frameshift deletion', 'stopgain', 'startloss', 'frameshift insertion', 'stoploss']
#id_lst = ['302','321','503','512','603','808','810']
#fi_list = ['./f_annot/' + s_id + '_targetgene_variants.v2.txt' for s_id in id_lst ]
fi_list = glob.glob('./f_annot/*_targetgene_variants.v2.txt')
for fi_name in fi_list :
    f_input = open(fi_name, 'r')
    f_output = open(fi_name.replace('_variants.v2.txt','_pathovariants.v2.txt'),'w')
    f_head = f_input.readline().strip().split('\t')
    f_output.write( '\t'.join(f_head[0:14]) + '\t' + 'InterVar' + '\t' + '\t'.join(f_head[14:]) + '\n')
    for f_line in f_input.readlines() :
        f_parse = f_line.strip().split('\t')
        if f_parse[8] in conf :
            tmp = f_parse[14].strip().split(': ')[1]
            iv_crit = tmp.split(' PVS1')[0]
            f_output.write( '\t'.join(f_parse[0:14]) + '\t' + iv_crit + '\t' + '\t'.join(f_parse[14:]) + '\n')
    f_input.close()
    f_output.close()
