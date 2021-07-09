{smcl}
{* 20Aug2020}{...}
{cmd:help r_ml_stata}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:r_ml_stata}{hline 1}}Implementing machine learning regression in Stata{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{hi:r_ml_stata}
{it:outcome} 
[{it:varlist}],
{cmd:mlmodel}{cmd:(}{it:{help r_ml_stata##modeltype:modeltype}}{cmd:)}
{cmd:out_sample}{cmd:(}{it:filename}{cmd:)}
{cmd:in_prediction}{cmd:(}{it:name}{cmd:)}
{cmd:out_prediction}{cmd:(}{it:name}{cmd:)}
{cmd:cross_validation}{cmd:(}{it:name}{cmd:)}
{cmd:seed}{cmd:(}{it:integer}{cmd:)}
[{cmd:save_graph_cv}{cmd:(}{it:name}{cmd:)}]


where: 

{phang} {it:outcome} is a numerical variable. Missing values are not allowed.    

{phang} {it:varlist} is a list of numerical variables representing the features. When a feature is categorical,
please generate the categorical dummies related to this feature. As the command does not do it by default,
it is user's responsibility to generate the appropriate dummies.  
Missing values are not allowed.    
 
 
{title:Description}

{pstd} {cmd:r_ml_stata} is a command for implementing machine learning regression algorithms in Stata 16.
It uses the Stata/Python integration ({browse "https://www.stata.com/python/api16/Data.html":sfi}) 
capability of Stata 16 and allows to implement the following regression
algorithms: elastic net, tree, boosting, random forest, neural network, nearest neighbor,
support vector machine. It provides hyper-parameters' optimal tuning via K-fold cross-validation using greed search.  
This command makes use of the Python {browse "https://scikit-learn.org/stable/":Scikit-learn} API to carry out both cross-validation and prediction.

    
{title:Options}
    
{phang} {cmd:mlmodel}{cmd:(}{it:{help r_ml_stata##modeltype:modeltype}}{cmd:)} 
specifies the machine learning algorithm to be estimated.   

{phang} {cmd:out_sample}{cmd:(}{it:filename}{cmd:)}
requests to provide a new dataset in {it:filename} containing the new 
instances over which estimating predictions. This dataset contains only features.

{phang} {cmd:in_prediction}{cmd:(}{it:name}{cmd:)}
requires to specify a {it:name} for the file that will contain in-sample predictions. 

{phang} {cmd:out_prediction}{cmd:(}{it:name}{cmd:)}
requires to specify a {it:name} for the file that will contain out-sample predictions.
These predictions are those obtained from the option {cmd:out_sample}{cmd:(}{it:filename}{cmd:)}.   

{phang} {cmd:cross_validation}{cmd:(}{it:name}{cmd:)}
requires to specify a {it:name} for the dataset that will contain cross-validation results.
The command uses K-fold cross-validation, with K=10 by default. 

{phang} {cmd:seed}{cmd:(}{it:integer}{cmd:)} requests to specify a integer seed to assure replication
of same results.  

{phang} {cmd:save_graph_cv}{cmd:(}{it:name}{cmd:)} allows to obtain the cross-validation optimal tuning graph drawing both train and test accuracy.   


{marker modeltype}{...}
{synopthdr:modeltype_options}
{synoptline}
{syntab:Model}
{p2coldent : {opt elasticnet}}Elastic net{p_end}
{p2coldent : {opt tree}}Regression tree{p_end}
{p2coldent : {opt randomforest}}Bagging and random forests{p_end}
{p2coldent : {opt boost}}Boosting{p_end}
{p2coldent : {opt nearestneighbor}}Nearest Neighbor{p_end}
{p2coldent : {opt neuralnet}}Neural network{p_end}
{p2coldent : {opt svm}}Support vector machine{p_end}
{synoptline}


{title:Returns}

{pstd} {cmd:r_ml_stata} returns into e-return scalars (if numeric) or macros (if string) 
the "optimal hyper-parameters", the "optimal train accuracy" and the "optimal test accuracy" obtained via
cross-validation.     


{title:Remarks}

{phang} -> Missing values in both {it:outcome} and {it:varlist} are not allowed. 
           Before running this command, please check whether your dataset presents missing values
           and delete them.  

{phang} -> To run this program you need to have both Stata 16 and Python (from version 2.7 onwards) installed.
           Also, the Python Scikit-learn and the Stata Function Interface (SFI) 
           packages must be uploaded before running the command. 

{phang} -> Please, remember to have the most recent up-to-date version of this program installed.


{title:Example}

{phang} . use "r_ml_stata_data_example.dta" , clear

{phang} . r_ml_stata y x1-x13 , mlmodel(tree) in_prediction("in_pred") cross_validation("CV") ///
out_sample("r_ml_stata_data_new_example") out_prediction("out_pred") seed(10) save_graph_cv("graph_cv")


{title:Reference}

{phang}
Gareth, J., Witten, D., Hastie, D.T., Tibshirani, R. 2013. {it:An Introduction to Statistical Learning : with Applications in R}. New York, Springer.


{phang} 
Raschka, S., Mirjalili, V. 2019. {it:Python Machine Learning}. 3rd Edition, Packt Publishing.


{title:Author}

{phang}Giovanni Cerulli{p_end}
{phang}IRCrES-CNR{p_end}
{phang}Research Institute for Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}


{title:Also see}

{psee}
Online: {helpb python}, {helpb c_ml_stata}, {helpb srtree}, {helpb srtree}, {helpb subset}
{p_end}