################################################################################
#! "r_boost.py": Tree regression using Python Scikit-learn, and called by
#! the Stata command "r_tree.ado" 
#! Author: Giovanni Cerulli
#! Version: 3
#! Date: 23 July 2020
################################################################################

# IMPORT NEEDED PACKAGES
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.model_selection import GridSearchCV
from sfi import Macro, Scalar
from sfi import Data , SFIToolkit
import numpy as np
import pandas as pd
import os

# SET THE DIRECTORY
dir=Macro.getLocal("dir")
os.chdir(dir)

# SET THE TRAIN/TEST DATASET AND THE NEW-INSTANCES-DATASET
dataset=Macro.getLocal("data_fitting")

# LOAD A STATA DATASET LOCATED INTO THE DIRECTORY AS PANDAS DATAFRAME
df = pd.read_stata(dataset)
print(df)
df.info()

# DEFINE y THE TARGET VARIABLE
y=df.iloc[:,0]
y

# DEFINE X THE FEATURES
X=df.iloc[:,1::]
X

# READ THE "SEED" FROM STATA
R=int(Macro.getLocal("seed"))

# ESTIMATE A "ABC" AT GIVEN PARAMETERS (JUST TO TRY IF IT WORKS)
model = GradientBoostingRegressor(learning_rate=0.1, n_estimators=100, random_state=R)

# ABC "CROSS-VALIDATION"
# WE CROSS-VALIDATE OVER TWO PARAMETERS:
# 1. "D = learning_rate"
# 2. "G = n_estimators"

# GENERATE THE TWO PARAMETERS' GRID AS "LISTS"
# GRID FOR "learning_rate"
gridD=[0.001,0.005,0.01,0.05,0.1,0.20]
#print(gridD)
# GRID FOR "n_estimators"
gridG=list(range(1,21))
#print(gridG)

# PUT THE GENERATED GRIDS INTO A PYTHON DICTIONARY 
param_grid = {'learning_rate': gridD, 'n_estimators': gridG}


# INSTANTIATE THE GRID
# BUILD A "GRID SEARCH CLASSIFIER"
grid = GridSearchCV(model,param_grid,cv=10,
                    scoring='explained_variance',
					return_train_score=True)

# FIT THE GRID
grid.fit(X, y)

# VIEW THE RESULTS 
CV_RES=pd.DataFrame(grid.cv_results_)[['mean_train_score','mean_test_score','std_test_score']]
D=Macro.getLocal("cross_validation") 
D=D+".dta"
CV_RES.to_stata(D)

# EXAMINE THE BEST MODEL
print("                                                      ")
print("                                                      ")
print("------------------------------------------------------")
print("CROSS-VALIDATION RESULTS TABLE")
print("------------------------------------------------------")
print("The best score is:")                           
print(grid.best_score_)
Scalar.setValue('OPT_SCORE',grid.best_score_,vtype='visible')
print("------------------------------------------------------")
print("The best parameters are:")
print(grid.best_params_)

# PUT OPTIMAL PARAMETER(S) INTO STATA SCALAR(S)
params_values=list(grid.best_params_.values()) 
Scalar.setValue('OPT_LEARNING_RATE',params_values[0],vtype='visible')
Scalar.setValue('OPT_N_ESTIMATORS',params_values[1],vtype='visible')


print("------------------------------------------------------")
print("The best estimator is:")
print(grid.best_estimator_)
print("------------------------------------------------------")
print("The best index is:")
print(grid.best_index_)
print("------------------------------------------------------")

################################################################################

# STORE THE BEST PARAMETER INTO A VARIABLE

# GET THE VALUE "opt_leaves" AND PUT IT INTO A STATA SCALAR "OPT_LEAVES"
opt_learning_rate=grid.best_params_.get('learning_rate')
opt_n_estimators=grid.best_params_.get('n_estimators')

# TRAIN YOUR MODEL USING ALL DATA AND THE BEST KNOWN PARAMETERS
model = GradientBoostingRegressor(learning_rate=opt_learning_rate, 
                                  n_estimators=opt_n_estimators, 
								  random_state=R)

# FIT THE MODEL
model.fit(X, y)

# MAKE IN-SAMPLE PREDICTION FOR y, AND PUT IT INTO A DATAFRAME
y_hat = model.predict(X)
#print(y_hat)
D=Macro.getLocal("in_prediction") 
Data.addVarByte(D)
Data.store(D, None, y_hat)

################################################################################

# SET THE TRAIN/TEST DATASET AND THE NEW-INSTANCES-DATASET
D=Macro.getLocal("out_sample") 
D=D+".dta"

# LOAD A STATA DATASET LOCATED INTO THE DIRECTORY AS PANDAS DATAFRAME
#Xnew = pd.read_stata("data")
Xnew = pd.read_stata(D)

#print(Xnew)
ynew = model.predict(Xnew)
print(ynew)
type(ynew)

# EXPORT LABEL PREDICTION FOR y INTO AN EXCEL FILE
Ynew = pd.DataFrame(ynew)

# Generate a dataframe 'OUT' from the previous array
OUT = pd.DataFrame(Ynew)
                
# Get to the Stata (Excel) for results
# (NOTE: the first column is the prediction "y_hat")
D=Macro.getLocal("out_prediction") 
D=D+".dta"
OUT.to_stata(D)
################################################################################












