################################################################################
#! "elastic.py": Elastic-net using Python Scikit-learn, and called by
#! the Stata command "elastic.ado" 
#! Author: Giovanni Cerulli
#! Version: 3
#! Date: 23 July 2020
################################################################################

# IMPORT NEEDED PACKAGES
from sklearn.linear_model import ElasticNet
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

# INITIALIZE AN ELATIC NET
model = ElasticNet()

# "CROSS-VALIDATION" FOR "L1_RATIO" ("C") AND "ALFA"  BY PRODUCING A "GRID SEARCH"
# GENERATE THE TWO PARAMETERS' GRID AS A "LIST"
gridC=(0,0.25,0.50,0.75,1)
gridG=(0,10,20,30,40,50,60,70,80,90,100,110,120,130,150)

# PUT THE GENERATED GRIDS INTO A PYTHON DICTIONARY 
param_grid = {'l1_ratio': gridC, 'alpha': gridG}
#print(param_grid)


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

params_values=list(grid.best_params_.values()) 
Scalar.setValue('OPT_ALPHA',params_values[0],vtype='visible')
Scalar.setValue('OPT_L1_RATIO',params_values[1],vtype='visible')

print("------------------------------------------------------")
print("The best estimator is:")
print(grid.best_estimator_)
print("------------------------------------------------------")
print("The best index is:")
print(grid.best_index_)
print("------------------------------------------------------")

################################################################################

# STORE THE BEST PARAMETER INTO A VARIABLE

# GET THE VALUE "opt_c" AND PUT IT INTO A STATA SCALAR "OPT_C"
opt_c=grid.best_params_.get('l1_ratio')

# GET THE VALUE "opt_gamma" AND PUT IT INTO A STATA SCALAR "OPT_GAMMA"
opt_gamma=grid.best_params_.get('alpha')

# TRAIN YOUR MODEL USING ALL DATA AND THE BEST KNOWN PARAMETERS
model = ElasticNet(l1_ratio=opt_c, alpha=opt_gamma)

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












