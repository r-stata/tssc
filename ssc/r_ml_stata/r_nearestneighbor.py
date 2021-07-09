################################################################################
#! "r_nearestneighbor.py": Nearest neighbor regression using Python Scikit-learn, and called by
#! the Stata command "r_nearestneighbor.ado" 
#! Author: Giovanni Cerulli
#! Version: 3
#! Date: 23 July 2020
################################################################################

# IMPORT NEEDED PACKAGES
from sklearn.neighbors import KNeighborsRegressor
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

# INITIALIZE a KNN (with the n_neighbors parameter=5)
model = KNeighborsRegressor(n_neighbors=5)

# DEFINE THE PARAMETER VALUES THAT SHOULD BE SEARCHED
k_range = list(range(1, 31))
weight_options = ['uniform', 'distance']

# CREATE A PARAMETER GRID: MAP THE PARAMETER NAMES TO THE VALUES THAT SHOULD BE SEARCHED
param_grid = dict(n_neighbors=k_range, weights=weight_options)
print(param_grid)

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

# PUT "OPT_LEAVES" INTO A STATA SCALAR
params_values=list(grid.best_params_.values()) 

# STORE THE BEST NUMBER OF NEIGHBORS INTO A STATA SCALAR
opt_nn=grid.best_params_.get('n_neighbors')
Scalar.setValue('OPT_NN',opt_nn,vtype='visible')

# STORE THE BEST WEIGHT-TYPE INTO A STATA SCALAR
opt_weight=grid.best_params_.get('weights')
Macro.setGlobal('OPT_WEIGHT',opt_weight, vtype='visible')

print("------------------------------------------------------")
print("The best estimator is:")
print(grid.best_estimator_)
print("------------------------------------------------------")
print("The best index is:")
print(grid.best_index_)
print("------------------------------------------------------")

################################################################################

# TRAIN YOUR MODEL USING ALL DATA AND THE BEST KNOWN PARAMETERS
model=KNeighborsRegressor(n_neighbors=opt_nn, weights=opt_weight)

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












