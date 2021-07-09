{smcl}
{* *! version 1.0  13may2016}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{viewerjumpto "References" "references##references"}{...}
{title:Title}

{phang}
{bf:gb2reg} {hline 2} Regression with a GB2 Error Term


{marker syntax}{...}
{title:Syntax}

{p 8 20 2}
{cmdab:gb2reg}
{depvar}
{indepvars}
[{it:if}]
[{it:in}]
[{cmd:,} {it:options}]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt qinf:inite}}use the generalized gamma distribution {p_end}
{synopt:{opt ln:ormal}}use the lognormal distribution {p_end}
{synopt:{opt sigma}}variable list used in the sigma equation{p_end}
{synopt:{opt p}}variable list used in the p equation {p_end}
{synopt:{opt p}}variable list used in the q equation {p_end}
{synopt:{opt init:ial}}initial values for the coefficients (optional and must be equal to the number of regressors plus the number of free parameters){p_end}
{synopt:{opth const:raints(numlist)}}constraints by number to be applied{p_end}
{synopt:{it:{help ml##noninteractive_maxopts:maximize_options}}}control the
maximization process{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:gb2reg} fits a model of the log of {depvar} on {indepvars} using maximum likelihood with an error term distributed as a gb2. The parameter delta varies with the independent variables. 
The other parameters can also vary with the independent variables 
if the sigma(), p(), and q() options are used. All values of the dependent 
variable must be positive.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt qinf:inite} specifies that the distribution that should be used should be the limit of the gb2 as the parameter q becomes arbitrarily large (i.e. the generalized gamma distribution, which has three free parameters).

{phang}
{opt ln:ormal} specifies that the lognormal distribution should be used (two free parameters).

{phang}
{opt sigma} specifies the variables to be used in the sigma equation. 

{phang}
{opt p} specifies the variables to be used in the p equation (not valid if using option lnormal). 

{phang}
{opt q} specifies the variables to be used in the q equation (not valid if using option lnormal or qinfinite). 

{phang}
{opt initial} list of numbers that specifies the initial values of the coefficients. This is optional, the program will attempt to search for the best initial values if no initial values are provided.

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes
        types that are robust to some kinds of misspecification (robust), that
        allow for intragroup correlation (cluster clustvar), and that are
        derived from asymptotic theory (oim, opg); see {manhelp vce_option R}.


{phang}
{cmd:constraints(}{it:{help numlist)}}
specifies the linear constraints to be
applied during estimation.  {opt constraints(numlist)} specifies the
constraints by number. Constraints are defined using the {cmd:constraint}
command; see {manhelp constraint R}.

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
{opt nrtol:erance(#)}; see {manhelp maximize R}. Allowed techniques include Newton-Raphson (nr), Berndt-Hall-Hausman (bhhh), Davidon
-Fletcher-Powell (dfp), and Broyden-Fletcher-Goldfarb-Shanno (bfgs). The default
 algorithm is Newton-Raphson.


{marker remarks}{...}
{title:Remarks}

{pstd}
In cases where the convergence is difficult, try to use the option {cmd: technique(bfgs)}, or the other two {cmd: technique} options. {cmd: technique(bfgs)} is often more robust than the default {cmd: technique(nr)}.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. clear}{p_end}
{phang}{cmd:. set obs 1000}{p_end}
{phang}{cmd:. set seed 5678}{p_end}
{phang}{cmd:. gen x1 = rnormal(0,1)}{p_end}
{phang}{cmd:. gen x2 = runiform()}{p_end}
{phang}{cmd:. gen y = 1 + 2*x1 + 3*x2 + rnormal(0,1)}{p_end}

{phang}{cmd:. gb2reg y x1 x2}{p_end}
{phang}{cmd:. gb2reg y x1 x2, vce(robust)}{p_end}
{phang}{cmd:. gb2reg y x1 x2, technique(bfgs)}{p_end}
{phang}{cmd:. gb2reg y x1 x2, qinf}{p_end}
{phang}{cmd:. gb2reg y x1 x2, sigma(x2) p(x2) qinf }{p_end}
{phang}{cmd:. gb2reg y x1 x2, sigma(x2) ln }{p_end}


{phang}{cmd:. constraint define 1 [p]_cons=2}{p_end}

{phang}{cmd:. gb2reg y x1 x2, const(1) qinf }{p_end}


