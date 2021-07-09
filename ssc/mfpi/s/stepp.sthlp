{smcl}
{* 04sep2009}{...}
{hline}
help for {hi:stepp_tail}, {hi:stepp_window}, {hi:stepp_plot}{right:Patrick Royston}
{hline}

{title:Subpopulation treatment effect pattern plot (STEPP)}

{phang2}
{cmd:stepp_tail}
{it:regression_cmd}
[{it:yvar}]
{it:zvar}
[{it:adjvars}]
{ifin}
{cmd:,}
{it:options}

{phang2}
{cmd:stepp_window}
{it:regression_cmd}
[{it:yvar}]
{it:zvar}
[{it:adjvars}]
{ifin}
{cmd:,}
{it:options}

{phang2}
{cmd:stepp_plot} {it:stubname}
[{cmd:, }
{it:options}]

{pstd}
{marker syntax}where

{pin}
{it:regression_cmd} may be
{helpb clogit},
{helpb cnreg},
{helpb glm},
{helpb intreg}, 
{helpb logistic},
{helpb logit},
{helpb mlogit},
{helpb nbreg},
{helpb ologit},
{helpb oprobit},
{helpb poisson},
{helpb probit},
{helpb qreg},
{helpb regress},
{helpb stcox},
{helpb streg},
or
{helpb xtgee}.


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt gen(stubname)}}creates five new variables containing results of STEPP analysis{p_end}
{synopt :{opt g(#)}}({cmd:stepp_tail} only) defines the number of subpopulation groups{p_end}
{synopt :{opt n1(#)}}({cmd:stepp_window} only) defines the number of individuals belonging only to one of two neighbouring subpopulations{p_end}
{synopt :{opt n2(#)}}({cmd:stepp_window} only) defines the number of individuals in a subpopulation{p_end}
{synopt :{opt treatment(trt_varlist)}}defines the list of variables whose interactions with {it:zvar} are to be studied{p_end}
{synopt :{it:regression_cmd_options}}options for {it:regression_cmd}{p_end}

{syntab :{it:options} for {cmd:stepp_plot}}
{synopt :{opt vn(#)}}variable number in {cmd:treatment()}{p_end}
{synopt :{opt plot(plot)}}adds other plots to the generated graph{p_end}
{synopt :{it:graph_options}}options of {cmd:graph twoway}{p_end}
{synoptline}
{p2colreset}{...}


{phang}
All weight types supported by {it:regression_cmd} are allowed; see {help weight}.{p_end}

{phang}
{it:yvar} is not allowed for {opt streg} and {opt stcox}. For these commands,
you must first {helpb stset} your data.


{title:Description}

{pstd}
{cmd:ststep_tail} and {cmd:ststep_window} compute Bonetti & Gelber (2000, 2004)'s
STEPP estimators for graphical exploration of a treatment/covariate interaction.
{cmd:ststep_tail} provides the tail-oriented estimator, and
{cmd:ststep_window} the sliding-window estimator. Plotting the results may 
be done by using {cmd:stepp_plot}, in which case {it:stubname} is the same as in the
{opt gen(stubname)} option of {cmd:stepp_tail} and {cmd:stepp_window}.

{pstd}
{it:zvar} is the continuous covariate whose interaction with treatment
is to be studied, and {it:adjvars} is a list of other covariates used
to linearly adjust each model fitted to the
treatment variable(s) defined by {cmd:treatment()}.


{title:Options}

{pstd}{ul:Options for {cmd:stepp_tail} and {cmd:stepp_window}}:

{phang}
{opt gen(stubname)} creates five new variables called {it:stubname}{hi:b},
{it:stubname}{hi:se}, {it:stubname}{hi:mean}, {it:stubname}{hi:lb}, {it:stubname}{hi:ub}.
{it:stubname}{hi:b} is the estimated regression coefficient in each subpopulation,
{it:stubname}{hi:se} is its standard error, {it:stubname}{hi:mean} contains the mean
of {it:zvar} in each subpopulation, and {it:stubname}{hi:lb} and {it:stubname}{hi:ub}
are pointwise 95% confidence limits for {it:stubname}{hi:b}. If {cmd:treatment()} includes more
than one variable, the created variables have 2, 3, ... appended to the names, 
e.g. {it:stubname}{hi:b2}.

{phang}
{opt g(#)} ({cmd:stepp_tail} only) defines the number of subpopulation groups.
The actual number of subpopulations used is 2 * # - 1.

{phang}
{opt n1(#)} ({cmd:stepp_window} only) defines the number of individuals
belonging only to one of two neighbouring subpopulations.

{phang}
{opt n2(#)} ({cmd:stepp_window} only) defines the number of individuals
in a subpopulation. The overlap between two neighbouring subpopulations is
{cmd:n2()} minus {cmd:n1()} individuals.

{phang}
{opt treatment(trt_varlist)} defines the list of variables whose interactions with
{it:zvar} are to be studied. Typically {it:trt_varlist} will comprise just one
binary variable, representing the two arms of a parallel-group clinical trial.

{phang}
{it:regression_cmd_options} are options for {it:regression_cmd}.

{pstd}{ul:Options for {cmd:stepp_plot}}:

{phang}
{opt vn(#)} {it:#} is an integer defining the variable number in {cmd:treatment()}, when more
than one variable is specified. When only one variable is specified,
{opt vn()} is not required.

{phang}
{opt plot(plot)} provides a way to add other plots to the 
generated graph; see help {help plot_option:plot option}.

{phang}
{it:graph_options} are options of {cmd:graph twoway}, such as
{cmd:xtitle()}, {cmd:ytitle()}, etc.


{title:Examples}

{phang}{cmd:. stepp_tail regress y x a1 a2, g(10) gen(z) treatment(t)}{p_end}

{phang}{cmd:. stepp_window stcox x a1 a2, n1(40) n2(50) gen(z) treatment(t)}{p_end}

{phang}{cmd:. stepp_plot z, xtitle("Serum rhubarb") ytitle("log relative hazard") name(myplot)}{p_end}


{title:Author}

{pstd}
Patrick Royston, MRC Clinical Trials Unit, London.{break}
pr@ctu.mrc.ac.uk


{title:References}

{phang}
M. Bonetti and R. D. Gelber. 2000. A graphical method to assess treatment-covariate interactions
using the Cox model on subsets of the data. {it:Statistics in Medicine} 19: 2595-2609.

{phang}
M. Bonetti and R. D. Gelber. 2004. Patterns of treatment effects in subsets of patients in clinical
trials. {it:Biostatistics} 5: 465-481.

{phang}
P. Royston and W. Sauerbre. 2009. Two techniques for investigating interactions
between treatment and continuous covariates in clinical trials. {it:Stata Journal}
9(2): 230-251.

{phang}
W. Sauerbrei, P. Royston and K. Zapien. 2007. Detecting an interaction between treatment
and a continuous covariate: a comparison of two approaches.
{it:Computational Statistics and Data Analysis} 51: 4054-4063.


{title:Also see}

{psee}Article: {it:Stata Journal}, volume 9, number 2: {browse "http://www.stata-journal.com/article.html?article=st0164":st0164}

{psee}
Online:  {help mfpi}{p_end}
