#******************************************************************************
# * TITLE:  "NEURAL-NETWORK CLASSIFICATION USING CROSS-VALIDATION" 
# * DATE:   24/07/2020
# * AUTHOR: GIOVANNI CERULLI
# *****************************************************************************
# * USE THE "scikit-learn" PYTHON PACKAGE TO ACHIEVE THIS GOAL, AND IN 
# * PARTICULAR THE FUNCTION "AdaBoostClassifier()"
# *****************************************************************************

# IMPORT THE NEEDED PYTHON PACKAGES
from sklearn.neural_network import MLPClassifier
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
print(y)

# DEFINE X THE FEATURES
X=df.iloc[:,1::]
print(X)

# READ THE "SEED" FROM STATA
R=int(Macro.getLocal("seed"))

# INITIALIZE a BOOSTING-TREE (with boosting parameters)
model = MLPClassifier(solver='lbfgs', alpha=1e-5,hidden_layer_sizes=(5, 2), random_state=R)

# ABC "CROSS-VALIDATION"
# WE CROSS-VALIDATE OVER TWO PARAMETERS:
# 1. "D = learning_rate"
# 2. "G = n_estimators"

# DEFINE THE PARAMETER VALUES THAT SHOULD BE SEARCHED FOR CROSS-VALIDATION
# 1. "NUMBER OF LAYERS" 
# 2. "NUMBER OF NEURONS" 
# 3. "RANDOM SEED" 

# CREATE A PARAMETER GRID AS A 2D "LIST" FOR LAYERS AND NEURONS
grid=[]
for i in range(1,10,1):
  for j in range(1,6,1):
     g=(i,j)
     grid.append(g)
print(grid)

# GENERATE THE GRID (JUST ONE NUMBER) FOR THE "RANDOM SEED"	
gridR=[1]
	
# PUT THE GENERATED GRIDS INTO A PYTHON DICTIONARY 
param_grid={'hidden_layer_sizes': grid , 'random_state':gridR }


# INSTANTIATE THE GRID
grid = GridSearchCV(model, param_grid, cv=10, scoring='accuracy', return_train_score=True)

# FIT OVER THE GRID
grid.fit(X, y)

# VIEW THE RESULTS 
CV_RES=pd.DataFrame(grid.cv_results_)[['mean_train_score','mean_test_score','std_test_score']]
D=Macro.getLocal("cross_validation") 
D=D+".dta"
CV_RES.to_stata(D)


# EXAMINE THE BEST MODEL AND PUT RESULTS INTO STATA
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

print("------------------------------------------------------")
print("The best estimator is:")
print(grid.best_estimator_)
print("------------------------------------------------------")
print("The best index is:")
print(grid.best_index_)
print("------------------------------------------------------")


# STORE THE TWO BEST PARAMETERS INTO TWO VARIABLES 
opt_nn=grid.best_params_.get('hidden_layer_sizes')
opt_layers=opt_nn[0]
opt_neurons=opt_nn[1]
Scalar.setValue('OPT_LAYERS',opt_layers,vtype='visible')
Scalar.setValue('OPT_NEURONS',opt_neurons,vtype='visible')

# USING THE BEST PARAMETERS TO MAKE PREDICTIONS
# TRAIN YOUR MODEL USING ALL DATA AND THE BEST KNOWN PARAMETERS
model = MLPClassifier(solver='lbfgs', alpha=1e-5,hidden_layer_sizes=opt_nn, random_state=R)

# FIT THE MODEL
model.fit(X, y)

# MAKE IN-SAMPLE PREDICTION FOR y and prob, AND PUT IT INTO A DATAFRAME
y_hat = model.predict(X)
prob = model.predict_proba(X)
#dfprob=pd.DataFrame(prob)

# STACK THE PREDICTIONS
in_sample=np.column_stack((y_hat,prob))
in_sample = pd.DataFrame(in_sample)
                
# GET RESULTS INTO STATA
# (NOTE: the first column is the prediction "y_hat")
D=Macro.getLocal("in_prediction") 
D=D+".dta"
in_sample.to_stata(D)

################################################################################
# MAKE OUT-OF-SAMPLE "LABEL" PREDICTION FOR y USING A PREPARED DATASET
################################################################################
D=Macro.getLocal("out_sample") 
D=D+".dta"
Xnew = pd.read_stata(D)
ynew = model.predict(Xnew)

# MAKE OUT-OF-SAMPLE "PROBABILITY" PREDICTION FOR y USING A PREPARED DATASET
prob_new = model.predict_proba(Xnew)
Prob_new  = pd.DataFrame(prob_new )

# EXPORT LABEL PREDICTION FOR y INTO AN EXCEL FILE
Ynew = pd.DataFrame(ynew)

# MERGE LABEL AND PROBABILITY PREDICTION FOR y INTO AN EXCEL FILE
# Use "numpy" to stack by column 'ynew' and 'prob_new'
out=np.column_stack((ynew,prob_new))
# Generate a dataframe 'OUT' from the previous array
OUT = pd.DataFrame(out)
                
# Get to the Stata (Excel) for results
# (NOTE: the first column is the prediction "y_hat")
D=Macro.getLocal("out_prediction") 
D=D+".dta"
OUT.to_stata(D)

# END
