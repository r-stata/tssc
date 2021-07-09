{smcl}
{* *! version 1.0.5  04jun2013}{...}
{cmd:help spreg}{right:also see:  {helpb spreg postestimation}}
{right:{helpb spivreg}{space 13}}
{right:{helpb spmat}{space 15}}
{hline}


{title:Title}

{p2colset 5 14 16 2}{...}
{p2col:{hi:spreg} {hline 2}}Spatial-autoregressive model with
spatial-autoregressive disturbances{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{cmd:spreg} {it:estimator} {depvar} [{indepvars}] {ifin}{cmd:,} {opt id(varname)} [{it:options}]


{synoptset 26}{...}
{p2coldent:{it:estimator}}description{p_end}
{synoptline}
{synopt:{opt ml}}maximum likelihood (ML){p_end}
{synopt:{opt gs2sls}}generalized spatial two-stage least squares (GS2SLS){p_end}
{synoptline}

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model}
{p2coldent:* {opt id(varname)}}ID variable{p_end}
{synopt:{cmd:{ul:dl}mat(}{it:name}[{cmd:, eig}]{cmd:)}}{helpb spmat:spmat} object used in the
spatial-autoregressive term{p_end}
{synopt:{cmd:{ul:el}mat(}{it:name}[{cmd:, eig}]{cmd:)}}{helpb spmat:spmat} object used in the
spatial-error term{p_end}
{synopt:{opt nocons:tant}}suppress constant term{p_end}

{syntab :ML estimator}
{synopt:{opt grid:search(#)}}search for initial values{p_end}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply
specified linear constraints{p_end}

{syntab :GS2SLS estimator}
{synopt:{opt het:eroskedastic}}use the estimator that allows for 
heteroskedastic disturbance terms {p_end}
{synopt:{cmd:impower(}{it:q}{cmd:)}}use {it:q} powers of matrix {bf:W} in forming the
instrument matrix {bf:H}; default is {cmd:2}{p_end}

{syntab :Maximization}
{synopt :{it:{help spreg##maximize_options:maximize_options}}}control the
maximization process; seldom used{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
* Required{p_end}


{title:Description}

{pstd}
{cmd:spreg} estimates the parameters of a cross-sectional
spatial-autoregressive model with spatial-autoregressive disturbances which
is known as a SARAR model.

{pstd}
A SARAR model includes a weighted average of the dependent variable, known
as a spatial lag, as a right-hand-side variable and it allows the
disturbance term to depend on a weighted average of the disturbances
corresponding to other units.  The weights may differ for each observation
and are frequently inversely related to the distance from the current
observation.  These weights must be stored in a spatial-weighting matrix
created by {helpb spmat}.

{pstd}
{cmd:spreg} estimates the parameters by either maximum likelihood (ML) or by
generalized spatial two-stage least squares (GS2SLS).  

{pstd}
You can download Drukker, Prucha, and Raciborski (2011), which documents
this command, from 
{browse "http://econweb.umd.edu/~prucha/Papers/WP_spreg_2011.pdf"}.


{title:Options}

{dlgtab:Model}

{phang}
{opt id(varname)} specifies a numeric variable that contains a unique
    identifier for each observation.

{phang}
{cmd:dlmat(}{it:name}[{cmd:, eig}]{cmd:)} specifies an {helpb spmat} object 
that contains the spatial-weighting matrix {bf:W} to be used in the 
spatial-autoregressive term.  {cmd:eig} forces the calculation of the
eigenvalues of {bf:W}, even if the {cmd:spmat} object contains them.
The {cmd:eig} option is only allowed with the {cmd:ml} estimator.

{phang}
{cmd:elmat(}{it:name}[{cmd:, eig}]{cmd:)} specifies an {helpb spmat} object 
that contains the spatial-weighting matrix {bf:M} to be used in the 
spatial-error term.  {cmd:eig} forces the calculation of the eigenvalues
of {bf:M, even if the {cmd:spmat} object contains them.  The {cmd:eig} option
is only allowed with the {cmd:ml} estimator.

{phang}
{opt noconstant} suppresses the constant term in the model.

{dlgtab:ML}

{phang}
{cmd:gridsearch(}{it:#}{cmd:)} specifies the fineness of the grid used in 
searching for the initial values of the parameters {it:lambda} and {it:rho}
in the concentrated log likelihood.  The allowed range is 
[0.001,0.1] with 0.1 being the default.

{phang}
{opt constraints(constraints)};
see {helpb estimation options:[R] estimation options}.

{phang}
{it:maximize_options}: 
{opt dif:ficult},
{opt tech:nique(algorithm_spec)},
{opt iter:ate(#)},
[{cmdab:no:}]{opt lo:g}, 
{opt tr:ace}, 
{opt grad:ient},
{opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)}, {opt ltol:erance(#)}, 
{opt nrtol:erance(#)}, {opt nonrtol:erance}, 
{opt from(init_specs)}; see {manhelp maximize R}.  These options are seldom
used.  {cmd:from()} takes precedence over {cmd:gridsearch()}.

{dlgtab:GS2SLS}

{phang}
{opt heteroskedastic} specifies that {cmd:spreg} use an estimator that
allows e to be heteroskedastically distributed over the observations.
By default, {cmd:spreg} uses an estimator that assumes homoskedasticity.

{phang}
{cmd:impower(}{it:q}{cmd:)} specifies how many powers of the matrix {bf:W}
to include in calculating the instrument matrix {bf:H}.
Integers in the set {c -(}2, 3, ..., {cmd:floor(sqrt(cols(W)))}{c )-}
are allowed, with {it:q} = {cmd:2} being the default.

{phang}
{it:maximize_options}:
{opt iter:ate(#)},
[{cmdab:no:}]{opt lo:g}, 
{opt tr:ace}, 
{opt grad:ient},
{opt showstep},
{opt showtol:erance},
{opt tol:erance(#)}, {opt ltol:erance(#)}; see {manhelp maximize R}.
These options are seldom used.
{opt from(init_specs)} is also allowed, but because {it:rho} is the only
parameter in the optimization problem, the initial value should be
specified as {opt from(#)}.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. use pollute, clear}{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat, replace}{p_end}

{pstd}Estimate the SARAR parameters by ML{p_end}
{phang2}{cmd:. spreg ml pollution factories area, id(id) dlmat(cobj) elmat(cobj)}{p_end}

{pstd}Estimate the SARAR parameters by GS2SLS{p_end}
{phang2}{cmd:. spreg gs2sls pollution factories area, id(id) dlmat(cobj) elmat(cobj)}{p_end}


{title:Saved results}

{pstd}
{cmd:spreg ml} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(iterations)}}number of ML iterations{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(chi2)}}chi-squared statistic{p_end}
{synopt:{cmd:e(p)}}significance{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:spreg}{p_end}
{synopt:{cmd:e(estimator)}}{cmd:ml}{p_end}
{synopt:{cmd:e(model)}}{cmd:sarar}, {cmd:sar}, {cmd:sare}, or {cmd:lr}{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(indeps)}}names of independent variables{p_end}
{synopt:{cmd:e(constant)}}{cmd:noconstant} or {cmd:hasconstant}{p_end}
{synopt:{cmd:e(idvar)}}name of ID variable{p_end}
{synopt:{cmd:e(dlmat)}}name of {cmd:spmat} object in {cmd:dlmat()}{p_end}
{synopt:{cmd:e(elmat)}}name of {cmd:spmat} object in {cmd:elmat()}{p_end}
{synopt:{cmd:e(chi2type)}}type of model chi-squared test{p_end}
{synopt:{cmd:e(vce)}}{cmd:oim}{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(crittype)}}type of optimization{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(estat_cmd)}}program used to implement {cmd:estat}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(Cns)}}constraints matrix{p_end}
{synopt:{cmd:e(ilog)}}iteration log{p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{pstd}
{cmd:spreg gs2sls} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(rho_2sls)}}initial estimate of {it:rho}{p_end}
{synopt:{cmd:e(iterations)}}number of GMM iterations{p_end}
{synopt:{cmd:e(iterations_2sls)}}number of 2SLS iterations{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if GMM stage converged, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(converged_2sls)}}{cmd:1} if 2SLS stage converged, {cmd:0} otherwise{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:spreg}{p_end}
{synopt:{cmd:e(estimator)}}{cmd:gs2sls}{p_end}
{synopt:{cmd:e(model)}}{cmd:sarar}, {cmd:sar}, {cmd:sare}, or {cmd:lr}{p_end}
{synopt:{cmd:e(het)}}{cmd:heteroskedastic} or {cmd:homoskedastic}{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(indeps)}}names of independent variables{p_end}
{synopt:{cmd:e(exogr)}}exogenous regressors{p_end}
{synopt:{cmd:e(constant)}}{cmd:noconstant} or {cmd:hasconstant}{p_end}
{synopt:{cmd:e(H_omitted)}}names of omitted instruments in {bf:H}{p_end}
{synopt:{cmd:e(idvar)}}name of ID variable{p_end}
{synopt:{cmd:e(dlmat)}}name of {cmd:spmat} object in {cmd:dlmat()}{p_end}
{synopt:{cmd:e(elmat)}}name of {cmd:spmat} object in {cmd:elmat()}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(estat_cmd)}}program used to implement {cmd:estat}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(delta_2sls)}}initial estimate of {it:lambda} and {bf:b}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:References}

{phang}
Drukker, D. M., I. R. Prucha, and R. Raciborski. 2011. 
Maximum-likelihood and generalized spatial two-stage least-squares estimators
for a spatial-autoregressive model with spatial-autoregressive disturbances.
Working paper, University of Maryland, Department of Economics,
{browse "http://econweb.umd.edu/~prucha/Papers/WP_spreg_2011.pdf"}.


{title:Authors}

{phang}
David Drukker, StataCorp, College Station, TX.
{browse "mailto:ddrukker@stata.com":ddrukker@stata.com}.

{phang}
Ingmar Prucha, Department of Economics, University of Maryland, College Park, MD.
{browse "mailto:prucha@econ.umd.edu":prucha@econ.umd.edu}.

{phang}
Rafal Raciborski, StataCorp, College Station, TX.
{browse "mailto:rraciborski@stata.com":rraciborski@stata.com}.


{title:Acknowledgment}

{pstd}
We gratefully acknowledge financial support from the National Institute of
Health through the SBIR grant R43 AG027622 and R44 AG027622.

{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

