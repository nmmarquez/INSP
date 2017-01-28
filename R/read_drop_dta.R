#' Read a dropbox dta file
#'
#' @description Read a dropbox dta file by pulling it into a temp file and
#' using readstata13 to parse it into a data frame
#'
#' @return data frame object read from dropbox dta file path
#' 
#' @export

read_drop_dta <- function(file_to_dta){
    library(rdrop2)
    library(httpuv)
    library(readstata13)
    token <- load_token()
    file_temp <- tempfile() # temp file to download to
    drop_get(file_to_dta, file_temp, dtoken=token) # download the data to memory
    dta_df <- read.dta13(file_temp) #translate to r data frame
    unlink(file_temp) # get rid of the file in memory
    return(dta_df)
}