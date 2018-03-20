import re
import requests
from bs4 import BeautifulSoup
url = "http://movie.naver.com/movie/sdb/rank/rmovie.nhn"
soup = BeautifulSoup(requests.get(url).text, 'html.parser')
move_list = soup.find_all('div', 'tit3')
count = 1
for m in move_list:
    title = m.find('a')
    print (count, '위:', re.search('title=".+"', str(title)).group()[7:-1])
    count += 1
