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

#library()
#영화 목록파일을 직접 선택
csv_file<-read.csv("C:\\Users\\CS3-10\\Documents\\GitHub\\graduation-work\\movie_list02.csv",header = T,sep=',',stringsAsFactors = F)

csv_file<-csv_file%>%
  select(-X)


movie_codes<-c()
movie_data2<-c()


defalut_address1<-'C:\\Users\\CS3-10\\Documents\\GitHub\\graduation-work\\movie_reviews_list\\'
defalut_address2<-'.csv'
write_address1<-'C:\\Users\\CS3-10\\Documents\\GitHub\\graduation-work\\movie_keyword_list\\'
write_address2<-'.csv'

useSejongDic()
buildDictionary(ext_dic='sejong',user_dic = data.frame(readLines("addNoun.txt"), "ncn"))

for(i in 1:length(csv_file$code)){
  movie_codes<-c(movie_codes,csv_file$code[i])
}
#movie_codes
#length(movie_codes)
for(j in 1:length(movie_codes)){
address=NULL
address<-paste(defalut_address1,movie_codes[j],defalut_address2,sep='')
#address<-paste(defalut_address1,movie_codes[45],defalut_address2,sep='')
movie_data2<-read.csv(address,header = T,stringsAsFactors = F)
movie_data2<-movie_data2%>%
  select(reviews)

nouns <- sapply(movie_data2, extractNoun, USE.NAMES = F)
#nouns<-extractNoun(movie_data2[,1])
#nouns
wordcount<-table(unlist(nouns))
#wordcount
df_word<-as.data.frame(wordcount,stringsAsFactors = F)
df_word<-filter(df_word,nchar(Var1)>=2)
top40<-df_word%>%
  arrange(desc(Freq))%>%
  head(40)
#top40

write_address=NULL

write_address<-paste(write_address1,movie_codes[j],write_address2,sep='')
#write_address<-paste(write_address1,movie_codes[1],write_address2,sep='')
write.csv(top40,write_address,row.names=FALSE)
}
