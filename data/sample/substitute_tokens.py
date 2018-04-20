import sys
from random import randint
"""
vocab = []
wf = open("formulasfalse.norm.lst",'w')
with open("vocab.txt","r") as vocab_file:
    for line in vocab_file:
        vocab.append(line.strip())

with open("formulas.norm.lst",'r') as of:
    for line in of:
        tokens = line.rstrip().split(" ")
        substitute_index = randint(0, len(tokens)-1)
        tokens[substitute_index] = vocab[randint(0,len(vocab))-1]
        wf.write(" ".join(tokens)+"\n")
"""
new_num = 1200
wf = open("test_filter_targeted.lst","w")
with open("test_filter.lst","r") as of:
    for line in of:
        # new_num += 1
        image, num = line.split()
        new_line = image+" "+str(int(num)+new_num)+"\n"
        wf.write(new_line)
wf.close()

