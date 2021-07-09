{smcl}
{* *! version 1.2  2020-06-02}{...}
{* *  version 1.1  2020-05-21}{...}
{* *  version 1.0  2020-05-05}{...}
{findalias asfradohelp}{...}
{vieweralsosee "[R] help" "help help"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] bunchfilter" "help bunchfilter"}{...}
{vieweralsosee "[R] bunchbounds" "help bunchbounds"}{...}
{vieweralsosee "[R] bunchtobit" "help bunchtobit"}{...}
{viewerjumpto "Syntax" "bunching##syntax"}{...}
{viewerjumpto "Description" "bunching##description"}{...}
{viewerjumpto "Stored results" "bunching##results"}{...}
{viewerjumpto "Reference" "bunching##reference"}{...}
{title:Title}

{phang}
{bf:bunching} {hline 2} uses bunching to partially and point identify the elasticity of income with respect to tax rates using different assumptions 
on unobserved heterogeneity,  according to the procedures of Bertanha, McCallum, and Seegert (2019).


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:bunching}
{it:varname}
{ifin}
{weight}
{cmd:,}
	 {cmdab:k:ink}({it:#}) 
	 {cmdab:tax0}({it:#}) 
	 {cmdab:tax1}({it:#}) 
	 {cmdab:m}({it:#}) 
[	 {cmdab:gen:erate}({it:newvar}) 
	 {cmdab:deltam}({it:#}) 
	 {cmdab:deltap}({it:#}) 
	 {cmdab:perc:_obs}({it:#}) 
	 {cmdab:pol:order}({it:#})
	 {cmdab:g:rid}({it:numlist})  
	 {cmdab:n:umiter}({it:#}) 
	 {cmdab:verbose}
	 {cmdab:savingbounds}({it:string}) 
	 {cmdab:savingtobit}({it:string}) 
	 {cmdab:binw:idth}({it:#})
	 {cmdab:nopic}
]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt varname}}must be one dependent variable (ln of income), covariates are optional{p_end}
{synopt :{opt if | in}}like in any other Stata command, to restrict the working sample{p_end}

{syntab:Options}

{synopt :{opt k:ink}(# real)}is the location of the mass point{p_end}
{synopt :{opt tax0(# real)}}is the marginal income tax rate before the {it:kink} point{p_end}
{synopt :{opt tax1(# real)}}is the marginal tax rate after the {it:kink} point, which must be strictly bigger than {it:tax0}{p_end}
{synopt :{opt m(# real)}}is the maximum slope magnitude of the probability density function (PDF) of the unobserved heterogeneity, a strictly positive scalar (option of {help bunchbounds}){p_end}
{p2coldent :* {opt gen:erate(newvar)}}generates the filtered variable with a user-specified name of {it:varname} (option of {help bunchfilter}). If this option is used, 
then options {it:deltam} and {it:deltap} must also be specified.{p_end}
{p2coldent :* {opt deltam(# real)}}is the lower half-length of the hump window, that is, the distance between the mass point to the lower-bound of the hump window (option of {help bunchfilter}). If this option is used, 
then options {it:generate} and {it:deltap} must also be specified. {p_end}
{p2coldent :* {opt deltap(# real)}}is the upper half-length of the hump window, that is, the distance between the mass point to the upper-bound of the hump window (option of {help bunchfilter}). If this option is used, 
then options {it:generate} and {it:deltam} must also be specified.{p_end}
{p2coldent :* {opt perc:_obs(# real)}}for better fit, the polynomial regression of {help bunchfilter} uses observations in a symmetric window around the {it:kink} point that contains {it:perc_obs} percent of the sample. 
Default value is 40, ({it:integer, min = 1, max = 99}).{p_end}
{p2coldent :* {opt pol:order(# integer)}}maximum order of polynomial regression of {help bunchfilter}. Default value is 7, {it:min = 2; max = 7}.{p_end}
{p2coldent :* {opt g:rid(numlist)}}grid with integer numbers between 1 and 99 (option of {help bunchtobit}). The number of grid points determines the number of symmetric truncation windows around the kink point, 
on which the Tobit regressions are run. The value of the grid points correspond to the percentage of the sample that is selected by each truncation window. The code will always add 100 (full sample) to the grid, 
so the number of grid points is always one more than the number of grid points 
provided by the user. The default value for the grid is {it:10(10)90}.{p_end}
{p2coldent :* {opt n:umiter(# int)}}maximum number of iterations for likelihood maximizations of Tobit regressions. Default is 500.{p_end}
{p2coldent :* {opt verbose}}if provided, this option makes the code display detailed output of Tobit regressions and likelihood iterations. Non-verbose mode is the default.{p_end}
{p2coldent :* {opt savingbounds(string [, replace])}}gives you the option to save a *.dta file with (x,y) coordinates of the graph of the partially-identified set as a function of the slope 
magnitude of the heterogeneity distribution (option of {help bunchbounds}). Use 
{it:saving(filename.dta)} or {it:saving(filename.dta, replace)} if {it:filename.dta} already exists in the working directory.{p_end}
{p2coldent :* {opt savingtobit(string [, replace])}}gives you the option to save a *.dta file with Tobit estimates for each truncation window. The *.dta file contains eight variables 
corresponding to the matrices that the code stores in {it:r()}. See below for more details. Use {it:saving(filename.dta)} or {it:saving(filename.dta, replace)} if {it:filename.dta} already exists in the working directory.{p_end}
{p2coldent :* {opt binw:idth(# real)}}the width of the bins for histograms of {help bunchfilter} and {help bunchtobit}. Default value is half of what is automatically produced by the 
command {help histogram}. A strictly positive value.{p_end}
{p2coldent :* {opt nopic}}if you state this option, then no graphs will be displayed. Default state is to have graphs displayed{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:*} optional parameters {p_end}
{p 4 4 2}
only {cmd:fweight} or {cmd:fw} (frequency weights) are allowed; see {help weight} {p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:bunching} – uses a mass point (bunching) in a distribution of reported income to partially  and point identify the elasticity of income with respect to tax rate.  The marginal income tax rate changes discontinuously at the mass point 
(i.e. kink point in the budget set). This is a master function that combines {help bunchbounds} for partial identification with {help bunchtobit} for point identification. If desired, bunching also calls {help bunchfilter} 
to filter out friction error of the data. 

{pstd}
You need to have a dataset with a dependent variable (e.g., ln of income) and possibly some covariates. 
The dependent variable is drawn from a mixed continuous-discrete distribution, that is, continuous except for the {it:kink} value, which has a positive mass point. The proportion of values at the {it:kink} must be positive in your sample. 
Check to see if {it:count if y==kink} (where {it:y} is the dependent variable) gives you the right number. In case it gives you zero when it should not, check the value of the 
{it:kink} and if {it:y} is type {it:double}. In 
case your dependent variable is such that the bunching mass is dispersed in a neighborhood around the {it:kink} point because of friction errors, please refer to the last two paragraphs of this description.

{pstd}
First, bunching calls {help bunchbounds}. The code computes the maximum and minimum values of the elasticity that are consistent with the slope restriction on the PDF and the observed distribution of 
income. The true value of {it:m} is unknown 
but the code gives suggestions of {it:m} values based on the continuous part of the distribution. The minimum and maximum values of {it:m} in the data are constructed from a histogram of the dependent 
variable that excludes the {it:kink} point and 
use the same default binwidth as {help bunchtobit}. If that histogram happens to be too undersmoothed, the maximum value of {it:m} in the data might be too high (and vice-versa).

{pstd}
Second, the code runs a sequence of mid-censored Tobit regressions using different sub-samples of the data. It starts with the entire sample, then it truncates the value of the income variable in shrinking 
symmetric windows centered 
at the {it:kink} point. The elasticity estimate is plotted as a function of the percentage of data used by the truncation windows. The code also plots the histogram of the income variable along 
with the best-fit Tobit distribution for each truncation window.

{pstd}
In case there are friction errors in the dependent variable and the the bunching mass is dispersed in a neighborhood around the {it:kink} point, the user must specify the following three 
options together: {it:generate}, {it:deltam}, and 
{it:deltap}. Bunching will then run {help bunchfilter} before {help bunchbounds} and {help bunchtobit} and generate a variable without 
friction errors. The distribution of the data with error is continuous and its PDF typically exhibits a hump around the location of the mass point. The distribution without error is 
mixed continuous-discrete with one mass point at the kink.
The option {opt generate} specifies the name of the new variable without friction errors.
Options {opt deltam} and {opt deltap} specify the window around the mass point that contains the hump, that is, {it:(kink - deltam, kink + deltap)}.

{pstd}
The procedure of {help bunchfilter} fits a polynomial regression to the empirical cumulative distribution function (CDF) of the dependent variable (observed with error). This regression excludes 
points in the hump window and has a dummy for observations on the left or right of the mass point. The fitted regression predicts values of the empirical CDF in the hump window with a 
jump discontinuity at the mass point. The filtered 
data equals the inverse of the predicted CDF evaluated at the empirical CDF value of each observation in the sample. This procedure works well for cases where the friction error has 
bounded support {it:(- deltam, + deltap)} and only affects observations that would be at the {it: kink} in the absence of error. A proper deconvolution theory still needs to be developed for a filtering procedure with general validity.
	
{p 40 20 2}(Go up to {it:{help bunching##syntax:Syntax}}){p_end}

{marker examples}{...}
{title:Examples}

{p 4 8}Load the test data file included in the package:{p_end}
{p 8 8}{cmd:. use bunching}{p_end}

{p 4 8}Run {cmd: bunching} with filter:{p_end}
{p 8 8}{cmd:. bunching y_i x1 x2,  k(2.15) tax0(-0.34) tax1(0) m(2) gen(y_2) deltap(0.3) deltam(0.3) savingtobit(dtobit.dta, replace) savingbounds(dbounds.dta, replace)}{p_end}

{p 4 8}Run {cmd: bunching} without filter:{p_end}
{p 8 8}{cmd:. bunching yclean x1 x2,  k(2.15) tax0(-0.34) tax1(0) m(2)  savingtobit(dtobit.dta, replace) savingbounds(dbounds, replace)}{p_end}

{p 40 20 2}(Go up to {it:{help bunching##syntax:Syntax}}){p_end}

{marker results}{...}
{title:Stored results}{p 50 20 2}{p_end}
{pstd}
{cmd:bunching} stores the following in {cmd:r()}:

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

{synopt:{cmd:r(bounds_e_trap)}}estimated elasticity using trapezoidal approximation{p_end}
{synopt:{cmd:r(bounds_emin_mmax)}}lower bound estimate for the elasticity using constant {it:m} entered by user{p_end}
{synopt:{cmd:r(bounds_emax_mmax)}}upper bound estimate for the elasticity using constant {it:m} entered by user{p_end}
{synopt:{cmd:r(bounds_M_hat)}}if heterogeneity PDFs have maximum slope magnitude greater than {it:M_hat}, then we cannot rule out PDFs that equal zero inside the bunching interval. In this case, the upper bound is infinity{p_end}
{synopt:{cmd:r(bounds_M_min_hat)}}if heterogeneity PDFs have maximum slope magnitude smaller than {it:M_min_hat}, then no heterogeneity PDF is consistent with the observed distribution of income. Bounds are not defined{p_end}
{synopt:{cmd:r(bounds_M_data_min)}}minimum value of slope magnitude in the estimated PDF of the observed distribution of income (continuous part of the PDF){p_end}
{synopt:{cmd:r(bounds_M_data_max)}}maximum value of slope magnitude in the estimated PDF of the observed distribution of income (continuous part of the PDF){p_end}
{synopt:{cmd:r(bounds_emin_mhat)}}lower bound estimate for the elasticity if the choice of {it:m} were equal to {it:M_hat}. Available only when the choice of {it:m} entered by user is bigger than {it:M_hat}{p_end}
{synopt:{cmd:r(bounds_emax_mhat)}}upper bound estimate for the elasticity if the choice of {it:m} were equal to {it:M_hat}. Available only when the choice of {it:m} entered by user is bigger than {it:M_hat}{p_end}
{synopt:{cmd:r(tobit_bin_n)}}number of bins used in histograms of {help bunchtobit}{p_end}
{synopt:{cmd:r(filter_Bhat)}}estimated bunching mass{p_end}
{synopt:{cmd:r(filter_R2)}}R-squared of polynomial regression{p_end}
{synopt:{cmd:r(filter_vars_dropped)}}number of variables dropped out of the polynomial regression in case the initial set of explanatory variables had perfect collinearity{p_end}
{synopt:{cmd:r(binwidth)}}value of bindwidth used in histograms of {help bunchfilter} and {help bunchtobit}. This is not stored if option {opt nopic} is stated. {p_end}

	
{p 40 20 2}(Go up to {it:{help bunching##syntax:Syntax}}){p_end}

{marker reference}
{title:Reference}

{p 5 6 2}
Bertanha, M., McCallum, A., Seegert, N. (2019), “Better Bunching, Nicer Notching”. Working paper SSRN 3144539. {p_end}


