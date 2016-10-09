#Gets the state ids from twitter
source("~/R/RTwitterAPI/R/twitter_api_call.R");
#library(RTwitterAPI)
load("~/R/getcreds.R")

as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}

fetchfromtwitter <- function(url,query=c()){
  count <- 15
  retvalue <- twitter_api_call(url,query,params)
  print(retvalue)
  while (retvalue == '{\"errors\":[{\"message\":\"Rate limit exceeded\",\"code\":88}]}')
  {
    print("Rate limit reached, waiting")
    print(count)
    print("minutes")
    Sys.sleep(60)
    retvalue <- twitter_api_call(url,query,params)
  }
  return(retvalue)
}

get_state_geocodes <- function(){
  statecoords <- read.csv2("~/R/statecoords",sep="\t", header=TRUE);
  
  url <- "https://api.twitter.com/1.1/geo/reverse_geocode.json";
  
  stategeo <- c()
  
  for (i in 1:51) {
    state <- statecoords[i:i,c('State')]
    latitude <- statecoords[i:i,c('Latitude')]
    longitude <- statecoords[i:i,c('Longitude')]
    query <- c(lat=as.numeric.factor(latitude),long=as.numeric.factor(longitude),granularity="admin")
    retvalue <- fetchfromtwitter(url,query)
    tempstate <- c('State'=statecoords$State[i],'geocode'=retvalue)
    stategeo <- c(tempstate,stategeo)
  };
  
  save(stategeo,file="~/R/stategeocodes.R",ascii=TRUE);
  
}

show_tweet <- function(id)
{
  url = "https://api.twitter.com/1.1/statuses/show.json"
  return fetchfromtwitter(url,c("id"=id))
}

find_tweets <- function(query) {
  url = "https://api.twitter.com/1.1/search/tweets.json";
  return(fetchfromtwitter(url,query));
}

tweet_per_state <- function(query){
  read("/R/")
  
}