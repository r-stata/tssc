{smcl}
{* 17may2019}{...}
{cmd:help subset}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:subset}{hline 1}}Implementing covariates best and stepwise subset selection{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{hi:subset}
{it:outcome} 
[{it:varlist}]
{ifin}
{cmd:model}{cmd:(}{it:{help subset##modeltype:modeltype}}{cmd:)}
{cmd:rversion}{cmd:(}{it:R_version}{cmd:)}
[{cmd:nvmax}{cmd:(}{it:number}{cmd:)}
{cmd:index_values}{cmd:(}{it:filename}{cmd:)}
{cmd:matrix_results}{cmd:(}{it:filename}{cmd:)}
{cmd:optimal_vars}{cmd:(}{it:filename}{cmd:)}]


{title:Description}

{pstd} {cmd:subset} is a Stata wrapper for the R function "regsubsets()", providing "best", 
"backward", and "forward" stepwise subset covariates selection, a Machine Learning approach to select the optimal number of features (covariates) 
in a supervised linear learning approach (i.e. a linear regression model) with many covariates. 
The "forward" model can be also  used when {it:p} (the number of covariates) is 
larger than {it:N} (the sample size). This method provides both the optimal 
subset of covariates for each specific size of the model 
(i.e., size=1 covariates, size=2 covariates, etc.), 
and the overall optimal size. The latter one is found 
using three criteria as validation approaches: Adjusted R2, CP, and BIC.   


     
{title:Options}

{bf:General options}
    
{phang} {cmd:model}{cmd:(}{it:{help subset##modeltype:modeltype}}{cmd:)} specifies the model
to be estimated. It is always required to specify one model.   

{phang} {cmd:rversion}{cmd:(}{it:R_version}{cmd:)} specifies the R version intalled in the operating system. A typical value is: "3.6.0".

{phang} {cmd:nvmax}{cmd:(}{it:number}{cmd:)} specifies the maximum order of best set of variables to show as result.

{phang} {cmd:index_values}{cmd:(}{it:filename}{cmd:)} specifies the name of the Stata .dta file containing the values of the AdjR2 (adjusted R2), CP, and BIC used for finding the final optimal number of covariates.

{phang} {cmd:matrix_results}{cmd:(}{it:filename}{cmd:)} specifies the name of the Stata .dta file containing the matrix of results, i.e. the optimal number of covariates for each model number of covariates.

{phang} {cmd:optimal_vars}{cmd:(}{it:filename}{cmd:)} specifies the name of the Stata .dta file containing the name of the optimal covariates at each model number of covariates.


{marker modeltype}{...}
{synopthdr:modeltype_options}
{synoptline}
{syntab:Model}
{p2coldent : {opt best_subset}}Best subset selection{p_end}
{p2coldent : {opt backward}}Backward stepwise selection{p_end}
{p2coldent : {opt forward}}Forward stepwise selection{p_end}
{synoptline}


{title:Remarks}
	 
{pstd} --> Before running this program, remember to have the most recent up-to-date version installed.


{title:Examples}

{inp:. subset y w x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 , model(backward) rversion("3.6.0") nvmax(6) index_values("myindex") matrix_results("myresults")}



{title:Reference}

{phang}
Gareth, J., Witten, Hastie, D.T., Tibshirani. 2013. {it: An Introduction to Statistical Learning : with Applications in R}. New York, Springer.
{p_end}



{title:Author}

{phang}Giovanni Cerulli{p_end}
{phang}IRCrES-CNR{p_end}
{phang}Research Institute for Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}


{title:Also see}

{psee}
Online: {helpb srtree}, {helpb sctree}
{p_end}
