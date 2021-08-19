{smcl}
{* *! version 1.0  6 Sep 2020}{...}
{viewerjumpto "Syntax" "twest##syntax"}{...}
{viewerjumpto "Description" "twest##description"}{...}
{viewerjumpto "Options" "twest##options"}{...}
{viewerjumpto "Remarks" "twest##remarks"}{...}
{viewerjumpto "Examples" "twest##examples"}{...}
{title:Title}
{phang}
{bf:twsave} {hline 2} save the matrices created with twset.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:twsave} 
{cmd:}
[{help using}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt {help using}}} followed by a path will save a set of matrices in that path. If using option is omitted the matrices will be stored in the current directory {p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:twsave} save the matrices created with twset and stored in eresults. wsave and twload are used to save and load the results of twset which is the step that is more computationally demanding. {p_end}

{title:Common Errors}
{p2col 8 12 12 2: 1.} This command only work after running "twset" and before the eresults are over-written. 

{marker examples}{...}
{title:Examples}
{pstd}twsave using "../folder/x" {p_end}
{pstd} In this example the matrices will be saved in "folder" with prefix "x".


{title:More information}
{phang}
For more information of {it:twsave} {browse "https://github.com/paulosomaini/twowayreg-stata/tree/master":Github}


{title:Also see}
{help twset}
{help twres}
{help twest}
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

