{smcl}
{* December 2008}{...}
{* Version 1.2 Updated: November 2012}
{hline}
{cmd: Help for spmlreg}
{vieweralsosee "anketest" "help anketest"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "spmlreg postestimation" "help spmlreg postestimation"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "spwmatrix" "help spwmatrix"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "splagvar" "help splagvar"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "spseudor2" "help spseudor2"}{...}
{viewerjumpto "Syntax" "spmlreg##syntax"}{...}
{viewerjumpto "Description" "spmlreg##description"}{...}
{viewerjumpto "Options" "spmlreg##options"}{...}
{viewerjumpto "Saved results" "spmlreg##results"}{...}
{viewerjumpto "Examples" "spmlreg##examples"}{...}
{viewerjumpto "Author information" "spmlreg##author"}{...}
{viewerjumpto "Citation" "spmlreg##cit"}{...}
{viewerjumpto "References" "spmlreg##references"}{...}
{hline}

{title:Title}

{p 2 8 2}
{bf:spmlreg --- Estimates the spatial lag, the spatial error, the spatial durbin, and the general spatial models by maximum likelihood}

{marker contents}{dlgtab: Table of Contents}
{p 2 16 2}

{p 2}{bf:Click on the "Jump To" link at the top right corner.}

{hline}

{marker syntax}{title:Syntax}

{phang}
{cmd: spmlreg} {help varlist} {cmd:[if]} {cmd:[in]}{cmd:,} {opt w:eights(weights_name)} {opt wf:rom(Stata|Mata)} {opt e:ignvar(varname)} {opt m:odel(lag|error|durbin|sac)} 
[{help spmlreg##other_options:Other_options}]


{synoptset 28 tabbed}
{synopthdr}
{synoptline}
{syntab:{bf:Main}} 

{synopt :{opt w:eights(weights_name)}}indicate the name of the spatial weights matrix to be used{p_end}

{synopt :{opt wf:rom(Stata|Mata)}}indicate the source of the spatial weights matrix{p_end}
  
{synopt :{opth e:ignvar(varname)}}indicate the name of the variable holding the eigenvalues of the weights matrix supplied with {opt weigths()}{p_end}

{synopt :{opt m:odel(lag|error|durbin|sac)}}indicate the model to be estimated{p_end}

{synoptline}
{syntab:{bf:Other}} 

{synopt :{opt no:log}}suppress the iteration log{p_end}

{synopt :{opt r:obust}}request Huber-White standard errors for the spatial lag or the spatial durbin model{p_end}

{synopt :{opt l:evel(#)}}set the confidence level{p_end}

{synopt :{opt favor(speed|space)}}favor speed or space{p_end}

{synopt :{opt wrho(name)}}indicate the name of the weights matrix to be used to generate the spatially lagged dependent variable in the {bf:sac} model{p_end}

{synopt :{opth eigw:rho(varname)}}specify the variable holding the eigenvalues of the weights matrix supplied with {opt wrho(name)}{p_end}

{synopt :{opt initr:ho(#)}}provide initial value for rho{p_end}

{synopt :{opt initl:ambda(#)}}provide initial value for lambda{p_end}

{synopt :{opt sr2}}obtain goodness of fit measures for the spatial lag, the spatial durbin, and the general spatial models{p_end}

{synopt :{help maximize:Other maximization_options}}specify other maximization options{p_end}


{synoptline}
{p2colreset}{...}

{marker description}{dlgtab:Description}

{pstd}{cmd:spmlreg} estimates by maximimum likelihood the spatial lag, the spatial error, the spatial durbin, and the general spatial 
(or spatial mixed) models. Optionally, at the end of the estimation process, goodness of fit is calculated based on the expression for the conditional expectation of the reduced form since 
the spatially lagged dependent variable is endogenous.

{pstd}{bf:Limitations:} While the sample size that can be used is not subject to the {help matsize} limit of your Stata flavor, unless you 
are running {bf:Small Stata}, model estimation using huge datasets may be hampered by memory limitation since sparse matrix operations are 
not yet allowed in Mata. However, as long as you can generate a spatial weights matrix and a variable holding the eigenvalues using 
{help spwmatrix}, {cmd:spmlreg} will dutifully estimate a model for you.

{pstd}{bf:Dependency:} {cmd:spmlreg} relies heavily on {help splagvar} which must be installed.

{pstd}{bf:Stata 12.0 or higher is required.}


{marker options}{dlgtab:Required options}

{phang}
{opt weights(weights_name)} specifies the name of the spatial weights matrix to be used in the estimation.

{phang}{opt wfrom}{cmd:(}{help matrix:Stata} | {help mf_fopen##remarks5:Mata}{cmd:)} indicates whether the spatial 
weights matrix is from Stata or Mata. If the spatial weights matrix is from Mata, the file should be located in the working directory. 
A spatial weights matrix created using {help spwmatrix} should exist as a Stata matrix loaded in memory or as a Mata file.{p_end}

{phang}
{opt eignvar(varname)} indicates the name of the variable holding the eigenvalues of the weights matrix supplied with {opt weigths()}. 
This variable must have been generated using the {help spwmatrix##eigv:eignvar()} option of the {cmd:spwmatrix} command. Make sure the spatial weights 
matrix is {help spwmatrix##rowst:row-standardized}.

{phang}
{opt model(lag|error|durbin|sac)} indicates the type of spatial model to be estimated. {opt model(lag)} estimates the spatial lag model, 
{opt model(error)} estimates the spatial error model, {opt model(durbin)} estimates the spatial durbin model, and {opt model(sac)} 
estimates the general spatial (or spatial mixed) model allowing for both lag and error autocorrelation.


{marker other_options}{dlgtab:Optional options}

{phang}{opt log} and {opt nolog} specify whether an iteration log showing the progress of the log likelihood is to be displayed.  
The log is displayed by default, and nolog suppresses it. 

{phang}
{opt robust} requests Huber-White standard errors for the spatial lag and the spatial durbin models. 

{phang}
{opt level(#)} specifies the confidence level, in percent, for confidence intervals. The default is level(95) or as set by set {opt level()}.

{phang}
{opt favor(speed|space)} instructs {cmd:spmlreg} to favor speed or space when calculating several underlying spatially lagged variables.
{opt favor(speed)} is the default. This option provides a tradeoff between speed and memory use. See {help mata_set:[M-3] mata set}.

{phang}
{opt wrho(name)} indicates the name of the spatial weights matrix to be used when generating the spatially lagged dependent variable in the {bf:sac} model.
By default, the spatial weights matrix supplied with {opt wname()} is used for both the spatially lagged dependent variable and the spatially lagged 
disturbances, although there may be identification problems. The two spatial weights must be of the same source, as indicated with {opt wfrom()}.

{phang}
{opt eigwrho(varname)} specifies the variable holding the eigenvalues of the weights matrix supplies with {opt wrho()}.

{pmore}{bf:Note 1:} Options {opt wrho()} and {opt eigwrho()} are necessary when you want to estimate the general spatial model with different spatial 
weights for the autoregressive lag and the autoregressive error terms. When these two options are not specified, {cmd:spmlreg} uses the same spatial weights 
matrix for both the autoregressive lag and the autoregressive error terms (see {help spmlreg##examples:examples below}). 

{phang}
{opt initrho(#)} provides initial value for rho. The default is {opt initrho(0)}.

{phang}
{opt initlambda(#)} provides initial value for lambda. The default is {opt initlambda(0)}.

{pmore}{bf:Note 2:} You should rarely have to specify {opt initrho(#)} and {opt initlambda(#)} 

{phang}
{opt sr2} requests that goodness of fit measures for the spatial lag, the spatial durbin, and the general spatial models be displayed. 
When this option is specified, two goodness of fit measures are reported. The first one is computed as the squared correlation between 
the predicted and observed values of the dependent variable. The other one is calculated as the ratio of the variance of the predicted 
values to the variance of the observed values of the dependent variable. As stressed above, for the spatial lag, the spatial durbin, and the general spatial 
models, {cmd:spmlreg} generates the predicted values from the expression for the conditional expectation of the reduced form: 

{pmore2}{bf:y_hat = E(y|x) = (I-rho_hat*W)^-1 * X*beta_hat}


{pmore}By default, goodness of fit measures are calculated when you specify {opt model(error)}. 

{phang}
{help maximize:Other maximization_options} allows the user to specify other maximization options (e.g., difficult, trace, iterate(#), constraint(#), etc.).  
However, you should rarely have to specify them, though they may be helpful if parameters approach boundary values.

{marker results}{dlgtab:Saved Results}

{p}Depending on the model estimated, {cmd:spmlreg} saves the following results in {cmd:e()}:

Scalars        
{col 4}{cmd:e(N)}{col 22}number of observations
{col 4}{cmd:e(k)}{col 22}number of parameters
{col 4}{cmd:e(k_eq)}{col 22}number of equations 
{col 4}{cmd:e(k_eq_model)}{col 22}number of equations to include in a model Wald test 
{col 4}{cmd:e(k_dv)}{col 22}number of dependent variables 
{col 4}{cmd:e(df_m)}{col 22}model degrees of freedom
{col 4}{cmd:e(ll)}{col 22}log likelihood for the current model
{col 4}{cmd:e(ll_0)}{col 22}log likelihood for OLS
{col 4}{cmd:e(chi2)}{col 22}chi-squared 
{col 4}{cmd:e(p)}{col 22}significance of model of test 
{col 4}{cmd:e(ic)}{col 22}number of iterations 
{col 4}{cmd:e(rank)}{col 22}rank of e(V)
{col 4}{cmd:e(rank0)}{col 22}rank of e(V) for OLS
{col 4}{cmd:e(rc)}{col 22}return code 
{col 4}{cmd:e(converged)}{col 22}1 if converged, 0 otherwise 
{col 4}{cmd:e(varRatio)}{col 22}variance ratio of predicted to observed values of the dependent variable
{col 4}{cmd:e(sqCorr)}{col 22}squared correlation between predicted and observed values of the dependent variable
{col 4}{cmd:e(wald_durbin)}{col 22}Wald test for the coefficients on the lags of X's
{col 4}{cmd:e(p_durbin)}{col 22}p-value for the Wald test on the coefficients on lags of X's
{col 4}{cmd:e(Wald)}{col 22}Wald test for rho or lambda equal to zero
{col 4}{cmd:e(maxEigen)}{col 22}Maximum eigenvalue
{col 4}{cmd:e(minEigen)}{col 22}minimum eigenvalue

Macros         
{col 4}{cmd:e(cmd)}{col 22}name of the command
{col 4}{cmd:e(cmdline)}{col 22}command as typed
{col 4}{cmd:e(depvar)}{col 22}name of the dependent variable
{col 4}{cmd:e(indvar)}{col 22}list of the independent variables
{col 4}{cmd:e(title)}{col 22}title in estimation output
{col 4}{cmd:e(chi2type)}{col 22}Wald 
{col 4}{cmd:e(vce)}{col 22}vcetype specified in vce()
{col 4}{cmd:e(vcetype)}{col 22}title used to label Std. Err.
{col 4}{cmd:e(opt)}{col 22}type of optimization
{col 4}{cmd:e(ml_method)}{col 22}type of ml method by commands using ml
{col 4}{cmd:e(user)}{col 22}name of likelihood-evaluator program
{col 4}{cmd:e(technique)}{col 22}from technique() option
{col 4}{cmd:e(crittype)}{col 22}optimization criterion
{col 4}{cmd:e(properties)}{col 22}estimator properties
{col 4}{cmd:e(wname)}{col 22}name of the spatial weights matrix
{col 4}{cmd:e(wfrom)}{col 22}source of the main spatial weights matrix: Mata or Stata
{col 4}{cmd:e(model)}{col 22}name of the estimation model

Matrices       
{col 4}{cmd:e(b)}{col 22}coefficient vector
{col 4}{cmd:e(V)}{col 22}variance-covariance matrix of the estimators
{col 4}{cmd:e(gradient)}{col 22}gradient vector 
{col 4}{cmd:e(ilog)}{col 22}iteration log (up to 20 iterations); 

Functions      
{col 4}{cmd:e(sample)}{col 22}marks estimation sample


{marker examples}{dlgtab:Examples}
{phang} 

{title:For Windows users}

{pmore}{stata "mkdir \data\spmlreg":. mkdir \data\spmlreg}

{pmore}{stata "cd \data\spmlreg":. cd \data\spmlreg}


{title:For Mac and Unix users}

{pmore}{stata "mkdir ~/data/spmlreg":. mkdir ~/data/spmlreg}

{pmore}{stata "cd ~/data/spmlreg":. cd ~/data/spmlreg}

{synoptline}

{phang}
Load the Columbus crime dataset

{pmore}{stata "use http://fmwww.bc.edu/repec/bocode/c/columbus_dataset, clear" :. use http://fmwww.bc.edu/repec/bocode/c/columbus_dataset, clear} 

{phang}
Import the first order contiguity spatial weights matrix, columbus.gal, created in GeoDa

{pmore}{stata "spwmatrix import using http://fmwww.bc.edu/repec/bocode/c/columbus.gal, wn(W) eignvar(eigvarW) rowstand mataf" :. spwmatrix import using http://fmwww.bc.edu/repec/bocode/c/columbus.gal, wn(W) eignvar(eigvarW) row mataf}{p_end}

{synoptline}


{phang} 
1) Estimate the spatial lag model 

{pmore}{stata "spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eigvarW) model(lag) sr2" :. spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eigvarW) model(lag) sr2}{p_end}

{synoptline}


{phang}
2) Estimate the spatial error model 

{pmore}{stata "spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eigvarW) model(error)" :. spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eigvarW) model(error)}{p_end}

{synoptline}


{phang}
3) Estimate the spatial durbin model 

{pmore}{stata "spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eigvarW) model(durbin) sr2" :. spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eigvarW) model(durbin) sr2}{p_end}

{synoptline}

{phang} 
4) Estimate the general spatial model: {bf:y = rho*W*y + X*b + u, where u = lambda*W*u + e} 

{pmore}{stata "spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eigvarW) model(sac) sr2" :. spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eigvarW) model(sac) sr2}{p_end}

{synoptline}


{phang}
Create an inverse distance squared spatial weights matrix with a cutoff distance of 5 to be used for the lag autocorrelation

{pmore}{stata "spwmatrix gecon y x, wn(W1) cart rowstand wtype(inv) alpha(2) dband(0 5) eignvar(eigvarW1) mataf" :. spwmatrix gecon y x, wn(W1) cart rowstand wtype(inv) alpha(2) dband(0 5) eignvar(eigvarW1) mataf}{p_end}


{phang}
5) Estimate the general spatial model: {bf:y = rho*W1*y + X*b + u, where u = lambda*W*u + e} 

{pmore}{stata "spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eigvarW) model(sac) wrho(W1) eigwrho(eigvarW1) sr2" :. spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eignvarW) model(sac) wrho(W1) eigwrho(eigvarW1) sr2}{p_end}

{synoptline}


{marker acknow}{title:Acknowledgments}

Thanks to Maurizio Pisati for writing {cmd:spatreg}. Thanks to Mark E. Schaffer for suggesting that I write {cmd:spmlreg} and for commenting on the first version.


{marker author}{title:Author}

{p 4 4 2}{hi: P. Wilner Jeanty}, Dept. of Agricultural, Environmental, and Development Economics, 
    	   The Ohio State University{break}
	   
{p 4 4 2}Email to {browse "mailto:jeanty.1@osu.edu":jeanty.1@osu.edu} for any comments or suggestions.


{marker cit}{title:Citation}

Users should please cite {cmd:spmlreg} as follows:

Jeanty, P.W., 2010. {cmd:spmlreg}: Stata module to estimate the spatial lag, the spatial error, the spatial durbin, and the general spatial models.


