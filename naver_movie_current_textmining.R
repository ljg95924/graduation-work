rm(list=ls())# 변수 다삭제 
#install.packages('KoNLP')
#install.packages('rJava')
#install.packages('memoise')
#install.packages('KoNLP')
#install.packages("rvest")
library(rvest)
library(XML)
library(stringr)
library(dplyr)
library(KoNLP)

useNIADic()
#library()
#영화 목록파일을 직접 선택
csv_file<-read.csv("C:\\Users\\CS3-10\\Documents\\GitHub\\graduation-work\\movie_list02.csv",header = T,sep=',',stringsAsFactors = F)

csv_file<-csv_file%>%
  select(-X)


movie_codes<-c()
movie_data<-c()
movie_data2<-c()
movie_data3<-c()
for(i in 1:length(csv_file$code)){
  movie_codes<-c(movie_codes,csv_file$code[i])
}
#for(j in 1:length(movie_codes)){
address=NULL
defalut_address1<-'C:\\Users\\CS3-10\\Documents\\GitHub\\graduation-work\\movie_review_list\\'
defalut_address2<-'.csv'
#address<-paste(defalut_address1,movie_codes[j],defalut_address2,sep='')
address<-paste(defalut_address1,movie_codes[1],defalut_address2,sep='')
movie_data2<-read.csv(address,header = T,stringsAsFactors = F)
movie_data2<-movie_data2%>%
  select(-X)
#movie_data2
#summarise(movie_data2)
#movie_data<-c(movie_data,movie_data2)
#print(address)
#guess_encoding(movie_data2)
#movie_data2<-iconv(movie_data2, from="EUC-KR", to="UTF8")
#movie_data2 <- repair_encoding(movie_data2, from = 'utf-8')  
#movie_data2<-str_replace_all(movie_data2,'\\D',' ')
nouns<-extractNoun(movie_data2[,1])
nouns
wordcount<-table(unlist(nouns))
wordcount
df_word<-as.data.frame(wordcount,stringsAsFactors = F)
df_word<-filter(df_word,nchar(Var1)>=2)
top20<-df_word%>%
  arrange(desc(Freq))%>%
  head(40)
top20
library(wordcloud)
library(RColorBrewer)
pal<-brewer.pal(8,'Dark2')
set.seed(1234)
wordcloud(words=df_word$Var1, #단어
          freq=df_word$Freq,  #빈도
          min.freq = 2, #최소단어빈도
          max.words=200, #표현 단어 수
          random.order = F, #고빈도 단어 중앙 배치
          rot.per=.1, #회전 단어 비율
          scale=c(4,0.3), #단어 크기 범위
          colors = pal) #색상목록
}
length(movie_data)
as.data.frame(movie_data)

class(movie_data)
summarise(movie_data)
movie_data
#movie_data<-movie_data%>%
#  select(-X)

movie_data3<-str_replace_all(movie_data,'\\W',' ')
length(movie_data3)
movie_data3
