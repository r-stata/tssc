{smcl}
{* Help file update 2020-04-21,2010-05-20,2010-03-09, 2009-09-15}{...}
{hline}
help for {hi:sgini}{right:P. Van Kerm (April 2020, February 2010, September 2009)}
{hline}

{title:Title}

{pstd}{hi:sgini} {hline 2} Generalized Gini and Concentration coefficients (with factor decomposition)


{title:Syntax}

{p 8 15 2}
{cmd:sgini}
{it:varlist} 
[{it:weight}] 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
[{cmd:,} {it:options}]

{synoptset 22 tabbed}
{synopthdr}
{synoptline}
{synopt :{opth p:arameters(numlist)}}specifies inequality aversion parameters{p_end}
{synopt :{opt source:decomposition}}requests factor decomposition (decomposition by source){p_end}
{synopt :{opt aggr:egate}} switches to computation of S-Gini welfare indices{p_end}
{synopt :{opt wel:fare}} is synonymous to {opt aggr:egate}{p_end}
{synopt :{opt abs:olute}}switches to computation of absolute S-Gini indices{p_end}
{synopt :{opth s:ortvar(varname)}}sets ordering variable for Concentration coefficients{p_end}
{synopt :{opth frac:rankvar(varname)}}passes a varname with existing fractional ranks{p_end}
{synopt :{opth for:mat(%fmt)}}display format; default is {cmd:format(%5.4f)}{p_end}
{synoptline}

                  
{p 4 8 2}
  {it:varlist} may contain time-series operators; see {help tsvarlist}.
{p_end}
{p 4 6 2}{cmd:bootstrap}, {cmd:jackknife}, {cmd:svy bootstrap}, and {cmd:svy jackknife} prefixes are allowed; see {help prefix}.{p_end}
{p 4 6 2}{cmd:fweight}, {cmd:aweight} and {cmd:pweight} are allowed; see help {help weights:weights}.
{p_end}


{title:Description}

{pstd}
{hi:sgini} is a command for calculations of generalized Gini (a.k.a. S-Gini) and Concentration 
coefficients from unit-record data. {hi:sgini} computes relative (scale invariant) 
Gini indices of inequality by default but can be requested to produce absolute (translation invariant) 
indices or aggregate welfare S-Gini indices. The command can also optionally report decomposition by 
factor components (income sources).
{p_end}

{pstd} 
Multiple variables and multiple inequality aversion parameters can be passed to {hi:sgini}. Beware that if 
multiple variables are input, {hi:sgini} will discard observations with missing data on {it:any} of the
input variables and compute all coefficients on the resulting sample.
{p_end}

{pstd} 
{cmd:sgini} does not provide sampling variance estimates (as an r-class command) but it is easily bootstrapped using 
a {cmd:bootstrap} or {svy bootstrap} prefix. See the user-written {help svylorenz}, {help lorenz} or {help inequaly} for
estimation of Gini coefficients with (analytic) standard errors. 
{p_end}

{pstd}
An accompanying {browse "http://www.vankerm.net/stata/manuals/sgini.pdf":online manual} provides details on formulas, option 
descriptions and usage examples.
{p_end}


{title:Options}

{phang}
{opth p:arameters(numlist)} specifies inequality aversion parameters. Default is 2 leading to the standard Gini and
Concentration coefficients. Multiple parameters can be requested.
{p_end}

{phang}
{opth s:ortvar(varname)} sets ordering variable for Concentration coefficients. Default is to cumulate the variable(s) 
of interest against themselves, leading to Gini coefficients.
{p_end}

{phang}
{opth frac:rankvar(varname)} passes the name of an existing variable containing fractional ranks based on which
the Gini and Concentration coefficients can be computed. This is a rarely used and dangerous option, but it may 
provide considerable speed gains under certain circumstances. 
It is essential that the fractional rank variable be computed correctly (using e.g. {hi:fracrank}), and on the adequate (sub-)sample (think missing data, {hi:if} clauses, ordering). Use carefully!
{p_end}

{phang}
{opt source:decomposition} requests factor decomposition of indices. It is relevant when more than one variable is passed
in {it:varlist}. It requests that a variable be created by taking the row sum of all elements in {it:varlist}, 
computes the Gini (or Concentration) coefficient for this created variable, and estimates the contribution of 
each element of {it:varlist} to the latter by applying the 'natural' decomposition rule for Gini coefficients
(see Lerman & Yitzhaki, 1985).
{p_end}

{phang}
{opt aggr:egate} and {opt abs:olute} request, respectively, computation of aggregate S-Gini welfare measures 
or computation of absolute Gini and Concentration coefficients, instead of the relative inequality measures.
They are mutually exclusive and incompatible with {opt sourcedecomposition}. {opt welf:are} is synonymous to {opt aggr:egate}.
{p_end}

{phang}
{opth format(%fmt)} controls the display format; default is {cmd:format(%5.4f)}.
{p_end}


{title:Saved Results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(coeffs)}}estimated coefficients{p_end}
{synopt:{cmd:r(parameters)}}parameters from {opth param(numlist)}{p_end}
{synopt:{cmd:r(r)}}Gini correlations between source and total income (if {opt sourcedecomposition} requested){p_end}
{synopt:{cmd:r(c)}}Concentration coefficients of each source (if {opt sourcedecomposition} requested){p_end}
{synopt:{cmd:r(elasticity)}}elasticities between source and total Gini (if {opt sourcedecomposition} requested){p_end}
{synopt:{cmd:r(s)}}factor shares (if {opt sourcedecomposition} requested){p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(sum_w)}}sum of weights{p_end}
{synopt:{cmd:r(coeff)}}estimated coefficient for first variable, first parameter{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(varlist)}}{it:varlist}{p_end}
{synopt:{cmd:r(paramlist)}}list of parameters from {opth param(numlist)}{p_end}
{synopt:{cmd:r(sortvar)}}{it:varname} if {opth sortvar(varname)} specified{p_end}


{title:Example}

{p 8 12 2}{inp:. use http://www.stata-press.com/data/r9/nlswork , clear }

{p 8 12 2}{inp:. tsset idcode year }

{p 8 12 2}{inp:. gen w = exp(ln_wage) }

{p 8 12 2}{inp:. sgini w }

{p 8 12 2}{inp:. sgini w , param(1.5(.5)5) absolute}

{p 8 12 2}{inp:. sgini w L.w L2.w}

{p 8 12 2}{inp:. sgini w L.w L2.w , sortvar(w)}

{p 8 12 2}{inp:. sgini w L.w L2.w  , source}

{p 8 12 2}{inp:. bootstrap G=r(coeff) , reps(250) nodots : /// }

{p 8 12 2}{inp: {space 5} sgini w if !mi(w) }

{p 8 12 2}{inp:. jackknife G=r(coeff) rclass nodots : /// }

{p 8 12 2}{inp: {space 5} sgini w if !mi(w) }


{title:References}

{p 4 8 2}Chotikapanich, D. C. & Griffiths, W. (2001), On calculation of the extended gini coefficient, Review of Income and Wealth, 47: 541{c -}547.

{p 4 8 2}Lerman, R. I. & Yitzhaki, S. (1985), Income inequality effects by income source: A new approach and applications to the United States, Review of Economics and Statistics, 67(1): 151{c -}156.

{p 4 8 2}Lopez-Feldman, A. (2006), Decomposing inequality and obtaining marginal effects, Stata Journal, 6(1): 106{c -}111.


{title:Also see}

{psee}
Manual:  {bf:[R] inequality}

{psee}
Online:  {helpb descogini} (if installed), {helpb ineqdeco} (if installed), {helpb svylorenz} (if installed), {helpb inequal7} (if installed),
among {stata "findit gini inequality":several others}


{title:Author}

{pstd}Philippe Van Kerm, Luxembourg Institute of Socio-Economic Research (LISER) and University of Luxembourg, philippe.vankerm@liser.lu


{title:Acknowledgments}

{pstd}
This package was originally written for the MeDIM project 
({it:Advances in the Measurement of Discrimination, Inequality and Mobility}) 
supported by the Luxembourg Fonds National de la Recherche (contract FNR/06/15/08) 
and by core funding for CEPS/INSTEAD by the
Ministry of Culture, Higher Education and Research of Luxembourg. 


{* Version 4.0 2020-04-21}
{* Version 3.0 2010-02-05}
{* Version 2.0 2009-09-15}