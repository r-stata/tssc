********************************************************************************
*! SUBSET: Stata command to perform "regression subset selection using R" 
*! Cerulli, V.4, 23mar2020
********************************************************************************
program define subset
     syntax [anything] [if] [in] [pw] , ///
	 model(string) rversion(string) nvmax(numlist max=1 integer) index_values(string) matrix_results(string) optimal_vars(string)
	 version 15
	 marksample touse
	 local var `anything' if `touse'
********************************************************************************
     local dir `c(pwd)'
	 cd "`dir'"
********************************************************************************
	 qui export delimited `var' using "mydata.csv", nolabel replace 
********************************************************************************
     subset_1 , nvmax(`nvmax') index_values(`index_values') matrix_results(`matrix_results') optimal_vars(`optimal_vars') model(`model') // R code 
********************************************************************************
	 runR , rversion(`rversion')
********************************************************************************	 
end 
********************************************************************************

********************************************************************************
capture program drop subset_1
********************************************************************************
program subset_1  // this does the most extended tree (baseline)
syntax , nvmax(numlist max=1 integer) index_values(string) matrix_results(string) optimal_vars(string) model(string)
// Write R Code
// dependencies: foreign
local A=`nvmax'
local B="`index_values'"
if "`model'" == "best_subset"{
local C=1
}
else if "`model'" == "backward"{
local C=2
}
else if "`model'" == "forward"{
local C=3
}
********************************************************************************
quietly: file open rcode using mysubset.R , write replace
quietly: file write rcode ///
    `"list.of.packages <- c("foreign","MASS","ISLR","leaps","plyr")"' _newline ///
    `"new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]"' _newline ///
    `"if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')"' _newline ///
	`"library("foreign")"' _newline ///
	`"# Loading the data"' _newline ///
	`"library(foreign)"' _newline ///
	`"my_data <- read.csv("mydata.csv", sep=",")"' _newline ///
	`"WD <- getwd()"' _newline ///
	`"setwd(WD)"' _newline ///
	`"data<-as.data.frame(my_data)"' _newline ///
	`"y <- data[,1]"' _newline ///
	`"x <- data[2:ncol(my_data)]"' _newline ///
	`"data <-cbind(y,x)"' _newline ///
	`"# Load libraries"' _newline ///
	`"library(MASS)"' _newline ///
	`"library(plyr)"'_newline ///
    `""'_newline ///
	///
    `"##########################################################################"'_newline ///
	`"# Fit 'Best Subset Selection'"' _newline ///
	`"##########################################################################"'_newline ///
	///
	`""'_newline ///
	`"library(ISLR)"'_newline ///
	`"attach(data)"'_newline ///
	`"names(data)"'_newline ///
	`"dim(data)"'_newline ///
	`"library(leaps)"'_newline ///
	`"##########################################################################"'_newline ///
	`"K <-`C'"'_newline ///	
	`"K"'_newline ///
	`"if (K==1){"'_newline ///
	`"regfit.full=regsubsets(y~.,data=data,nvmax=19)"'_newline ///
	`"}"'_newline /// 
	`"if (K==2) {"'_newline ///
	`"regfit.full=regsubsets(y~.,data=data,nvmax=19,method="backward")"'_newline ///
	`"}"'_newline /// 
	`"if (K==3){"'_newline ///
	`"regfit.full=regsubsets(y~.,data=data,nvmax=19,method="forward")"'_newline ///
	`"}"'_newline ///
	`"##########################################################################"'_newline ///
	`"reg.summary=summary(regfit.full)"'_newline ///
    `""'_newline ///
	///
    `"##########################################################################"'_newline ///
	`"# Summary of results for Best Subset Selection"' _newline ///
	`"##########################################################################"'_newline ///
	///
	`""'_newline ///
	`"reg.summary"' _newline ///
	`"##########################################################################"'_newline ///
	`""'_newline ///
	`"attach(reg.summary)"' _newline ///
    `"names(reg.summary)"'_newline ///
	`"A <- as.data.frame(reg.summary[1])"'_newline ///
	`"write.dta(A, "`matrix_results'.dta")"'_newline ///
	`"par(mar=c(1,1,1,1))"'_newline ///
	`"plot(regfit.full,scale="r2")"'_newline ///
	`"par("mar")"'_newline ///
	`"plot(regfit.full,scale="adjr2")"'_newline ///
	`"plot(regfit.full,scale="Cp")"'_newline ///
	`"plot(regfit.full,scale="bic")"'_newline ///
	`""'_newline ///
	`""'_newline ///
	`"##########################################################################"'_newline ///
	`"# Optimal model according to the Adjusted-R2 criterion"'_newline ///
	`"##########################################################################"'_newline ///
	`"coef(regfit.full,which.max(adjr2))"'_newline ///
	`"A1 <- coef(regfit.full,which.max(adjr2))"'_newline /// 
	`"B1<-names(A1)"'_newline ///
	`"C1<-length(B1)"'_newline ///
	`"Adjr2=B1[2:C1]"'_newline ///
	`"y1 <- matrix(Adjr2, nrow=C1-1, ncol=1)"'_newline ///
	`"plot(adjr2,xlab="Number of Variables",ylab="Adjusted-R2",type="b")"'_newline ///
	`"##########################################################################"'_newline ///
	`""'_newline ///
	`""'_newline ///
	`"##########################################################################"'_newline ///
	`"# Optimal model according to the Cp criterion"'_newline ///
	`"##########################################################################"'_newline ///
	`"coef(regfit.full,which.min(cp))"'_newline ///
	`"A2 <- coef(regfit.full,which.min(cp))"'_newline ///
	`"B2<-names(A2)"'_newline ///
	`"C2<-length(B2)"'_newline ///
	`"CP=B2[2:C2]"'_newline ///
	`"y2 <- matrix(CP, nrow=C2-1, ncol=1)"'_newline ///
	`"plot(cp,xlab="Number of Variables",ylab="Cp",type="b")"'_newline ///
	`"##########################################################################"'_newline ///
	`""'_newline ///
	`""'_newline ///
	`"##########################################################################"'_newline ///
	`"# Optimal model according to the BIC criterion"'_newline ///
	`"##########################################################################"'_newline ///
	`"coef(regfit.full,which.min(bic))"'_newline ///
	`"A3 <- coef(regfit.full,which.min(bic))"'_newline ///  
	`"B3<-names(A3)"'_newline ///
	`"C3<-length(B3)"'_newline ///
	`"BIC=B3[2:C3]"'_newline ///
	`"y3 <- matrix(BIC, nrow=C3-1, ncol=1)"'_newline ///
	`"plot(bic,xlab="Number of Variables",ylab="BIC",type="b")"'_newline ///
	`"##########################################################################"'_newline ///
	`"matLis <- list(y1,y2,y3)"'_newline /// 
	`"n <- max(sapply(matLis, nrow))"'_newline /// 
	`"H <- do.call(cbind, lapply(matLis, function (x) rbind(x, matrix(, n-nrow(x), ncol(x)))))"'_newline /// 
	`"H <- as.data.frame(H)"'_newline ///
	`"names(H) <- c("AdjR2", "CP", "BIC")"'_newline ///
	`"write.dta(H, "`optimal_vars'.dta")"'_newline ///
	`"##########################################################################"'_newline ///
	`""'_newline ///
	`""'_newline ///
	`"Q2 <- as.data.frame(reg.summary[[2]])"'_newline ///
	`"Q3 <- as.data.frame(reg.summary[[3]])"'_newline ///
	`"Q4 <- as.data.frame(reg.summary[[4]])"'_newline ///
	`"Q5 <- as.data.frame(reg.summary[[5]])"'_newline ///
	`"Q6 <- as.data.frame(reg.summary[[6]])"'_newline ///
	`"`index_values' <- cbind(Q2,Q3,Q4,Q5,Q6)"'_newline ///
	`"`index_values' <- rename(`index_values',c("reg.summary[[2]]"="RSQ",  "'_newline ///
							`"	"reg.summary[[3]]"="RSS",    "'_newline ///
							`"	"reg.summary[[4]]"="adjR2",  "'_newline ///
							`"	"reg.summary[[5]]"="CP",     "'_newline ///
							`"	"reg.summary[[6]]"="BIC"))   "'_newline ///
	`"ID = seq(dim(`index_values')[1]) "'_newline ///
	`"`index_values' <- cbind(`index_values',ID)"'_newline ///
	`"write.dta(`index_values', "`index_values'.dta")"' 
quietly: file close rcode
end
********************************************************************************

********************************************************************************
capture program drop runR
********************************************************************************
program define runR
syntax , rversion(string)
********************************************************************************
// Run R from Stata
********************************************************************************
local using `"mysubset.R"'
********************************************************************************
* MAC
if "`c(os)'" == "MacOSX" {
local rpath    `"/Library/Frameworks/R.framework/Resources/bin/R"'
local roptions `"--slave"'
}
********************************************************************************
* PC
else{
local rpath `"C:\Program Files\R\R-`rversion'\bin\x64\Rterm.exe"'
local roptions `"--vanilla"'
}
********************************************************************************
tempfile tempsource templis
copy `"`using'"' `"`tempsource'"'
local Rcommand `""`rpath'" `roptions' < "`tempsource'" > "`templis'""'
shell `Rcommand'
********************************************************************************
// Type R output in Stata
********************************************************************************
disp _n as text "--> Beginning of R output from source file: " as result `"`using'"'
type `"`templis'"'
disp _n as text "--> End of R output from source file: " as result `"`using'"'
********************************************************************************
end
********************************************************************************