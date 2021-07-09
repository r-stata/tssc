{smcl}
{* documented: April 14, 2009}{...}
{* revised: July 10, 2009}{...}
{cmd:help mtreatreg}{right:also see:  {help mtreatreg postestimation}}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col:{hi:mtreatreg} {hline 2}}Multinomial treatment effects model{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:mtreatreg}
{depvar}
[{indepvars}]
{ifin}
{weight}{cmd:,}
{cmdab:mtreat:ment(}{it:depvar_mt} {cmd:=} {it:indepvars_mt}{cmd:)}
{cmdab:sim:ulationdraws(}{it:#}{cmd:)} 
{cmdab:den:sity(}{it:{help mtreatreg##densityname:densityname}}{cmd:)}
[{it:{help mtreatreg##options:options}}]

{marker options}{...}
{synoptset 26 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Model}
{synopt :{opt mtreat:ment(string)}}{it:string} is specified as depvar_mt = indepvars_mt.  
It is required.{p_end}
{synopt :{opt sim:ulationdraws(#)}}number of simulation draws per observation.  
It is required.{p_end}
{synopt :{opth den:sity(mtreatreg##densityname:densityname)}}distribution of 
{depvar}.  It is required.{p_end}
{synopt :{cmdab:pre:fix(string)}}prefix for the indicator variables created 
	from the multinomial treatment variable.  The default is a set of 
	indicator variables starting with _T. {p_end}
{synopt:{cmdab:const:raint(}{it:{help constraint}}{cmd:)}}apply specified linear constraints{p_end}

{syntab:SE/Robust}
{synopt:{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt r:obust},
	{opt opg}, {opt boot:strap} or {opt jack:knife}{p_end}
{synopt:{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}
{synopt:{opth cl:uster(varname)}}adjust standard errors for intragroup
	correlation{p_end}

{syntab:Reporting}
{synopt:{opt ver:bose}}report mixed multinomial logit treatment and exogenous 
	outcome regressions.{p_end}

{syntab :Quasi-random numbers}
{synopt :{opt facsc:ale(#)}}specifies the standard deviation of each of the
	quasi-random variables.  The default is 1.{p_end}
{synopt :{opt start:point(#)}}specifies the starting point in the
	Halton sequence from which the quasi-random variates are generated. 
	The default is 20.{p_end}

{syntab :Max options}
{synopt :{opt facfr:om(string)}}specifies the starting value 
	for the parameter associated with the latent factor.  The default 
	starting value is zero.{p_end}
{synopt :{it:{help mtreatreg##mtreatreg_maximize:maximize_options}}}control the 
	maximization process.  These options are seldom used.{p_end}
{synoptline}

{marker densityname}{...}
{synoptset 23}{...}
{synopthdr :densityname}
{synoptline}
{synopt :{opt gamma}}Gamma{p_end}
{synopt :{opt logit}}Logistic{p_end}
{synopt :{opt negbin1}}Negative Binomial-1 (constant dispersion){p_end}
{synopt :{opt negbin2}}Negative Binomial-2 (mean dispersion){p_end}
{synopt :{opt normal}}Normal{p_end}
{synoptline}

{p2colreset}{...}
{p 4 6 2}
{opt bootstrap}, {opt by}, {opt jackknife}, {opt rolling}, {opt statsby}, and
{opt xi} are allowed; see {help prefix}.
	{p_end}
{p 4 6 2}
{opt pweight}s, {opt aweight}s, {opt fweight}s, and {opt iweight}s are
allowed.
	{p_end}
{p 4 6 2}
See {help mtreatreg postestimation} for features available after estimation.
	{p_end}


{title:Description}

{pstd}
{opt mtreatreg} fits models with multinomial treatments and continuous, count
and binary outcomes outcomes using maximum simulated likelihood.  The model 
considers the effect of an endogenously chosen multinomial-valued treatment 
on an outcome variable, conditional on two sets of independent variables.  
The outcome variable can be continuous, binary or integer-valued while the 
treatment choice is assumed to follow a mixed multinomial logit distribution.  
The model is estimated using maximum simulated likelihood and the simulator 
uses Halton sequences.


{title:Options}

{dlgtab:Model}

{phang}
{cmd:mtreatment(}{it:depvar_mt = indepvars_mt}{cmd:) specifies the variables 
  for the treatment equation.  It is required.

{phang}
{cmd:simulationdraws(}{it:#}{cmd:)} specifies the number of simulation draws
used per observation.  It is required.

{phang}
{cmd:density(densityname)} specifies the distribution of {depvar}.  
See {it:{help mtreatreg##densityname:densityname}}.  It is
required.

{phang}
{cmd:prefix(string)} allows the user to choose a prefix other than
_T for the indicator variables created from the multinomial treatment
variable.  The default is a set of indicator variables starting with 
_T.  When mtreatreg is called, all previously created indicator
variables starting with the prefix specified in the prefix(string) 
option or with _T are dropped.

{phang}
{opt noconstant}, {opt constraint(constraint)}, {opt collinear}; see
    {help estimation options##noconstant:estimation options}.

{dlgtab:SE/Robust}

{phang}
{opth vce(vcetype)}; see {it:{help vce_option}}.

{phang}
{opt robust}, {opth cluster(varname)}; see
   {help estimation options##robust:estimation options}.

{dlgtab:Reporting}

{phang}
{opt verbose} specifies that output from the mixed multinomial logit treatment and exogenous 
	outcome regressions be reported. {opt verbose} has no effect if {opt from} is 
	specified.

{dlgtab :Quasi-random numbers}

{phang}
{opt facscale(#)} specifies the standard deviation of the
	quasi-random variables.  The default is 1.{p_end}

{phang}
{opt startpoint(#)} specifies the starting point in the Halton sequence from 
	which the quasi-random variates are generated.  The default is 20.{p_end}

{marker maximize_options}{...}
{dlgtab:Max options}

{phang}
{opt facfrom(string)}}specifies the starting value for the parameter 
	associated with the latent factor.  The default starting value 
	is zero.{p_end}

{phang}
{it:maximize_options}:
{opt diff:icult},
{opt tech:nique(algorithm_spec)},
{opt iter:ate(#)},
[{cmdab:no:}]{opt lo:g},
{opt tr:ace},
{opt grad:ient},
{opt showstep},
{opt hess:ian},
{opt shownr:tolerance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt gtol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance(#)},
{opt from(init_specs)};
see {help maximize}.  These options are seldom used.


{title:Remarks}

{pstd}
{opt difficult} may sometimes be a useful option if convergence is slow.{p_end}

{pstd}
{opt robust} produces standard errors which take simulation error into account.  
It is the preferred option unless {opt cluster(varname)} is specified.{p_end}

{pstd}
The available outcome densities and associated conditional means are

	Density			{cmd:mtreatreg} option	cond. mean
	{hline 60}
	Gamma			{cmd:density(gamma)}	exp(xb)
	Logistic		{cmd:density(logit)}	exp(xb)/(1+exp(xb))
	Negative Binomial-1	{cmd:density(negbin1)}	exp(xb)
	Negative Binomial-2	{cmd:density(negbin2)}	exp(xb)
	Normal(Gaussian)	{cmd:density(normal)}	xb 


{title:Examples}

{p 8 12 2}{cmd:. mtreatreg ycontinuous x1 x2, mtreat(d=x1 x2 z) sim(200) dens(gamma)}
{p_end}
{p 8 12 2}{cmd:. mtreatreg yinteger x1 x2, mtreat(d=x1 x2 z) sim(200) dens(negbin1)}
{p_end}


{title:References}

{p 4 8 2}Deb, P., and P. K. Trivedi (2006), Specification and Simulated Likelihood 
Estimation of a Non-normal Treatment-outcome Model with Selection: Application 
to Health Care Utilization, {it:Econometrics Journal}, 9, 307-331.

{p 4 8 2}Deb, P., and P. K. Trivedi (2006), Maximum Simulated Likelihood Estimation 
of a Negative-binomial Regression Model with Multinomial Endogenous Treatment, 
{it: The Stata Journal}, 6, 246-255.


{title:Author}

{phang}Partha Deb, Hunter College and The Graduate Center, City University of New York, 
and NBER, USA.{p_end}
{phang}partha.deb@hunter.cuny.edu{p_end}



{title:Also see}

{psee}
Online:  
{help mtreatreg postestimation}{break}
{helpb treatreg}
{p_end}
