{smcl}
{* *! version 1.1  11 Feb 2015}{...}
{cmd:help hpc} 
{hline}

{title:Title}

{p2colset 8 16 19 2}{...}
{p2col :{cmd: hpc} {hline 2}}Specification test to discriminate between models for non-negative data with many zeros{p_end}
{p2colreset}{...}

{title:Syntax}

{phang}

{p 8 13 2}
{cmd:hpc}  {depvar} {indepvars} {ifin}, a({varname}) b({varname}) [options] 


{synoptset 25 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}

{synopt:{opt c:luster(clustvar)}}specifies that the test is performed using standard errors that are computed allowing for intra-cluster 
correlation; the variable identifying the clusters is defined by {it:clustvar}{p_end}

{synoptline}
{p2colreset}{...}

{phang}The current version of {cmd:hpc} does not allow {cmd:weights}.{p_end}


{title:Description}

{pstd}
{cmd:hpc} computes the HPC test (Santos Silva, Tenreyro, and Windmeijer, 2015) for the case where the conditional expectation of
a nonnegative {depvar} is specified as the product of the exponential of a linear combination of {indepvars}, times a 
function that is bounded between zero and one (and can be identically equal to one). Examples of such models are given in Table 1 of 
Santos Silva, Tenreyro, and Windmeijer (2015). Other models that satisfy this condition are the Poisson and negative-binomial models 
and their zero inflated counterparts. Besides the dependent variable ({depvar}) and a set of regressors ({indepvars}), {cmd:hpc} 
requires the user to provide the fitted values of the conditional expectation of the two competing models as the arguments of a({varname}) 
and b({varname}).


{title:Options}

{phang}
{opt cl:uster(clustvar)} by default hpc computes the test statistics using heteroskedasticity robust standard errors. 
The cluster option specifies that the test is performed using standard errors that also allow for intragroup correlation, 
relaxing the usual requirement that the observations be independent.  That is, the observations are independent across 
groups (clusters) but not necessarily within groups.  {it:clustvar} specifies to which group each observation 
belongs; see {findalias frrobust}.


{title:Remarks}

{pstd}
{cmd: hpc} was written by J.M.C. Santos Silva, Silvana Tenreyro, and Frank Windmeijer and it is not an official Stata 
command. For further help and support, please contact jmcss@essex.ac.uk. Please notice that this software is provided 
as is, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, 
fitness for a particular purpose and noninfringement. In no event shall the author be liable for any claim, damages or 
other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the 
software or the use or other dealings in the software.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse nlsw88.dta}{p_end}

{pstd}Compare Mullahy's (1988) Modified Two-Part Model and an exponential model estimated by Poisson pseudo-maximum likelihood (the Modified Two-Part Model is model A){p_end}
{phang2}{cmd:. probit tenure union collgrad married race age}{p_end}
{phang2}{cmd:. predict p, p}{p_end}
{phang2}{cmd:. poisson tenure union collgrad married race age if tenure>0}{p_end}
{phang2}{cmd:. predict fp, n}{p_end}
{phang2}{cmd:. g f_two=fp*p}{p_end}
{phang2}{cmd:. poisson tenure union collgrad married race age}{p_end}
{phang2}{cmd:. predict f_one, n}{p_end}
{phang2}{cmd:. hpc tenure union collgrad married race age, a(f_two) b(f_one)}{p_end}

{pstd}Compare a Poisson regression model with a zero-inflated model (the ZIP is model A){p_end}
{phang2}{cmd:. zip tenure union collgrad married race age, inflate(union collgrad married race age)}{p_end}
{phang2}{cmd:. predict f_zip, n}{p_end}
{phang2}{cmd:. hpc tenure union collgrad married race age, a(f_zip) b(f_one)}{p_end}


{title:Saved results}

{pstd}
{cmd:hpc} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{synopt:{cmd:r(N_a)}}number of observations used in the auxiliary regression used to compute the test statistic when model A is the null hypothesis{p_end}
{synopt:{cmd:r(R2_a)}}R-squared for model A{p_end}
{synopt:{cmd:r(p_a)}}p-value of the hpc test when model A is the null hypothesis{p_end}
{synopt:{cmd:r(t_a)}}hpc test statistic when model A is the null hypothesis{p_end}
{synopt:{cmd:r(N_b)}}number of observations used in the auxiliary regression used to compute the test statistic when model B is the null hypothesis{p_end}
{synopt:{cmd:r(R2_b)}}R-squared for model B{p_end}
{synopt:{cmd:r(p_b)}}p-value of the hpc test when model B is the null hypothesis{p_end}
{synopt:{cmd:r(t_b)}}hpc test statistic when model B is the null hypothesis{p_end}


{title:References}

{phang} Mullahy, J. (1998), Much ado about two: Reconsidering retransformation and the two-part model in health econometrics, 
{it: Journal of Health Economics} 17, 247-282.{p_end}

{phang} Santos Silva, J.M.C., Tenreyro, S., and Windmeijer, F. (2015), 
{browse "http://www.degruyter.com/view/j/jem.2015.4.issue-1/jem-2013-0005/jem-2013-0005.xml?format=INT":Testing Competing Models for Non-negative Data with Many Zeros}, {it:Journal of Econometric Methods}, 4(1), pp. 
29-46.{p_end} 


	