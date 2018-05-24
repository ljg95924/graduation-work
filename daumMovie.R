#install.packages('qgraph')
library(rvest)
library(httr)
library(KoNLP)
library(stringr)
library(tm)
library(qgraph)
library(xml2)

url_base <- 'http://movie.daum.net/moviedb/grade?movieId=99056&type=netizen&page='   # 크롤링 대상 URL

all.reviews <- c() 

for(page in 1:500){    ## 500페이지 까지만 수집 (본인이 나름대로 설정하면 됨) 
  
  url <- paste(url_base, page, sep='')   #url_base의 뒤에 페이지를 1~500 까지 늘리면서 접근
  
  htxt <- read_html(url)                       # html 코드 불러오기
  
  comments <- html_nodes(htxt, 'div') %>% html_nodes('p')  ## comment 가 있는 위치 찾아 들어가기 
  
  reviews <- html_text(comments)               # 실제 리뷰의 text 파일만 추출
  
  reviews <- repair_encoding(reviews, from = 'utf-8')  ## 인코딩 변경
  
  if( length(reviews) == 0 ){ break }                              #리뷰가 없는 내용은 제거
  
  reviews <- str_trim(reviews)                                      # 앞뒤 공백문자 제거
  
  all.reviews <- c(all.reviews, reviews)                          #결과값 저장
  
}
head(all.reviews)
##불필요 내용 필터링
all.reviews <- all.reviews[!str_detect(all.reviews,"평점")]   # 수집에 불필요한 단어가 포함된 내용 제거
Encoding(all.reviews)
options(encoding="utf-8")

## 명사/형용사 추출 함수 생성
ko.words <- function(doc){
  d <- as.character(doc)
  pos <- paste(SimplePos09(d))
  extracted <- str_match(pos, '([가-힣]+)/[NP]')
  keyword <- extracted[,2]
  keyword[!is.na(keyword)]
  
}

options(mc.cores=1)    # 단일 Core 만 활용하도록 변경 (옵션), 윈도에서는 멀티코어 사용시 Java와 충돌하므로 코어 수를 1로 고정

cps <- Corpus(VectorSource(all.reviews))  

#inspect(cps)
tdm <- TermDocumentMatrix(cps,   
                          control=list(tokenize=ko.words   ## token 분류시 활용할 함수명 지정
                          #removePunctuation=T,
                          #removeNumbers=T,
                          #wordLengths=c(2, 6),  
                          #weighting=weightBin
                          ))  
tdm

cps<-tm_map(cps,removePunctuation)
tdm<-TermDocumentMatrix(cps,
                        control = list(wordLengths=c(2,Inf)))

Encoding(tdm$dimnames$Terms)='UTF-8'
findFreqTerms(tdm,lowfreq = 10)
#최종결과 확인
dim(tdm)

tdm_matrix <- as.matrix(tdm)
as.matrix(tdm)
tdm_matrix
Encoding(rownames(tdm.matrix))<-"utf-8"
rownames(tdm_matrix)[1:100]
Encoding(rownames(tdm_matrix))


word.count <- rowSums(tdm_matrix)  ##각 단어별 합계를 구함

word.order <- order(word.count, decreasing=T)  #다음으로 단어들을 쓰인 횟수에 따라 내림차순으로 정렬

freq.words <- tdm.matrix[word.order[1:20], ] #Term Document Matrix에서 자주 쓰인 단어 상위 20개에 해당하는 것만 추출

co.matrix <- freq.words %*% t(freq.words)  #행렬의 곱셈을 이용해 Term Document Matrix를 Co-occurence Matrix로 변경



qgraph(co.matrix,
       
       labels=rownames(co.matrix),   ##label 추가
       
       diag=F,                       ## 자신의 관계는 제거함
       
       layout='spring',              ##노드들의 위치를 spring으로 연결된 것 처럼 관련이 강하면 같이 붙어 있고 없으면 멀리 떨어지도록 표시됨
       
       edge.color='blue',
       
       vsize=log(diag(co.matrix))*2) ##diag는 matrix에서 대각선만 뽑는 것임. 즉 그 단어가 얼마나 나왔는지를 알 수 있음. vsize는 그 크기를 결정하는데 여기 인자값으로 단어가 나온 숫자를 넘겨주는 것임. log를 취한것은 단어 크기의 차이가 너무 커서 log를 통해서 그 차이를 좀 줄여준것임. 



