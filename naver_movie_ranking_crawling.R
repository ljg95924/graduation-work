install.packages('XML')
library(XML)
library(stringr)
#네이버 영화 랭킹 목록
url_base<-'http://movie.naver.com/movie/sdb/rank/rmovie.nhn?sel=pnt&date=20180315&page='

#영화 코드 목록
all.codes<-c()
#영화 이름 목록
all.titles<-c()
#영화 평점 목록
all.points<-c()

#1~40 페이지 영화 목록 수집
#for(page in 1:40)
#{
  url<-paste(url_base,1,sep='') #url_base 에 페이지 번호를 붙인다. (1~40까지)
  txt<-readLines(url,encoding = 'euc-kr') #url에 해당하는 웹을 읽고 인코딩 euc-kr로
  
  #tit5클래스 아래 1줄 아래에는 영화 고유코드와 제목이 있다.
  movie_info<-txt[which(str_detect(txt,'class=\"tit5\"'))+1] #읽어온 정보 txt 에서 class='tit5'라는 문자열이 존재하는 곳을 찾아서 한 줄 아래 있는 정보를 moive_info 에
  #tit5클래스 아래 7줄 아래에는 평점이 있다.
  points<-txt[which(str_detect(txt,'class=\"point\"'))]

  #일부 코드를 선택
  codes<-substr(movie_info,40,50) #movie_info 에 내용 중 40번째 문자부터 50개의 문자만 가져옴 
  #코드 중 숫자만 남기고 지우기
  codes<-gsub('\\D','',codes) #codes에는 숫자 형식의 영화 코드값과 일부 소스값이 담겨있다 
  #텍스트만 남기고 코드 지우기
  titles<-gsub('<.+?>|\t','',movie_info) #소스코드는 없애고 영화 제목만 남긴다 
  #텍스트만 남기고 코드 지우기
  points<-gsub('<.+?>|\t','',points) #평점만 남긴다.
  
  #영화 코드값 저장
  all.codes<-c(all.codes,codes)
  #영화 이름 저장
  all.titles<-c(all.titles,titles)
  #영화 평점 저장
  all.points<-c(all.points,points)
}

x<-cbind(all.codes,all.titles,all.points)
head(x)
colnames(x)<-c('code','movie_title','point')
write.csv(x,'C:\\Users\\CS3-10\\Documents\\GitHub\\R-study\\movie_list.csv')
