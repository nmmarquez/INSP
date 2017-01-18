pacman::p_load(rdrop2)

load_token <- function(){
    if(!file.exists("~/.droptoken.rds")){
        # interactive step!!! if its not there youll need to accept in a browser
        token <- drop_auth()
        saveRDS(token, "~/.droptoken.rds")
    }
    token <- readRDS("~/.droptoken.rds")
    return(token)
}