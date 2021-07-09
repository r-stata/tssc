{smcl}
{* 6 May 2014}{...}
{cmd:help npseries}{right: ({browse "http://staff.vwi.unibe.ch/kaiser/research.html"})}
{hline}

{title:Title}

{p2colset 5 25 22 2}{...}
{p2col :{hi: npseries} {hline 2}}Nonparametric Power Series Estimation{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab:npseries} {depvar} {indepvars} {weight} {ifin} {cmd:,} [{it:options}]


{synoptset 25}{...}
{synopthdr}
{synoptline}
{syntab :series estimation options}
{synopt:{opth max:order(integer)}}maximal order of power series expansion{p_end}
{synopt:{opth o:rder(integer)}}user-specified order{p_end}
{synopt:{opth lin:ear(varlist)}}covariates entering linearly{p_end}
{synopt:{cmd:logit}}series logit estimator{p_end}

{syntab :marginal effects}
{synopt:{opth der:ivative(varlist)}}varlist for derivative estimation{p_end}
{synopt:{cmd:at(}{it:varname=exp [...]}{cmd:)}}values for evaluation of marginal effects{p_end}
{synopt:{cmd:subpop(}{it:exp}{cmd:)}}marginal effect in subpopulation{p_end}
{synopt:{cmdab:fixed:reg}}assume fixed regressors in inference{p_end}

{syntab :VCE options}
{synopt:{opth vce(vcetype)}}variance-covariance estimator{p_end}

{syntab :other options}
{synopt:{cmdab:list:only}}generating variable lists only{p_end}
{synopt:{cmdab:gen:erate}}generate higher-order variables{p_end}
{synopt:{cmdab:coll:keep}}keep collinear variables{p_end}
{synopt:{cmdab:det:ail}}show details of variable generating process{p_end}
{synoptline}
{p 4 6 2}
{cmd:pweight}s and {cmd:aweight}s are allowed; see {help weight}.{p_end}


{title:Description}

{pstd}
{cmd:npseries} provides useful features for nonparametric series estimation using
power series expansions. 
First, one can automatically generate power series expansions of 
a specified list of independent variables, retaining only non-redundant
higher-order terms. 
Second, the command estimates nonparametric models using power series
expansions, where
the order of the series is either pre-specified by the user or  determined
automatically by  the minimization of a cross-validation criterion. 
 The cross-validation 
 criterion minimizes the integrated mean-squared error (see Hanson, 2014, Ch. 12). 
{p_end}

{title:Prediction and Marginal Effects}
 {pstd}
After estimating a model with {cmd:npseries}, predictions of the dependent 
variable are obtained as usual by the {helpb predict} postestimation command.
For example, in treatment evaluation, the series logit estimator 
can be used to estimate the 
propensity score, see Hirano et al. (2003). 
The model is estimated by {cmd:npseries} using the 
{hi:logit} option and the
propensity score is then predicted using {helpb predict}.{p_end}
 {pstd}{cmd:npseries} can also compute point estimates and standard errors of
 average marginal effects (AME). Marginal effects can be evaluated 
 at specific values of (some of) the independent variables and/or they can
 be computed for a specific subpopulation. For example, in treatment evaluation, 
 the average treatment effect on the treated can be estimated by typing{p_end}
 
{phang2}{cmd:npseries} {it:depvar treatvar indepvars}, 
derivative({it:treatvar}) subpop({it:treatvar}==1){p_end}



{title:Options}

{phang} {cmdab:max:order(}{it:integer}) specifies the highest order p
 of the series expansion that is considered for the minimization 
 of the cross-validation criterion. Default is p=2. {p_end}

{phang} {cmdab:o:rder(}{it:integer}) sets a user-specified order of the power
series.{p_end}

{phang} {cmdab:lin:ear}({it:varlist}) specifies covariates that enter the 
model linearly. This allows for the estimation of semiparametric models.{p_end}

{phang} {cmdab:logit} specifies that the series logit estimator is used.
Default is the series linear estimator.{p_end}

{phang} {cmdab:der:ivative(}{it:varlist}) specifies the list of covariates
for which average derivatives (marginal effects) are to be computed. {p_end}

{phang} {cmdab:at}({it:varname1=exp [...]}) can be used to evaluate marginal
effects at some specific values of (some of) the independent variables.
Example: at(exp=20 educ=10 female=1).{p_end}

{phang} {cmdab:subpop}({it:exp}) specifies that marginal effects are 
computed in a particular subpopulation defined by {it:exp}. Note that
{it:exp} must be specified as an if-statement. For example:
subpop(female==1). {p_end}

{phang} {cmdab:fixed:reg} imposes the assumption of 'fixed regressors'
in the estimation of the standard errors for marginal effects.
This means that inference is performed conditional on the covariates
in the sample. The default is the unconditional variance. {p_end}

{phang} {cmdab:vce(}{it:vcetype}) specifies the estimator of the 
variance-covariance matrix of the parameters. Default is vce(robust).{p_end}

{phang} {cmdab:list:only} Only variable lists of power series are 
produced. No model is estimated.{p_end}

{phang} {cmdab:gen:erate} Newly created higher-order terms are 
added as variables to the dataset.{p_end}

{phang} {cmdab:coll:keep} Perfectly collinear variables are 
retained.{p_end}

{phang} {cmdab:det:ail} Provides more details in the production
of variable lists.{p_end}


{title:Example}

{phang} /*load and edit sample data*/{p_end}
{phang2}{cmd:. webuse nlsw88, clear}{p_end}
{phang2}{cmd:. g lnwage=ln(wage)}{p_end}
{phang2}{cmd:. rename ttl_exp exp}{p_end}
{phang2}{cmd:. rename married mar}{p_end}

{phang} /*estimate model of order 2 and compute derivatives*/{p_end}
{phang2}{cmd:. npseries lnwage exp grade mar union, order(2) der(exp grade mar union)}{p_end}

{phang} /*estimate partially linear model and choose order of power series
automatically by minimizing the cross-validation criterion*/{p_end}
{phang2}{cmd:. npseries lnwage exp grade, maxorder(5) der(exp) lin(mar union)}{p_end}

{phang} /*produce lists only*/{p_end}
{phang2}{cmd:. npseries lnwage exp grade mar union, order(3) listonly gen}{p_end}
{phang2}{cmd:. ret list}{p_end}


{title:Saved results}
 
{phang}{cmd:npseries} saves the following in {cmd:r()} (depending on options):{p_end}
 
{synoptset 15 tabbed}
{p2col: Matrices}{p_end}
{synopt:{cmd:r(Der)}}derivatives (estimates, st.err., p-values){p_end}
{synopt:{cmd:r(CV)}}cross-validation criteria{p_end}
 
{p2col: Macros}{p_end}
{synopt:{cmd:r(xlist)}}list of all regressors{p_end}
{synopt:{cmd:r(popt)}}order of (optimal) power series{p_end}
{synopt:{cmd:r(expand_2)}}list of additional regressors in order 2{p_end}
{synopt:{cmd:...}}...{p_end}
{synopt:{cmd:r(expand_p)}}list of additional regressors in order p{p_end}
 
 
{title:References}
 
{phang}
Hanson, Bruce E. 2014. Econometrics. University of Wisconsin. 
{browse "http://www.ssc.wisc.edu/~bhansen/econometrics/Econometrics.pdf"}.{p_end}

{phang}
Hirano, Keisuke, Guido W. Imbens, and Geert Ridder. 
"Efficient estimation of average treatment effects using the estimated propensity score." 
Econometrica 71.4 (2003): 1161-1189.{p_end}

{title:Please cite {cmd:npseries} as follows}

{pstd}
Kaiser, Boris (2014). "NPSERIES: Stata module to perform Nonparametric Power Series Estimation", 
{browse "http://ideas.repec.org/c/boc/bocode/s457830.html"}.{p_end}
 
 
{title:Disclaimer}

{p 4 4 2}THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
OR IMPLIED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. 
SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

{p 4 4 2}IN NO EVENT WILL THE COPYRIGHT HOLDERS OR THEIR EMPLOYERS, OR ANY OTHER PARTY WHO
MAY MODIFY AND/OR REDISTRIBUTE THIS SOFTWARE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY 
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM.

 
{title:Author}
 
{pstd}For questions, queries or suggestions, please contact{p_end}
{pstd}Boris Kaiser, bo.kaiser@gmx.ch{p_end}
 
