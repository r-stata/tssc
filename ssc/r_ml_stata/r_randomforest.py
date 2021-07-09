################################################################################
#! "r_randomforest.py": Random-forest regression using Python Scikit-learn, and called by
#! the Stata command "r_tree.ado" 
#! Author: Giovanni Cerulli
#! Version: 3
#! Date: 23 July 2020
################################################################################

# IMPORT NEEDED PACKAGES
from sklearn.ensemble import RandomForestRegressor
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

# COMPUTE THE NUMBER OF FEATURES 
X = np.array(X)
n_features=int(len(X[0]))
print(n_features)

# READ THE "SEED" FROM STATA
R=int(Macro.getLocal("seed"))

# ESTIMATE A "RFC" AT GIVEN PARAMETERS (JUST TO TRY IF IT WORKS)
model = RandomForestRegressor(max_depth=5, n_estimators=3, max_features=2, random_state=R)

# RFC "CROSS-VALIDATION":
# WE CROSS-VALIDATE OVER TWO PARAMETERS:
# 1. "D = tree depth" (i.e., number of leaves of the tree);
# 2. "G = percentage of features to randomly consider at each split"

# GENERATE THE TWO PARAMETERS' GRID AS "LISTS"
gridD=list(range(1,31))
print(gridD)
gridG=list(range(1,n_features+1))
print(gridG)

# PUT THE GENERATED GRIDS INTO A PYTHON DICTIONARY 
param_grid = {'max_depth': gridD, 'max_features': gridG}


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

# GET THE VALUE "opt_max_depth" AND PUT IT INTO A STATA SCALAR "OPT_MAX_DEPTH"
opt_max_depth=grid.best_params_.get('max_depth')
Scalar.setValue('OPT_MAX_DEPTH',opt_max_depth,vtype='visible')

# GET THE VALUE "opt_max_features" AND PUT IT INTO A STATA SCALAR "OPT_MAX_FEATURES"
opt_max_features=grid.best_params_.get('max_features')
Scalar.setValue('OPT_MAX_FEATURES',opt_max_features, vtype='visible')

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


# TRAIN YOUR MODEL USING ALL DATA AND THE BEST KNOWN PARAMETERS
model = RandomForestRegressor(max_depth=opt_max_depth, 
                                n_estimators=100, 
								max_features=opt_max_features, 
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












