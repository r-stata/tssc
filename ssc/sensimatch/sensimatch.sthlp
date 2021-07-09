{smcl}
{* 11oct2018}{...}
{cmd:help sensimatch}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:sensimatch}{hline 1}}Data-driven sensitivity analysis for Matching estimator{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{hi:sensimatch}
{it:outcome} 
{it:treatment}
[{it:varlist}]
{ifin}
{weight}{cmd:,}
{cmd:mod}{cmd:(}{it:{help sensimatch##modeltype:modeltype}}{cmd:)}
{cmd:sims}{cmd:(}{it:number}{cmd:)}
[{cmd:fac}{cmd:(}{it:varlist_f}{cmd:)}
{cmd:seed}{cmd:(}{it:number}{cmd:)}
{cmd:save_sens}{cmd:(}{it:filename}{cmd:)}
{cmd:vce}{cmd:(}{it:vcetype}{cmd:)}
{cmd:gr_dep_var}{cmd:(}{it:text}{cmd:)}
{cmd:gr1_save}{cmd:(}{it:filename}{cmd:)}
{cmd:gr1_title}{cmd:(}{it:text}{cmd:)}
{cmd:gr1_xtitle}{cmd:(}{it:text}{cmd:)}
{cmd:gr1_ysize}{cmd:(}{it:size}{cmd:)}
{cmd:gr1_xsize}{cmd:(}{it:size}{cmd:)}
{cmd:gr2_save}{cmd:(}{it:filename}{cmd:)}
{cmd:gr2_title}{cmd:(}{it:text}{cmd:)}
{cmd:gr2_xtitle}{cmd:(}{it:text}{cmd:)}
{cmd:gr2_ysize}{cmd:(}{it:size}{cmd:)}
{cmd:gr2_xsize}{cmd:(}{it:size}{cmd:)}]


{pstd}{cmd:fweight}s, {cmd:pweight}s, {cmd:iweight}s are allowed only for model "reg";
see {help weight}.


{title:Description}

{pstd} {cmd:sensimatch} provides a sensitivity test for checking the robustness of the selection-on-observables assumption
in treatment effect observational studies, both within a regression adjustment and a propensity-score matching approach.
Rooted in the machine learning literature, this sensitivity analysis is
based on a "leave-one-covariate-out" (LOCO) approach. This method recalls a bootstrap over different subsets of covariates, and simulates 
various estimation scenarios to be compared with the baseline results obtained by the analyst. 
The main output of {cmd:sensimatch} is graphical, thus providing the user with an easy-to-interpret robustness check 
of his/her study results.


     
{title:Options}

{bf:General options}
    
{phang} {cmd:mod}{cmd:(}{it:{help sensimatch##modeltype:modeltype}}{cmd:)} specifies the model
to be estimated, where {it:modeltype} must be one of the following
models: "reg" or "match". It is always required to specify one model.   

{phang} {cmd:sims}{cmd:(}{it:number}{cmd:)} specifes the number of model simulations for each set of included covariates.

{phang} {cmd:fac}{cmd:(}{it:varlist_f}{cmd:)} specifies that factor variables have to be included
among the regressors. It is optional in each model.

{phang} {cmd:seed}{cmd:(}{it:number}{cmd:)} specifies the random generation seed for each simulation. 

{phang} {cmd:save_sens}{cmd:(}{it:filename}{cmd:)} allows to save the variables used to generate the sensitivity graph.

{phang} {cmd:vce}{cmd:(}{it:vcetype}{cmd:)}: allows to choose {it:vcetype} as either {it:robust}, or {it:cluster clustvar}. This option works only for model "reg".

{phang} {cmd:gr_dep_var}{cmd:(}{it:text}{cmd:)} allows to customize the name of the dependent variable appearing in the sensitivity graph.



{bf:Graph options}


{phang} {it:Graph 1 - ATET}

{phang} {cmd:gr1_save}{cmd:(}{it:filename}{cmd:)} allows to save the sensitivity graph for ATET by a user specifed filename.

{phang} {cmd:gr1_title}{cmd:(}{it:text}{cmd:)} allows to customize the overall title of the sensitivity graph for ATET.

{phang} {cmd:gr1_xtitle}{cmd:(}{it:text}{cmd:)} allows to customize the x-axis title of the sensitivity graph for ATET.

{phang} {cmd:gr1_ysize}{cmd:(}{it:size}{cmd:)} allows to customize the size of the y-axis title of the sensitivity graph for ATET.

{phang} {cmd:gr1_xsize}{cmd:(}{it:size}{cmd:)} allows to customize the size of the x-axis title of the sensitivity graph for ATET.


{phang} {it:Graph 2 - T-Student}

{phang} {cmd:gr2_save}{cmd:(}{it:filename}{cmd:)} allows to save the sensitivity graph for the T-Student by a user specifed filename.

{phang} {cmd:gr2_title}{cmd:(}{it:text}{cmd:)} allows to customize the overall title of the sensitivity graph for T-Student.

{phang} {cmd:gr2_xtitle}{cmd:(}{it:text}{cmd:)} allows to customize the x-axis title of the sensitivity graph for T-Student.

{phang} {cmd:gr2_ysize}{cmd:(}{it:size}{cmd:)} allows to customize the size of the y-axis title of the sensitivity graph for T-StudentT.

{phang} {cmd:gr2_xsize}{cmd:(}{it:size}{cmd:)} allows to customize the size of the x-axis title of the sensitivity graph for T-Student.



{marker modeltype}{...}
{synopthdr:modeltype_options}
{synoptline}
{syntab:Model}
{p2coldent : {opt reg}}Regression estimated by ordinary least squares (OLS){p_end}
{p2coldent : {opt match}}Propensity-score matching{p_end}
{synoptline}


{title:Remarks}
	 
{pstd} Please, before running this program, remember to have the most recent up-to-date version installed.


{title:Examples}

*----------------------------------------------------------------------------------------------------------
{inp:. webuse nlsw88 , clear}
{inp:. global y "wage"}
{inp:. global w "union"} 
{inp:. global xvars "age race married never_married grade south smsa c_city collgrad hours ttl_exp tenure"}
{inp:. global factors "industry occupation"}
*----------------------------------------------------------------------------------------------------------
{inp:. sensimatch $y $w $xvars if c_city==1  , mod(match) sims(5) vce(robust) ///}
{inp:fac($factors) save_sens(data_sens) seed(1010) ///}
{inp:gr_dep_var("Wage") ///}
{inp:gr1_title("") ///}
{inp:gr1_xtitle(Number of included covariates) ///}
{inp:gr1_ytitle(ATET)  ///}
{inp:gr1_xsize(small)  ///}
{inp:gr1_ysize(small)  ///}
{inp:gr1_save(mygraph1) ///}
{inp:gr2_title("") ///}
{inp:gr2_xtitle(Number of included covariates) ///}
{inp:gr2_ytitle(T-Student)  ///}
{inp:gr2_xsize(small)  ///}
{inp:gr2_ysize(vsmall)  ///}
{inp:gr2_save(mygraph2)}
*----------------------------------------------------------------------------------------------------------


{title:Reference}

{phang}
Cerulli, G. 2015. {it: Econometric Evaluation of Socio-Economic Programs: Theory and Applications}.
Springer, Berlin.
{p_end}

{phang}
Nannicini, T. 2007. {it: Simulation-based sensitivity analysis for matching estimators}. 
The Stata Journal, 7, Number 3, pp. 334-350.
{p_end}

{phang}
Rosenbaum, P. R. 1987. {it:Sensitivity analysis to certain permutation inferences in matched observational studies}. 
Journal of the Royal Statistical Society, Series B, 45, pp. 212-218.
{p_end}

{phang}
Rosenbaum, P. R., and Rubin, D. B. 1983. {it:Assessing sensitivity to an unobserved binary covariate in an observational 
study with binary outcome}. Journal of the Royal Statistical Society, Series B, 45, pp. 212-218.
{p_end}


{title:Author}

{phang}Giovanni Cerulli{p_end}
{phang}IRCrES-CNR{p_end}
{phang}Research Institute for Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}


{title:Also see}

{psee}
Online: {helpb sensatt}, {helpb rbounds}
{p_end}
