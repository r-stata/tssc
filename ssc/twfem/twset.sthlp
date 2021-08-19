{smcl}
{* *! version 1.0  6 Sep 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "twres" "help twres"}{...}
{vieweralsosee "twest" "help twest"}{...}
{vieweralsosee "twsave" "help twsave"}{...}
{vieweralsosee "twload" "help twload"}{...}
{vieweralsosee "twload" "help twfem"}{...}
{viewerjumpto "Syntax" "twest##syntax"}{...}
{viewerjumpto "Description" "twest##description"}{...}
{viewerjumpto "Options" "twest##options"}{...}
{viewerjumpto "Remarks" "twest##remarks"}{...}
{viewerjumpto "Examples" "twest##examples"}{...}
{title:Title}
{phang}
{bf:twset} {hline 2} First step of the model based on Somaini and Wolak (2015). 

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:twset} varlist 
[{help weight}]
[{help if}]
[{help in}]
[{help using}]
[{cmd:,}
{it:options}]



{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt {weight}}}Analytic weights can be added as an optional third argument {p_end}
{synopt:{opt {help using}}} followed by a path will save a set of matrices in that path. If using option is omitted, the matrices will be stored in eresults {p_end}
{synopt:{opt gen:erate(newvars)}} to create new group identifiers {p_end}

{synoptline}
    varlist contains the name of the two group identifiers.
{p2colreset}{...}


{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:twset} is the first step of an algorithm to estimate the two-way fixed effect linear model. It uses the group identifiers and weights to create a set of matrices that can be used for multiple specifications. {p_end}

{marker options}{...}
{title:Options}

{marker opt_model}{...}
{dlgtab: Full Description}

{phang}
{help using} adding using followed by a path will save a set of matrices in that path. Otherwise, the matrices will be saved in eresults. STATA may fail if it tries to store a matrix that exceeds matsize in ereturn. Adding using avoids that limitation.  {p_end}

{phang}
{opt weight} the optional third input can be a variable of analytic weights. If weight option is omitted then the weigth of every observation will be 1.  {p_end}

{phang}
{opth gen:erate(newvars)} if the group identifiers are not consecutive after dropping redundants and missing observations, then you have this option to create new group identifiers. This option will create new variables in the database. {p_end}

{marker examples}{...}
{title:Examples}
{pstd}twset hhid tid, gen(newids newts)  {p_end}
{pstd}twset hhid tid  {p_end}
{pstd}twset hhid tid w, gen(newids newts)  {p_end}
{pstd}twset hhid tid w  {p_end}
{pstd}twset hhid tid using "../folder/x", gen(newids newts)  {p_end}
{pstd}twset hhid tid using "../folder/x"  {p_end}

{title:Shortcomings}
{p2col 8 12 12 2: 1.} Use the if and in options to exclude observations with missing values in the variables included in the specification.{p_end}

{title:Common Errors}
{p2col 8 12 12 2: 1.} The algorithm will not work if the fixed effects after removing redundant and missing observations are not consecutives and the {opth gen:erate}  option is not used. {p_end}
{p2col 8 12 12 2: 2.} generate option: The algorithm wil break if the user tries to create a new variable with a name that already exists.{p_end}

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
{p 12 8 1}{cmd:e(C)} Matrix C is needed for the first and second step of the algorithm{p_end}
{p 12 8 1}{cmd:e(AinvDDDH)} Matrix AinvDDDH is needed for the first step of the algorithm{p_end}

{synoptset 15 tabbed}{...}
{syntab:Functions}
{synopt:{cmd:e(sample)}} marks estimation sample{p_end}
{p2colreset}{...}

{title:More information}
{phang}
For more information of {it:twset} {browse "https://github.com/paulosomaini/twowayreg-stata/tree/master":Github}


{title:Also see}
{help twres}
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




