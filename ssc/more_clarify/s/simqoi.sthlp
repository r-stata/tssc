{smcl}
{* *! version 1.0}{...}
{cmd:help simqoi}
{hline}

{title:Title}

{phang}
{bf:simqoi} {hline 2} Simulate quantities of interest


{title:Syntax}

{p 8 17 2}
{cmdab:simqoi}
{ifin}
{bf:{help using}} {it:filename}
{weight}
[{cmd:,} 
{it:{help simqoi##quantity_of_interest:quantity_of_interest}}
{it:{help simqoi##options_table:options}}] 


{marker response_options}{...}
{synoptset 22 tabbed}{...}
{synopthdr:quantity_of_interest}
{synoptline}
{synopt :{opt ev}}simulate expected values; the default{p_end}
{synopt :{opt pv}}simulate predicted values{p_end}
{synopt :{opt diff}}simulate the difference between two expected values{p_end}
{synopt :{opt rat:io}}simulate the ratio of two expected values{p_end}
{synoptline}

{marker options_table}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt:{opt dep:var(eqno)}}specify the dependent variable{p_end}
{synopt:{opt gen:erate(stubname)}}save simulated values as variables with prefix {it:stubname}{p_end}
{synopt :{opt d:ouble}}generate variable type as {cmd: double}; default is {cmd :float}{p_end}
{synopt :{opt seed(#)}}set random-number seed to {it:#}{p_end}

{syntab:At}
{synopt:{cmd:at(}{it:{help simqoi##atspec:atspec}{cmd:)}}}simulate
        quantity of interest at specified values of covariates{p_end}
{synopt:{opt noe:sample}}do not restrict calculation of statistics to the
		estimation sample{p_end}
{synopt:{opt now:eights}}ignore weights specified in estimation{p_end}
{synopt:{opt noo:ffset}}ignore any {opt offset()} or {opt exposure()} variable{p_end}

{syntab:Reporting}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt:{opt noh:eader}}suppress output header{p_end}
{synopt:{opt nol:abel}}display numeric codes rather than value labels{p_end}
{synopt:{opt noa:ttable}}suppress table of fixed covariate values{p_end}
{synoptline}

{p2colreset}{...}
{pstd}
The {ifin} qualifiers restrict the scope of {opt at()} to those observations
for which the value of the expression is true.{p_end}
{pstd}
See {bf:{help simqoi##at_op:at()}} under {it:Options} for a description
of {it:atspec}.{p_end}
{pstd}
{cmd:fweight}s, {cmd:aweight}s and {cmd:pweight}s are allowed; see {help weight}.
{p_end}


{title:Description}

{pstd}
{cmd:simqoi} implements a simulation-based approach for transforming the raw output of
regression models into quantities of substantive interest. 
This approach has been discussed, among others, by
{help simqoi##refs:Dowd et al. (2014)},
{help simqoi##refs:Gelman and Hill (2007)},
{help simqoi##refs:King et al. (2000)} and
{help simqoi##refs:Krinsky and Robb (1986; 1990; 1991)}.

{pstd}
Specifically, {cmd:simqoi} simulates predicted and expected values of the outcome variable 
using the parameters stored by {helpb bootstrap} or {helpb postsim}.
{cmd:simqoi} also includes a {it: wrapper} for simulating differences and ratios of two 
expected values.

{pstd}
Users can further transform the simulations produced by {cmd:simqoi} into any function of
interest through basic data manipulation.
Point estimates and measures of uncertainty of these functions can be assessed with 
simple descriptive statistics (mean, median, standard deviation, centile-based confidence 
intervals, etc.).
This technique is very convenient for tackling complex, non-linear functions of predicted 
and expected values that are difficult to derive with standard analytical methods.

{pstd}
{cmd:simqoi} currently supports the following estimation commands:

{synoptset 20 tabbed}{...}
{p2coldent :command}description{p_end}
{synoptline}
{syntab:Linear regression models}
{p2col :{helpb cnsreg}}Constrained linear regression{p_end}
{p2col :{helpb eivreg}}Errors-in-variables regression{p_end}
{p2col :{helpb regress}}Linear regression{p_end}
{p2col :{helpb skewnreg}}Skew-normal linear regression{p_end}
{p2col :{helpb skewtreg}}Skew-t linear regression{p_end}
{p2col :{helpb tobit}}Tobit regression{p_end}

{syntab:Binary-response regression models}
{p2col :{helpb biprobit}}Bivariate probit regression{p_end}
{p2col :{helpb blogit}}Logistic regression for grouped data{p_end}
{p2col :{helpb bprobit}}Probit regression for grouped data{p_end}
{p2col :{helpb cloglog}}Complementary log-log regression{p_end}
{p2col :{helpb hetprob}}Heteroskedastic probit regression{p_end}
{p2col :{helpb logistic}}Logistic regression, reporting odds ratios{p_end}
{p2col :{helpb logit}}Logistic regression, reporting coefficients{p_end}
{p2col :{helpb probit}}Probit regression{p_end}
{p2col :{helpb scobit}}Skewed logistic regression{p_end}

{syntab:Discrete-response regression models}
{p2col :{helpb mlogit}}Multinomial (polytomous) logistic regression{p_end}
{p2col :{helpb ologit}}Ordered logistic regression{p_end}
{p2col :{helpb oprobit}}Ordered probit regression{p_end}

{syntab:Poisson regression models}
{p2col :{helpb gnbreg}}Generalized negative binomial model{p_end}
{p2col :{helpb nbreg}}Negative binomial regression{p_end}
{p2col :{helpb poisson}}Poisson regression{p_end}
{p2col :{helpb zinb}}Zero-inflated negative binomial regression{p_end}
{p2col :{helpb zip}}Zero-inflated Poisson regression{p_end}

{syntab:Instrumental-variables regression models}
{p2col :{helpb ivregress}}Single-equation instrumental-variables regression{p_end}

{syntab:Regression models with selection}
{p2col :{helpb heckman}}Heckman selection model{p_end}
{p2col :{helpb heckprob}}Probit model with sample selection{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
{cmd:simqoi} can be used with {helpb svy} estimation results; see
{manhelp svy_estimation SVY:svy estimation}.


{title:Options}

{dlgtab:Main}

{phang}
{cmd: depvar(#}{it:#} | {it:name}{cmd:)} is relevant only when you have previously fit
  a model with two dependent variables in {cmd:e(depvar)}.
	It specifies the equation to which you are referring.
	The default is {cmd:depvar(#1)}.
	{opt depvar()} can be specified using

{pin2}
	{cmd:#1}, {cmd:#2}, ..., where {cmd:#1} means the first equation,
	{cmd:#2} means the second equation, etc.; or

{pin2}
	the name of the dependent variable.

{phang}
{opth generate(newvar)} specifies that the simulated values be stored as variables 
  named {it:stubname1}, {it:stubname2},{it: ...}.
  Each observation in each new variable contains one simulated value.

{phang}
{opt double} specifies that the new variables be stored as Stata {opt double}s, 
  meaning 8-byte reals. 
  If {opt double} is not specified, variables are stored as {opt float}s, 
  meaning 4-byte reals. 
  See {manhelp data_types D:data types}.

{phang}
{opt seed(#)} sets the random-number seed.
	Specifying this option is equivalent to typing the following command prior
	to calling {cmd:simqoi}:

{phang2}
{cmd:. set seed} {it:#}

{dlgtab:At}

{marker at_op}{...}
{phang}
{opt at(atspec)} specifies values for covariates to be treated as fixed.
	The default is {cmd:at((mean) _all)}.

{phang2}
    {cmd:at(age=20)} fixes covariate {cmd:age} to the value specified.
    {cmd:at()} may be used to fix continuous or factor covariates.

{phang2}
    {cmd:at(age=20 sex=1)} simultaneously fixes covariates {cmd:age}
    and {cmd:sex} at the values specified.

{phang2}
    {cmd:at(age=(20 30 40 50))} fixes age first at 20, then at 30, etc.
    {cmd:simqoi} produces separate results for each specified value.

{phang2}
    {cmd:at(age=(20(10)50))} does the same as
    {cmd:at(age=(20 30 40 50))}; that is, you may specify a
    {help numlist}.

{phang2}
    {cmd:at((mean) age{bind:  }(median) distance)}
    fixes the covariates at the summary statistics specified.
    {cmd:at((p25) _all)} fixes all covariates at their 25th percentile
    values.
    See {it:{help simqoi##atspec:Syntax of at()}} for the full list
    of summary-statistic modifiers.

{phang2}
	{cmd:at((mean) _all{bind:  }(median) x{bind:  }x2=1.2{bind:  }z=(1 2 3))}
	is read from left to right, with latter specifiers overriding former ones.
	Thus all covariates are fixed at their means except for
	{cmd:x} (fixed at its median), {cmd:x2} (fixed at 1.2), and
	{cmd:z} (fixed first at 1, then at 2, and finally at 3).

{phang2}
	{cmd:at((means) _all{bind:  }(median) x2)}
	is a convenient way to set all covariates except {cmd:x2} to the mean.

{phang2}
	See {it:{help simqoi##atspec:Syntax of at()}} for more information.

{phang}
{opt noesample}
	affects {opt at(atlist)}.
	It specifies that the whole dataset be considered instead of only those
	observations marked in the {cmd:e(sample)} defined by the previous estimation
	command.

{phang}
{opt noweights}
  affects {opt at(atlist)}.
	It specifies that any weights specified on the previous estimation command be 
  ignored. 
	By default {cmd:simqoi} uses the weights specified on the estimator to compute         
  summary statistics.
	If {it:weights} are specified on the {cmd:simqoi} command they override previously 
  specified weights, 
	making it unnecessary to specify {cmd:noweights}.

{phang}
{opt nooffset}
  specifies that the calculation should be made, ignoring any offset or exposure
  variable specified when the model was fit.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt nolabel} requests that value labels attached to the dependent variable in 
the model be ignored.

{phang}
{opt noheader} prevents the table header from being displayed.

{phang}
{opt noattable} prevents the table of fixed covariate values from being displayed.


{marker atspec}{...}
{title:Syntax of {opt at()}}

{pstd}
In option {cmd:at(}{it:atspec}{cmd:)},
{it:atspec} may contain one or more of the following specifications:

{p 12 12 2}
{it:varlist}

{p 12 12 2}
{cmd:(}{it:stat}{cmd:)} {it:varlist} 

{p 12 12 2}
{it:varname} {cmd:=} {it:#}

{p 12 12 2}
{it:varname} {cmd:= (}{it:{help numlist}}{cmd:)} 

{pstd}
where

{p 12 15 2}
    1. {it:varname}s must be covariates in the current estimation results.

{p 12 15 2}
    2. Variable names (whether in {it:varname} or {it:varlist}) 
       may be continuous variables, factor variables, or virtual level
       variables, such as {cmd:age}, {cmd:group}, or {cmd:3.group}.

{p 12 15 2}
3. {it:varlist} may also be one of three standard lists:
{p_end}
{p 19 22 2}
a. {opt _all} (all covariates),
{p_end}
{p 19 22 2}
b. {opt _f:actor} (all factor-variable covariates), or
{p_end}
{p 19 22 2}
c. {opt _c:ontinuous} (all continuous covariates).
{p_end}

{p 12 15 2}
4. Specifications are processed from left to right with latter specifications 
   overriding previous ones.

{p 12 15 2}
5. {it:stat} can be any of the following:

{p2colset 5 22 24 2}{...}
{p2line}
{p2col :}                                       {space 44}variables{p_end}
{p2col :{it:stat}} description                  {space 32}allowed{p_end}
{p2line}
{p2col :{opt mean}}   means (default)		{space 28}all{p_end}
{p2col :{opt median}} medians                   {space 36}continuous{p_end}
{p2col :{opt p1}}     1st percentile            {space 29}continuous{p_end}
{p2col :{opt p2}}     2nd percentile            {space 29}continuous{p_end}
{p2col :{it:...}}     3rd-49th percentiles 	{space 23}continuous{p_end}
{p2col :{opt p50}}    50th percentile (same as {cmd:median}) 
                                                {space 11}continuous{p_end}
{p2col :{it:...}}     51st-97th percentiles 	{space 22}continuous{p_end}
{p2col :{opt p98}}    98th percentile           {space 28}continuous{p_end}
{p2col :{opt p99}}    99th percentile           {space 28}continuous{p_end}
{p2col :{opt min}}    minimums                  {space 35}continuous{p_end}
{p2col :{opt max}}    maximums                  {space 35}continuous{p_end}
{p2col :{opt zero}}   fixed at zero             {space 30}continuous{p_end}
{p2col :{opt base}}   base level                {space 33}factors{p_end}
{p2line}
{p2colreset}{...}


{title:Examples}

{pstd}
These examples are intended for quick reference. For more intricate examples with 
discussion see the program's {browse "http://javier-marquez.com/software/moreclarify":website}.


{title:Example: {help simqoi##refs:Dowd, Greene and Norton (2014)}}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse margex}{p_end}

{pstd}Bootstrap replications{p_end}
{phang2}{cmd:. bootstrap, saving(boots) reps(1000): logit outcome c.age##i.sex}{p_end}

{pstd}Expected value (predicted probability){p_end}
{phang2}{cmd:. simqoi using boots, ev at(age=50 sex=1)}{p_end}

{pstd}Partial effect{p_end}
{phang2}{cmd:. simqoi using boots, diff at(age=(50 51) sex=1)}{p_end}

    {hline}

{pstd}Post-estimation simulation (Krinsky-Robb method){p_end}
{phang2}{cmd:. {helpb postsim}, saving(sims) reps(1000): logit outcome c.age##i.sex}{p_end}

{pstd}Expected value (predicted probability){p_end}
{phang2}{cmd:. simqoi using sims, ev at(age=50 sex=1)}{p_end}

{pstd}Partial effect{p_end}
{phang2}{cmd:. simqoi using sims, diff at(age=(50 51) sex=1)}{p_end}


{title:Saved results}

{pstd}
{cmd:simqoi} saves the following in {cmd:r()}:

{synoptset 13 tabbed}{...}
{p2col 5 13 17 2: Scalars}{p_end}
{synopt:{cmd:r(N_reps)}}number of simulations{p_end}

{synoptset 13 tabbed}{...}
{p2col 5 13 17 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}{cmd:simqoi}{p_end}
{synopt:{cmd:r(qi)}}{cmd:ev} or {cmd:pv}{p_end}
{synopt:{cmd:r(level)}}# from level(#) option{p_end}
{synopt:{cmd:r(atstats)}}list of keywords associated with the {cmd:at()} option; 
a keyword is either {cmd:value} or one of {it:stat}s{p_end}
{synopt:{cmd:r(wtype)}}weight type{p_end}
{synopt:{cmd:r(wexp)}}weight expression{p_end}
{synopt:{cmd:r(seed)}}initial random-number seed{p_end}

{synoptset 13 tabbed}{...}
{p2col 5 13 17 2: Matrices}{p_end}
{synopt:{cmd:r(b)}}mean of simulated values{p_end}
{synopt:{cmd:r(se)}}standard errors{p_end}
{synopt:{cmd:r(lb)}}lower confidence bound{p_end}
{synopt:{cmd:r(ub)}}upper confidence bound{p_end}
{synopt:{cmd:r(Results)}}Results{p_end}
{synopt:{cmd:r(at)}}matrix of values from the {cmd:at()} option{p_end}


{marker refs}{...}
{title:References}

{phang}
Dowd, Bryan E., William H. Greene, and Edward C. Norton. 2013.
Computation of Standard Errors. 
{it:Health Services Research} 49, no. 2: 731-750.

{phang}
Gelman, Andrew and Jennifer Hill. 2007. 
{it:Data Analysis using Regression and Multilevel/Hierarchical Models}. 
Cambridge University Press.

{phang}
King, Gary, Michael Tomz, and Jason Wittenberg. 2000.
Making the Most of Statistical Analyses: 
Improving Interpretation and Presentation.
{it:American Journal of Political Science} 44, no. 2: 347-61.

{phang}
Krinsky, Itzhak and A. Leslie Robb. 1986.
On Approximating the Statistical Properties of Elasticities.
{it:The Review of Economics and Statistics} 68, no. 4: 715-19.

{phang}
Krinsky, Itzhak, and A. Leslie Robb. 1990
On Approximating the Statistical Properties of Elasticities: A Correction.
{it:The Review of Economics and Statistics} 72, no. 1: 189-90.

{phang}
Krinsky, Itzhak and A. Leslie Robb. 1991.
Three Methods for Calculating the Statistical Properties of Elasticities: A Comparison. 
{it:Empirical Economics} 16, no. 2: 199-209.


{title:Author}

{phang}
Javier M{c a'}rquez Pe{c n~}a,{break}
Buend{c i'}a & Laredo, Mexico City.{break}
javier.marquez@buendiaylaredo.com{break}
{browse "http://javier-marquez.com/software/moreclarify"}


{title:Also see}

{psee}
{space 2}Help:  {cmd:{help postsim}}, {cmd:{help simqi}} (if installed);{break}
{manhelp bootstrap R}, {manhelp jackknife R}, {manhelp permute R}.
{p_end}