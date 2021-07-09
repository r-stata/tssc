{smcl}
{* October 11 2014}{...}
{hline}
Help for {hi:loocv}
{hline}

{title:Description}

{p}{cmd:loocv} - Leave-One-Out Cross-Validation.{p_end}

{p}For every observation in the estimating sample, {cmd:loocv} estimates the model specified by the user with all but the ith observation,  
fits the model using the remaining N-1 observations and uses 
the resulting parameters to predict the value of the dependent variable for the ith observation.
The prediction error for the ith variable is stored in memory and {cmd: loocv} proceeds to the next 
observation in the sample.{p_end}

{p}{cmd:loocv} reports three goodness-of-fit measures: the root mean squared error (RMSE), 
the mean absolute error (MAE), and the pseudo-R2 (the square of the correlation
coefficient of the predicted and observed values of the dependent variable).{p_end}

{p}Note that {cmd:loocv} estimates one regression for each observation in the estimating sample,
so it may take a while to run for large estimating samples.

{title:Syntax}

{cmd:loocv} {it:model} [{it:if}] [{it:in}] [weights], [eweights] [{it:model_options}]

{synoptset}{...}
{marker Use}{...}
{synopthdr:Use}
{synoptline}
{synopt:{it:model}}The model one wishes to evaluate, such as "{cmd:reg} yvar x1var x2var" 
(without the quotations).{p_end}
{synopt:{it:weights}}Model weights. These weights are used to estimate the model, so
they must be compatible with the estimation method in use.{p_end}
{synoptline}



{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{it:eweights}}Weights for error evaluation purposes. These may be the same as or different
than the model weights, but must be specified. {cmd:loocv} does not assume that {it: weights} and
{it:eweights} are the same.{p_end}
{synopt:{it:model_options}}Modelling command options (such as {it:fe} for {cmd:xtreg}).{p_end}
{synoptline}

{title:Examples}

{cmd:. sysuse nlsw88}
(NLSW, 1988 extract)

{p}{cmd:. loocv reg wage age collgrad married}{p_end}

 Leave-One-Out Cross-Validation Results 
-----------------------------------------
         Method          |    Value
-------------------------+---------------
Root Mean Squared Errors |   5.5467815
Mean Absolute Errors     |   3.3990273
Pseudo-R2                |   .07084915
-----------------------------------------


{p}{cmd:. loocv reg wage hours grade i.race i.industry i.occupation}{p_end}
 
 Leave-One-Out Cross-Validation Results 
-----------------------------------------
         Method          |    Value
-------------------------+---------------
Root Mean Squared Errors |   5.1635111
Mean Absolute Errors     |   2.9866291
Pseudo-R2                |   .20001635
-----------------------------------------


{p}{cmd:. loocv reg wage union [weight=hours], eweight(hours)}{p_end}
(analytic weights assumed)

 Leave-One-Out Cross-Validation Results 
-----------------------------------------
         Method          |    Value
-------------------------+---------------
Root Mean Squared Errors |   4.1280683
Mean Absolute Errors     |   3.0713142
Pseudo-R2                |   .02064774
-----------------------------------------


{p}{cmd:. sort idcode}

{p}{cmd:. loocv xi: ivreg2 wage collgrad (ttl_exp = age) in 1/100}


 Leave-One-Out Cross-Validation Results 
-----------------------------------------
         Method          |    Value
-------------------------+---------------
Root Mean Squared Errors |   7.4361463
Mean Absolute Errors     |   5.2287439
Pseudo-R2                |   .00001683
-----------------------------------------

{p}{cmd:. ret list}

scalars:
                 r(r2) =  .0000168265967266
                r(mae) =  5.228743877410889
               r(rmse) =  7.436146288561151

{p}{cmd:. mat list r(loocv)}

r(loocv)[3,1]
               LOOCV
     RMSE  7.4361463
      MAE  5.2287439
Pseudo-R2  .00001683



{title:Saved Results}

{p}{cmd:loocv} returns the root mean squared error {bf:r(rmse)}, the mean
absolute deviation {bf:r(mae)}, and the pseudo R squared {bf:r(r2)}. It also stores 
these results in the 3x1 matrix {bf: r(loocv)}.{p_end}

{title:Acknoledgments} 

{p}{cmd:loocv} is based on Ben Daniels' {cmd:crossfold} module, that performs 
x-fold cross-validation. To the extent possible, {cmd:loocv}'s syntax and options 
follow those in {cmd:crossfold} to facilitate its use among users familiar with 
{cmd:crossfold}. Any errors are my own.{p_end}


{title:Author}

Manuel Barron
manuel.barron@gmail.com

{title:References}

{p} Daniels, Benjamin. 2012. "CROSSFOLD: Stata module to perform k-fold cross-validation" 
(https://ideas.repec.org/c/boc/bocode/s457426.html) {p_end}
