{smcl}
{* *! version 0.3.2  24 June 2020}{...}
{viewerjumpto "Examples" "rforest_examples##examples"}{...}

{...}{* NB: these hide the newlines }
{...}
{...}
{title:Title}

{p2colset 5 23 25 2}{...}
{p2col :{cmd:rforest} {hline 2}} Random Forest algorithm  {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:rforest}  {depvar} {indepvars} {ifin} {cmd:,}  [ {it:options}  ]

{p 8 16 2}
{cmd:predict} { {newvar} | {varlist} | stub* } {ifin} {cmd:,}  [ pr ]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model}

{synopt :{opt type:(str)}} The type of decision tree. Must be one of "class" (classification) or "reg" (regression). {p_end}
{synopt :{opt iter:ations(int)}} Set the number of iterations (trees), default to 100 if not specified. {p_end}

{synopt: {opt numv:ars(int)}} Set the number of variables to randomly investigate, default to sqrt(number of indepvars). {p_end}

{syntab: Tree Size}

{synopt :{opt d:epth(int)}} Set the maximum depth of the random forest, default to 0 for unlimited, if not specified. {p_end}
{synopt :{opt ls:ize(int)}} Set the minimum number of observations per leaf, default to 1 if not specified. {p_end}
{synopt :{opt v:ariance(real)}} Set the minimum proportion of the variance at a node in order for splitting to be performed in regression trees, default to 1e^(-3) if not specified. Only applicable to regression. {p_end}

{syntab: Other}

{synopt :{opt s:eed(int)}} Set the seed value, default to 1 if not specified. {p_end}

{synopt :{opt numdec:imalplaces(int)}} Set the precision for computation, default to minimum 5 decimal places if not specified. {p_end}
{synoptline}

{title:Predict Syntax}

{phang}
{cmd: predict} { {newvar} | newvarlist | stub* } {ifin} {cmd:,}  [ pr ] {p_end}

{phang}
If option {opt pr} is specified, the post-estimation command returns the class probabilities. This option is only applicable to classification problems.

{marker description}{...}
{title:Description}

{pstd}
{cmd:rforest} is a plugin for random forest classification and regression algorithms. It is built on a Java backend which acts as an interface to the RandomForest Java class presented in the WEKA project, developed at the University of
Waikato and distributed under the GNU Public License.{p_end}

{marker details}{...}
{title:Details}

{pstd}
Missing values: {p_end}
{pstd}
The independent variables may contain missing values. 
Splits at any node can occur even if some independent variables are missing. 
If the independent variable is missing from an observation, 
it will be ignored for estimation but predictions can still be made on the observation. 
If the dependent variable for the training data contains missing values, 
the function will exit with an error message. 
In other words, any missing values in the dependent (response) variable 
in the training set needs to be imputed or excluded prior to executing 
the {cmd:rforest} command.{p_end}

{pstd}
Class values: {p_end}
{pstd}
For classification problems, the class values must be non-negative integers.
{p_end}

{pstd}
Out-of-bag error: {p_end}
{pstd}
Out-of-bag error is computed against the samples not included in the sub-trees of the random forest during the training stage. 
For regression problems, this value represents the RMSE. For classification problems, this value represents the classification error. 
Typically, a scatter plot of OOB error vs. the number of iterations monitors the convergence of the OOB error. If convergence is not reached, the number of iterations is increased. 
It is not possible to produce such a plot in a single run because WEKA only computes the OOB estimates once, when the entire ensemble has been built. 
In practice, this means rforest needs to be run at least twice with two different iterations (e.g. 1000 and 1100). 
If the OOB error is roughly the same, either run is satisfactory; otherwise the number of iterations need to be increased.
{p_end}

{pstd}
Splitting criterion: {p_end}
{pstd}
Random Forest uses entropy for split selection in the classification case.{p_end}

{pstd}
For more information on the WEKA library, please visit {browse "http://www.cs.waikato.ac.nz/~ml/index.html"}
{p_end}

{pstd}
Installation: {p_end}
{pstd}
Installation details are not relevant to most users. This plugin requires Java Runtime Environment 1.8.0, which comes with your Stata download. If you cannot find a folder titled jre1.8.0_121.jre, 
or if you encounter a Java runtime error when calling functions from the rforest plugin, 
try downloading and installing JDK v.8 from Oracle's website at {browse "http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html"}{p_end}
{pstd}
You can verify that all the jar files are in the right paths and that java has been initialized by typing {cmd:query java} in the Stata command line.


{marker optionsForRandomForest}{...}
{title:Options for rforest}

{dlgtab:Model}

{phang}
{opt type} specifies whether the prediction is categorical or continuous. {cmd:type(class)} builds a classification tree and {cmd:type(reg)} builds a regression tree.

{phang}
{opt iterations} sets the number of trees to be generated when constructing the model. The default value is 100 if not specified.

{phang}
{opt numvars} sets the number of independent variables to randomly investigate at each split. The default value is sqrt(number of independent variables) if not specified.


{dlgtab:Tree Size}

{phang}
{opt depth} sets the maximum depth of the random forest model, which is the length of the longest path from the root node to a leaf node. 
The default value is 0, which indicates that the maximum height is unlimited.

{phang}
{opt lsize} sets the mininum number of observations to include at each leaf node. The default value is 1 if not specified.


{phang}
{opt variance} sets the minimum proportion of the variance on all the data that needs to be present at a node in order for splitting to be performed in regression trees. 
If the variance of the dependent variable is {cmd:a} on the full dataset, and this parameter is set to {cmd:b}, then a node will only be considered 
for splitting if the variance of the dependent variable at this node is at least {cmd:a * b}.

{dlgtab:Other}

{phang}
{opt seed} sets the seed value for reproducible results.

{phang}
{opt numdecimalplaces} sets the number of decimal places to be retained during random forest model building and post-estimation.


{marker optionsForPredict}{...}
{title:Options for predict}

{phang} Options must be the same as specified for {cmd:rforest} in {opt type()}

{pstd}
For regression models  a single {newvar} need to be supplied. 
This is also true for classification models where class assignments are desired rather than the probabilities for each class.
For classification models with class probabilities ({opt pr}), one variable needs to be supplied for 
each class of the dependent variable. For example, for binary outcomes two variables need to be specified.
This can be accomplished either by specifying all variable names in {opt newvarlist} or by 
specifying a {opt stub*} which creates variables by substituting {opt *} with integers ranging from 1 to the number of classes.
The order of the variable names corresponds to the order of the class values from lowest to highest.  
{p_end}

{pstd}
In the regression case, {opt predict newvar} computes the expected values of the dependent variable, which is a set of continuous real numbers, 
based on the previously computed model and the current set of observations.
{p_end}

{pstd}
In the classification case, {opt predict newvar} computes the expected values of the dependent variable, which is a set of discrete positive integers, 
based on the previously computed model and the current set of observations.
{p_end}

{pstd}
In the classification case, {opt predict varlist|stub* , pr} computes the expected probability distributions of the dependent variable, 
which is a set of continuous real numbers between 0 and 1, based on the previously computed model and the current set of observations. To use this command, 
you must specify the individual classes that you want to predict in the same order as the results of {cmd: levelsof depvar}. 
For an example, please refer to the {cmd: Classification Example} section.
{p_end}

{title:Bug}
{pstd} If the rforest statement and the predict statements are called more than once with the same prediction variable, subsequent predictions are sometimes incorrect. 
The bug is inside the JAVA code rather than the Stata code that calls JAVA. 
Since I (Schonlau) do not code in Java I cannot currently fix it. Finding a solution is on my to-do list.
Here are two easy work-arounds: 

{phang2}{cmd:. foreach i of numlist 1/5} { {p_end}
{phang3}{cmd:. cap drop p    //removing any existing prediction variables avoids the bug }{p_end}
{phang3}{cmd:. rforest $y $xvars , type(class) }{p_end}
{phang3}{cmd:. predict p }{p_end}
{phang2} } {p_end}

{pstd} Alternatively, you can choose different names for the prediction variable:

{phang2}{cmd: foreach i of numlist 1/5 } { {p_end}
{phang3}{cmd: 	rforest $y $xvars , type(class)}{p_end}
{phang3}{cmd: 	predict p`i'  //giving a different name each time avoids the bug also} {p_end}
{phang2} } {p_end}

{pstd} If you call {cmd: rforest} only once, this bug does not affect you.


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:rforest} stores the following in {cmd:e()}:

{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(Observations)}}number of observations{p_end}
{synopt:{cmd:e(features)}}number of attributes used in building the random forest{p_end}
{synopt:{cmd:e(Iterations)}}number of iterations used in building the random forest{p_end}
{synopt:{cmd:e(OOB_Error)}}out-of-bag error calculated when building the random forest{p_end}
{synopt:{cmd:e(depvar)}}Name of the dependent variable{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:rforest}{p_end}
{synopt:{cmd:e(model_type)}}to indicate if it is a classification or regression problem{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(importance)}}the matrix of variable importance for each variable used when building 
the classifier. The values are scaled proportional to the largest value in the set.{p_end}
{synoptline}

{pstd}
{cmd:predict} stores the following in {cmd:e()}:

{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(MAE)}}mean absolute error (only applicable to regression problems){p_end}
{synopt:{cmd:e(RMSE)}}root mean squared error (only applicable to regression problems){p_end}
{synopt:{cmd:e(correct_class)}}number of correctly classified observations (only applicable to classification problems){p_end}
{synopt:{cmd:e(incorrect_class)}}number of incorrectly classified observations (only applicable to classification problems){p_end}
{synopt:{cmd:e(error_rate)}}error rate (only applicable to classification problems){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(fMeasure)}}the matrix of f-measures for each class (only applicable to classification problems){p_end}


{pstd}
All results from the predict statement refer to the observations as specified by [if][in] in the predict command. 
The {cmd: rforest} command may have used a different [if][in] statement for training. 
{p_end}

{pstd}
If the dependent variable of the observations as specified by [if][in] in the predict statement contains missing values, 
these statistics are not computed.
{p_end}



{marker runexamples}{...}
{title:Examples}
INCLUDE help rforest_examples


{title:Copyright}

{pstd} {cmd: Wrapper}

{pstd} Copyright 2017 Matthias Schonlau {p_end}

{pstd} This program is free software: you can redistribute it and/or modify it under the terms of the GNU General 
Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any later version. {p_end}

{pstd} This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. {p_end}

{pstd} For the GNU General Public License, please visit {browse "http://www.gnu.org/licenses/"} {p_end}

{pstd}{cmd: WEKA}{p_end}
    GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007
{pstd}For a full copy of the license, please visit {browse "http://weka.sourceforge.net/"}


{marker technical}{...}
{title:Technical Notes}

{pstd} At its current stage, this plugin is not designed for large-scale parallel computing. Performance may vary 
between different machines. For 64-bit macOS with 16GB of RAM, the maximum matrix size tested is around 40,000 by 403, 
or 16,120,000 entries in total.


{marker authors}{...}
{title:Authors}

{pstd} Rosie Yuyan Zou <y53zou@uwaterloo.ca>{p_end}

{pstd} Matthias Schonlau <schonlau@uwaterloo.ca>{p_end}

{marker reference}{...}
{title:References}

{pstd} Breiman, Leo (2001). Random Forests. Machine learning, 45(1), pp 5-32.{p_end}

{pstd} Eibe Frank, Mark A. Hall, and Ian H. Witten (2016). The WEKA Workbench. 
Online Appendix for "Data Mining: Practical Machine Learning Tools and Techniques", Morgan Kaufmann, Fourth Edition, 2016. {p_end}