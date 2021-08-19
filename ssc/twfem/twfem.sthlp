{smcl}
{* *! version 1.0  6 Sep 2020}{...}
{viewerjumpto "Syntax" "twest##syntax"}{...}
{viewerjumpto "Description" "twest##description"}{...}
{viewerjumpto "Options" "twest##options"}{...}
{viewerjumpto "Remarks" "twest##remarks"}{...}
{viewerjumpto "Examples" "twest##examples"}{...}
{title:Title}
{phang}
{bf:twfem} {hline 2} Algorithm to efficiently estimate a two-way fixed effects model based on Somaini and Wolak (2015).

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:twfem} command varlist
[{help if}]
[{help in}]
[{help using}]
[{cmd:,}
{it:options}]

{pstd}
Command is an estimation command, e.g., regress, ivregress, sureg. The varlist contains the dependent variable followed by the independent variables. The syntaxis of the varlist replicates the syntaxis of the original estimation command. {p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt {help using}}} followed by a path will save a set of matrices in that path. If using option is omitted, the matrices will be stored in eresults {p_end}

{syntab:Required in the first regression}
{synopt:{opt abs:orb(absvars weight)}} two categorical variables that indentify the fixed effects to be absorbed. Analytic weights can be added as an optional third argument{p_end}
{synopt:{opt gen:erate(newvars)}} creates new group identifiers {p_end}

{synopt:{opt newv:ars(name)}} creates residualized variables with 
the prefix in "newvars" {p_end}

{syntab:or}

{synopt:{opt replace}} replace the variables for their residualized 
version {p_end}

{syntab:Running different specifications with residualized variables}
{synopt:{opt noproj}} Run the regression without creating any arrays or projecting new variables. It assumes that all the variables have been residualized. {p_end}

{syntab:SE/Robust}
{p2coldent:+ {opt vce}{cmd:(}{help vcetype}{cmd:)}}{it:vcetype}
may be {opt un:adjusted} (default), {opt robust} or {opt cluster} {clustervar}{p_end}



{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:twfem} is an algorithm to estimate the two-way fixed effect linear model. The algorithm relies on the Frisch-Waugh-Lovell theorem and applies to ordinary least squares (OLS), two-stage least squares (TSLS) and GMM estimators. {p_end}


{marker options}{...}
{title:Options}

{marker opt_model}{...}
{dlgtab: Full Description}

{phang}
{help using} adding using followed by a path will save a set of matrices in that path. Otherwise, the matrices will be saved in eresults. STATA may fail if it tries to store a matrix that exceeds matsize in ereturn. Adding using avoids that limitation.  {p_end}

{phang}
{opth abs:orb(absvars weight)} the two levels of fixed effects are specified in this option, it takes at least two variables with group identifiers. The optional third input can be a variable of analytic weights. {p_end}

{phang}
{opth gen:erate(newvars)} if the group identifiers are not consecutive after dropping redundants and missing observations, then you have this option to create new group identifiers. This option will create new variables in the database. {p_end}

{phang}
{opth newv:ars(name)} creates new variables, the residualized variables will be stored as new variables that will be named with a prefix specified in `newvars'. This option will create new variables in the database. See option replace for replacing existing variables. {p_end}

{phang}
{opt replace} replace the variables for their residualized version. See option newvars for creating new variables without changing existent ones. {p_end}

{phang}
{opt noproj} run the regression without creating any arrays or projecting new variables. This option will take the matrices created and stored in eresults or in the path selected by using option. {p_end}


{marker examples}{...}
{title:Examples}
{pstd}twfem reg y x1 x2 x3 x4, absorb(hhid tid w) newv(w_) vce(robust)  {p_end}
{pstd}twfem reg w_y w_x1, noproj vce(cluster hhid)  {p_end}
{pstd}twfem ivregress 2sls w_y w_x1 (w_x2= w_x3), noproj vce(robust)  {p_end}

{title:Shortcomings}
{p2col 8 12 12 2: 1.} Factor-variable and time-series operators not allowed.{p_end}
{p2col 8 12 12 2: 2.} The program may throw an error if the dataset contains a variable with the name of an estimation command such as reg (commonly used for variables of region). If the dataset contains a variable called reg, then do not abbreviate the estimation command. {p_end}

{title:Common Errors}
{p2col 8 12 12 2: 1.} The algorithm will not work if the fixed effects after the cleaning of the redundants and missing observations are not consecutives and the generate option is not used.{p_end}
{p2col 8 12 12 2: 2.} The algorithm will not work if the user tries to create with "generate" or with "newvars" new variables with a name that already exits. {p_end}
{p2col 8 12 12 2: 3.} The vce option is not allowed when the estimation command is "sureg". {p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}


{title:Stored results}
{pstd}
{it:Note: All the results of the original command selected and the matrices and scalars needed for the algorithm will be stored in the eresults. Use ereturn to list them.} 

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
{synopt:{cmd:e(V)}} variance-covariance matrix with the degree of freedom correction {p_end}


{p 8 8 1}
If "using" is omitted{p_end}
{p 8 8 1}{cmd:e(invDD)} is a vector of (dimN)x1 taking the diagonal elements of the inverse of the matrix D'D{p_end}
{p 8 8 1}{cmd:e(invHH)} is a vector of (dimT-1)x1 taking the diagonal elements of the inverse of the matrix H'H {p_end}
{p 8 8 1}{cmd:e(B)} Matrix B is needed for the first and second step of the algorithm {p_end}


{p 12 8 1}If {cmd:e(dimN)}<{cmd:e(dimT)}{p_end}
{p 12 8 1}{cmd:e(A)} Matrix A is needed for the first and second step of the algorithm{p_end}
{p 12 8 1}{cmd:e(CinvHHDH)} Matrix CinvHHDH is needed for the first and second step of the algorithm{p_end}

{p 12 8 1}
If {cmd:e(dimN)}>={cmd:e(dimT)}{p_end}
{p 12 8 1}{cmd:e(C)} Matrix C is needed for the first and second step of the algorithm{p_end}
{p 12 8 1}{cmd:e(AinvDDDH)} Matrix AinvDDDH is needed for the first step of the algorithm{p_end}


{synoptset 15 tabbed}{...}
{syntab:Functions}
{synopt:{cmd:e(sample)}} marks estimation sample{p_end}
{p2colreset}{...}

{title:More information}
{phang}
For more information of {it:twfem} {browse "https://github.com/paulosomaini/twowayreg-stata/tree/master":Github}

{title:Also see}
For advanced options:
{help twset}
{help twres}
{help twest}
{help twsave}
{help twload}

{title:References}
{phang}
Somaini, P. and F.A. Wolak, (2015), An Algorithm to Estimate the Two-Way Fixed Effects Model, Journal of Econometric Methods, 5, issue 1, p. 143-152.

{title: Aditional References}
{phang}
Arellano, M. (1987), Computing Robust Standard Errors for Within-Groups Estimators, Oxford Bulletin of Economics and Statistics, 49, issue 4, p. 431–434.

{phang}
Cameron, A. C., & Miller, D. L. (2015). A practitioner’s guide to cluster-robust inference. Journal of human resources, 50(2), 317-372.



