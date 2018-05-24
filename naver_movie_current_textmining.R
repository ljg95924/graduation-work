###
#영화 키워드 추출
rm(list=ls())# 변수 다삭제
options(mc.cores=1) # 단일 Core 만 활용하도록 변경 (옵션), 윈도에서는 멀티코어 사용시 Java와 충돌하므로 코어 수를 1로 고정
Sys.setlocale("LC_COLLATE", "ko_KR.UTF-8");
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
csv_file<-read.csv("C:\\Users\\CS3-10\\Documents\\GitHub\\graduation-work\\movie_list02.csv",header = T,sep=',',stringsAsFactors =  F)
csv_file<-csv_file%>%
  select(-X)
movie_codes<-c()
movie_data2<-c()


#defalut_address1<-'C:\\Users\\CS3-10\\Documents\\GitHub\\graduation-work\\movie_reviews_list\\'
defalut_address1<-'C:\\Users\\CS3-10\\Documents\\GitHub\\graduation-work\\movie_review_list\\'
defalut_address2<-'.csv'



write_address1<-'C:\\Users\\CS3-10\\Documents\\GitHub\\graduation-work\\movie_keyword_list\\'
write_address2<-'.csv'

#useSejongDic()
#buildDictionary(ext_dic='sejong',user_dic = data.frame(readLines("addNoun.txt"), "ncn"))

for(i in 1:length(csv_file$code)){
  movie_codes<-c(movie_codes,csv_file$code[i])
}

#movie_codes
#length(movie_codes)
for(j in 1:length(movie_codes)){
useSejongDic()
buildDictionary(ext_dic='sejong',user_dic = data.frame(readLines("addNoun.txt"), "ncn"))

address=NULL
address<-paste(defalut_address1,movie_codes[j],defalut_address2,sep='') #for문

#address<-paste(defalut_address1,151196,defalut_address2,sep='') #test용

#Encoding(movie_data2)<-"UTF-8"
movie_data2<-read.csv(address,header = T,stringsAsFactors = F)
#movie_data2<-read.table(address,header=F,sep="",stringsAsFactors = F)

#movie_data2
movie_data2<-movie_data2%>%
  select(reviews)
nouns <- sapply(movie_data2, extractNoun, USE.NAMES = F)
#nouns<-extractNoun(movie_data2[,1])
#nouns
wordcount<-table(unlist(nouns))
#wordcount
df_word<-as.data.frame(wordcount,stringsAsFactors = F)
df_word<-filter(df_word,nchar(Var1)>=2)
top150<-df_word%>%
  arrange(desc(Freq))%>%
  head(150)
top150
addre<-paste(write_address1,movie_codes[j],write_address2,sep='')
write.csv(top150,addre)
}
###---- wordcloud
library(wordcloud)
library(RColorBrewer)
wordcloud(words=top150$Var1,freq=top150$Freq,min.freq = 5,random.order=F,rot.per = 0.1, colors = brewer.pal(8, "Dark2"))

###---- wordcloud

###---- plot
library(ggplot2)
library(plotly)
top40<-top150%>%
  head(40)

p<-ggplot(data=top40,aes(x=reorder(Var1,-Freq),y=Freq))+geom_col(position='dodge')+theme(axis.text.x = element_text(angle = 60, hjust = 1))
ggplotly(p)

ggplot(data=top40,aes(x=reorder(Var1,-Freq),y=Freq))+geom_col()+theme(axis.text.x = element_text(angle = 60, hjust = 1))
###---- plot

#Sys.getlocale()
#Sys.setlocale("LC_ALL", "en_US.UTF-8") 
Encoding(top40[1,1])
library(RMySQL)
library(rJava)
library(RJDBC) # rJava에 의존적이다.
drv <- JDBC(driverClass="com.mysql.jdbc.Driver", 
            classPath="C:\\mysql-connector-java-5.1.46-bin.jar")
con <- dbConnect(MySQL(), host = "127.0.0.1", dbname = "test",
                 user = "root", password = "1122", port = 3306)
###
query<-'select * from test'
dbGetQuery(con,query)
dbSendQuery(con,'insert into test values(45,"앙기로미",99)')
dbGetQuery(con,'select * from test')
###
dbWriteTable(con,"test",top40,overwrite=T)

###
rs <- dbSendQuery(con, 'set character set utf8')
dbSendQuery(con, "SET character_set_client=euckr;")
dbSendQuery(con, "SET character_set_connection=euckr;")
dbSendQuery(con, "SET character_set_results=euckr;")
dbGetQuery(con, "SHOW VARIABLES LIKE 'character_set_%';")
dbGetQuery(con, "set names 'euckr'")
dbWriteTable(con, value = accent_UTF8,name = "default_UTF8",row.names=FALSE,overwrite=TRUE )
dbWriteTable(con,"abccc",top40,overwrite=T)
a<-dbReadTable(con,'abccc')
a
Encoding(a[,1])<-"UTF-8"
Encoding(a[,1])
dbListTables(con) 
install.packages('RODBC')
library(RODBC)
conn<-odbcConnect(dsn='localhost',uid='root',pwd='1122',DBMSencoding='UTF-8')


library(DBI)
library(rJava)
library(RJDBC)
drv <- JDBC(driverClass="com.mysql.jdbc.Driver", 
            classPath="C:\\mysql-connector-java-5.1.46-bin.jar")
###---- csv save 
write_address=NULL

#write_address<-paste(write_address1,movie_codes[j],write_address2,sep='')
write_address<-paste(write_address1,movie_codes[1],write_address2,sep='')
write.csv(top150,write_address,row.names=FALSE)
###---- csv save
}
