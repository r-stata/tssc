{smcl}
{right:version 1.6.6 14.March.2019}
{title:}

{phang}
{cmd:cvauroc} {hline 2} Cross-validated Area Under the Curve for ROC Analysis after Predictive Modelling for Binary Outcomes 
 

{title:Syntax}

{p 4 4 2}
{cmd: cvauroc} {depvar} {varlist} [if] [pw] [{cmd:,} Kfold() Seed() Probit Fit Detail Graph Graphlowess]
{p_end}


{title:Description}

{p 4 4 2}
Receiver operating characteristic (ROC) analysis is used for comparing predictive models, both in model selection and model evaluation.
This method is often applied in clinical medicine and social science to assess the tradeoff between model sensitivity and specificity. 
After fitting a binary logistic regression model with a set of independent variables, the predictive performance of this set of variables 
- as assessed by the area under the curve (AUC) from a ROC curve - must be estimated for a sample (the 'test' sample) that is independent 
of the sample used to predict the dependent variable (the 'training' sample). An important aspect of predictive modeling (regardless of 
model type) is the ability of a model to generalize to new cases. Evaluating the predictive performance (AUC) of a set of independent 
variables using all cases from the original analysis sample tends to result in an overly optimistic estimate of predictive performance. 
K-fold cross-validation can be used to generate a more realistic estimate of predictive performance. To assess this ability in situations 
in which the number of observations is not very large, {hi:cross-validation} and {hi:bootstrap} strategies are useful. {hi:cvauroc} is a 
Stata rclass program that implements k-fold cross-validation for the AUC for a binary outcome after fitting a logit or probit regression model.
{hi:cvauroc} averages the AUCs corresponding to each fold and applies the bootstrap procedure to the cross-validated AUC to obtain statistical 
inference and 95% bias corrected confidence intervals (CI). Furthermore, {hi:cvauroc} optionally provides the cross-validated fitted probabilities 
for the dependent variable or outcome contianed in a new variable named {hi:_fit}, the sensitivity and specificity, contained in two new variables 
named, {hi:_sen} and {hi:_spe}, and the plot for the mean cvAUC and k-fold ROC curves.

{title:Options}

{p 4 4 2}
{bf:pw} This option allows the user to include sampling weights (e.g. inverse-probability of censoring or treatment weights -IPCW or IPTW-).
{p_end}

{p 4 4 2}
{bf:Kfold} This option allows the user to set the number of random folds to an integer greater or equal than 0 (default = 10). 
{p_end}

{p 4 4 2}
{bf:Seed} This option allows the user to set the random seed to an integer greater than 1 (default = 7777).
{p_end} 

{p 4 4 2}
{bf:Probit} This option allows the user to fit a probit rather than a logit model (default).
{p_end} 

{p 4 4 2}
{bf:Fit} This option allows the user to generate a new variable (_fit) containing the cross-validated probabilities for the dependent variable or outcome.
{p_end} 

{p 4 4 2}
{bf:Detail} This option allows the user to tabulate the prevalence of the outcome, the sensitivity, specificity and false positive values by each level of the outcome fitted probabilities.
Furthermore, it creates two new variables containing the cross-validated sensitivity (_Sen) and specificity (_Spe) for the independent variable or predictor.
{p_end} 

{p 4 4 2}
{bf:Graph} This option allows the user to graph the empirical cross-validated ROC curves for the respective k folds specified by the user.
{p_end} 

{p 4 4 2}
{bf:Graphlowess} This option allows the user to graph a smoothed version of the mean cross-validated ROC curve and the empirical ROC curves for the respective k folds specified by the user.
{p_end} 


{title:Example}

. use http://www.stata-press.com/data/r14/cattaneo2.dta
(Excerpt from Cattaneo (2010) Journal of Econometrics 155: 138-154)

. gen lbw = cond(bweight<2500,1,0.)

. cvauroc lbw mage medu mmarried prenatal fedu mbsmoke mrace order, kfold(10) seed(1972) probit fit det 

1-fold (N=465).........AUC =  0.726
2-fold (N=464).........AUC =  0.752
3-fold (N=464).........AUC =  0.660
4-fold (N=464).........AUC =  0.621
5-fold (N=464).........AUC =  0.703
6-fold (N=465).........AUC =  0.742
7-fold (N=464).........AUC =  0.579
8-fold (N=464).........AUC =  0.641
9-fold (N=464).........AUC =  0.730
10-fold(N=464).........AUC =  0.704

Model:probit

Seed:1972

----------------------------------------------------------------
Cross-validated (cv) mean AUC, SD and Bootstrap Corrected 95%CI
----------------------------------------------------------------
cvMean AUC:                 | 0.6857
Booststrap corrected 95%CI: | 0.6348, 0.7079
cvSD AUC:                   | 0.0578
----------------------------------------------------------------

------------------------------------------------------------------
Mean cross-validated Sen, Spe and false(+) at lbw predicted values
------------------------------------------------------------------

Prevalence of lbw: 6.01%
------------------------

 _Pp |      _sen      _spe       _fp
-----+------------------------------
0.01 |     99.83      0.52     99.48
0.02 |     98.21      4.09     95.91
0.03 |     88.82     20.12     79.88
0.04 |     73.69     49.21     50.79
0.05 |     66.05     64.58     35.42
0.06 |     60.17     69.31     30.69
	   
(output omitted ...)

0.39 |      0.27     99.98      0.02
------------------------------------------

*******************************************************
*  Naive performance based on non-crossvalidated AUC  *
*******************************************************

. logistic lbw mage medu mmarried prenatal fedu mbsmoke mrace order

Logistic regression                             Number of obs     =      4,642
                                                LR chi2(8)        =     137.10
                                                Prob > chi2       =     0.0000
Log likelihood = -986.35435                     Pseudo R2         =     0.0650

------------------------------------------------------------------------------
         lbw | Odds Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        mage |   .9959165   .0140441    -0.29   0.772     .9687674    1.023826
        medu |   .9451338   .0283732    -1.88   0.060     .8911276    1.002413
    mmarried |   .6109995   .1014788    -2.97   0.003     .4412328    .8460849
    prenatal |   .5886787    .073186    -4.26   0.000     .4613759    .7511069
        fedu |   1.040936   .0214226     1.95   0.051     .9997838    1.083782
     mbsmoke |   2.145619   .3055361     5.36   0.000     1.623086    2.836376
       mrace |   .3789501    .057913    -6.35   0.000     .2808648    .5112895
       order |    1.05529   .0605811     0.94   0.349     .9429895    1.180964
       _cons |   .3468141   .1498299    -2.45   0.014     .1487176    .8087812
------------------------------------------------------------------------------

. predict fitted, pr

. roctab lbw fitted

                      ROC                    -Asymptotic Normal--
           Obs       Area     Std. Err.      [95% Conf. Interval]
     ------------------------------------------------------------
         4,642     0.6939       0.0171        0.66041     0.72749

{title:Authors}

{p 4 4 2}
Miguel Angel Luque-Fernandez   {break}
LSHTM, NCDE, Cancer Survival Group, London, UK   {break}
Email: miguel-angel.luque@lshtm.ac.uk   {break}

{p 4 4 2}
Camille Maringe   {break}
LSHTM, NCDE, Cancer Survival Group, London, UK   {break}
Email: camille.maringe at lshtm.ac.uk  {break}

{p 4 4 2}
Daniel Redondo-Sanchez  {break}
Biomedical Research Institute of Granada (ibs.Granada)   {break}
Email: daniel.redondo.easp at juntadeandalucia.es  {break}

{title:Acknowledgements}

{p 4 4 2}
Miguel Angel Luque Fernandez is supported by the Spanish National Institute of Health, Carlos III Miguel Servet I Investigator
Award (CP17/00206).

{title:References}

{p 4 4 2}
Miguel Angel Luque-Fernandez (2016), Crossvalidation in Epidemiology {browse "http://scholar.harvard.edu/malf/presentations/cross-validation-epidemiology": Presentation}
{p_end}

{p 4 4 2}
StataCorp. 2015. Stata Statistical Software: Release 14. College Station, TX: StataCorp LP.
{p_end}

{p 4 4 2}
Hastie T., Tibshirani R., Friedman J., (2013). The elements of Statistical Learning, Data Mining, Inference and Prediction. Springer Series in Statistics.
{p_end}

{title:Also see}

{psee}
Online:  {helpb crossfold} {helpb roctab} {helpb lsens} {helpb lroc} {helpb rocreg}
{p_end}
