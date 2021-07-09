{smcl}
{* *! version 1.4  2020-06-02}{...}
{* *  version 1.3  2020-05-21}{...}
{* *  version 1.2  2019-12-19}{...}
{* * version 1.0  2019-11-05}{...}
{findalias asfradohelp}{...}
{vieweralsosee "[R] help" "help help"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] bunching" "help bunching"}{...}
{vieweralsosee "[R] bunchfilter" "help bunchfilter"}{...}
{vieweralsosee "[R] bunchtobit" "help bunchtobit"}{...}
{viewerjumpto "Syntax" "bunchbounds##syntax"}{...}
{viewerjumpto "Description" "bunchbounds##description"}{...}
{viewerjumpto "Stored results" "bunchbounds##results"}{...}
{viewerjumpto "Reference" "bunchbounds##reference"}{...}
{title:Title}

{phang}
{bf:bunchbounds} {hline 2} uses bunching to compute partially-identified set for the elasticity of income with respect to tax rates, 
according to the procedures of Bertanha, McCallum, and Seegert (2019).


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:bunchbounds}
{it:varname}
{ifin}
{weight}
{cmd:,}
	 {cmdab:k:ink}({it:#}) 
	 {cmdab:m}({it:#}) 
	 {cmdab:tax0}({it:#}) 
	 {cmdab:tax1}({it:#}) 
[	 {cmdab:nopic}
	 {cmdab:saving}({it:string}) 
]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt varname}}must be one dependent variable (ln of income){p_end}
{synopt :{opt if | in}}like in any other Stata command, to restrict the working sample{p_end}

{syntab:Options}
{synopt :{opt k:ink(# real)}}is the location of the kink point where tax rates change{p_end}
{synopt :{opt m(# real)}}is the maximum slope magnitude of the probability density function (PDF) of the unobserved heterogeneity, a strictly positive scalar{p_end}
{synopt :{opt tax0(# real)}}is the marginal income tax rate before the {it:kink} point{p_end}
{synopt :{opt tax1(# real)}}is the marginal tax rate after the {it:kink} point, which must be strictly bigger than {it:tax0}{p_end}
{p2coldent :* {opt nopic}}if you state this option, then no graphs will be displayed. Default state is to have graphs displayed{p_end}
{p2coldent :* {opt saving(string [, replace])}}gives you the option to save a DTA file with (x,y) coordinates of the graph of the partially-identified set as a function of the slope magnitude of the heterogeneity distribution.
Use {it:saving(filename.dta)} or {it:saving(filename.dta, replace)} if {it:filename.dta} already exists in the working directory{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:*} optional parameters {p_end}
{p 4 4 2}
only {cmd:fweight} or {cmd:fw} (frequency weights) are allowed; see {help weight} 



{marker description}{...}
{title:Description}

{pstd}
{cmd:bunchbounds} – uses a mass point (bunching) in a distribution of reported income to partially identify the elasticity of income with respect to tax rate. 
The marginal income tax rate changes discontinuously at the mass point (i.e. kink point in the budget set).

{pstd}
The user enters the name of the income variable (in natural logs), the location of the {it:kink}  point, 
the maximum slope magnitude {it:m} of the PDF of the unobserved heterogeneity, 
and the marginal tax rates before and after the {it:kink} point. 
The code computes the maximum and minimum values of the elasticity that are consistent with the slope restriction on the 
PDF and the observed distribution of income. The true value of {it:m} is unknown but the code gives suggestions of {it:m} values based on the continuous part of the distribution. The minimum and maximum values 
of {it:m} in the data are constructed from a histogram of the dependent variable that excludes the {it:kink} point and use the same default {it:binwidth} as {help bunchtobit}. If that histogram happens to be too undersmoothed, 
the maximum value of {it:m} in the data might be too high (and vice-versa).

{p 4 4 2}{it:Note 1}: You need to have a dataset with one variable drawn from a mixed continuous-discrete distribution. The distribution is continuous except for the {it:kink} value, which has a positive mass point. 
The proportion of income values at the {it:kink} value must be positive in your sample.{p_end}
{p 4 4 2}Check to see if {cmd:count if y==kink} (where {it:y} is the dependent variable) gives you the right number. In case it gives you zero when it should not, check the 
value of the {it:kink} and if {it:y} is type {it:double}.{p_end}

{p 4 4 2}{it:Note 2}: You need to have installed the Stata package {cmd:"lpdensity"} before proceeding.{p_end}
{p 4 4 2}References:{p_end}

{p 4 4 2}{it:Cattaneo, Jansson and Ma (2019): Simple Local Polynomial Density Estimators, Journal of the American Statistical Association, forthcoming.}{p_end}

{p 4 4 2}{browse "https://sites.google.com/site/nppackages/lpdensity":https://sites.google.com/site/nppackages/lpdensity}{p_end}


{p 40 20 2}(Go up to {it:{help bunchbounds##syntax:Syntax}}){p_end}


{marker example}{...}
{title:Example}

{p 4 8}Load the test data file included in the package:{p_end}
{p 8 8}{cmd:. use bunching}{p_end}

{p 4 8}Run {cmd: bunchbounds}:{p_end}
{p 8 8}{cmd:. bunchbounds yclean, k(2.15) m(2) tax0(-0.34) tax1(0) saving(dbounds.dta, replace)}{p_end}

{p 40 20 2}(Go up to {it:{help bunchbounds##syntax:Syntax}}){p_end}

{marker results}{...}
{title:Stored results}{p 50 20 2}{p_end}
{pstd}
{cmd:bunchbounds} stores the following in {cmd:r()}:

{synoptset 24 tabbed}{...}
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

	
{p 40 20 2}(Go up to {it:{help bunchbounds##syntax:Syntax}}){p_end}

{marker reference}
{title:Reference}

{p 5 6 2}
Bertanha, M., McCallum, A., Seegert, N. (2019), “Better Bunching, Nicer Notching”. Working paper SSRN 3144539.
{p_end}
