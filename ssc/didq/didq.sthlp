{smcl}
{* *! version 1.4  06Mar2015}{...}
{cmd:help didq} 
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{hi: didq} {hline 2} Difference-in-differences estimations under alternative Parallel-{it:q} assumptions.}
{p2colreset}{...}

{title:Syntax}
	
{p 8 16 2}
{opt didq} {depvar} [{indepvars}] {ifin} {weight} {cmd:,} {opt tr:eated(treatvar)} {opt t:ime(timevar)} [{it:options}]

{synoptset 20 tabbed}{...}

{synopthdr}
{synoptline}
{syntab: Model: Required}
{synopt :{opt tr:eated(treatvar)}}specifies the treatment variable{p_end}
{synopt :{opt t:ime(timevar)}}specifies the time variable{p_end}

{syntab: Model}
{synopt :{opt b:egin(integer)}}sets the first period the treatment effect is estimated{p_end}
{synopt :{opt e:nd(integer)}}sets the last period the treatment effect is estimated{p_end}
{synopt :{opt q(integer)}}specifies the highest Parallel-{it:q} assumption to be used{p_end}
{synopt :{opt ff}}estimates the fully flexible model (the default option){p_end}
{synopt :{opt standard}}estimates the standard model with common flexible dynamics{p_end}
{synopt :{opt linear}}as the standard model plus a linear trend difference between treated and controls{p_end}
{synopt :{opt quadratic}}as the standard model plus a quadratic trend difference between treated and controls{p_end}
{synopt :{opt force}}estimates auxiliary model even if the variance-covariance matrix X'X of controls is not invertible{p_end}

{syntab:SE/Robust}
{synopt: {opt robust}}uses the Huber/White/sandwich estimator (the default option){p_end}
{synopt: {opt cluster:(varname)}}uses the clustered sandwich estimator{p_end}

{syntab:Reporting}
{synopt: {opt detail}}displays additional statistics{p_end}
{synopt: {opt level(#)}}sets confidence level as a percentage{p_end}
{synopt: {opt a:uxiliary}}displays regression output from auxiliary regression{p_end}
{hline}

{p 4 4 2}
{it:depvar} and {it:indepvars} must be numeric; see {help datatype}{break}
{* {it:indepvars} may contain factor variables; see {help fvvarlist}{break}}
{* {it:depvar} and {it:indepvars} may contain time-series operators; see {help tsvarlist}{break}}
{opt by} is allowed; see {help prefix}{break}
{opt aweights}, {opt fweights}, {opt iweights}, and {opt pweights} are allowed; see {help weight}{p_end}

{title:Description}

{pstd}
{cmd:didq} performs difference-in-differences estimations under alternative Parallel-{it:q} assumptions as proposed by Mora and Reggio (2012).

{title:Options}

{dlgtab:Model: Required}

{phang}
{opt treated(treatvar)} specifies that {it:treatvar} indicates treatment. {it:treatvar} must take value {cmd:0} 
 for observations from the control group and value {cmd:1} for observations from the treated group.

{phang}
{opt time}{cmd:(}{it:timevar}{cmd:)} sets {it:timevar} as the time variable. {it:timevar} must be an integer variable (i.e., byte, int, or long).

{dlgtab:Model}

{phang}
{opt begin}{cmd:(}{it:#b}{cmd:)} specifies the first period at which treatment effects are evaluated. Hence, using the notation of the output display, at {it:timevar}={it:#b}, {cmd:s}={cmd:1}. 

{phang}
{opt end}{cmd:(}{it:#e}{cmd:)} specifies the last period at which effects are evaluated. Values {it:#b} and {it:#e} must be such that {it: min}({it:timevar}) <  {it:#b} {ul:<} {it:#e} {ul:<} {it: max}({it:timevar}). 
If neither {cmd:begin()} nor {cmd:end()} are specified, then both are set equal to {it: max}({it:timevar}), i.e., by default the last period in {it:timevar} is assumed to be the only post-treatment period. 
If either {cmd:begin()} or {cmd:end()} is not specified, then it is set equal to the one specified.

{phang}
{opt q}{cmd:(}{it:#q}{cmd:)} specifies the highest Parallel-{it:q} assumption to be used  (only relevant with option {opt ff}). It must lie between 1 and the number of pre-treatment periods, {it:Q}. 
For example, with only two pre-treatment periods, {it:#q} can be, at most, equal to 2. With {it:#q} equal to 2, the analysis is conducted under both Parallel Paths ({it:q}=1) 
and Parallel Growths ({it:q}=2). If option {cmd:q()} is not specified or {it:#q} is set larger than {it:Q}, then {it:#q} is set equal to {it:Q}.

{phang}
{opt ff} estimates the fully flexible model. This is the default if no model is specified. 
When the fully flexible model is chosen, {cmd:didq} displays point estimates and standard errors of treatment effects under each Parallel-{it:q} assumption between Parallel-1 and Parallel-{it:#q}. 
For each {it:q}, {cmd:didq} computes the treatment effects up to {it:S} periods, where {it:S}={it:#e}-{it:#b}+1. By default, effects only up to {it:s}=3 are displayed.
To see the effects for {it:s} larger than 3, the option {cmd:detail} should be used.
For example, assume that there are 3 periods before treatment and we set {it:#q}=3, {it:#b}=4, and {it:#e}=5.
In this case, {cmd:didq} will obtain for Parallel-1, Parallel-2, and Parallel-3 assumptions the treatment estimates one period ({cmd:s}={cmd:1}) and two periods ({cmd:s}={cmd:2}) after treatment. 
{cmd:didq} additionally displays tests for 
(a) the equivalence of all Parallel-{it:q} assumptions between Parallel-1 and Parallel-{it:Q}; 
(b) for each Parallel-{it:q} assumption where {it:q}=2,..,{it:#q}, the equivalence of Parallel-{it:q} and Parallel-({it:q-1}); 
and (c) for each Parallel-{it:q} assumption where {it:q}=1,..,{it:#q}, the absence of dynamics in treatment effects between {it:#b} and {it:#e}.

{phang}
{opt standard} estimates the standard model with common flexible dynamics. This model implicitly assumes the equivalence of all Parallel-{it:q} assumptions between Parallel-1 and Parallel-{it:Q}
 and the absence of dynamics in treatment effects. The output displayed includes the estimate and standard error of the diff-in-diff estimator as well as 
tests for (a) the equivalence of all Parallel-{it:q} assumptions between Parallel-1 and Parallel-{it:Q}; and (b) the absence of dynamics in treatment effects between {it:#b} and {it:#e}.

{phang}
{opt linear} estimates the standard model with common flexible dynamics and a linear trend difference between treated and controls. This model implicitly assumes 
the equivalence of all Parallel-{it:q} assumptions between Parallel-2 and Parallel-{it:Q} and the absence of dynamics in treatment effects.
The output displayed includes the estimate and standard error of the diff-in-diff estimator as well as tests for 
(a) the equivalence of all Parallel-{it:q} assumptions between Parallel-2 and Parallel-{it:Q};
and (b) the absence of dynamics in treatment effects between {it:#b} and {it:#e}.

{phang}
{opt quadratic} estimates the standard model with common flexible dynamics and a quadratic trend difference between treated and controls. This model implicitly assumes the
 equivalence of all Parallel-{it:q} assumptions between Parallel-3 and Parallel-{it:Q} and the absence of dynamics in treatment effects. 
The output displayed includes the estimate and standard error of the diff-in-diff estimator as well as tests for 
(a) the equivalence of all Parallel-{it:q} assumptions between Parallel-3 and Parallel-{it:Q}; 
and (b) the absence of dynamics in treatment effects between {it:#b} and {it:#e}.

{dlgtab:SE/Robust}

{phang}
{opt robust} the default, uses the Huber/White/sandwich estimator

{phang}
{opth cluster(varname)} clustered sandwich estimator (see {help vce_option})

{dlgtab:Reporting}

{phang}
{opt detail} displays the treatment effects for {it:s} larger than 3 and also some additional statistics: t-ratios, p-values, and confidence intervals of all estimates (only relevant with {opt ff}).

{phang}
{opt level(#)} sets confidence level as a percentage (only relevant with {opt detail}); default is {opt level(95)}

{title:Remarks}

{p 4 4 2}
The data must contain at least two observations per group and period combinations. 
There must be at least one period before treatment starts and one period after treatment ends. 
The data set must contain a variable that identifies the period from which each observation is drawn, and a time-invariant treatment variable that signals treatment. 
The output and the treatment variables must be numeric. 
The time variable must be an integer (i.e. must be either byte, int, or long). 
In addition, for the computations in didq to be meaningful, the difference between any two consecutive periods should be equal to one.

{pstd}
Only one model may be specified. 

{pstd}
{cmd: didq} is an e-class ado. It first estimates an auxiliary regression and then it computes the treatment effects as linear combinations of the estimates of the auxiliary regression. 
In addition to the treatment effects and their standard errors, it also saves the vector of coefficient estimates of the auxiliary regression and their variance-covariance matrix.

{title:Examples}

{p 4 8 2}
Consider the following simulated data:

{p 4 8 2}
{stata "use didq_examples.dta, clear"}

{p 4 8 2} 
{stata "describe"}

{p 4 8 2} 
Variable {it: t} is the variable that describes the period of the observation. There are five periods and treatment takes place between periods 3 and 4. 
Variable {it: output} measures the output on which we want to estimate the effects. 
Variable {it:D} takes value 1 if treated and 0 otherwise. Variables {it: x1} and {it:x2} are additional controls.

{p 4 4 2}
Restrict the sample to periods 3 and 4: {stata "drop if t<3 | t>4"}. The following example estimates the treatment effect in the fourth period with the standard model under the Parallel Paths Assumption:{p_end}


{p 8 16 2}{cmd:. didq output, treated(D) time(t) standard }{p_end}

{p 4 4 2}
Using the original data set:{p_end}

{p 8 16 2}{cmd:. didq output if (t==3 | t==4), treated(D) time(t) standard }{p_end}

{p 4 4 2}
Assume now that we only want to use periods 2, 3, and 4. The following example provides two alternative estimates of the treatment effect (under Parallel-1, and under Parallel-2) using the fully flexible model:{p_end}

{p 8 16 2}{cmd:. didq output if (t>1 & t<5), treated(D) time(t)}{p_end}

{p 4 4 2}
With only three periods, the treatment effect estimate under Parallel-2 is equivalent to the estimate of the treatment effect with the standard model and linear deterministic trends:{p_end}

{p 8 16 2}{cmd:. didq output if (t>1 & t<5), treated(D) time(t) linear} {p_end}


{p 4 4 2}
With three pre{c -}treatment periods (1,2,3) and two post{c -}treatment periods (4,5), {cmd:end} can be either 4 or 5 and {cmd: q} can be 1, 2, or 3:{p_end}

{p 8 16 2} // fully flexible model, q=1,2,3, s=1{p_end}
{p 8 16 2}{cmd:. didq output, treated(D) time(t) begin(4) end(4) }{p_end}

{p 8 16 2} // fully flexible model, q=1,2, s=1,2{p_end}
{p 8 16 2}{cmd:. didq output, treated(D) time(t) begin(4) end(5) q(2)} {p_end} 

{p 4 4 2}Additional controls can be added{p_end}

{p 8 16 2}{cmd:. didq output x1 x2, treated(D) time(t) begin(4) end(4) }{p_end}

{title:Saved results}

{pstd}
{cmd:didq} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(common_trend)}}the Wald test of the joint significance of all interactions of pre-treatment time dummies and the treatment dummy{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(alpha)}}{it:#q}x{it:S} matrix of effect estimates{p_end}
{synopt:{cmd:e(std_alpha)}}{it:#q}x{it:S} matrix of standard errors of effect estimates{p_end}
{synopt:{cmd:e(beta)}}vector of estimates in auxiliary regression. The first elements of {cmd:e(beta)} are the estimates of the coefficients for the interactions between the treatment variable and the time dummies in the fully flexible model. 
For the standard, linear, and quadratic model, the first elements are the estimates of the coefficients of the interactions between the treatment variable and the corresponding polynomial elements (i.e., constant, linear, and quadratic terms).
In all models, the estimate of the treatment coefficient is next. Then, the estimates for the coefficients for the common time dummies follow. 
Finally, {cmd:e(beta)} includes estimates for the coefficients for the additional controls (when available) and the constant{p_end}
{synopt:{cmd:e(Vbeta)}}(co)variance estimates in auxiliary regression{p_end}
{synopt:{cmd:e(tests)}}equivalence tests and tests on the equality of the effect on all post-treatment periods{p_end}
{synopt:{cmd:e(p_values)}}p-values for the equivalence tests and tests on the equality of the effect on all post-treatment periods{p_end}

{title:Authors}

{pstd}
{browse "mailto:ricmora@eco.uc3m.es":Ricardo Mora} & {browse "mailto:ireggio@eco.uc3m.es":Iliana Reggio} {break}
Departament of Economics, Universidad Carlos III Madrid{break}
Madrid, Spain{break}


{title:References}

{phang}
Mora, R. & I. Reggio 2012.
"Treatment Effect Identification Using Alternative Parallel Assumptions." {it: WP 12-33}. UC3M, Spain.{break}
{browse "http://e-archivo.uc3m.es/handle/10016/16065":Link to UC3M e-Archivo database}.


{phang}Update: March - 2015{p_end}



