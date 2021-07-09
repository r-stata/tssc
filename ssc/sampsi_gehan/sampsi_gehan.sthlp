{smcl}
{* *! version 1.0  2 Jul 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "sampsi_gehan##syntax"}{...}
{viewerjumpto "Description" "sampsi_gehan##description"}{...}
{viewerjumpto "Options" "sampsi_gehan##options"}{...}
{viewerjumpto "Remarks" "sampsi_gehan##remarks"}{...}
{viewerjumpto "Examples" "sampsi_gehan##examples"}{...}
{title:Title}
{phang}
{bf:sampsi_gehan} {hline 2} a command to give the parameters of the single stage Gehan design

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:sampsi_gehan}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt b:eta(#)}}  specifies the first stage maximum probability of seeing no responses. Default value is 0.1.{p_end}
{synopt:{opt p:1(#)}}  specifies the desired probability of response. Default value is 0.2.{p_end}
{synopt:{opt se(#)}}   specifies the desired standard error in the second stage. Default value is 0.1.{p_end}
{synopt:{opt s:tart(#)}}  specifies the smallest n to start the search from. Default value is 1.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
 {cmd:sampsi_gehan} calculates the sample sizes for the first and second stages of the Gehan design
    (1961).

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt b:eta(#)}  specifies the first stage maximum probability of seeing no responses. Default value is 0.1

{phang}
{opt p:1(#)}  specifies the desired probability of response. Default value is 0.2

{phang}
{opt se(#)}   specifies the desired standard error in the second stage. Default value is 0.1

{phang}
{opt s:tart(#)}  specifies the smallest n to start the search from. Default value is 1


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
 {stata sampsi_gehan, p1(0.2) beta(0.05) se(0.1) }

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(n1)}}  The first stage sample size {p_end}{synopt:{cmd:r(p1)}}  The interesting p1  {p_end}{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(beta)}}  The type 2 error {p_end}{synopt:{cmd:r(se)}}  Standard error {p_end}{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(n2)}}  The second stage sample size {p_end}

{title:References}
{pstd}

{pstd}
Gehan, E.A. (1961) The Determination of the Number of Patients Required in a Preliminary and 
Follow-Up Trial of a New Chemotherapeutic Agent. Journal of Chronic Diseases, 13, 346-353.

{pstd}

{pstd}


{title:Author}
{p}

Dr Adrian Mander, MRC Biostatistics Unit, University of Cambridge.

Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}



{title:See Also}
Related commands:

{pstd}
{help sampsi_fleming} (if installed)  {stata ssc install sampsi_fleming} (to install this command)

{pstd}
{help simon2stage} (if installed)   {stata ssc install simon2stage} (to install this command)

{pstd}
