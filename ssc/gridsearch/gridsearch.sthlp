{smcl}
{* *! version 0.0.1  10May2017}{...}
{viewerjumpto "Syntax" "gridsearch##syntax"}{...}
{viewerjumpto "Description" "gridsearch##description"}{...}
{viewerjumpto "Options" "gridsearch##options"}{...}
{viewerjumpto "Examples" "gridsearch##examples"}{...}
{viewerjumpto "Authors" "gridsearch##authors"}{...}

{...}{* NB: these hide the newlines }
{...}
{...}
{title:Title}
par
{p2colset 5 23 25 2}{...}
{p2col :{cmd:gridsearch} {hline 2}} Optimizing tuning parameter levels with a grid search  {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:gridsearch} {cmd:command} {depvar} {indepvars} {ifin} {cmd:,} method(str1 str2) par1name(str) par1list(numlist) criterion(str) [ {it:options} ]

{p 8 16 2}
{cmd:gridsearch} {cmd:discrim} subcommand {indepvars} {ifin} {cmd:,} method(str1 str2) par1name(str) par1list(numlist) criterion(str)  group({depvar}) [ {it:options} ]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt par1name:(string)}} Name of the a tuning parameter of {cmd:command} {p_end}
{synopt :{opt par1list:(numlist)}} Values to explore for tuning parameter  {p_end}
{synopt :{opt par2name:(string)}} Name of the an optional second tuning parameter of {cmd:command} {p_end}
{synopt :{opt par2list:(numlist)}} Values to explore for the second tuning parameter   {p_end}
{synopt :{opt crit:erion(string)}} Evaluation criterion  {p_end}
{synopt :{opt method(str1 str2)}} str1 specifies train-validation method; str2 specifies corresponding option.  {p_end}
{synopt :{opt nogrid}} Explore all parameter values as a list (do not form a grid) {p_end}
{synopt :{opt options}} Additional options are passed to the estimation command {p_end}
{synopt :{opt predoptions:(string)}} Any prediction options are passed to the prediction command {p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:gridsearch} runs a  user-specified statistical learning (aka  machine learning) algorithm repeatedly with a grid of values corresponding to one or two tuning parameters. This facilities the tuning of statistical learning algorithms.  
Examples of statistical learning algorithms that require tuning include support vector machines, gradient boosting, k-nearest neighbors, random forests.

{pstd}
After evaluating all combinations of values according to {cmd:criterion}, {cmd:gridsearch} lists the 
best combination and the corresponding value of the {cmd:criterion}. Running time (in seconds) is also given.

{pstd}
{cmd:gridsearch} may be very time intensive depending on the estimation command and the number of parameter 
combinations  to explore.
  
{title:Remarks}
{pstd}
Only estimation commands that allow the use of {cmd:predict} after the estimation command can be used.
The program does not currently support the prediction of multiple variables as would be needed, for example, 
for multinomial logistic regression.
 
{pstd}
The {cmd: discrim} command has a slightly different syntax and is listed separately above. It is particularly useful for 
k nearest neighbor :  {cmd: discrim knn}.
 
{marker options}{...}
{title:Options}

{phang}
{opt  par1name:(string)} Name of a tuning parameter of {cmd:command}. {p_end}

{phang}
{opt  par1list:(numlist)} Values of the  tuning parameter to explore. {p_end}

{phang}
{opt  par2name:(string)} Name of an optional second tuning parameter of {cmd:command}. {p_end}

{phang}
{opt  par2list:(numlist)} Values of the second tuning parameter to explore. {p_end}

{phang}
{opt  crit:erion:(string)} Implemented criteria for binary outcomes (classification) is "accuracy" and "AUC" (area under the curve)
 and for continuous outcomes (regression) is "mse". If trainfraction is specified, 
 evaluation occurs on the test observations. If {cmd:cv}  is specified evaluation occurs on all observations. 
 For classification,  if  {cmd:predict}  gives a probability rather than 0/1 classification 
 the probabilities are rounded. {p_end}

{phang}
{opt method(str1 str2)} str1 specifies the the method, str2 the corresponding option. 
Available methods are "trainfraction", "trainvar" and "cv". 

{pmore}
{opt method(trainfraction #)} Fraction of the data used for training. The first ({cmd:trainfraction}*N) observations 
are designated training data, the remainder the test data. To ensure that training data are selected at random, 
the data should be in random sort order before calling {cmd:gridsearch}. {cmd:trainfraction} should be in the range of (0,1).
 
{pmore}
{opt  method(trainvar varname)} Indicator variable (0,1) for whether or not the data are training data. 
This is useful when training observations cannot be sampled at random.
For example, if there are multiple measurements for each person, all measurements for one person should be either in the training or in the test data.

{pmore}
{opt  method(cv #)} Number of folds for crossvalidation. This option requires our command {cmd: crossvalidate} which must be installed first. This option can be very time consuming. 

{phang}
{opt  nogrid} Explore parameter values as a list: the i th value of the first tuning parmaeter is paired with the i th value of the second and third tuning 
parameter.  If not specified, explore all combinations of the values of the tuning parameters (grid). 
  This option has no affect if only one tuning parameter is specified. {p_end}

{phang}
{marker options}{...} 
{opt  options}  Additional options are passed to the estimation command. The same option 
must not be specified twice: tuning parameters must not also be specified as an additional option. {p_end}

{phang}
{opt  predoptions:(string)}  Any prediction options are passed to the prediction command. This is rarely used but useful, for example, for {cmd:randomforest} 
where {cmd:predict} requires specification of either {cmd:class} or {cmd:reg}. {p_end}


{marker examples}{...}
{title:Examples}

{title:Example k nearest neighbor classification}

{pstd} k nearest neighbor classification.  k is the only tuning parameter. Search for values of k=1,2,...,5. 

{phang}{cmd:. sysuse auto}

{pstd} Shuffle

{phang}{cmd:. set seed 793742 }

{phang}{cmd:. generate u = runiform() }

{phang}{cmd:. sort u }

{phang}{cmd:. gridsearch  discrim knn  weight length mpg price , par1name(k) par1list(1/5) group(foreign) criterion(accuracy) method(trainfraction .8) }

{pstd} Gridsearch outputs the best parameter combination. Optionally, can look at the accuracy of all runs:

{phang}{cmd:. matrix gridsearch= r(gridsearch)}

{phang}{cmd:. svmat gridsearch , names(col) }

{phang}{cmd:. list accuracy k seconds in 1/5 }


{title:Example support vector machines regression}

{pstd} We consider two tuning parameters, c and gamma. We first standardize the variables.  This is a toy 
example: the sample size, 74 observations, is too small for a training/test split. 
{cmd: svmachines} is a user written programand and must be downloaded first via {cmd: net search svmachines}.
{* Syntax with parentheses of for loop is weird but works}

{phang}{cmd:. sysuse auto}

{phang}{cmd:. foreach var of varlist weight length mpg headroom  } {

{phang}{cmd:. 		sum `var' }

{phang}{cmd:. 		replace `var'= (`var'-r(mean))/r(sd) }

{phang}{cmd:. } }

{phang}{cmd:. gridsearch  svmachines price foreign  weight length mpg headroom , par1name(c) par1list(0.1 1 10 100 1000 10000)  par2name(gamma) par2list(1 5 10)    criterion(mse) method(trainfraction .5) type(svr) kernel(rbf) }


{title:Example (continued): split into train/validation/test}
{pstd} The previous example used {cmd: trainfraction} to split the data into training and validation data and evaluated the gridsearch on the validation data. Instead, we now wish to split the data into train/validation/test data. We validate the gridsearch on the validation data, without ever using the test data. 

{phang}{cmd:. set seed 793742 }

{phang}{cmd:. generate u = runiform() }

{phang}{cmd:. sort u }

{phang}{cmd:. gen test= _n> 0.8*_N}

{phang}{cmd:. gridsearch  svmachines price foreign  weight length mpg headroom if !test, par1name(c) par1list(0.1 1 10 100 1000 10000)  par2name(gamma) par2list(1 5 10)    criterion(mse) method(trainfraction .5) type(svr) kernel(rbf) }


{title:Example (continued): Use crossvalidation}
{pstd} Instead of splitting the data into training/validation data, we can also use cross-validation. 

{phang}{cmd:. gridsearch mypred svmachines price foreign  weight length mpg headroom, cv(5) par1name(c) par1list(0.1 1 10 100 1000 10000)  par2name(gamma) par2list(1 5 10)  criterion(rmse) type(svr) kernel(rbf) }

{pstd} As before {cmd: if !test} can also be specified (not shown here).

{title:Stored results}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(gridsearch)}}
 Matrix  with one row for each search 
and column names `par1name', `par2name' (if specified), `criterion', seconds
{p_end}

{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(tune1)}}
Best value according to the criterion chosen for tuning parameter 1

{synopt:{cmd:r(tune2)}}
Best value according to the criterion chosen  for tuning parameter 2
{p_end}

{marker authors}{...}
{title:Author}

{pmore} Matthias Schonlau <schonlau@uwaterloo.ca>{p_end}



