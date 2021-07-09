{smcl}
{* *! version 3.9 29 Feb 2020}{...}
{cmd:help qreg2} {right:also see:  {help qreg postestimation}}

{hline}

{title:Title}

{p2colset 8 17 19 2}{...}
{p2col :{cmd: qreg2} {hline 2}}Quantile regression with robust and clustered standard errors{p_end}
{p2colreset}{...}


{title:Syntax}

{phang}

{p 8 13 2}
{cmd:qreg2} {depvar} [{indepvars}] {ifin} {weight}
	[{cmd:,} {it:options}]


{synoptset 25 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}

{synopt :{opt q:uantile(#)}}estimate {it:#} quantile; default is {cmd:quantile(.5)}{p_end}

{synopt:{opt c:luster(clustvar)}}specifies that the standard errors are computed allowing for intra-cluster correlation; 
the variable identifying the clusters is defined by {it:clustvar}{p_end}

{synopt :{opt mss(varlist)}}use {it:varlist} in the MSS heteroskedasticity test{p_end}

{synopt :{opt not:est}}suppresses the computation of the MSS and PSS tests{p_end}

{synopt :{opt s:ilverman}}uses Silverman's rule-of-thumb as a scaling factor for the bandwidth{p_end}

{synopt :{opt wls:iter(#)}}attempt {it:#} weighted least-squares iterations before doing linear programming iterations; default is {cmd:wlsiter(1)}{p_end}

{synopt :{opt e:psilon(#)}}controls the number of residuals set to zero (seldom used); default is {cmd:epsilon(1e-7)}{p_end}


{synoptline}
{p2colreset}{...}

{phang} {it: indepvars} may contain factor variables; see {help fvvarlist}.{p_end}
{phang}{cmd:qreg2} allows {cmd:fweight}s except when the option {opt cluster} is used; see {help weight}.{p_end}
{phang}See {manhelp qreg_postestimation R:qreg postestimation} for features available after estimation.



{title:Description}

{pstd}
{cmd:qreg2} is a wrapper for {manlink R qreg}  which estimates quantile regression and reports robust standard 
errors and t-statistics. By default the standard errors are asymptotically valid under heteroskedasticity 
and misspecification. The robust covariance matrix is computed following Chamberlain (1994), Angrist et al. (2006), 
and Powell (1984). Standard errors that are also robust to intra-cluster correlation can be obtained with the option 
{opt cluster}; see Parente and Santos Silva (2016). Additionally, {cmd:qreg2} reports the value of the objective 
function, defined as the average of the check function; the R-squared, defined as the square of the correlation between 
the fitted values and the dependent variable (note however that in quantile regressions the R-squared is even less meaningful 
than usual); and the result of a specification test. By default, the Machado-Santos Silva (2000) test for 
heteroskedasticity is reported. This test is valid after quantile regression estimation and by default the test 
variables are the fitted values of the dependent variable and its squares as in the "Special case of the White test"; 
see Wooldridge (2009, p. 276). Alternative sets of test variables can be specified with {opt mss(varlist)}. When the
option {opt cluster} is used the Parente-Santos Silva (2016) test for intra-cluster correlation is reported. The 
computation of the test statistics can be suppressed with the option {opt notest}.


{title:Citations}

{pstd}
We would be grateful if you could cite our work when you use {cmd:qreg2}. The correct citations are as follows:

{pstd}
a) If you use clustered standard errors or the Parente-Santos Silva (2016) test, please cite:

{phang} Parente, P.M.D.C. and Santos Silva, J.M.C. (2016), 
{browse "http://www.degruyter.com/printahead/j/jem":Quantile Regression with Clustered Data}, 
{it:Journal of Econometric Methods}, 5, 1-15.{p_end}

{pstd}
b) If you use the Machado-Santos Silva (2000) test, please cite:

{phang} Machado, J.A.F. and Santos Silva, J.M.C. (2000), 
{browse "http://www.sciencedirect.com/science/article/pii/S0304407600000166":Glejser's Test Revisited}, 
{it:Journal of Econometrics}, 97, 189-202.{p_end}

{pstd}
c) If you just use heteroskedasticity-robust standard errors, please cite:

{phang} Machado, J.A.F., Parente, P.M.D.C., and Santos Silva, J.M.C. (2011), QREG2: Stata module to perform 
quantile regression with robust and clustered standard errors, Statistical Software Components S457369, 
Boston College Department of Economics.{p_end}

{marker options}
{title:Options}

{phang}{opt quantile(#)} specifies the quantile to be estimated and should be
a number between 0 and 1, exclusive.  Numbers larger than 1 are interpreted as
percentages.  The default value of 0.5 corresponds to the median.

{phang}{opt cluster(clustvar)} specifies that the standard errors are computed 
allowing for intra-cluster correlation as in Parente and Santos Silva (2016); the 
variable identifying the clusters is defined by {it:clustvar}.

{phang}{opt mss(varlist)} specifies the list of variables to be used in the Machado-Santos 
Silva (2000) heteroskedasticity test. By default, the test is performed using the fitted 
values of the dependent variable and its squares.

{phang}{opt notest} suppresses the computation of the Machado-Santos Silva (2000) and 
Parente-Santos Silva (2016) tests.

{phang}{opt silverman} by default the scaling factor for the bandwidth is the median absolute 
deviation of the quantile regression residuals, as in Parente and Santos Silva (2016). When 
the option {opt silverman} is used, the scaling factor is given by Silverman's (1986) rule-of-thumb.

{phang}{opt wlsiter(#)} specifies the number of weighted least-squares
iterations that will be attempted before the linear programming iterations are
started.  The default value is 1.  If there are convergence 
problems, increasing this number may help.

{phang}{opt epsilon(#)} controls the number of residuals set to zero (seldom used), 
the default value is 1e-7. In quantile regression, there should be at least as many 
residuals equal to zero as parameters estimated. However, when residuals are generated, 
some of those that should be zero are not set exactly equal to zero. This is important 
because the covariance matrix and the tests depend on how many residuals are negative, 
zero, or positive.  {cmd: qreg2} uses a rule to set to zero the residuals whose absolute 
value is small enough. This rule works generally well, but in rare cases it may generate 
too few or too many zero residuals, and the option {opt epsilon(#)} can be used to correct 
this. The number of residuals equal to zero can be found in {cmd:e(zeros)}.  


{title:Remarks}

{pstd}
{cmd: qreg2} was written by J.A.F. Machado, P.M.D.C. Parente, and J.M.C. Santos Silva and it is not an 
official Stata command. For further help and support, please contact jmcss@surrey.ac.uk. Please notice 
that this software is provided as is, without warranty of any kind, express or implied, including but 
not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. 
In no event shall the authors be liable for any claim, damages or other liability, whether in an action 
of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other 
dealings in the software.


{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}Median regression with heteroskedasticity-robust standard errors{p_end}
{phang2}{cmd:. qreg2 price weight length foreign}{p_end}

{pstd}Estimate .25 quantile with heteroskedasticity-robust standard errors{p_end}
{phang2}{cmd:. qreg2 price weight length foreign, quantile(.25)}{p_end}

{pstd}Median regression computing the MSS test using the regressors as test variables{p_end}
{phang2}{cmd:. qreg2 price weight length foreign, mss(weight length foreign)}{p_end}

{pstd}Median regression suppressing the MSS test{p_end}
{phang2}{cmd:. qreg2 price weight length foreign, not}{p_end}

{pstd}Estimate .25 quantile and cluster standard errors by headroom {p_end}
{phang2}{cmd:. qreg2 price weight length foreign, q(.25) c(headroom)}{p_end}



    {hline}


{title:Saved results}

{pstd}
{cmd:qreg2} saves the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom - always set to missing{p_end}
{synopt:{cmd:e(zeros)}}number of residuals equal to zero{p_end}
{synopt:{cmd:e(q)}}quantile requested{p_end}
{synopt:{cmd:e(q_v)}}value of the quantile{p_end}
{synopt:{cmd:e(sum_adev)}}sum of absolute deviations{p_end}
{synopt:{cmd:e(sum_rdev)}}sum of raw deviations{p_end}
{synopt:{cmd:e(obj_func)}}mean of the check function{p_end}
{synopt:{cmd:e(f_r)}}residual density estimate{p_end}
{synopt:{cmd:e(convcode)}}{cmd:0} if converged; otherwise, return code for why nonconvergence{p_end}
{synopt:{cmd:e(r2)}}R-squared defined as the square of the correlation between the fitted values and the dependent variable{p_end}
{synopt:{cmd:e(mss_chi2)}}MSS test statistic (if computed){p_end}
{synopt:{cmd:e(mss_df)}}degrees of freedom of the MSS test (if computed){p_end}
{synopt:{cmd:e(mss_p)}}p-value of the MSS test (if computed){p_end}
{synopt:{cmd:e(pss_t)}}PSS test statistic (if computed){p_end}
{synopt:{cmd:e(pss_p)}}p-value of the PSS test (if computed){p_end}


{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:qreg}{p_end}
{synopt:{cmd:e(cmdline)}}command as used in the estimation{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(marginsnotok)}}predictions disallowed by {cmd:margins}{p_end}


{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{title:References}

{phang} Angrist, J.; Chernozhukov, V. and Fernández-Val, I. (2006), Quantile Regression under Misspecification, 
with an Application to the U.S. Wage Structure, 
{it:Econometrica}, 74, 539-563.{p_end} 
{phang} Chamberlain, G. (1994), Quantile Regression, Censoring and the Structure of Wages, in 
{it:Advances in Econometrics}, ed. C.A. Sims, Cambridge University Press, 171-209.{p_end} 
{phang} Machado, J.A.F. and Santos Silva, J.M.C. (2000), {browse "http://www.sciencedirect.com/science/article/pii/S0304407600000166":Glejser's Test Revisited}, {it:Journal of Econometrics}, 
97, 189-202.{p_end} 
{phang} Parente, P.M.D.C. and Santos Silva, J.M.C. (2016), {browse "http://www.degruyter.com/printahead/j/jem":Quantile Regression with Clustered Data}, 
{it:Journal of Econometric Methods}, 5, 1-15.{p_end} 
{phang} Powell, J.L. (1984), Least Absolute Deviation Estimation for the Censored Regression Model, 
{it:Journal of Econometrics}, 25, 303-325.{p_end} 
{phang} Silverman, B. W. (1986), {it:Density estimation for statistics and data analysis}, New York(NY): Chapman and Hall.{p_end} 
{phang} Wooldridge, J.M. (2009), {it:Introductory Econometrics}, 4th edition, Mason (OH): South Western.{p_end}


{title:Also see}

{psee}
Manual:  {manlink R qreg}

{psee}
{space 2}Help:  {manhelp qreg_postestimation R:qreg postestimation};

