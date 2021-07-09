{smcl}
{* *! version 1.0.5  04jun2013}{...}
{cmd:help spivreg}{right:also see:  {helpb spivreg postestimation:spivreg postestimation}}
{right:{helpb spreg}{space 17}}
{right:{helpb spmat}{space 17}}
{hline}


{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi:spivreg} {hline 2}}Spatial-autoregressive model with
spatial-autoregressive erros and additional endogenous variables{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{cmd:spivreg} {depvar} [{it:{help varlist:varlist1}}] {cmd:(}{it:varlist2}
{cmd:=} [{it:varlist_iv}]{cmd:)} {ifin}{cmd:,} {opt id(varname)} [{it:options}]


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model}
{p2coldent:* {opt id(varname)}}ID variable{p_end}
{synopt:{cmd:{ul:dl}mat(}{it:name}{cmd:)}}{helpb spmat:spmat} object used in the
spatial-autoregressive term{p_end}
{synopt:{cmd:{ul:el}mat(}{it:name}{cmd:)}}{helpb spmat:spmat} object used in the
spatial-error term{p_end}
{synopt:{opt nocons:tant}}suppress constant term{p_end}
{synopt:{opt het:eroskedastic}}use the formula for the heteroskedastic error term{p_end}
{synopt:{cmd:impower(}{it:q}{cmd:)}}use {it:q} powers of matrix {bf:W} in forming the
instrument matrix {bf:H}; default is {cmd:2}{p_end}

{syntab :Maximization}
{synopt :{it:{help spivreg##maximize_options:maximize_options}}}control the
maximization process; seldom used{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
* Required{p_end}


{title:Description}

{pstd}
{cmd:spivreg} estimates the parameters of a cross-sectional
spatial-autoregressive model with spatial-autoregressive disturbances which
is known as a SARAR model when there are additional endogenous regressors.

{pstd}
A SARAR model includes a weighted average of the dependent variable, known
as a spatial lag, as a right-hand-side variable and it allows the
disturbance term to depend on a weighted average of the disturbances
corresponding to other units.  The weights may differ for each observation
and are frequently inversely related to the distance from the current
observation.  These weights must be stored in a spatial-weighting matrix
created by {helpb spmat}.

{pstd}
{cmd:spivreg} estimates the parameters by generalized spatial two-stage least
squares (GS2SLS).

{pstd}
You can download Drukker, Prucha, and Raciborski (2011), which documents
this command, from 
{browse "http://econweb.umd.edu/~prucha/Papers/WP_spivreg_2011.pdf"}.


{title:Options}

{dlgtab:Model}

{phang}
{opt id(varname)} specifies a numeric variable that contains a unique
    identifier for each observation. This option is required.

{phang}
{cmd:dlmat(}{it:name}{cmd:)} specifies an {helpb spmat} object 
that contains the spatial-weighting matrix {bf:W} to be used in the 
spatial-autoregressive term.

{phang}
{cmd:elmat(}{it:name}{cmd:)} specifies an {helpb spmat} object 
that contains the spatial-weighting matrix {bf:M} to be used in the 
spatial-error term.

{phang}
{opt noconstant} suppresses the constant term in the model.

{phang}
{opt heteroskedastic} specifies that {cmd:spivreg} use an estimator that
allows {bf:e} to be heteroskedastically distributed over the observations.
By default, {cmd:spivreg} uses an estimator that assumes homoskedasticity.

{phang}
{cmd:impower(}{it:q}{cmd:)} specifies how many powers of the matrix {bf:W}
to include in calculating the instrument matrix {bf:H}.
Integers in the set {c -(}2, 3, ..., {cmd:floor(sqrt(cols(W)))}{c )-}
are allowed, with {it:q} = {cmd:2} being the default.

{marker maximize_options}{...}
{dlgtab:Maximization}

{phang}
{it:maximize_options}:
{opt iter:ate(#)},
[{cmdab:no:}]{opt lo:g}, 
{opt tr:ace}, 
{opt grad:ient},
{opt showstep},
{opt showtol:erance},
{opt tol:erance(#)}, {opt ltol:erance(#)},
{opt from(init_specs)}; see {manhelp maximize R}.  These options are seldom used.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. use pollute}{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat}{p_end}

{pstd}Estimate the SARAR parameters{p_end}
{phang2}{cmd:. spivreg pollution area (factories = penalties), id(id) dlmat(cobj) elmat(cobj)}{p_end}


{title:Saved results}

{pstd}
{cmd:spivreg} saves the following in {cmd:e()}:

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
{synopt:{cmd:e(cmd)}}{cmd:spivreg}{p_end}
{synopt:{cmd:e(model)}}{cmd:sarar}, {cmd:sar}, {cmd:sare}, or {cmd:lr}{p_end}
{synopt:{cmd:e(het)}}{cmd:heteroskedastic} or {cmd:homoskedastic}{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(indeps)}}names of independent variables{p_end}
{synopt:{cmd:e(exogr)}}exogenous regressors{p_end}
{synopt:{cmd:e(insts)}}instruments{p_end}
{synopt:{cmd:e(instd)}}instrumented variables{p_end}
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
A command for estimating spatial-autoregressive models with spatial
autoregressive disturbances and additional endogenous variables.
Working paper, The University of Maryland, Department of Economics,
{browse "http://econweb.umd.edu/~prucha/Papers/WP_spivreg_2011.pdf"}.


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

{psee}Online:  {helpb spmat}, {helpb spreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

