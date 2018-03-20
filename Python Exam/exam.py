import urllib.request
from bs4 import BeautifulSoup
import pandas as pd
import datetime
from itertools import count
import xml.etree.ElementTree as ET # XML
import csv
from collections import defaultdict

def get_request_url(url, enc='utf-8'):
    req = urllib.request.Request(url)

    try:
        response=urllib.request.urlopen(req)
        if response.getcode()==200:
            try:
                rcv=response.read()
                ret=rcv.decode(enc)
            except UnicodeDecodeError:
                ret = rcv.decode(enc,'replace')

            return ret
    except Exception as e:
        print(e)
        print("[%s] Error for URL : %s " %(datetime.datetime.now(),url))
        return None
def getPelicanaAddress(result):
    f=open('movie_list.csv','r',encoding='euc-kr')
    rdr=csv.DictReader(f)
    columns=defaultdict(list)

    for row in rdr:
        for (k,v) in row.items():
            columns[k].append(v)

    f.close()
    for page_idx in columns['code']:      
        Movie_URL="https://movie.naver.com/movie/sdb/rank/rmovie.nhn?sel=pnt&date=%s" %str(page_idx)
        url_paging="&type=after&isActualPointWriteExecute=false&isMileageSubscriptionAlready=false&isMileageSubscriptionReject=false&page="
        #Pelicana_URL="http://www.pelicana.co.kr/store/stroe_search.html?page=%s&branch_name=&gu=&si=" %str(page_idx+1)
        print("[Movie Page] : [%s]" %(str(page_idx)))

        rcv_data=get_request_url(Movie_URL)
        soupData=BeautifulSoup(rcv_data,'html.parser')

        store_div=soupData.find('div',attrs={'class':'score_result'})
        print(store_div)
        bEnd=True
        for store_li in store_div.findAll('li'):
            bEnd=False
            tr_tag=list(store_li.strings)
            print(tr_tag)
            store_name=tr_tag[1]
            store_address=tr_tag[3]
            store_sido_gu=store_address.split()[:2]

            result.append([store_name]+store_sido_gu+[store_address])
        if(bEnd==True):
            return
    return
def main():
    result=[]
    

    print('PERICANA ADDRESS CRAWLING START')
    getPelicanaAddress(result)
    #print(result)
    pericana_table=pd.DataFrame(result,columns=('store','sido','gungu','store_address'))
    pericana_table.to_csv("C:/pericana.csv",encoding='cp949',mode='w',index=True)
    del result[:]

if __name__=='__main__':
    main()
