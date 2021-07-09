{smcl}
{* 24Sept2014}{...}
{cmd:help qregpd}
{hline}

{title:Title}

{p2colset 5 20 29 2}{...}
{p2col :{hi:qregpd} {hline 2}} Quantile Regression for Panel Data (QRPD){p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 15 2}
{cmd:qregpd}
{depvar} {indepvars} {ifin} {weight} {cmd:,}
[{opth q:uantile(#)}
 {opth instr:uments(varlist)}
 {opth id:entifier(varlist)}
 {opth fix(varlist)}
 {opth optimize(string)}
 {it:{help genqreg##mcmc_options:MCMC options}}
 {it:{help genqreg##grid_options:Grid-search options}}
 ]

{title:Description}

{pstd}
{cmd:qregpd} can be used to fit the quantile regression for panel data (QRPD) estimator developed 
in {browse "http://works.bepress.com/david_powell/1/":Powell (2015)}.
The estimator addresses a fundamental problem posed by alternative 
fixed-effect quantile estimators: inclusion of indiviudal fixed effects alters the interpretation of
the estimated coefficient on the treatment variable. As detailed in 
{browse "http://works.bepress.com/david_powell/4/":Powell (2016)}, the 
QRPD estimator is a special case of the generalized quantile estimator implemented by {cmd:genqreg}.

{pstd}
Numerical optimization proceeds via a Nelder-Mead algorithm. As estimation and calculation of 
standard errors can sometimes pose numerical challenges, 
the user can estimate generalized quantile regressions using
Markov Chain Monte Carlo methods or grid-search methods. 

{title:Syntax}

{pstd}
{cmd:genqreg} is invoked in the usual way - the command name, followed by the 
dependent variable, followed by control variables. One can then specify options after a comma. 

{title:Options}

{phang}
{opth q:uantile(#)} specifies the quantile to be estimated and should be a number between 0 and 1, exclusive.  
Numbers larger than 1 are interpreted as percentages.  The default value of 0.5 corresponds to the median.

{phang}
{opth instr:uments(varlist)} All exogenous explanitory variables and any addtional 
instrumental variables must be included in {opth instr:uments(varlist)}. If no variables 
are included in {opth instr:uments(varlist)}, then it is assumed all the RHS variables
are exogenous. 

{phang}
{opth id:entifier(varlist)} This option must be specified as it defines the unit of observation that
we observe over multiple time periods. Think of {opth id:entifier(varlist)}
as the {it:panelvar} in {help xtset:{bf:xtset}}.  "Time" is defined in {opth fix(varlist)}. 

{phang}
{opth fix(varlist)} This is the "time" fixed effect. Think of {opth fix(varlist)}
as the {it:timevar} in {help xtset:{bf:xtset}}.

{phang}
{opth optimize(string)} Three optimization techniques can be used to estimate {cmd:qregpd}:
Nelder-Mead (default), {it:{help genqreg##mcmc_options:adaptive MCMC}} and 
{it:{help genqreg##grid_options:Grid-search}}. 

{marker NM_options}{...}
{title:Nelder-Mead Options}

{pstd}
{opt nmsimplex(string)} A Stata matrix for the NM simplex. See {it:{help mf_moptimize##syn_technique:moptimize Nelder-Mead}}

{marker mcmc_options}{...}
{title:MCMC Options}

{pstd}
To use the adaptive MCMC optimization procedure specify {cmd:optimize(}{...}{cmd:"mcmc"}{cmd:)}.
For further help see {cmd:help mf_amcmc} if installed.

{pstd}
{opt draws(#)} tells the algorithm how many draws to perform

{pstd}
{opt burn(#)} tells the algorithm how many draws to drop as a burn-in period;
accordingly, the algorithm returns only the last {opt draws(#)}-{opt burn(#)} draws.

{pstd}
{opt arate(#)}  acceptance rates of the algorithm. Must be between 0 and 1. 
The default is 0.234.

{pstd}
{opt sampler(string)} a string scalar specifying the drawing scheme desired by the user.
{opt sampler("mwg")} is Metropolis-within-Gibbs sampling (each component of the function is sampled alone and in order). 
{opt sampler("global")} is global, all-at-once sampling (defualt).

{pstd}
{opt dampparm(#)} is an adjustment parameter telling the algorithm how agressively or conservatively to adapt the proposal distribution to achieve the
    acceptance rate specified by the user in {opt arate(#)}. {opt dampparm(#)} should lie between zero and one, with values closer to zero corresponding with slower
    adaptation, and values closer to one corresponding to more rapid adaptation to the proposal history. The defualt is 0.234.

{pstd}
{opt from(string)} initial parameter values EXCLUDING the constant. This must be a Stata matrix.
If left blank, starting values are from {cmd:qreg}.

{pstd}
{opt fromv:ariance(#)} initial covariance matrix EXCLUDING the constant. This must be a Stata matrix.
If left blank, starting values are from {cmd:qreg}.

{pstd}
{opt saving(string)} specifies a location to store the draws of the parameters. The file will contain just the draws after
any burn-in period or thinning of values is applied. 

{pstd}
{opt replace} specifies that an existing file is to be overwritten with parameter draws.

{pstd}
{opt append} specifies that an existing file is to be appended with parameter draws.

{pstd}
{opt thin(int)} specifies that only every #th draw is to be retained, so if {cmd:thin(3)} is specified, only every
third draw is retained. This option is designed to help ease autocorrelation in the resulting draws, as is the option
{cmd:jumble}, which randomly mixes draws. Both options may be applied.

{pstd}
{opt jumble} specifies that retained draws are to be jumbled. This helps reduce autocorrelation between draws.

{pstd}
{opt noisy} If specified, the algorithm produces feedback - each time the target distribution is evaluated, it produces a "." as output, while after 50 calls, it produces 
the value of the target distribution.

{pstd}
{opt usemax} By default, the mean of the MCMC draws are reported as the coefficient "estimates" to match Stata conventional output. 
By specifying the option {cmd:usemax}, the set of draws that correspond to the maximum objective function value are reported.

{pstd}
{opt analytic} By default, the variance of the MCMC draws are used to calculate the standard errors to match Stata conventional output.
By specifying the option {cmd:analytic}, analytic standard errors are reported (See, {browse "http://www.rand.org/pubs/working_papers/WR710-3.html":Powell (2014b)}).

{marker grid_options}{...}
{title:Grid-search Options}

{pstd}
To use the grid-search optimization procedure specify {cmd:optimize(}{...}{cmd:"grid"}{cmd:)}.
A maximum of two RHS variables may be used with the grid-search optimization procedure. 
As such, you will need to specify the minimum, maximum and interval for each variable's grid.

{pstd}
{opth grid1(numlist)} Grid for first independent variable. 

{pstd}
{opth grid2(numlist)} Grid for second independent variable.

{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Setup {p_end}
{phang2}{cmd:. webuse nlswork}{p_end}

{pstd}Robust quantile regression for panel data{p_end}
{phang2}{cmd:. qregpd ln_wage tenure union, id(idcode) fix(year)}{p_end}

{res}{txt}
{pstd}Same as above, but using MCMC methods{p_end}
{phang2}{cmd:. qregpd ln_wage tenure union, id(idcode) fix(year) optimize(mcmc) noisy draws(1000) burn(100) arate(.5)}{p_end}
{phang2}{cmd:. mat list e(gamma)} {p_end}

{res}{txt}
{pstd}Robust instrumental variable quantile regression for panel data. MCMC optimization.{p_end}
{phang2}{cmd}. qregpd ln_wage tenure union, id(idcode) fix(year)
			optimize(mcmc) noisy draws(1000) burn(100) arate(.5) 
			instruments(ttl_exp wks_work  union){p_end}
{phang2}{cmd:. mat list e(gamma)}{p_end}

{res}{txt}
{pstd}Robust instrumental variable quantile regression for panel data. Grid-search optimization.{p_end}
{phang2}{cmd}. qregpd ln_wage tenure union, id(idcode) fix(year) 
			optimize(grid) min1(0) max1(0.06) intvl1(0.005) min2(0.05) max2(0.1) intvl2(0.005) 
			instruments(ttl_exp wks_work  union) {p_end}
{phang2}{cmd}. mat list e(gamma) {p_end}
		
{res}{txt}	 
{title:Saved results}

{pstd}
{cmd:qregpd} saves the following in {cmd:e()}:{txt}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}{txt}number of observations{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}"qregpd"{p_end}
{synopt:{cmd:e(title)}}"Quantile Regression for Panel Data"{p_end}
{synopt:{cmd:e(indepvars)}} Righ-hand side variables {p_end}
{synopt:{cmd:e(depvar)}} Left-hand side variable {p_end}
{synopt:{cmd:e(gamma)}} Values on the gamma vector {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}Parameter values{p_end}
{synopt:{cmd:e(V)}}Variance-covariance matrix of parameters{p_end}
{synopt:{cmd:e(solutions)}}Parameter values from grid search; may contain multiple solutions.{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}
		
{title:Reference}

{phang}{browse "http://works.bepress.com/david_powell/1/" :Powell, David. 2015.}
Quantile Regression with Nonadditive Fixed Effects. 
{it:RAND Labor and Population Working Paper}.{p_end}

{phang}{browse "http://works.bepress.com/david_powell/4/" :Powell, David. 2016.} 
Quantile Treatment Effects in the Presence of Covariates. {it:RAND Labor and Population Working Paper}.{p_end} 

{phang}{browse "http://www.rand.org/pubs/working_papers/WR710-3.html" :Powell, David. 2014b.} 
Did the Economic Stimulus Payments of 2008 Reduce Labor Supply? 
Evidence from Quantile Panel Data Estimation. 
{it:RAND Labor and Population Working Paper 710-3}. 

{title:Authors}

{phang}This command was written by Matthew J. Baker (matthew.baker@hunter.cuny.edu), David Powell (dpowell@rand.org), and Travis Smith
(tasmith@uga.edu). Comments, criticisms, and suggestions for improvement are welcome. {p_end}

{title:Also see}

{psee}
Manual: {help qreg:{bf:quantile}} 

{psee}
Other: Generalized Quantile Regression (GQR), if installed:
{help genqreg:{bf:genqreg}} 
