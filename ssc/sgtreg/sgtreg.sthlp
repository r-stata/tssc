{smcl}
{* *! version 1.0  03aug2015}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{viewerjumpto "References" "references##references"}{...}
{title:Title}

{phang}
{bf:sgtreg} {hline 2} Regression with a Skewed Generalized T Error Term


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:sgtreg}
{depvar}
{indepvars}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt init:ial}}initial values for the coefficients{p_end}
{synopt:{it:{help ml##noninteractive_maxopts:maximize_options}}}control the
maximization process{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:sgtreg} fits a model of {depvar} on {indepvars} using maximum likelihood with an error term distributed as a skewed generalized t.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt initial} list of numbers that specifies the initial values of the coefficients.

{phang}{marker noninteractive_maxopts}
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
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)}; see {manhelp maximize R}.


{marker remarks}{...}
{title:Remarks}

{pstd}
In cases where the convergence is difficult, try to use the option {cmd: technique(bfgs)}, or the other two {cmd: technique} options. {cmd: technique(bfgs)} is often more robust than the default {cmd: technique(nr)}.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. clear}{p_end}
{phang}{cmd:. set obs 1000}{p_end}
{phang}{cmd:. set seed 1234}{p_end}
{phang}{cmd:. gen x1 = rnormal(0,1)}{p_end}
{phang}{cmd:. gen x2 = runiform()}{p_end}
{phang}{cmd:. gen y = 1 + 2*x1 + 3*x2 + rnormal(0,1)}{p_end}

{phang}{cmd:. sgtreg y x1 x2, technique(bfgs)}{p_end}

{marker references}{...}
{title:References}

{phang}
Davis, Carter, James B. McDonald, and Daniel Walton. 2015.
{it:A Generalized Regression Specification using the Skewed Generalized T Distribution},
working paper.
