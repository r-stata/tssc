{smcl}
{* *! version 2.0.0 Kenneth Houngbedji 14jan2016}{...}
{viewerjumpto "Syntax" "absdid##syntax"}{...}
{viewerjumpto "Description" "absdid##description"}{...}
{viewerjumpto "Options" "absdid##options"}{...}
{viewerjumpto "Remarks" "absdid##remarks"}{...}
{viewerjumpto "Examples" "absdid##examples"}{...}
{viewerjumpto "Stored results" "absdid##results"}{...}
{viewerjumpto "References" "absdid##references"}{...}
{viewerjumpto "Author" "absdid##author"}{...}
{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{bf: absdid} {hline 2}}Semiparametric Difference-in-Difference Estimator
 of {help absdid##A2005:Abadie (2005)}{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}{opt absdid} {depvar} {ifin} [{cmd:,} 
    {opt tv:ar(varname)}
    {opt xv:ar(varlist)}
	{it:options}
]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Heterogeneity}
{synopt :{opth yxv:ar(varlist)}}list of variables which can modify the treatment 
effect{p_end}

{syntab:Propensity score}
{synopt :{opt sle}}set a logistic function to estimate the propensity score{p_end}
{synopt :{opt ord:er(#)}}set order of the polynomial function used to estimate the 
propensity score{p_end}
{synopt :{opt csi:nf(#)}}drop the observations of which the propensity score 
is less than #{p_end}
{synopt :{opt csu:p(#)}}drop the observations of which the propensity score is 
greater than #{p_end}
{synoptline}
{p 4 6 2}
{opt xv:ar(varlist)} and {opt yxv:ar(varlist)} may contain factor variables 
and interactions terms; 
see {help fvvarlist}.{p_end}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:absdid} implements the semiparametric difference-in-difference estimator of
 {help absdid##A2005:Abadie (2005)}. 

{phang}
The estimator compares {depvar} (the change of the outcome of interest between 
baseline and follow-up) across the treated ({opt tv:ar(varname)} == {cmd:1}) 
and the untreated ({opt tv:ar(varname)} == {cmd:0}) groups. To address non-random 
selection into treatment groups, the estimator adjusts for observable differences 
between treatment groups at the baseline based on the list {opt xv:ar(varlist)} 
of control variables.
{p_end}

{marker options}{...}
{title:Options}

{dlgtab:Mandatory}

{phang}
{opt tv:ar(varname)} is the binary treatment variable. It is required and should
 be coded as {cmd:0} or {cmd:1}, with {cmd:0} indicating an untreated observation
 and {cmd:1} indicating a treated observation. {p_end}

{phang}
{opt xv:ar(varlist)} specifies the variables for the selection into treatment 
equation. It is an integral part of the semiparametric difference-in-difference 
estimator and is required. The selection equation should contain at least one 
variable. 
{p_end}

{dlgtab:Heterogeneity}

{phang}
{opt yxv:ar(varlist)} specifies the variables which can modify the treatment effect. 
By default the treatment effect is assumed to be constant.
{p_end}

{dlgtab:Propensity score}

{phang}
{opt sle} forces to use a logistic specification to estimate the propensity score 
(see {help absdid##H2003:Hirano {it:et} al.(2003)}). This ensures for instance 
that the estimated propensity score is always greater than 0 and less than 1. By
 default the propensity score is estimated with a linear regression. 
{p_end}

{phang}
{opt ord:er(#)} indicates the order of the polynomial function to be used to 
estimate the propensity score. By default it is equal to 1.
{p_end}

{phang}
{opt csi:nf(#)} troncates the observations of which the propensity score 
is less than #. The default is {opt csi:nf(0)}.
{p_end}

{phang}
{opt csu:p(#)} troncates the observations of which the propensity score 
is greater than #. The default is {opt csu:p(1)}.
{p_end}

{marker examples}{...}
{title:Example: Union-wage premium}

{pstd}Setup{p_end}
{phang2}{cmd:. use "http://www.parisschoolofeconomics.eu/docs/houngbedji-kenneth/absdid.dta", clear }{p_end}

{pstd}Estimate the union-wage premium{p_end}
{phang2}{cmd:. absdid dlwage, tvar(union97) xvar(age black hispanic married i.grade)}{p_end}

{pstd}Union-wage premium with the {opt sle} option{p_end}
{phang2}{cmd:. absdid dlwage, tvar(union97) xvar(age black hispanic married i.grade) sle}{p_end}

{pstd}Union-wage premium when the probability to be treated varies between {cmd:0.01} and {cmd:0.99}{p_end}
{phang2}{cmd:. absdid dlwage, tvar(union97) xvar(age black hispanic married i.grade) csinf(0.01) csup(0.99)}{p_end}

{pstd}Union-wage premium using a polynomial function of order 4 to estimate the propensity score{p_end}
{phang2}{cmd:. absdid dlwage, tvar(union97) xvar(age black hispanic married i.grade) order(4)}{p_end}

{pstd}Variation of union-wage premium across age and education{p_end}
{phang2}{cmd:. absdid dlwage, tvar(union97) xvar(age black hispanic married i.grade) yxvar(age hschool college)}{p_end}

{pstd}Interaction terms{p_end}
{phang2}{cmd:. absdid dlwage, tvar(union97) xvar(c.age##c.age black hispanic married i.grade) yxvar(c.age##c.age hschool college)}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:absdid} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:absdid}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{marker references}{...}
{title:References}

{marker A2005}{...}
{phang}
Abadie, A. 2005. {browse "http://www.ksg.harvard.edu/fs/aabadie/didp.pdf":Semiparametric Difference-in-Differences Estimators.} {it:Review of Economic Studies} 72: 1--19
{p_end}

{marker H2003}{...}
{phang}
Hirano, K., Imbens, G.W. and Ridder, G. 2003. 
{browse "http://scholar.harvard.edu/imbens/files/efficient_estimation_of_average_treatment_effects_using_the_estimated_propensity_score.pdf":Efficient Estimation of Average Treatment Effects Using the Estimated Propensity Score.}
{it:Econometrica} 71(4): 1161--1189
{p_end}

{marker author}{...}
{title:Author}

{marker contact}{...}
{phang}
Kenneth Houngbedji, 
Paris School of Economics, Paris, France. email: {browse "mailto:kenneth.houngbedji@psemail.eu":kenneth.houngbedji@psemail.eu}.
{p_end}
