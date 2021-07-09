{smcl}
{* *! version 1.0.13  15oct2019}{...}
{hline}
{cmd:help lasso2}{right: lassopack v1.3.1}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: lasso2} {hline 2}}Program for lasso, square-root lasso, elastic net, ridge, adaptive lasso and post-estimation OLS{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 4} Full syntax

{p 8 14 2}
{cmd:lasso2}
{it:depvar} {it:regressors} 
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[{cmd:,}} {cmdab:alp:ha(}{it:real}{cmd:)}
{cmd:sqrt}
{cmdab:ada:ptive}
{cmdab:adal:oadings(}{it:string}{cmd:)}
{cmdab:adat:heta(}{it:real}{cmd:)}
{cmd:ols}
{cmdab:l:ambda}{cmd:(}{it:numlist}{cmd:)}
{cmdab:lc:ount}{cmd:(}{it:integer}{cmd:)}
{cmdab:lminr:atio}{cmd:(}{it:real}{cmd:)}
{cmdab:lmax:}{cmd:(}{it:real}{cmd:)}
{cmdab:notp:en(}{it:varlist}{cmd:)}
{cmdab:par:tial(}{it:varlist}{cmd:)}
{cmdab:nor:ecover}
{cmdab:pload:ings(}{it:string}{cmd:)}
{cmdab:unitl:oadings}
{cmdab:prestd}
{cmdab:stdc:oef}
{cmd:fe}
{cmd:noftools}
{cmdab:noc:onstant}
{cmdab:tolo:pt}{cmd:(}{it:real}{cmd:)}
{cmdab:tolz:ero}{cmd:(}{it:real}{cmd:)}
{cmdab:maxi:ter}{cmd:(}{it:int}{cmd:)}
{cmdab:plot:path}{cmd:(}{it:method}{cmd:)}
{cmdab:plotv:ar}{cmd:(}{it:varlist}{cmd:)}
{cmdab:ploto:pt}{cmd:(}{it:string}{cmd:)}
{cmdab:plotl:abel}
{cmd:ic}{cmd:(}{it:string}{cmd:)}
{cmd:lic}{cmd:(}{it:string}{cmd:)}
{cmdab:ebicg:amma}{cmd:(}{it:real}{cmd:)}
{opt noic}
{cmd:long}
{opt displayall}
{opt postall}
{cmdab:postres:ults}
{opt ver:bose}
{cmdab:vver:bose}
{bind:{cmd:wnorm}]}

{p 8 14 2}
Note: the {opt fe} option will take advantage of the {helpb lasso2##SG2016:ftools}
package (if installed) for the fixed-effects transformation;
the speed gains using this package can be large.
See {rnethelp "http://fmwww.bc.edu/RePEc/bocode/f/ftools.sthlp":help ftools}
or click on {stata "ssc install ftools"} to install.

{synoptset 20}{...}
{synopthdr:Estimators}
{synoptline}
{synopt:{cmdab:a:lpha(}{it:real}{cmd:)}}
elastic net parameter, which controls the degree of L1-norm (lasso-type) to L2-norm (ridge-type) penalization.
alpha=1 corresponds to the lasso (the default estimator), and alpha=0 to ridge regression. 
alpha must be in the interval [0,1]. 
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
For example, this could be the vector e(b) from an initial {cmd:lasso2} estimation.
The elements of the vector are raised to the power -theta (note the minus).
See {cmdab:ada:ptive} option.
{p_end}
{synopt:{cmdab:adat:heta(}{it:real}{cmd:)}}
exponent for calculating adaptive penalty loadings. See {cmdab:ada:ptive} option. Default=1. 
{p_end}
{synopt:{cmd:ols}}
post-estimation OLS. 
If lambda is a list, post-estimation OLS results are displayed and returned in {cmd:e(betas)}.
If lambda is a scalar, post-estimation OLS is always displayed, 
and this option controls whether standard or post-estimation 
OLS results are stored in {cmd:e(b)}.
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
{synopt:{cmd:lic}{cmd:(}{it:string}{cmd:)}}
after first {cmd:lasso2} estimation using list of lambdas, estimate model corresponding to minimum information criterion.
'aic', 'bic', 'aicc', and 'ebic' (the default) are allowed.
Note the lower case spelling.
See {help lasso2##informationcriteria:Information criteria} for the definition of each information criterion.
{p_end}
{synopt:{cmdab:ebicg:amma}{cmd:(}{it:real}{cmd:)}}
controls the {it:xi} parameter of the EBIC. 
{it:xi} needs to lie in the [0,1] interval.
{it:xi}=0 is equivalent to the BIC. 
The default choice is {it:xi}=1-log(n)/(2*log(p)). 
{p_end}
{synopt:{cmdab:postres:ults}} Used in combination with {cmd:lic()}. 
Stores estimation results of the model selected by information criterion in {cmd:e()}.
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
{synopt:{cmdab:nor:ecover}}
suppresses recovery of partialled out variables after estimation.
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
{synopt:{cmdab:stdc:oef}}
return coefficients in standard deviation units, i.e., don't un-standardize. 
Only supported with {cmd:prestd} option.
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
See {help lasso2##standardization:discussion of standardization}.

{synoptset 20}{...}
{synopthdr:FE & constant}
{synoptline}
{synopt:{cmd:fe}}
within-transformation is applied prior to estimation. Requires data to be xtset.
{p_end}
{synopt:{cmd:noftools}}
do not use {helpb lasso2##SG2016:ftools} package for fixed-effects transform (slower; rarely used)
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

{marker plottingopts}{...}
{synoptset 20}{...}
{synopthdr:Plotting options*}
{synoptline}
{synopt:{cmdab:plot:path(}{it:method}{cmd:)}}
plots the coefficients path as a function of the L1-norm ({it:norm}), lambda ({it:lambda}) 
or the log of lambda ({it:lnlambda}) 
{p_end}
{synopt:{cmdab:plotv:ar(}{it:varlist}{cmd:)}}
list of variables to be included in the plot
{p_end}
{synopt:{cmdab:ploto:pt(}{it:string}{cmd:)}}
additional plotting options passed on to {helpb line}. For example, use {cmd:plotopt(legend(off))} to turn off the legend.
{p_end}
{synopt:{cmdab:plotl:abel}}
displays variable labels in graph. 
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
{it:*} Plotting is not available if lambda is a scalar value.

{synoptset 20}{...}
{synopthdr:Display options}
{synoptline}
{synopt:{opt displayall}{it:*}}
display full coefficient vectors including unselected variables (default: display only selected, unpenalized and partialled-out)
{p_end}
{synopt:{opt postall}{it:*}}
post full coefficient vector including unselected variables in e(b) (default: e(b) has only selected, unpenalized and partialled-out)
{p_end}
{synopt:{opt long}†}
show long output; instead of showing only the points at which predictors enter or leave
 the model, all models are shown.
{p_end}
{synopt:{opt ver:bose}}
show additional output
{p_end}
{synopt:{opt vver:bose}}
show even more output
{p_end}
{synopt:{cmd:ic}{cmd:(}{it:string}{cmd:)}†}
controls which information criterion is shown in the output.
'aic', 'bic', 'aicc', and 'ebic' (the default' are allowed).
Note the lower case spelling.
See {help lasso2##informationcriteria:Information criteria} for the definition of each information criterion.
{p_end}
{synopt:{cmd:noic}†}
suppresses the calculation of information criteria.
This will lead to speed gains if alpha<1, 
since calculation of effective degrees of freedom requires one inversion per lambda.
{p_end}
{synopt:{opt wnorm}†}
displays L1 norm of beta estimates weighted by penalty loadings, i.e., ||Psi*beta||(1) instead of ||beta||(1), which is the default. 
Note that this also affects plotting if {cmdab:plot:path(}{it:norm}{cmd:)}} is specified.
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
{it:*} Only applicable if lambda is a scalar value.
† Only applicable if lambda is a list (the default).

{p 4} Replay syntax

{p 8 14 2}
{cmd:lasso2}
{bind:[{cmd:,}}
{cmdab:plot:path}{cmd:(}{it:method}{cmd:)}
{cmdab:plotv:ar}{cmd:(}{it:varlist}{cmd:)}
{cmdab:ploto:pt}{cmd:(}{it:string}{cmd:)}
{cmdab:plotl:abel}
{opt long}
{cmdab:postres:ults}
{cmd:lic}{cmd:(}{it:string}{cmd:)}
{cmd:ic}{cmd:(}{it:string}{cmd:)}
{bind:{cmd:wnorm}]}

{synoptset 20}{...}
{synopthdr:Replay options}
{synoptline}
{synopt:{opt long}}
show long output; instead of showing only the points at which predictors enter or leave
 the model, all models are shown.
{p_end}
{synopt:{cmd:ic}{cmd:(}{it:string}{cmd:)}}
controls which information criterion is shown in the output.
'aic', 'bic', 'aicc', and 'ebic' (the default) are allowed.
Note the lower case spelling.
See {help lasso2##informationcriteria:Information criteria} for the definition of each information criterion.
{p_end}
{synopt:{cmd:lic}{cmd:(}{it:string}{cmd:)}}
estimate model corresponding to minimum information criterion.
'aic', 'bic', 'aicc', and 'ebic' (the default) are allowed.
Note the lower case spelling.
See {help lasso2##informationcriteria:Information criteria} for the definition of each information criterion.
{p_end}
{synopt:{cmdab:postres:ults}}
store estimation results in e() if {cmd:lic}{cmd:(}{it:string}{cmd:)} is used
{p_end}
{synopt:{cmdab:plot:path(}{it:method}{cmd:)}}
see {help lasso2##plottingopts:Plotting options} above
{p_end}
{synopt:{cmdab:plotv:ar(}{it:varlist}{cmd:)}}
see {help lasso2##plottingopts:Plotting options} above
{p_end}
{synopt:{cmdab:ploto:pt(}{it:string}{cmd:)}}
see {help lasso2##plottingopts:Plotting options} above
{p_end}
{synopt:{cmdab:plotl:abel}}
see {help lasso2##plottingopts:Plotting options} above
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
Only applicable if lambda was a list in the previous {cmd:lasso2} estimation.

{p 4} Postestimation:

{p 8 14 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} 
{cmd:xb}
{cmdab:r:esiduals}
{opt u}
{opt e}
{opt ue}
{opt xbu}
{cmd:ols}
{cmdab:l:ambda(}{it:real}{cmd:)}
{cmd:lid(}{it:int}{cmd:)}
{cmdab:appr:ox}
{cmdab:noi:sily}
{bind:{cmdab:postres:ults}]}

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
{synopt:{cmd:ols}}
use post-estimation OLS for prediction 
{p_end}
{synopt:{cmdab:l:ambda(}{it:real}{cmd:)}‡}
lambda value for prediction. Ignored if {cmd:lasso2} was called with scalar lambda value.
{p_end}
{synopt:{cmd:lid(}{it:int}{cmd:)}‡}
index of lambda value for prediction. 
{p_end}
{synopt:{cmd:lic}{cmd:(}{it:string}{cmd:)}}
selects which information criterion to use for prediction.
{p_end}
{synopt:{cmdab:appr:ox}‡}
linear approximation is used instead of re-estimation. 
Faster, but only exact if coefficient path is piecewise linear.
Only supported in combination with lambda().
{p_end}
{synopt:{cmdab:noi:sily}}
displays beta used for prediction. 
{p_end}
{synopt:{cmdab:postres:ults}‡}
store estimation results in e() if re-estimation is used
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
‡ Only applicable if lambda was a list in the previous {cmd:lasso2} estimation.

{pstd}
{opt lasso2} may be used with time-series or panel data,
in which case the data must be tsset or xtset first;
see help {helpb tsset} or {helpb xtset}.

{pstd}
All varlists may contain time-series operators or factor variables; see help varlist.

{title:Contents}

{phang}{help lasso2##description:Description}{p_end}
{phang}{help lasso2##coordinate:Coordinate descent algorithm}{p_end}
{phang}{help lasso2##penalization:Penalization level}{p_end}
{phang}{help lasso2##standardization:Standardization of variables}{p_end}
{phang}{help lasso2##informationcriteria:Information criteria}{p_end}
{phang}{help lasso2##estimators:Estimators}{p_end}
{phang}{help lasso2##examples:Examples and demonstration}{p_end}
{phang}{help lasso2##examples_data:--Data set}{p_end}
{phang}{help lasso2##examples_general:--General demonstration}{p_end}
{phang}{help lasso2##examples_information:--Information criteria}{p_end}
{phang}{help lasso2##examples_plotting:--Plotting}{p_end}
{phang}{help lasso2##examples_predicted:--Predicted values}{p_end}
{phang}{help lasso2##examples_standardization:--Standardization}{p_end}
{phang}{help lasso2##examples_penalty:--Penalty loadings and notpen()}{p_end}
{phang}{help lasso2##examples_partialling:--Partialling vs penalization}{p_end}
{phang}{help lasso2##examples_adaptive:--Adaptive lasso}{p_end}
{phang}{help lasso2##saved_results:Saved results}{p_end}
{phang}{help lasso2##references:References}{p_end}
{phang}{help lasso2##website:Website}{p_end}
{phang}{help lasso2##installation:Installation}{p_end}
{phang}{help lasso2##acknowledgements:Acknowledgements}{p_end}
{phang}{help lasso2##citation:Citation of lassopack}{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt lasso2} solves the following problem

	1/N RSS + lambda/N*alpha*||Psi*beta||[1] + lambda/(2*N)*(1-alpha)*||Psi*beta||[2], 
	
{pstd}
where 

{synoptset 8}{...}
{synopt:RSS}
= sum(y(i)-x(i)'beta)^2 denotes the residual sum of squares,
{p_end}
{synopt:beta}
is a p-dimensional parameter vector,
{p_end}
{synopt:lambda}
is the overall penalty level,
{p_end}
{synopt:||.||[j]}
denotes the L(j) vector norm for j=1,2;
{p_end}
{synopt:alpha}
the elastic net parameter, which determines the relative contribution of L1 (lasso-type) to L2 (ridge-type) penalization.
{p_end}
{synopt:Psi}
is a p by p diagonal matrix of predictor-specific penalty loadings. Note that {cmd:lasso2} treats Psi as a row vector.
{p_end}
{synopt:N}
number of observations
{p_end}
{p2colreset}{...}

{pstd}
Note: the above lambda differs from the definition used in parts of the lasso and elastic net literature; 
see for example the R package {it:glmnet} by Friedman et al. ({helpb lasso2##Friedman2010:2010}).
We have here adopted an objective function following Belloni et al. ({helpb lasso2##Belloni2012:2012}).
Specifically, {it:lambda=2*N*lambda(GN)} where {it:lambda(GN)} is the penalty level used by {it:glmnet}.

{pstd}
In addition, if the option {cmd:sqrt} is specified, {opt lasso2} estimates the square-root lasso (sqrt-lasso) estimator, which is defined as the solution to the following objective function:

	sqrt(1/N*RSS) + lambda/N*||Psi*beta||[1]. 
	
{marker coordinate}{...}
{title:Coordinate descent algorithm}

{pstd}
{cmd:lasso2} implements the elastic net and sqrt-lasso using coordinate descent algorithms. 
The algorithm  (then referred to as "shooting") was first proposed by Fu ({helpb lasso2##Fu1998:1998}) for the lasso, and by Van der Kooij ({helpb lasso2##Kooji2007:2007}) for the elastic net. 
Belloni et al. ({helpb lasso2##BelloniSqrt2011:2011}) implement the coordinate descent for the sqrt-lasso, and have kindly provided Matlab code.

{pstd}
Coordinate descent algorithms repeatedly cycle over predictors {it:j}=1,...,{it:p} and update single coefficient estimates until convergence. 
Suppose the predictors are centered and standardized to have unit variance. 
In that case, the update for coefficient {it:j} is obtained using univariate regression of the current partial residuals (i.e., excluding the contribution of predictor {it:j}) against predictor {it:j}.

{pstd}
The algorithm requires an initial beta estimate for which the Ridge estimate is used.
If the coefficient path is obtained for a list of lambda values, 
{cmd:lasso2} starts from the largest lambda value and uses previous estimates as warm starts. 

{pstd}
See Friedman et al. ({helpb lasso2##Friedman2007:2007}, {helpb lasso2##Friedman2010:2010}), and references therein, for further information. 

{marker penalization}{...}
{title:Penalization level: choice of lambda (and alpha)}

{pstd}
Penalized regression methods, such as the elastic net and the sqrt-lasso, 
rely on tuning parameters that control the degree and type of penalization. 
The estimation methods implemented in {cmd:lasso2} use two tuning parameters:
lambda, which controls the general degree of penalization, and alpha, 
which determines the relative contribution of L1-type to L2-type penalization.
{cmd:lasso2} obtains elastic net and sqrt-lasso solutions for a given lambda value or a list of lambda values, and for a given alpha value (default=1).

{pstd}
{cmd:lassopack} offers three approaches for selecting the "optimal" lambda (and alpha) value:

{pstd}
(1) The penalty level may be chosen by cross-validation in order to optimize out-of-sample prediction performance. 
{it:K}-fold cross-validation and rolling cross-validation (for panel and time-series data) are implemented in {helpb cvlasso}. 
{cmd:cvlasso} also supports cross-validation across alpha. 

{pstd}
(2) Theoretically justified and feasible penalty levels and loadings are available for the lasso and sqrt-lasso
via the separate command {helpb rlasso}. 
The penalization is chosen to dominate the noise of the data-generating process (represented by the score vector),
which allows derivation of theoretical results with regard to consistent prediction and parameter estimation. 
Since the error variance is in practice unknown, 
Belloni et al. ({helpb lasso2##Belloni2012:2012}) introduce the rigorous (or feasible) lasso that relies on an iterative algorithm for estimating the optimal penalization 
and is valid in the presence of non-Gaussian and heteroskedastic errors. 
Belloni  et al. ({helpb lasso2##Belloni2016:2016}) extend the framework to the panel data setting. 
In the case of the sqrt-lasso under homoskedasticity, the optimal penalty level is independent of the unknown error variance, 
leading to a practical advantage and better performance in finite samples
(see Belloni et al., {helpb lasso2##BelloniSqrt2011:2011}, {helpb lasso2##BelloniSqrt2014:2014}).
See help {helpb rlasso} for more details.

{pstd}
(3) Lambda can also be selected using information criteria.
{cmd:lasso2} calculates four information criteria: 
Akaike Information Criterion (AIC; Akaike, {helpb lasso2##Akaike1974:1974}),
Bayesian Information Criterion (BIC; Schwarz, {helpb lasso2##Schwarz1978:1978}),
Extended Bayesian information criterion (EBIC; Chen & Chen, {helpb lasso2##Chen2008:2008})
and the corrected AIC (AICc; Sugiura, {helpb lasso2##Sugiura1978:1978},
 and Hurvich, {helpb lasso2##Hurvich1989:1989}). 
By default, {cmd:lasso2} displays EBIC in the output, 
but all four information criteria are stored in {cmd:e(aic)}, {cmd:e(bic)}, {cmd:e(ebic)} and {cmd:e(aicc)}. 
See section {help lasso2##informationcriteria:Information criteria} for more information.

{marker standardization}{...}
{title:Standardization of variables}

{pstd}
Standard practice is for predictors to be "standardized",
i.e., normalized to have mean zero and unit variance.
By default {opt lasso2} achieves this by incorporating the standardization into the penalty loadings.
We refer to this method as standardization "on the fly", as standardization occurs during rather than before estimation.
Alternatively, the option {opt prestd} causes the predictors to be standardized prior to the estimation.

{pstd}
Standardizing "on the fly" via the penalty loadings and pre-standardizing the data prior to estimation
are theoretically equivalent.
The default standardizing "on the fly" is often faster.
The {opt prestd} option can lead to improved numerical precision or more stable results in the case of difficult problems;
the cost is the computation time required to pre-standardize the data.

{marker estimators}{...}
{title:Estimators}

{pstd}
{ul:Ridge regression (Hoerl & Kennard, {helpb lasso2##Hoerl1970:1970})}

{pstd}
The ridge estimator can be written as 

	 betahat(ridge) = (X'X+lambda*I(p))^(-1)X'y.

{pstd}
Thus, even if X'X is not full rank (e.g. because p>n), the problem becomes nonsingular by adding a constant to the diagonal of X'X. 
Another advantage of the ridge estimator over least squares stems from the variance-bias trade-off. 
Ridge regression may improve over ordinary least squares by inducing a mild bias while decreasing the variance. 
For this reason, ridge regression is a popular method in the context of multicollinearity.
In contrast to estimators relying on L1-penalization, the ridge does not yield sparse solutions and keeps all predictors in the model. 
	
{pstd}
{ul:Lasso estimator (Tibshirani, {helpb lasso2##Tib1996:1996})}

{pstd}
The lasso minimizes the residual sum of squares subject to a constraint on the absolute size of coefficient estimates.
Tibshirani ({helpb lasso2##Tib1996:1996}) motivates the lasso with two major advantages over least squares.
First, due to the nature of the L1-penalty, the lasso tends to produce sparse solutions and thus facilitates model interpretation. 
Secondly, similar to ridge regression, lasso can outperform least squares in terms of prediction due to lower variance. 
Another advantage is that the lasso is computationally attractive due to its convex form. 
This is in contrast to model selection based on AIC or BIC (which employ L0 penalization) where each possible sub-model has to be estimated. 

{pstd}
{ul:Elastic net (Zou & Hastie, {helpb lasso2##Zou2005:2005})}

{pstd}
The elastic net applies a mix of L1 (lasso-type) and L2 (ridge-type) penalization. 
It combines some of the strengths of lasso and ridge regression.
In the presence of groups of correlated regressors, the lasso selects typically only one variable from each group,
whereas the ridge tends to produce similar coefficient estimates for groups of correlated variables. 
On the other hand, the ridge does not yield sparse solutions impeding model interpretation. 
The elastic net is able to produce sparse solutions (for some alpha greater than zero) and retains (or drops) correlated variables jointly. 

{pstd}
{ul:Adaptive lasso (Zou, {helpb lasso2##Zou2006:2006})}

{pstd}
The lasso is only variable selection consistent under the rather strong "irrepresentable condition", 
which imposes constraints on the degree of correlation between predictors in the true model
and predictors outside of the model (see Zhao & Yu, {helpb lasso2##Zhao2006:2006}; Meinshausen & Bühlmann, {helpb lasso2##Buhlmann2006:2006}).
Zou ({helpb lasso2##Zou2006:2006}) proposes the adaptive lasso which uses penalty loadings of 1/abs(beta0(j))^theta
where beta0 is an initial estimator. 
The adaptive lasso is variable-selection consistent for fixed p under weaker assumptions than the standard lasso. 
If p<n, OLS can be used as the initial estimator. 
Huang et al. ({helpb lasso2##Huang2008:2008}) suggest to use univariate OLS if p>n. 
Other initial estimators are possible. 

{pstd}
{ul:Square-root lasso (Belloni et al., {helpb lasso2##BelloniSqrt2011:2011}, {helpb lasso2##BelloniSqrt2014:2014})}

{pstd}
The sqrt-lasso is a modification of the lasso that minimizes (RSS)^(1/2) instead of RSS, 
while also imposing an L1-penalty. 
The main advantage of the sqrt-lasso over the standard lasso is that the theoretically grounded, 
data-driven optimal lambda is independent of the unknown error variance under homoskedasticity.
See {helpb rlasso}.

{pstd}
{ul:Post-estimation OLS}

{pstd}
Penalized regression methods induce a bias that can be alleviated by post-estimation OLS, 
which applies OLS to the predictors selected by the first-stage variable selection method. 
For the case of the lasso, Belloni and Chernozhukov ({helpb lasso2##Belloni2013:2013}) have shown that the post-lasso OLS performs at least as well as the lasso under mild additional assumptions.

{pstd} 
For further information on the lasso and related methods, see for example the textbooks by Hastie et al. ({helpb lasso2##Hastie2009:2009}, {helpb lasso2##Hastie2015:2015}; both available for free)
 and Bühlmann & Van de Geer ({helpb lasso2##Buhlmann2011:2011}).
 
{marker informationcriteria}{...}
{title:Information criteria}
 
{pstd} 
The information criteria supported by {cmd:lasso2} are 
the Akaike information criterion (AIC, Akaike, {helpb lasso2##Akaike1974:1974}),
the Bayesian information criterion (BIC, Schwarz, {helpb lasso2##Schwarz1978:1978}),
the corrected AIC (Sugiura, {helpb lasso2##Sugiura1978:1978}; Hurvich, {helpb lasso2##Hurvich1989:1989}),
and the Extended BIC (Chen & Chen, {helpb lasso2##Chen2008:2008}). 
These are given by (omitting dependence on lambda and alpha):

	AIC	= N*log(RSS/N) + 2*{it:df}
	BIC	= N*log(RSS/N) + {it:df}*log(N) 
	AICc	= N*log(RSS/N) + 2*{it:df}*N/(N-{it:df})
	EBIC	= BIC + 2*{it:xi}*{it:df}*log(p)

{pstd} 
where RSS(lambda,alpha) is the residual sum of squares 
and {it:df}(lambda,alpha) is the effective degrees of freedom, 
which is a measure of model complexity.
In the linear regression model, the degrees of freedom is simply the number of regressors.
Zou et al. ({helpb lasso2##Zou2007:2007}) show that the number of non-zero coefficients 
is an unbiased and consistent estimator of {it:df}(lambda,alpha) for the lasso.
More generally,  the degrees of freedom of the elastic net can be calculated as
 the trace of the projection matrix.
With an unbiased estimator for {it:df} available,
the above information criteria can be employed to select tuning parameters.

{pstd} 
The BIC is known to be model selection consistent if the true model is among the candidate models, 
whereas the AIC tends to yield an overfitted model.
On the other hand, the AIC is loss efficient in the sense that it selects the model 
that minimizes the squared average prediction error,
while the BIC does not possess this property. 
Zhang et al. ({helpb lasso2##Zhang2010:2010}) show that these principles also apply 
when AIC and BIC are employed to select the tuning parameter for penalized regression.
  
{pstd} 
Both AIC and BIC tend to overselect regressors in the small-N-large-p case. 
The AICc corrects the small sample bias of the AIC which can be especially severe 
in the high-dimensional context. Similarily, the EBIC addresses the shortcomings 
of the BIC when p is large by imposing a larger penalty on the number of coefficients. 
Chen & Chen ({helpb lasso2##Chen2008:2008}) show that the EBIC
performs better in terms of false discovery rate at the cost of a 
negligible reduction in the positive selection rate. 

{pstd} 
The EBIC depends on an additional parameter, {it:xi} (denoted
as gamma in the original article), which can be controlled using 
{cmdab:ebicg:amma}{cmd:(}{it:real}{cmd:)}. 
{it:gamma}=0 is equivalent to the BIC.
We follow Chen & Chen ({helpb lasso2##Chen2008:2008}, p. 768) 
and use {it:xi}=1-log(n)/(2*log(p))
as the default choice. 
An upper and lower threshold is applied to ensure that {it:xi} lies in the [0,1] interval.

{pstd} 
The EBIC is displayed in the output of {cmd:lasso2} by default (if lambda is a list), 
but all four information criteria are returned in {cmd:e()}.
The lambda values that minimize the information criteria for a given alpha
are returned in {cmd:e(laic)}, {cmd:e(lbic)}, {cmd:e(laicc)} and {cmd:e(lebic)}, 
respectively.
To change the default display, use the {cmd:ic(}{it:string}{cmd:)} option. 
{cmd:noic} suppresses the calculation of information criteria,
which leads to a speed gain if alpha<1.

{marker examples}{...}
{title:Example using prostate cancer data (Stamey et al., {helpb lasso2##Stamey1989:1989})}

{marker examples_data}{...}
{pstd}
{ul:Data set}

{pstd}
The data set is available through Hastie et al. ({helpb lasso2##Hastie2009:2009}) on the {browse "https://web.stanford.edu/~hastie/ElemStatLearn/":authors' website}. 
The following variables are included in the data set of 97 men:

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

{pstd}Estimate coefficient lasso path over (default) list of lambda values.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45"}{p_end}

{pstd}The replay syntax can be used to re-display estimation results.{p_end}
{phang2}. {stata "lasso2"}{p_end}

{pstd}User-specified lambda list.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, lambda(100 50 10)"}{p_end}

{pstd}The list of returned {cmd:e()} objects depends on whether {cmd:lambda()} is a list (the default) or a scalar value.
For example, if lambda is a scalar, one vector of coefficient estimates is returned.
If lambda is a list, the whole coefficient path for a range of lambda values is obtained.
The last row of {cmd:e(betas)} is equal to the row vector {cmd:e(b)}.
{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, lambda(100 50 10)"}{p_end}
{phang2}. {stata "ereturn list"}{p_end}
{phang2}. {stata "mat list e(betas)"}{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, lambda(10)"}{p_end}
{phang2}. {stata "ereturn list"}{p_end}
{phang2}. {stata "mat list e(b)"}{p_end}

{pstd}Sqrt-lasso.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, sqrt"}{p_end}

{pstd}Ridge regression.
All predictors are included in the model.
{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, alpha(0)"}{p_end}

{pstd}Elastic net with alpha=0.1.
Even though alpha is close to zero (Ridge regression),
the elastic net can produce sparse solutions.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, alpha(0.1)"}{p_end}

{pstd}The option {cmd:ols} triggers the use of post-estimation OLS.
OLS alleviates the shrinkage bias induced by L1 and L2 norm penalization.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, ols"}{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, sqrt ols"}{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, alpha(0.1) ols"}{p_end}

{marker examples_information}{...}
{pstd}
{ul:Information criteria}

{pstd}
{cmd:lasso2} calculates four information criteria: AIC, BIC, EBIC and AICc. 
The EBIC is shown by default in the output along with the R-squared.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45"}{p_end}

{pstd}
To see another information criterion in the outout, use the {cmd:ic(}{it:string}{cmd:)} option
where {it:string} can be replaced by {it:aic}, {it:bic}, {it:ebic} or {it:aicc} (note the lower case spelling).
For example, to display AIC: {p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, ic(aic)"}{p_end}

{pstd}
In fact, there is no need to re-run the full model. 
We can make use of the replay syntax: {p_end}
{phang2}. {stata "lasso2, ic(aic)"}{p_end}

{pstd}
The {cmd:long} option triggers extended output;
instead of showing only the points at which predictors enter or leave the model,
all models are shown. 
An asterisk marks the model (i.e., the value of lambda)
that minimizes the information criterion (here, AIC). {p_end}
{phang2}. {stata "lasso2, ic(aic) long"}{p_end}

{pstd}
To estimate the model corresponding to the minimum information criterion, click on the link at the bottom of the output or type one of the following: {p_end}
{phang2}. {stata "lasso2, lic(aic)"}{p_end}
{phang2}. {stata "lasso2, lic(ebic)"}{p_end}
{phang2}. {stata "lasso2, lic(bic)"}{p_end}
{phang2}. {stata "lasso2, lic(aicc)"}{p_end}

{pstd}
To store the estimation results of the selected model, add the {cmdab:postres:ults} option.{p_end}
{phang2}. {stata "lasso2, lic(ebic)"}{p_end}
{phang2}. {stata "ereturn list"}{p_end}
{phang2}. {stata "lasso2, lic(ebic) postres"}{p_end}
{phang2}. {stata "ereturn list"}{p_end}

{pstd}
The same can also be achieved in one line without using the replay syntax.
{cmd:lasso2} first obtains the full coefficient path for a list lambda values, 
and then runs the model selected by AIC.
Again, {cmdab:postres:ults} can be used to store results of the selected model.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, lic(aic) postres"}{p_end}

{marker examples_plotting}{...}
{pstd}
{ul:Plotting}

{pstd}Plot coefficients against lambda:
As lambda increases, the coefficient estimates are shrunk towards zero.
Lambda=0 corresponds to OLS and if lambda is sufficiently large the model is empty.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, plotpath(lambda)"}{p_end}

{pstd}Plot coefficients against L1 norm.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, plotpath(norm)"}{p_end}

{pstd}The replay syntax can also be used for plotting.{p_end}
{phang2}. {stata "lasso2, plotpath(norm)"}{p_end}

{pstd}Only selected variables are plotted.{p_end}
{phang2}. {stata "lasso2, plotpath(norm) plotvar(lcavol svi)"}{p_end}

{pstd}The variable names can be displayed directly next to each series using {cmd:plotlabel}.
{cmd:plotopt(legend(off))} suppresses the legend.{p_end}
{phang2}. {stata "lasso2, plotpath(lambda) plotlabel plotopt(legend(off))"}{p_end}
{phang2}. {stata "lasso2, plotpath(norm) plotlabel plotopt(legend(off))"}{p_end}

{marker examples_predicted}{...}
{pstd}
{ul:Predicted values}

{pstd}
{cmd:xbhat1} is generated by re-estimating the model for lambda=10. 
The {cmd:noisily} option triggers the display of the estimation results.
{cmd:xbhat2} is generated by linear approximation
using the two beta estimates closest to lambda=10.
{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45"}{p_end}
{phang2}. {stata "cap drop xbhat1"}{p_end}
{phang2}. {stata "predict double xbhat1, xb l(10) noisily"}{p_end}
{phang2}. {stata "cap drop xbhat2"}{p_end}
{phang2}. {stata "predict double xbhat2, xb l(10) approx"}{p_end}

{pstd}The model is estimated explicitly using lambda=10. 
If {cmd:lasso2} is called with a scalar lambda value, 
the subsequent {cmd:predict} command requires no {cmd:lambda()} option.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, lambda(10)"}{p_end}
{phang2}. {stata "cap drop xbhat3"}{p_end}
{phang2}. {stata "predict double xbhat3, xb"}{p_end}

{pstd}All three methods yield the same results.
However note that the linear approximation is only exact for the lasso
which is piecewise linear.{p_end}
{phang2}. {stata "sum xbhat1 xbhat2 xbhat3"}{p_end}

{pstd}It is also possible to obtain predicted values 
by referencing a specific lambda ID using the {cmd:lid()} option.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45"}{p_end}
{phang2}. {stata "cap drop xbhat4"}{p_end}
{phang2}. {stata "predict double xbhat4, xb lid(21)"}{p_end}
{phang2}. {stata "cap drop xbhat5"}{p_end}
{phang2}. {stata "predict double xbhat5, xb l(25.45473900468241)"}{p_end}
{phang2}. {stata "sum xbhat4 xbhat5"}{p_end}

{marker examples_standardization}{...}
{pstd}
{ul:Standardization}

{pstd}
By default {cmd:lasso2} standardizes the predictors to have unit variance.
Standardization is done by default "on the fly" via penalty loadings.
The coefficient estimates are returned in original units. {p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10)"}{p_end}

{pstd}
Instead of standardizing "on the fly" by setting penalization loadings equal to standardization loadings,
we can standardize the regressors prior to estimation with the {opt prestd} option.
Both methods are equivalent in theory.
Standardizing "on the fly" tends to be faster, 
but pre-standardization may lead to more stable results in the case of difficult problems.
See {help lasso2##standardization:here} for more information.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10)"}{p_end}
{phang2}. {stata "mat list e(Psi)"}{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) prestd"}{p_end}
{phang2}. {stata "mat list e(Psi)"}{p_end}

{pstd}
The used penalty loadings are stored in {cmd:e(Psi)}. 
In the first case above, the standardization loadings are returned. 
In the second case the penalty loadings are equal to one for all regressors.
{p_end}

{pstd}
To get the coefficients in standard deviation units,
{cmd:stdcoef} can be specified along with the {opt prestd} option.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) prestd stdcoef"}{p_end}

{pstd}
We can override any form of standardization with the {opt unitloadings} options,
which sets the penalty loadings to a vector of 1s.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) unitloadings"}{p_end}

{pstd}The same logic applies to the sqrt-lasso (and elastic net).{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) sqrt"}{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) sqrt prestd"}{p_end}

{marker examples_penalty}{...}
{pstd}
{ul:Penalty loadings and {cmd:notpen()}}

{pstd}
By default the penalty loading vector is a vector of standard deviations.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10)"}{p_end}
{phang2}. {stata "mat list e(Psi)"}{p_end}

{pstd}
We can set the penalty loading for specific predictors to zero, implying no penalization.
Unpenalized predictor are always included in the model.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) notpen(lcavol)"}{p_end}
{phang2}. {stata "mat list e(Psi)"}{p_end}

{pstd}
We can specify custom penalty loadings.
The option {cmd:ploadings} expects a row vector of size {it:p} where {it:p} is the number of regressors (excluding the constant,
which is partialled out).
Because we pre-standardize the data (and we are using the lasso)
the results are equivalent to the results above (standardizing on the fly and specifying lcavol as unpenalized).{p_end}
{phang2}. {stata "mat myloadings = (0,1,1,1,1,1,1,1)"}{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) ploadings(myloadings) prestd"}{p_end}
{phang2}. {stata "mat list e(Psi)"}{p_end}

{marker examples_partialling}{...}
{pstd}
{ul:Partialling vs penalization}

{pstd}If lambda and the penalty loadings are kept constant,
partialling out and not penalizing of variables yields the same results for the included/penalized regressors. 
Yamada ({helpb lasso2##Yamada2017:2017}) shows that the equivalence of partialling out and not penalizing holds for lasso and ridge regression.
The examples below suggest that the same result also holds for the elastic net in general and the sqrt-lasso.
Note that the equivalence only holds if the regressor matrix and other penalty loadings are the same.
Below we use the {opt unitloadings} option to achieve this;
alternatively we could use the {opt ploadings(.)} option.
{p_end}

{pstd}Lasso.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) notpen(lcavol) unitload"}{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) partial(lcavol) unitload"}{p_end}

{pstd}Sqrt-lasso.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) sqrt notpen(lcavol) unitload"}{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) sqrt partial(lcavol) unitload"}{p_end}

{pstd}Ridge regression.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) alpha(0) notpen(lcavol) unitload"}{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) alpha(0) partial(lcavol) unitload"}{p_end}

{pstd}Elastic net.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) alpha(0.5) notpen(lcavol) unitload"}{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) alpha(0.5) partial(lcavol) unitload"}{p_end}

{marker examples_adaptive}{...}
{pstd}
{ul:Adaptive lasso}

{pstd}The adaptive lasso relies on an initial estimator to calculate the penalty loadings.
The penalty loadings are given by 1/abs(beta0(j))^theta, 
where beta0(j) denotes the initial estimate for predictor j.
By default, {cmd:lasso2} uses OLS as the initial estimator 
as originally suggested by Zou ({helpb lasso2##Zou2006:2006}).
If the number of parameters exceeds the numbers of observations, univariate OLS is used;
see Huang et al. ({helpb lasso2##Huang2008:2008}).{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, adaptive"}{p_end}
{phang2}. {stata "mat list e(Psi)"}{p_end}

{pstd}See the OLS estimates for comparison.{p_end}
{phang2}. {stata "reg lpsa lcavol lweight age lbph svi lcp gleason pgg45"}{p_end}

{pstd}Theta (the exponent for calculating the adaptive loadings) 
can be changed using the {cmd:adatheta()} option.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, adaptive adat(2)"}{p_end}
{phang2}. {stata "mat list e(Psi)"}{p_end}

{pstd}Other initial estimators such as ridge regression are possible.{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, l(10) alpha(0)"}{p_end}
{phang2}. {stata "mat bhat_ridge = e(b)"}{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, adaptive adaloadings(bhat_ridge)"}{p_end}
{phang2}. {stata "mat list e(Psi)"}{p_end}

{marker saved_results}{...}
{title:Saved results}

{pstd}
The set of returned e-class objects depends on whether lambda is a scalar or a list (the default).
{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: scalars}{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}
{synopt:{cmd:e(cons)}}=1 if constant is present, 0 otherwise{p_end}
{synopt:{cmd:e(fe)}}=1 if fixed effects model is used, 0 otherwise{p_end}
{synopt:{cmd:e(alpha)}}elastic net parameter{p_end}
{synopt:{cmd:e(sqrt)}}=1 if the sqrt-lasso is used, 0 otherwise{p_end}
{synopt:{cmd:e(ols)}}=1 if post-estimation OLS results are returned, 0 otherwise{p_end}
{synopt:{cmd:e(adaptive)}}=1 if adaptive loadings are used, 0 otherwise{p_end}
{synopt:{cmd:e(p)}}number of penalized regressors in model{p_end}
{synopt:{cmd:e(notpen_ct)}}number of unpenalized variables{p_end}
{synopt:{cmd:e(partial_ct)}}number of partialled out regressors (incl constant){p_end}
{synopt:{cmd:e(prestd)}}=1 if pre-standardized{p_end}
{synopt:{cmd:e(lcount)}}number of lambda values{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: scalars (only if lambda is a list)}{p_end}
{synopt:{cmd:e(lmax)}}largest lambda value{p_end}
{synopt:{cmd:e(lmin)}}smallest lambda value{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: scalars (only if lambda is a scalar)}{p_end}
{synopt:{cmd:e(lambda)}}penalty level{p_end}
{synopt:{cmd:e(rmse)}}root mean squared error{p_end}
{synopt:{cmd:e(rmseOLS)}}root mean squared error of post-estimation OLS{p_end}
{synopt:{cmd:e(pmse)}}minimized objective function (penalized mse, lasso/elastic net/ridge only){p_end}
{synopt:{cmd:e(prmse)}}minimized objective function (penalized rmse, sqrt-lasso only){p_end}
{synopt:{cmd:e(k)}}number of selected and unpenalized/partialled-out regressors including constant
(if present){p_end}
{synopt:{cmd:e(s)}}number of selected regressors{p_end}
{synopt:{cmd:e(s0)}}number of selected and unpenalized regressors including constant (if present){p_end}
{synopt:{cmd:e(niter)}}number of iterations{p_end}
{synopt:{cmd:e(maxiter)}}maximum number of iterations{p_end}
{synopt:{cmd:e(tss)}}total sum of squares{p_end}
{synopt:{cmd:e(aicmin)}}minimum AIC{p_end}
{synopt:{cmd:e(bicmin)}}minimum BIC{p_end}
{synopt:{cmd:e(aiccmin)}}minimum AICc{p_end}
{synopt:{cmd:e(ebicmin)}}minimum EBIC{p_end}
{synopt:{cmd:e(laic)}}lambda corresponding to minimum AIC{p_end}
{synopt:{cmd:e(lbic)}}lambda corresponding to minimum BIC{p_end}
{synopt:{cmd:e(laicc)}}lambda corresponding to minimum AICc{p_end}
{synopt:{cmd:e(lebic)}}lambda corresponding to minimum EBIC{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: macros}{p_end}
{synopt:{cmd:e(cmd)}}command name{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(varX)}}all predictors{p_end}
{synopt:{cmd:e(varXmodel)}}penalized predictors{p_end}
{synopt:{cmd:e(partial)}}partialled out predictors{p_end}
{synopt:{cmd:e(notpen)}}unpenalized predictors{p_end}
{synopt:{cmd:e(method)}}estimation method{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: macros (only if lambda is a scalar)}{p_end}
{synopt:{cmd:e(selected)}}selected predictors{p_end}
{synopt:{cmd:e(selected0)}}selected predictors excluding constant{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: matrices}{p_end}
{synopt:{cmd:e(Psi)}}row vector used penalty loadings{p_end}
{synopt:{cmd:e(stdvec)}}row vector of standardization loadings{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: matrices (only if lambda is a list)}{p_end}
{synopt:{cmd:e(lambdamat)}}column vector of lambdas{p_end}
{synopt:{cmd:e(l1norm)}}column vector of L1 norms for each lambda value (excludes the intercept){p_end}
{synopt:{cmd:e(wl1norm)}}column vector of weighted L1 norms for each lambda value (excludes the intercept), see {cmd:wnorm}{p_end}
{synopt:{cmd:e(dof)}}column vector of L0 norm for each lambda value (excludes the intercept){p_end}
{synopt:{cmd:e(betas)}}matrix of estimates, where each row corresponds to one lambda value. The intercept is stored in the last column.{p_end}
{synopt:{cmd:e(ess)}}column vector of explained sum of squares for each lambda value{p_end}
{synopt:{cmd:e(rss)}}column vector of residual sum of squares for each lambda value{p_end}
{synopt:{cmd:e(ebic)}}column vector of EBIC for each lambda value{p_end}
{synopt:{cmd:e(bic)}}column vector of BIC for each lambda value{p_end}
{synopt:{cmd:e(aic)}}column vector of AIC for each lambda value{p_end}
{synopt:{cmd:e(aicc)}}column vector of AICc for each lambda value{p_end}
{synopt:{cmd:e(rsq)}}column vector of R-squared for each lambda value{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: matrices (only if lambda is a scalar)}{p_end}
{synopt:{cmd:e(b)}}posted coefficient vector (see {cmd:postall} and {cmd:displayall}). Used for prediction.{p_end}
{synopt:{cmd:e(beta)}}coefficient vector{p_end}
{synopt:{cmd:e(betaOLS)}}coefficient vector of post-estimation OLS{p_end}
{synopt:{cmd:e(betaAll)}}full coefficient vector including omitted, 
factor base variables, etc.
{p_end}
{synopt:{cmd:e(betaAllOLS)}}full post-estimation OLS coefficient vector including omitted, 
factor base variables, etc. {p_end}

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

{marker BelloniSqrt2011}{...}
{phang}
Belloni, A., Chernozhukov, V., & Wang, L. (2011). 
Square-root lasso: pivotal recovery of sparse signals via conic programming. 
{it:Biometrika} 98(4), 791–806. 
{browse "https://doi.org/10.1093/biomet/asr043"}
{p_end}

{marker Belloni2012}{...}
{phang}
Belloni, A., Chen, D., Chernozhukov, V., & Hansen, C. (2012). Sparse Models and Methods for Optimal Instruments With an Application to Eminent Domain. {it:Econometrica} 80(6), 2369–2429. 
{browse "https://doi.org/10.3982/ECTA9626"}
{p_end}

{marker Belloni2013}{...}
{phang}
Belloni, A., & Chernozhukov, V. (2013). Least squares after model selection in high-dimensional sparse models. {it:Bernoulli}, 19(2), 521–547. 
{browse "https://doi.org/10.3150/11-BEJ410"}
{p_end}

{marker BelloniSqrt2014}{...}
{phang}
Belloni, A., Chernozhukov, V., & Wang, L. (2014). Pivotal estimation via square-root Lasso in nonparametric regression. {it:The Annals of Statistics} 42(2), 757–788. 
{browse "https://doi.org/10.1214/14-AOS1204"}
{p_end}

{marker Belloni2016}{...}
{phang}
Belloni, A., Chernozhukov, V., Hansen, C., & Kozbur, D. (2016). Inference in High Dimensional Panel Models with an Application to Gun Control. {it:Journal of Business & Economic Statistics} 34(4), 590–605. Methodology.
{browse "https://doi.org/10.1080/07350015.2015.1102733"}
{p_end}

{marker Buhlmann2006}{...}
{phang}
Bühlmann, P., & Meinshausen, N. (2006). High-dimensional graphs and variable selection with the Lasso. {it:The Annals of Statistics], 34(3), 1436–1462. 
{browse "http://doi.org/10.1214/009053606000000281"}
{p_end}

{marker Buhlmann2011}{...}
{phang}
Bühlmann, P., & Van de Geer, S. (2011). Statistics for High-Dimensional Data. Berlin, Heidelberg: Springer-Verlag.
{p_end}

{marker Chen2008}{...}
{phang}
Chen, J., & Chen, Z. (2008). Extended Bayesian information criteria for model selection with large model spaces. {it:Biometrika}, 95(3), 759–771. 
{browse "https://doi.org/10.1093/biomet/asn034"}
{p_end}

{marker SG2016}{...}
{phang}
Correia, S. 2016.
FTOOLS: Stata module to provide alternatives to common Stata commands optimized for large datasets.
{browse "https://ideas.repec.org/c/boc/bocode/s458213.html"}
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

{marker Hastie2015}{...}
{phang}
Hastie, T., Tibshirani, R., & Wainwright, M. J. (2015). Statistical Learning with Sparsity: The Lasso and Generalizations. Boca Raton: CRC Press, Taylor & Francis. 
{browse "https://www.stanford.edu/~hastie/StatLearnSparsity/"}
{p_end}

{marker Hoerl1970}{...}
{phang}
Hoerl, A. E., & Kennard, R. W. (1970). Ridge Regression: Applications to Nonorthogonal Problems. {it:Technometrics} 12(1), 69–82. 
{browse "https://doi.org/10.1080/00401706.1970.10488635"}
{p_end}

{marker Huang2008}{...}
{phang}
Huang, J., Ma, S., & Zhang, C.-H. (2008). Adaptive Lasso for Sparse High-Dimensional Regression Models Supplement. {it:Statistica Sinica} 18, 1603–1618. 
{browse "https://doi.org/10.2307/24308572"}
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

{marker Stamey1989}{...}
{phang}
Stamey, T. A., Kabalin, J. N., Mcneal, J. E., Johnstone, I. M., Freiha, F., Redwine, E. A., & Yang, N. (1989). Prostate Specific Antigen in the Diagnosis and Treatment of Adenocarcinoma of the Prostate. II. Radical Prostatectomy Treated Patients. {it:The Journal of Urology} 141(5), 1076–1083. {browse "https://doi.org/10.1016/S0022-5347(17)41175-X"}
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

{marker Kooji2007}{...}
{phang}
Van der Kooij A (2007). Prediction Accuracy and Stability of Regrsssion with Optimal Scaling Transformations. Ph.D. thesis, Department of Data Theory, University of Leiden.  
{browse "http://hdl.handle.net/1887/12096"}
{p_end}

{marker Yamada2017}{...}
{phang}
Yamada, H. (2017). The Frisch–Waugh–Lovell theorem for the lasso and the ridge regression. {it:Communications in Statistics - Theory and Methods} 46(21), 10897–10902. 
{browse "https://doi.org/10.1080/03610926.2016.1252403"}
{p_end}

{marker Zhang2010}{...}
{phang}
Zhang, Y., Li, R., & Tsai, C.-L. (2010). Regularization Parameter Selections via Generalized Information Criterion. {it:Journal of the American Statistical Association}, 105(489), 312–323. 
{browse "http://doi.org/10.1198/jasa.2009.tm08013"}
{p_end}

{marker Zhao2006}{...}
{phang}
Zhao, P., & Yu, B. (2006). On Model Selection Consistency of Lasso. {it:Journal of Machine Learning Research}, 7, 2541–2563. 
{browse "http://dl.acm.org/citation.cfm?id=1248547.1248637"}
{p_end}

{marker Zou2005}{...}
{phang}
Zou, H., & Hastie, T. (2005). Regularization and variable selection via the elastic net. {it:Journal of the Royal Statistical Society. Series B: Statistical Methodology} 67(2), 301–320. 
{browse "https://doi.org/10.1111/j.1467-9868.2005.00503.x"}
{p_end}

{marker Zou2006}{...}
{phang}
Zou, H. (2006). The Adaptive Lasso and Its Oracle Properties. {it:Journal of the American Statistical Association} 101(476), 1418–1429. 
{browse "https://doi.org/10.1198/016214506000000735"}
{p_end}

{marker Zou2007}{...}
{phang}
Zou, H., Hastie, T., & Tibshirani, R. (2007). On the "degrees of freedom" of the lasso. Ann. Statist., 35(5), 2173–2192. 
{browse "https://doi.org/10.1214/009053607000000127"}
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

{pstd}
Thanks to Alexandre Belloni, who provided Matlab code for the square-root lasso estimator,
Sergio Correia for advice on the use of the FTOOLS package,
and Jan Ditzen. 


{marker citation}{...}
{title:Citation of lasso2}

{pstd}{opt lasso2} is not an official Stata command. It is a free contribution
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
Help: {helpb cvlasso}, {helpb rlasso}, {helpb lassologit}, {helpb ivlasso}, {helpb pdslasso} (if installed).{p_end}
