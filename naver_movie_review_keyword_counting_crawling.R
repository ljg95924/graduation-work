rm(list=ls())# 변수 다삭제 

library(XML)
library(stringr)
library(dplyr)
#code 받기 전까지의 주소
url_base<-"http://movie.naver.com/movie/bi/mi/pointWriteFormList.nhn?code=" 
#상세 리뷰 주소
url_paging<-"&type=after&isActualPointWriteExecute=false&isMileageSubscriptionAlready=false&isMileageSubscriptionReject=false&page="

#한 영화에 대한 리뷰 건수를 기록할 리스트
all.review_cnt<-c()
#영화 리뷰 중 특정 키워드가 인용된 건수
all.keyword_cnt<-c()

#특정 키워드 지정
keyword<-'감동'
#영화 목록파일을 직접 선택
target_file<-read.csv(file.choose(),header = T,sep=',')

target_file<-target_file%>%
  select(-X)

#정보 확인한 영화 건 수
success_cnt<-0  #웹 크로링을 많은 시간동안 하다보니 중간에 크롤링을 끊어도 그 전까지 정보를 저장하고자한 체크변수
start_moive<-1
##크롤링 시작 // 영화별로 리뷰건수와 리뷰내용을 크롤링한다.
#for(i in start_moive:5)
#{01
#  movie_code<-target_file$code[i]
  movie_code<-target_file$code[1]
  #네이버에서 관리하는 영화 고유 코드 값
  url_main<-paste(url_base,movie_code,sep='')
  url_main<-paste(url_main,url_paging,sep='')
  url_main<-paste(url_main,1,sep='')
  
  #웹 크롤링
  txt<-readLines(url_main,encoding = 'UTF-8')
  review_cnt<-txt[which(str_detect(txt,'class=\"total\"'))]
  #review_cnt
  review_cnt<-str_replace(review_cnt,'140자 평','')
  review_cnt<-gsub('\\D','',review_cnt) #숫자를 제외한 문자 제거
  
  if(review_cnt==0| length(review_cnt)==0)
  {
    review_cnt<-0
    all.review_cnt<-c(all.review_cnt,review_cnt)#리뷰 건수 저장
    break
  }
  all.review_cnt<-c(all.review_cnt,review_cnt)
  
  #반복할 리뷰 페이징 건수
  if(review_cnt>10 | length(review_cnt)>1)
  {
    #페이지마다 리뷰가 10건씩 , 총리뷰/10 = 최종 페이지
    total_page<-as.numeric(review_cnt)%/%10 
  }else
  {
    total_page<-1
  }
  all.reviews<-c() #영화 리뷰
  
  ##영화 리뷰 내용 크롤링
  #for(page in 1:total_page)
  for(page in 1:30)  
  {
    url_sub<-paste(url_base,movie_code,sep='')
    url_sub<-paste(url_sub,url_paging,sep='')
    url_sub<-paste(url_sub,page,sep='')
    
    review_txt<-readLines(url_sub,encoding = 'UTF-8')
    
    reviews<-review_txt[which(str_detect(review_txt,'class=\"score_reple\"'))+1]
    
    reviews<-c(str_match(reviews,keyword)) #특정 키워드 포함된 리뷰만 저장 아니면 NA로 
    
    all.reviews<-c(all.reviews,reviews) #리뷰 목록 저장
  }
  #review_txt
  #reviews
  #all.reviews
  ##영화 리뷰 내용 크롤링 후 해당 영화의 리뷰에서 특정 단어가 몇 번이나 인용되었는지 
  keyword_cnt<-all.reviews[!is.na(all.reviews)]
  #keyword_cnt
  keyword_cnt<-length(keyword_cnt)
  all.keyword_cnt<-c(all.keyword_cnt,keyword_cnt)
  #all.keyword_cnt
  success_cnt<-success_cnt+1
#}
  

#x<-target_file[start_moive:start_moive+success_cnt,]
x<-target_file
#x
x<-cbind(x,head(all.review_cnt,n=success_cnt))
x<-cbind(x,head(all.keyword_cnt,n=success_cnt))

colnames(x)<-c('code','movie_title','point','review_cnt','keyword_cnt')
write.csv(x,'C:\\Users\\CS3-10\\Documents\\GitHub\\R-study\\final_list.csv')
