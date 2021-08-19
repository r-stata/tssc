{smcl}
{* *! version 1.0  6 Sep 2020}{...}
{viewerjumpto "Syntax" "twest##syntax"}{...}
{viewerjumpto "Description" "twest##description"}{...}
{viewerjumpto "Options" "twest##options"}{...}
{viewerjumpto "Remarks" "twest##remarks"}{...}
{viewerjumpto "Examples" "twest##examples"}{...}
{title:Title}
{phang}
{bf:twest} {hline 2} performs the last step of the algorithm  based on the model of Somaini and Wolak (2016). 

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:twest} command varlist
[{cmd:,}
{it:options}]

{pstd}
Command is an estimation command, e.g., regress, ivregress, sureg. The varlist contains the dependent variable followed by the independent variables. The syntaxis of the varlist replicates the syntaxis of the original estimation command. {p_end}


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:SE/Robust}
{p2coldent:+ {opt vce}{cmd:(}{help vcetype}{cmd:)}}{it:vcetype}
may be {opt un:adjusted} (default), {opt robust} or {opt cluster} {clustervar}{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:twest} performs the last step of the algorithm, making the regression of the projected variables {p_end}

{marker options}{...}
{title:Options}

{marker opt_model}{...}
{dlgtab: Full Description}


{title:Shortcomings}
{p2col 8 12 12 2: 1.} Factor-variable and time-series operators not allowed.{p_end}

{title:Common Errors}
{p2col 8 12 12 2: 1.} Running twres after some other comment erased or overwrote eresults. {p_end}
{p2col 8 12 12 2: 2.} Using the vce with the "sureg" command.{p_end}

{marker examples}{...}
{title:Examples}
{pstd}twest reg w_y w_x*, vce(cluster hhid)  {p_end}
{pstd}twest ivregress w_y w_x1 w_x2 (w_x3= w_x4 w_x5), vce(robust)  {p_end}


{title:Stored results}
{pstd}
{it:Note: All the results of the original command selected and the matrices and scalars needed for the algorithm will be stored in eresults. Use ereturn to list them.} 

{synoptset 15 tabbed}{...}
{syntab:Scalars}
{synopt:{cmd:e(dof_adj)}} Degree of freedom adjustment {p_end}
{synopt:{cmd:e(dimN)}} number of first fixed effect without the redundants observations{p_end}
{synopt:{cmd:e(dimT)}} number of second fixed effect without the redundants observations{p_end}
{synopt:{cmd:e(nested_adj)}} Adjustment in the degree of freedom if one of the fixed effect or both of them are nested within the cluster var {p_end}
{synopt:{cmd:e(rank_adj)}} Adjustment based on the rank of {cmd:e(A)} if {cmd:e(dimN)}<{cmd:e(dimT)}, otherwise is based on the rank of {cmd:e(C)}{p_end}

{synoptset 15 tabbed}{...}
{syntab:Macros}
{synopt:{cmd:e(absorbed)}} name of the fixed effects absorbed and the weight variable {p_end}

{synoptset 15 tabbed}{...}
{syntab:Matrices}
{synopt:{cmd:e(b)}} coefficient vector{p_end}
{synopt:{cmd:e(V)}} variance-covariance matrix adjusted of the estimators {p_end}


{p 8 8 1}
If "using" is omitted{p_end}
{p 8 8 1}{cmd:e(invDD)} is a vector of (dimN)x1 taking the diagonal elements of the inverse of the matrix D'D{p_end}
{p 8 8 1}{cmd:e(invHH)} is a vector of (dimT-1)x1 taking the diagonal elements of the inverse of the matrix H'H {p_end}
{p 8 8 1}{cmd:e(B)} Matrix B needed for the first and second step of the algorithm {p_end}


{p 12 8 1}If {cmd:e(dimN)}<{cmd:e(dimT)}{p_end}
{p 12 8 1}{cmd:e(A)} Matrix A needed for the first and second step of the algorithm{p_end}
{p 12 8 1}{cmd:e(CinvHHDH)} Matrix CinvHHDH needed for the first and second step of the algorithm{p_end}

{p 12 8 1}
If {cmd:e(dimN)}>={cmd:e(dimT)}{p_end}
{p 12 8 1}{cmd:e(C)} Matrix C needed for the first and second step of the algorithm{p_end}
{p 12 8 1}{cmd:e(AinvDDDH)} Matrix AinvDDDH needed for the first step of the algorithm{p_end}


{synoptset 15 tabbed}{...}
{syntab:Functions}
{synopt:{cmd:e(sample)}} marks estimation sample{p_end}
{p2colreset}{...}

{title:More information}
{phang}
For more information of {it:twest} {browse "https://github.com/paulosomaini/twowayreg-stata/tree/master":Github}

{title:Also see}
For advanced options:
{help twset}
{help twres}
{help twsave}
{help twload}
{help twfem}

{title:References}
{phang}
Somaini, P. and F.A. Wolak, (2015), An Algorithm to Estimate the Two-Way Fixed Effects Model, Journal of Econometric Methods, 5, issue 1, p. 143-152.

{title: Aditional References}
{phang}
Arellano, M. (1987), Computing Robust Standard Errors for Within-Groups Estimators, Oxford Bulletin of Economics and Statistics, 49, issue 4, p. 431–434.

{phang}
Cameron, A. C., & Miller, D. L. (2015). A practitioner’s guide to cluster-robust inference. Journal of human resources, 50(2), 317-372.



