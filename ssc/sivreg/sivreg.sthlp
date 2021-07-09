{smcl}
{cmd:help sivreg}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:sivreg} {hline 2} (Adaptive) Lasso with some invalid instruments}{p_end}
{p2colreset}{...}

{title:Syntax}

	{opt sivreg} {depvar} {indepvars} {ifin}{cmd:,} {cmd:endog(}{vars}{cmd:)} {cmd:exog(}{vars}{cmd:)} [{it:options}]

{pstd}

{synoptset 20}{...}
{synopthdr}
{synoptline}
{synopt :{opt endog(varlist)}}specifies the endogenous variable [required]{p_end}
{synopt :{opt exog(varlist)}}specifies a list of potentially exogenous instruments and additional exogenous regressors [required]{p_end}
{synopt :{opt adaptive}}performs adaptive Lasso as described in Windmeijer et al. (2016){p_end}
{synopt :{opt c}}the confidence level of the performed J-tests is 1-{opt c}/ln(n), default {opt c}=0.1{p_end}
{synoptline}

{title:Description}

{pstd} {cmd:sivreg} estimates a linear instrumental variables regression where some of the instruments fail the exclusion restriction and are thus invalid.
The LARS algorithm (Efron et al., 2004) is applied as long as the Hansen statistic (OID test) rejects. The results report the instruments, which are identified 
as invalid, and report the Post-Lasso estimate from a 2SLS regression applying the (adaptive) Lasso selection. 
For general information about adaptive Lasso see Zou (2006).

{pstd} {cmd:sivreg} uses the moremata package. If it is not already installed, type "{it:ssc install moremata}" in Stata.

{title:Example}

{pstd}Let {opt y} be the outcome, {opt d} an endogenous regressor, {opt x} an exogenous control variable and {opt z1 z2 z3} a set of potentially 
exogenous instruments, then the adaptive Lasso regression would be{p_end}

{phang2}{cmd:. sivreg y d x, endog(d) exog(x z1 z2 z3) adaptive}{p_end}

{title:Author}

{pstd}Helmut Farbmacher{p_end}
{pstd}Munich Center for the Economics of Aging (MEA){p_end}
{pstd}Max Planck Society, Germany{p_end}
{pstd}farbmacher@mea.mpisoc.mpg.de{p_end}

{title:Reference}

{psee}Windmeijer, F. {it:et al.} (2018): {it:On the Use of the Lasso for Instrumental Variables Estimation with Some Invalid Instruments}, Journal of the American Statistical Association, forthcoming.{p_end}
{psee}Zou, H. (2006): {it:The Adaptive Lasso and Its Oracle Properties}, Journal of the American Statistical Association 101, 1418-1429.{p_end}
{psee}Efron, B. {it:et al.} (2004): {it:Least Angle Regression}, Annals of Statistics 32, 407-499.{p_end}

