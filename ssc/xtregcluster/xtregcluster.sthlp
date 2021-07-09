{smcl}
{* *! version 1.0.0  24Feb2016}{...}
{vieweralsosee "[XT] xtreg" "help xtreg"}{...}
{vieweralsosee "[XT] xtset" "help xtset"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[MV] cluster kmeans" "help cluster kmeans"}{...}
{viewerjumpto "Syntax" "xtregcluster##syntax"}{...}
{viewerjumpto "Initial partition" "xtregcluster##initpartition"}{...}
{viewerjumpto "Description" "xtregcluster##description"}{...}
{viewerjumpto "Options" "xtregcluster##options"}{...}
{viewerjumpto "Examples" "xtregcluster##examples"}{...}
{viewerjumpto "Saved results" "xtregcluster##results"}{...}
{viewerjumpto "References" "xtregcluster##references"}{...}
{viewerjumpto "Authors" "xtregcluster##authors"}{...}
{viewerjumpto "Acknowledgments" "xtregcluster##acknowledgments"}{...}

{cmd:help xtregcluster}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{pstd}{cmd:xtregcluster} {hline 2} Partially heterogeneous linear panel data with fixed effects{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:xtregcluster} {depvar} {indepvars}  {ifin}  {weight}{cmd:,} {opt omega(#)} {it:initpartition} [{it:options}]


{marker initpartition}{...}
{synoptset 24 tabbed}{...}
{synopthdr :initpartition}
{synoptline}

{phang}You must specify one of the following methods for obtaining the initial partition:

{synopt :{opt random}}obtain the initial partition through
uniform random selection{p_end}

{synopt :{opth preclass(varname)}}obtain the initial partition on the
basis of one categorical variable. {opt omega(#)} is not allowed
with {opth preclass(varname)} as the levels of {opt {varname}}
determine the size of Omega{p_end}

{synopt :{opth prevars(varlist)}}obtain the initial partition on the basis
of pre-specified variables using the Calinski-Harabasz clustering criterion
from {stata "help cluster kmeans":cluster kmeans}.
{opth prevars(varlist)} takes a specific list of covariates which may
include variables specified in {opt {indepvars}} or not.
Special cases include {opt prevars(X)} for using all explanatory variables
as specified in {opt {varlist}}, and {opt prevars(b)} for using the individual
specific slopes.{p_end}

{synopt :{opt prevarsopt(kmeansopt)}}can only be specified with {opt prevars(varlist)}
and takes all options from {stata "help cluster kmeans":cluster kmeans} with the sole
exception of {opt k(#)} which is already set by the option {opt omega(#)}.

{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:xtregcluster} operationalises the Sarafidis and Weber (2015) estimator for
classifying individuals into clusters with homogeneous slope parameters
and the intra-cluster heterogeneity being attributed to unobserved fixed effects.
The method is available for linear short panel data and is useful for exploring
data in the absence of knowledge about parameter structures. It is also useful
for confirming parameter homogeneity and examining the validity of normatively
imposed classifications.

{marker options}{...}
{title:Options}

{marker Method_options}{...}
{dlgtab:Method options}

{synopt :* {opt omega(#)}}{opt omega(#)} is required. It specifies the size of Omega > 1.
{opt omega(#)} takes integer arguments.{p_end}

{synopt :{opt theta(#)}}specifies the theta given N in the penalty function of the MIC
for overfitting Omega. The default is {opt theta((1/3)*ln(N)+(2/3)*sqrt(N)))}.
{opt theta()} can take any other real argument. Other typical theta include the
value of 2, ln(N) and sqrt(N){p_end}

{synopt :{opt seed(#)}}sets the random-number seed for the entire program.
The seed is relevant for randomizing the numerical panel identifiers, and for the
{opt random} method in obtaining the initial partition. The default is {opt seed(123)}.

{marker Iteration_options}{...}
{dlgtab:Iteration options}

{synopt :{opt iter:ate(#)}}specifies the maximum number of iterations for
minimizing the Total RSS given {opt omega(#)}. The default is {opt iterate(100)}{p_end}

{synopt :{opt tol:erance(#)}}specifies the tolerance for the convergence of Total RSS
given{opt omega(#)}. The default is {opt tolerance(1e-6)}{p_end}

{marker Reporting_options}{...}
{dlgtab:Reporting options}

{synopt :{opth name(varname)}}specifies the name for the newly generated variable
that identifies the levels in the optimized partition given Omega. The default
name is {opt omegas#}, where {opt #} is the number specified in {opt omega(#)}{p_end}

{synopt :{opt nolog}}supress RSS iteration log{p_end}

{synopt :{opt graph}}see clustered scatter plots with superimposed linear fits
for every omega{p_end}

{synopt :{opt table}}print a table of estimates for all linear panel data
fixed effects by omega, e.g. xtreg if omega==1, fe for the first omega,
and so on for the rest.
{synoptline}

{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{stata "use http://www.stata-press.com/data/r14/productivity.dta":. use http://www.stata-press.com/data/r14/productivity.dta}{p_end}
{phang2}{stata "xtset state year":. xtset state year}{p_end}
{phang2}{stata "global yx gsp private emp hwy water other unemp":. global yx gsp private emp hwy water other unemp}{p_end}

{pstd}Obtaining initial partition using random selection{p_end}
{phang2}{stata "xtregcluster $yx, random omega(2/10)":. xtregcluster $yx, random omega(2/10)}{p_end}
{phang2}{stata "xtregcluster $yx i.year, random omega(2/10) name(omT)":. xtregcluster $yx i.year, random omega(2/10) name(omT)}{p_end}
{phang2}{stata "xtregcluster $yx, random omega(4) name(om3) seed(456)":. xtregcluster $yx, random omega(4) name(om3) seed(456)}{p_end}

{pstd}Obtaining initial partition using predetermined categorical variables{p_end}
{phang2}{stata "xtregcluster $yx, preclass(region)":. xtregcluster $yx, preclass(region)}{p_end}
{phang2}{stata "tabulate region omega_region, all":. tabulate region omega_region, all}{p_end}

{pstd}Obtaining initial partition using prespecified variation in variables{p_end}
{phang2}{stata "xtregcluster $yx, prevars(gsp) omega(2/6) name(om_gsp)":. xtregcluster $yx, prevars(gsp) omega(2/6) name(om_gsp)}{p_end}
{phang2}{stata "xtregcluster $yx, prevars(hwy private) omega(2/6) name(omhp)":. xtregcluster $yx, prevars(hwy private) omega(2/6) name(omhp)}{p_end}
{phang2}{stata "xtregcluster $yx, prevars(X) omega(2/6) name(omX)":. xtregcluster $yx, prevars(X) omega(2/8) name(omX)}{p_end}

{pstd}Obtaining initial partition using prespecified variation in individual slopes{p_end}
{phang2}{stata "bysort state: generate Ti = _N":. bysort state: generate Ti = _N}{p_end}
{phang2}{stata "xtregcluster $yx if Ti>=7, prevars(b) omega(2/6) name(omb)":. xtregcluster $yx if Ti>=7, prevars(b) omega(2/6) name(omb)}{p_end}

{pstd}Stricter penalty for the MIC{p_end}
{phang2}{stata "egen tag = tag(state)":. egen tag = tag(state)}{p_end}
{phang2}{stata "quietly count if tag":. quietly count if tag}{p_end}
{phang2}{stata "scalar sqrtN = sqrt(r(N))":. scalar sqrtN = sqrt(r(N))}{p_end}
{phang2}{stata "xtregcluster $yx, random omega(2/10) name(omega_srict) theta(`=sqrtN')":. xtregcluster $yx, random omega(2/10) name(omega_srict) theta(`=sqrtN')}{p_end}

{pstd}Reporting and convergence options{p_end}
{phang2}{stata "drop omega*":. drop omega*}{p_end}
{phang2}{stata "xtregcluster $yx, random omega(2/5) nolog graph table":. xtregcluster $yx, random omega(2/5) nolog}{p_end}
{phang2}{stata "xtregcluster $yx, random omega(2/8) name(omtol) tolerance(0.01) iterate(50)":. xtregcluster $yx, random omega(2/8) name(omtol) tolerance(0.01) iterate(50)}{p_end}

{marker results}{...}
{title:Saved results}

{col 4}Scalars
{col 8}{cmd:e(N)}{col 27}N panels used in estimation
{col 8}{cmd:e(T)}{col 27}T or average Ti
{col 8}{cmd:e(NT)}{col 27}NT or NTi
{col 8}{cmd:e(rss_pool)}{col 27}Pooled RSS
{col 8}{cmd:e(mic_pool)}{col 27}Pooled MIC
{col 8}{cmd:e(omega)}{col 27}Specified Omega
{col 8}{cmd:e(theta)}{col 27}Specified theta
{col 8}{cmd:e(rss_tot)}{col 27}Total RSS given Omega
{col 8}{cmd:e(mic_tot)}{col 27}Total MIC given Omega

{col 4}Macros
{col 8}{cmd:e(cmdline)}{col 27}Estimator

{col 4}Matrices
{col 8}{cmd:e(rss)}{col 27}Total RSS at every iteration

{col 4}Functions
{col 8}{cmd:e(sample)}{col 27}Marks estimation sample


{marker references}{...}
{title:References}

{p 4 6 2}Christodoulou, D. and V. Sarafidis (20XX),
xtcluster: A partially heterogeneous framework for short panel data models,
{it:The Stata Journal}, Volume vv, Number ii, pp. xx-xx.

{p 4 6 2}Sarafidis, V. and N. Webber (2015),
A partially heterogeneous framework for analyzing panel data,
{it:Oxford Bulletin of Economics and Statistics}, Volume 77, Number 2, pp. 274-296.


{marker authors}{...}
{title:Authors}

{phang}{browse "http://sydney.edu.au/business/research/meafa/":Demetris Christodoulou}{p_end}
{phang}MEAFA Research Group{p_end}
{phang}The University of Sydney Business School{p_end}
{phang}Sydney, NSW 2006{p_end}
{phang}Australia{p_end}
{phang}{browse "mailto:demetris.christodoulou@sydney.edu.au":demetris.christodoulou@sydney.edu.au}{p_end}

{phang}{browse "https://www.monash.edu/research/people/profiles/profile.html?sid=1750605&pid=12161":Vasilis Sarafidis}{p_end}
{phang}Department of Econometrics and Business Statistics{p_end}
{phang}Monash University{p_end}
{phang}Melbourne, VIC 3145{p_end}
{phang}Australia{p_end}
{phang}{browse "mailto:Vasilis.Sarafidis@monash.edu":Vasilis.Sarafidis@monash.edu}{p_end}


{marker acknowledgments}{...}
{title:Acknowledgements}

{p 4 4 2}{cmd:xtregcluster} is not an official Stata command, it is a free
contribution to the research community. Please cite the respective
publication in The Stata Journal as provided just above. We acknowledge Karl Keesman's
input in the develoment of the first draft of the program.

