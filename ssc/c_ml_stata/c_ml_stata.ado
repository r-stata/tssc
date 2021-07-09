********************************************************************************
*! "c_ml_stata"
*! Author: Giovanni Cerulli
*! Version 6
*! Date: 22 August 2020
********************************************************************************
program c_ml_stata , eclass
version 16
syntax varlist , mlmodel(string)  in_prediction(name) cross_validation(name) out_sample(name) ///
out_prediction(name) seed(numlist max=1 integer) ///
[save_graph_cv(name)]
********************************************************************************
gettoken y X : varlist
********************************************************************************
* WARNING 1
********************************************************************************
capture confirm numeric variable `y'
if _rc!=0 {
di _newline
di in red "***************************************************************************"
di in red "WARNING: It seems that your categorical outcome variable '`y''             "
di in red "is a string variable. Please, econde this variable to become numeric       "
di in red "The classes numbering must be: [1,2,...,M].                                "
di in red "***************************************************************************"
exit
}
********************************************************************************
* WARNING 2
********************************************************************************
foreach V of local X{
capture confirm numeric variable `V'
if _rc!=0 {
di _newline
di in red "*****************************************************************************"
di in red "WARNING: It seems that feature '`V'' is a string variable.                  "
di in red "Please, econde this feature to become numeric.                              "
di in red "If '`V'' is a factor variable, please generate the classes binary dummies and"
di in red "insert them as separate features in the model.                               "
di in red "*****************************************************************************"
exit
}
}
********************************************************************************
* WARNING 3
********************************************************************************
levelsof `y' , local(LEV)
local A: word 1 of `LEV'
if `A'==0{
di _newline
di in red "**********************************************************************************"
di in red "WARNING: It seems that the numbering of the classes of variable '`y''             " 
di in red "starts from 0. Please, recode the classes to start from 1.                        " 
di in red "The classes numbering must be: [1,2,...,M].                                       "	
di in red "**********************************************************************************"
exit
}
********************************************************************************
* WARNING 4
********************************************************************************
cap confirm file `out_sample'.dta
if _rc!=0 {
di _newline
di in red "***************************************************************************"
di in red "WARNING: File '`out_sample'' does not exist in your directory.             " 
di in red "Please, provide a Stata out-of-sample dataset made only of new X-instances."   
di in red "***************************************************************************"
di _newline
exit
}
else if _rc==0{
********************************************************************************
* PASS THE STATA DIRECTORY TO PYTHON
********************************************************************************
local dir `c(pwd)'
********************************************************************************
tempfile data_intial 
save `data_intial' , replace
********************************************************************************
* WARNING 5
********************************************************************************
preserve
keep `y' `X'
qui count 
local NN=r(N)
qui reg `y' `X'
keep if e(sample)
qui count 
local SS=r(N)
restore
********************************************************************************
if `SS'!=`NN'{
di _newline
di in red "********************************************************************************"
di in red "WARNING: It seems there are missing values in your outcome and/or features.     "
di in red "Please, remove them and re-run this command.                                    "
di in red "********************************************************************************"
di _newline
exit
}
********************************************************************************
* KEEP ONLY y AND X
********************************************************************************
keep `y' `X'
order `y' `X'
********************************************************************************
*
********************************************************************************
* ESTIMATION PROCEDURE
********************************************************************************
* SAVE THE DATASET AS IT IS
tempfile data_fitting 
save `data_fitting' , replace
********************************************************************************
* PYTHON CODE - BEGIN 
********************************************************************************
if "`mlmodel'"=="tree"{
python script "`c(sysdir_plus)'py/c_tree.py"
ereturn clear
ereturn scalar OPT_LEAVES=OPT_LEAVES
}
********************************************************************************
else if "`mlmodel'"=="boost"{
python script "`c(sysdir_plus)'py/c_boost.py"
ereturn clear
ereturn scalar OPT_LEARNING_RATE=OPT_LEARNING_RATE
ereturn scalar OPT_N_ESTIMATORS=OPT_N_ESTIMATORS
}
********************************************************************************
else if "`mlmodel'"=="naivebayes"{
python script "`c(sysdir_plus)'py/c_naivebayes.py"
ereturn clear
ereturn scalar OPT_VAR_SMOOTHING=OPT_VAR_SMOOTHING
}
********************************************************************************
else if "`mlmodel'"=="regularizedmultinomial"{
python script "`c(sysdir_plus)'py/c_regularizedmultinomial.py"
ereturn clear
ereturn scalar OPT_PENALIZATION=OPT_PENALIZATION
ereturn scalar OPT_L1_RATIO=OPT_L1_RATIO
}
********************************************************************************
else if "`mlmodel'"=="nearestneighbor"{
python script "`c(sysdir_plus)'py/c_nearestneighbor.py"
ereturn clear
ereturn scalar OPT_NN=OPT_NN
ereturn local OPT_WEIGHT "$OPT_WEIGHT"
}
********************************************************************************
else if "`mlmodel'"=="neuralnet"{
python script "`c(sysdir_plus)'py/c_neuralnet.py"
ereturn clear
ereturn scalar OPT_LAYERS=OPT_LAYERS
ereturn scalar OPT_NEURONS=OPT_NEURONS
}
********************************************************************************
else if "`mlmodel'"=="randomforest"{
python script "`c(sysdir_plus)'py/c_randomforest.py"
ereturn clear
ereturn scalar OPT_MAX_DEPTH=OPT_MAX_DEPTH
ereturn scalar OPT_MAX_FEATURES=OPT_MAX_FEATURES
}
********************************************************************************
else if "`mlmodel'"=="svm"{
python script "`c(sysdir_plus)'py/c_svm.py"
ereturn clear
ereturn scalar OPT_C=OPT_C
ereturn scalar OPT_GAMMA=OPT_GAMMA
}
********************************************************************************
* PYTHON CODE - END 
******************************************************************************** 
preserve
********************************************************************************
use `cross_validation' , clear
qui sum mean_test_score
scalar max_score_test=r(max)
ereturn scalar TEST_ACCURACY=max_score_test
********************************************************************************
qui sum mean_train_score if mean_test_score==max_score_test
scalar score_train=r(mean)
ereturn scalar TRAIN_ACCURACY=score_train
********************************************************************************
qui sum index if mean_test_score==max_score_test
scalar max_index=r(mean)
ereturn scalar BEST_INDEX=max_index
********************************************************************************
restore
********************************************************************************
preserve
use `out_prediction' , clear
rename _0 label_out_pred
la var label_out_pred "Label out-of-sample prediction"
rename _* Prob_*
save `out_prediction' , replace
restore
********************************************************************************
preserve
use `in_prediction' , clear
rename _0 label_in_pred
la var label_in_pred "Label in-sample prediction"
rename _* Prob_*
save `in_prediction' , replace
restore
********************************************************************************
}
********************************************************************************
* CROSS-VALIDATION GRAPH
********************************************************************************
use `cross_validation' , clear
local A=max_index
if "`save_graph_cv'"!=""{
tw ///
(line mean_test_score index  , xline(`A',lp(dash) lw(thick))) ///
(line mean_train_score index ) , ///
legend(order(1 "TEST ACCURACY" 2 "TRAIN ACCURACY")) ///
note("Learner = `mlmodel'" "Optimal index = `A'") ///
ytitle(Accuracy = (1 - Err)) xtitle(Index) ///
graphregion(fcolor(white)) scheme(s2mono) saving(`save_graph_cv' , replace)
}
********************************************************************************
use `data_intial' , clear
********************************************************************************
end 
********************************************************************************
