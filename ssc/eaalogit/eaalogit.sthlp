{smcl}
{* 12Oct2013}{...}
{cmd:help eaalogit}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col :{hi:eaalogit} {hline 2}}Endogenous attribute attendance model{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:eaalogit}
{depvar}
[{indepvars}] {ifin} {cmd:,}
{cmdab:gr:oup(}{varname}{cmd:)}
{cmdab:id(}{varname}{cmd:)}
{opt k:eaa(#)}
{opt eaa:spec(string)}
[{opt z:vars(varlist)}
 {opt l:evel(#)}
 {opt const:raints(numlist)}
 {opt vce(vcetype)} 
 {it:maximize_options}]


{p 8 15 2}
{cmd:eaapred}
{newvar} {ifin}

 
{title:Description}

{pstd}
{cmd:eaalogit} fits the endogenous attribute attendance model described in Hole (2011).

{pstd}
{cmd:eaapred} calculates predicted probabilities after {cmd:eaalogit}. The predictions are available
both in and out of sample; type {cmd:eaapred} ... {cmd:if e(sample)} ... if
predictions are wanted for the estimation sample only.


{title:Options for eaalogit}

{phang}
{opth group(varname)} is required and specifies a numeric identifier variable
for the choice occasions.

{phang}
{opth id(varname)} is required and specifies a numeric identifier variable for 
the decision makers.

{phang}
{opt k:eaa(#)} is required and specifies the number of non-attendance parameters to be estimated.

{phang}
{opt eaa:spec(string)} is required and specifies the non-attendance pattern. This option is best 
explained by using an example - see below.

{phang}
{opth z:vars(varlist)} specifies the variables to model the non-attendance (if any).

{phang}
{opt level(#)}; see {help estimation options}.

{phang}
{opth constraints(numlist)}; see {help estimation options}.

{phang}
{opth vce(vcetype)}; {it:vcetype} may be {opt oim},
{opt r:obust}, {opt cl:uster} {it:clustvar}, or {opt opg}.

{phang}
{it:maximize_options}:
{opt dif:ficult},
{opt tech:nique(algorithm_spec)}, 
{opt iter:ate(#)}, {opt tr:ace}, {opt grad:ient}, 
{opt showstep}, {opt hess:ian}, {opt tol:erance(#)}, 
{opt ltol:erance(#)} {opt gtol:erance(#)}, {opt nrtol:erance(#)}, 
{opt from(init_specs)}; see {help maximize}.


{title:Examples}

{pstd}
The following examples use traindata.dta, which is described in Hole (2007).

{phang2}{cmd:. use http://fmwww.bc.edu/repec/bocode/t/traindata.dta}{p_end}

{phang2}{cmd:. eaalogit y price contract local wknown tod seasonal, group(gid) id(pid) keaa(3) eaaspec(one x1 x2 x2 x3 x3)}{p_end}

{pstd}
This estimates an EAA model with full attendance to {cmd:price} (the "{cmd:one}" in {opt eaaspec}), and allows for non-attendance to the
remaining attributes. It is assumed that {cmd:local} is ignored when {cmd:wknown} is ignored (the repeated "{cmd:x2}" in {opt eaaspec}) 
and that {cmd:tod} is ignored when {cmd:seasonal} is ignored (the repeated "{cmd:x3}" in {opt eaaspec}).  

{pstd}
The non-attendance probabilities can be calculated using {cmd:nlcom}:

{phang2}{cmd:. nlcom (ANA_contract: invlogit(-[Gamma1]_cons))}{p_end}
{phang2}{cmd:. nlcom (ANA_local_wknown: invlogit(-[Gamma2]_cons))}{p_end}
{phang2}{cmd:. nlcom (ANA_tod_seasonal: invlogit(-[Gamma3]_cons))}{p_end}

{pstd}
The results show that the probability of non-attendance to {cmd:contract} is 0.62, the probability of non-attendance to {cmd:local}/{cmd:wknown} 
is 0.48 and the probability of non-attendance to {cmd:tod}/{cmd:seasonal} is 0.01 (the latter probability is insignificantly different from zero).

{pstd}
A model in which a separate non-attendance probability is estimated for each attribute is specified as:

{phang2}{cmd:. eaalogit y price contract local wknown tod seasonal, group(gid) id(pid) keaa(6) eaaspec(x1 x2 x3 x4 x5 x6)}{p_end}

{pstd}
As before the non-attendance probabilities can be calculated using {cmd:nlcom}, e.g.:

{phang2}{cmd:. nlcom (ANA_price: invlogit(-[Gamma1]_cons))}{p_end}


{title:References}

{phang}Hole AR. 2007. Fitting mixed logit models by using maximum simulated likelihood. {it:The Stata Journal} 7(3): 388-401.

{phang}Hole AR. 2011. A discrete choice model with endogenous attribute attendance. {it:Economics Letters} 110(3): 203-205.


{title:Author}

{phang}This command was written by Arne Risa Hole (a.r.hole@sheffield.ac.uk). 
Comments and suggestions are welcome. {p_end}


{title:Also see}

{psee}
Manual:  {bf:[R] clogit}

{psee}
Online:  {manhelp clogit R}{p_end}
