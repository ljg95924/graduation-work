import csv
#import os
from collections import defaultdict
#print (os.getcwd())
from itertools import count
columns=defaultdict(list)
f=open('movie_list.csv','r',encoding='euc-kr')
rdr=csv.DictReader(f)
print(rdr)
for row in rdr:
    for (k,v) in row.items():
        columns[k].append(v)
        
print(columns['code'])
f.close()
#for r in columns['code']:
#    print(r)
for d in count():
    
