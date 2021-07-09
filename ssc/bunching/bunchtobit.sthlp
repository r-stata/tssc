{smcl}
{* *! version 1.5  2020-06-02}{...}
{* *  version 1.4  2020-05-21}{...}
{* *  version 1.3  2020-04-24}{...}
{* *  version 1.2  2019-12-19}{...}
{* *  version 1.0  2019-11-05}{...}
{findalias asfradohelp}{...}
{vieweralsosee "[R] help" "help help"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] bunching" "help bunching"}{...}
{vieweralsosee "[R] bunchfilter" "help bunchfilter"}{...}
{vieweralsosee "[R] bunchbounds" "help bunchbounds"}{...}
{viewerjumpto "Syntax" "bunchtobit##syntax"}{...}
{viewerjumpto "Description" "bunchtobit##description"}{...}
{viewerjumpto "Stored results" "bunchtobit##results"}{...}
{viewerjumpto "Reference" "bunchtobit##reference"}{...}
{title:Title}

{phang}
{bf:bunchtobit} {hline 2} uses bunching, Tobit regressions, and covariates to point-identify the elasticity of income with respect to tax rates,
 according to the procedures of Bertanha, McCallum, and Seegert (2019).


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:bunchtobit}
{it:varname}
{ifin}
{weight}
{cmd:,}
	 {cmdab:k:ink}({it:#}) 
	 {cmdab:tax0}({it:#}) 
	 {cmdab:tax1}({it:#}) 
[	 {cmdab:g:rid}({it:numlist})  
	 {cmdab:verbose}
	 {cmdab:n:umiter}({it:#}) 
	 {cmdab:binw:idth}({it:#})
	 {cmdab:nopic}
	 {cmdab:saving}({it:string}) 
]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt varname}}must be one dependent variable (ln of income), covariates are optional{p_end}
{synopt :{opt if | in}}like in any other Stata command, to restrict the working sample{p_end}

{syntab:Options}
{synopt :{opt k:ink(# real)}}is the location of the kink point where tax rates change{p_end}
{synopt :{opt tax0(# real)}}is the marginal income tax rate before the {it:kink} point{p_end}
{synopt :{opt tax1(# real)}}is the marginal tax rate after the {it:kink} point, which must be strictly bigger than {it:tax0}{p_end}
{p2coldent :* {opt grid(numlist)}}grid with integer numbers  between 1 and 99. The 
number of grid points determines the number of symmetric truncation windows around the kink point. The 
value of the grid points correspond to the percentage of the sample that is selected by each truncation window. The 
code will always add 100 (full sample) to the grid, so the number of grid points is always one more than the number
of grid points provided by the user. The default value for the grid is {it:10(10)90}{p_end}
{p2coldent :* {opt verbose}}if provided, this option makes the code display detailed output of Tobit regressions and likelihood iterations.
 Non-verbose mode is the default{p_end}
{p2coldent :* {opt numiter(# int)}}maximum number of iterations for likelihood maximizations. Default is 500{p_end}
{p2coldent :* {opt binwidth(# real)}} Default value is half of what is automatically produced by the command {help histogram}.
 A strictly positive value {p_end}
{p2coldent :* {opt nopic}}if you state this option, then no graphs will be displayed.
 Default state is to have graphs displayed{p_end}
{p2coldent :* {opt saving(string [, replace])}}gives you the option to save a *.dta file with Tobit estimates for each truncation window.
 The *.dta file contains eight variables corresponding to the matrices that the code stores in 
{it:r()}. See below for more details. Use {it:saving(filename.dta)} or {it:saving(filename.dta, replace)} if {it:filename.dta} already 
exists in the working directory{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:*} optional parameters {p_end}
{p 4 4 2}
only {cmd:fweight} or {cmd:fw} (frequency weights) are allowed; see {help weight} {p_end}



{marker description}{...}
{title:Description}

{pstd}
{cmd:bunchtobit} – uses a mass point (bunching), Tobit regressions, and covariates to point-identify the elasticity of income with 
respect to tax rate. The marginal income tax rate changes discontinuously at the mass point (i.e. kink point in the budget set).

{pstd}
The user enters the name of the income variable (in natural logs), the names of explanatory variables, the location of the {it:kink} point, 
the marginal tax rates before and after the kink point. The code runs a sequence 
of mid-censored Tobit regressions using different
sub-samples of the data. It starts with the entire sample, then it truncates the value of the income variable in shrinking symmetric windows centered at the {it:kink} point. The elasticity estimate is plotted 
as a function of the percentage of 
data used by the truncation windows. The code also plots the histogram of the income variable along with the best-fit Tobit distribution for each truncation window.

{p 4 4 2}{it:Note}: you need to have a dataset with the income variable drawn from a mixed continuous-discrete distribution. The distribution is continuous except for the kink value, which has a positive mass point.
The proportion of income values at the kink value must be positive in your sample.{p_end}
{p 4 4 2}Check to see if {cmd:count if y==kink} (where {it:y} is the dependent variable) gives you the right number. In case it gives you zero when it should not, check the 
value of the {it:kink} and if {it:y} is type {it:double}.{p_end}

{p 40 20 2}(Go up to {it:{help bunchtobit##syntax:Syntax}}){p_end}

{marker example}{...}
{title:Example}

{p 4 8}Load the test data file included in the package:{p_end}
{p 8 8}{cmd:. use bunching}{p_end}

{p 4 8}Run {cmd: bunchtobit}:{p_end}
{p 8 8}{cmd:. bunchtobit yclean x1 x2, kink(2.15) tax0(-0.34) tax1(0)  saving(dtobit.dta, replace)}{p_end}

{p 40 20 2}(Go up to {it:{help bunchtobit##syntax:Syntax}}){p_end}

{marker results}{...}
{title:Stored results}{p 50 20 2}{p_end}
{pstd}
{cmd:bunchtobit} stores the following in {cmd:r()}:

{synoptset 24 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(tobit_theta_l_hat)}}intercept of left-hand side equation{p_end}
{synopt:{cmd:r(tobit_theta_r_hat)}}intercept of the right-hand side equation{p_end}
{synopt:{cmd:r(tobit_sigma_hat)}}standard error of error term{p_end}
{synopt:{cmd:r(tobit_perc_obs)}}percentage of observations selected by truncation window{p_end}
{synopt:{cmd:r(tobit_eps_hat)}}elasticity estimate{p_end}
{synopt:{cmd:r(tobit_se_hat)}}standard error of elasticity estimator{p_end}
{synopt:{cmd:r(tobit_covcol)}}number of covariates whose coefficients were restricted because of collinearity{p_end}
{synopt:{cmd:r(tobit_flag)}}dummy that equals one if the likelihood optimization did not converge {p_end}

{p2col 5 20 24 2: Scalars}{p_end}

{synopt:{cmd:r(binwidth)}}value of bindwidth used in histograms{p_end}
{synopt:{cmd:r(tobit_bin_n)}}number of bins used in histograms{p_end}
	
{p 40 20 2}(Go up to {it:{help bunchtobit##syntax:Syntax}}){p_end}

{marker reference}{...}
{title:Reference}

{p 5 6 2}
Bertanha, M., McCallum, A., Seegert, N. (2019), “Better Bunching, Nicer Notching”. Working paper SSRN 3144539.
{p_end}
