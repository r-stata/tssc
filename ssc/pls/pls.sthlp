{smcl}
{* *! version 1.1  25may2016}{...}

{cmd:help pls}
{hline}

{title:Title}

{phang}
{bf:pls} {hline 2} calculates composite variables using the partial least squares path modeling (PLS) algorithm


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:pls} {cmd:(}{newvar:1} = {varlist:1}{cmd:)}
{cmd:(}{newvar:2} = {varlist:2}{cmd:)} 
{it:...} {cmd:(}{newvar:N} = {varlist:N}{cmd:)} {ifin}
[, {it:options}]

{synoptset 50 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options}
{synopt:{cmdab:a:djacent(}{varlist:1} [, {varlist:2}, {it:...}, {varlist:N}])}defines which composites are adjacent to each other{p_end}
{synopt:{opt m:odeB}({varlist})}sets Mode B outer estimation{p_end}
{synopt:{opt s:cheme(scheme)}}sets innner estimation scheme{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is allowed; see {manhelp by D}.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:pls} calculates composite variables using the partial least squares path 
modeling (PLS) algorithm. 

{pstd}
The composites are calculated as weighted combinations of existing variables 
using the weight algorithm introduced by Wold {help pls##wold1982:(see Wold 1982)}.
The composites produced by {cmd:pls} are identical to the composites produced by commercial
PLS software as well as the open source 
{browse "https://cran.r-project.org/web/packages/matrixpls/index.html":matrixpls}
R package except for small numerical differences due to different convergence
criterion.

{marker options}{...}
{title:Options}

{dlgtab:Options}

{phang}
{cmd:adjacent(}{varlist:1} [, {varlist:2}, {it:...}, {varlist:N}]) defines which composites are adjacent to each other during inner
estimation. The first variable of varlist is defined as being adjacent to the
other variables. If the path scheme is used for inner estimation, the 
directionality of adjacencies is from the other variables toward the first
variable.

{phang}
{opt modeB}({varlist})} sets Mode B outer estimation for the composites in varlist. All other composites are calculated with Mode A outer estimation.

{phang}
{opt scheme(scheme)} sets innner estimation scheme. Valid values for scheme are centroid, factor, and path. The default is the centroid method.{p_end}

{marker remarks}{...}
{title:Remarks}

{phang}
This program is provided for educational purposes. It is difficult to recommend 
the PLS composites for any serious empirical work
(see {help pls##rma2015:R{c o:}nkk{c o:}, McIntosh, and Antonakis (2015)})

{phang}
{cmd:pls} is not an official Stata command. Please cite it as: 

{phang}R{c o:}nkk{c o:}, M. (2016) pls: Stata module to calculate PLS composites
https://github.com/mronkko/StataPLS

{marker examples}{...}
{title:Example}
{pstd}The example uses the ECSI dataset {help pls##tecl2005:(Tenenhaus et al 2005)}, which
is commonly used to demonstrate PLS. The data are standardized with the user written {cmd:center} command.{p_end}

{pstd}Setup the data{p_end}

{phang2}{cmd:. sysuse ecsimobi}{p_end}
{phang2}{cmd:. center _all, inplace standardize}{p_end}

{pstd}Calculate the PLS composites{p_end}

{phang2}{cmd:. pls (Expectation = CUEX1-CUEX3) ///}{break}
{cmd:(Satisfaction = CUSA1-CUSA3) ///}{break}
{cmd:(Complaint = CUSCO) ///}{break}
{cmd:(Loyalty = CUSL1-CUSL3) ///}{break}
{cmd:(Image = IMAG1-IMAG5) ///}{break}
{cmd:(Quality = PERQ1-PERQ7) ///}{break}
{cmd:(Value = PERV1-PERV2), ///}{break}
{cmd:adjacent(Expectation Image, Quality Expectation, Value Expectation Quality, ///}{break}
{cmd:Satisfaction Value Quality Image Expectation, Complaint Satisfaction, Loyalty Complaint Satisfaction Image) ///}{break}
{cmd:scheme("path")}{break}

{pstd}Regression between the composites{p_end}

{phang2}{cmd:. regress Expectation Image}{p_end}
{phang2}{cmd:. estimates store Expectation}{p_end}

{phang2}{cmd:. regress Quality Expectation}{p_end}
{phang2}{cmd:. estimates store Quality}{p_end}

{phang2}{cmd:. regress Value Expectation Quality}{p_end}
{phang2}{cmd:. estimates store Value}{p_end}

{phang2}{cmd:. regress Satisfaction Value Quality Image Expectation}{p_end}
{phang2}{cmd:. estimates store Satisfaction}{p_end}

{phang2}{cmd:. regress Complaint Satisfaction}{p_end}
{phang2}{cmd:. estimates store Complaint}{p_end}

{phang2}{cmd:. regress Loyalty Complaint Satisfaction Image}{p_end}
{phang2}{cmd:. estimates store Loyalty}{p_end}

{phang2}{cmd:. estimates table Expectation Quality Value Satisfaction Complaint Loyalty}{p_end}

{marker references}{...}
{title:References}

{marker rma2015}{...}
{phang}
R{c o:}nkk{c o:}, M., McIntosh, C. N., & Antonakis, J. (2015). On the adoption of partial least squares in psychological research: Caveat emptor. {it:Personality and Individual Differences}, (87), 76-84. 
{browse "http://doi.org/10.1016/j.paid.2015.07.019":DOI:10.1016/j.paid.2015.07.019}
{p_end}

{marker tecl2005}{...}
{phang}
Tenenhaus, M., Esposito Vinzi, V., Chatelin, Y.-M., & Lauro, C. (2005). PLS path modeling. {it:Computational Statistics & Data Analysis}, 48(1), 159-205.
{browse "http://doi.org/10.1016/j.csda.2004.03.005":DOI:10.1016/j.csda.2004.03.005}
{p_end}

{marker wold1982}{...}
{phang}
Wold, H. (1982). Soft modeling: The basic design and some extensions. 
In K. G. J{c o:}reskog & S. Wold (Eds.), {it:Systems under indirect observation?: causality, structure, prediction} (pp. 1-54). Amsterdam: North-Holland.
