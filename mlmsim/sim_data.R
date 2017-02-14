rm(list=ls())
pacman::p_load(INSP, data.table, TMB)
set.seed(123)

N <- nrow(mx.sp.df@data)
b0 <- -4.4
b1 <- .3

mx.sp.df@data <- as.data.table(mx.sp.df@data)

mx.sp.df@data[,V1:=rnorm(N)]
mx.sp.df@data[,pop:=sample(120:100000, N, replace=T)]
mx.sp.df@data[,yobs:=rpois(N, exp(b0 + b1 * V1) * pop)]

statedf <- mx.sp.df@data[,lapply(list(pop, yobs), sum), by=CVE_ENT]
setnames(statedf, c("V1", "V2"), c("pop", "yobs")) 

statedf[,ID:=as.numeric(CVE_ENT) - 1]
mx.sp.df@data[,ID:=as.numeric(CVE_ENT) - 1]


setwd("~/Documents/INSP/mlmsim/")
model <- "sim_data"
if (file.exists(paste0(model, ".so"))) file.remove(paste0(model, ".so"))
if (file.exists(paste0(model, ".o"))) file.remove(paste0(model, ".o"))
if (file.exists(paste0(model, ".dll"))) file.remove(paste0(model, ".dll"))
compile(paste0(model, ".cpp"))

Data <- list(state_yobs=statedf$yobs, pop=mx.sp.df$pop, V1=mx.sp.df$V1,
             state_id_vec=mx.sp.df$ID)
Params <- list(b0=0, b1=0)
dyn.load(dynlib(model))
Obj <- MakeADFun(data=Data, parameters=Params, DLL=model)
system.time(Opt <- nlminb(start=Obj$par, objective=Obj$fn, gradient=Obj$gr))
# user   system  elapsed 
# 1128.412   10.468 1140.782 
Report <- Obj$report()
Opt$convergence

Report$b0
Report$b1

Report <- sdreport(Obj, getJointPrecision = T)
Report$cov.fixed
