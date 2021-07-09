{smcl}
{* April 2014}{...}
{hline}
help for {hi:unemp (Version 1.0)}{right:Carlos Gradín (April 2014)}
{hline}

{title: Measures of employment deprivation (unemployment) among households}

{p 8 17 2} {cmd:unemp} {it:unempvar} [{it:weights}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}] , {cmdab:hid:}{it:(hidvar)}  [ {cmdab:hs:ize}{it:(hsizevar)} {cmdab:th:ao}{it:(#)} {cmdab:f:ormat}{it:(%9.#f)}
{cmdab:g:amma}{it:(# [# ...])} {cmdab:a:lpha}{it:(# [# ...])}
{cmdab:gen:erate}{it:(newvar)} {cmdab:dec:omp} ]

{p 4 4 2} {cmd:fweights}, {cmd:aweights} and {cmd:iweights} are allowed; see {help weights}.

{title:Description}

{p 4 4 2}
{cmd:unemp} computes aggregate households' employment deprivation measures, which are sensitive to the distribution of employment among deprived households.

{p 4 4 2}
The program computes the family of FGT-type employment deprivation measures at the household level proposed in Gradín, Cantó, and Del Río (REHO 2014).

{p 4 4 2}
The measure first computes indices of employment deprivation for each household based on individual information on either unemployment (a dummy variable: 1 if unemployed, 0 if employed), 
or underemployment (a continuous variable; i.e. relative gap in hours worked with respect to whished hours, ranging between 0 and 1).

{p 8 8 2}
Households deprivation indices can be saved as new variables using {cmdab:gen}{it:(newvar)} with _subscripts indicating the value of gamma
(i.e. with {cmdab:gen(u)}, u_0, u_1, u_2... are created standing for household deprivation index for gamma=0, 1, 2 ...).
This could be useful to further analyze their distribution drawing kernel densities (see {help akdensity} if installed) 
or computing "employment deprivation curves" (similar to TIP curves in poverty analysis) (using {help glcurve} if installed).

{p 4 4 2}
In a second step, the program aggregates households' employment deprivation indices across the entire target population in order to obtain a distribution-sensitive aggregate index of households' deprivation in employment.

{p 8 4 2}
By default, the aggregate index weights households by the number of economically active members (units are individuals) such as in official unemployment rates.

{p 8 4 2}
It is possible to weight each household by the number of members (whether in the labor force or not) or any other household-level variable using the {cmdab:hs:ize} option. See examples below.

{p 4 4 2}
By default, a household is considered to be deprived in employment if any member has a positive gap (i.e. is unemployed or underemployed).
For restricting deprived households to be only those having a deprivation level (proportion of unemployed members or of hours, depending on how the gap was measured) greater than a given threshold (i.e .20, .50, ...),
use option {cmdab:th:ao}{it:(#)}, the default is {cmdab:th:ao}{it:(0)}. If {cmdab:th:ao}{it:(1)}, only households with all their members fully deprived contribute to aggregate deprivation.

{title:Data requirements}

{p 4 4 2}
Microdata are required with observations being individuals in the labor force (economically active). Information identiying the households they belong to is necessary too. {it:unempvar} is a variable containing individual unemployment gaps that can be either a dummy variable (1 if unemployed, 0 if employed)
or a continuous variable between 0 and 1 (i.e. indicating the relative gap in hours worked with respect to whished hours).
{it:hidvar} is the household identifier. Observations can be weighted by the number of households members (see example below). Individuals with missing values in {it:unempvar} or {it:hidvar} will not be used in calculations.

{title:Reporting}

{p 4 4 2}
* Aggregate measure of households' employment deprivation U() for the specified values of the parameters:

{p 8 8 2}
. gamma, for one or more nonnegative integer numbers (0, 1,2 3,...) specified in option {cmdab:g:amma}{it:(integer [integer ...])}, the default is to report gamma=0,1,2.

{p 12 12 2}
If {it:unempvar} is a dummy, the index does not vary with gamma, thus {cmdab:g:amma}{it:(1)} is recommended.

{p 12 12 2}
This parameter captures the sensitivity of household-level deprivation indices to variability of employment gaps across their members.

{p 8 8 2}
. alpha, for one or more nonnegative integer numbers specified in option {cmdab:a:lpha}{it:(integer [integer ...])}, the default is to report alpha=0,1,2.

{p 12 12 2}
This parameter captures the sensitivity of the aggregate measure of households deprivation in employment to inequality of employment indices among deprived households.

{p 4 4 2}
* If option {cmdab:dec:omp} is specified, the decomposition of the aggregate indices into deprivation incidence, intensity and inequality of employment among the deprived households is also reported.

{title:Required Option}

{p 4 8 2}
{cmdab:hid:}{it:(hidvar)} to indicate household identifier.


{title:Other Options}

{p 4 8 2}
{cmdab:g:amma}{it:(integer [integer ...])} to indicate the values of gamma, the default is {cmdab:g:amma}{it:(0 1 2)}.

{p 4 8 2}
{cmdab:a:lpha}{it:(integer [integer ...])} to indicate the values of alpha, the default is {cmdab:a:lpha}{it:(0 1 2)}.

{p 4 8 2}
{cmdab:th:ao}{it:(#)} to set the threshold in employement deprivation (real value between 0 and 1). For thao<1, only those households with a deprivation (for gamma=1) larger than the threshold will be considered deprived in employment. For thao=1,
only fully deprived households are considered depived.
The default is {cmdab:th:ao}{it:(0)} (i.e. a household with u_1>0 is considered deprived).

{p 4 8 2}
{cmdab:gen:erate}{it:(newvar)} to create new variables containing households' employment deprivation indices for different values of gamma. 
If this option is combined with {cmdab:hs:ize}, the variables created only take values for one observation per-household.

{p 4 8 2}
{cmdab:dec:omp} to make the general decompoistion of the index for each aplha into incidence, intensity (alpha>0) and inequality (alpha>1) among deprived households.
It also computes the variance of individual households deprivation indices (u) and the  coefficient of variation for 1-u in the case of alpha=2.

{p 4 8 2}
{cmdab:f:ormat}{it:(%9.#f)} to change numeric format, the default is {cmdab:f:ormat}{it:(%9.4f)}.

{p 4 8 2}
{cmdab:hs:ize}{it:(hsizevar)} to weight each household according to {it:(hsizevar)}. {it:(hsizevar)} might be the number of household members. If {it:hsizevar} is the same for all households, then the aggregate measure weights each household equally, regardless of their size.

{title:Saved results}

{p 4 4 2}
Matrices:

{p 8 8 2}
r(unemp): aggregate employment deprivation measure, and main decomposition if option {cmdab:dec:omp} specified

{p 8 8 2} 
r(dec2): alternative decomposition for alpha=2 if option  {cmdab:dec:omp} specified

{p 4 4 2}
Scalars:

{p 8 8 2}
r(U_i_j): aggregate employment deprivation measures U() for gamma=i and alpha=j.

{title:Inference}

{p 4 4 2}
It is possible to obtain bootstrap standard errors with {cmd:unemp} using the returned scalars (see example below).

{title:Examples}

{p 4 8 2}
. {stata use unemp.dta, clear }

{p 4 8 2}
. {stata desc}

{p 4 8 2}
1. Households are weighted according to the number of people in the labor force:

{p 8 8 2}
With a dummy indicating unemployment status (the index does not vary with gamma, only gamma=1 requested)

{p 4 8 2}
. {stata unemp unemployed [aw=w] , hid(hid) gamma(1) }

{p 8 8 2}
With a variable indicating gap in hours, e.g. (whished-worked)/whished

{p 4 8 2}
. {stata unemp hgap [aw=w] , hid(hid) }

{p 8 8 2}
Saved results

{p 4 8 2}
. {stata ret list}

{p 4 8 2}
2. Households are equally weighted regardless of their size

{p 4 8 2}
. {stata gen hs=1 }

{p 4 8 2}
. {stata unemp hgap [aw=w], hid(hid) hs(hs) }

{p 4 8 2}
3. Households are weighted according to their household size (i.e. including non economically active members)

{p 4 8 2}
. {stata unemp hgap [aw=w], hid(hid) hs(hsize) }


{p 4 8 2}
Generating household employment deprivation index

{p 4 8 2}
. {stata unemp hgap [aw=w] , hid(hid) hs(hsize) gen(u) }

{p 4 8 2}
. {stata desc u_*}

{p 4 8 2}
Computing employment deprivation curve (gamma=2) across the population of households with at leat one member in the labor force (including members not in the labor force)[ {help glcurve} must be installed]

{p 4 8 2}
. {stata gen mu_2=-u_2}

{p 4 8 2}
. {stata glcurve u_2 [aw=w*hsize] , sort(mu_2)}

{p 4 8 2}
Estimating the density of household employment deprivation indices (gamma=1) across the target population [ {help akdensity}  must be installed]

{p 4 8 2}
. {stata akdensity u_1 if u_1>0 [aw=w*hsize], at(u_1)}

{p 4 8 2}
Changing default values of the parameters

{p 4 8 2}
. {stata unemp hgap [aw=w] if country==1, hid(hid) hs(hsize) th(.2) gamma(0 1 2 3) alpha(1 2 3 4) }

{p 4 8 2}
Specific rates:

{p 4 8 2}
Standard unemployment rate

{p 4 8 2}
. {stata unemp unemployed [aw=w], hid(hid) g(1) a(1) }

{p 4 8 2}
Unemployment rate of households heads (% households)

{p 4 8 2}
. {stata unemp unemployed [aw=w] if head==1 , hid(hid) g(1) a(1) }

{p 4 8 2}
Proportion of people whose household head is unemployed

{p 4 8 2}
. {stata unemp unemployed [aw=w] if head==1 , hid(hid) hs(hsize) g(1) a(1)  }

{p 4 8 2}
Proportion of households with all economically active members unemployed

{p 4 8 2}
. {stata unemp unemployed [aw=w], hid(hid) hs(hs) thao(1) g(1) a(1) }

{p 4 8 2}
Proportion of people in households with all economically active members unemployed

{p 4 8 2}
. {stata unemp unemployed [aw=w], hid(hid) hs(hsize) thao(1) g(1) a(1) }

{p 4 8 2}
Decomposition

{p 4 8 2}
. {stata unemp hgap [aw=w], hid(hid) hs(hsize) decomp}

{p 4 8 2}
Bootstrapping U(), exmaple for alpha=2, gamma=0,1,2 [BC estimates for Confidence Interval]

{p 8 8 2}
cap program drop hhu

{p 8 8 2}
program def hhu

{p 8 8 2}
unemp hgap [aw=w], hid(hid) hs(hsize)

{p 8 8 2}
end

{p 8 8 2}
bootstrap r(U_0_2) r(U_1_2) r(U_2_2) if country==1, reps(10): hhu

{p 8 8 2}
estat bootstrap

{title:Author}


{p 4 4 2}{browse "http://webs.uvigo.es/cgradin": Carlos Gradín}
<cgradin@uvigo.es>{break}
Facultade de CC. Económicas{break}
Universidade de Vigo{break}
36310 Vigo, Galicia, Spain.

{title:References}

{p 4 8 2}
Gradín, C, Cantó, O., and Del Río, C.(2014), Measuring employment deprivation in the EU using a household-level index, Review of the Economics of the Household.

{title:Also see}

{p 4 13 2}
{help akdensity} if installed; ; {help glcurve} if installed

	