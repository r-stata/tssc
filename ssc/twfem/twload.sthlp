{smcl}
{* *! version 1.0  6 Sep 2020}{...}
{viewerjumpto "Syntax" "twest##syntax"}{...}
{viewerjumpto "Description" "twest##description"}{...}
{viewerjumpto "Options" "twest##options"}{...}
{viewerjumpto "Remarks" "twest##remarks"}{...}
{viewerjumpto "Examples" "twest##examples"}{...}
{title:Title}
{phang}
{bf:twsave} {hline 2} load the matrices saved with twsave.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:twload} 
{cmd:}
[{help using}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt {help using}}} followed by a path will load the set of matrices that has been saved in that path. If using option is omitted, the command will search for matrices in the current directory. {p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:twload} load the matrices saved with twsave. twsave and twload are used to save and load the results of twset which is the step that is more computationally demanding. {p_end}


{title:Common Errors}
{p2col 8 12 12 2: 1.} This command will work only if there are matrices saved in the path folder. 

{marker examples}{...}
{title:Examples}
{pstd}twload using "../folder/x" {p_end}
{pstd} In this example the matrices will be load from "folder" with prefix "x".

{synoptline}
{p2colreset}{...}
{p 4 6 2}


{title:More information}
{phang}
For more information of {it:twload} {browse "https://github.com/paulosomaini/twowayreg-stata/tree/master":Github}


{title:Also see}
{help twset}
{help twres}
{help twest}
{help twsave}
{help twfem}


{title:References}
{phang}
Somaini, P. and F.A. Wolak, (2015), An Algorithm to Estimate the Two-Way Fixed Effects Model, Journal of Econometric Methods, 5, issue 1, p. 143-152.

{title: Aditional References}
{phang}
Arellano, M. (1987), Computing Robust Standard Errors for Within-Groups Estimators, Oxford Bulletin of Economics and Statistics, 49, issue 4, p. 431–434.

{phang}
Cameron, A. C., & Miller, D. L. (2015). A practitioner’s guide to cluster-robust inference. Journal of human resources, 50(2), 317-372.


