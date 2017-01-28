#' Load all models from a drop_box designated location
#'
#' @description Loads all the dta file paths from a designated location
#'
#' @return named character vector of file paths
#' 
#' @export

model_path <- function(home="/ANALÍSIS SIC-MIDO/1 BASES DE DATOS/Margins"){
    library(rdrop2)
    library(httpuv)
    token <- load_token()
    { sink("/dev/null"); paths <- drop_dir(home, dtoken=token)$path; sink(); }
    x <- strsplit(paths, split="/")
    x <- sapply(x, function(x) strsplit(x[length(x)], split="\\.")[[1]][1])
    names(paths) <- x
    return(paths)
}
