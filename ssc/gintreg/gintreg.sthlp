{smcl}
{* *! version 1.1  14jun2016}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{viewerjumpto "References" "references##references"}{...}

{title:Title}

{phang}
{bf:gintreg} {hline 2} Generalized Interval Regression


{marker syntax}{...}
{title:Syntax}

{p 8 20 2}
{cmdab:gintreg}
{it:{help depvar:depvar1}}
{it:{help depvar:depvar2}}
[{indepvars}]
[{it:if}]
[{it:in}]
[{cmd:,} {it:options}]

{pstd}
{it:depvar1} and {it:depvar2} should have the following form:

             Type of data {space 16} {it:depvar1}  {it:depvar2}
             {hline 46}
             point data{space 10}{it:a} = [{it:a},{it:a}]{space 4}{it:a}{space 8 }{it:a} 
             interval data{space 11}[{it:a},{it:b}]{space 4}{it:a}{space 8}{it:b }
             left-censored data{space 3}(-inf,{it:b}]{space 4}{cmd:.}{space 8}{it:b}
             right-censored data{space 3}[{it:a},inf){space 4}{it:a}{space 8}{cmd:.} 
             {hline 46}

If using grouped data then the form will be similar:

	     Type of data {space 16} {it:depvar1}  {it:depvar2} {space 1} {it: frequency}
             {hline 66}
             point data{space 10}{it:a} = [{it:a},{it:a}]{space 4}{it:a}{space 8 }{it:a} {space 8} {it:n}
             interval data{space 11}[{it:a},{it:b}]{space 4}{it:a}{space 8}{it:b } {space 7} {it:n}
             left-censored data{space 3}(-inf,{it:b}]{space 4}{cmd:.}{space 8}{it:b} {space 8} {it:n}
             right-censored data{space 3}[{it:a},inf){space 4}{it:a}{space 8}{cmd:.}  {space 7} {it:n}
             {hline 66}


{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt dist:ribution}(dist_type)} dist_type may be gb2, br12, br3, gg, gamma, ln, sgt, st, gt sged, ged, t, slaplace or
normal; default is normal. {p_end}
{synopt:{opth const:raints(numlist)}} specified linear constraints by number to be applied. Can use this option along with {opt dist:ribution} to allow for any distribution in the SGT or GB2 family trees.{p_end}
{synopt:{opth freq:uency(varlist)}} if using group data specify variable that denotes frequency. {p_end}

{syntab: Model}
{synopt:{cmdab: sigma(}{varlist}{cmd:)}} allow the {opt log of sigma} to vary as a function of independent variables; can use with dist_type normal, lnormal, gg, gb2, sgt, or sged. {p_end}
{synopt:{cmdab: lambda(}{varlist}{cmd:)}} allow lambda to vary as a function of independent variables; can use with dist_type sgt or sged. {p_end}
{synopt:{cmdab: p(}{varlist}{cmd:)}} allow p to vary as a linear function of independent variables; can use with dist_type gb2, gg, sgt, or sged. {p_end}
{synopt:{cmdab: q(}{varlist}{cmd:)}} allow q to vary as a linear function of independent variables; can use with dist_type gb2 or sgt. {p_end}

{syntab: SE/Robust}

{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim},{opt r:obust}, {opt cl:uster} {it:clustvar}, {opt opg}, {opt boot:strap}, or {opt jack:knife}. {p_end}
{synopt:{opt robust}} use robust standard errors. {p_end}
{synopt: {cmd: cluster(}{varlist}{cmd:)}} cluster standard errors with respect to sampling
unit {varlist}. {p_end}


{syntab: Estimation}
{synopt:{opth init:ial(numlist)}} initial values for p,q and lambda in that order. if the distribution does not have p, q or lambda, key in initial values for mu and lnsigma in that order.{p_end}
{synopt:{it:{help ml##noninteractive_maxopts:maximize_options}}}control the
maximization process{p_end}

{syntab: Display}
{synopt: {opt showc:onstonly}} Show the estimated constant only model. {p_end}
{synopt: {opth eyx(stat)}} Show the expected value of {depvar} conditional on {indepvars} at level of stat; default is mean. {p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:gintreg} fits a model of {depvar} on {indepvars} using maximum likelihood
where the dependent variable can be point data, interval data, right-censored data,
or left-censored data. This is a generalization of the built in STATA command
{cmd: intreg} and will yield identical estimates if the normal distribution option is used.
Unlike {cmd: intreg}, {cmd: gintreg} allows the underlying variable of interest to
be distributed according to a more general distribution including all distributions
in the Skewed Generalized T family and Generalized Beta of the Second Kind tree. Finally,
{cmd: gintreg} allows for grouped data when using the frequency option.

{pstd}
 The assumed model for interval regression is y = XB + eps where only the 
 thresholds containing the latent variable y are observed, X is a vector of
 explanatory variables with a corresponding coefficient vector B and eps is assumed
 to be independently and identically distributed random distrubances. The upper and 
 lower thresholds for y can be denoted by U and L respectively.
 
 {pstd}
 The conditional probability that y is in the interval (L,U) is: Pr(L <= y <= U)
 = F(eps = U - XB: theta) - F(eps: L-XB: theta), where F denotes the cdf of the
 random disturbances and theta denotes a vector of distributional parameters. 
 {cmd:gintreg} uses MLE on the corresponding log-likelihood function to estimate
 beta (displayed as mu or delta in the output) and the distributional parameters 
 theta.



{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt dist:ribution}(dist_type) specifies the type of distribution used in the interval regressions.
{cmd: gintreg} will use a log-likelihood function composed of the pdf and cdf of this distribution
(pdf for point data and cdf for intervals and censored observations). dist_type may be gb2, gg, ln, sgt, sged, or
normal; Default is normal. 

{phang}
{cmd:constraints(}{it:{help numlist)}} specified linear constraints by number to be applied. 
Can use this option along with {opt dist:ribution} to allow for any distribution in the SGT or GB2 family trees.
Constraints are defined using the {cmd:constraint}
command; see {manhelp constraint R}.

{phang} 
{opt freq:uency}({it:{help varlist)}} if using grouped data, specify the variable 
that denotes the frequency of the observation. Can be in percentage terms or 
levels as {cmd: gintreg} will normalize by summing the value of 
frequency for all observations. E.g. {it: gintreg depvar1 depvar2 indepvars, freq(freqvar)}

{dlgtab: Model}

{phang}
The {indepvars} specified will allow the location parameter (mu or delta) to vary
as a function of the independent variables. The other parameters in the distribution
can also be a function of explanatory variables by using the commands below.
If the user specifies a parameter that is not part of dist_type then {cmd: gintreg}
will indicate an error; e.g. specifying independent variables for q when using the
Generalized Gamma distribution.

{phang}
{cmd:sigma(}{it:{help varlist)}} allows the {opt log of sigma} to be a function of {varlist}  and can 
model heteroskedasticity.

{phang}
{cmd:lambda(}{it:{help varlist)}} allows lambda to be a function of {varlist} that bounds lambda to be between -1 and 1 
and can model skewness.

{phang}
{cmd:p(}{it:{help varlist)}} allows p to be a linear function of {varlist}. A shape parameter
that impacts the tail thickness and peakedness of the distribution.

{phang}
{cmd:q(}{it:{help varlist)}} allows q to be a linear function of {varlist}. A shape parameter
that impacts the tail thickness and peakedness of the distribution.



{dlgtab: Standard Errors}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes
        types that are robust to some kinds of misspecification (robust), that
        allow for intragroup correlation (cluster clustvar), and that are
        derived from asymptotic theory (oim, opg); see {manhelp vce_option R}.

{phang}
{opt robust} use robust standard errors.

{phang}
{cmd: cluster(}{varlist}{cmd:)} cluster standard errors with respect to sampling
unit {varlist}.

{dlgtab: Estimation}
		
{phang}
{cmd: initial(}{it: {help numlist}}{cmd:)} 
list of numbers that specifies the initial values of the parameters in the constant
only model. This must be equal to the number of distributional parameters; 
i.e. two for the normal and log-normal (mu, sigma), one for the Generalized Gamma (p), two for
the GB2 (p, q) and the SGED (p, lambda), and three for the SGT(p, q, lambda). 

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

{dlgtab: Display}

{phang}
{opt showc:onstonly} {cmd:: gintreg} will always estimate the constant only model
first prior to estimating the model with {indepvars}, but this output is suppressed.
 Use this option to see the estimate of the constant only model.
 
{phang}
{opt eyx(stat)} This option helps with inference in models with a positive distribution
(gb2, gg, lnormal). At the end of the STATA printout, it displays the estimated conditional value of the dependent variable
with respect to the independent variables being at the level of stat. This result is returned and is accessible after estimation
by e(eyx).

If stat is not specified then the independent variables will be taken at their mean levels:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: stat}{p_end}
{synopt:{cmd:mean}}mean values of independent variables{p_end}
{synopt:{cmd:min}}minimum values of independent variables{p_end}
{synopt:{cmd:max}}maximum values of independent variables{p_end}
{synopt:{cmd: p1}}1st percentile of independent variables{p_end}
{synopt:{cmd: p5}}5th percentile of independent variables {p_end}
{synopt:{cmd: p10}}10th percentile of independent variables{p_end}
{synopt:{cmd: p25}}25th percentile of independent variables{p_end}
{synopt:{cmd: p50}}50th percentile of independent variables{p_end}
{synopt:{cmd: p75}}75th percentile of independent variables{p_end}
{synopt:{cmd: p90}}90th percentile of independent variables{p_end}
{synopt:{cmd: p95}}95th percentile of independent variables{p_end}
{synopt:{cmd: p99}}99th percentile of independent variables{p_end}
{p2colreset}{...}




{marker remarks}{...}
{title:Remarks}

{pstd}
If the optimization is not working, try using the {opt dif:ficult} option. You can also use the option {cmd: technique(bfgs)}, or the other two {cmd: technique} options,
 which are often more robust than the default {cmd: technique(nr)}.


{marker examples}{...}
{title:Examples}

{pstd}
We have a dataset containing wages, truncated and in categories.  Some of
the observations on wages appear below

        wage1    wage2
{p 8 27 2}20{space 7}25{space 6} meaning  20000 <= wages <= 25000{p_end}
{p 8 27 2}50{space 8}.{space 6} meaning 50000 <= wages

{pstd}Load the example dataset{p_end}
{phang2}{cmd:. webuse intregxmpl}{p_end}

{pstd}Interval regression with a normal distribution{p_end}
{phang2}{cmd:. gintreg wage1 wage2 age nev_mar rural school tenure}

{pstd}Interval regression with a gb2 distribution (use difficult option) {p_end}
{phang2}{cmd:. gintreg wage1 wage2 age nev_mar rural school, distribution(gb2) difficult}

{pstd}Interval regression with a gb2 distribution with the expected value of the 
dependent variable evaluated when the independent variables are at the 25 percentile (E[Y|X] appears 
at the end of the printout {p_end}
{phang2}{cmd:. gintreg wage1 wage2 age, distribution(gb2) eyx(p25) difficult}


{pstd}Interval regression with a sgt distribution allowing sigma to vary as a function of independent variables{p_end}
{phang2}{cmd:. gintreg wage1 wage2 age nev_mar rural school tenure, distribution(sgt) sigma(age nev_mar rural school tenure)}

{pstd}Interval regression using the burr3 distribution {p_end}
{phang2}{cmd:. constraint define 1 [q]_cons=1}

{phang2}{cmd:. gintreg wage1 wage2 age nev_mar rural school tenure, distribution(gb2) constraints( 1 )}

{pstd}Interval regression with a gg distribution with initial values specified p value{p_end}
{phang2}{cmd:. gintreg wage1 wage2 age nev_mar rural school tenure, distribution(gg) initial(1)}

{marker author}{...}
{title:Author}

{phang}
Authored by James McDonald and Jacob Orchard at Brigham Young University. For
support contact Jacob at orchard.jake@gmail.com.


{marker references}{...}
{title:References}

{phang}
James B., McDonald, Olga Stoddard, and Daniel Walton. 2016.
{it:On using interval response data in experimental economics},
working paper.

{phang}
James B., McDonald, and Daniel Walton. 2016.
{it: Distributional Assumptions and the Estimation of Contingent Valuation Models.}


