
{smcl}
{* *! version 1.0  30Jul2019}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{viewerjumpto "References" "references##references"}{...}
{title:Title}

{phang}
{bf:sob} {hline 2} Second-Order Bootstrap Standard Error Correction


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:sob}
[{depvar}]
[{indepvars}]
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt reps}}How many bootstrap iterations to use (default 400){p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:sob} creates heteroskedasticity robust standard errors for finite samples.

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:sob} may be used after running a regression command or as a regression command.
The output includes the virtual standard errors and p-values 
(robust in finite samples).

{marker example}{...}
{title:Example}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. regress price mpg weight foreign turn}{p_end}
{phang2}{cmd:. sob, reps(500)}{p_end}

    {hline}
{pstd}Alternate Syntax{p_end}
{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. sob price mpg weight foreign turn, reps(500)}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
In addition to the results saved by the {help bootstrap} command, {cmd:sob} stores the following in {cmd:e()}:


{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(se_virtual)}}virtual standard errors from second-order bootstrap{p_end}

{p2colreset}{...}
{pstd}
    Note: {cmd:e(V)} will be replaced by the bootstrapped variance covariance 
	matrix after running sob. Post estimation testing (e.g., using {cmd:test} 
	or {cmd:testnl}) will use the bootstrapped variance matrix instead of the 
	second-order corrected variance matrix.

{title:References}

{p 4 8 2}Hausman, J. and Palmer, C. 2012. {it:Economic Letters.} vol. 116: 232{c -}235



{title:Author}
{p 4 8 2}Original code by Christopher Palmer, adapted by Jonathan Jensen{break}
For questions or to report problems, contact Jonathan Jensen {break}
E-mail: jonathanjens@gmail.com. {break}




{title:Also see}

{p 4 13 2}
 
{help bootstrap}


