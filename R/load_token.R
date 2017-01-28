#' Load a dropbox token for use in repeated dropbox calls
#'
#' @description Loads a file that is a dropbox key such that credentials need
#' not be inputted on every new session. If no key exists yet one is created 
#' by asking for credentials.
#'
#' @return token object which can be used for passwordless rdrop2 calls
#' 
#' @export

load_token <- function(){
    library(rdrop2)
    library(httpuv)
    if(!file.exists("~/.droptoken.rds")){
        # interactive step!!! if its not there youll need to accept in a browser
        token <- drop_auth()
        saveRDS(token, "~/.droptoken.rds")
    }
    token <- readRDS("~/.droptoken.rds")
    return(token)
}
