{smcl}
{* 25may2020,17:55}{...}
{cmd:help tfdiff}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col: {hi:tfdiff} {hline 1}}Pre- and post-treatment estimation of the Average Treatment Effect (ATE) with binary time-fixed treatment{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:tfdiff}
{it: outcome} 
{it: treatment}
[{it:varlist}]
{ifin}
{weight}{cmd:,}
{cmd:datatype}{cmd:(}{it:datatype}{cmd:)}
{cmd:model}{cmd:(}{it:modeltype}{cmd:)}
{cmd:tvar}{cmd:(}{it:time_variable}{cmd:)}
{cmd:t}{cmd:(}{it:#}{cmd:)}
[{cmd:pvar}{cmd:(}{it:panel_variable}{cmd:)}
{cmd:test_pt}
{cmd:graph}
{cmd:ci}{cmd:(}{it:#}{cmd:)}
{cmd:vce}{cmd:(}{it:vcetype}{cmd:)}
{cmd:save_graph}{cmd:(}{it:graphname}{cmd:)}
{cmd:save_results}{cmd:(}{it:filename}{cmd:)}]


{pstd}{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.



{title:Description}

{pstd}{cmd:tfdiff} estimates Average Treatment Effects (ATEs) when the treatment is binary and fixed to a specific point in time. It assumes the availability of a panel dataset where the same treated and untreated units are observed over time.
Using {cmd:tfdiff}, the user can estimate 
the {it:pre}- and {it:post}-intervention effects by selecting the intervention time {it:t}. The results are plotted in an easy-to-read graphical representation. In order to assess the reliability of the causal results achieved by
the user's specified model, {cmd:tfdiff} allows to test the "parallel trend" assumption via a joint significance test on the pre-treatment effects. The model estimated by {cmd:tfdiff} is a generalization of the Difference-In-Differences (DID) approach to more than one pre- and post-treatment periods and fixed treatment time. 


{phang} According to the {cmd:tfdiff} syntax:

{phang} {it:outcome}: is the target variable over which measuring the impact of the treatment

{phang} {it:treatment}: is the binary treatment variable taking 1 for treated, and 0 for untreated units

{phang} {it:varlist}: is the set of pre-treatment (or observable confounding) variables

     
{title:Options}

{phang} {cmd:datatype}{cmd:(}{it:datatype}{cmd:)} specifies the type of dataset employed, where {it:datatype} must be one out of these two alternatives:
"cross-section" (for a cross-section dataset), or "panel" (for a longitudinal dataset). 
It is always required to specify one data type. 

{phang} {cmd:model}{cmd:(}{it:modeltype}{cmd:)} specifies the estimation model, 
where {it:modeltype} must be one out of these two alternatives:
"fe" (fixed effects), or "ols" (ordinary least squares). It is always required to specify one model. Notice that, with option "cross-section" in 'datatype()', only one model must be declared into the option 'model()': "ols".

{phang} {cmd:tvar}{cmd:(}{it:time_variable}{cmd:)} specifies the time variable. It has to be numeric. 

{phang} {cmd:t}{cmd:(}{it:#}{cmd:)} allows to specify the time of treatment. 

{phang} {cmd:pvar}{cmd:(}{it:panel_variable}{cmd:)} specifies the panel variable. It has to be numeric.    

{phang} {cmd:test_pt} allows for performing the parallel trend test using the pre-treatment periods.

{phang} {cmd:graph} allows for a graphical representation of results.

{phang} {cmd:ci}{cmd:(}{it:#}{cmd:)} sets the statistical significance level for ATE(t). It takes values 1, 5, 10 (meaning 1%, 5%, and 10% significance respectively).

{phang} {cmd:vce}{cmd:(}{it:vcetype}{cmd:)} allows for robust and clustered regression standard errors in model's estimates.

{phang} {cmd:save_graph}{cmd:(}{it:graphname}{cmd:)} allows to save in the hard-disk the graph of results.

{phang} {cmd:save_results}{cmd:(}{it:filename}{cmd:)} allows to save in the user's hard-disk a new dataset named {it:filename} containing the ATE({it:t}) function and relative confidence intervals.


{title:Post-estimation results}

{pstd}
{cmd:tfdiff} creates these variables:

{pmore}
{inp:_D2, ..., _DT}: are time dummies used to build the treatment effects estimation.


{pstd}
{cmd:tfdiff} returns the following scalars:

{pmore}
{inp:e(N)} is the total number of (used) observations.

{pmore}
{inp:e(N1)} is the number of (used) treated units.

{pmore}
{inp:e(N0)} is the number of (used) untreated units.

{pmore}
{inp:e(T)} is the number of times.

{pmore}
{inp:e(t)} is the treatment time.


{title:Remarks}

{pstd} - The treatment has to be a 0/1 binary variable (1 = treated, 0 = untreated).

{pstd} - It is assumed that the model is correctly specified.

{pstd} - Please remember to use the {cmdab:update query} command before running
this program to make sure you have an up-to-date version of Stata installed.

{title:Examples}

********************************************************************************
* SIMULATED DATASET
********************************************************************************
. clear all
. set scheme s1mono
********************************************************************************
. global E=2  // average effect of the policy
********************************************************************************
. global Nobs=100
. global T=21
. set obs $Nobs
. set seed 1234
. gen H=_n if _n<=$T
. centile H , c(50)
. global t_star=1999+r(c_1)
********************************************************************************
. gen id=_n
. expand $T
. gen w=(id<=$T)
. bys id: gen time=_n+1999
. gen x=uniform()
. gen y=rnormal(0,0.5)
********************************************************************************
. replace y=rnormal($E,1) if (time >= $t_star) & w==1
********************************************************************************
. keep id time y w x
********************************************************************************
. tsset id time
********************************************************************************
. tfdiff y w x , t(2010) pvar(id) tvar(time) datatype(panel) ///
  model(ols) ci(10) graph vce(cluster id) save_results(RES_tfdiff)
********************************************************************************


{title:References}

{phang}
Cerulli, G. (2015). {it:Econometric Evaluation of Socio-Economic Programs: Theory and Applications},
Springer.

{phang}
Cerulli, G. and Ventura, M. (2019). TVDIFF: Estimation of pre-and posttreatment average treatment effects with binary time-varying treatment using Stata, {it:The Stata Journal}, 19, 3, 2019.
{p_end}

{title:Authors}

{phang}Giovanni Cerulli{p_end}
{phang}IRCrES-CNR{p_end}
{phang}Research Institute on Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}


{title:Also see}

{psee}
Online: {helpb teffects}, {helpb tvdiff}
{p_end}
