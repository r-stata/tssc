{smcl}
{* *! version 1.0 25 May 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "cedesign##syntax"}{...}
{viewerjumpto "Description" "cedesign##description"}{...}
{viewerjumpto "Options" "cedesign##options"}{...}
{viewerjumpto "Remarks" "cedesign##remarks"}{...}
{viewerjumpto "Examples" "cedesign##examples"}{...}
{title:Title}
{phang}
{bf:cedesign} {hline 2} A command to find the optimal flexible two stage single-arm binary outcome design using the discrete conditional error function.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:cedesign}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt p1(#)}}  specifies the alternative probability that the study is powered for. Default value is 0.3.{p_end}
{synopt:{opt p0(#)}}  specifies the null probability that is used in the null hypothesis. Default value is 0.1.{p_end}
{synopt:{opt alpha(#)}}  specifies the significance level. Default value is 0.05.{p_end}
{synopt:{opt beta(#)}}  specifies the type II eror level. Default value is 0.1.{p_end}
{synopt:{opt n1min(#)}}  specifies the minimum first stage sample size. Default value is 2.{p_end}
{synopt:{opt n1max(#)}}  specifies the maximum first stage sample size. Default value is 22.{p_end}
{synopt:{opt n2min(#)}}  specifies the minimum second stage sample size. Default value is 2.{p_end}
{synopt:{opt n1n2max(#)}}  Default value is 50.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
This command creates a two-stage fully flexible design with a binary outcome variable, often response or not,
 that uses a conditional error function. The design usually is interested in rejecting the null hypothesis
that response is {bf:H0: p=p0}. The methods are published by S. Englert and M. Keiser (2012)
Improving the flexibility and efficiency of phase 2 designs for oncology trials, Biometrics.

{pstd}
A discrete conditional error function, D(i) is defined for the number of responders, i, in the first phase 
of the trial. If the second stage p-value is < D(i) then the null hypothesis is rejected. The function D() must 
be non-decreasing with i but this command allows no other restrictions on what D() can take. However, 
there is no point picking values other than the discrete set of second stage p-values.

{pstd}
However, there are a huge number of possible first stage and second stage sample sizes but this command will
search over a range of values and find the optimal one. It can take a huge amount of time if you pick large 
sample sizes but the search
uses a branch and bound algorithm, so is efficient. Currently the optimal one is one that has the smallest expected
sample size at p0.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt p1(#)}  specifies the alternative probability that the study is powered for. Default value is 0.3

{phang}
{opt p0(#)}  specifies the null probability that is used in the null hypothesis. Default value is 0.1

{phang}
{opt alpha(#)}  specifies the significance level. Default value is 0.05

{phang}
{opt beta(#)}  specifies the type II eror level. Default value is 0.1

{phang}
{opt n1min(#)}  specifies the minimum first stage sample size. Default value is 2

{phang}
{opt n1max(#)}  specifies the maximum first stage sample size. Default value is 22

{phang}
{opt n2min(#)}  specifies the minimum second stage sample size. Default value is 2

{phang}
{opt n1n2max(#)}  Default value is 50


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
Assuming that p0=0.1, p1=0.5,we can run the command 

{pstd}
{stata cedesign, p0(0.1) p1(0.5) n1min(5) n1n2max(30)}

{title:Author}
{p}

Dr Adrian Mander, MRC Biostatistics Unit, University of Cambridge.

Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}



{title:See Also}
Related commands:

{pstd}

{pstd}
{help simon2stage} (if installed) install by clicking {stata ssc install simon2stage}

{pstd}
{help crm} (if installed) install by clicking {stata ssc install crm}
