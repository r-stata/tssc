{smcl}
{* 10nov2012}{...}
{hline}
help for {hi:sspecialreg, xtspecialreg}
{hline}

{title:Estimate binary choice model with discrete endogenous regressor via special regressor method}

{p 8 14}{cmd:sspecialreg}{it: depvar specreg} [{cmd:if} {it:exp}] [{cmd:in} {it:range}] 
, {cmd:endog(}{it:varlist}) {cmd:iv(}{it:varlist}) [
{cmd:exog(}{it:varlist}) {cmd:hetero} {cmd:hetv(}{it:varlist}) {cmd:kdens} 
{cmd:trim(}{it:real}) {cmd:winsor} {cmd:bs} {cmd:bsreps(}{it:integer}) ]

{p 8 14}{cmd:xtspecialreg}{it: depvar specreg} [{cmd:if} {it:exp}] [{cmd:in} {it:range}] 
, {cmd:endog(}{it:varlist}) {cmd:iv(}{it:varlist}) [
{cmd:exog(}{it:varlist}) {cmd:hetero} {cmd:hetv(}{it:varlist}) {cmd:kdens} 
{cmd:trim(}{it:real}) {cmd:winsor} {cmd:bs} {cmd:bsreps(}{it:integer}) ]

{title:Description}

{p}{cmd:sspecialreg} estimates a binary choice model that includes one or more endogenous
regressors using Lewbel and Dong's (Econometric Reviews, 2015) special regressor method. This assumes that the model
includes a particular 'special regressor', V, that is exogenous and appears additively in the model.
It must be continuously distributed with a large support. A special regressor with thick
tails (greater than Normal kurtosis) will be more useful as a special regressor. 
To invoke {cmd:sspecialreg},
you specify the {it:depvar} and the {it:specreg}, as well as the required lists of endogenous
regressors and excluded instruments.

{p}{cmd:xtspecialreg} performs the same function in the context of panel data which have
been {cmd:tsset} or {cmd:xtset}.

This method has advantages over the linear probability model (estimated with OLS or IV),
maximum likelihood and control function methods. The latter, as implemented by Stata's 
{cmd:ivprobit}, do not handle discrete or limited endogenous regressors. Unlike the maximum
likelihood approach, the special regressor method allows for heteroskedasticity of unknown
form in the model's error process.

A particular case, the simple special regressor method, is implemented by {cmd:sspecialreg}.
Two forms are defined, depending on assumptions made about the distribution of the special
regressor V. In the first form, only the mean of V is assumed to be related to other 
covariates. In the second, heteroskedastic form, higher moments of V can depend in 
arbitrary, unknown ways on the other covariates.

Two forms of the density estimator are available in {cmd:sspecialreg}: one based on a 
standard kernel density approach, making use of Jann's {cmd:kdens}, and the other
based on the 'sorted data density' approach of Lewbel and Schennach (2007).

Just as in a {cmd:probit} or {cmd:ivprobit} model, the quantities of interest are not
the estimated coefficients, but rather the marginal effects, which are derived from
the average index function proposed by Lewbel, Dong and Yang (2012). Estimates of the
precision of the marginal effects are derived by bootstrapping, and {cmd:sspecialreg}
has options to specify that bootstrap standard errors should be computed. To reproduce
results, use {cmd:set seed} before giving this command.

{title:Options}

{p 0 4}{cmd:endog}({it:varlist}) is a required option. It provides the names
of one or more endogenous regressors. This and other varlists do not allow factor variables
nor time series operators. However, a flaw in earlier versions which did not properly handle 
hyphenated varlists has been corrected. 

{p 0 4}{cmd:iv}({it:varlist}) is a required option. It provides the names
of one or more excluded instruments. To satisfy the order condition for identification,
there must be at least as many variables listed as there are in the endog() option.

{p 0 4}{cmd:exog}({it:varlist}) may be used to provide the names
of one or more included exogenous variables. 

{p 0 4}{cmd:hetero} specifies that the heteroskedastic form of the model should be 
estimated.

{p 0 4}{cmd:hetv}({it:varlist}) may be used to provide the names
of one or more variables assumed to play a role in the heteroskedasticity of the 
special regressor V. These might include, for instance, squares and cross products
of some of the exogenous regressors in the model. The use of {cmd:hetv} implies {cmd:hetero}.

{p 0 4}{cmd:kdens} specifies that the kernel density estimator should be used, rather
than the default sorted data density estimator. The {cmd:kdens} package from SSC must
be installed.

{p 0 4}{cmd:trim(}{it:real}) specifies that to ensure adequate support, the data are
to be trimmed by a specified percentage, such as 2.5.

{p 0 4}{cmd:winsor} specifies that the data are to be winsorized at the points specified
by the trim() option. You must specify both trim() and winsor.

{p 0 4}{cmd:bs} specifies that bootstrap standard errors are to be computed for the 
marginal effects.

{p 0 4}{cmd:bsreps}({it:integer}) specifies the number of bootstrap replications to be
computed. The default value is 10. Computation of a large number of bootstrap replications
may be very time-consuming.

{title:Saved results}

{p}{cmd:sspecialreg} saves the estimated coefficients and VCE of the instrumental variables
regression if the {it:bs} option is not specified. If the {it:bs} option is specified,
the estimated marginal effects and their VCE are saved in e(b) and e(V), respectively,
allowing the use of postestimation commands such as {cmd:test} and {cmd:lincom}.


{title:Examples}

{p 8 12}{inp:.} {stata "ssc install bcuse  ":ssc install bcuse}

{p 8 12}{inp:.} {stata "bcuse sspecialreg_sample  ":bcuse sspecialreg_sample}

{p 8 12}{inp:.} {stata "local exog whiteh married child educat ":local exog whiteh married child educat }

{p 8 12}{inp:.} {stata "local iv fstamp welfare resproptax ":local iv fstamp welfare resproptax}

{p 8 12}{inp:.} {stata "sspecialreg D3 ageh, trim(5) kdens exog(`exog') endog(logfinc homeowner) iv(`iv') " : sspecialreg D3 ageh, trim(5) kdens exog(`exog') endog(logfinc homeowner) iv(`iv')} 

{p 8 12}{inp:.} {stata "sspecialreg D3 ageh, trim(5) bs exog(`exog') endog(logfinc homeowner) iv(`iv') " : sspecialreg D3 ageh, trim(5) bs exog(`exog') endog(logfinc homeowner) iv(`iv')} 

{p 8 12}{inp:.} {stata "g newpid=mod(_n,1000)" : g newpid=mod(_n,1000)}

{p 8 12}{inp:.} {stata "bys newpid: g tee=_n" : bys newpid: g tee=_n}

{p 8 12}{inp:.} {stata "xtset newpid tee" : xtset newpid tee}

{p 8 12}{inp:.} {stata "xtspecialreg D3 ageh, trim(5) kdens exog(`exog') endog(homeowner) iv(`iv') " : xtspecialreg D3 ageh, trim(5) kdens exog(`exog') endog(homeowner) iv(`iv')} 

{p 8 12}{inp:.} {stata "xtspecialreg D3 ageh, trim(5) bs exog(`exog') endog(homeowner) iv(`iv') " : xtspecialreg D3 ageh, trim(5) bs exog(`exog') endog(homeowner) iv(`iv')} 


 
{title:Acknowledgements}

Development of the sspecialreg routine is based on code written by Yingying Dong. 
Thanks to Arthur Lewbel for clarifying the modifications needed in a panel data
setting. Implementation of a much faster version of the sorted data density estimator 
was provided by Ben Jann.  Jann's {cmd:kdens} routine is used to provide the kernel density 
estimates. Thanks to Christophe Bontemps for pointing out an error in the AIF code 
(corrected in v1.1.6).  Thanks also to participants in the 2012 German Stata Users Meetings, 
the 2012 Stata Conference and Manuel Denzer for their helpful comments.

{title:References}

{p 0 4} Baum, CF, Dong, Y., Lewbel, A., Yang, T., 2012. Binary Choice Models with
Endogenous Regressors. {browse "http://repec.org/san2012/baum.san2012.pdf":http://repec.org/san2012/baum.san2012.pdf}.

{p 0 4} Dong, Y. and Lewbel, A., 2015. A Simple Estimator for Binary Choice Models with 
Endogenous Regressors. Econometric Reviews, 34, 1-2, 82-105.  
{browse "http://fmwww.bc.edu/EC-P/wp604.pdf":http://fmwww.bc.edu/EC-P/wp604.pdf}.

{p 0 4} Lewbel, A., 2000. Semiparametric Qualitative Response Model Estimation with Unknown
Heteroskedasticity or Instrumental Variables.  Journal of Econometrics, 97, 145-177.

{p 0 4} Lewbel, A., 2012.  An Overview of the Special Regressor Method. 
{browse "http://fmwww.bc.edu/EC-P/wp810.pdf":http://fmwww.bc.edu/EC-P/wp810.pdf}.

{p 0 4} Lewbel, A., Dong, Y., Yang, T., 2012. Comparing features of Convenient Estimators 
for Binary Choice Models With Endogenous Regressors. Canadian Journal
of Economics, 45:3, 2012. Working paper version available from 
{browse "http://fmwww.bc.edu/EC-P/wp789.pdf":http://fmwww.bc.edu/EC-P/wp789.pdf}.

{p 0 4} Lewbel, A. and Schennach, S., 2007. A Simple Ordered Data Estimator for Inverse
Density Weighted Functions. Journal of Econometrics, 186, 189-211.


{title:Citation}

{p}{cmd:sspecialreg} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Baum, CF, 2012.
sspecialreg: Stata module to estimate binary choice model with discrete endogenous regressor via special regressor method.
{browse "http://ideas.repec.org/c/boc/bocode/s457546.html":http://ideas.repec.org/c/boc/bocode/s457546.html}{p_end}

{title:Author}

{p 0 4}Christopher F Baum, Boston College, USA{p_end}
{p 0 4}baum@bc.edu{p_end}


