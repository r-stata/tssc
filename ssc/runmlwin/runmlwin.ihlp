{smcl}
{* *! runmlwin.sthlp, George Leckie and Chris Charlton}{...}
{bf:help runmlwin}
{hline}

{title:Title}

    {cmd:runmlwin} - Run the MLwiN multilevel modelling software from within Stata


{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmd:runmlwin} {it:responses_and_fixed_part}{cmd:,} {it:random_part}
[discrete({it:{help runmlwin##discrete_options:discrete_options}})]
[mcmc({it:{help runmlwin##mcmc_options:mcmc_options}})]
[{it:{help runmlwin##general_options:general_options}}]

{p 4 4 2}
where the syntax of {it:responses_and_fixed_part} is one of the following

{p 8 8 2}
for univariate continuous, binary, proportion and count response models

{p 12 24 2}
{depvar} {indepvars} {ifin}

{p 8 8 2}
for univariate ordered and unordered categorical response models

{p 12 24 2}
{depvar} {it:{help varlist:indepvars1}} [({it:{help varlist:indepvars2}}{cmd:,} {opth con:trast(numlist)}) ... ] {ifin}

{p 12 12 2}
where {it:indepvars1} are those independent variables which appear 
with separate coefficients in each of every log-odds contrast, while {it:indepvars2} are those independent variables which appear 
with common coefficients for those log-odds contrasts specified in {opt contrast(numlist)}.
Contrasts can be thought of as the separate "subequations" or "arms" of a multinomial response model.
These contrasts are indexed 1,2,... up to the total number of contrasts included in the model.
The total number of contrasts will be one less than the number of response categories.

{p 8 8 2}
for multivariate response models

{p 12 24 2}
({it:{help varname:depvar1}} {it:{help varlist:indepvars1}}{cmd:,} {opth eq:uation(numlist)}){break}
({it:{help varname:depvar2}} {it:{help varlist:indepvars2}}{cmd:,} {opth eq:uation(numlist)}){break}
[({it:{help varname:depvar3}} {it:{help varlist:indepvars3}}{cmd:,} {opth eq:uation(numlist)})]{break} 
[ ... ]{break}
{ifin}

{p 12 12 2}
where {opt equation(numlist)} specifies equation numbers.
Equation numbers are indexed 1,2,... up to the total number of equations (i.e. response variables) included in the model.

{p 4 4 2}
and the syntax of {it:random_part} is

{p 8 18 2}
[ ... ] [level2({it:{help varname:levelvar}}: [{varlist}] [{cmd:,} {it:{help runmlwin##random_part_options:random_part_options}}])]{break}
level1({it:{help varname:levelvar}}: [{varlist}] [{cmd:,} {it:{help runmlwin##random_part_options:random_part_options}}])

{p 4 4 2}
where {it:levelvar} is a variable identifying the groups or clusters for the random effects at each level.
{it:varlist} is the list of variables with random coefficients at each level.{p_end}

{synoptset 38 tabbed}{...}
{marker random_part_options}{...}
{synopthdr :random_part_options - (R)IGLS and MCMC}
{synoptline}
{syntab:Model - (R)IGLS and MCMC}
{synopt:{opt d:iagonal}}set all covariances to zero{p_end}

{syntab:Model - (R)IGLS only}
{synopt:{opth el:ements(matrix:matrix)}}set specific (co)variances to zero{p_end}
{synopt:{opth w:eightvar(varname:varname)}}specify variable containing sampling weights{p_end}

{syntab:Model - MCMC only}
{synopt:{opth mmi:ds(varlist:varlist)}}specify variables containing multiple membership unit identifiers{p_end}
{synopt:{opth mmw:eights(varlist:varlist)}}specify variables containing multiple membership weights{p_end}
{synopt:{opth cari:ds(varlist:varlist)}}specify variables containing conditional autoregressive (CAR) unit identifiers{p_end}
{synopt:{opth carw:eights(varlist:varlist)}}specify variables containing conditional autoregressive (CAR) weights{p_end}
{synopt:{opth fli:nits(matrix)}}specify initial values for factor loadings{p_end}
{synopt:{opth flc:onstraints(matrix)}}constrain specific factor loadings to their initial values{p_end}
{synopt:{opth fvi:nits(matrix)}}specify initial values for factor (co)variances{p_end}
{synopt:{opth fvc:onstraints(matrix)}}constrain specific factor (co)variances to their initial values{p_end}
{synopt:{bf}{ul:fs}cores({sf:{it:stub}}{bf:*})}{sf}where {it:stub{bf:*}} is the variable stub for factor scores and their standard errors at this level{p_end} 
{synopt:{opt parexp:ansion}}parameter expansion{p_end}

{syntab:Estimation - (R)IGLS only}
{synopt:{opth reset:(runmlwin##resetname:resetname)}}reset (co)variances to zero when variances turn negative{p_end}

{syntab:Post-estimation - (R)IGLS and MCMC}
{synopt:{bf}{ul:r}esiduals({sf:{it:stub}}{bf:*,}{sf: [{it:{help runmlwin##residuals_options:residuals_options}}]}{bf}){sf}}where 
{it:stub{bf:*}} is the variable stub for residuals and their standard errors at this level{p_end}
{synoptline}

{marker discrete_options}{...}
{synopthdr :discrete_options - (R)IGLS and MCMC}
{synoptline}
{syntab:Model((R)IGLS and MCMC)}
{synopt:{opth d:istribution(runmlwin##distname:distname)}}distribution(s) of {it:depvar(s)}{p_end}
{synopt:{opth l:ink(runmlwin##linkname:linkname)}}link function{p_end}
{synopt:{opth de:nominator(varlist:varlist)}}denominator(s) of {it:depvar(s)}{p_end}
{synopt:{opt e:xtra}}extra binomial variation{p_end}
{synopt:{opt b:asecategory(#)}}set the value of the response to be used as the base or reference category (multinomial distributions only){p_end}
{synopt:{opth o:ffset(varname:varname)}}include {it:varname} in the model with coefficient constrained to 1 
(Poisson or negative binomial distributions only){p_end}
{synopt:{opth p:roportion(varname:varname)}}specify variable containing multinomial proportions{p_end} 
{syntab:Estimation - (R)IGLS only}
{synopt:{opt mql1:}}fit model using first order marginal quasi-likelihood linearization, the default{p_end}
{synopt:{opt mql2:}}fit model using second order marginal quasi-likelihood linearization{p_end}
{synopt:{opt pql1:}}fit model using first order penalised quasi-likelihood linearization{p_end}
{synopt:{opt pql2:}}fit model using second order penalised quasi-likelihood linearization{p_end}
{synoptline}

{marker mcmc_options}{...}
{synopthdr :mcmc_options - MCMC only}
{synoptline}
{syntab:Model - MCMC only}
{synopt:{opt log:formulation}}specify log formulation for level 1 variance{p_end}
{synopt:{opt cc}}specify cross-classified model{p_end}
{synopt:{opt msubs:cripts}}use multiple subscript notation{p_end}
{synopt:{opth corr:esiduals(runmlwin##restype:restype)}}specify the correlation structure of the level 1 random effects (i.e. the residual errors){p_end}
{synopt:{cmd:me(}{it:{help varlist}}{cmd:, }{cmd:variances(}{it:{help numlist}}{cmd:)}{cmd:)}}specify subset of independent variables with measurement error{p_end}
{synopt:{opth priorm:atrix(matrix:matrix)}}specify informative priors for fixed and random part parameters{p_end}
{synopt:{opth rpp:riors(runmlwin##rppriors_spec:rppriors_spec)}}specify prior distributions for the random part priors, the default is gamma(0.001,0.001){p_end}
{synopt:{opt carc:entre}}use CAR mean centring{p_end}
{synopt:{opth savew:inbugs(runmlwin##savewinbugs_options:savewinbugs_options)}}save specified model as a WinBUGS model{p_end}

{syntab:Estimation - MCMC only}
{synopt:{opt on}}fit model using default MCMC options{p_end}
{synopt:{opt b:urnin(#)}}specify number of iterations for the burn-in period, default is 500{p_end}
{synopt:{opt c:hain(#)}}specify number of iterations for the monitoring chain period, default is 5000{p_end}
{synopt:{opt t:hinning(#)}}store every # iteration, default is 1{p_end}
{synopt:{opt r:efresh(#)}}refresh the MLwiN equation window every # iterations, default is 50{p_end}
{synopt:{opt scale(#)}}set scale factor, default is 5.8{p_end}
{synopt:{opt noadapt:ation}}do not use adaptation{p_end}
{synopt:{opt accept:ance(#)}}set Metropolis Hastings acceptance rate, default is 0.5{p_end}
{synopt:{opt tol:erance(#)}}set the tolerance, default is 0.1{p_end}
{synopt:{opt cycles(#)}}number of cycles, default is 1{p_end}
{synopt:{opth fem:ethod(runmlwin##mcmc_method:mcmc_method)}}specify fixed effects method, default depends on specified model{p_end}
{synopt:{opth rem:ethod(runmlwin##mcmc_method:mcmc_method)}}specify random effects method, default depends on specified model{p_end}
{synopt:{opth levelonevarmethod:(runmlwin##mcmc_method:mcmc_method)}}specify level 1 variance method, default depends on specified model{p_end}
{synopt:{opth higherlevelsvarmethod:(runmlwin##mcmc_method:mcmc_method)}}specify higher level variances method, default depends on specified model{p_end}
{synopt:{opt smcmc}}use structured MCMC methods{p_end}
{synopt:{opt smvn}}use structured multivariate normal (MVN) framework{p_end}
{synopt:{opt orth:ogonal}}use orthogonal parameterisation{p_end}
{synopt:{opt hc:entring(#)}}use hierarchical centring at level #{p_end}
{synopt:{opt seed(#)}}set MCMC random number seed, default is 1{p_end}
	
{syntab:Post estimation - MCMC only}
{synopt:{cmdab:savec:hains(}{it:filename}[{opt , replace}]{cmd:)}}save MCMC parameter estimates for each iteration in filename.dta{p_end}
{synopt:{opth imputei:terations(numlist:numlist)}}impute missing values at specified iterations{p_end}
{synopt:{opt imputes:ummaries}}for each missing value, calculate the mean and the standard deviation of the chain for that missing value{p_end}
{synoptline}

{marker general_options}{...}
{synopthdr :general_options - (R)IGLS and MCMC}
{synoptline}
{syntab:Model - (R)IGLS only}
{synopt:{bf}{ul:w}eights({sf}{it:{help runmlwin##weights_options:weights_options}}{bf}){sf}}apply sampling weights options{p_end}
{synopt:{opth c:onstraints(numlist)}}apply specified linear constraints{p_end}

{syntab:Estimation - (R)IGLS only}
{synopt:{opt igls:}}fit model via iterative generalised least squares (equivalent to maximum likelihood), the default{p_end}
{synopt:{opt rigls:}}fit model via restrictive iterative generalised least squares (equivalent to maximum restricted likelihood){p_end}
{synopt:{opt maxi:terations(#)}}specifies the maximum number of (R)IGLS iterations, default is 20{p_end}
{synopt:{opt tol:erance(#)}}IGLS convergence tolerance, default is 2 (as in 10e-2){p_end}
{synopt:{opt seed:(#)}}set IGLS random number seed, default is {opt seed(1)}{p_end}

{syntab:Estimation - (R)IGLS and MCMC}
{synopt:{opt initsp:revious}}use parameter estimates from previous model as initial values{p_end}
{synopt:{opt initsm:odel(name)}}use parameter estimates from specified model as initial values{p_end}
{synopt:{opth initsb:(matrix:matrix)}}initial parameter values vector {p_end}
{synopt:{opth initsv:(matrix:matrix)}}initial sampling (co)variance values matrix{p_end}

{syntab:SE/Robust - (R)IGLS only}
{synopt:{opt fps:andwich}}sandwich estimates for fixed part standard errors{p_end}
{synopt:{opt rps:andwich}}sandwich estimates for random part standard errors{p_end}

{syntab:Reporting - (R)IGLS and MCMC}
{synopt:{opt l:evel(#)}}set confidence level; default is level(95){p_end}
{synopt:{opt or}}report fixed-effects coefficients as odds ratios{p_end}
{synopt:{opt ir:r}}report fixed-effects coefficients as incidence-rate ratios{p_end}
{synopt:{opt rr:r}}report fixed-effects coefficients as relative-rate ratios{p_end}
{synopt:{opt sd}}show random-effects variance as standard deviations{p_end}
{synopt:{opt cor:relations}}show random-effects covariance as correlations{p_end}
{synopt:{opt nohead:er}}suppress output header{p_end}
{synopt:{opt nogr:oup}}suppress table summarizing groups{p_end}
{synopt:{opt nocont:rast}}suppress table summarizing contrasts{p_end}
{synopt:{opt nofet:able}}suppress fixed-effects table{p_end}
{synopt:{opt noret:able}}suppress random-effects table{p_end}
{synopt:{help runmlwin##display_options:display_options}}control column formats{p_end}

{syntab:Reporting - MCMC only}
{synopt:{opt nodiag:nostics}}do not calculate MCMC diagnostics{p_end}
{synopt:{opt mo:de}}report parameter estimates as chain modes{p_end}
{synopt:{opt me:dian}}report parameter estimates as chain medians{p_end}
{synopt:{opt z:ratio}}report classical z-ratios and p-values{p_end}

{syntab:Post-estimation - (R)IGLS and MCMC}
{synopt:{opth sim:ulate(newvar:newvar)}}simulates a new response variable {it:newvar} based on the estimated model parameters{p_end}

{syntab:Export - (R)IGLS and MCMC}
{synopt:{opt viewm:acro}}view the MLwiN macro for the fitted model{p_end}
{synopt:{cmdab:savem:acro(}{it:filename}[{opt , replace}]{cmd:)}}save the MLwiN macro for the fitted model{p_end}
{synopt:{cmdab:savew:orksheet(}{it:filename}[{opt , replace}]{cmd:)}}save the MLwiN worksheet for the fitted model{p_end}

{syntab:Other - (R)IGLS and MCMC}
{synopt:{opt forces:ort}}forces the data to be sorted according to the model hierarchy{p_end}
{synopt:{opt nosort:}}prevents checking that the data are sorted according to the model hierarchy{p_end}
{synopt:{opt forcer:ecast}}forces a recast of all variables saved as long or double to float{p_end}
{synopt:{opt nod:rop}}prevents variables that do not appear in the model from being dropped prior to sending the data to MLwiN{p_end}
{synopt:{opt nomlwin:}}prevent MLwiN from being run{p_end}
{synopt:{opt mlwinpath:(string)}}mlwin.exe file address, including the file name{p_end}
{synopt:{opt mlwinscriptpath:(string)}}mlnscript.exe file address, including the file name; advanced use only{p_end}
{synopt:{bf}mlwinsettings({sf}{it:{help runmlwin##mlwin_settings:mlwin_settings}}{bf}){sf}}manually override MLwiN settings{p_end}
{synopt:{opt nop:ause}}suppresses the two pause steps in MLwiN{p_end}
{synopt:{opt batc:h}}prevents any MLwiN GUI windows being displayed; advanced use only{p_end}
{synoptline}

{synoptset 38}{...}
{marker resetname}{...}
{synopthdr :resetname - (R)IGLS only}
{synoptline}
{synopt :{opt all:}}reset all (co)variances to zero{p_end}
{synopt :{opt var:iances}}reset only the variances to zero{p_end}
{synopt :{opt none:}}reset no (co)variances{p_end}
{synoptline}

{marker weights_options}{...}
{synopthdr :weights_options - (R)IGLS only}
{synoptline}
{synopt :{opt nos:tandardisation}}no standardisation of the level specific weight variables{p_end}
{synopt :{opt nofps:andwich}}no sandwich estimates for fixed part standard errors{p_end}
{synopt :{opt norps:andwich}}no sandwich estimates for random part standard errors{p_end}
{synoptline}

{marker residuals_options}{...}
{synopthdr :residuals_options - (R)IGLS and MCMC}
{synoptline}
{synopt :{opt var:iances}}posterior variances{p_end}
{synopt :{opt stand:ardised}}standardised residuals{p_end}
{synopt :{opt lev:erage}}leverage residuals{p_end}
{synopt :{opt inf:luence}}influence residuals{p_end}
{synopt :{opt del:etion}}deletion residuals{p_end}
{synopt :{opt samp:ling}}sampling variance-covariance matrix{p_end}
{synopt :{opt norecode:}}do not recode residuals exceedingly close or equal to zero to missing{p_end}
{synopt :{opt ref:lated}}unshrunken residuals{p_end}
{synoptline}

{marker residuals_options}{...}
{synopthdr :residuals_options - MCMC only}
{synoptline}
{synopt:{cmdab:savec:hains(}{it:filename}[{opt , replace}]{cmd:)}}save MCMC residual estimates for each iteration in filename.dta{p_end}
{synoptline}

{marker distname}{...}
{synopthdr :distname - (R)IGLS and MCMC}
{synoptline}
{synopt :{opt normal:}}normal distribution{p_end}
{synopt :{opt binomial:}}binomial distribution{p_end}
{synopt :{opt multinomial:}}multinomial distribution{p_end}
{synopt :{opt poisson:}}Poisson distribution{p_end}
{synopt :{opt nbinomial:}}negative binomial distribution{p_end}
{synoptline}

{marker linkname}{...}
{synopthdr :linkname - (R)IGLS and MCMC}
{synoptline}
{synopt :{opt l:ogit}}logit link function{p_end}
{synopt :{opt p:robit:}}probit link function{p_end}
{synopt :{opt c:loglog:}}complementary log-log link function{p_end}
{synopt :{opt log:}}log link function{p_end}
{synopt :{opt ol:ogit:}}ordered logit link function{p_end}
{synopt :{opt op:robit:}}ordered probit link function{p_end}
{synopt :{opt oc:loglog:}}ordered complementary log-log link function{p_end}
{synopt :{opt m:logit:}}unordered logit link function{p_end}
{synoptline}

{marker restype}{...}
{synopthdr :restype - MCMC only}
{synoptline}
{synopt :{opt un:structured}}unstructured (co)variance matrix{p_end}
{synopt :{opt ex:changeable}}structured errors with a common correlation parameter and a common variance parameter{p_end}
{synopt :{opt areq:vars}}AR1 errors with a common variance parameter{p_end}
{synopt :{opt eqcorrsindep:vars}}structured errors with a common correlation parameter and independent variance parameters{p_end}
{synopt :{opt arindep:vars}}AR1 errors with independent variance parameters{p_end}
{synoptline}
	
{marker rppriors_spec}{...}
{synopthdr :rppriors_spec - MCMC only}
{synoptline}
{synopt :{opt u:niform}}use the uniform prior distribution{p_end}
{synopt :{opt g:amma(a b)}}use the gamma prior distribution with shape a and scale b, the default is gamma(0.001,0.001){p_end}
{synoptline}

{marker mcmc_method}{...}
{synopthdr :mcmc_method - MCMC only}
{synoptline}
{synopt :{opt gibbs}}Gibbs algorithm{p_end}
{synopt :{opt uni:variatemh}}univariate Metropolis Hastings algorithm{p_end}
{synopt :{opt multi:variatemh}}multivariate Metropolis Hastings algorithm{p_end}
{synoptline}
	
{marker savewinbugs_options}{...}
{synopthdr :savewinbugs_options - MCMC only}
{synoptline}
{synopt :{cmdab:m:odel(}{it:filename}[{opt , replace}]{cmd:)}}save model as a WinBUGS model in filename.txt{p_end}
{synopt :{cmdab:i:nits(}{it:filename}[{opt , replace}]{cmd:)}}save initial values in WinBUGS format in filename.txt{p_end}
{synopt :{cmdab:d:ata(}{it:filename}[{opt , replace}]{cmd:)}}save data in WinBUGS format in filename.txt{p_end}
{synopt :{opt nof:it}}do not fit the model in MLwiN{p_end}
{synoptline}

{marker mlwin_settings}{...}
{synopthdr :mlwin_settings - (R)IGLS and MCMC}
{synoptline}
{synopt :{opt s:ize(#)}}specify maximum worksheet size allowed in MLwiN{p_end}
{synopt :{opt l:evels(#)}}specify maximum number of levels allowed in MLwiN{p_end}
{synopt :{opt c:olumns(#)}}specify maximum number of data columns allowed in MLwiN{p_end}
{synopt :{opt v:ariables(#)}}specify maximum number of modelled variables allowed in MLwiN{p_end}
{synopt :{opt tempmat}}use memory allocated to the worksheet to store temporary matrices in MLwiN{p_end}
{synopt :{opt optimat}}limit the maximum matrix size allocated in MLwiN{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:runmlwin} allows Stata users to run the powerful MLwiN multilevel modelling software from within Stata.

{pstd}
See {it:{help runmlwin##alternative_commands:Remarks on alternative Stata commands for fitting multilevel models}} below for more information.

{pstd}
MLwiN has the following features:

{p 8 12 2}
(1) Estimation of multilevel models for continuous, binary, count, ordered categorical and unordered categorical data;

{p 8 12 2}
(2) Fast estimation via classical and Bayesian methods;

{p 8 12 2}
(3) Estimation of multilevel models for cross-classified and multiple membership non-hierarchical data structures;

{p 8 12 2}
(4) Estimation of multilevel multivariate response models, multilevel spatial models, multilevel measurement error models and multilevel multiple imputation models.


{pstd}
MLwiN is required to use {cmd:runmlwin}.
See {it:{help runmlwin##downloading_runmlwin:Remarks on {cmd:runmlwin} installation instructions}} below for more information.

{pstd}
A comprehensive range of {cmd:runmlwin} examples and a user forum are available at:

{p 8 12 2}{browse "http://www.bristol.ac.uk/cmm/software/runmlwin":http://www.bristol.ac.uk/cmm/software/runmlwin}


{marker options}{...}
{title:Options}

{marker options_model}{...}
{dlgtab:Model}

{pstd}(a) random part model options

{pstd}All options reported in this sub-section are specific to the level at which they are specified.

{phang}{opt diagonal} specifies a diagonal matrix for the random effects variance-covariance matrix.
This implies zero correlations between the random effects at that level.
Note that should a Toeplitz or other banded structures be desired (for example when modelling longitudinal data),
these can be implemented using the {opt constraints} options.

{phang}{opt elements(matrix)} sets specific (co)variances to zero.
Note that the matrix must be a row vector with one column for each (co)variance where the lower diagonal elements of the 
variance covariance matrix have been vectorised row by row.
If there are {it:q} random effects terms (variables with random coefficients),
the unstructured covariance matrix has {it:q}({it:q}+1)/2 unique parameters.
The elements of this vector must be 0 or 1 where 0 sets the relevant (co)variance to zero and 1 specifies the parameter to be freely estimated.
See {it:{help runmlwin##examples:Examples}} for an example of this option.

{phang}{opt weightvar(varname)} specifies the variable containing the sampling weights.

{phang}{opt mmids(varlist)} specifies the variables containing the multiple membership unit identifiers.
The number of variables should equal the maximum number of higher level units that any lower level unit belongs to.
The order in which the multiple membership unit identifier variables is specified is irrelevant other than it must correspond to
the order in which the associated multiple membership weight variables is specified.
Zero values rather than missing values must be assigned for redundant identifier variables.

{phang}{opt mmweights(varlist)} specifies the variables containing the multiple membership weights.
The number of variables should equal the maximum number of higher level units that any lower level unit belongs to.
The ordering of the variables must correspond to the ordering of the multiple membership unit identifier variables.
Zero values rather than missing values must be assigned for redundant weight variables.

{phang}{opt carids(varlist)} specifies the variables containing the conditional autoregressive (CAR) unit identifiers.
The number of variables should equal the maximum number of higher level units that any lower level unit belongs to.
The order in which the CAR unit identifier variables is specified is irrelevant other than it must correspond to
the order in which the associated CAR weight variables is specified.
Zero values rather than missing values must be assigned for redundant identifier variables.

{phang}{opt carweights(varlist)} specifies the variables containing the conditional autoregressive (CAR) weights.
The number of variables should equal the maximum number of higher level units that any lower level unit belongs to.
The ordering of the variables must correspond to the ordering of the CAR unit identifier variables.
Zero values rather than missing values must be assigned for redundant weight variables.

{phang}{opt flinits(matrix)} specifies initial values for factor loadings.
The number of rows must equal the number of responses.
The number of columns must equal the number of factors.

{phang}{opt flconstraints(matrix)} constrain specific factor loadings to their initial values.
The number of rows must equal the number of responses.
The number of columns must equal the number of factors.
The elements of this matrix must be 0 or 1 where 0 freely estimates the factor loading and 1 constrains the factor loading to its initial value.

{phang}{opt fvinits(matrix)} specifies initial values for factor (co)variances.
The number of rows and the number of columns must equal the number of factors.
The diagonal elements correspond to the factor variances.
The off-diagonal elements correspond to the factor covariances.
Initial values for the factor variances must be positive.
Intial values for the covariances must correspond to correlations that lie between -1 and +1.

{phang}{opt fvconstraints(matrix)} constrain specific factor (co)variances to their initial values.
The number of rows and the number of columns must equal the number of factors.
The elements of this matrix must be 0 or 1 where 0 freely estimates the (co)variance and 1 constrains the (co)variance to its initial value.

{phang}{bf}{ul:fs}cores({sf:{it:stub}}{bf:*}){sf} calculates posterior estimates of the factor scores and their associated standard errors for all factors specified at the given level.
runmlwin will name the factors.  
For example if there are three factors in the model, runmlwin would name the factors {it:stub1}, {it:stub2}, {it:stub3} and would name their associated standard errors as {it:stub1se}, {it:stub2se}, {it:stub3se}.

{phang}{opt parexpansion} uses parameter expansion. Note that parameter expansion cannot be specified at level 1.


{pstd}(b) discrete response model options         

{phang}{opt distribution(distname)} specifies the distribution(s) of the {it:depvar(s)}. 
{opt normal} is applicable for continuous response variables, {opt binomial} for binary and proportion response variables, 
{opt multinomial} for ordinal and nominal categorical response variables and {opt poisson} and {opt nbinomial} (negative binomial) are 
applicable for count responses.
In multivariate response models where one or more response variables are discrete, one distribution must be given for each response variable.

{phang}{opt link(linkname)} specifies the link function.
{opt logit}, {opt probit} and {opt cloglog} (complementary log-log) are applicable when the {opt binomial}
distribution has been specified,
{opt log} is applicable when either the {opt poisson} or {opt nbinomial} distributions have been specified, 
and {opt ologit} (ordered logit), {opt oprobit} (ordered probit), {opt ocloglog} (ordered complementary log-log)
and {opt mlogit} (unordered logit) are applicable  when the {opt multinomial} distribution has been specified.
Note that it is not possible to specify multivariate response models which have a mixture of different types of discrete response.
Thus, only one link function can be specified for the discrete responses.
In multivariate response models where a mixture of continuous and discrete response variables are specified,
only the link function for the discrete responses is specified.

{phang}{opt denominator(varlist)} specifies the variables containing the {opt binomial} denominator(s) (i.e. the number of binomial 
trials) for the response variable(s).
This option is only applicable when modelling proportions (i.e. counts with known totals). 
For example, to model school level data on the proportion of students who pass an exam, the data should have one row per school, 
the {it:depvar} is the proportion of students who passed the exam and the {opt denominator} is the number of students who took the exam. 
Note that this implementation differs from that for {manhelp xtmelogit XT} where one would specify a numerator (the number of children who 
passed the exam) as the response variable rather than the proportion.

{phang}{opt extra} specifies an extra binomial variation parameter to allow for over- or under-dispersion.

{phang}{opt basecategory(#)} specifies the value of the response to be used as the base or reference category.
This option is only applicable when modelling ordinal or nominal categorical response variables using the {opt multinomial} distribution. 
When modelling ordinal responses, the basecategory must be either the first or last response category.

{phang}{opt offset(varname)} includes {it:varname} in the fixed part of the model with coefficient constrained to one.
This option is only applicable when modelling count responses using the {opt poisson} or {opt nbinomial} distributions.

{phang}{opt proportion(varname)} specifies the variable containing multinomial proportions.
For example, to model neighbourhood level data on the proportion of individuals in good, average and poor health,
the data should have three rows per neighbourhood.
The first row should give the proportion of individuals in good health.
The second row should give the proportion of individuals in average health.
The third row should give the proportion of individuals in poor health.
The total number of individuals in each neighbourhood is then specified with the {opt denominator} option.


{pstd}(c) MCMC model options

{phang}{opt logformulation} specifies a log formulation model for the level 1 variance.

{phang}{opt cc} specifies that the model is a non-hierarchical cross-classified model rather than a hierarchal model. In cross-classified models, the levels are often referred to as classifications.

{phang}{opt msubscripts} uses multiple subscript notation.

{phang}{opt corresiduals(restype)} specifies the correlation structure of the level 1 random effects (i.e. the residual errors).

{pmore}{opt unstructured}, the default, is the most general structure; 
it estimates distinct variances for each residual error and distinct covariances for each residual error pair.

{pmore}{opt exchangeable} fits structured errors with a common correlation parameter and a common variance parameter.

{pmore}{opt ar1eqvars} fits AR1 errors with a common variance parameter.

{pmore}{opt eqcorrsindepvars} fits structured errors with a common correlation parameter and independent variance parameters.

{pmore}{opt ar1indepvars} fits AR1 errors with independent variance parameters.

{phang}{cmd:me(}{it:varlist}{cmd:, }{cmd:variances(}{it:numlist}{cmd:)}{cmd:)} specifies the subset of independent variables with measurement error.
The corresponding measurement error variances are specified in {opt variances(numlist)}.

{phang}{opt priormatrix(matrix)} specifies informative priors for the fixed and random part parameters.

{phang}{opt rppriors(rppriors_spec)} specifies prior distributions for the random part priors.
{opt uniform} specifies the uniform distribution.
{opt gamma(a, b)} specifies the gamma distribution.
The default {it:rppriors_spec} is {cmd:gamma(0.001,0.001)}.
Note that when {opt uniform} is specified there is a display error in MLwiN by which the Equations window incorrectly shows the uniform priors to be gamma priors.

{phang}{opt carcentre} enables CAR mean centring (an intercept should be included in the model when this option is turned on)

{phang}{opt savewinbugs(savewinbugs_options)} saves the specified model as a WinBUGS model.
The model can then be fitted in WinBUGS using the {cmd:winbugs} suite of commands if these are installed.

{pmore}
{it:savewinbugs_options} are

{phang3}
{opt model(filename [, replace])} saves the model as a WinBUGS model in filename.txt
	
{phang3}
{opt inits(filename [, replace])} saves the initial values in WinBUGS format in filename.txt
	
{phang3}
{opt data(filename [, replace])} saves the data in WinBUGS format in filename.txt
	
{phang3}
{opt nofit} do not fit the model in MLwiN


{pstd}(d) general model options

{phang}{opt weights(weights_options)} specifies overall options for any sampling weights variables included in the model.
This option can only be specified if the user has specified the {opt weightvar} option at one or more levels.

{pmore}The {opt nostandardisation} option specifies that the level specific weight variables should not be standardised

{pmore}The {opt nofpsandwich} option specifies that sandwich estimates should not be used for the standard errors of the fixed part parameter estimates at any level

{pmore}The {opt norpsandwich} option specifies that sandwich estimates should not be used for the standard errors of the random part parameter estimates at any level

{pmore}
See {it:{help runmlwin##sampling_weights:Remarks on using sampling weights}} below for more information.

{phang}{opt constraints(clist)} specifies the constraint numbers for the constraints to be applied to the model.
Constraints are specified using the {manhelp constraint R} command.
Only linear constraints can be specified.
See {it:{help runmlwin##examples:Examples}} for an example of this option.


{marker options_estimation}{...}
{dlgtab:Estimation}

{pstd}(a) random part estimation options

{pstd}All options reported in this sub-section are specific to the level at which they are specified.

{phang}{opt reset(resetname)} specifies the action to be taken when during estimation a variance parameter at a particular iteration 
is estimated to be negative. 
{cmd:all} resets a negative variance to zero along with any associated covariances. 
{cmd:variances} resets a negative variance to zero but not the associated covariances. 
{cmd:none} ignores negative variances; no parameters are reset to zero. 


{pstd}(b) discrete response estimation options

{phang}{opt mql1}, the default, specifies that the model be fitted using a first order marginal quasi-likelihood linearization.
See {it:{help runmlwin##quasilikelihood_estimates:Remarks on quasilikelihood estimates: MQL1, MQL2, PQL1 and PQL2}} below for more information.

{phang}{opt mql2} specifies that the model be fitted using a second order marginal quasi-likelihood linearization.

{phang}{opt pql1} specifies that the model be fitted using a first order penalised quasi-likelihood linearization.

{phang}{opt pql2} specifies that the model be fitted using a second order penalised quasi-likelihood linearization.


{pstd}(c) MCMC estimation options

{phang}{opt on} fits the specified model using default MCMC options.

{phang}{opt burnin(#)} specifies the number of iterations for the burn-in period.
The default is {cmd:burnin(500)}.
This option specifies the number of iterations necessary for the MCMC to reach approximate stationary or, equivalently, to converge to a stationary distribution.
The required length of the burn-in period will depend on the initial values.

{phang}{opt chain(#)} specifies the number of iterations for the monitoring chain period.
The default {cmd:is chain(5000)}.
This is the number of iterations, after the burn-in period, for which the chain is to be run.
Distributional summaries for the parameters are based on these iterations.
Parameter estimates are given by the means of these chains, while the standard errors are given by the standard deviation of these chains.

{phang}{opt thinning(#)} stores every #-th iteration of the monitoring chains.
The default is {cmd:thinning(1)}.
Parameter means and standard deviations are based on the non-thinned monitoring chains.
All other MCMC summary statistics (e.g. ESS and 95% credible intervals) are based on the thinned monitoring chain.
The {opt or}, {opt irr}, {opt rrr}, {opt sd}, {opt correlation}, {opt mode} and {opt median} options also all only apply to the thinned monitoring chains.
For example, fitting a model for a monitoring chain length of 50,000 and setting thinning to 10 will result in 5,000 iterations being stored.
The parameter means and standard deviations will then be based on all 50,000 iterations,
while the ESS's and 95% credible intervals will be based on the 5,000 stored iterations.

{phang}{opt refresh(#)} refreshes the MLwiN equation window every # stored iterations.
The default is {cmd:refresh(50)}.
When the {opt nopause} option is not used, refreshing the MLwiN equation window less frequently can speed up estimation time. 

{phang}{opt scale(#)} sets the scale factor.
The default is {cmd:scale(5.8)}.

{phang}{opt noadaptation} prevents adaptation from being used.

{phang}{opt acceptance(#)} sets the Metropolis Hastings acceptance rate.
The default is {cmd:acceptance(0.5)} and permissible values range from zero to one.

{phang}{opt tolerance(#)} sets the tolerance rate used for adapting.
The default is {cmd:tolerance(0.1)} and permissible values range from zero to one.

{phang}{opt cycles(#)} sets the number of Metropolis Hastings cycles per MCMC iteration.
The default is {cmd:cycles(1)}.
The higher # is, the more likely a new proposed parameter value will be accepted on each iteration.

{phang}{opt femethod(mcmc_method)} specifies the MCMC method for estimating the fixed effects.
The default depends on the specified model.

{pmore}{opt gibbs} uses the Gibbs algorithm and is the default for continuous response models.

{pmore}{opt univariatemh} uses the univariate Metropolis Hastings algorithm and is the default for univariate discrete response models.

{pmore}{opt multivariatemh} uses the multivariate Metropolis Hastings algorithm and is the default for multivariate response models
with at least one discrete response.

{phang}{opt remethod(mcmc_method)} specifies the MCMC method for estimating the random effects.
The default depends on the specified model.
{it:mcmc_method} is defined under the {opt femethod(mcmc_method)} option.

{phang}{opt levelonevarmethod(mcmc_method)} specifies the MCMC method for estimating the level 1 variance.
The default depends on the specified model. {it:mcmc_method} is defined under the {opt femethod(mcmc_method)} option.

{phang}{opt higherlevelsvarmethod(mcmc_method)} specifies the MCMC method for estimating the level 2 and higher variances.
The default depends on the specified model. {it:mcmc_method} is defined under the {opt femethod(mcmc_method)} option.

{phang}{opt smcmc} uses structured MCMC methods.

{phang}{opt smvn} uses the structured multivariate normal (MVN) framework.

{phang}{opt orthogonal} uses orthogonal parameterisation.
Note that Browne (2012) recommends to always specify this option for discrete response models.
There is little advantage to specifying this option for continuous response models as in these models the fixed effects are generally blocked updated.

{phang}{opt hcentring(#)} uses hierarchical centring at level #.

{phang}{opt seed(#)} specifies the initial value of the MCMC random number seed. The default is {cmd:seed(1)}.
{it:#} should be a positive integer.
Note that there are two random number seeds in MLwiN and therefore two seed options in {cmd:runmlwin}:
The IGLS random number seed and the MCMC random number seed.
In contrast to Stata commands, both seeds in MLwiN have default initial values.
That is, these seeds are the same every time you call {cmd:runmlwin}.
The only time you will therefore need to set the IGLS or M seeds is
if you wish to replicate MLwiN analyses carried out when using MLwiN in the traditional point-and-click way.


{pstd}(d) General estimation options

{phang}{opt igls}, the default, specifies that the model be fitted using iterative generalised least squares (equivalent to maximum likelihood).
See {it:{help runmlwin##IGLS_vs_RIGLS:Remarks on IGLS vs. RIGLS}} below for more information.

{phang}{opt rigls} specifies that the model be fitted using restrictive iterative generalised least squares (equivalent to maximum restricted likelihood, 
also referred to as residual maximum likelihood).

{phang}{opt maxiterations(#)} specifies the maximum number of (R)IGLS iterations.
The default is {cmd:maxiterations(20)}.

{phang}{opt tolerance(#)} specifies the convergence tolerance for the IGLS algorithm.
The default is {opt tolerance(2)} as in a tolerance of 10e-2.
IGLS iterations will be halted once every parameter changes by a relative amount less than {it:#}.

{phang}{opt seed(#)} specifies the initial value of the IGLS random number seed.
The default is {opt seed(1)}.
This option allows you to replicate your results if you use the {opt simulate(newvar)} option.
{it:#} should be a positive integer.
Note that there are two random number seeds in MLwiN and therefore two seed options in {cmd:runmlwin}:
The IGLS random number seed and the MCMC random number seed.
In contrast to Stata commands, both seeds in MLwiN have default initial values.
That is, these seeds are the same every time you call {cmd:runmlwin}.
The only time you will therefore need to set the IGLS or M seeds is
if you wish to replicate MLwiN analyses carried out when using MLwiN in the traditional point-and-click way.

{phang}{opt initsprevious} specifies that the parameter estimates from the previous model are used as the initial values. 
This option is used:
(1) when building a series of increasingly complex models using IGLS;
(2) when moving from MQL1 estimation to PQL2 estimation;
(3) to specify initial values for MCMC estimation.
When the current model contains new parameters not specified in the previous model, new fixed part parameters are set to zero,
random part variance parameters are set to one and random part covariances are set to zero.

{pmore}
Note that when this option is used to specify initial values for fitting the model using the Metropolis Hastings algorithm in MCMC 
(i.e. for discrete response models), this option will also feed the parameter sampling variance-covariance values into the algorithm.

{phang}{opt initsmodel(name)} specifies that the parameter estimates from the model results saved under {it:name} are used as the initial values.
See comments for {opt initsprevious}.

{phang}{opt initsb(matrix)} specifies the parameter initial values vector.
See comments for {opt initsprevious}.

{phang}{opt initsv(matrix)} specifies the parameter initial sampling variance-covariance values matrix.
Note this option is only relevant when fitting the model using the Metropolis Hastings algorithm in MCMC (i.e. for discrete response models).
See comments for {opt initsprevious}.


{marker options_se_robust}{...}
{dlgtab:SE/Robust}

{phang}{opt fpsandwich} specifies the cluster-robust or sandwich estimates for the fixed part standard errors.
The clusters are the highest-level units.

{phang}{opt rpsandwich} specifies the cluster-robust or sandwich estimates for the random part standard errors.
The clusters are the highest-level units.


{marker options_reporting}{...}
{dlgtab:Reporting}

{phang}{opt level(#)} set confidence level (credible level if using MCMC);
default is {cmd:level(95)}.

{phang}{opt or} reports the fixed-effects coefficients transformed to odds ratios, i.e., exp(b) rather than b.
Standard errors and confidence intervals are similarly transformed.  
This option affects how results are displayed, not how they are estimated.  
{opt or} may only be specified when modelling binary responses when using the {opt binomial} distribution and logit link function
or when modelling ordinal categorical responses using the {opt multinomial} distribution.
{opt or} may be specified at estimation or when replaying previously estimated results.

{phang}{opt irr} reports the fixed-effects coefficients transformed to incidence-rate ratios, i.e., exp(b) rather than b.
Standard errors and confidence intervals are similarly transformed.
This option affects how results are displayed, not how they are estimated.
{opt irr} may only be specified when modelling count responses using the {opt poisson} or {opt nbinomial} distributions.
{opt irr} may be specified at estimation or when replaying previously estimated results.

{phang}{opt rrr} reports the fixed-effects coefficients transformed to relative-risk ratios, i.e., exp(b) rather than b.
Standard errors and confidence intervals are similarly transformed.
This option affects how results are displayed, not how they are estimated.
{opt rrr} may only be specified when modelling nominal categorical responses using the {opt multinomial} distribution.
{opt rrr} may be specified at estimation or when replaying previously estimated results.

{phang}{opt sd} shows random-effects variance parameter estimates as standard deviations.
Standard errors and confidence intervals are similarly transformed.  
This option affects how results are displayed, not how they are estimated.  
{opt sd} may be specified at estimation or when replaying previously estimated results.

{phang}{opt correlations} shows random-effects covariance parameter estimates as correlations.
Standard errors and confidence intervals are similarly transformed.  
This option affects how results are displayed, not how they are estimated.  
{opt correlations} may be specified at estimation or when replaying previously estimated results.

{phang}{opt noheader} suppresses the output header, either at estimation or upon replay.

{phang}{opt nogroup} suppresses the display of group summary information (number of groups, average group size, minimum, and maximum) 
from the output header.
{opt nogroup} may be specified at estimation or when replaying previously estimated results.

{phang}{opt nocontrast} suppresses the display of contrast summary information (number of contrasts, description of each contrast) 
from the output header.
This option is only relevant for multinomial response models.
{opt nocontrast} may be specified at estimation or when replaying previously estimated results.

{phang}{opt nofetable} suppresses the fixed-effects table from the output, either at estimation or upon replay.

{phang}{opt noretable} suppresses the random-effects table from the output, either at estimation or upon replay.

{phang}{opt nodiagnostics} prevents MCMC diagnostics from being calculated.
This is a helpful option to specify if you are running a simulation study using MCMC estimation
as the calculation of the MCMC diagnostics can take some time for models fitted to large data sets.
Note that specifying this option will not allow the
{opt or}, {opt irr}, {opt rrr}, {opt sd}, {opt correlation}, {opt mode} and {opt median} options to be specified.
{opt nodiagnostics} may be specified at estimation or when replaying previously estimated results.

{phang}{opt mode} reports the parameter estimates as the modes of the MCMC chains rather than the means.
{opt mode} may be specified at estimation or when replaying previously estimated results.

{phang}{opt median} reports the parameter estimates as the medians of the MCMC chains rather than the means.
{opt median} may be specified at estimation or when replaying previously estimated results.

{phang}{opt zratio} reports classical z-ratios and p-values (i.e. under the assumption that the chains are normally distributed)
{opt zratio} may be specified at estimation or when replaying previously estimated results.

{marker display_options}{...}
{phang}{opt display_options}  cformat({help fmt:%fmt}), pformat({help fmt:%fmt}), sformat({help fmt:%fmt}); see {help estimation options##display_options:[R] estimation options.}

{marker options_post_estimation}{...}
{dlgtab:Post-estimation}

{phang}{opt simulate(newvar)} simulates a new response variable based on the estimated model parameters.
Make sure to specify the IGLS random number {opt seed} to be able to replicate the simulated responses.

{phang}{opt residuals(stub*, residuals_options)} calculates posterior estimates of the residuals and their associated standard errors 
for all random effects specified at the given level.
Posterior estimates are also known as empirical Bayes estimates or best linear unbiased predictions (BLUPs) of the random effects.
{cmd:runmlwin} will name the residuals.
For example if there are three random effects terms in the model, {cmd:runmlwin} would name the
residuals {it:stub0}, {it:stub1}, {it:stub2} and would name their associated standard errors as {it:stub0se}, {it:stub1se}, {it:stub2se}.

{pmore}The {opt variances} option calculates the posterior variances instead of the posterior standard errors.

{pmore}The {opt standardised}, {opt leverage}, {opt influence} and {opt deletion} options calculate standardised, leverage, influence 
and deletion residuals respectively.
The postfix for these four types are {it:std}, {it:lev}, {it:inf} and {it:del} respectively.
For example if there are two random effects terms in the model, {cmd:runmlwin} would name the standardised residuals {it:stub0std},
{it:stub1std} and {it:stub2std}.

{pmore}The {opt sampling} option calculates the sampling variance covariance matrix for the residuals.
For example if there are three random effects terms in the model, {cmd:runmlwin} would name the standardised residuals {it:stub0var},
{it:stub01cov}, {it:stub1var}, {it:stub02cov}, {it:stub12cov}, {it:stub2var}.

{pmore}The {opt norecode} option prevents residuals with values exceedingly close or equal to zero from being recoded to missing.

{pmore}The {opt reflate} option returns unshrunken residuals.

{phang}{opt savechains(filename [, replace])} saves the MCMC parameter estimates for each iteration in filename.dta.

{phang}{opt imputeiterations(numlist)} imputes missing values at specified iterations.
It is important to specify a sufficiently high number of iterations between imputations to reduce the correlation between the sets of imputed values.

{phang}{opt imputesummaries} for each missing value, calculates the mean and the standard deviation of the chain for that missing value.


{marker options_export}{...}
{dlgtab:Export}

{phang}{opt viewmacro} view the MLwiN macro for the fitted model.
This option is useful if you wish to learn how to write your own MLwiN macros.

{phang}{opt savemacro(filename[, replace])} saves the MLwiN macro for the fitted model.
The {opt replace} option overwrites the MLwiN macro if it already exists.

{phang}{opt saveworksheet(filename[, replace])} saves the MLwiN worksheet for the fitted model.
The {opt replace} option overwrites the MLwiN worksheet if it already exists.


{marker options_other}{...}
{dlgtab:Other}

{phang}{opt forcesort} forces the data sent to MLwiN to be sorted according to the model hierarchy.
We recommend that users sort their data manually using the {cmd:sort} command prior to using {cmd:runmlwin}.

{phang}{opt nosort} prevents {cmd:runmlwin} from checking that the data are sorted according to the model hierarchy.
When this option is used {cmd:runmlwin} does not report the table summarizing groups and the {opt residuals()} and {opt fscores()} options are not allowed.

{phang}{opt forcerecast} forces a recast of all variables saved as long or double to float.
forcerecast should be used with caution.
forcerecast is for those instances where you have a variable saved as a long or double but would now be satisfied to have the variable stored as a float, even
though that would lead to a slight rounding of its values.
An important example of when this is inappropriate is when identifiers variables are saved as long or double.
A slight rounding of the values of identifiers will lead to a merging of units.

{phang}{opt nodrop} prevents variables that do not appear in the model from being dropped prior to sending the data to MLwiN.

{phang}{opt nomlwin} prevents MLwiN from being run.
When used in conjunction with the {opt viewmacro} option, the user can examine the MLwiN macro that {cmd:runmlwin} writes,
without having to fit the associated model in MLwiN.

{phang}{opt mlwinpath(string)} specifies the file address for mlwin.exe, including the file name.

{pmore}
For example: {bf:mlwinpath(C:\Program Files (x86)\MLwiN v2.31\i386\mlwin.exe)}.

{phang}{opt mlwinscriptpath(string)} is an advanced option which specifies the file address for mlnscript.exe, including the file name.

{pmore}
For example: {bf:mlwinscriptpath(C:\Program Files\MLwiN v2.26\i386\mlnscript.exe)}.

{pmore}
mlnscript.exe is a command line version of MLwiN, which only runs scripts.
Note, that runmlwin will only call mlnscript.exe when {opt batch} is specified.
See {it:{help runmlwin##remarks_batch_mode:Remarks on running runmlwin in batch mode}} below for more information.

{phang}{opt mlwinsettings(mlwin_settings)} manually overrides MLwiN's default settings.
The default behaviour is that {cmd:runmlwin} will examine the specified model and then automatically override
MLwiN's default {opt size}, {opt levels}, {opt columns} and {opt variables} settings with model specific settings.
However, a potential issue is that {cmd:runmlwin} typically overrides MLwiN's default settings with settings that are conservative
(i.e. settings that are typically higher than the minimum required to fit the model).
Thus, {cmd:runmlwin} will assign more RAM to MLwiN than is strictly necessary.
Users who run into error messages relating to a shortage of RAM on their computer,
may therefore wish to experiment with manually overriding these settings to attempt to get the model to fit.

{pmore}
{it:mlwin_settings} are

{phang3}
{opt size(#)} specifies the maximum worksheet size allowed in MLwiN
	
{phang3}
{opt levels(#)} specifies the maximum number of levels allowed in MLwiN
	
{phang3}
{opt columns(#)} specifies the maximum number of data columns allowed in MLwiN
	
{phang3}
{opt variables(#)} specifies the maximum number of modelled variables allowed in MLwiN

{phang3}
{opt tempmat} instructs MLwiN to use memory allocated to the worksheet to store temporary matrices used by the (R)IGLS algorithm

{phang3}
{opt optimat} instructs MLwiN to limit the maximum matrix size that can be allocated by the (R)IGLS algorithm.
Specify this option if MLwiN gives the following error message "Overflow allocating smatrix".
This error message arises if one more higher-level units is extremely large (contains more than 800 lower-level units).
In this situation {cmd:runmlwin}'s default behaviour is to instruct MLwiN to allocate a larger matrix size to the (R)IGLS algorithm than is currently possible.
Specifying {opt optimat} caps the maximum matrix size at 800 lower-level units, circumventing the MLwiN error message, and allowing most MLwiN functionality.

{phang}{opt nopause} suppresses the two pause steps in MLwiN.
This option is very useful if you want to run a do-file containing a series of {cmd:runmlwin} models.
MLwiN will automatically launch and exit once each specified model has been fitted.
MLwiN will not display the Equations window, but estimation progress is indicated by the progress gauges in the bottom left hand corner of the MLwiN software.
See {it:{help runmlwin##examples:Examples}} for an example of this option.

{phang}{opt batch} suppresses the two pause steps in MLwiN and prevents the MLwiN software from being displayed.
This option is very useful if you want to perform a simulation study.
MLwiN will automatically launch and exit once each specified model has been fitted, but this will not be visible to the user.
A limitation of this option is that there is no way of monitoring a model's estimation progress.
For example, it is not possible to see for how many iterations a model has been iterating for.

{pmore}
This option can also be used in conjunction with running Stata in batch mode in an environment without an interactive session. 
Examples of this would be running Stata from a task scheduler (see {browse "http://www.stata.com/support/faqs/win/batch.html":http://www.stata.com/support/faqs/win/batch.html}) 
or submitting jobs to a cluster.
When this option is used any error messages produced by MLwiN are displayed in Stata after the model is run.

{pmore}
In addition, if you have used {opt mlwinscriptpath()} or the MLwiNScript_path {cmd:global} to specify the mlnscript.exe file address,
then specifying {opt batch} will run the model using mlnscript.exe rather than mlwin.exe.
See {it:{help runmlwin##remarks_batch_mode:Remarks on running runmlwin in batch mode}} below for more information.


{marker remarks}{...}
{title:Remarks}

{pstd}
Remarks are presented under the following headings:

{pstd}
{help runmlwin##alternative_commands:Remarks on alternative Stata commands for fitting multilevel models}{break}
{help runmlwin##downloading_runmlwin:Remarks on downloading runmlwin}{break}
{help runmlwin##downloading_runmlwin_manually:Remarks on downloading runmlwin_manually}{break}
{help runmlwin##updating_runmlwin:Remarks on keeping runmlwin up-to-date}{break}
{help runmlwin##remarks_first_time:Remarks on getting runmlwin working for the first time}{break}
{help runmlwin##remarks_batch_mode:Remarks on running runmlwin in batch mode}{break}
{help runmlwin##how_runmlwin_works:Remarks on how runmlwin works}{break}
{help runmlwin##estimation_procedures_in_MLwiN:Remarks on estimation procedures in MLwiN: (R)IGLS and MCMC}{break}
{help runmlwin##IGLS_vs_RIGLS:Remarks on IGLS vs. RIGLS}{break}
{help runmlwin##quasilikelihood_estimates:Remarks on quasilikelihood estimates: MQL1, MQL2, PQL1 and PQL2}{break}
{help runmlwin##MCMC:Remarks on MCMC}{break}
{help runmlwin##Bayesian_DIC:Remarks on Bayesian DIC}{break}
{help runmlwin##sampling_weights:Remarks on using sampling weights}{break}
{help runmlwin##mm_weights:Remarks on using multiple membership weights}{break}
{help runmlwin##MLwiN_estimation_problems_and_error_messages:Remarks on MLwiN estimation problems and error messages}{break}



{marker alternative_commands}{...}
{title:Remarks on alternative Stata commands for fitting multilevel models}

{pstd}
The multilevel models fitted by {cmd:runmlwin} are often considerably faster than those fitted by the Stata's
{manhelp xtmixed XT}, {manhelp xtmelogit XT} and {manhelp xtmepoisson XT} commands.
The range of models which can be fitted by {cmd:runmlwin} is also much wider than those available through those commands.
{cmd:runmlwin} also allows fast estimation on large data sets for many of the more complex multilevel models
available through the user written {bf:{help gllamm}} command.
Rabe-Hesketh and Skrondal (2012) is an outstanding resource for readers wanting to first familiarise themselves with each of these pre-existing Stata commands.
The Stata manual help pages for these commands also provide much useful information.


{marker downloading_runmlwin}{...}
{title:Remarks on downloading runmlwin}

{pstd}
The recommended way to install {cmd:runmlwin} is to type the following from a net-aware version of Stata

{p 8 12 2}
{cmd:. ssc install runmlwin}

{pstd}
and this will install {cmd:runmlwin} from its official location on the Statistical Software Components (SSC) archive.


{marker downloading_runmlwin_manually}{...}
{title:Remarks on downloading runmlwin manually}

{pstd}
Some users will not be allowed to download Stata ado packages to their computer, for example students in computer labs. 
For these users we recommend that IT support at their institutions install {cmd:runmlwin} centrally for them.
However, if this is not possible, then we recommend users manually change their default Stata ado package download location to one where they are allowed to save files.
Users then need to instruct Stata where on their computer this location is.
This process can be semi-automated by issuing the following five commands where users must change the directory path "C:\temp" to a path where they can save files.

{p 8 12 2}
(1) Store the original PLUS directory path in the {cmd:global} macro sysdir_plus{break}

{p 8 12 2}
{cmd:. global sysdir_plus = c(sysdir_plus)}

{p 8 12 2}
(2) Change the PLUS directory path to a directory where you can save files{break}

{p 8 12 2}
{cmd:. sysdir set PLUS "C:\temp"}

{p 8 12 2}
(3) Install {cmd:runmlwin} to this new directory{break}

{p 8 12 2}
{cmd:. ssc install runmlwin}

{p 8 12 2}
(4) Revert back to the original PLUS directory path{break}

{p 8 12 2}
{cmd:. sysdir set PLUS "$sysdir_plus"}

{p 8 12 2}
(5) Add the {cmd:runmlwin} directory to the ado-file directory path{break}

{p 8 12 2}
{cmd:. adopath + "C:\temp"}

{pstd}
Note, you will need to run the last command every time you open Stata.
Advanced users may wish do this by inserting the command into the profile do-file profile.do.
See {bf:{help profile}}.


{marker remarks_first_time}{...}
{title:Remarks on getting runmlwin working for the first time}

{pstd}
In order to get {cmd:runmlwin} working, you must: 

{p 8 12 2}
(1) install the latest version of MLwiN on your computer;

{p 8 12 2}
(2) set the full MLwiN path using {opt mlwinpath(string)} or a {cmd:global} macro called MLwiN_path.

{pstd}
If you don't have the latest version of MLwiN, visit:

{p 8 12 2}{browse "http://www.bristol.ac.uk/cmm/software/mlwin":http://www.bristol.ac.uk/cmm/software/mlwin}. 

{pstd}
MLwiN is free for UK academics (thanks to support from the UK Economic and Social Research Council).
A fully unrestricted 30-day trial version is available for non-UK academics.

{pstd}
Advanced users may wish to set the MLwiN path every time Stata is started by simply inserting the following line into the profile do-file profile.do.
See {bf:{help profile}}.

{p 8 12 2}
{cmd:. global MLwiN_path "C:\Program Files (x86)\MLwiN v2.31\i386\mlwin.exe"}

{pstd}
Where you must substitute the MLwiN path that is correct for your computer for the path given in quotes in the above example. 


{marker remarks_batch_mode}{...}
{title:Remarks on running runmlwin in batch mode}

Advanced users may wish to additionally specify the {opt mlwinscriptpath(string)} or a {cmd:global} macro called MLwiNScript_path in order to run {cmd:runmlwin} using {opt batch}.
The situations where this may be useful include:

{p 8 12 2}
(1) Faster loading times/execution;

{p 8 12 2}
(2) Fitting models to very large datasets (via the 64-bit version of mlnscript.exe);

{p 8 12 2}
(3) Running {cmd:runmlwin} in environments where no graphical user interface (GUI) is available, for example when run as a scheduled task or on Unix (Linux or Mac OSX) type systems.

{pstd}
Users may wish to set the MLwiN script path every time Stata is started by simply inserting the following line into the profile do-file profile.do.
See {bf:{help profile}}.

{pstd}
32-bit users should point to the 32-bit version of mlnscript.exe.

{p 8 12 2}
{cmd:. global MLwiNScript_path "C:\Program Files\MLwiN v2.26\i386\mlnscript.exe"}

{pstd}
64-bit users should point to the 64-bit version of mlnscript.exe.

{p 8 12 2}
{cmd:. global MLwiNScript_path "C:\Program Files (x86)\MLwiN v2.26\x64\mlnscript.exe"}

{pstd}
Where in both cases you must substitute the MLwiN script path that is correct for your computer for the path given in quotes in the above example. 


{marker updating_runmlwin}{...}
{title:Remarks on keeping runmlwin up-to-date}

{pstd}
We are constantly improving {cmd:runmlwin}. To check that you are using the latest version of {cmd:runmlwin}, type the following command:

{phang2}{stata "adoupdate runmlwin":. adoupdate runmlwin}{p_end}


{marker how_runmlwin_works}{...}
{title:Remarks on how runmlwin works}

{pstd}
{cmd:runmlwin} carries out the following steps:

{p 8 12 2}
(1) Writes an MLwiN macro for the specified multilevel model.

{p 8 12 2}
(2) Opens MLwiN and runs the MLwiN macro.

{p 8 12 2}
(3) Pauses MLwiN once the model is specified.
This allows the user to check that the model is specified as expected.
If the model is specified correctly, the user should click the "Resume macro" button (otherwise the user should click the "Abort macro" button to return 
control to Stata). 

{p 8 12 2}
(4) Fits the model in MLwiN.

{p 8 12 2}
(5) Pauses MLwiN once the model has been fitted (i.e. converged).
This allows the user to examine the model results. If the model has fitted correctly, the user should click
the "Resume macro" button (otherwise the user should click the "Abort macro" button to return control to Stata). 

{p 8 12 2}
(6) Stores and displays the model results in Stata

{pstd}
Note that advanced users can use the {opt nopause} option to suppress steps (3) and (5).
This is essential when running simulation studies.


{marker estimation_procedures_in_MLwiN}{...}
{title:Remarks on estimation procedures in MLwiN: (R)IGLS and MCMC}

{pstd}
MLwiN uses two principal estimation procedures: 

{p 8 12 2}
(1) Iterative Generalised Least Squares (IGLS) equivalent to maximum likelihood under normality and Restrictive Iterative Generalised Least Squares (RIGLS) which is formally equivalent to residual maximum likelihood (REML) under normality.
See {it:{help runmlwin##IGLS_vs_RIGLS:Remarks on IGLS vs. RIGLS}} below for more information.

{p 8 12 2}
(2) Markov Chain Monte Carlo (MCMC) estimation.
See {it:{help runmlwin##MCMC:Remarks on MCMC}} below for more information.

{pstd}
In addition, for discrete response models fitted by (R)IGLS, quasilikelihood estimates are calculated. 
See {it:{help runmlwin##quasilikelihood_estimates:Remarks on quasilikelihood estimates: MQL1, MQL2, PQL1 and PQL2}} below for more information.


{marker IGLS_vs_RIGLS}{...}
{title:Remarks on IGLS vs. RIGLS}

{pstd}
{opt igls} and {opt rigls} will give almost identical results in models where the number of units at each level is high.
The methods give different results, particularly for the random part parameters, when the number of units at a given level are few.
For example, the {opt rigls} estimate for the level 2 variance in a two-level normal response model will be larger than
the {opt igls} estimate when there are few level 2 units.


{marker quasilikelihood_estimates}{...}
{title:Remarks on quasilikelihood estimates: MQL1, MQL2, PQL1 and PQL2}

{pstd}
{opt mql1}, {opt mql2}, {opt pql1} and {opt pql2} specify the linearization technique for fitting discrete response models by (R)IGLS.
All four quasilikelihood methods are approximate: {opt pql2} is the most accurate but the least stable and the slowest to converge, 
{opt mql1} is the least accurate but the most stable and fastest to converge.
We recommend that model exploration is conducted using {opt mql1}. 
For any final model, we recommend fitting the model using {opt pql2} (or preferably MCMC) as a two stage process. 
First fit the model using {cmd:mql1}, then refit the model using {opt pql2} where the
{opt initsprevious} option (or {opt initsmodel(name)} or initsb(matrix)) is specified 
to use the {opt mql1} parameter estimates as the starting values for fitting the model using {opt pql2}. 


{marker MCMC}{...}
{title:Remarks on MCMC}

{pstd}
Markov Chain Monte Carlo (MCMC) methods are Bayesian estimation techniques which can be used to estimate multilevel models.

{pstd}
MCMC works by drawing a random sample of values for each parameter from its probability distribution.
The mean and standard deviation of each random sample gives the point estimate and standard error for that parameter.

{pstd}
We start by specifying the model and our prior knowledge for each parameter (we nearly always specify that we have no knowledge!).
Next we specify initial values for the model parameters (nearly always the IGLS estimates).
We then run the MCMC algorithm until each parameter distribution has settled down to its stationary distribution.
(i.e. the burnin period when the chains are converging to their posterior distribution).
We then run the MCMC algorithm for a further period (the monitoring period) in order to store a monitoring chain for each parameter.
Point estimates and standard errors are given by the means and standard deviations of these monitoring chains.

{pstd}
An important aspect of MCMC is specifying initial values.
Users can specify that the initial values are the parameter estimates from the previous model, {opt initsprevious}.
Alternatively, they can specify that the initial values are the parameter estimates from some other previously stored model, {opt initsmodel(name)}.
Or they can even manually specify any set of initial values they like, {opt initsb(matrix)}.

{pstd}
A second important aspect of MCMC is the prior knowledge (i.e. prior distribution) that we specify for each parameter.
By default MLwiN sets diffuse or uninformative priors, and these can be used to approximate maximum likelihood estimation.
Users can specify informative priors using the {opt priormatrix(matrix)} and {opt rppriors(rppriors_spec)} options.

{pstd}
We recommend users seeking further information, examples and references,
to consult the comprehensive MLwiN MCMC manual by Browne (2012) and additionally the help system within MLwiN.
The MLwiN MCMC manual also gives lengthier explanations for all MCMC options implemented in {cmd:runmlwin}.


{marker Bayesian_DIC}{...}
{title:Remarks on Bayesian DIC}

{pstd}
The Bayesian Deviance Information Criterion (DIC) is an MCMC penalised goodness of fit measure.
It is equivalent to the Akaike Information Criterion (AIC) used in maximum likelihood estimation.

{pstd}
The AIC is given by

{p 8 8 2}
AIC = -2*logL + 2k = Deviance + 2k

{pstd}
where

{p 8 8 2}
L is the maximized value of the likelihood function (i.e. the likelihood evaluated at the maximum likelihood point estimates of the model parameters)

{p 8 8 2}
k is the number of model parameters

{pstd}
In MCMC estimation, the DIC statistic has an analogous definition:

{p 8 8 2}
DIC = Deviance + 2*p_d

{pstd}
where:

{p 8 8 2}
The Deviance is evaluated at the posterior means of the model parameters

{p 8 8 2}
p_d is the effective number of model parameters

{pstd}
The four statistics reported in the standard {cmd:runmlwin} model output are:

{pstd}
Dbar:
The average goodness of fit of the model over the iterations.

{pstd}
D(thetabar): 
The goodness of fit of the model evaluated at the posterior means of the model parameters.

{pstd}
pD: 
The effective number of parameters summarises the complexity of the model: pD = Dbar - D(thetabar).

{pstd}
DIC: 
The statistic of interest: DIC = Dbar + pD = D(thetabar) + 2pD.


{marker sampling_weights}{...}
{title:Remarks on using sampling weights}

{pstd}
Sampling weights are only available for estimation using (R)IGLS.
Sampling weights should therefore only be used for continuous response variables as the quasilikelihood procedures available for (R)IGLS estimation of discrete response variables are only approximate.
See {it:{help runmlwin##quasilikelihood_estimates:Remarks on quasilikelihood estimates: MQL1, MQL2, PQL1 and PQL2}} above for more information.
We recommend that sampling weights should always be standardised and that sandwich estimates should always be used for the sampling estimates of both fixed part and random part parameter estimates.
These recommendations are implemented in the default settings for {cmd:runmlwin}, but can be changed using the {opt weights} option.
Note also that if level 2 weights are specified then MLwiN requires the level 1 weights to be conditional level 1 weights.


{marker mm_weights}{...}
{title:Remarks on using multiple membership weights}

{pstd}
Consider a two-level multiple membership model of students (level 1) who are multiple members of schools (level 2). 
In this example, the number of multiple membership unit identifier variables specified should
equal the maximum number of schools attended by any given student.
Suppose this maximum number of schools attended is three, then there should be three multiple membership unit identifier variables.
Intuitively, these can be thought of as corresponding to the first school attended,
the second school attended and the third school attended, respectively.
However, the order in which the (potentially) three school IDs appears is irrelevant
other than it must correspond to the ordering of the associated multiple membership weight variables.

{pstd}
For students who attend three schools, all {it:three} of the multiple membership unit identifier variables should take different
non-zero values and these values should give the school IDs of the {it:three} different schools attended.

{pstd}
For students who attend two schools, {it:two} of the three multiple membership unit identifier variables should take
non-zero values and these values should give the school IDs of the {it:two} different schools attended.
The third multiple membership unit identifier variable must take the value zero to indicate that no third school was attended.
No other value than zero (not even a missing value) is permitted to indicate that a third school was not attended.
A consequence of this is that zero is the only invalid school identifier value; no school in the data should have a zero value.

{pstd}
Finally, for students who attend a single school, one of the three multiple membership unit identifier variables should take a
non-zero value and this value should give the school ID of the {it:single} school attended.
The second and third multiple membership unit identifier variables should take zero values to indicate that no 
second or third schools were attended.


{marker MLwiN_estimation_problems_and_error_messages}{...}
{title:Remarks on MLwiN estimation problems and error messages}

{pstd}
Multilevel models are complex, often involving multiple sets of random effects at multiple levels.
Users may sometimes run into MLwiN error messages.
Help for a range of common MLwiN error messages are provided on the MLwiN website:

{p 8 12 2}{browse "http://www.bristol.ac.uk/cmm/software/support/support-faqs/errors.html#errormessage":http://www.bristol.ac.uk/cmm/software/support/support-faqs/errors.html#errormessage}
{p_end}


{marker examples}{...}	
{title:Examples}

{pstd}IMPORTANT.
The following examples will only work on your computer once you have installed MLwiN and once you have told {cmd:runmlwin} what the mlwin.exe file address is.
See {it:{help runmlwin##downloading_runmlwin:Remarks on installing runmlwin}} above for more information.

{pstd}{bf:(a) Continuous response models}{p_end}

{pstd}Two-level models{p_end}
    {hline}
{pstd}Setup{p_end}
{phang2}{bf:{stata "use http://www.bristol.ac.uk/cmm/media/runmlwin/tutorial, clear":. use http://www.bristol.ac.uk/cmm/media/runmlwin/tutorial, clear}}

{pstd}Two-level random-intercept model, analogous to xtreg (fitted using IGLS){break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/manual-web.pdf#section.2.5":2.5} of the MLwiN User Manual)}{p_end}
{phang2}{bf:{stata "runmlwin normexam cons standlrt, level2(school: cons) level1(student: cons) nopause":. runmlwin normexam cons standlrt, level2(school: cons) level1(student: cons) nopause}}

{pstd}Two-level random-intercept and random-slope (coefficient) model (fitted using IGLS){break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/manual-web.pdf#section.4.4":4.4} of the MLwiN User Manual)}{p_end}
{phang2}{bf:{stata "runmlwin normexam cons standlrt, level2 (school: cons standlrt) level1 (student: cons) nopause":. runmlwin normexam cons standlrt, level2 (school: cons standlrt) level1 (student: cons) nopause}}

{pstd}Refit the model, where this time we additionally calculate the level 2 residuals (fitted using IGLS){break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/manual-web.pdf#section.4.4":4.4} of the MLwiN User Manual)}{p_end}
{phang2}{bf:{stata "runmlwin normexam cons standlrt, level2 (school: cons standlrt, residuals(u)) level1 (student: cons) nopause":. runmlwin normexam cons standlrt, level2 (school: cons standlrt, residuals(u)) level1 (student: cons) nopause}}

{pstd}Two-level random-intercept and random-slope (coefficient) model with a complex level 1 variance function (fitted using IGLS){break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/manual-web.pdf#section.7.3":7.3} of the MLwiN User Manual)}{p_end}
{phang2}{bf:{stata "matrix A = (1,1,0,0,0,1)":. matrix A = (1,1,0,0,0,1)}}{p_end}
{phang2}{bf}{stata "runmlwin normexam cons standlrt girl, level2(school: cons standlrt) level1(student: cons standlrt girl, elements(A)) nopause":. runmlwin normexam cons standlrt girl,}
{stata "runmlwin normexam cons standlrt girl, level2(school: cons standlrt) level1(student: cons standlrt girl, elements(A)) nopause":level2(school: cons standlrt) level1(student: cons standlrt girl, elements(A)) nopause}{sf}

{pstd}Two-level random-intercept and random-slope (coefficient) model using MCMC
(where we first fit the model using IGLS to obtain initial values for the MCMC chains){break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/mcmc-web.pdf#chapter.6":6.0} of the MLwiN MCMC Manual)}{p_end}
{phang2}{bf:{stata "runmlwin normexam cons standlrt, level2 (school: cons standlrt) level1 (student: cons) nopause":. runmlwin normexam cons standlrt, level2 (school: cons standlrt) level1 (student: cons) nopause}}{p_end}
{phang2}{bf}{stata "runmlwin normexam cons standlrt, level2 (school: cons standlrt) level1 (student: cons) mcmc(on) initsprevious nopause":. runmlwin normexam cons standlrt,}
{stata "runmlwin normexam cons standlrt, level2 (school: cons standlrt) level1 (student: cons) mcmc(on) initsprevious nopause":level2 (school: cons standlrt) level1 (student: cons) mcmc(on) initsprevious nopause}{sf}

{pstd}Multivariate response models{p_end}
    {hline}
{pstd}Setup{p_end}
{phang2}{bf:{stata "use http://www.bristol.ac.uk/cmm/media/runmlwin/gcsemv1, clear":. use http://www.bristol.ac.uk/cmm/media/runmlwin/gcsemv1, clear}}

{pstd}Random-intercept bivariate response model (fitted using IGLS){break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/manual-web.pdf#section.14.3":14.3} of the MLwiN User Manual)}{p_end}
{phang2}{bf}{stata "runmlwin (written cons female, eq(1)) (csework cons female, eq(2)), level2(school: (cons, eq(1)) (cons, eq(2))) level1(student: (cons, eq(1)) (cons, eq(2))) nopause":. runmlwin (written cons female, eq(1))}
{stata "runmlwin (written cons female, eq(1)) (csework cons female, eq(2)), level2(school: (cons, eq(1)) (cons, eq(2))) level1(student: (cons, eq(1)) (cons, eq(2))) nopause":(csework cons female,}
{stata "runmlwin (written cons female, eq(1)) (csework cons female, eq(2)), level2(school: (cons, eq(1)) (cons, eq(2))) level1(student: (cons, eq(1)) (cons, eq(2))) nopause":eq(2)), level2(school: (cons, eq(1)) (cons, eq(2))) level1(student:}
{stata "runmlwin (written cons female, eq(1)) (csework cons female, eq(2)), level2(school: (cons, eq(1)) (cons, eq(2))) level1(student: (cons, eq(1)) (cons, eq(2))) nopause": (cons, eq(1)) (cons, eq(2))) nopause}{sf}

{pstd}Cross-classified models{p_end}
    {hline}
{pstd}Setup{p_end}
{phang2}{bf:{stata "use http://www.bristol.ac.uk/cmm/media/runmlwin/xc, clear":. use http://www.bristol.ac.uk/cmm/media/runmlwin/xc, clear}}

{pstd}Two-way cross-classified model (fitted using MCMC where starting values for the MCMC chains are manually specified by the user){break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/mcmc-web.pdf#section.15.4":15.4} of the MLwiN MCMC Manual)}{p_end}
{phang2}{bf:{stata "matrix b = (0,.33,.33,.33)":. matrix b = (0,.33,.33,.33)}}{p_end}
{phang2}{bf:{stata "runmlwin attain cons, level3(sid: cons) level2(pid: cons) level1(pupil: cons) mcmc(cc) initsb(b) nopause":. runmlwin attain cons, level3(sid: cons) level2(pid: cons) level1(pupil: cons) mcmc(cc) initsb(b) nopause}}


{pstd}{bf:(b) Discrete response models}{p_end}

{pstd}Binary response multilevel models{p_end}
    {hline}
{pstd}Setup{p_end}
{bf}{phang2}{stata "use http://www.bristol.ac.uk/cmm/media/runmlwin/bang, clear":. use http://www.bristol.ac.uk/cmm/media/runmlwin/bang, clear}{p_end}
{phang2}{stata "generate lc1 = (lc==1)":. generate lc1 = (lc==1)}{p_end}
{phang2}{stata "generate lc2 = (lc==2)":. generate lc2 = (lc==2)}{p_end}
{phang2}{stata "generate lc3plus = (lc>=3)":. generate lc3plus = (lc>=3)}{sf}

{pstd}Two-level random intercepts logit model (fitted using IGLS MQL1) {break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/manual-web.pdf#section.9.3":9.3} of the MLwiN User Manual)}{p_end}
{phang2}{bf}{stata "runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman) discrete(distribution(binomial) link(logit) denominator(cons)) nopause":. runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman)}
{stata "runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman) discrete(distribution(binomial) link(logit) denominator(cons)) nopause":discrete(distribution(binomial) link(logit) denominator(cons)) nopause}{sf}

{pstd}Two-level random intercepts logit model (fitted using IGLS PQl2 where IGLS MQL1 estimates from previous model are used as initial values){break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/manual-web.pdf#section.9.3":9.3} of the MLwiN User Manual)}{p_end}
{phang2}{bf}{stata "runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman) discrete(distribution(binomial) link(logit) denominator(cons) pql2) initsprevious nopause":. runmlwin use cons lc1 lc2 lc3plus age}
{stata "runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman) discrete(distribution(binomial) link(logit) denominator(cons) pql2) initsprevious nopause":, level2(district: cons)}
{stata "runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman) discrete(distribution(binomial) link(logit) denominator(cons) pql2) initsprevious nopause":level1(woman) discrete(distribution(binomial) link(logit)}
{stata "runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman) discrete(distribution(binomial) link(logit) denominator(cons) pql2) initsprevious nopause":denominator(cons) pql2) initsprevious nopause}{sf}

{pstd}Two-level random intercepts probit model (fitted using IGLS PQL2){p_end}
{phang2}{bf}{stata "runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman) discrete(distribution(binomial) link(probit) denominator(cons) pql2) nopause":. runmlwin use cons lc1 lc2 lc3plus age, }
{stata "runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman) discrete(distribution(binomial) link(probit) denominator(cons) pql2) nopause":level2(district: cons) level1(woman)}
{stata "runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman) discrete(distribution(binomial) link(probit) denominator(cons) pql2) nopause":discrete(distribution(binomial) link(probit) denominator(cons) pql2) nopause}{sf}

{pstd}Two-level random intercepts probit model (fitted using MCMC where IGLS PQL2 estimates from previous model are used as initial values){break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/mcmc-web.pdf#section.10.2":10.2} of the MLwiN MCMC Manual)}{p_end}
{phang2}{bf}{stata "runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman) discrete(distribution(binomial) link(probit) denominator(cons)) mcmc(on) initsprevious nopause":. runmlwin use cons lc1 lc2 lc3plus age,}
{stata "runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman) discrete(distribution(binomial) link(probit) denominator(cons)) mcmc(on) initsprevious nopause":level2(district: cons) level1(woman)}
{stata "runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman) discrete(distribution(binomial) link(probit) denominator(cons)) mcmc(on) initsprevious nopause":discrete(distribution(binomial) link(probit)}
{stata "runmlwin use cons lc1 lc2 lc3plus age, level2(district: cons) level1(woman) discrete(distribution(binomial) link(probit) denominator(cons)) mcmc(on) initsprevious nopause":denominator(cons)) mcmc(on) initsprevious nopause}{sf}


{pstd}Unordered multinomial response models{p_end}
    {hline}
{pstd}Setup{p_end}
{bf}{phang2}{stata "use http://www.bristol.ac.uk/cmm/media/runmlwin/bang, clear":. use http://www.bristol.ac.uk/cmm/media/runmlwin/bang, clear}{p_end}
{phang2}{stata "generate lc1 = (lc==1)":. generate lc1 = (lc==1)}{p_end}
{phang2}{stata "generate lc2 = (lc==2)":. generate lc2 = (lc==2)}{p_end}
{phang2}{stata "generate lc3plus = (lc>=3)":. generate lc3plus = (lc>=3)}{sf}

{pstd}Two-level random intercepts unordered multinomial model (fitted using IGLS MQL1) {break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/manual-web.pdf#section.10.5":10.5} of the MLwiN User Manual)}{p_end}
{phang2}{bf}{stata "runmlwin use4 cons lc1 lc2 lc3plus, level2(district: cons) level1(woman) discrete(distribution(multinomial) link(mlogit) denom(cons) basecategory(4)) nopause":. runmlwin use4 cons lc1 lc2 lc3plus, level2(district: cons)}
{stata "runmlwin use4 cons lc1 lc2 lc3plus, level2(district: cons) level1(woman) discrete(distribution(multinomial) link(mlogit) denom(cons) basecategory(4)) nopause":level1(woman) discrete(distribution(multinomial) link(mlogit) denom(cons)}
{stata "runmlwin use4 cons lc1 lc2 lc3plus, level2(district: cons) level1(woman) discrete(distribution(multinomial) link(mlogit) denom(cons) basecategory(4)) nopause":basecategory(4)) nopause}{sf}

{pstd}Ordered multinomial response models{p_end}
    {hline}
{pstd}Setup{p_end}
{bf}{phang2}{stata "use http://www.bristol.ac.uk/cmm/media/runmlwin/alevchem, clear":. use http://www.bristol.ac.uk/cmm/media/runmlwin/alevchem, clear}{p_end}
{phang2}{stata "egen school = group(lea estab)":. egen school = group(lea estab)}{p_end}
{phang2}{stata "generate gcseav =  gcse_tot/gcse_no":. generate gcseav =  gcse_tot/gcse_no}{p_end}
{phang2}{stata "egen gcseav_rank = rank(gcseav)":. egen gcseav_rank = rank(gcseav)}{p_end}
{phang2}{stata "generate gcseav_uniform = (gcseav_rank - 0.5)/_N":. generate gcseav_uniform = (gcseav_rank - 0.5)/_N}{p_end}
{phang2}{stata "generate gcseavnormal = invnorm(gcseav_uniform)":. generate gcseavnormal = invnorm(gcseav_uniform)}{sf}

{pstd}Two-level random intercepts ordered multinomial model with common coefficients for predictor variable gcseavnormal (fitted using IGLS PQL2){break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/manual-web.pdf#section.11.4":11.4} of the MLwiN User Manual)}{p_end}
{phang2}{bf:. runmlwin a_point cons (gcseavnormal, contrast(1/5)), level2(school: (cons, contrast(1/5))) level1(pupil) discrete(distribution(multinomial) link(ologit) denom(cons) base(6) pql2) nopause}{p_end}
{phang2}{it:({stata "runmlwin a_point cons (gcseavnormal, contrast(1/5)), level2(school: (cons, contrast(1/5))) level1(pupil) discrete(distribution(multinomial) link(ologit) denom(cons) base(6) pql2) nopause":Click to run})}
 
{pstd}Two-level random intercepts ordered multinomial model with separate coefficients for predictor variable gcseavnormal (fitted using IGLS PQL2){break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/manual-web.pdf#section.12.3":12.3} of the MLwiN User Manual)}{p_end}
{phang2}{bf}{stata "runmlwin a_point cons gcseavnormal, level2(school: (cons, contrast(1/5))) level1(pupil) discrete(distribution(multinomial) link(ologit) denom (cons) base(6) pql2) nopause":. runmlwin a_point cons gcseavnormal, }
{stata "runmlwin a_point cons gcseavnormal, level2(school: (cons, contrast(1/5))) level1(pupil) discrete(distribution(multinomial) link(ologit) denom (cons) base(6) pql2) nopause":level2(school: (cons,}
{stata "runmlwin a_point cons gcseavnormal, level2(school: (cons, contrast(1/5))) level1(pupil) discrete(distribution(multinomial) link(ologit) denom (cons) base(6) pql2) nopause":contrast(1/5))) level1(pupil) discrete(distribution(multinomial)}
{stata "runmlwin a_point cons gcseavnormal, level2(school: (cons, contrast(1/5))) level1(pupil) discrete(distribution(multinomial) link(ologit) denom (cons) base(6) pql2) nopause":link(ologit) denom (cons) base(6) pql2) nopause}{sf}

{pstd}Count data model{p_end}
    {hline}
{pstd}Setup{p_end}
{bf}{phang2}{stata "use http://www.bristol.ac.uk/cmm/media/runmlwin/mmmec, clear":. use http://www.bristol.ac.uk/cmm/media/runmlwin/mmmec, clear}{p_end}
{phang2}{stata "generate lnexpected = ln(exp)":. generate lnexpected = ln(exp)}{sf}

{pstd}Three-level random intercepts Poisson model (fitted using RIGLS MQL1) {break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/manual-web.pdf#section.12.3":12.3} of the MLwiN User Manual)}{p_end}
{phang2}{bf}{stata "runmlwin obs cons uvbi, level3(nation: cons) level2(region: cons) level1(county) discrete(distribution(poisson) offset(lnexpected)) rigls nopause":. runmlwin obs cons uvbi, level3(nation: cons) }
{stata "runmlwin obs cons uvbi, level3(nation: cons) level2(region: cons) level1(county) discrete(distribution(poisson) offset(lnexpected)) rigls nopause":level2(region: cons) level1(county)}
{stata "runmlwin obs cons uvbi, level3(nation: cons) level2(region: cons) level1(county) discrete(distribution(poisson) offset(lnexpected)) rigls nopause":discrete(distribution(poisson) offset(lnexpected)) rigls nopause}{sf}

{pstd}Three-level random intercepts Poisson model (fitted using MCMC where IGLS MQL1 estimates from previous model are used as initial values){break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/mcmc-web.pdf#section.11.3":11.3} of the MLwiN MCMC Manual)}{p_end}
{phang2}{bf:. runmlwin obs cons uvbi, level3(nation: cons) level2(region: cons) level1(county) discrete(distribution(poisson) offset(lnexpected)) mcmc(burnin(5000) chain(50000) refresh(500)) initsprevious nopause}{p_end}
{phang2}{it:({stata "runmlwin obs cons uvbi, level3(nation: cons) level2(region: cons) level1(county) discrete(distribution(poisson) offset(lnexpected)) mcmc(burnin(5000) chain(50000) refresh(500)) initsprevious nopause":Click to run})}


{pstd}{bf:(c) Multivariate response models}{p_end}

{pstd}Multivariate discrete and mixed response models{p_end}
    {hline}
{pstd}Setup{p_end}
{bf}{phang2}{stata "use http://www.bristol.ac.uk/cmm/media/runmlwin/tutorial, clear":. use http://www.bristol.ac.uk/cmm/media/runmlwin/tutorial, clear}{p_end}
{phang2}{stata "generate binexam = (normexam>0)":. generate binexam = (normexam>0)}{p_end}
{phang2}{stata "generate binlrt = (standlrt>0)":. generate binlrt = (standlrt>0)}{sf}

{pstd}Two-level bivariate binary response probit model (fitted using IGLS MQL1) {break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/manual-web.pdf#section.14.5":14.5} of the MLwiN User Manual)}{p_end}
{phang2}{bf}{stata "runmlwin (binexam cons, equation(1)) (binlrt cons, equation(2)), level1(student:) discrete(distribution(binomial binomial) link(probit) denominator(cons cons)) nosort nopause":. runmlwin (binexam cons, equation(1)) }
{stata "runmlwin (binexam cons, equation(1)) (binlrt cons, equation(2)), level1(student:) discrete(distribution(binomial binomial) link(probit) denominator(cons cons)) nosort nopause":(binlrt cons, equation(2)), level1(student:) }
{stata "runmlwin (binexam cons, equation(1)) (binlrt cons, equation(2)), level1(student:) discrete(distribution(binomial binomial) link(probit) denominator(cons cons)) nosort nopause":discrete(distribution(binomial binomial) }
{stata "runmlwin (binexam cons, equation(1)) (binlrt cons, equation(2)), level1(student:) discrete(distribution(binomial binomial) link(probit) denominator(cons cons)) nosort nopause":link(probit) denominator(cons cons)) nosort nopause}{sf}
 
{pstd}Two-level mixed bivariate continuous and binary response probit model (fitted using IGLS MQL1) {break}
{it:(See Section {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/2-26/manual-web.pdf#section.14.5":14.5} of the MLwiN User Manual)}{p_end}
{phang2}{bf:. runmlwin (normexam cons, equation(1)) (binlrt cons, equation(2)), level1(student:(cons, equation(1)) (cons, equation(2))) discrete(distribution(normal binomial) link(probit) denominator(cons cons)) nosort nopause}{p_end}
{phang2}
{it:({stata "runmlwin (normexam cons, equation(1)) (binlrt cons, equation(2)), level1(student:(cons, equation(1)) (cons, equation(2))) discrete(distribution(normal binomial) link(probit) denominator(cons cons)) nosort nopause":Click to run})}

    {hline}

{pstd}
A full range of {cmd:runmlwin} examples using both (R)IGLS and MCMC is available at:

{p 8 12 2}{browse "http://www.bristol.ac.uk/cmm/software/runmlwin/examples/":http://www.bristol.ac.uk/cmm/software/runmlwin/examples/}

{pstd}
These include do-files which allow you to replicate all the analyses reported in the MLwiN User Manual (Rasbash et al., 2012)
and the MCMC MLwiN Manual (Browne, 2012).

{pstd}
The log files for these two manuals are presented below.

{pstd}MLwiN User Manual{p_end}
{phang2}1 - Introducing Multilevel Models{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/2_Introduction_to_Multilevel_Modelling.do":2 - Introduction to Multilevel Modelling}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/3_Residuals.do":3 - Residuals}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/4_Random_Intercept_and_Random_Slope_Models.log":4 - Random Intercept and Random Slope Models}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/5_Graphical_Procedures_for_Exploring the Model.log":5 - Graphical Procedures for Exploring the Model}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/6_Contextual_Effects.log":6 - Contextual Effects}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/7_Modelling_the_Variance_as_a_Function_of_Explanatory_Variables.log":7 - Modelling the Variance as a Function of Explanatory Variables}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/8_Getting_Started_with_your_Data.log":8 - Getting Started with your Data}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/9_Logistic_Models_for_Binary_and_Binomial_Responses.log":9 - Logistic Models for Binary and Binomial Responses}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/10_Multinomial_Logistic_Models_for_Unordered_Categorical_Responses.log":10 - Multinomial Logistic Models for Unordered Categorical Responses}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/11_Fitting_an_Ordered_Category_Response_Model.log":11 - Fitting an Ordered Category Response Model}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/12_Modelling_Count_Data.log":12 - Modelling Count Data}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/13_Fitting_Models_to_Repeated_Measures_Data.log":13 - Fitting Models to Repeated Measures Data}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/14_Multivariate_Response_Models.log":14 - Multivariate Response Models}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/15_Diagnostics_for_Multilevel_Models.log":15 - Diagnostics for Multilevel Models}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/16_An_Introduction_to_Simulation_Methods_of_Estimation.log":16 - An Introduction to Simulation Methods of Estimation}{p_end}
{phang2}17 - Bootstrap Estimation{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/18_Modelling_Cross-classified_Data.log":18 - Modelling Cross-classified Data}{p_end}
{phang2}19 - Multiple Membership Models{p_end}

{pstd}MLwiN MCMC Manual{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/1_Introduction_to_MCMC_Estimation_and_Bayesian_Modelling.log":1 - Introduction to MCMC Estimation and Bayesian Modelling}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/2_Single_Level_Normal_Response_Modelling.log":2 - Single Level Normal Response Modelling}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/3_Variance_Components_Models.log":3 - Variance Components Models}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/4_Other_Features_of_Variance_Components_Models.log":4 - Other Features of Variance Components Models}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/5_Prior_Distributions,_Starting_Values_and_Random_Number_Seeds.log":5 - Prior Distributions, Starting Values and Random Number Seeds}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/6_Random_Slopes_Regression_Models.log":6 - Random Slopes Regression Models}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/7_Using_the_WinBUGS_Interface_in_MLwiN.log":7 - Using the WinBUGS Interface in MLwiN}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/8_Running_a_Simulation_Study_in_MLwiN.log":8 - Running a Simulation Study in MLwiN}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/9_Modelling_Complex_Variance_at_Level_1_Heteroscedasticity.log":9 - Modelling Complex Variance at Level 1 - Heteroscedasticity}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/10_Modelling_Binary_Responses.log":10 - Modelling Binary Responses}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/11_Poisson_Response_Modelling.log":11 - Poisson Response Modelling}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/12_Unordered_Categorical_Responses.log":12 - Unordered Categorical Responses}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/13_Ordered_Categorical_Responses.log":13 - Ordered Categorical Responses}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/14_Adjusting_for_Measurement_Errors_in_Predictor_Variables.log":14 - Adjusting for Measurement Errors in Predictor Variables}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/15_Cross_Classified_Models.log":15 - Cross Classified Models}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/16_Multiple_Membership_Models.log":16 - Multiple Membership Models}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/17_Modelling_Spatial_Data.log":17 - Modelling Spatial Data}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/18_Multivariate_Normal_Response_Models_and_Missing_Data.log":18 - Multivariate Normal Response Models and Missing Data}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/19_Mixed_Response_Models_and_Correlated_Residuals.log":19 - Mixed Response Models and Correlated Residuals}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/20_Multilevel_Factor_Analysis_Modelling.log":20 - Multilevel Factor Analysis Modelling}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/21_Using_Structured_MCMC.log":21 - Using Structured MCMC}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/22_Using_the_Structured_MVN_framework_for_models.log":22 - Using the Structured MVN framework for models}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/23_Using_Orthogonal_fixed_effect_vectors.log":23 - Using Orthogonal fixed effect vectors}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/24_Parameter_expansion.log":24 - Parameter expansion}{p_end}
{phang2}{stata "view http://www.bristol.ac.uk/cmm/media/runmlwin/25_Hierarchical_Centring.log":25 - Hierarchical Centring}{p_end}
 
 
{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:runmlwin} saves the following in e():

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Scalars}{p_end}
{synopt:{cmd:e(numlevels)}}number of levels{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_f)}}number of FE parameters{p_end}
{synopt:{cmd:e(k_r)}}number of RE parameters{p_end}
{synopt:{cmd:e(extrabinomial)}}1 if extra binomial variation is used, 0 otherwise{p_end}
{synopt:{cmd:e(ll)}}log (restricted) likelihood{p_end}
{synopt:{cmd:e(deviance)}}deviance (= -2*e(ll)){p_end}
{synopt:{cmd:e(iterations)}}number of iterations{p_end}
{synopt:{cmd:e(converged)}}1 if converged, 0 otherwise{p_end}
{synopt:{cmd:e(time)}}estimation time (seconds){p_end}
{synopt:{cmd:e(burnin)}}number of burn-in iterations{p_end}
{synopt:{cmd:e(chain)}}number of chain iterations{p_end}
{synopt:{cmd:e(thinning)}}frequency with which successive values in the chain are stored{p_end}
{synopt:{cmd:e(mcmcnofit)}}1 if MCMC model is not fitted, 0 otherwise{p_end}
{synopt:{cmd:e(mcmcdiagnostics)}}1 if MCMC diagnostics have been calculated, 0 otherwise{p_end}
{synopt:{cmd:e(dbar)}}average deviance across the chain iterations{p_end}
{synopt:{cmd:e(dthetabar)}}deviance at the mean values of the model parameters{p_end}
{synopt:{cmd:e(pd)}}effective number of parameters{p_end}
{synopt:{cmd:e(dic)}}Bayesian deviance information criterion{p_end}
{synopt:{cmd:e(size)}}maximum worksheet size allowed in MLwiN{p_end}
{synopt:{cmd:e(maxlevels)}}maximum number of levels allowed in MLwiN{p_end}
{synopt:{cmd:e(columns)}}maximum number of data columns allowed in MLwiN{p_end}
{synopt:{cmd:e(variables)}}maximum number of modelled variables allowed in MLwiN{p_end}
{synopt:{cmd:e(tempmat)}}1 if use memory allocated to the worksheet to store temporary matrices in MLwiN, 0 otherwise{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}runmlwin{p_end}
{synopt:{cmd:e(version)}}runmlwin version{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(depvars)}}name(s) of dependent variable(s){p_end}
{synopt:{cmd:e(distribution)}}distribution(s){p_end}
{synopt:{cmd:e(link)}}link function{p_end}
{synopt:{cmd:e(denominators)}}denominator(s){p_end}
{synopt:{cmd:e(basecategory)}}the value of {it:depvar} to be treated as the base category{p_end}
{synopt:{cmd:e(respcategories)}}the values of {it:depvar}{p_end}
{synopt:{cmd:e(offsets)}}offset(s){p_end}
{synopt:{cmd:e(ivars)}}grouping variables{p_end}
{synopt:{cmd:e(level1id)}}level 1 identifier variable{p_end}
{synopt:{cmd:e(weightvar)}}sampling weights variables{p_end}
{synopt:{cmd:e(weighttype)}}sampling weights types{p_end}
{synopt:{cmd:e(method)}}estimation method: IGLS, RIGLS or MCMC{p_end}
{synopt:{cmd:e(linearization)}}linearization technique: MQL1, MQL2, PQL1 or PQL2{p_end}
{synopt:{cmd:e(properties)}}b V{p_end}
{synopt:{cmd:e(chains)}}MCMC chains for all parameters{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(N_g)}}group counts{p_end}
{synopt:{cmd:e(g_min)}}group size minimum{p_end}
{synopt:{cmd:e(g_avg)}}group size averages{p_end}
{synopt:{cmd:e(g_max)}}group size maximums{p_end}
{synopt:{cmd:e(RP2)}}level 2 matrix of random part parameters{p_end}
{synopt:{cmd:e(RP1)}}level 1 matrix of random part parameters{p_end}
{synopt:{cmd:e(P)}}priors{p_end}
{synopt:{cmd:e(sd)}}standard deviation for each chain{p_end}
{synopt:{cmd:e(mode)}}mode for each chain{p_end}
{synopt:{cmd:e(meanmcse)}}Monte Carlo standard error (MCSE) evaluated at the mean of each chain{p_end}
{synopt:{cmd:e(ess)}}effective sample size (ESS) for each chain{p_end}
{synopt:{cmd:e(quantiles)}}quantiles for each chain{p_end}
{synopt:{cmd:e(lb)}}lower credible interval bound for each chain{p_end}
{synopt:{cmd:e(ub)}}upper credible interval bound for each chain{p_end}
{synopt:{cmd:e(KD1)}}kernel density for each chain{p_end}
{synopt:{cmd:e(KD2)}}kernel density for each chain{p_end}
{synopt:{cmd:e(ACF)}}autocorrelation function (ACF) for each chain{p_end}
{synopt:{cmd:e(PACF)}}partial autocorrelation function (PACF) for each chain{p_end}
{synopt:{cmd:e(MCSE)}}Monte Carlo standard error (MCSE) for each chain{p_end}
{synopt:{cmd:e(bd)}}Brooks-Draper diagnostic for mean of each chain{p_end}
{synopt:{cmd:e(rl1)}}Raftery-Lewis diagnostic for each 2.5th quantile of each chain{p_end}
{synopt:{cmd:e(rl2)}}Raftery-Lewis diagnostic for each 97.5th quantile of each chain{p_end}
{synopt:{cmd:e(pvalmean)}}one-sided Bayesian p-value for each chain where chain mean is treated as parameter estimate{p_end}
{synopt:{cmd:e(pvalmode)}}one-sided Bayesian p-value for each chain where chain mode is treated as parameter estimate{p_end}
{synopt:{cmd:e(pvalmedian)}}one-sided Bayesian p-value for each chain where chain median is treated as parameter estimate{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{marker about_cmm}{...}
{title:About the Centre for Multilevel Modelling}

{pstd}
The MLwiN software is developed at the Centre for Multilevel Modelling.
The Centre was established in 1986, and has been supported largely by project grants from the UK Economic and Social Research Council.
The Centre has been based at the University of Bristol since 2005.

{pstd}
The Centre’s website:

{p 8 12 2}{browse "http://www.bristol.ac.uk/cmm":http://www.bristol.ac.uk/cmm}

{pstd}
contains much of interest, including new developments, and details of courses and workshops.
This website also contains the latest information about the MLwiN software, including upgrade information,
maintenance downloads, and documentation.

{pstd}
The Centre also runs a free online multilevel modelling course:

{p 8 12 2}{browse "http://www.bristol.ac.uk/cmm/learning/course.html":http://www.bristol.ac.uk/cmm/learning/course.html}

{pstd}
which contains modules starting from an introduction to quantitative research progressing to multilevel modelling of 
continuous and categorical data.
Modules include a description of concepts and models and instructions of how to carry out analyses in MLwiN, Stata and R.
There is a also a user forum, videos and interactive quiz questions for learners’ self-assessment.


{marker citation}{...}
{title:How to cite {cmd:runmlwin} and MLwiN}

{pstd}{cmd:runmlwin} is not an official Stata command.
It is a free contribution to the research community, like a paper.
Please cite it as such:

{p 8 12 2}
Leckie, G. and Charlton, C. 2013. {cmd:runmlwin} - A Program to Run the MLwiN Multilevel Modelling Software from within Stata. Journal of Statistical Software, 52 (11),1-40.{break}
{browse "http://www.jstatsoft.org/v52/i11":http://www.jstatsoft.org/v52/i11}

{pstd}Similarly, please also cite the MLwiN software:

{p 8 12 2}
Rasbash, J., Charlton, C., Browne, W.J., Healy, M. and Cameron, B. 2009. MLwiN Version 2.1. Centre for Multilevel Modelling, 
University of Bristol.

{pstd}For models fitted using MCMC estimation, we ask that you additionally cite:

{p 8 12 2}
Browne, W.J. 2012. MCMC Estimation in MLwiN, v2.26. Centre for Multilevel Modelling, University of Bristol.


{marker user_forum}{...}
{title:The {cmd:runmlwin} user forum}

{pstd}Please use the {cmd:runmlwin} user forum to post any questions you have about {cmd:runmlwin}.
We will try to answer your questions as quickly as possible, but where you know the answer to another user's question please also reply to them!

{p 8 12 2}{browse "http://www.cmm.bristol.ac.uk/forum/viewforum.php?f=3":http://www.cmm.bristol.ac.uk/forum/}


{marker authors}{...}
{title:Authors}

{p 4}George Leckie{p_end}
{p 4}Centre for Multilevel Modelling{p_end}
{p 4}University of Bristol{p_end}
{p 4}{browse "mailto:g.leckie@bristol.ac.uk":g.leckie@bristol.ac.uk}{p_end}


{p 4}Chris Charlton{p_end}
{p 4}Centre for Multilevel Modelling{p_end}
{p 4}University of Bristol{p_end}


{marker acknowledgments}{...}
{title:Acknowledgments}

{pstd}We are very grateful to colleagues at the Centre for Multilevel Modelling and the University of Bristol for their useful comments.

{pstd}The development of this command was funded under the LEMMA project, a node of the
UK Economic and Social Research Council's National Centre for Research Methods (grant number RES-576-25-0003).


{marker disclaimer}{...}
{title:Disclaimer}

{pstd}{cmd:runmlwin} comes with no warranty.
We recommend that users check their results with those obtained through operating MLwiN by its graphical user interface.
Users are also encouraged to check their results with those produced by other statistical software packages.


{marker references}{...}
{title:References}

{p 4 8 2}
Browne, W.J. 2012. MCMC Estimation in MLwiN, v2.26.  Centre for Multilevel Modelling, University of Bristol.{break}
{browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/manuals.html":http://www.bristol.ac.uk/cmm/software/mlwin/download/manuals.html}

{p 4 8 2}
Leckie, G. and Charlton, C. 2013. {cmd:runmlwin} - A Program to Run the MLwiN Multilevel Modelling Software from within Stata. Journal of Statistical Software, 52 (11),1-40.{break}
{browse "http://www.jstatsoft.org/v52/i11":http://www.jstatsoft.org/v52/i11}

{p 4 8 2}
Rabe-Hesketh, S. and Skrondal, A. 2012. Multilevel and Longitudinal Modeling using Stata (Third Edition). College Station, TX: Stata Press.

{p 4 8 2}
Rasbash, J., Steele, F., Browne, W.J. and Goldstein, H. 2012. A User’s Guide to MLwiN, v2.26. Centre for Multilevel Modelling, University of Bristol.{break}
{browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/manuals.html":http://www.bristol.ac.uk/cmm/software/mlwin/download/manuals.html}


{title:Also see}

{psee}
Manual:  {bf:[XT] xtmixed} {bf:[XT] xtmelogit} {bf:[XT] xtmepoisson} {bf:[XT] xtreg}

{psee}
Online:  {manhelp xtmixed XT}, {manhelp xtmelogit XT}, {manhelp xtmepoisson XT}, {manhelp xtreg XT}, {bf:{help mcmcsum}}, {bf:{help usewsz}}, {bf:{help savewsz}}, {bf:{help reffadjust}}, {bf:{help gllamm}}
{p_end}

