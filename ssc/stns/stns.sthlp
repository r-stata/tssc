{smcl}
{* *! version 1.4.4 15May2014}{...}
{viewerdialog graph "dialog stns_graph"}{...}
{viewerdialog list "dialog stns_list"}{...}
{vieweralsosee "[ST] stns" "mansection ST stns"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[ST] st" "help st"}{...}
{vieweralsosee "[ST] stci" "help stci"}{...}
{vieweralsosee "[ST] stcox" "help stcox"}{...}
{vieweralsosee "[ST] stns graph" "help stns_graph"}{...}
{vieweralsosee "[ST] stns list" "help stns_list"}{...}
{vieweralsosee "[ST] stset" "help stset"}{...}
{viewerjumpto "Syntax" "stns##syntax"}{...}
{viewerjumpto "Description" "stns##description"}{...}
{viewerjumpto "Examples" "stns##examples"}{...}
{viewerjumpto "Saved results" "stns##saved_results"}{...}
{title:Title}

{p2colset 5 18 20 1}{...}
{p2col :{help stns:stns} {hline 2}}Graph and list the net survival and net cumulative hazard functions{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 21 2}
{cmd:stns} {opt g:raph} {ifin} [{cmd:,} ...]

{p 8 21 2}
{cmd:stns} {opt l:ist} {ifin} [{cmd:,} ...]

{pstd}
{opt using}, {opt age()}, {opt period()}, and {opt rate()} are required to estimate the
 net survival function, net failure function, and net cumulative hazard function. When 
 the rate table is stratified, {opt strata()} is required to match the stratification 
 variables in the dataset and the rate table.
{p_end}

{pstd}
You must {cmd:stset} your data before using {cmd:stns}; see
{manhelp stset ST}.{p_end}

{pstd}
See {help stns_graph:stns graph} and {help stns_list:stns list} for details of syntax.


{marker description}{...}
{title:Description}

{pstd}
{cmd:stns} reports and creates variables containing the estimated net survival and
related functions, such as the net cumulative hazard function. 

{pmore}
{cmd:stns graph} graphs the net survival function.

{pmore}
{cmd:stns list} lists the estimated net survival and related functions.


{marker examples}{...}
{title:Example: Listing and graphing variables}
{pstd}Setup{p_end}
{phang2}{cmd:. use rdata}{p_end}
{phang2}{cmd:. stset survtime, failure(cens==1) id(id)}

{pstd}Suppress showing st settings{p_end}
{phang2}{cmd:. stset, noshow}

{pstd}Compute and list the net survival function{p_end}
{phang2}{cmd:. stns list using myslopop, age(agediag=age) period(datediag=year) rate(rate) strata(sex)}

{pstd}Graph the net survival function{p_end}
{phang2}{cmd:. stns graph}


{title:Example: Comparing net survival or net cumulative hazard functions}
{pstd}Graph the net survival functions for the two categories of {cmd:sex}, showing results on one graph{p_end}
{phang2}{cmd:. stns graph using myslopop, age(agediag=age) period(datediag=year) rate(rate) strata(sex), by(sex)}

{pstd}Same as above command but produce two side-by-side graphs{p_end}
{phang2}{cmd:. stns graph, by(sex) separate}

{pstd}Now graph the net cumulative hazard functions for the two
categories of {cmd:sex}{p_end}
{phang2}{cmd:. stns graph, cumhaz by(sex)}

{pstd}Now list the two categories of {cmd:sex} for the net survival function{p_end}
{phang2}{cmd:. stns list, at(0 100 to 1700) by(sex)}{p_end}
