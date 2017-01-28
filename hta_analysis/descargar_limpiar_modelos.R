rm(list=ls())

# load the packages rdrop and data table
pacman::p_load(rdrop2, data.table, readstata13)

add1 <- function(x){
    return(x + 1)
}

read_drop_dta <- function(file_to_dta){
    file_temp <- tempfile() # temp file to download to
    drop_get(file_to_dta, file_temp) # download the data to memory
    dta_df <- read.dta13(file_temp) #translate to r data frame
    unlink(file_temp) # get rid of the file in memory
    return(dta_df)
}

model_dir <- "/ANALÍSIS SIC-MIDO/1 BASES DE DATOS/Margins"
model_dir
model_path <- drop_dir(model_dir)$path
model_path[2]



# mal!!!!
df_list <- as.list(1:length(model_path))
df_list[[1]] <- read_drop_dta(model_path[1])
df_list[[2]] <- read_drop_dta(model_path[2])
df_list[[3]] <- read_drop_dta(model_path[3])
df_list[[4]] <- read_drop_dta(model_path[4])

# loop
df_list <- as.list(1:length(model_path)) # create a list with four things
for(i in 1:length(model_path)){ # loop from 1 to the number of files we have
    print(i) # print our number
    df_list[[i]] <- read_drop_dta(model_path[i])
}

# apply
df_list <- lapply(model_path, read_drop_dta)
class(df_list)

#
sqrt(4)
sapply(1:10, sqrt)
lapply(1:10, add1)
