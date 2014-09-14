library(jsonlite);
library(RCurl);

source("./oauth1_signature.R");

# GET request to the API
# https://dev.twitter.com/docs/auth/authorizing-request

twitter_api_call <- function(url, api, params, print_result=FALSE, use_cygwin=FALSE, cygwin_bash="c:\\cygwin64\\bin\\bash.exe") {
  if(is.na(params["oauth_timestamp"])) {
    params["oauth_timestamp"] <- as.character(as.integer(Sys.time()));
  }
  
  if(is.na(params["oauth_nonce"])) {
    params["oauth_nonce"] <- sprintf("%d%s",as.integer(Sys.time()),paste(floor(runif(6)*10^6),collapse=""));
  }
  
  params["oauth_signature"] <- oauth1_signature(method = "GET", url, api, params);
  
  httpheader <- c(
    "Authorization" = sprintf(paste(c(
      'OAuth oauth_consumer_key="%s", oauth_nonce="%s", oauth_signature="%s", ',
      'oauth_signature_method="%s", oauth_timestamp="%s", oauth_token="%s", oauth_version="1.0"'),
      collapse=""),
      params["oauth_consumer_key"], params["oauth_nonce"], params["oauth_signature"],
      params["oauth_signature_method"], params["oauth_timestamp"], params["oauth_token"], params["oauth_version"])
  );
  
  q <- paste(paste(names(api),api,sep="="), collapse="&");
  urlq <- paste(url,q,sep="?");
  
  if(!use_cygwin) {
    result <- getURL(urlq, httpheader=httpheader);
  } else {
    httpheader_escaped <- sprintf("Authorization: %s",gsub('"','\"',httpheader["Authorization"]))
    cmd <- sprintf("%s -c \"/usr/bin/curl --silent --get '%s' --data '%s' --header '%s'\"", cygwin_bash, url, q, httpheader_escaped)
    result <- system(cmd)
  }
  
  if(print_result) {
    cat(prettify(result));
  }
  
  return(result);
}