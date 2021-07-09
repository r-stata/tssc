{smcl}
{* *! version 1.0.0 29oct2017}{…}
{cmd:help brglm} 
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{bf: brglm} {hline 2}}Bias reduced estimators for binary response models {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:brglm}
{depvar}
[{indepvars}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model}
{synopt :{opth m:odel(brglm##modelname:modelname)}}model for the distribution of {depvar}; default is {opt probit} {p_end}
{synopt :{opt nocon:stant}}suppress constant term{p_end}


{syntab :Options}
{synopt :{opth iter:ations(##)}}maximum number of iterations; default is 5000{p_end}
{synopt :{opth tol:erances(##)}}tolerance level; default is 1.000e-6{p_end}


{marker modelname}{...}
{synoptset 23}{...}
{synopthdr:modelname}
{synoptline}
{synopt :{opt logit}}Logit{p_end}
{synopt :{opt probit}}Probit{p_end}
{synopt :{opt cloglog}}Cloglog{p_end}
{synoptline}
{p2colreset}{...}


{p 4 6 2}
{it:indepvars} may contain time-series operators or factor variables, see {help fvvarlist}.{p_end}



{marker description}{...}
{title:Description}

{pstd}
{opt brglm} estimates bias-reduced probit, logit and cloglog models by iterative weighted least squares (IWLS). {p_end}

{pstd}
- Cross-sectional properties are derived by Kosmidis and Firth (2009). {p_end}

{pstd}
- Panel models with fixed effects can be estimated by including an indicator variable for each panel unit as shown by Kunz, Staub and Winkelmann (2017).{p_end}


{marker examples}{...}
{title:Example: Cross-Section}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse union}{p_end}

{pstd}Biased-reduced probit model{p_end}
{phang2}{cmd:. brglm union age grade i.not_smsa south if year==88 , model(probit) }
{p_end}

{title:Example: Panel}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse ships}{p_end}

{pstd}Prepare dataset{p_end}
{phang2}{cmd:. g y=accident>0}{p_end}
{phang2}{cmd:. bys ship: g time=_n}{p_end}
{phang2}{cmd:. xi i.ship}{p_end}

{pstd}Biased-reduced fixed effects probit model{p_end}
{phang2}{cmd:. brglm y _Iship* time, model(probit)}
{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:brglm,} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}brglm{p_end}
{synopt:{cmd:e(model)}}{bf:modelname} {p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:References}

{synoptset 20 tabbed}{...}
Kosmidis, Ioannis & David Firth. 2009. 
	‘Bias reduction in exponential family nonlinear models.’ {it: Biometrika}, 96(4):793–804.

Kunz, Johannes S., Kevin E. Staub & Rainer Winkelmann. 2017. 
	‘Estimating fixed effects: Perfect prediction and bias in binary response panel models, 
	with an application to the Hospital Readmissions Reduction Program.’ {it: SSRN Working Paper No.} 3074193.

