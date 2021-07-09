{smcl}
{* *! version 1.0.09  15oct2019}{...}
{hline}
{cmd:help cvlasso}{right: lassopack v1.3.1}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: cvlasso} {hline 2}}Program for cross-validation using lasso, square-root lasso, elastic net, adaptive lasso and post-OLS estimators{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 4} Full syntax

{p 8 14 2}
{cmd:cvlasso}
{it:depvar} {it:regressors} 
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[{cmd:,}} {cmdab:alp:ha(}{it:numlist}{cmd:)}
{cmdab:alphac:ount(}{it:int}{cmd:)}
{cmd:sqrt}
{cmdab:ada:ptive}
{cmdab:adal:oadings(}{it:string}{cmd:)}
{cmdab:adat:heta(}{it:real}{cmd:)}
{cmd:ols}
{cmdab:l:ambda}{cmd:(}{it:real}{cmd:)}
{cmdab:lc:ount}{cmd:(}{it:integer}{cmd:)}
{cmdab:lminr:atio}{cmd:(}{it:real}{cmd:)}
{cmdab:lmax:}{cmd:(}{it:real}{cmd:)}
{cmd:lopt}
{cmd:lse}
{cmdab:notp:en(}{it:varlist}{cmd:)}
{cmdab:par:tial(}{it:varlist}{cmd:)}
{cmdab:pload:ings(}{it:string}{cmd:)}
{cmdab:unitl:oadings}
{cmdab:pres:td}
{cmd:fe}
{cmd:noftools}
{cmdab:noc:onstant}
{cmdab:tolo:pt}{cmd:(}{it:real}{cmd:)}
{cmdab:tolz:ero}{cmd:(}{it:real}{cmd:)}
{cmdab:maxi:ter}{cmd:(}{it:int}{cmd:)}
{cmdab:nf:olds}{cmd:(}{it:int}{cmd:)}
{cmdab:foldv:ar}{cmd:(}{it:varname}{cmd:)}
{cmdab:savef:oldvar}{cmd:(}{it:varname}{cmd:)}
{cmdab:roll:ing}
{cmd:h}{cmd:(}{it:int}{cmd:)}
{cmdab:or:igin}{cmd:(}{it:int}{cmd:)}
{cmdab:fixedw:indow}
{cmd:seed}{cmd:(}{it:real}{cmd:)}
{cmd:plotcv}
{cmd:plotopt}{cmd:(}{it:string}{cmd:)}
{bind:{cmd:saveest}{cmd:(}{it:string}{cmd:)}]}

{p 8 14 2}
Note: the {opt fe} option will take advantage of the {helpb cvlasso##SG2016:ftools}
package (if installed) for the fixed-effects transform;
the speed gains using this package can be large.
See {rnethelp "http://fmwww.bc.edu/RePEc/bocode/f/ftools.sthlp":help ftools}
or click on {stata "ssc install ftools"} to install.

{synoptset 20}{...}
{synopthdr:Estimators}
{synoptline}
{synopt:{cmdab:a:lpha(}{it:numlist}{cmd:)}}
a scalar elastic net parameter or an ascending list of elastic net parameters.
If the number of alpha values is larger than 1,
cross-validation is conducted over alpha (and lambda).
The default is alpha=1, which corresponds to the lasso estimator.
The elastic net parameter controls the degree of L1-norm (lasso-type) 
to L2-norm (ridge-type) penalization.
Each alpha value must be in the interval [0,1]. 
{p_end}
{synopt:{cmdab:alphac:ount(}{it:real}{cmd:)}}
number of alpha values used for cross-validation across alpha. 
By default, cross-validation is only conducted across lambda, but not over alpha.
Ignored if {cmd:alpha()} is specified.
{p_end}
{synopt:{cmd:sqrt}}
square-root lasso estimator.
{p_end}
{synopt:{cmdab:ada:ptive}}
adaptive lasso estimator.
The penalty loading for predictor j is set to 1/abs(beta0(j))^theta 
where beta0(j) is the OLS estimate or univariate OLS estimate if p>n.
Theta is the adaptive exponent, and can be controlled using the {cmdab:adat:heta(}{it:real}{cmd:)} option.
{p_end}
{synopt:{cmdab:adal:oadings(}{it:string}{cmd:)}}
alternative initial estimates, beta0, used for calculating adaptive loadings. 
For example, this could be the vector e(b) from an initial {help lasso2} estimation.
The elements of the vector are raised to the power -theta (note the minus).
See {cmdab:ada:ptive} option.
{p_end}
{synopt:{cmdab:adat:heta(}{it:real}{cmd:)}}
exponent for calculating adaptive penalty loadings. See {cmdab:ada:ptive} option. Default=1. 
{p_end}
{synopt:{cmd:ols}}
post-estimation OLS. 
Note that cross-validation using OLS will in most cases lead to no unique optimal lambda (since MSPE is a step function over lambda).
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
See overview of {help lasso2##estimators:estimation methods}.

{synoptset 20}{...}
{synopthdr:Lambda(s)}
{synoptline}
{synopt:{cmdab:l:ambda}{cmd:(}{it:numlist}{cmd:)}}
a scalar lambda value or list of descending lambda values. Each lambda value must be greater than 0.
If not specified, the default list is used which is given by {cmd:exp(rangen(log(lmax),log(lminratio*lmax),lcount))} (see {helpb mf_range}). 
{p_end}
{synopt:{cmdab:lc:ount}{cmd:(}{it:integer}{cmd:)}†}
number of lambda values for which the solution is obtained. Default is 100.
{p_end}
{synopt:{cmdab:lminr:atio}{cmd:(}{it:real}{cmd:)}†}
ratio of minimum to maximum lambda. {cmd:lminratio} must be between 0 and 1. Default is 1/1000.
{p_end}
{synopt:{cmdab:lmax:}{cmd:(}{it:real}{cmd:)}†}
maximum lambda value. Default is 2*max(X'y), and max(X'y) in the case of the square-root lasso
(where X is the pre-standardized regressor matrix and y is the vector of the response variable). 
{p_end}
{synopt:{cmd:lopt}}
after cross-validation, estimate model with lambda that minimized the mean-squared prediction error
{p_end}
{synopt:{cmd:lse}}
after cross-validation, estimate model with largest lambda that is within one standard deviation from lopt
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
† Not applicable if lambda() is specified.

{synoptset 20}{...}
{synopthdr:Loadings & standardization}
{synoptline}
{synopt:{cmdab:notp:en(}{it:varlist}{cmd:)}}
sets penalty loadings to zero for predictors in {it:varlist}.  Unpenalized predictors are always included in the model.
{p_end}
{synopt:{cmdab:par:tial(}{it:varlist}{cmd:)}}
variables in {it:varlist} are partialled out prior to estimation. 
{p_end}
{synopt:{cmdab:pload:ings(}{it:matrix}{cmd:)}}
a row-vector of penalty loadings; overrides the default standardization loadings (in the case of the lasso, =sqrt(avg(x^2))).
The size of the vector should equal the number of predictors (excluding partialled out variables and excluding the constant).
{p_end}
{synopt:{cmdab:unitl:oadings}}
penalty loadings set to a vector of ones; overrides the default standardization loadings (in the case of the lasso, =sqrt(avg(x^2)).
{p_end}
{synopt:{cmdab:pres:td}}
dependent variable and predictors are standardized prior to estimation 
rather than standardized "on the fly" using penalty loadings.
See {help lasso2##standardization:here} for more details.
By default the coefficient estimates are un-standardized (i.e., returned in original units). 
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
See {help lasso2##standardization:discussion of standardization} in the {help lasso2} help file. 
Also see Section {help cvlasso##transform:Data transformations in cross-validation} below.

{synoptset 20}{...}
{synopthdr:FE & constant}
{synoptline}
{synopt:{cmd:fe}}
within-transformation is applied prior to estimation. Requires data to be xtset.
{p_end}
{synopt:{opt noftools}}
do not use FTOOLS package for fixed-effects transform (slower; rarely used)
{p_end}
{synopt:{cmdab:noc:onstant}}
suppress constant from estimation.
Default behaviour is to partial the constant out (i.e., to center the regressors). 
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:Optimization}
{synoptline}
{synopt:{cmdab:tolo:pt}{cmd:(}{it:real}{cmd:)}}
tolerance for lasso shooting algorithm (default=1e-10)
{p_end}
{synopt:{cmdab:tolz:ero}{cmd:(}{it:real}{cmd:)}}
minimum below which coeffs are rounded down to zero (default=1e-4)
{p_end}
{synopt:{cmdab:maxi:ter}{cmd:(}{it:int}{cmd:)}}
maximum number of iterations for the lasso shooting algorithm (default=10,000)
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:Fold variable options}
{synoptline}
{synopt:{cmd:nfolds(}{it:integer}{cmd:)}}
the number of folds used for {it:K}-fold cross-validation. Default is 10.
{p_end}
{synopt:{cmd:foldvar(}{it:varname}{cmd:)}}
user-specified variable with fold IDs, ranging from 1 to #folds. 
If not specified, fold IDs are randomly generated such that each fold is of approximately equal size.
{p_end}
{synopt:{cmd:savefoldvar(}{it:varname}{cmd:)}}
saves the fold ID variable.
Not supported in combination with {cmd:rolling}.
{p_end}
{synopt:{cmdab:roll:ing}}
uses rolling {it:h}-step ahead cross-validation. Requires the data to be tsset.
{p_end}
{synopt:{cmd:h(}{it:integer}{cmd:)}‡}
changes the forecasting horizon. Default is 1.
{p_end}
{synopt:{cmdab:or:igin(}{it:integer}{cmd:)}‡}
controls the number of observations in the first training dataset.
{p_end}
{synopt:{cmdab:fixedw:indow}‡}
ensures that the size of the training dataset is always the same.
{p_end}
{synopt:{cmd:seed(}{it:real}{cmd:)}}
set seed for the generation of a random fold variable. Only relevant if fold variable is randomly generated.
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
‡ Only applicable with {opt rolling} option.

{synoptset 20}{...}
{synopthdr:Plotting options}
{synoptline}
{synopt:{cmdab:plotc:v}}
plots the estimated mean-squared prediction error as a function of ln(lambda)
{p_end}
{synopt:{cmdab:ploto:pt(}{it:varlist}{cmd:)}}
overwrites the default plotting options. All options are passed on to {helpb line}. 
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:Display options}
{synoptline}
{synopt:{cmd:omitgrid}}
suppresses the display of mean-squared prediction errors
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:Store lasso2 results}
{synoptline}
{synopt:{cmd:saveest(}{it:string}{cmd:)}}
saves {help lasso2} results from each step of the cross-validation in {it:string1}, ..., {it:stringK} where {it:K} is the number of folds. 
Intermediate results can be restored using {helpb estimates restore}. 
{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
{opt cvlasso} may be used with time-series or panel data,
in which case the data must be tsset or xtset first;
see help {helpb tsset} or {helpb xtset}.

{pstd}
All varlists may contain time-series operators or factor variables; see help varlist.

{p 4} Replay syntax

{p 8 14 2}
{cmd:cvlasso}
{bind:[{cmd:,}}
{cmd:lopt}
{cmd:lse}
{cmdab:postres:ults}
{cmdab:plotc:v}{cmd:(}{it:method}{cmd:)}
{bind:{cmdab:ploto:pt}{cmd:(}{it:string}{cmd:)}]}

{synoptset 20}{...}
{synopthdr:Replay options}
{synoptline}
{synopt:{cmd:lopt}}
show estimation results using the model corresponding to lambda={cmd:e(lopt)}
{p_end}
{synopt:{cmd:lse}}
show estimation results using the model corresponding to lambda={cmd:e(lse)}
{p_end}
{synopt:{cmdab:postres:ults}}
post {help lasso2} estimation results (to be used in combination with {cmd:lse} or {cmd:lopt})
{p_end}
{synopt:{cmdab:plotc:v}{cmd:(}{it:method}{cmd:)}}
see plotting options above
{p_end}
{synopt:{cmdab:ploto:pt}{cmd:(}{it:string}{cmd:)}}
see plotting options above
{p_end}
{synoptline}
{p2colreset}{...}

{phang}
Postestimation:

{p 8 14 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} 
{cmd:xb}
{opt u}
{opt e}
{opt ue}
{opt xbu}
{cmdab:r:esiduals}
{cmd:lopt}
{cmd:lse}
{bind:{cmdab:noi:sily}]}

{synoptset 20}{...}
{synopthdr:Predict options}
{synoptline}
{synopt:{cmd:xb}}
compute predicted values (the default)
{p_end}
{synopt:{cmdab:r:esiduals}}
compute residuals
{p_end}
{synopt:{opt e}}
generate overall error component e(it). 
Only after {opt fe}.
{p_end}
{synopt:{opt ue}}
generate combined residuals, i.e., 
u(i) + e(it). Only after {opt fe}.
{p_end}
{synopt:{opt xbu}}
prediction including fixed effect, i.e., 
a + xb + u(i). Only after {opt fe}.
{p_end}
{synopt:{opt u}}
fixed effect, i.e., 
u(i). Only after {opt fe}.
{p_end}
{synopt:{cmd:lopt}}
use lambda that minimized the mean-squared prediction error
{p_end}
{synopt:{cmd:lse}}
use the largest lambda that is within one standard deviation from lopt
{p_end}
{synopt:{cmdab:noi:sily}}
displays beta used for prediction. 
{p_end}
{synoptline}
{p2colreset}{...}


{title:Contents}

{phang}{help cvlasso##description:Description}{p_end}
{phang}{help cvlasso##folds:Partitioning of folds}{p_end}
{phang}{help cvlasso##transform:Data transformations in cross-validation}{p_end}
{phang}{help cvlasso##examples:Examples of usage}{p_end}
{phang}{help cvlasso##examples_general:--General demonstration}{p_end}
{phang}{help cvlasso##examples_rolling1:--Rolling cross-validation with time-series data}{p_end}
{phang}{help cvlasso##examples_rolling2:--Rolling cross-validation with panel data}{p_end}
{phang}{help cvlasso##saved_results:Saved results}{p_end}
{phang}{help cvlasso##references:References}{p_end}
{phang}{help cvlasso##website:Website}{p_end}
{phang}{help cvlasso##installation:Installation}{p_end}
{phang}{help cvlasso##acknowledgements:Acknowledgements}{p_end}
{phang}{help cvlasso##citation:Citation of lassopack}{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt cvlasso} implements {it:K}-fold cross-validation and {it:h}-step ahead rolling cross-validation for the following estimators: lasso, square-root lasso, adaptive lasso, ridge regression, elastic net. 
See {help lasso2} for more information about these estimators.

{pstd}
The purpose of cross-validation is to assess the out-of-sample prediction performance of the estimator. 

{pstd}
The steps for {it:K}-fold cross-validation over lambda can be summarized as follows:

{pstd}
1. Split the data into {it:K} groups, referred to as folds, of approximately equal size. Let n({it:k}) denote the number of observations in the {it:k}th data partition with {it:k}=1,...,{it:K}.

{pstd}
2. The first fold is treated as the validation dataset 
and the remaining {it:K}-1 parts constitute the training dataset.
The model is fit to the training data for a given value of lambda. 
The resulting estimate is denoted as betahat(1,lambda).
The mean-squared prediction error for group 1 is computed as

		MSPE(1,lambda)=1/n(1)*sum([y(i) - x(i)'betahat(1,lambda)]^2)	
	
{pstd}
for all i in the first data partition.
	
{pstd}
The procedure is repeated for {it:k}=2,...,{it:K}. 
Thus, MSPE(2,lambda), ..., MSPE({it:K},lambda) are calculated.

{pstd}
3. The {it:K}-fold cross-validation estimate of the MSPE, which serves as a measure of prediction performance, is

		CV(lambda)=1/{it:K}*sum(MSPE({it:k},lambda)).

{pstd}
4. Step 2 and 3 are repeated for a range of lambda values.

{pstd}
{it:h}-step ahead rolling cross-validation proceeds in a similar way, except that the partitioning of training and validation takes account of the time-series structure.
Specifically, the training window is iteratively extended (or moved forward) by one step.  
See below for more details.

{marker folds}{...}
{title:Partitioning of folds}

{pstd}
{cmd:cvlasso} supports {it:K}-fold cross-validation and cross-validation using rolling {it:h}-step ahead forecasts. 
{it:K}-fold cross-validation is the standard approach and relies on a fold ID variable. 
Rolling {it:h}-step ahead cross-validation is applicable with time-series data, or panels with large time dimension.

{pstd}
{ul:K-fold cross-validation}

{pstd}
The fold ID variable marks the observations which are used as validation data. 
For example, a fold ID variable (with three folds) could have the following structure:

	    {c TLC}{hline 7}{c -}{hline 7}{c -}{hline 2}{c TRC}
	    {c |} {res}fold   y      x  {txt}{c |}
	    {c LT}{hline 7}{c -}{hline 7}{c -}{hline 2}{c RT}
	    {c |} {res} 3     y1     x1 {txt}{c |}
	    {c |} {res} 2     y2     x2 {txt}{c |}
	    {c |} {res} 1     y3     x3 {txt}{c |}
	    {c |} {res} 3     y4     x4 {txt}{c |}
	    {c |} {res} 1     y5     x5 {txt}{c |}
	    {c |} {res} 2     y6     x6 {txt}{c |}
	    {c BLC}{hline 7}{c -}{hline 7}{c -}{hline 2}{c BRC}

{pstd}
It is instructive to illustrate the cross-validation process implied by the above fold ID variable. 
Let T denote a training observation and V denote a validation point. 
The division of folds can be summarized as follows: 

      		 Step
					
      		1  2  3  
              {c TLC}{c -}       {c -}{c TRC}
            1 {c |} T  T  V {c |} 
            2 {c |} T  V  T {c |}
            3 {c |} V  T  T {c |} 
        i   4 {c |} T  T  V {c |}
            5 {c |} V  T  T {c |}
            6 {c |} T  V  T {c |}
              {c BLC}{c -}       {c -}{c BRC}

{pstd}
In the first step, the 3rd and 5th observation are in the validation dataset and remaining data constitute the training dataset. 
In the second step, the validation dataset includes the 2nd and 6th observation, etc.

{pstd}
By default, the fold ID variable is randomly generated such that each fold is of approximately equal size. 
The default number of folds is equal to 10, but can be changed using the {cmd:nfolds()} option.

{pstd}
{ul:Rolling h-step ahead cross-validation}

{pstd}
To allow for time-series data, {cmd:cvlasso} supports cross-validation using rolling {it:h}-step forecasts (option {cmd:rolling}); see Hyndman, {helpb cvlasso##Hyndman2016:2016}.
To use rolling cross-validation, the data must be tsset or xtset. 
The options {cmd:h()} and {cmd:origin()} control the forecasting horizon and the starting point of the rolling forecast, respectively.

{pstd}
The following matrix illustrates the division between training and validation data over the course of the cross-validation for the case of 1-step ahead forecasting (the default when {cmd:rolling} is specified). 
					
      		    Step
					
      		1  2  3  4  5
              {c TLC}{c -}             {c -}{c TRC}
            1 {c |} T  T  T  T  T {c |} 
            2 {c |} T  T  T  T  T {c |}
            3 {c |} T  T  T  T  T {c |} 
        t   4 {c |} V  T  T  T  T {c |}
            5 {c |} .  V  T  T  T {c |}
            6 {c |} .  .  V  T  T {c |}
            7 {c |} .  .  .  V  T {c |}
            8 {c |} .  .  .  .  V {c |}
              {c BLC}{c -}             {c -}{c BRC}

{pstd}
In the first iteration (illustrated in the first column), the first three observations are in the training dataset, which corresponds to {cmd:origin(3)}. 
The option {cmd:h()} controls the forecasting horizon used for cross-validation (the default is 1). 
If {cmd:h(2)} is specified, which corresponds to 2-step ahead forecasting, the structure changes to:       
            
      		    Step
					
      		1  2  3  4  5
              {c TLC}{c -}             {c -}{c TRC}
            1 {c |} T  T  T  T  T {c |} 
            2 {c |} T  T  T  T  T {c |}
            3 {c |} T  T  T  T  T {c |} 
            4 {c |} .  T  T  T  T {c |} 
        t   5 {c |} V  .  T  T  T {c |}
            6 {c |} .  V  .  T  T {c |}
            7 {c |} .  .  V  .  T {c |}
            8 {c |} .  .  .  V  . {c |}
            9 {c |} .  .  .  .  V {c |}
              {c BLC}{c -}             {c -}{c BRC}
              
{pstd}
The {cmdab:fixedw:indow} option ensures that the size of the training dataset is always the same. In this example (using {cmd:h(1)}), each step uses three data points for training: 
					
      		    Step
					
      		1  2  3  4  5
              {c TLC}{c -}             {c -}{c TRC}
            1 {c |} T  .  .  .  . {c |} 
            2 {c |} T  T  .  .  . {c |}
            3 {c |} T  T  T  .  . {c |} 
        t   4 {c |} V  T  T  T  . {c |}
            5 {c |} .  V  T  T  T {c |}
            6 {c |} .  .  V  T  T {c |}
            7 {c |} .  .  .  V  T {c |}
            8 {c |} .  .  .  .  V {c |}
              {c BLC}{c -}             {c -}{c BRC}


{marker transform}{...}
{title:Data transformations in cross-validation}

{pstd}
An important principle in cross-validation is that
the training dataset should not contain information from the validation dataset.
This mimics the real-world situation where out-of-sample predictions are made
not knowing what the true response is.
The principle applies not only to individual observations
(the training and validation data do not overlap)
but also to data transformations.
Specifically, data transformations applied to the training data
should not use information from the validation data or full dataset.
In particular, standardization using the full sample violates this principle.

{pstd}
{opt cvlasso} implements this principle for all data transformations supported by {help lasso2}:
data standardization, fixed effects and partialling-out.
In most applications using the estimators supported by {opt cvlasso},
predictors are standardized to have mean zero and unit variance.
The above principle means that the standardization applied to the training data
is based only on observations in the training data;
further, the standardization transformation applied to the validation data
will also be based only on the means and variances of the observations in the training data.
The same applies to the fixed effects transformation:
the group means used to implement the within transformation
to both the training data and the validation data
are calculated using only the training data.
Similarly, the projection coefficients used to "partial out" variables
are estimated using only the training data and are applied
to both the training dataset and the validation dataset.

{marker examples}{...}
{title:General introduction using K-fold cross-validation}

{pstd}
{ul:Dataset}

{pstd}
The dataset is available through Hastie et al. ({help lasso2##Hastie2015:2015}) on the {browse "https://web.stanford.edu/~hastie/ElemStatLearn/":authors' website}. 
The following variables are included in the dataset of 97 men:

{synoptset 10 tabbed}{...}
{p2col 5 19 23 2: Predictors}{p_end}
{synopt:lcavol}log(cancer volume){p_end}
{synopt:lweight}log(prostate weight){p_end}
{synopt:age}patient age{p_end}
{synopt:lbph}log(benign prostatic hyperplasia amount){p_end}
{synopt:svi}seminal vesicle invasion{p_end}
{synopt:lcp}log(capsular penetration){p_end}
{synopt:gleason}Gleason score{p_end}
{synopt:pgg45}percentage Gleason scores 4 or 5{p_end}

{synoptset 10 tabbed}{...}
{p2col 5 19 23 2: Outcome}{p_end}
{synopt:lpsa}log(prostate specific antigen){p_end}

{pstd}Load prostate cancer data.{p_end}
{phang2}. {stata "insheet using https://web.stanford.edu/~hastie/ElemStatLearn/datasets/prostate.data, clear tab"}{p_end}

{marker examples_general}{...}
{pstd}
{ul:General demonstration}

{pstd}10-fold cross-validation across lambda. 
The lambda value that minimizes the mean-squared prediction 
error is indicated by an asterisk (*). 
A hat (^) marks the largest lambda at which the MSPE is within one 
standard error of the minimal MSPE. 
The former is returned in {cmd:e(lopt)}, the latter in {cmd:e(lse)}.
We use {cmd:seed(123)} throughout this demonstration for replicability of folds.{p_end}
{phang2}. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, seed(123)"}{p_end}
{phang2}. {stata "di e(lopt)"}{p_end}
{phang2}. {stata "di e(lse)"}{p_end}

{pstd}
{ul:Estimate the full model}

{pstd}Estimate the the full model with either e(lopt) or e(lse).
{cmd:cvlasso} internally calls {help lasso2} with lambda=lopt or lse, respectively.{p_end}
{phang2}. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, lopt seed(123)"}{p_end}
{phang2}. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, lse seed(123)"}{p_end}

{pstd}The same as above can be achieved using the replay syntax.{p_end}
{phang2}. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, seed(123)"}{p_end}
{phang2}. {stata "cvlasso, lopt"}{p_end}
{phang2}. {stata "cvlasso, lse"}{p_end}

{pstd}If {cmdab:postres:ults} is specified, {cmd:cvlasso} posts the {help lasso2} estimation results.{p_end}
{phang2}. {stata "cvlasso, lopt postres"}{p_end}
{phang2}. {stata "ereturn list"}{p_end}

{pstd}
{ul:Cross-validation over lambda and alpha}

{pstd}{cmd:alpha()} can be a scalar or list of elastic net parameters. 
Each alpha value must lie in the interval [0,1]. 
If {cmd:alpha()} is a list longer than 1, {cmd:cvlasso} cross-validates over lambda and alpha.
The table at the end of the output indicates the alpha value that minimizes the empirical MSPE.{p_end}
{phang2}. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, alpha(0 0.1 0.5 1) lc(10) seed(123)"}{p_end}

{pstd}Alternatively, the {cmd:alphacount()} option can be used 
to control the number of alpha values used for cross-validation.{p_end}
{phang2}. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, alphac(3) lc(10) seed(123)"}{p_end}

{pstd}
{ul:Plotting}

{pstd}We can plot the estimated mean-squared prediction error over lambda.
Note that the plotting feature is not supported if we cross-validate over alpha.{p_end}
{phang2}. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, seed(123) plotcv"}{p_end}

{pstd}
{ul:Prediction}

{pstd}The {cmd:predict} postestimation command allows to obtain predicted values
 and residuals for lambda=e(lopt) or lambda=e(lse).{p_end}
{phang2}. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, seed(123)"}{p_end}
{phang2}. {stata "cap drop xbhat1"}{p_end}
{phang2}. {stata "predict double xbhat1, lopt"}{p_end}
{phang2}. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, seed(123)"}{p_end}
{phang2}. {stata "cap drop xbhat2"}{p_end}
{phang2}. {stata "predict double xbhat2, lse"}{p_end}

{pstd}
{ul:Store intermediate steps}

{pstd}{cmd:cvlasso} calls internally {help lasso2}.
To see intermediate estimation results, we can use the {cmd:saveest}{cmd:(}{it:string}{cmd:)} option.{p_end}
{phang2}. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, seed(123) nfolds(3) saveest(step)"}{p_end}
{phang2}. {stata "estimates dir"}{p_end}
{phang2}. {stata "estimates restore step1"}{p_end}
{phang2}. {stata "estimates replay step1"}{p_end}

{marker examples_rolling1}{...}
{title:Time-series example using rolling h-step ahead cross-validation}

{pstd}Load airline passenger data.{p_end}
{phang2}. {stata "webuse air2, clear"}{p_end}

{pstd}There are 144 observations in the sample.
{cmd:origin()} controls the sample range used for 
training and validation. 
In this example, {cmd:origin(130)} implies that data up to 
and including {it:t}=130
 are used for training in the first iteration.
Data points {it:t}=131 to 144 are successively used for validation. 
The notation `{it:a}-{it:b} ({it:v})' indicates that data {it:a} to  {it:b} 
 are used for estimation (training), and data point {it:v} is used for forecasting (validation).
Note that the training dataset starts with t=13 since 12 lags are used as predictors.{p_end}
{phang2}. {stata "cvlasso air L(1/12).air, rolling origin(130)"}{p_end}

{pstd}The optimal model includes lags 1, 11 and 12.{p_end}
{phang2}. {stata "cvlasso, lopt"}{p_end}

{pstd}The option {cmd:h()} controls the forecasting horizon (default=1).{p_end}
{phang2}. {stata "cvlasso air L(1/12).air, rolling origin(130) h(2)"}{p_end}

{pstd}In the above examples, the size of the training dataset increases by one data point each step.
To keep the size of the training dataset fixed, specify {cmdab:fixedw:indow}.{p_end}
{phang2}. {stata "cvlasso air L(1/12).air, rolling origin(130) fixedwindow"}{p_end}

{pstd}Cross-validation over alpha with alpha={0, 0.1, 0.5, 1}.{p_end}
{phang2}. {stata "cvlasso air L(1/12).air, rolling origin(130) alpha(0 0.1 0.5 1)"}{p_end}

{pstd}Plot mean-squared prediction errors against ln(lambda).{p_end}
{phang2}. {stata "cvlasso air L(1/12).air, rolling origin(130)"}{p_end}
{phang2}. {stata "cvlasso, plotcv"}{p_end}

{marker examples_rolling2}{...}
{title:Panel data example using rolling h-step ahead cross-validation}

{pstd}Rolling cross-validation can also be applied to panel data.
For demonstration, load Grunfeld data.{p_end}
{phang2}. {stata "webuse grunfeld, clear"}{p_end}

{pstd}Apply {it:1}-step ahead cross-validation.{p_end}
{phang2}. {stata "cvlasso mvalue L(1/10).mvalue, rolling origin(1950)"}{p_end}

{pstd}The model selected by cross-validation:{p_end}
{phang2}. {stata "cvlasso, lopt"}{p_end}

{pstd}Same as above with fixed size of training data.{p_end}
{phang2}. {stata "cvlasso mvalue L(1/10).mvalue, rolling origin(1950) fixedwindow"}{p_end}

{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:cvlasso} saves the following in {cmd:e()}:

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: scalars}{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}
{synopt:{cmd:e(nfolds)}}number of folds{p_end}
{synopt:{cmd:e(lmax)}}largest lambda{p_end}
{synopt:{cmd:e(lmin)}}smallest lambda{p_end}
{synopt:{cmd:e(lcount)}}number of lambdas{p_end}
{synopt:{cmd:e(sqrt)}}=1 if sqrt-lasso, 0 otherwise{p_end}
{synopt:{cmd:e(adaptive)}}=1 if adaptive loadings are used, 0 otherwise{p_end}
{synopt:{cmd:e(ols)}}=1 if post-estimation OLS, 0 otherwise{p_end}
{synopt:{cmd:e(partial_ct)}}number of partialled out predictors{p_end}
{synopt:{cmd:e(notpen_ct)}}number of not penalized predictors{p_end}
{synopt:{cmd:e(prestd)}}=1 if pre-standardized, 0 otherwise{p_end}
{synopt:{cmd:e(nalpha)}}number of alphas{p_end}
{synopt:{cmd:e(h)}}forecasting horizon for rolling forecasts (only returned if {opt rolling} is specified){p_end}
{synopt:{cmd:e(origin)}}number of observations in first training dataset (only returned if {opt rolling} is specified){p_end}
{synopt:{cmd:e(lopt)}}optimal lambda (may be missing if no unique minimum MSPE){p_end}
{synopt:{cmd:e(lse)}}lambda se (may be missing if no unique minimum MSPE){p_end}
{synopt:{cmd:e(mspemin)}}minimum MSPE{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: macros}{p_end}
{synopt:{cmd:e(cmd)}}cvlasso{p_end}
{synopt:{cmd:e(method)}}indicates which estimator is used (e.g. lasso, elastic net){p_end}
{synopt:{cmd:e(cvmethod)}}indicates whether {it:K}-fold or rolling cross-validation is used{p_end}
{synopt:{cmd:e(varXmodel)}}predictors (excluding partialled-out variables){p_end}
{synopt:{cmd:e(varX)}}predictors{p_end}
{synopt:{cmd:e(partial)}}partialled out predictors{p_end}
{synopt:{cmd:e(notpen)}}not penalized predictors{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}
		
{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: matrices}{p_end}		
{synopt:{cmd:e(lambdamat)}}column vector of lambda values{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: functions}{p_end}
{synopt:{cmd:e(sample)}}estimation sample{p_end}

{pstd}
{ul:In addition, if {cmd:cvlasso} cross-validates over alpha and lambda:}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: scalars}{p_end}
{synopt:{cmd:e(alphamin)}}optimal alpha, i.e., the alpha that minimizes the empirical MSPE{p_end}
			
{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: macros}{p_end}
{synopt:{cmd:e(alphalist)}}list of alpha values{p_end}
			
{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: matrices}{p_end}
{synopt:{cmd:e(mspeminmat)}}minimum MSPE for each alpha{p_end}

{pstd}
{ul:In addition, if {cmd:cvlasso} cross-validates over lambda only:}
 
{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: scalars}{p_end}
{synopt:{cmd:e(alpha)}}elastic net parameter{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: matrices}{p_end}
{synopt:{cmd:e(mspe)}}matrix of MSPEs for each fold and lambda where 
each column corresponds to one lambda value and each row corresponds to one fold. {p_end}
{synopt:{cmd:e(mmspe)}}column vector of MSPEs for each lambda{p_end}
{synopt:{cmd:e(cvsd)}}column vector standard deviation of MSPE (for each lambda){p_end}
{synopt:{cmd:e(cvupper)}}column vector equal to MSPE + 1 standard deviation{p_end}
{synopt:{cmd:e(cvlower)}}column vector equal to MSPE - 1 standard deviation{p_end}

{marker references}{...}
{title:References}

{marker SG2016}{...}
{phang}
Correia, S. 2016.
FTOOLS: Stata module to provide alternatives to common Stata commands optimized for large datasets.
{browse "https://ideas.repec.org/c/boc/bocode/s458213.html"}
{p_end}

{marker Hyndman2016}{...}
{phang}
Hyndman, Rob J. (2016). Cross-validation for time series. {it:Hyndsight blog}, 5 December 2016. 
{browse "https://robjhyndman.com/hyndsight/tscv/"}
{p_end}

{phang}
See {help lasso2##references:lasso2} for further references.
{p_end}

{marker website}{title:Website}

{pstd}
Please check our website {browse "https://statalasso.github.io/"} for more information. 

{marker installation}{title:Installation}

{pstd}
To get the latest stable version of {it:lassopack} from our website, 
check the installation instructions at {browse "https://statalasso.github.io/installation/"}.
We update the stable website version more frequently than the SSC version.

{pstd}
To verify that {it:lassopack} is correctly installed, 
click on or type {stata "whichpkg lassopack"} (which requires {helpb whichpkg} 
to be installed; {stata "ssc install whichpkg"}).

{marker acknowledgements}{title:Acknowledgements}

{pstd}Thanks to Sergio Correia for advice on the use of the FTOOLS package.{p_end}


{marker citation}{...}
{title:Citation of cvlasso}

{pstd}{opt cvlasso} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Ahrens, A., Hansen, C.B., Schaffer, M.E. 2018.
LASSOPACK: Stata module for lasso, square-root lasso, elastic net, ridge, adaptive lasso estimation and cross-validation
{browse "http://ideas.repec.org/c/boc/bocode/s458458.html"}{p_end}

{phang}Ahrens, A., Hansen, C.B., Schaffer, M.E. 2019.
lassopack: Model selection and prediction with regularized regression in Stata
{browse "https://arxiv.org/abs/1901.05397"}{p_end}

{title:Authors}

	Achim Ahrens, Public Policy Group, ETH Zurich, Switzerland
	achim.ahrens@gess.ethz.ch
	
	Christian B. Hansen, University of Chicago, USA
	Christian.Hansen@chicagobooth.edu

	Mark E Schaffer, Heriot-Watt University, UK
	m.e.schaffer@hw.ac.uk

{title:Also see}

{p 7 14 2}
Help: {helpb lasso2}, {helpb lassologit}, {helpb rlasso} (if installed){p_end}
