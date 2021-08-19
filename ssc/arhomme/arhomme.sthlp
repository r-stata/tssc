{smcl}
{* *! version 1.0.0  30jan2020 author: }{...}
{vieweralsosee "[R] heckman" "mansection R heckman"}{...}
{vieweralsosee "[R] probit" "mansection R probit"}{...}
{vieweralsosee "[R] qreg" "mansection R qreg"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] heckman" "help heckman"}{...}
{vieweralsosee "[R] probit" "help probit"}{...}
{vieweralsosee "[R] qreg" "help qreg"}{...}
{viewerjumpto "Syntax" "arhomme##syntax"}{...}
{viewerjumpto "Description" "arhomme##description"}{...}
{viewerjumpto "Link to Stata Journal publication" "arhomme##linkspdf"}{...}
{viewerjumpto "Options for Arellano-Bonhomme selection model" "arhomme##options"}{...}
{viewerjumpto "Remarks" "arhomme##remarks"}{...}
{viewerjumpto "Examples" "arhomme##examples"}{...}
{viewerjumpto "Stored results" "arhomme##results"}{...}
{viewerjumpto "Reference" "arhomme##reference"}{...}
{p2colset 1 16 18 2}{...}
{p2col:{bf:arhomme} {hline 2}}Arellano and Bonhomme (2017) quantile selection model (by Martin Biewen and Pascal Erhardt, 2020){p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang}Basic syntax

{p 8 16 2}{cmd:arhomme} {depvar} {indepvars}{cmd:,} 
      {opth sel:ect(varlist:varlist_s)}

      or

{p 8 16 2}{cmd:arhomme} {depvar} {indepvars}{cmd:,} 
      {cmdab:sel:ect(}{cmd:=}
                    {it:{help varlist:varlist_s}}{cmd:)}

      or

{p 8 16 2}{cmd:arhomme} {depvar} {indepvars}{cmd:,} 
      {cmdab:sel:ect(}{it:{help depvar:depvar_s}} {cmd:=}
                    {it:{help varlist:varlist_s}}{cmd:)}


{phang}Full syntax for Arellano and Bonhomme's selection corrected quantile estimation

{p 8 16 2}{cmd:arhomme} {depvar} [{indepvars}] {ifin}
[{it:{help arhomme##weight:weight}}]{cmd:,} 
    {opt sel:ect}{cmd:(}[[{it:{help depvar:depvar_s}}] {cmd:=}]
    {it:{help varlist:varlist_s}}]{cmd:)} 
    [{it:{help arhomme##arhomme_options:options}}]


{synoptset 28 tabbed}{...}
{marker arhomme_options}{...}
{synopthdr :options}
{synoptline}
{syntab :Selection}
{p2coldent :* {opt sel:ect()}}specify selection equation: dependent and independent variables{p_end}

{syntab :Grid Tuning}
{synopt :{opt rho:points(#)}}defines the number of candidate points for the copula parameter grid search; default is {cmd:rhopoints(19)}{p_end}
{synopt :{opt tau:points(#)}}sets number of quantiles used to approximate the objective function; default is {cmd:taupoints(3)}{p_end}
{synopt :{opt mesh:size(#)}}grid scale parameter; default is {cmd:meshsize(1)}{p_end}
{synopt :{opt cent:ergrid(#)}}determines emphasis # of grid search; default is {cmd:centergrid(0)} for {cmd:frank} and {cmd:gaussian}, {cmd:centergrid(1)} for {cmd:plackett} and {cmd:joema}{p_end}
{synopt :{opt fra:nk}}Frank copula model; the default{p_end}
{synopt :{opt gau:ssian}}Gaussian copula model{p_end}
{synopt :{opt plack:ett}}Plackett copula model{p_end}
{synopt :{opt joe:ma}}Joe & Ma (2000) copula model{p_end}

{syntab :Standard Errors/Subsampling}
{synopt :{opt nostd:errors}}disables standard error computation; computes point estimates only{p_end}
{synopt :{opt sub:sample(#)}}specifies sample size for m-out-of-n bootstrap; default is entire sample size n, i.e. conventional bootstrap{p_end}
{synopt :{opt rep:etitions(#)}}perform # bootstrap replications, default is {cmd:repetitions(100)}{p_end}
{synopt :{opt fill:fraction(#)}}allow for up to a fraction of # of bootstrap replications to be replaced because of failed convergence, default is {cmd:fillfraction(.3)}{p_end}

{syntab :Instrument/Copula parameter}
{synopt :{opt instr:ument(varname)}}sets a user defined instrument to estimate the copula parameter; default is propensity score from first stage probit model{p_end}
{synopt :{opt cop:ulaparameter(varname)}}defines pre-estimated copula parameter values per observation; allowed only in combination with option {cmd:nostderrors}{p_end}

{syntab :Reporting}
{synopt :{opt q:uantiles(#[#[# ...]])}}estimates # quantiles; default is {cmd:quantiles(.1(.1).9)}{p_end}
{synopt :{opt gra:ph}}prints graph of objective function to the output window; by default disabled{p_end}
{synopt :{opt out:put([normal][bootstrap])}}specifies whether the output table is based on asymptotic (normal) or bootstrap distribution; default is normal distribution{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
* {opt select()} is required. The full specification is{break}
{opt sel:ect}{cmd:(}[[{it:depvar_s}] {cmd:=}] {it:varlist_s}{cmd:)}{p_end}

{p 4 6 2}{it:indepvars} must contain at least one valid variable name{p_end}
{marker weight}{...}
{phang}{cmd:arhomme} allows {cmd:pweight}s; see {help weight}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:arhomme} fits a conditional quantile regression in the presence of sample selection
using the method of Arellano and Bonhomme (2017).
Standard errors are computed by bootstrap or m-out-of-n bootstrap (a subsampling method, see Politis, Romano and Wolf, 1999).


{marker linkspdf}{...}
{title:Links to PDF documentation}

{pstd}
{it:link to Stata journal publication goes... }{bf:here}.
        
{pstd}
Some contents from publication above are not included in this help file.


{marker options}{...}
{title:Options for Arellano-Bonhomme selection model}

{dlgtab:Selection}

{phang}
{cmd:select(}[[{it:{help depvar:depvar_s}}] {cmd:=}] {it:{help varlist:varlist_s}}{cmd:)}
specifies the variables and options for the selection
equation.  It is an integral part of specifying the Arellano and Bonhomme (2017) model and is
required.  The selection equation must contain at least one variable that is
not in the outcome equation (exclusion restriction).

{pmore}
If {it:depvar_s} is specified, it should be coded as 0 or 1, with
0 indicating an observation not selected and 1 indicating a selected
observation.  If {it:depvar_s} is not specified, observations for which
{it:depvar} is not missing are assumed selected, and those for which
{it:depvar} is missing are assumed not selected.

{dlgtab:Grid Tuning}

{phang}
{opt rhopoints(#)} [{it:integer}] determines the number of candidate points for the copula parameter grid search. When option {cmd:frank} is chosen, the
copula candidate values are constructed as follows. First, the unit interval is divided into
(# + 1) equidistant intervals. Then, the i-th candidate is defined as the i-th quantile of a
Cauchy distribution with scale {cmd:meshsize} and shift {cmd:centergrid}. With option {cmd:gaussian} the quantiles of a
sinus density with emphasis {cmd:centergrid} and range {cmd:meshsize}*(1-|{cmd:centergrid}|) are 
built. The grid for the copula options {cmd:plackett} and {cmd:joema} is designed as the square root of the i-th
unit interval point divided by 1 minus this point.  This method ensures that the resulting grid is more dense around {cmd:centergrid}. The user can shift
the focus of grid search by specifying the desired {cmd:centergrid}, by reducing (increasing) {cmd:meshsize} or
by increasing (reducing) {cmd:rhopoints}. Note that the default {cmd:rhopoints(19)} is likely to be too small for
many applications.

{phang}
{opt taupoints(#)} [{it:integer}] specifies the number of quantiles for which the moment restriction is supposed to hold.
It is recommended to use this option in connection with {cmd:graph}. The resulting scatter plot
should suggest a smooth objective function (at least around the gravity center of search; sometimes
the objective function tends to be erratic towards outer values no matter how many {cmd:taupoints} are employed).
Increase {cmd:taupoints} to further smooth the objective function. The default {cmd:taupoints(3)} is a good start
in many applications, but a larger number of {cmd:taupoints} is recommended for more reliable estimates.

{phang}
{opt meshsize(#)} [{it:real}] scales the grid search interval up(down). For large # the resulting grid
becomes less dense but searches a wider range. # is restricted to strictly positive real values for
options {cmd:frank}, {cmd:plackett}, {cmd:joema} and restricted to (0,1] when using {cmd:gaussian}. The default {cmd:meshsize(1)} tends to be
a good start.

{phang}
{opt centergrid(#)} [{it:real}] sets the gravity center of the grid. If you already suspect the optimal copula
parameter to be a specific value, this option helps shifting the emphasis of your search. # is
restricted to (-1,1) with {cmd:gaussian} and to the positive real line for {cmd:plackett} and {cmd:joema}, and
 unrestricted with {cmd:frank}.
If left unspecified, the grid will always be symmetric about the independence copula, i.e. {cmd:centergrid(0)}
for {cmd:frank} and {cmd:gaussian}, and {cmd:centergrid(1)} for {cmd:plackett} and {cmd:joema}.

{phang}
{opt frank} specifies the Frank copula to model individually rotated quantiles. The copula parameter takes values on the entire real line, 
with rho -> -infinity corresponding to the lower Fréchet-Hoeffding bound, rho=0 to the independence copula, 
and rho -> +infinity to the upper Fréchet-Hoeffding bound.

{phang}
{opt gaussian} specifies the Gaussian copula to model individually rotated quantiles. The copula parameter takes values on the interval (-1,1), 
with rho -> -1 corresponding to the lower Fréchet-Hoeffding bound, rho=0 the independence copula, 
and rho -> +1 equal to the upper Fréchet-Hoeffding bound.

{phang}
{opt plackett} specifies the Plackett copula to model individually rotated quantiles. The copula parameter takes values on the positive real line, 
with rho -> 0 corresponding to the lower Fréchet-Hoeffding bound, rho=1 to the independence copula, 
and rho -> +infinity  to the upper Fréchet-Hoeffding bound. 
If standard errors are computed, the copula parameter is tested for rho=1 instead of rho=0. The p-value is reported accordingly.

{phang}
{opt joema} specifies the Joe and Ma (2000) copula to model individually rotated quantiles. The copula parameter takes values on the positive real line, 
with rho -> 0 corresponding to the lower Fréchet-Hoeffding bound, rho=1 to the independence copula, 
and rho -> +infinity to the upper Fréchet-Hoeffding bound.
If standard errors are computed, the copula parameter is tested for rho=1 instead of rho=0. The p-value is reported accordingly.

{dlgtab:Standard Errors/Subsampling}

{phang}
{opt nostderrors} disables the computation of standard errors. This option precludes the use of {cmd:subsample(#)} and {cmd:repetitions(#)}.

{phang}
{opt subsample(#)} [{it:integer}] draws samples of size # with replacement from the marked dataset. Standard errors
are computed by the m-out-of-n bootstrap method. If # is greater than or equal to the effective size of the entire
dataset the conventional bootstrap is executed.

{phang}
{opt repetitions(#)} [{it:integer}]  specifies the number of bootstrap replications to be used to obtain an estimate
of the variance-covariance matrix of the estimators. {cmd:repetitions(100)} is 
the default, which is likely to be too small in many applications.

{phang}
{opt fillfraction(#)} [{it:real}] determines up to which fraction of overall bootstrap repetitions the program replaces
subsamples in case of failed convergence. If this limit is reached, further failed subsamples are dropped without being replaced. {cmd:fillfraction(.3)} is 
the default.

{dlgtab:Instrument/Copula parameter}

{phang}
{opt instrument(varname)} [{it:numeric}] lets the user define a variable which serves as the instrument
varphi to estimate the copula parameter (equation (15) in Arrellano and Bonhomme, 2017). 
The instrument has to be a function of {it:varlist_s}. The default is the propensity score.

{phang}
{opt copulaparameter(varname)} [{it:numeric}] indicates that the copula parameter has already been estimated by the user
(for example, separately by sample subgroups in a first stage) and stored per observation in the variable {it: varname}. In this case, only step 3 of 
Arrellano and Bonhomme (2017) is performed (estimation of the selection corrected quantile coefficients).
The values in  {it: varname} are restricted to (-1,1) with option {cmd:gaussian}, to the
positive real line for {cmd:plackett} and {cmd:joema}, and unrestricted for {cmd:frank}. This option must be used in connection with {cmd:nostderrors} and 
precludes the use of {cmd:rhopoints(#)}, {cmd:taupoints(#)}, {cmd:meshsize(#)}, {cmd:centergrid(#)}, {cmd:subsample(#)}, {cmd:repetitions(#)}, {cmd:instrument}, and {cmd:graph}.
The reason is that the user will have to code her own bootstrap procedure including all the different stages of her estimations (e.g., using {cmd:bootstrap}). It is only in this way that
the sampling variability of the pre-estimated copula parameters is accounted for.


{marker Reporting}{...}
{dlgtab:Reporting}

{phang}
{opt quantiles(#)} [{it:numlist}] specifies the quantiles to be estimated. Valid inputs range from 0 to 1, exclusively, and in ascending order. The default values of 0.1(0.1)0.9 correspond to all deciles.

{phang}
{opt graph} specifies that a scatter plot of all objective function values is automatically generated after estimation.

{phang}
{opt output([normal] [bootstrap])} defines whether the output table generated is based on the asymptotic, i.e. normal, or the bootstrap distribution. If both are specified, two separate output tables are produced.
Note that  the first stage (probit) standard errors in the output are always asymptotic (coming from the default {opt probit} command). {cmd:repetitions} should be set to at least
500 when choosing {cmd:output(bootstrap)}. If both {it: normal} and {it: bootstrap} are specified, then results based on the normal distribution are reported first.

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:arhomme} estimates gamma, b(U) and rho in the model:

{pin}({it:U}-th conditional quantile regression equation: Y is {it:depvar}, X is {it:varlist}){p_end}
{pin}Y* = Xb(U)

{pin}(selection equation: Z is {it:varlist_s} and D {it:depvar_s}){p_end}
{pin}D=1(V<p(Z)){p_end}
{pin}Y=Y* only observed if D=1{p_end}

{pin}(distributional assumptions){p_end}
{pin}P[D=1|Z=z] = N(Z'gamma) (probit model){p_end}

{pin}U,V jointly uniform ~ C_{c -(}U,V|X{c )-}(u,v;rho) independent of Z{p_end}
{pin}with C_{c -(}U,V|X{c )-}(u,v;rho) specified by choice of {it:copula}{p_end}

{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse womenwk}{p_end}

{pstd}Obtain Arellano-Bonhomme's selection corrected estimates{p_end}
{phang2}{cmd:. arhomme wage education age, select(married children education age) nostd quantiles(.25 .5 .75)}

{pstd}Define and use each equation separately{p_end}
{phang2}{cmd:. global wage_eqn wage education age}{p_end}
{phang2}{cmd:. global seleqn married children education age}{p_end}
{phang2}{cmd:. arhomme $wage_eqn, select($seleqn) quantiles(.25 .5 .75)}

{pstd}Use a variable to identify selection{p_end}
{phang2}{cmd:. generate works = (wage < .)}{p_end}
{phang2}{cmd:. arhomme $wage_eqn, select(works = $seleqn) quantiles(.25 .5 .75)}

{pstd}Tune grid settings{p_end}
{phang2}{cmd:. arhomme $wage_eqn, select(works = $seleqn) centergrid(-2) meshsize(.8) taupoints(2) rhopoints(39) quantiles(.25 .5 .75)}{p_end}

{pstd}Switch to Gaussian copula{p_end}
{phang2}{cmd:. arhomme $wage_eqn, select(works = $seleqn) gaussian quantiles(.2(.2).8) }{p_end}

{pstd}Reduce subsample size{p_end}
{phang2}{cmd:. arhomme $wage_eqn, select(works = $seleqn) repetitions(250) subsample(500)}

{pstd}Generate objective function graph{p_end}
{phang2}{cmd:. arhomme $wage_eqn, select(works = $seleqn) centergrid(-5) graph quantiles(.5) nostd}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:arhomme} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(sN)}}number of selected observations{p_end}
{synopt:{cmd:e(rho)}}estimated copula parameter{p_end}
{synopt:{cmd:e(Vrho)}}estimated variance of copula parameter{p_end}
{synopt:{cmd:e(meshsize)}}measure of grid density{p_end}
{synopt:{cmd:e(centergrid)}}emphasis of grid search{p_end}
{synopt:{cmd:e(rhopts)}}number of rhopoints{p_end}
{synopt:{cmd:e(taupts)}}number of taupoints{p_end}
{synopt:{cmd:e(minFval)}}minimum of objective function{p_end}
{synopt:{cmd:e(subsample)}}size of subsamples{p_end}
{synopt:{cmd:e(repetitions)}}number of bootstrap repetitions{p_end}
{synopt:{cmd:e(spearman)}}Spearman's rank correlation{p_end}
{synopt:{cmd:e(kendall)}}Kendall's tau{p_end}
{synopt:{cmd:e(blomqvist)}}Bomqvist's beta {p_end}
{synopt:{cmd:e(fillfrac)}}fraction of maximally replaced subsamples{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:arhomme}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(instrument)}}instrument expression{p_end}
{synopt:{cmd:e(cparameter)}}copula parameter expression{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(pvals)}}p-values of test for significance based on bootstrap distribution{p_end}
{synopt:{cmd:e(confivals)}}confidence intervals of test for significance based on bootstrap distribution{p_end}
{synopt:{cmd:e(bbetas)}}estimated quantile coefficients (column) of each bootstrap replication (row){p_end}
{synopt:{cmd:e(sbetas)}}e(bbetas) where each row is sorted in ascending order{p_end}



{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{marker reference}{...}
{title:References}

{marker AB2017}{...}
{phang}
Arellano, M. and Bonhomme, S. 2017.
Quantile Selection Models with an application to understanding changes in wage inequality.
{it:Econometrica} 85(1): 1-28.
{p_end}

{marker Joe14}{...}
{phang}
Joe, H. 2014.
{it: Dependence modelling with copulas}. New York: Chapman and Hall/CRC.
{p_end}

{marker JoeMa}{...}
{phang}
Joe, H. & Ma, C. 2000.
Multivariate survival functions with a min-stable property.
{it:Journal of Multivariate Analysis} 75: 13-35.
{p_end}

{marker Pol}{...}
{phang}
Politis, D.N., J.P. Romano, M. Wolf, 2014.
{it: Subsampling}. Heidelberg/New York: Springer.
{p_end}
