rm(list=ls())
pacman::p_load(RMySQL)
source(paste0(dirname(sys.frame(1)$ofile), "/query_calls.R"))

cause_df <- query_wrapper(cause_list_call)
cause_list <- paste0(cause_df$cause_id, collapse=", ")

cod_df <- query_wrapper(gsub("\\{}", cause_list, cod_call_raw))
