{smcl}
{* *! version 4oct2019}{...}
{hline}
{cmd:help lassologit}{right: lassopack v1.3.1}
{cmd:help rlassologit}
{cmd:help cvlassologit}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{hi: lassologit} {hline 2}}Main program for regularized logistic regression{p_end}
{p2colreset}{...}

{p2colset 5 21 23 2}{...}
{p2col:{hi: cvlassologit} {hline 2}}Program for {it:K}-fold cross-validation with logistic regression{p_end}
{p2colreset}{...}

{p2colset 5 20 22 2}{...}
{p2col:{hi: rlassologit} {hline 2}}Program for regularized logistic regression with rigorous penalization{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 4} {ul:Full syntax}

{p 8 14 2}
{cmd:lassologit}
{it:depvar} {it:regressors} 
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[{cmd:,}} {cmdab:postl:ogit}
{cmdab:nocon:stant}
{cmdab:l:ambda}{cmd:(}{it:numlist}{cmd:)}
{cmdab:lc:ount}{cmd:(}{it:integer}{cmd:)}
{cmdab:lminr:atio}{cmd:(}{it:real}{cmd:)}
{cmdab:lmax:}{cmd:(}{it:real}{cmd:)}
{opt lambdan}
{cmd:lic}{cmd:(}{it:string}{cmd:)}
{cmdab:ebicx:i}{cmd:(}{it:real}{cmd:)}
{cmdab:postres:ults}
{cmdab:notp:en(}{it:varlist}{cmd:)}
{opt spsi(matrix)}
{cmd:nostd}
{cmd:stdcoef}
{opt holdout(varname)}
{cmdab:lossm:easure}{cmd:(}{it:string}{cmd:)}
{cmdab:tolo:pt}{cmd:(}{it:real}{cmd:)}
{cmdab:tolz:ero}{cmd:(}{it:real}{cmd:)}
{cmdab:maxi:ter}{cmd:(}{it:int}{cmd:)}
{cmdab:quadp:rec}
{cmdab:noseqr:ule}
{cmdab:plot:path}{cmd:(}{it:method}{cmd:)}
{cmdab:plotv:ar}{cmd:(}{it:varlist}{cmd:)}
{cmdab:ploto:pt}{cmd:(}{it:string}{cmd:)}
{cmdab:plotl:abel}
{opt long}
{cmdab:verb:ose}
{cmd:ic}{cmd:(}{it:string}{cmd:)}
{bind:{cmdab:nopro:gressbar}]}

{p 8 14 2}
{cmd:cvlassologit}
{it:depvar} {it:regressors} 
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[{cmd:,}} 
{cmdab:postl:ogit}
{cmdab:nocon:stant}
{cmdab:l:ambda}{cmd:(}{it:numlist}{cmd:)}
{cmdab:lc:ount}{cmd:(}{it:integer}{cmd:)}
{cmdab:lminr:atio}{cmd:(}{it:real}{cmd:)}
{cmdab:lmax:}{cmd:(}{it:real}{cmd:)}
{opt lambdan}
{cmd:lopt}
{cmd:lse}
{cmdab:postres:ults}
{cmdab:notp:en(}{it:varlist}{cmd:)}
{opt spsi(matrix)}
{cmd:nostd}
{cmdab:tolo:pt}{cmd:(}{it:real}{cmd:)}
{cmdab:tolz:ero}{cmd:(}{it:real}{cmd:)}
{cmdab:maxi:ter}{cmd:(}{it:int}{cmd:)}
{cmdab:quadp:rec}
{cmdab:noseqr:ule}
{cmdab:nf:olds}{cmd:(}{it:integer}{cmd:)}
{cmdab:foldv:ar}{cmd:(}{it:varname}{cmd:)}
{cmdab:savefoldv:ar}{cmd:(}{it:new varname}{cmd:)}
{cmd:seed}{cmd:(}{it:integer}{cmd:)}
{cmdab:strat:ified}
{opt storeest(string)}
{cmdab:lossm:easure}{cmd:(}{it:string}{cmd:)}
{cmd:plotcv}
{cmdab:ploto:pt}{cmd:(}{it:string}{cmd:)}
{opt long}
{cmdab:verb:ose}
{bind:{cmd:tabfold}]}

{p 8 14 2}
{cmd:rlassologit}
{it:depvar} {it:regressors} 
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[{cmd:,}} 
{cmdab:postl:ogit}
{cmdab:nocon:stant}
{opt gamma(real)}
{opt c(real)}
{opt holdout(varname)}
{cmdab:lossm:easure}{cmd:(}{it:string}{cmd:)}
{cmdab:tolo:pt}{cmd:(}{it:real}{cmd:)}
{cmdab:tolz:ero}{cmd:(}{it:real}{cmd:)}
{cmdab:maxi:ter}{cmd:(}{it:int}{cmd:)}
{cmdab:quadp:rec}
{cmdab:noseqr:ule}
{bind:{cmdab:verb:ose}]}


{p 4} {ul:Options}

{synoptset 20}{...}
{synopthdr:Estimators}
{synoptline}
{synopt:{cmdab:postl:ogit}}
use post-estimation logit. 
{cmd:lassologit}: If lambda is a list, 
post-estimation OLS results are displayed and returned in {cmd:e(betas)}.
If lambda is a scalar (or {cmd:rlassologit} is used),
post-estimation OLS is always displayed, 
and this option controls whether standard or post-estimation 
OLS results are stored in {cmd:e(b)}.
{cmd:cvlassologit}: post-estimation logit 
is used for cross-validation.
{p_end}
{synopt:{cmdab:nocon:stant}}
suppress constant from estimation (not recommended). 
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}

{synoptset 20}{...}
{synopthdr:Lambda(s)}
{synoptline}
{synopt:{cmdab:l:ambda}{cmd:(}{it:numlist}{cmd:)}}
a scalar lambda value or list of descending lambda values. Each lambda value must be greater than 0.
If not specified, the default list is used which is given by {cmd:exp(rangen(log(lmax),log(lminratio*lmax),lcount))} (see {helpb mf_range}). 
{p_end}
{synopt:{cmdab:lc:ount}{cmd:(}{it:integer}{cmd:)}†}
number of lambda values for which the solution is obtained. Default is 50.
{p_end}
{synopt:{cmdab:lminr:atio}{cmd:(}{it:real}{cmd:)}†}
ratio of minimum to maximum lambda. {cmd:lminratio} must be between 0 and 1. Default is 1/1000.
{p_end}
{synopt:{cmdab:lmax:}{cmd:(}{it:real}{cmd:)}†}
maximum lambda value. 
{p_end}
{synopt:{cmd:lambdan}}
uses {it:lambda}:={it:lambda}/{it:N} in the objective function.
This makes {it:lambda} comparable with {it:glmnet} 
(Friedman, Hastie & Tibshirani, {helpb lassologit##Friedman2010:2010}).
{p_end}
{synopt:{cmd:lic}{cmd:(}{it:string}{cmd:)}}
{cmd:lassologit}: after first {cmd:lassologit} estimation using list of lambdas, estimate model corresponding to minimum information criterion.
'aic', 'bic', 'aicc', and 'ebic' (the default) are allowed.
Note the lower case spelling.
See {help lassologit##informationcriteria:Information criteria} for the definition of each information criterion.
{p_end}
{synopt:{cmdab:ebicx:i}{cmd:(}{it:real}{cmd:)}}
{cmd:lassologit}: controls the {it:xi} parameter of the EBIC. 
{it:xi} needs to lie in the [0,1] interval.
{it:xi}=0 is equivalent to the BIC. 
The default choice is {it:xi}=1-log(n)/(2*log(p)). 
{p_end}
{synopt:{cmd:lopt}}
{cmd:cvlassologit}: after cross-validation, estimate model with lambda that minimized the mean-squared prediction error
{p_end}
{synopt:{cmd:lse}}
{cmd:cvlassologit}: after cross-validation, estimate model with largest lambda that is within one standard deviation from lopt
{p_end}
{synopt:{cmdab:postres:ults}} Used in combination with {cmd:lic()},
{cmd:lse} or {cmd:lopt}. 
Stores estimation results of the model selected by information criterion in {cmd:e()}.
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
The above options are only applicable for {cmd:lassologit} and {cmd:cvlassologit}.
† Not applicable if {cmdab:l:ambda}{cmd:(}{it:numlist}{cmd:)} is specified.

{synoptset 20}{...}
{synopthdr:Rigorous lambda}
{synoptline}
{synopt:{opt gamma(real)}}
specifies the significance level {it:gamma} 
for the rigorous lambda. The default is 0.05/max((p*log(n),n)).
{p_end}
{synopt:{opt c(real)}}
specified slack parameter {it:c} for
the rigorous lambda (default = 1.1)
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
The above options are only applicable for {cmd:rlassologit}.

{synoptset 20}{...}
{synopthdr:Loadings & standardization}
{synoptline}
{synopt:{cmdab:notp:en(}{it:varlist}{cmd:)}}
sets penalty loadings to zero for predictors in {it:varlist}.  Unpenalized predictors are always included in the model.
{p_end}
{synopt:{opt spsi(matrix)}}
a row-vector of penalty loadings 
(in standard units);
overrides the default which is a vector of ones.
The size of the vector should equal the number of predictors 
(excluding partialled
out variables and excluding the constant).
{p_end}
{synopt:{cmd:nostd}}
do not standardize the predictors. Default is to 
standardize predictors to have unit variance.
{p_end}
{synopt:{cmd:stdcoef}}
return coefficient estimates in standardized units.
Default is to return coefficients in original units.
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}

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
{synopt:{cmdab:quadp:rec}}
use {helpb mf_quadcross} instead of {helpb mf_cross} 
in the shooting algorithm. This will slow down
the program (considerably) 
but lead to
(in our experience minor)
gains in precision.
This will also disable the sequential strong rule, 
see next. 
{p_end}
{synopt:{cmdab:noseqr:ule}}
disables use of sequential strong rule, which discards
some predictors before running the shooting algorithm
(see Section 5 in 
Tibshirani et al., {helpb lassologit##Tib2012:2012}).
The sequential rule leads to speed gains.
NB: sequential rule is automatically disabled if intercept is 
omitted.
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:Cross-validation}
{synoptline}
{synopt:{cmd:nfolds(}{it:integer}{cmd:)}}
the number of folds used for {it:K}-fold cross-validation. Default is 5.
{p_end}
{synopt:{cmd:foldvar(}{it:varname}{cmd:)}}
user-specified variable with fold IDs, ranging from 1 to #folds. 
If not specified, fold IDs are randomly generated such that each fold is of approximately equal size.
{p_end}
{synopt:{cmd:savefoldvar(}{it:varname}{cmd:)}}
saves the fold ID variable.
{p_end}
{synopt:{cmd:seed(}{it:real}{cmd:)}}
set seed for the generation of a random fold variable. Only relevant if fold variable is randomly generated.
{p_end}
{synopt:{cmdab:strat:ified}}
observations are divided into folds 
such that number of successes / failures is 
approximately the same across folds.
Recommended especially if share of 
successes is close to 0 or 1. 
{p_end}
{synopt:{cmd:storeest(}{it:string}{cmd:)}}      
saves {cmd:lassologit} results from each step of the cross-validation in {it:string1},
..., {it:stringK} where {it:K} is the number of folds.  Intermediate results can
be restored using {helpb estimates restore}.
{p_end}
{synopt:{cmd:holdout(}{it:varname}{cmd:)}}
defines a holdout sample. {cmd:lassologit} and
{cmd:rlassologit} only. 
{it:varname} should be a binary variable where 1 indicates 
that observations are excluded from the estimation. 
Estimated loss is returned in {cmd:e(loss)}.
{p_end}
{synopt:{cmdab:lossm:easure(}{it:string}{cmd:)}}
loss measure used for cross-validation 
or for the holdout sample.
"deviance" and "class" (miss-classification error) 
are supported. Deviance is the default.
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
Only applicable for {cmd:cvlassologit}.

{marker plottingopts}{...}
{synoptset 20}{...}
{synopthdr:Plotting {cmd:lassologit}}
{synoptline}
{synopt:{cmdab:plot:path(}{it:method}{cmd:)}}
plots the coefficients path as a function of the L1-norm ({it:norm}), lambda ({it:lambda}) 
or the log of lambda ({it:lnlambda}) 
{p_end}
{synopt:{cmdab:plotv:ar(}{it:varlist}{cmd:)}}
list of variables to be included in the plot
{p_end}
{synopt:{cmdab:ploto:pt(}{it:string}{cmd:)}}
additional plotting options passed on to {helpb line}. 
For example, use {cmd:plotopt(legend(off))} to turn off the legend.
{p_end}
{synopt:{cmdab:plotl:abel}}
displays variable labels in graph. 
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
{it:Note:} Plotting with {cmd:lassologit} is not 
available if lambda is a scalar value.

{marker plottingopts}{...}
{synoptset 20}{...}
{synopthdr:Plotting {cmd:cvlassologit}}
{synoptline}
{synopt:{cmd:plotcv}}
plots the coefficients path as a function of the L1-norm ({it:norm}), lambda ({it:lambda}) 
or the log of lambda ({it:lnlambda}) 
{p_end}
{synopt:{cmdab:ploto:pt(}{it:string}{cmd:)}}
additional plotting options passed on to {helpb line}. 
For example, use {cmd:plotopt(legend(off))} to turn off the legend.
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}

{synoptset 20}{...}
{synopthdr:Display options}
{synoptline}
{synopt:{opt long}†}
show long output, 
applicable for {cmd:lassologit}
and {cmd:cvlassologit}.
{p_end}
{synopt:{opt ver:bose}}
show additional output
{p_end}
{synopt:{cmd:tabfold}}
{cmd:cvlassologit}: show frequency
table of fold variable 
{p_end}
{synopt:{cmd:ic}{cmd:(}{it:string}{cmd:)}†}
controls which information criterion is shown in the output.
'aic', 'bic', 'aicc', and 'ebic' (the default' are allowed).
Note the lower case spelling.
See {help lassologit##informationcriteria:Information criteria} 
for the definition of each information criterion.
{p_end}
{synopt:{cmdab:nopro:gressbar}}
{cmd:lassologit}: do not show progressbar
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}


{p 4} {ul:Replay syntax}

{pstd}
{cmd:lassologit} and {cmd:cvlassologit} support replay syntay. 
The replay syntax can be used to 
retrieve estimation results for the models selected by information
criteria (using the {opt lic()}) option or 
the model selected by cross-validation (using 
{opt lse} or {opt lopt}).
 
{p 8 14 2}
{cmd:lassologit}
{bind:[{cmd:,}}
{cmdab:plot:path}{cmd:(}{it:method}{cmd:)}
{cmdab:plotv:ar}{cmd:(}{it:varlist}{cmd:)}
{cmdab:ploto:pt}{cmd:(}{it:string}{cmd:)}
{cmdab:plotl:abel}
{opt long}
{cmdab:postres:ults}
{cmd:lic}{cmd:(}{it:string}{cmd:)}
{bind:{cmd:ic}{cmd:(}{it:string}{cmd:)}]}

{p 8 14 2}
{cmd:cvlassologit}
{bind:[{cmd:,}}
{cmdab:plot:path}{cmd:(}{it:method}{cmd:)}
{cmdab:plotv:ar}{cmd:(}{it:varlist}{cmd:)}
{cmdab:ploto:pt}{cmd:(}{it:string}{cmd:)}
{cmdab:plotl:abel}
{opt long}
{cmdab:postres:ults}
{cmd:lic}{cmd:(}{it:string}{cmd:)}
{bind:{cmd:ic}{cmd:(}{it:string}{cmd:)}]}


{p 4} {ul:Prediction}

{p 8 14 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} 
{cmd:xb}
{cmdab:p:r}
{cmdab:c:lass}
{cmdab:postl:ogit}
{cmd:lse}
{cmd:lopt}
{opt lic(string)}
{bind:{cmdab:noi:sily}}

{synoptset 20}{...}
{synopthdr:Predict options}
{synoptline}
{synopt:{cmd:xb}}
compute predicted values (the default)
{p_end}
{synopt:{cmdab:p:r}}
predicted probabilities
{p_end}
{synopt:{cmdab:c:lass}}
predicted class (either 1 or 0)
{p_end}
{synopt:{cmdab:postl:ogit}}
use post-logit (default is to use {cmd:e(b)}
{p_end}
{synopt:{cmd:lic}{cmd:(}{it:string}{cmd:)}}
after {cmd:lassologit}: selects which information criterion to use for prediction.
{p_end}
{synopt:{cmd:lopt}}
after {cmd:cvlassologit}: use lambda that minimizes
 the mean-squared prediction error
{p_end}
{synopt:{cmd:lse}}
after {cmd:cvlassologit}: use
largest lambda that is within one standard deviation
from lopt
{p_end}
{synopt:{cmdab:noi:sily}}
show estimation output if re-estimation required
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}


{p 4} {ul:Notes}

{pstd}
All varlists may contain time-series operators or factor variables; see {stata "help varlist"}.


{title:Contents}

{phang}{help lassologit##description:Description}{p_end}
{phang}{help lassologit##coordinate:Coordinate descent algorithm}{p_end}
{phang}{help lassologit##penalization:Penalization level}{p_end}
{phang}{help lassologit##crossvalidation:Cross-validation}{p_end}
{phang}{help lassologit##informationcriteria:Information criteria}{p_end}
{phang}{help lassologit##rigorous:Rigorous penalization}{p_end}
{phang}{help lassologit##technical:Technical notes}{p_end}
{phang}{help lassologit##example:Example using Spam data}{p_end}
{phang}{help lassologit##example_data:--Data set}{p_end}
{phang}{help lassologit##example_intro:--Introduction}{p_end}
{phang}{help lassologit##example_information:--Information criteria}{p_end}
{phang}{help lassologit##example_cv:--Cross-validation}{p_end}
{phang}{help lassologit##example_rigorous:--Rigorous penalization}{p_end}
{phang}{help lassologit##example_prediction:--Prediction}{p_end}
{phang}{help lassologit##example_holdout:--Holdout option}{p_end}
{phang}{help lassologit##example_plot_lassologit:--Plotting with lassologit}{p_end}
{phang}{help lassologit##example_plot_cvlassologit:--Plotting with cvlassologit}{p_end}
{phang}{help lassologit##saved_results:Saved results}{p_end}
{phang}{help lassologit##references:References}{p_end}
{phang}{help lassologit##website:Website}{p_end}
{phang}{help lassologit##installation:Installation}{p_end}
{phang}{help lassologit##acknowledgements:Acknowledgements}{p_end}
{phang}{help lassologit##citation:Citation of lassologit}{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt lassologit} implements logistic lasso regression. 
The logistic lasso maximizes the penalized log likelihood:

	max  1/N sum_i { y(i) * log p(x(i)) + (1-y(i)) * log(1-p(x(i))) }
					- lambda * ||Psi*beta||[1], 
	
{pstd}
where 

{synoptset 8}{...}
{synopt:y(i)}
is a binary response that is either 1 or 0,
{p_end}
{synopt:beta}
is a {it:p}-dimensional parameter vector,
{p_end}
{synopt:x(i)}
is a {it:p}-dimensional vector of predictors for observation i,
{p_end}
{synopt:p(x(i))}
is the probability that y(i) takes the value 1 given x(i); p(x(i)) = exp(x(i)'beta) / (1 + exp(x(i)'beta)),
{p_end}
{synopt:lambda}
is the overall penalty level,
{p_end}
{synopt:||.||[1]}
denotes the L(1) vector norm,
{p_end}
{synopt:Psi}
is a {it:p} by {it:p} diagonal matrix of predictor-specific penalty loadings. Note that {cmd:lassologit} 
treats Psi as a row vector.
{p_end}
{synopt:N}
number of observations
{p_end}
{p2colreset}{...}
	
{pstd}
{cmd:lassologit} uses coordinate descent algorithms
for logistic lasso as described in 
{helpb lassologit##Friedman2010:Friedman 2010}, Section 3. 


{marker penalization}{...}
{title:Penalization level: choice of lambda}

{pstd}
Penalized regression methods 
rely on tuning parameters that control the degree and type of penalization. 
Logistic lasso relies on the tuning parameter {it:lambda}
which determines the level penalization.
We offer three approaches for selecting the "optimal" lambda value
implemented in {cmd:lassologit}, {cmd:cvlassologit}
and {cmd:rlassologit}:

{pstd}
(1) The penalty level may be chosen by cross-validation in order to optimize 
out-of-sample prediction performance. 
{it:K}-fold cross-validation is implemented in {cmd:cvlassologit}.  

{pstd}
(2) Theoretically justified and feasible penalty levels and loadings are available for the 
logistic lasso via {cmd:rlassologit}. 

{pstd}
(3) Lambda can also be selected using information criteria.
{cmd:lassologit} calculates four information criteria: 
Akaike Information Criterion (AIC; Akaike, {helpb lassologit##Akaike1974:1974}),
Bayesian Information Criterion (BIC; Schwarz, {helpb lassologit##Schwarz1978:1978}),
Extended Bayesian information criterion (EBIC; Chen & Chen, {helpb lassologit##Chen2008:2008})
and the corrected AIC (AICc; Sugiura, {helpb lassologit##Sugiura1978:1978},
 and Hurvich, {helpb lassologit##Hurvich1989:1989}). 


{marker crossvalidation}{...}
{title:K-fold cross-validation}

{pstd}
{cmd:cvlassologit} implements {it:K}-fold cross-validation.
The purpose of cross-validation is to assess the out-of-sample
prediction (classification) performance. 
 
{pstd}
{ul:Cross-validation procedure}

{pstd}
{it:K}-fold cross-validation divides the data randomly
(or based on the user-specified {opt foldvar(varname)}
into {it:K} folds, i.e., data partitions of approximately 
equal size. In each step, one fold is left out of the estimation
(training) sample and used for validation. 
The prediction (classification) performance
is assessed based on loss measures.
{cmd:cvlassologit} offers two loss measures:
deviance and miss-classification error (defined below).
For more information, see {helpb cvlasso} (for the linear case).

{pstd}
{ul:Stratified cross-validation}

{pstd}
Simple {it:K}-fold cross-validation might fail
with randomly generated folds, 
or produce misleading results, 
if the share of successes (y=1) or 
failures (y=0) is low. The {cmdab:strat:ified}
option ensures that the number of success/failures
is approximately the same across folds.
The {opt tabfold} option can be useful in this context;
it asks {cmd:cvlassologit} to show the 
frequency distribution of successes/failures
across folds.

{pstd}
{ul:Loss measures}

{pstd} 
The prediction performance is assessed 
based on two loss measures:
deviance and miss-classification. 
Deviance is the default and is defined as:

	Deviance = -2 * {y0 :* log(p0) :+ (1:-y0):*log(1:-p0)} 

{pstd}
where y0 is the response in the validation data
and p0 are the predicted probabilities.	

{pstd}
The missclassification error is the average number
of wrongly classified cases, and can
be specified using {opt lossmeasure(class)}.


{marker informationcriteria}{...}
{title:Information criteria}
 
{pstd} 
The information criteria supported by {cmd:lassologit} are 
the Akaike information criterion (AIC, Akaike, {helpb lassologit##Akaike1974:1974}),
the Bayesian information criterion (BIC, Schwarz, {helpb lassologit##Schwarz1978:1978}),
the corrected AIC (Sugiura, {helpb lassologit##Sugiura1978:1978}; Hurvich, {helpb lassologit##Hurvich1989:1989}),
and the Extended BIC (Chen & Chen, {helpb lassologit##Chen2008:2008}). 
These are given by (omitting dependence on lambda and alpha):

	AIC	= -2*LL + 2*{it:df}
	BIC	= -2*LL + {it:df}*log(N) 
	AICc	= AIC + (2*{it:df}({it:df}+1))/(N-{it:df}-1)
	EBIC	= BIC + 2*{it:xi}*{it:df}*log(p)

{pstd} 
where LL is the log-likelihood
and {it:df}(lambda,alpha) is the effective degrees of freedom, 
which is a measure of model complexity.
{it:df} is approximated by the number of predictors selected.

{pstd}
By default, {cmd:lassologit} displays EBIC in the output, 
but all four information criteria are stored in {cmd:e(aic)}, {cmd:e(bic)}, {cmd:e(ebic)} and {cmd:e(aicc)}. 
See help file of {helpb lasso2} for more information.


{marker rigorous}{...}
{title:Rigorous penalization}

{pstd}
The theory-driven ("rigorous") penalty level
used by {cmd:rlassologit} is: 

	lambda = {it:c}/2 sqrt({it:N}) Phi^(-1)(1-{it:gamma})

{pstd}
where {it:c} is a slack parameter (default = 1.1),
Phi(.) is the standard normal CDF and
{it:gamma} is the significance level.
The default for {it:gamma} is 0.05/max((p*log(n),n)).
The approach requires the predictors to be standardized such that mean(x(i)^2)=1.
The penalty level is motivated by self-normalized moderate deviation theory,
and is aimed at overruling the noise associated with the data-generating process.
See Belloni, Chernozhukov & Wei ({helpb lassologit##Belloni2016:2016}).

{marker technical}{...}
{title:Technical notes}

{pstd}
{ul:Standardization}

{pstd}
{opt lassologit} centers and standardizes the predictors before estimation. 
The coefficient estimates are returned in original scale. If the 
{cmd:stdcoef} option is used, coefficients are returned in standardized units.
{opt nostd} can be used to estimate with predictors in original scale.

{pstd}
{ul:Constant}

{pstd}
The constant is not penalized by default. 
Thus, the constant is always included
in the model.
To omit the constant, 
use {cmdab:nocons:tant} (not recommended).


{marker example}{...}
{title:Example using Spam data}

{marker example_data}{...}
{pstd}
{ul:Data set}

{pstd}
For demonstration we consider the Spambase Data Set 
from the Machine Learning Repository. 
The data includes 4,601 observations and 57 variables.
The aim is to predict whether an email is spam 
(i.e., unsolicited commercial e-mail) or not.
Each observation corresponds to one email.

{synoptset 10 tabbed}{...}
{p2col 5 19 23 2: Predictors}{p_end}
{synopt:v1-v48}percentage of words in the e-mail that match a specific {it:word},
i.e. 100 * (number of times the word appears in the e-mail) divided by
total number of words in e-mail. 
To see which word each predictor corresponds to, see link below. {p_end}
{synopt:v49-v54}percentage of characters in the e-mail that match a specific {it:character},
i.e. 100 * (number of times the character appears in the e-mail) divided by
total number of characters in e-mail. 
To see which character each predictor corresponds to, see link below.{p_end}
{synopt:v55}average length of uninterrupted sequences of capital letters{p_end}
{synopt:v56}length of longest uninterrupted sequence of capital letters{p_end}
{synopt:v57}total number of capital letters in the e-mail{p_end}

{synoptset 10 tabbed}{...}
{p2col 5 19 23 2: Outcome}{p_end}
{synopt:v58}denotes whether the e-mail was considered spam (1)
 or not (0). {p_end}
 
{pstd}
For more information
about the data 
see {browse "https://archive.ics.uci.edu/ml/datasets/spambase"}.

{pstd}Load spam data.{p_end}
{phang2}. {stata "insheet using https://archive.ics.uci.edu/ml/machine-learning-databases/spambase/spambase.data, clear comma"}{p_end}

{marker example_intro}{...}
{pstd}
{ul:Introduction to {cmd:lassologit}}

{pstd}
The basic syntax for {cmd:lassologit} is to specify the dependent variable
followed by a list of predictors:

{phang2}. {stata "lassologit v58 v1-v57"}{p_end}

{pstd}
The output of {cmd:lassologit} shows the penalty levels (lambda), 
the number of predictors included (s), the L1-Norm, one information criterion
(EBIC by default), McFadden's Pseudo-R-squared and which predictors
are included/removed from the model.

{pstd}
By default, one line per knot is shown. Knots are points at which
predictors enter or leave the model. By specifying {opt long}, an 
extended output with one row for each lambda is shown.

{phang2}. {stata "lassologit, long"}{p_end}

{pstd}
To obtain the logistic lasso estimate for a scalar lambda or a list
of lambdas, the {opt lambda(numlist)} option can be used. 
For example:

{phang2}. {stata "lassologit v58 v1-v57, lambda(40 20)"}{p_end}
{phang2}. {stata "ereturn list"}{p_end}

{pstd}
And for one lambda:

{phang2}. {stata "lassologit v58 v1-v57, lambda(40)"}{p_end}
{phang2}. {stata "ereturn list"}{p_end}

{pstd}
Note that output and the objects stored in {opt e()}
depend on whether lambda is only one value or a list of more than one value.

{marker example_information}{...}
{pstd}
{ul:Information criteria}

{pstd}
To estimate the model selected by one of the information criteria, 
use the {cmd:lic()} option:

{phang2}. {stata "lassologit v58 v1-v57"}{p_end}
{phang2}. {stata "lassologit, lic(ebic)"}{p_end}
{phang2}. {stata "lassologit, lic(aicc)"}{p_end}

{pstd}
In the above example, we use the replay syntax that works 
similar to a post-estimation command. 
The same can also be achieved in one line:

{phang2}. {stata "lassologit v58 v1-v57, lic(ebic)"}{p_end}

{pstd}
When {cmd:lic()} is used, 
{cmd:lassologit} reports the logistic lasso estimates
and the post-logit estimates (from applying logit estimation to 
the model selected by the logitistic lasso)
for the value of lambda selected by the specified 
information criterion.

{pstd}
Note that {cmd:lic()} does not change the estimation 
results in memory. The advantage is that this way
{cmd:lic()} can be used multiple times to compare 
results without that we need to re-estimate the model.

{pstd}
To store the model selected by one of the information 
criteria, use {cmdab:postres:ults}:

{phang2}. {stata "lassologit, lic(ebic) postresults"}{p_end}

{marker example_cv}{...}
{pstd}
{ul:Cross-validation with {cmd:cvlassologit}}

{pstd}
{cmd:cvlassologit} implements {it:K}-fold
cross-validation where the data is by default 
randomly partitioned.

{pstd}
Here, we use {it:K}=3 and {opt seed(123)}
to set the seed for reproducibility. 
(Be patient, this takes a minute.)

{phang2}. {stata "cvlassologit v58 v1-v57, nfolds(3) seed(123)"}{p_end}

{pstd}
The output shows the prediction performance
measured by deviance for each lambda value. 
To estimate the model selected by cross-validation 
we can specify {cmd:lopt} or {cmd:lse} using the
replay syntax.

{phang2}. {stata "cvlassologit, lopt"}{p_end}
{phang2}. {stata "cvlassologit, lse"}{p_end}

{pstd}
The data is by default randomly partitioned 
into {it:K} folds. The {opt tabfold} option asks
{cmd:lassologit} to show the frequency distribution
of successes (1) and failures (0) across folds.

{phang2}. {stata "cvlassologit v58 v1-v57, nfolds(3) seed(123) tabfold"}{p_end}

{pstd}
In small samples, we might end up with a low number 
of success or failures in some folds. 
The {cmdab:strat:ified} option can help with this:
it ensures that 
the number of successes (1) and failures (0)
is approximately the same across folds: 

{phang2}. {stata "cvlassologit v58 v1-v57, nfolds(3) seed(123) tabfold stratified"}{p_end}

{pstd}
As with {cmd:lassologit}, we can use the {opt long} 
option for an extended outout.

{phang2}. {stata "cvlassologit, long"}{p_end}

{marker example_rigorous}{...}
{pstd}
{ul:Rigorous penalization with {cmd:rlassologit}}

{pstd}
Lastly, we consider the logistic lasso with
rigorous penalization:

{phang2}. {stata "rlassologit v58 v1-v57"}{p_end}

{pstd}
{cmd:rlassologit} displays
the logistic lasso solution and 
the post-logit solution. 

{pstd}
The rigorous lambda is returned in 
{cmd:e(lambda)} and is equal to 
79.207801.

{phang2}. {stata "di e(lambda)"}{p_end}

{pstd}
We get the same result when specifying the 
rigorous lambda manually using the
{cmd:lambda()} option of {cmd:lassologit}:

{phang2}. {stata "lassologit v58 v1-v57, lambda(79.207801)"}{p_end}

{marker example_prediction}{...}
{pstd}
{ul:Prediction}

{pstd}
After selecting a model, we can use {cmd:predict} to obtain
predicted probabilities or linear predictions.

{pstd}
First, we select a model using {cmd:lic()} in combination 
with {cmd:postresults} as above:

{phang2}. {stata "lassologit v58 v1-v57"}{p_end}
{phang2}. {stata "lassologit, lic(ebic) postresults"}{p_end}

{pstd}
Then, we use {cmd:predict}:

{phang2}. {stata "predict double phat, pr"}{p_end}
{phang2}. {stata "predict double xbhat, xb"}{p_end}

{pstd}
{cmdab:p:r} saves the predicted probability of 
success and {cmd:xb} saves the linear predicted
values.

{pstd} 
Note that the use of {cmdab:postres:ults} is required.
Without {cmdab:postres:ults} the results of the estimation
with the selected penalty level are not stored.

{pstd}
The approach for {cmd:cvlassologit} is very similar:

{phang2}. {stata "cvlassologit v58 v1-v57"}{p_end}
{phang2}. {stata "cvlassologit, lopt postresults"}{p_end}
{phang2}. {stata "predict double phat, pr"}{p_end}

{pstd}
In the case of {cmd:rlassologit}, we don't need to 
select a specific penalty level
and we also don't need to specify {cmdab:postres:ults}.

{phang2}. {stata "rlassologit v58 v1-v57"}{p_end}
{phang2}. {stata "predict double phat, pr"}{p_end}

{marker example_holdout}{...}
{pstd}
{ul:Assessing prediction accuracy with {opt holdout()}}

{pstd}
We can leave one partition of the data out of the estimation 
sample and check the accuracy of prediction 
using the {opt holdout(varname)} option. 

{pstd}
We first define 
a binary holdout variable: 

{phang2}. {stata "gen myholdout = (_n>4500)"}{p_end}

{pstd}
There are 4,601 observations in the sample, and 
we exclude observations 4,501 to 4,601 from the estimation.
The holdout variable should be set to 1 for all observations 
that we want to use for assessing classification accuracy.

{phang2}. {stata "lassologit v58 v1-v57, holdout(myholdout)"}{p_end}
{phang2}. {stata "mat list e(loss)"}{p_end}

{phang2}. {stata "rlassologit v58 v1-v57, holdout(myholdout)"}{p_end}
{phang2}. {stata "mat list e(loss)"}{p_end}

{pstd}
The loss measure is returned in {cmd:e(loss)}.
As with cross-validation, deviance is used by default.
{opt lossmeasure(class)} will return the 
average number of miss-classifications.

{marker example_plot_lassologit}{...}
{pstd}
{ul:Plotting with {cmd:lassologit}}

{pstd}
{cmd:lassologit} supports plotting of the 
coefficient path over lambda. 
Here, we create the plot using the replay syntax, 
but the same can be achieved in one line:

{phang2}. {stata "lassologit v58 v1-v57"}{p_end}
{phang2}. {stata "lassologit, plotpath(lambda) plotvar(v1-v5) plotlabel plotopt(legend(off))"}{p_end}

{pstd}
In the above example,
we use the following settings:
{opt plotpath(lambda)} plots estimates against lambda.
{opt plotvar(v1-v5)} restricts the set of variables plotted
to {it:v1-v5} (to avoid that the graph is too cluttered).
{opt plotlabel} puts variable labels next to the lines.
{opt plotopt(legend(off))} turns the legend off.

{marker example_plot_cvlassologit}{...}
{pstd}
{ul:Plotting with {cmd:cvlassologit}}

{pstd}
The {opt plotcv} option creates
a graph of the estimates loss 
a function of lambda:

{phang2}. {stata "cvlassologit v58 v1-v57, nfolds(3) seed(123)"}{p_end}
{phang2}. {stata "cvlassologit v58 v1-v57, plotcv"}{p_end}

{pstd}
The vertical solid red line indicates the 
value of lambda that minimizes the loss function. 
The dashed red line corresponds to the largest 
lambda for which MSPE is within one standard error
of the minimum loss.


{marker saved_results}{...}
{title:Saved results}

{pstd}
{ul:lassologit with single lambda and rlassologit}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: scalars}{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}
{synopt:{cmd:e(cons)}}=1 if constant is present, 0 otherwise{p_end}
{synopt:{cmd:e(p)}}number of predictors excluding intercept{p_end}
{synopt:{cmd:e(std)}}=1 if predictors are standardized{p_end}
{synopt:{cmd:e(lcount)}}number of lambda values{p_end}
{synopt:{cmd:e(ll0)}}log-likelihood of null model{p_end}
{synopt:{cmd:e(total_success)}}number of successes{p_end}
{synopt:{cmd:e(total_trials)}}number of trials{p_end}
{synopt:{cmd:e(N_holdout)}}observations in holdout sample{p_end}
{synopt:{cmd:e(lmax)}}largest lambda value{p_end}
{synopt:{cmd:e(lmin)}}smallest lambda value{p_end}
{synopt:{cmd:e(lambda)}}penalty level{p_end}
{synopt:{cmd:e(ll)}}log-likelihood{p_end}
{synopt:{cmd:e(shat)}}number of selected regressors{p_end}
{synopt:{cmd:e(shat0)}}number of selected and unpenalized regressors including constant (if present){p_end}
{synopt:{cmd:e(tss)}}total sum of squares{p_end}
{synopt:{cmd:e(aic)}}minimum AIC{p_end}
{synopt:{cmd:e(bic)}}minimum BIC{p_end}
{synopt:{cmd:e(aicc)}}minimum AICc{p_end}
{synopt:{cmd:e(ebic)}}minimum EBIC{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: macros}{p_end}
{synopt:{cmd:e(cmd)}}command name{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(varX)}}all predictors{p_end}
{synopt:{cmd:e(varXmodel)}}penalized predictors{p_end}
{synopt:{cmd:e(selected)}}selected predictors{p_end}
{synopt:{cmd:e(selected0)}}selected predictors including constant{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: matrices}{p_end}
{synopt:{cmd:e(b)}}posted coefficient vector. By default used for prediction.{p_end}
{synopt:{cmd:e(beta_post)}}post-logit coefficient vector{p_end}
{synopt:{cmd:e(beta_dense)}}logistic lasso coefficient vector without zeros{p_end}
{synopt:{cmd:e(beta_post_dense)}}post-logit coefficient vector without zeros{p_end}
{synopt:{cmd:e(beta_std)}}logitistic lasso coefficient vector in standard units{p_end}
{synopt:{cmd:e(beta_std_post)}}post-logit coefficient vector in standard units{p_end}
{synopt:{cmd:e(beta)}}logistic lasso coefficient vector{p_end}
{synopt:{cmd:e(sdvec)}}vector of standard deviations of the predictors{p_end}
{synopt:{cmd:e(sPsi)}}penalty loadings in standard units{p_end}
{synopt:{cmd:e(Psi)}}= {cmd:e(sPsi)} :* {cmd:e(sdvec)}{p_end}
{synopt:{cmd:e(loss)}}estimated loss if {opt holdout()} is used{p_end}

{pstd}
{ul:lassologit with multiple lambdas}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: scalars}{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}
{synopt:{cmd:e(cons)}}=1 if constant is present, 0 otherwise{p_end}
{synopt:{cmd:e(p)}}number of predictors excluding intercept{p_end}
{synopt:{cmd:e(std)}}=1 if predictors are standardized{p_end}
{synopt:{cmd:e(lcount)}}number of lambda values{p_end}
{synopt:{cmd:e(ll0)}}log-likelihood of null model{p_end}
{synopt:{cmd:e(total_success)}}number of successes{p_end}
{synopt:{cmd:e(total_trials)}}number of trials{p_end}
{synopt:{cmd:e(N_holdout)}}observations in holdout sample{p_end}
{synopt:{cmd:e(aicmin)}}minimum AIC{p_end}
{synopt:{cmd:e(bicmin)}}minimum BIC{p_end}
{synopt:{cmd:e(aiccmin)}}minimum AICc{p_end}
{synopt:{cmd:e(ebicmin)}}minimum EBIC{p_end}
{synopt:{cmd:e(aicid)}}lambda ID of minimum AIC{p_end}
{synopt:{cmd:e(bicid)}}lambda ID of minimum BIC{p_end}
{synopt:{cmd:e(aiccid)}}lambda ID of minimum AICc{p_end}
{synopt:{cmd:e(ebicid)}}lambda ID of minimum EBIC{p_end}
{synopt:{cmd:e(aiclambda)}}lambda corresponding to minimum AIC{p_end}
{synopt:{cmd:e(biclambda)}}lambda corresponding to minimum BIC{p_end}
{synopt:{cmd:e(aicclambda)}}lambda corresponding to minimum AICc{p_end}
{synopt:{cmd:e(ebiclambda)}}lambda corresponding to minimum EBIC{p_end}
{synopt:{cmd:e(loss)}}estimated loss if {opt holdout()} is used{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: macros}{p_end}
{synopt:{cmd:e(cmd)}}command name{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(varX)}}all predictors{p_end}
{synopt:{cmd:e(varXmodel)}}penalized predictors{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: matrices}{p_end}
{synopt:{cmd:e(betas)}}posted coefficient matrix{p_end}
{synopt:{cmd:e(betas_std)}}posted coefficient matrix in standard units{p_end}
{synopt:{cmd:e(lambdas)}}vector of lambdas{p_end}
{synopt:{cmd:e(aic)}}vector of AIC values{p_end}
{synopt:{cmd:e(aicc)}}vector of AICc values{p_end}
{synopt:{cmd:e(bic)}}vector of BIC values{p_end}
{synopt:{cmd:e(ebic)}}vector of EBIC values{p_end}
{synopt:{cmd:e(ll)}}vector of log-likelihood values{p_end}
{synopt:{cmd:e(l1norm)}}vector of L1-norm{p_end}
{synopt:{cmd:e(shat)}}number of included predictors{p_end}
{synopt:{cmd:e(shat0)}}number of included predictors including intercept{p_end}
{synopt:{cmd:e(sdvec)}}vector of standard deviations of the predictors{p_end}
{synopt:{cmd:e(sPsi)}}penalty loadings in standard units{p_end}
{synopt:{cmd:e(Psi)}}= {cmd:e(sPsi)} :* {cmd:e(sdvec)}{p_end}


{pstd}
{ul:cvlassologit}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(lunique)}}lunique{p_end}
{synopt:{cmd:e(lambdan)}}=1 if {opt lambdan} option is used{p_end}
{synopt:{cmd:e(mlossmin)}}number of observations{p_end}
{synopt:{cmd:e(lmin)}}smallest lambda used for CV{p_end}
{synopt:{cmd:e(lmax)}}maximum lambda used for CV{p_end}
{synopt:{cmd:e(lse)}}number of observations{p_end}
{synopt:{cmd:e(lopt)}}number of observations{p_end}
{synopt:{cmd:e(lseid)}}lambda ID corresponding to {cmd:e(lse)}{p_end}
{synopt:{cmd:e(loptid)}}lambda ID corresponding to {cmd:e(lopt)}{p_end}
{synopt:{cmd:e(nfolds)}}number of folds{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: macros}{p_end}
{synopt:{cmd:e(cmd)}}command name{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(varX)}}all predictors{p_end}
{synopt:{cmd:e(lossmeasure)}}loss measure ({it:deviance} or {it:class}){p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: matrices}{p_end}
{synopt:{cmd:e(lambdas)}}vector of lambda values used for cross-validation{p_end}
{synopt:{cmd:e(mloss)}}mean cross-validated loss{p_end}
{synopt:{cmd:e(loss)}}cross-validated loss for each fold; a matrix of size {it:nfolds} x {it:lcount}{p_end}
{synopt:{cmd:e(cvsd)}}estimate of standard error of mean cross-validated loss{p_end}
{synopt:{cmd:e(cvlower)}}= {cmd:e(mloss)} - {cmd:e(cvsd)}{p_end}
{synopt:{cmd:e(cvupper)}}= {cmd:e(mloss)} + {cmd:e(cvsd)}{p_end}

{pstd}
{ul:Estimation sample (always returned)}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: functions}{p_end}
{synopt:{cmd:e(sample)}}estimation sample{p_end}


{marker references}{...}
{title:References}

{marker Akaike1974}{...}
{phang}
Akaike, H. (1974). A new look at the statistical model identification. {it:IEEE Transactions on Automatic Control}, 19(6), 716–723. 
{browse "https://doi.org/10.1109/TAC.1974.1100705"}
{p_end}

{marker Belloni2016}{...}
{phang}
Belloni, A., Chernozhukov, V., & Wei, Y. (2016). Post-Selection Inference for Generalized Linear Models With Many Controls.  {it:Journal of Business & Economic Statistics}, 34(4), 606–619. 
{browse "https://doi.org/10.1080/07350015.2016.1166116"}
{p_end}

{marker Belloni2017}{...}
{phang}
Belloni, A., Chernozhukov, V., Fernández-Val, I., & Hansen, C. (2017).
Program Evaluation and Causal Inference With High-Dimensional Data.
{it:Econometrica}, 85(1), 233–298. 
{browse "https://doi.org/10.3982/ECTA12723"}
{p_end}

{marker Fu1998}{...}
{phang}
Fu, W. J. (1998). Penalized Regressions: The Bridge Versus the Lasso. {it:Journal of Computational and Graphical Statistics} 7(3), 397–416. 
{browse "https://doi.org/10.2307/1390712"}
{p_end}

{marker Friedman2007}{...}
{phang}
Friedman, J., Hastie, T., Höfling, H., & Tibshirani, R. (2007). Pathwise coordinate optimization. {it:The Annals of Applied Statistics} 1(2), 302–332. 
{browse "https://doi.org/10.1214/07-AOAS131"}
{p_end}

{marker Friedman2010}{...}
{phang}
Friedman, J., Hastie, T., & Tibshirani, R. (2010). Regularization Paths for Generalized Linear Models via Coordinate Descent. {it:Journal of Statistical Software} 33(1), 1–22. 
{browse "https://doi.org/10.18637/jss.v033.i01"}
{p_end}

{marker Hastie2009}{...}
{phang}
Hastie, T., Tibshirani, R., & Friedman, J. (2009). The Elements of Statistical Learning (2nd ed.). New York: Springer-Verlag.
{browse "https://web.stanford.edu/~hastie/ElemStatLearn/"}
{p_end}

{marker Hurvich1989}{...}
{phang}
Hurvich, C. M., & Tsai, C.-L. (1989). Regression and time series model selection in small samples. {it:Biometrika}, 76(2), 297–307. 
{browse "http://doi.org/10.1093/biomet/76.2.297"}
{p_end}

{marker Schwarz1978}{...}
{phang}
Schwarz, G. (1978). Estimating the Dimension of a Model. {it:The Annals of Statistics}, 6(2), 461–464. 
{browse "https://doi.org/10.1214/aos/1176344136"}
{p_end}

{marker Sugiura1978}{...}
{phang}
Sugiura, N. (1978). Further analysts of the data by akaike’ s information criterion and the finite corrections. {it:Communications in Statistics - Theory and Methods}, 7(1), 13–26. 
{browse "http://doi.org/10.1080/03610927808827599"}
{p_end}

{marker Tib1996}{...}
{phang}
Tibshirani, R. (1996). Regression Shrinkage and Selection via the Lasso. {it:Journal of the Royal Statistical Society. Series B (Methodological)} 58(1), 267–288. 
{browse "https://doi.org/10.2307/2346178"}
{p_end}

{marker Tib2012}{...}
{phang}
Tibshirani, R., Bien, J., Friedman, J., Hastie, T., Simon, N., Taylor, J., & Tibshirani, R. J. (2012). Strong rules for discarding predictors in lasso-type problems. 
{it:Journal of the Royal Statistical Society. Series B (Statistical Methodology)},
74(2), 245–266.
{browse "http://www.jstor.org/stable/41430939"}
{p_end}

{marker Kooji2007}{...}
{phang}
Van der Kooij A (2007). Prediction Accuracy and Stability of Regrsssion with Optimal Scaling Transformations. Ph.D. thesis, Department of Data Theory, University of Leiden.  
{browse "http://hdl.handle.net/1887/12096"}
{p_end}


{marker website}{title:Website}

{pstd}
Please check our website {browse "https://statalasso.github.io/"} for more information. 


{marker installation}{title:Installation}

{pstd}
To get the latest stable version of {cmd:lassologit} from our website, 
check the installation instructions at {browse "https://statalasso.github.io/installation/"}.
We update the stable website version more frequently than the SSC version.

{pstd}
To verify that {cmd:lassologit} is correctly installed, 
click on or type {stata "whichpkg lassopack"} 
(which requires {helpb whichpkg} 
to be installed; {stata "ssc install whichpkg"}).

{marker citation}{...}
{title:Citation of lassologit}

{pstd}{opt lassologit} is not an official Stata command. It is a free contribution
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
Help: {helpb lasso2}, {helpb cvlasso}, {helpb rlasso}, {helpb ivlasso}, {helpb pdslasso} (if installed).{p_end}
