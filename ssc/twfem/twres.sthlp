{smcl}
{* *! version 1.0  6 Sep 2020}{...}
{viewerjumpto "Syntax" "twest##syntax"}{...}
{viewerjumpto "Description" "twest##description"}{...}
{viewerjumpto "Options" "twest##options"}{...}
{viewerjumpto "Remarks" "twest##remarks"}{...}
{viewerjumpto "Examples" "twest##examples"}{...}
{title:Title}
{phang}
{bf:twres} {hline 2} performs the second step of the algorithm  based on the model of Somaini and Wolak (2015). 

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:twres} varlist
[{help using}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt {help using}}} followed by a path will use a set of matrices saved in that path. If using option is omitted the command will use the arrays stored in eresults {p_end}
{synopt:{opt p:refix(name)}} creates new variables that are the residual projection of the originals {p_end}
{synopt:{opt replace}} replace the existing variables by their residual projection {p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:twres} performs the second step of the algorithm. It is followed by a list of variables. These variables are projected onto the set of dummies and the residual of the projection is saved. {p_end}

{marker options}{...}
{title:Options}

{marker opt_model}{...}
{dlgtab: Full Description}

{phang}
{help using} adding using followed by a path will load a set of matrices saved in that path. Otherwise, the matrices will be loaded from eresults.  {p_end}

{phang}
{opth p:refix(name)} creates new variables, the residualized variables will be stored as new variables that will be named with a prefix specified in `newvars'. This option will create new variables in the database. See option replace for replacing existing variables. {p_end}

{phang}
{opt replace} replaces the variables for their residualized version. See option newvars for creating new variables without changing existent ones. {p_end}

{title:Shortcomings}
{p2col 8 12 12 2: 1.} If some of the variables has missing values the command will throw an error.{p_end}
{p2col 8 12 12 2: 2.} Factor-variable and time-series operators not allowed.{p_end}

{title:Common Errors}
{p2col 8 12 12 2: 1.} newvars option: trying to create a variable that already exists.{p_end}
{p2col 8 12 12 2: 2.} If using option is omitted: if the eresults were erased or overwritten by other command {p_end}


{marker examples}{...}
{title:Examples}
{pstd}twres y x1 x2, p(w_)  {p_end}
{pstd}twres y x1 x2, replace  {p_end}
{pstd}twres y x1 x2 using "../folder/x", p(w_)  {p_end}


{title:Stored results}
{pstd}

{synoptset 15 tabbed}{...}
{syntab:Scalars}
{synopt:{cmd:e(dimN)}} number of first fixed effect without the redundants observations{p_end}
{synopt:{cmd:e(dimT)}} number of second fixed effect without the redundants observations{p_end}
{synopt:{cmd:e(rank_adj)}} Adjustment based on the rank of {cmd:e(A)} if {cmd:e(dimN)}<{cmd:e(dimT)}, otherwise is based on the rank of {cmd:e(C)}{p_end}

{synoptset 15 tabbed}{...}
{syntab:Macros}
{synopt:{cmd:e(absorbed)}} name of the fixed effects absorbed and the weight variable {p_end}

{synoptset 15 tabbed}{...}
{syntab:Matrices}
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
{p 12 8 1}{cmd:e(C)} Matrix C needed for the first and second step of the algorithm{p_end}
{p 12 8 1}{cmd:e(AinvDDDH)} Matrix AinvDDDH is needed for the first step of the algorithm{p_end}

{synoptset 15 tabbed}{...}
{syntab:Functions}
{synopt:{cmd:e(sample)}} marks estimation sample{p_end}
{p2colreset}{...}

{title:More information}
{phang}
For more information of {it:twres} {browse "https://github.com/paulosomaini/twowayreg-stata/tree/master":Github}


{title:Also see}
{help twset}
{help twest}
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
