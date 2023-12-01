#2023.07.13
#extract intervar pathogenic variants (criteria3)

import glob

test = []
conf = ['Pathogenic','Likely pathogenic']
#id_lst = ['302','321','503','512','603','808','810']
#fi_list = ['./f_annot/' + s_id + '_targetgene_pathovariants.v2.txt' for s_id in id_lst ]
fi_list = glob.glob('./f_annot/*_targetgene_pathovariants.v2.txt')
for fi_name in fi_list :
    f_input = open(fi_name, 'r')
    f_output = open(fi_name.replace('_pathovariants.v2.txt','_intervarpathovar.v2.txt'),'w')
    f_head = f_input.readline().strip().split('\t')
    f_output.write( '\t'.join(f_head) + '\n')
    for f_line in f_input.readlines() :
        f_parse = f_line.strip().split('\t')
        test.append(f_parse[14])
        if f_parse[14] in conf :
            f_output.write('\t'.join(f_parse) + '\n')
    f_input.close()
    f_output.close()

print (list(set(test)))

