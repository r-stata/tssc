********************************************************************************
*! SCTREE: Stata command to perform a "classification tree using R called into Stata" 
********************************************************************************
* Version: 18
* Date: 06-05-2020
* Author: Giovanni Cerulli
********************************************************************************
program define sctree
     syntax [anything] [if] [in] [pw] , ///
	 model(string) rversion(string) [in_samp_data(string) out_samp_data(string) prune(numlist max=1 integer) cv_tree ///
	 mtry(numlist max=1 integer) ntree(numlist max=1 integer) inter_depth(numlist max=1 integer) shrinkage(numlist max=1) pdp(string) seed(numlist max=1) prediction(string)]
	 version 15
	 marksample touse
	 local var `anything' if `touse'
********************************************************************************
     local dir `c(pwd)'
	 cd "`dir'"
********************************************************************************
	 qui export delimited `var' using "mydata.csv", nolabel replace 
********************************************************************************
     if "`model'" == "tree" & "`prune'" == "" & "`cv_tree'" == "" & "`prediction'" == ""{
	 mytree1 , in_samp_data(`in_samp_data') out_samp_data(`out_samp_data') seed(`seed') // R code 
	 }
	 else if "`model'" == "tree" & "`prune'" != "" & "`cv_tree'" == "" & "`prediction'" == ""{
	 mytree2 , prune(`prune') in_samp_data(`in_samp_data') // R code
	 }
	 else if "`model'" == "tree" & "`prune'" == "" & "`cv_tree'" != "" & "`prediction'" == ""{
	 mytree3 , out_samp_data(`out_samp_data') seed(`seed') // R code
	 }
	 else if "`model'" == "randomforests" & "`prediction'" == ""{
	 mytree4 , mtry(`mtry') ntree(`ntree') in_samp_data(`in_samp_data') out_samp_data(`out_samp_data') seed(`seed') // R code
	 }
	 else if "`model'" == "boosting1" & "`prediction'" == ""{
	 mytree5 , inter_depth(`inter_depth') ntree(`ntree') shrinkage(`shrinkage') pdp(`pdp') in_samp_data(`in_samp_data') out_samp_data(`out_samp_data') seed(`seed') // R code
	 }
	 else if "`model'" == "boosting2" & "`prediction'" == ""{
	 mytree6 , inter_depth(`inter_depth') ntree(`ntree') shrinkage(`shrinkage') pdp(`pdp') in_samp_data(`in_samp_data') out_samp_data(`out_samp_data') seed(`seed') // R code
	 }
	 else if "`model'" == "tree" & "`prune'" != "" & "`cv_tree'" == "" & "`prediction'" != "" {
	 mytree7 , prune(`prune') out_samp_data(`out_samp_data') prediction(`prediction')  // R code
	 }
	 else if "`model'" == "randomforests" & "`prediction'" != ""{
	 mytree8 , mtry(`mtry') ntree(`ntree') out_samp_data(`out_samp_data') seed(`seed') prediction(`prediction') // R code
	 }
	 else if "`model'" == "boosting1" & "`prediction'" != ""{
	 mytree9 , inter_depth(`inter_depth') ntree(`ntree') shrinkage(`shrinkage') pdp(`pdp') out_samp_data(`out_samp_data') seed(`seed') prediction(`prediction') // R code
	 }
	 else if "`model'" == "boosting2" & "`prediction'" != ""{
	 mytree10 , inter_depth(`inter_depth') ntree(`ntree') shrinkage(`shrinkage') pdp(`pdp') out_samp_data(`out_samp_data') seed(`seed') prediction(`prediction') // R code
	 }	 
	 
	 runR , rversion(`rversion')
********************************************************************************	 
end 

********************************************************************************
program mytree1  // this does the most extended tree (baseline)
syntax , in_samp_data(string) out_samp_data(string) seed(numlist max=1)
// Write R Code
// dependencies: foreign
local S=`seed'
quietly: file open rcode using mytree.R , write replace
quietly: file write rcode ///
    `"list.of.packages <- c("foreign","tree","MASS","ISLR")"' _newline ///
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
	`"library("tree")"' _newline ///
	`"library(MASS)"' _newline ///
	`"library("tree")"'_newline ///
	`"library(MASS)"'_newline ///
	`"# Fit a Regression Tree over the whole training sample"' _newline ///
	`"tree.data=tree(y~.,data)"'_newline ///
	`"summary(tree.data)"'_newline ///
	`"plot(tree.data)"'_newline ///
	`"text(tree.data,pretty=0)"' _newline ///
	`"title(main="Regression Tree over the whole training sample")"' _newline ///
	`"# Estimate the train-MSE"' _newline ///
	`"yhat=predict(tree.data,type="class")"' _newline ///
	`"table(yhat,y)"' _newline ///
	`"y_train=y"' _newline ///
	`"yhat_train=yhat"' _newline ///
	///
	 `"data1 <- as.data.frame(cbind(y_train,yhat_train))"' _newline ///
     `"write.dta(data1, "`in_samp_data'.dta")"' _newline ///
	///
	`"# Estimate the test-MSE at tree size `A'"' _newline ///
	///
	`"attach(data)"'_newline ///
	`"set.seed(`S')"'_newline ///
    `"train = sample(1:nrow(data), nrow(data)/2)"'_newline ///	
	`"data.test=data[-train,]"'  _newline ///
    `"y.test=y[-train]"'  _newline ///
	`"tree.data=tree(y~.,data,subset=train)"'  _newline ///
	`"yhat_test=predict(tree.data,data.test,type="class")"' _newline ///
	`"table(yhat_test,y.test)"'  _newline ///
	`"data2 <- as.data.frame(cbind(yhat_test,y.test))"' _newline ///
    `"write.dta(data2, "`out_samp_data'.dta")"'
quietly: file close rcode
end
********************************************************************************

********************************************************************************
program mytree2   // this does a pruned tree of a given size A 
syntax , prune(numlist max=1 integer) in_samp_data(string)
// Write R Code
// dependencies: foreign
local A=`prune'
quietly: file open rcode using mytree.R , write replace
quietly: file write rcode ///
    `"list.of.packages <- c("foreign","tree","MASS","ISLR")"' _newline ///
    `"new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]"' _newline ///
    `"if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')"' _newline ///
	`"library("foreign")"' _newline ///
	`"# Loading"' _newline ///
	`"library(foreign)"' _newline ///
	`"my_data <- read.csv("mydata.csv", sep=",")"' _newline ///
	`"WD <- getwd()"' _newline ///
	`"setwd(WD)"' _newline ///
	`"data<-as.data.frame(my_data)"' _newline ///
	`"y <- data[,1]"' _newline ///
	`"x <- data[2:ncol(my_data)]"' _newline ///
	`"data <-cbind(y,x)"' _newline ///
	`"# Load libraries"' _newline ///
	`"library("tree")"' _newline ///
	`"library(MASS)"' _newline ///
	`"# Fit a Regression Tree over the whole training sample"' _newline ///
	///
	`"tree.data=tree(y~.,data)"'_newline ///
	`"#summary(tree.data)"'_newline ///
	`"#plot(tree.data, main="")"'_newline ///
	`"#text(tree.data,pretty=0)"' _newline ///
	`"#title(main="Regression Tree over the whole training sample")"' _newline ///
	///
	`"# Grow the pruned at size A"' _newline ///
	///
	`"prune.data=prune.tree(tree.data,best=`A')"'  _newline ///
	`"summary(prune.data)"'_newline ///
    `"plot(prune.data)"' _newline ///
  	`"text(prune.data,pretty=0)"' _newline ///
	`"title(main="Pruned tree over the training sample at size `A'")"' _newline ///
	///
	`"# Estimate the train-MSE at tree size `A'"' _newline ///
	///	
	`"yhat=predict(prune.data,type="class")"' _newline ///
	`"y_train=y"' _newline ///
	`"yhat_train=yhat"' _newline ///
	`"table(yhat_train,y_train)"' _newline ///
	`"data1 <- as.data.frame(cbind(y_train,yhat_train))"' _newline ///
     `"write.dta(data1, "`in_samp_data'.dta")"' _newline ///
	///
	`"# Show the sequence of pruned trees"' _newline ///
	///
	`"attach(tree.data)"'  _newline ///
	`"prune.data.seq=prune.tree(tree.data)"'  _newline ///
	`"summary(prune.data.seq)"'_newline
quietly: file close rcode
end
********************************************************************************

********************************************************************************
program mytree3  // this does the optimal-tree by cross-validation
syntax ,  out_samp_data(string) seed(numlist max=1)
// Write R Code
// dependencies: foreign
local S=`seed'
quietly: file open rcode using mytree.R , write replace
quietly: file write rcode ///
    `"list.of.packages <- c("foreign","tree","MASS","ISLR")"' _newline ///
    `"new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]"' _newline ///
    `"if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')"' _newline ///
	`"library("foreign")"' _newline ///
	`"# Loading"' _newline ///
	`"library(foreign)"' _newline ///
	`"my_data <- read.csv("mydata.csv", sep=",")"' _newline ///
	`"WD <- getwd()"' _newline ///
	`"setwd(WD)"' _newline ///
	`"data<-as.data.frame(my_data)"' _newline ///
	`"y <- data[,1]"' _newline ///
	`"x <- data[2:ncol(my_data)]"' _newline ///
	`"data <-cbind(y,x)"' _newline ///
	`"# Load libraries"' _newline ///
	`"library("tree")"' _newline ///
	`"library(MASS)"' _newline ///
	`"# Fit a Regression Tree over the whole training sample"' _newline ///
	`"# Fit a Regression Tree over the whole training sample"' _newline ///
	`"tree.data=tree(y~.,data)"' _newline ///
	`"yhat=predict(tree.data,type="class")"' _newline ///
	`"# Cross-validation to find the optimal tree size"' _newline ///
	`"set.seed(`S')"' _newline ///
	`"cv.data=cv.tree(tree.data,FUN=prune.misclass)"' _newline ///
	`"attach(cv.data)"' _newline ///
	`"plot(size,dev,type='b', main="Cross-validation: Mean Square Error Vs. Number of Nodes", xlab="Size", ylab="MSE")"' _newline ///
	`"opt.trees = which(dev == min(dev))"' _newline ///
	`"best.leaves = min(size[opt.trees])"' _newline ///
	`"# CV optimal tree size:"' _newline ///
	`"best.leaves"' _newline ///
	`"# CV optimal error rate:"' _newline ///
	`"Test_MSE=min(dev)/nrow(data)"' _newline ///
	`"# Grow the optimal pruned tree"' _newline ///
	`"prune.data.opt=prune.misclass(tree.data,best=best.leaves)"' _newline ///
	`"summary(prune.data.opt)"' _newline ///
	`"plot(prune.data.opt)"' _newline ///
	`"text(prune.data.opt,pretty=0)"' _newline ///
	`"title(main="CV-based optimal tree")"' _newline ///
	`"# Estimate the pruned optimal tree"' _newline ///
	`"prune.data=prune.tree(tree.data,best=best.leaves)"'  _newline ///
	`"yhat=predict(prune.data.opt,type="class")"' _newline ///
	`"data2 <- as.data.frame(cbind(yhat,y,best.leaves,Test_MSE))"' _newline ///
	`"write.dta(data2, "`out_samp_data'.dta")"'
quietly: file close rcode
end
********************************************************************************

********************************************************************************
program mytree4   // bagging and random-forests
syntax , mtry(numlist max=1 integer) ntree(numlist max=1 integer) in_samp_data(string) out_samp_data(string) seed(numlist max=1)
// Write R Code
// dependencies: foreign
local S=`seed'
local A=`mtry'
local B=`ntree'
quietly: file open rcode using mytree.R , write replace
quietly: file write rcode ///
    `"list.of.packages <- c("foreign","tree","MASS","ISLR","randomForest")"' _newline ///
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
	`"library("tree")"' _newline ///
	`"library(MASS)"' _newline ///
	`"library("tree")"'_newline ///
	`"library(MASS)"'_newline ///
	`"library(randomForest)"'_newline ///
	///
	`"# Fit the model by Bagging or Random-forests on the whole sample"' _newline ///
	///
	`"set.seed(`S')"' _newline ///
	`"bag.data=randomForest(y~.,data=data,mtry=`A',ntree=`B',importance=TRUE)"' _newline ///
	///
	`"# Train-MSE"' _newline ///
	///	
	`"yhat.train = predict(bag.data)"' _newline ///
	`"plot(yhat.train, y)"' _newline ///
	`"abline(0,1)"' _newline ///
	`"title(main="Actual Vs. Prediction on the training dataset")"' _newline ///
	`"y_train = y"' _newline ///
	`"data1 <- as.data.frame(cbind(yhat.train,y_train))"' _newline ///
    `"write.dta(data1, "`in_samp_data'.dta")"'  _newline ///
	///
	`"# Fit the model by Bagging or Random-forests on a test sample of size 1/2 of the original one"' _newline ///
	///
	`"# Test-MSE"' _newline ///
	///	
	`"set.seed(`S')"' _newline ///
	`"train = sample(1:nrow(data), nrow(data)/2)"' _newline ///
	`"bag.data=randomForest(y~.,data=data,subset=train,mtry=`A',ntree=`B',importance=TRUE)"' _newline ///
	`"yhat.test = predict(bag.data,newdata=data[-train,])"' _newline ///
	`"y.test=data[-train,"y"]"' _newline ///
	`"plot(yhat.test, y.test)"' _newline ///
	`"abline(0,1)"' _newline ///
	`"title(main="Actual Vs. Prediction on the testing dataset")"' _newline ///
	`"# The test-MSE is equal to:"' _newline ///
	`"data2 <- as.data.frame(cbind(yhat.test,y.test))"' _newline ///
    `"write.dta(data2,"`out_samp_data'.dta")"' _newline ///
	///
	`"# Factor-importance index:"' _newline ///
	///	
	`"importance(bag.data)"' _newline ///
	`"varImpPlot(bag.data)"'
quietly: file close rcode
end
********************************************************************************

********************************************************************************
program mytree5   // boosting_binomial
syntax , inter_depth(numlist max=1 integer) ntree(numlist max=1 integer) shrinkage(numlist max=1) pdp(string) in_samp_data(string) out_samp_data(string) seed(numlist max=1)
// Write R Code
// dependencies: foreign
local A=`inter_depth'
local B=`ntree'
local C=`shrinkage'
local D "`pdp'"  // partial dependent plot
local S=`seed'
quietly: file open rcode using mytree.R , write replace
quietly: file write rcode ///
    `"list.of.packages <- c("foreign","tree","MASS","ISLR","randomForest","gbm")"' _newline ///
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
	`"library("tree")"' _newline ///
	`"library(MASS)"' _newline ///
	`"library("tree")"'_newline ///
	`"library(MASS)"'_newline ///
	`"library(randomForest)"'_newline ///
	`"library(gbm)"'_newline ///
	///
	`"# Fit the model by Boosting on the whole sample"' _newline ///
	///
	`"set.seed(`S')"' _newline ///
	`"boost.data=gbm(y~.,data=data,n.trees=`B',interaction.depth=`A',shrinkage=`C',verbose=F)"' _newline ///
	`"yhat.boost=predict(boost.data,n.trees=`B',type="response")"' _newline ///
    `"pred_class <- NA"' _newline ///
    `"pred_class[yhat.boost >= 0.5] <- 1"' _newline ///
    `"pred_class[yhat.boost < 0.5]  <- 0"' _newline ///
	`"summary(boost.data)"' _newline ///
	///
	`"# Train-MSE "' _newline ///
	///
	`"# The training-MSE is:"' _newline ///
	`"yhat_train=pred_class"' _newline ///
	`"y_train=y"' _newline ///
	`"data1 <- as.data.frame(cbind(yhat_train,y_train))"' _newline ///
    `"write.dta(data1, "`in_samp_data'.dta")"'  _newline ///
	///
	`"# Fit the model by Boosting on a test sample of size 1/2 of the original one"' _newline ///
	///
	`"# Test-MSE"' _newline ///
	///
	`"train=sample(1:nrow(data), nrow(data)/2)"' _newline ///
    `"data.test=data[-train ,"y"]"' _newline ///
	`"boost.data=gbm(y~.,data=data[train,],n.trees=`B',interaction.depth=`A',shrinkage=`C',verbose=F)"' _newline ///
	///
	`"# Partial dependent plot"' _newline ///
	///
	`"plot(boost.data,i="`D'")"' _newline ///
	`"title(main="Partial dependent plot for variable `D'")"' _newline ///
    `"yhat.boost=predict(boost.data,newdata=data[-train,],n.trees=`B',type="response")"' _newline ///
	`"pred_class <- NA"' _newline ///
    `"pred_class[yhat.boost >= 0.5] <- 1"' _newline ///
    `"pred_class[yhat.boost < 0.5]  <- 0"' _newline ///
	`"# The testing-MSE is:"' _newline ///
	`"yhat_test=pred_class"' _newline ///
	`"y_test=data.test"' _newline ///
	`"# The testing-MSE is:"' _newline ///
	`"data2 <- as.data.frame(cbind(yhat_test,y_test))"' _newline ///
    `"write.dta(data2,"`out_samp_data'.dta")"'
quietly: file close rcode
end
********************************************************************************

********************************************************************************
program mytree6   // boosting_multinomial
syntax , inter_depth(numlist max=1 integer) ntree(numlist max=1 integer) shrinkage(numlist max=1) pdp(string) in_samp_data(string) out_samp_data(string) seed(numlist max=1)
// Write R Code
// dependencies: foreign
local A=`inter_depth'
local B=`ntree'
local C=`shrinkage'
local D "`pdp'"  // partial dependent plot
local S=`seed'
quietly: file open rcode using mytree.R , write replace
quietly: file write rcode ///
    `"list.of.packages <- c("foreign","tree","MASS","ISLR","randomForest","gbm")"' _newline ///
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
	`"library("tree")"' _newline ///
	`"library(MASS)"' _newline ///
	`"library("tree")"'_newline ///
	`"library(MASS)"'_newline ///
	`"library(randomForest)"'_newline ///
	`"library(gbm)"'_newline ///
	///
	`"# Fit the model by Boosting on the whole sample"' _newline ///
	///
	`"set.seed(`S')"' _newline ///
	`"boost.data=gbm(y~.,data=data,n.trees=`B',interaction.depth=`A',shrinkage=`C',verbose=F)"' _newline ///
	`"yhat.boost=predict(boost.data,n.trees=`B',type="response")"' _newline ///
	`"pred_class <- apply(yhat.boost, 1, which.max)"' _newline ///
	`"summary(boost.data)"' _newline ///
	///
	`"# Train-MSE "' _newline ///
	///
	`"# The training-MSE is:"' _newline ///
	`"yhat_train=pred_class"' _newline ///
	`"y_train=y"' _newline ///
	`"data1 <- as.data.frame(cbind(yhat_train,y_train))"' _newline ///
    `"write.dta(data1, "`in_samp_data'.dta")"'  _newline ///
	///
	`"# Fit the model by Boosting on a test sample of size 1/2 of the original one"' _newline ///
	///
	`"# Test-MSE"' _newline ///
	///
	`"train=sample(1:nrow(data), nrow(data)/2)"' _newline ///
    `"data.test=data[-train ,"y"]"' _newline ///
	`"boost.data=gbm(y~.,data=data[train,],n.trees=`B',interaction.depth=`A',shrinkage=`C',verbose=F)"' _newline ///
	///
	`"# Partial dependent plot"' _newline ///
	///
	`"plot(boost.data,i="`D'")"' _newline ///
	`"title(main="Partial dependent plot for variable `D'")"' _newline ///
    `"yhat.boost=predict(boost.data,newdata=data[-train,],n.trees=`B',type="response")"' _newline ///
	`"pred_class <- apply(yhat.boost, 1, which.max)"' _newline ///
	`"yhat_test=pred_class"' _newline ///
	`"y_test=data.test"' _newline ///
	`"# The testing-MSE is:"' _newline ///
	`"data2 <- as.data.frame(cbind(yhat_test,y_test))"' _newline ///
    `"write.dta(data2,"`out_samp_data'.dta")"'
quietly: file close rcode
end
********************************************************************************

********************************************************************************
program mytree7   // Pruned tree of a given size A - prediction
syntax , prune(numlist max=1 integer) out_samp_data(string) prediction(string)
// Write R Code
// dependencies: foreign
local A=`prune'
quietly: file open rcode using mytree.R , write replace
quietly: file write rcode ///
    `"list.of.packages <- c("foreign","tree","MASS","ISLR")"' _newline ///
    `"new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]"' _newline ///
    `"if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')"' _newline ///
	`"library("foreign")"' _newline ///
	`"# Loading"' _newline ///
	`"library(foreign)"' _newline ///
	`"my_data <- read.csv("mydata.csv", sep=",")"' _newline ///
	`"WD <- getwd()"' _newline ///
	`"setwd(WD)"' _newline ///
	`"data<-as.data.frame(my_data)"' _newline ///
	`"y <- data[,1]"' _newline ///
	`"x <- data[2:ncol(my_data)]"' _newline ///
	`"data <-cbind(y,x)"' _newline ///
	`"# Load libraries"' _newline ///
	`"library("tree")"' _newline ///
	`"library(MASS)"' _newline ///
	///
	`"# Fit the tree pruned at size A"' _newline ///
	///
	`"tree.data=tree(y~.,data)"'_newline ///
	`"prune.data=prune.tree(tree.data,best=`A')"'  _newline ///
	`"summary(prune.data)"'_newline ///
	///
	`"# Predictions at tree size `A'"' _newline ///
	///	
	`"yhat=predict(prune.data,type="class")"' _newline ///
	`"yhat_train=yhat"'_newline ///
	`"y_train=y"'_newline ///
	`"my_data_new <- read.csv("`prediction'.csv", sep=",")"' _newline ///
	`"attach(my_data_new)"' _newline ///
	`"yhat_new=predict(prune.data,my_data_new,type="class")"' _newline ///
	`"data1 <- as.data.frame(cbind(yhat_new))"' _newline ///
	`"write.dta(data1,"`out_samp_data'.dta")"'
quietly: file close rcode
end
********************************************************************************

********************************************************************************
program mytree8   // bagging and random-forests - prediction
syntax , mtry(numlist max=1 integer) ntree(numlist max=1 integer) out_samp_data(string) prediction(string) seed(numlist max=1)
// Write R Code
// dependencies: foreign
local S=`seed'
local A=`mtry'
local B=`ntree'
quietly: file open rcode using mytree.R , write replace
quietly: file write rcode ///
    `"list.of.packages <- c("foreign","tree","MASS","ISLR","randomForest")"' _newline ///
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
	`"library("tree")"' _newline ///
	`"library(MASS)"'_newline ///
	`"library(randomForest)"'_newline ///
	///
	`"# Fit the model by Bagging or Random-forests on the whole sample"' _newline ///
	///
	`"set.seed(`S')"' _newline ///
	`"bag.data=randomForest(y~.,data=data,mtry=`A',ntree=`B',importance=TRUE)"' _newline ///
	///
	`"# Prediction on new data"' _newline ///
	///	
	`"my_data_new <- read.csv("`prediction'.csv", sep=",")"' _newline ///
	`"data_new<-as.data.frame(my_data_new)"' _newline ///
    `"y <- data_new[,1]"' _newline ///
    `"x <- data_new[2:ncol(my_data_new)]"' _newline ///
    `"data_new <-cbind(y,x)"' _newline ///
	`"attach(data_new)"' _newline ///
	`"yhat_new=predict(bag.data,data_new,type="class")"' _newline ///
	`"data1 <- as.data.frame(cbind(yhat_new))"' _newline ///
	`"write.dta(data1,"`out_samp_data'.dta")"'
quietly: file close rcode
end
********************************************************************************

********************************************************************************
program mytree9   // boosting_binomial - prediction
syntax , inter_depth(numlist max=1 integer) ntree(numlist max=1 integer) shrinkage(numlist max=1) pdp(string) out_samp_data(string) seed(numlist max=1) prediction(string)
// Write R Code
// dependencies: foreign
local A=`inter_depth'
local B=`ntree'
local C=`shrinkage'
local D "`pdp'"  // partial dependent plot
local S=`seed'
quietly: file open rcode using mytree.R , write replace
quietly: file write rcode ///
    `"list.of.packages <- c("foreign","tree","MASS","ISLR","randomForest","gbm")"' _newline ///
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
	`"library("tree")"' _newline ///
	`"library(MASS)"' _newline ///
	`"library("tree")"'_newline ///
	`"library(MASS)"'_newline ///
	`"library(randomForest)"'_newline ///
	`"library(gbm)"'_newline ///
	///
	`"# Fit the model by Boosting on the whole sample"' _newline ///
	///
	`"set.seed(`S')"' _newline ///
	`"boost.data=gbm(y~.,data=data,n.trees=`B',interaction.depth=`A',shrinkage=`C',verbose=F)"' _newline ///
	`"my_data_new <- read.csv("`prediction'.csv", sep=",")"' _newline ///
	`"data_new<-as.data.frame(my_data_new)"' _newline ///
    `"y <- data_new[,1]"' _newline ///
    `"x <- data_new[2:ncol(my_data_new)]"' _newline ///
    `"data_new <-cbind(y,x)"' _newline ///
	`"attach(data_new)"' _newline ///
	`"yhat_new = predict(boost.data,data_new,n.trees=`B',type="response")"' _newline ///	
    `"pred_class <- NA"' _newline ///
    `"pred_class[yhat_new >= 0.5] <- 1"' _newline ///
    `"pred_class[yhat_new < 0.5]  <- 0"' _newline ///	
	`"data1 <- as.data.frame(cbind(yhat_new,pred_class))"' _newline ///
	`"write.dta(data1,"`out_samp_data'.dta")"'
quietly: file close rcode
end
********************************************************************************

********************************************************************************
program mytree10   // boosting_multinomial - prediction
syntax , inter_depth(numlist max=1 integer) ntree(numlist max=1 integer) shrinkage(numlist max=1) pdp(string) out_samp_data(string) seed(numlist max=1) prediction(string)
// Write R Code
// dependencies: foreign
local A=`inter_depth'
local B=`ntree'
local C=`shrinkage'
local D "`pdp'"  // partial dependent plot
local S=`seed'
quietly: file open rcode using mytree.R , write replace
quietly: file write rcode ///
    `"list.of.packages <- c("foreign","tree","MASS","ISLR","randomForest","gbm")"' _newline ///
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
	`"library("tree")"' _newline ///
	`"library(MASS)"' _newline ///
	`"library("tree")"'_newline ///
	`"library(MASS)"'_newline ///
	`"library(randomForest)"'_newline ///
	`"library(gbm)"'_newline ///
	///
	`"# Fit the model by Boosting on the whole sample"' _newline ///
	///
	`"set.seed(`S')"' _newline ///
	`"boost.data=gbm(y~.,data=data,n.trees=`B',interaction.depth=`A',shrinkage=`C',verbose=F)"' _newline ///
	///
	`"# Prediction on new data"' _newline ///
	///
	`"my_data_new <- read.csv("`prediction'.csv", sep=",")"' _newline ///
	`"data_new<-as.data.frame(my_data_new)"' _newline ///
    `"y <- data_new[,1]"' _newline ///
    `"x <- data_new[2:ncol(my_data_new)]"' _newline ///
    `"data_new <-cbind(y,x)"' _newline ///
	`"attach(data_new)"' _newline ///
	`"yhat_new = predict(boost.data,data_new,n.trees=`B',type="response")"' _newline ///	
	`"prob_new <- as.data.frame(yhat_new)"' _newline ///
	`"pred_class <- apply(yhat_new, 1, which.max)"' _newline ///
	`"data1 <- as.data.frame(cbind(pred_class,prob_new))"' _newline ///
    `"write.dta(data1,"`out_samp_data'.dta")"'
quietly: file close rcode
end
********************************************************************************

********************************************************************************
program define runR
syntax , rversion(string)
********************************************************************************
// Run R from Stata
********************************************************************************
local using `"mytree.R"'
********************************************************************************
* MAC
if "`c(os)'" == "MacOSX"{
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
