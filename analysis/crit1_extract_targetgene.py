#2023.07.13
#extract variants within target gene regions (PD22-02to08)

import glob

tg_list = []
tg_dic = dict()
f_crit = open('TotGeneList_3Categ.txt','r')
for fc_line in f_crit.readlines() :
    fc_parse = fc_line.strip().split('\t')
    tg_list.append(fc_parse[0])
    tmp = [ i for i in fc_parse[1:] if i != 'NA']
    tg_dic[fc_parse[0]] = ','.join(tmp)
f_crit.close()

conf = []
#id_lst = ['206','208','213','302','310','311','320','321','408','412','415','502','503','512','515','517D','602','603','609','618','619','709','718','803','804','808','810']
#fi_list = ['../f_iPSCs/' + s_id + '.hg38_multianno.txt.intervar' for s_id in id_lst ]
fi_list = glob.glob('../f_iPSCs/*.hg38_multianno.txt.intervar')
for fi_name in fi_list :
    out_name = fi_name.replace('../f_iPSCs/','./f_annot/')
    f_output = open(out_name.replace('.hg38_multianno.txt.intervar','_targetgene_variants.v2.txt'),'w')
    f_input = open(fi_name, 'r')
    fi_header = f_input.readline().strip().split('\t')
    f_output.write('\t'.join(fi_header[0:5]) + '\t' + 'genesymb' + '\t' + 'category' + '\t' + '\t'.join(fi_header[6:]) + '\n')
    for fi_line in f_input.readlines() :
        fi_parse = fi_line.strip().split('\t')
        g_list = fi_parse[5].strip().split(';')
        #conf.append(fi_parse[5])
        if fi_parse[6].count('exonic') != 0 :
            for gene in g_list :
                if gene in tg_dic :
                    f_output.write('\t'.join(fi_parse[0:5]) + '\t' + gene + '\t' + tg_dic[gene] + '\t' + '\t'.join(fi_parse[6:]) + '\n')
    f_input.close()
    f_output.close()
#print (set(conf))
