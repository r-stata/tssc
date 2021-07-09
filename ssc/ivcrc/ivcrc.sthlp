{smcl}
{* *! version 2 4june2020}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Title" "ivcrc##title"}{...}
{viewerjumpto "Syntax" "ivcrc##syntax"}{...}
{viewerjumpto "Description" "ivcrc##description"}{...}
{viewerjumpto "Options" "ivcrc##options"}{...}
{viewerjumpto "Examples" "ivcrc##examples"}{...}

{marker title}{...}
{title:Title}

{phang}
{bf:ivcrc} {hline 2} Instrumental variables correlated random coefficients estimator 


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:ivcrc} {depvar} [{it:{help varlist:varlist1}}]
{cmd:(}{it:{help varlist:varlist_edg}} {cmd:=}
        {it:{help varlist:varlist2}}{cmd:)} {ifin} [{cmd:,} {it:options}]

	
{phang}
{it:varlist1} is the list of exogenous explanatory variables.{p_end}

{phang}
{it:varlist_edg} is the list of (basic) endogenous explanatory variables.{p_end}
   
{phang}
{it:varlist2} is the list of excluded exogenous variables to be used with {it:varlist1} as instruments for {it:varlist_edg}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ivcrc} implements the instrumental variables (IV) estimator for the linear correlated random coefficients (CRC) model 
described in Benson, Masten, and Torgovitsky (2020). The linear CRC model is a generalization of the standard linear IV
 model that allows for endogenous, multivalued treatments and unobserved heterogeneity in treatment effects. 
 {cmd:ivrcr} allows for flexible functional forms and permits instruments that may be binary, discrete, or continuous.
 The command is based on semiparametric identification results described in Masten and Torgovitsky (2016), and draws 
 on computation, estimation, and asymptotic theory described in Masten and Torgovitsky (2014). The command also 
 allows for the estimation of varying coefficients regressions, which are closely related in structure.{p_end}


{marker options}{...}
{title:Options}

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt dendog:(varlist)}}List of derived endogenous variables, known functions of {it:varlist_edg}.{p_end}

{synopt :{opt boot:strap(options)}}Bootstrap confidence intervals and standard errors; 
default setting is no standard errors. 
Allows passing {cmd:bootstrap} command {it:options}, e.g. {it:reps(#)} or {it:cluster(varlist)}. 
Access additional post-estimation statistics via {cmd:estat bootstrap}.{p_end}

{synopt :{opt k:ernel()}}Choose alternative kernel functions; default is the epanechnikov kernel. 
Other options: {it:uniform}, {it:triangle}, {it:biweight}, {it:triweight}, {it:cosine}, and {it:gaussian}.{p_end}

{synopt :{opt band:width()}}Bandwidth of kernel; default is 0.05. If multiple (comma separated) values are specified, estimates for each bandwidth are reported. 
Sub-option: together with {cmd:varcoef}, specify the bandwidth for a varying coefficients model.{p_end}

{synopt :{opt r:anks(integer)}}Use (1/{it:integer},...,1 - 1/{it:integer}) evenly spaced quantiles for 
computing the conditional rank statistic; default is 50. {p_end}

{synopt :{opt ave:rage(lb(g)ub)}}Options for numerical integration, with generalized numlist syntax {it:lb}({it:g}){it:ub}. 
Specify {cmd:average}({it:lb}(0){it:ub}) to use the sample average method; default setting is {cmd:average}(0(0)1). 
Specify non-zero values of {it:g} to use the grid method, e.g. {cmd:average}(.01(.01).99) to numerically integrate 
over the grid (.01,.02,...,.99). The space of integration may be comprised of non-overlapping ascending subsets by 
specifying comma separated lists. Sub-option: specifying {cmd:average}({it:lb1}({it:g1}){it:ub1},...,{it:lbN}({it:gN}){it:ubN}, report) returns estimates for each subset as well as estimates over their union. 
Sub-option: together with {cmd:varcoef}, specify the support for kernel weights in a varying coefficients model.{p_end}

{synopt :{opt gen:erate(varname)}}Save conditional rank estimates to {it:varname} in the working dataset. This option is ignored when bootstrapping.{p_end}

{synopt :{opt userank(varname)}}Use {it:varname} as the conditional rank statistic, bypassing rank estimation.{p_end}

{synopt :{opt savecoef(filename)}}Creates a comma delimited (csv) dataset of the local rank-specific coefficient estimates, saved to {it:filename}.{p_end}

{synopt :{opt varcoef(varlist)}}Estimate a varying coefficients model, in which coefficients are conditioned on covariates specified in {it:varlist} as an alternative to conditioning on the ranks of the basic endogenous variables {it:varlist_edg}. Options {cmd:average} and {cmd:bandwidth} are required with {cmd:varcoef}.{p_end}

{synopt :{opt nocons:tant}}Suppress the constant term of the model.{p_end}

{synoptline}



{marker examples}{...}
{title:Examples}

{pstd}
Using NLSYM data, available as part of Cameron and Trivedi (2010) {p_end}  
{phang}{cmd:net from http://www.stata-press.com/data/musr}{p_end}
{phang}{cmd:net install musr}{p_end}
{phang}{cmd:net get musr}{p_end}
{phang}{cmd:use mus06klingdata.dta }{p_end}

{phang}{cmd:ivcrc wage76 (grade76 = col4 age76 agesq76) }{p_end}
{phang}{cmd:ivcrc wage76 (grade76 = col4 age76 agesq76), bootstrap(reps(100))}{p_end}
{phang}{cmd:ivcrc wage76 (grade76 = col4 age76 agesq76), bandwidth(.025) average(.05(0).95) kernel(uniform)}{p_end}
{phang}{cmd:ivcrc wage76 (grade76 = col4 age76 agesq76), dendog(exp76 expsq76) quantiles(200) savecoef(localests)}{p_end}
{phang}{cmd:ivcrc wage76 grade76 exp76 expsq76, varcoef(age76) bandwidth(2) average(30(0)50)}{p_end}



{title:Author}

{pstd}{browse "https://www.federalreserve.gov/econres/david-a-benson.htm":David Benson}, Board of Governors of the Federal Reserve System{break}
(in collaboration with {browse "https://mattmasten.github.io/":Matt Masten} and {browse "https://a-torgovitsky.github.io/":Alexander Torgovitsky})
{p_end}



{title:References}

{p 4 8}
Benson, David, Matthew A. Masten, and Alexander Torgovitsk (2020). "ivcrc: An Instrumental Variables Estimator for the Correlated Random Coefficients Model" Working paper{p_end}

{p 4 8}
Cameron, A. Colin, and Pravin K. Trivedi (2010). "Microeconometrics Using Stata Revised Edition" {it:Stata Press, College Station, Texas}  {p_end}

{p 4 8}
Masten, Matthew A., and Alexander Torgovitsky (2016). "Identification of Instrumental Variable Correlated Random Coefficients Models" {it:The Review of Economics and Statistics} 98 (5), pp. 1001-1005.{p_end}

{p 4 8}
Masten, Matthew A., and Alexander Torgovitsky (2014). "Instrumental Variables Estimation of a Generalized Correlated Random Coefficients Model" {it:Cemmap} working paper CWP02/14{p_end}