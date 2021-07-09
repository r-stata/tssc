{smcl}
{* *! version 11.2  22aug2015}{...}
{cmd:help incomecdf} {right:Sean Higgins}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:incomecdf}}is deprecated; see help {help ceqgraph cdf} {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
    {cmd:incomecdf} {varlist} {ifin} {weight} [{cmd:,} {it:options}]
	
{p 4 4 2}
{cmd:pweight}, {cmd:fweight}, {cmd:aweight}, and {cmd:iweight} are allowed; see help {help weights}.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:PPP conversion}
{synopt :{opth ppp(real)}}PPP conversion factor (LCU per international $, consumption-based) from year of PPP (e.g., 2005 or 2011) to year of PPP; do not use PPP factor for year of household survey{p_end}
{synopt :{opth cpib:ase(real)}}CPI of base year (i.e., year of PPP, usually 2005 or 2011){p_end}
{synopt :{opth cpis:urvey(real)}}CPI of year of household survey{p_end}
{synopt :{opt da:ily}}Indicates that variables are in daily currency{p_end}
{synopt :{opt mo:nthly}}Indicates that variables are in monthly currency{p_end}
{synopt :{opt year:ly}}Indicates that variables are in yearly currency{p_end}
{synopt :{opt al:readyppp}}Indicates that the variables have already been converted to purchasing power parity (PPP) adjusted US dollars per day{p_end}

{syntab:Graph options}
{synopt :{opt y:title(string)}}title of y-axis {p_end}
{synopt :{opt x:title(string)}}title of x-axis{p_end}
{synopt :{opt t:itle(string)}}title of graph{p_end}
{synopt :{opt sub:title(string)}}subtitle of graph{p_end}
{synopt :{opt col:ors(string)}}string of colors for CDF lines{p_end}
{synopt :{opt leg:end(string)}}legend options{p_end}
{synopt :{opt l:width(string)}}width of lines{p_end}
{synopt :{opt no:draw}}suppress graph{p_end}

{title:Description}

{pstd}
{cmd:incomecdf} graphs cumulative distribution functions (CDFs) of income for
different income concepts, after converting from local currency to purchasing power
parity (PPP) adjusted dollars if the {opth ppp(real)}, {opth cpib:ase(real)}, {opth cpis:urvey(real)}, and {opt da:ily}/{opt mo:nthly}/{opt year:ly} options are specified. The command produces five graphs at various levels of 'zooming in' on the x-axis and inserts
vertical poverty lines at $1.25, $2.50, $4, $10, $50, and $100 per day PPP. The graphs
are saved in the working directory as CDF`x'.gph where `x' is from the list 250
400 1000 5000 10000.

{pstd}
{cmd: incomecdf} automatically converts local currency variables to PPP dollars, using the PPP conversion 
factor given by {opth ppp(real)}, the consumer price index (CPI) of the year of PPP (e.g., 2005 or 
2011) given by {opth cpib:ase(real)}, and the CPI of the year of the household 
survey used in the analysis given by {opth cpis:urvey(real)}. The year of PPP, also called base year, 
refers to the year of the International Comparison Program (ICP) that is being used, e.g. 2005 or 2011. 
The survey year refers to the year of the household survey used in the analysis. If the year of PPP is 
2005, the PPP conversion factor should be the "2005 PPP conversion factor, private consumption (LCU per 
international $)" indicator from the World Bank's World Development Indicators (WDI). If the year of 
PPP is 2011, use the "PPP conversion factor, private consumption (LCU per international $)" indicator 
from WDI. The PPP conversion factor should convert from year of PPP to year of PPP. In other words, 
when extracting the PPP conversion factor, it is possible to select any year; DO NOT select the year of 
the survey, but rather the year that the ICP was conducted to compute PPP conversion factors (e.g., 
2005 or 2011). The base year (i.e., year of PPP) CPI, which can also be obtained from WDI, should match 
the base year chosen for the PPP conversion factor. The survey year CPI should match the year of the 
household survey. Finally, for the PPP conversion, the user can specify whether the original variables 
are in local currency units per day ({opt da:ily}), per month ({opt mo:nthly}), or per year 
({opt year:ly}, the default assumption).

{pstd}
If the variables given in {varlist} have already been converted to PPP dollars per day, specify the {opt al:readyppp} option and do {bf:not} specify the {opth ppp(real)}, {opth cpib:ase(real)}, {opth cpis:urvey(real)}, or {opt da:ily}/{opt mo:nthly}/{opt year:ly} options.

{pstd}
{opt ytitle(string)} enters the title of the y-axis. The default is 'Cumulative percent of the 
population.' {opt xtitle(string)} enters the title of the x-axis. The default is 'Income in $ PPP per 
day.' {opt title(string)} enters the title of the graph. The default is no title. 
{opt subtitle(string)} enters the subtitle of the graph. The default is no subtitle. 
{opt colors(string)} lists a string of colors for the CDF curves. {opth legend(legend_style)} 
specifies options for the legend. See {manhelp legend_option G}.

{phang}
{opth lwidth(linewidthstyle)} specifies the line width for the curves. The default is "thin".
See {manhelp linewidthstyle G}.

{phang}
{opt nodraw} suppresses the graph.

{title:Examples}

{pstd}Locals for PPP conversion (obtained from WDI through the {cmd: wbopendata} command){p_end}
{phang} {cmd:. local ppp = 1.5713184 // 2005 Brazilian reais per 2005 $ PPP}{p_end}
{phang} {cmd:. local cpi = 95.203354 // CPI for Brazil for 2009}{p_end}
{phang} {cmd:. local cpi05 = 79.560051 // CPI for Brazil for 2005}{p_end}

{phang}If income is in local currency per year{p_end}
{phang} {cmd:. incomecdf ym_BC yn_BC yd_BC ypf_BC [pw=s_weight], ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') yearly}{p_end}

{phang}If income is in local currency per month{p_end}
{phang} {cmd:. incomecdf ym_BC yn_BC yd_BC ypf_BC [pw=s_weight], ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') monthly}{p_end}

{phang}If income is in local currency per day{p_end}
{phang} {cmd:. incomecdf ym_BC yn_BC yd_BC ypf_BC [pw=s_weight], ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') daily}{p_end}

{phang}Graphing options{p_end}
{phang} {cmd:. incomecdf ym_BC yn_BC yd_BC ypf_BC [pw=s_weight], ppp(`ppp') cpibase(`cpi05') cpisurvey(`cpi') yearly title("Cumulative Distribution Functions of Income") subtitle("Brazil") colors(red blue green sand) legend(position(5) ring(0) cols(1)) nodraw}{p_end}

{title:Author}

{p 4 4 2}Sean Higgins, Tulane University, shiggins@tulane.edu

{title:Reference}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}

{phang}
Lustig, N. and S. Higgins. 2013. "Commitment to Equity Assessment (CEQ): Estimating the Incidence of Social Spending, Subsidies and Taxes Handbook." {browse "http://www.commitmentoequity.org/publications_files/Methodology/CEQWPNo1%20Handbook%20Edition%20Sept%202013.pdf":CEQ Working Paper 1.}{p_end}
