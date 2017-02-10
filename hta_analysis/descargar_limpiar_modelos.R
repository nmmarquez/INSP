rm(list=ls())

# load the packages rdrop and data table
pacman::p_load(rdrop2, data.table, readstata13, INSP)

add1 <- function(x){
    return(x + 1)
}

read_drop_dta <- function(file_to_dta){
    tok <- load_token()
    file_temp <- tempfile() # temp file to download to
    drop_get(file_to_dta, file_temp, dtoken=tok) # download the data to memory
    dta_df <- read.dta13(file_temp) #translate to r data frame
    unlink(file_temp) # get rid of the file in memory
    return(dta_df)
}

tok <- load_token()
model_dir <- "/ANALÍSIS SIC-MIDO/1 BASES DE DATOS/Margins"
model_dir
model_path <- drop_dir(model_dir, dtoken=tok)$path
model_path <- grep("_corr.", model_path, value=TRUE)

# apply
df_list <- lapply(model_path, read_drop_dta)
class(df_list)

#
fnames <- sapply(strsplit(model_path, "/"), function(x) x[5])
model_type <- sapply(strsplit(fnames, "_"), function(x) x[1])

for(i in 1:length(df_list)){
    df_list[[i]]$model_type <- model_type[i]
    df_list[[i]]$model_number <- i
    df_list[[i]]$model_name <- gsub(".dta", "", fnames[i])
}

DT <- rbindlist(df_list, fill=T)
DT$edad <- 22
DT$sexo <- "ambos"
DT$GEOID <- DT$cod_mun

fwrite(DT, "~/Documents/INSP/hta_analysis/hta_visual/models/models_limpia.csv")
