{smcl}
{* *! aefdr version 1.0 18Dec19}{...}
{cmd:help aefdr}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{cmd:aefdr} {hline 2}}False discovery rate p-value adjustment for adverse event data{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 13 2}
{cmdab:aefdr}  {cmd:,} {opth bodysys(varname)} {opth event(varname)} {opth pvalueadj(varname)}  [{it:options}]

{phang}
{bf:aefdr} requires summary data in long format with one row per event

{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt body:sys(varname)}}indicates the variable containing the higher level AE name/identifier. {varname} may be a numeric or a string variable{p_end}
{p2coldent:* {opt event(varname)}}indicates the variable containing the lower level AE name/identifier. {varname} may be a numeric or a string variable{p_end}
{p2coldent:* {opt pvalueadj(varname)}}indicates the variable containing the unadjusted p-values at the {cmd: event()} level (must be numeric){p_end}

{synopt:{opt fdr:val(#)}}indicates the alpha value at which events will be flagged if the adjusted p-values fall below; default is {cmd:fdrval(0.1)}{p_end}

{synoptline}
{p2colreset}{...}
{pstd}* {cmd:bodysys()}, {cmd:event()} and {cmd:pvalueadj()} are required{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:aefdr} performs a false discovery rate (FDR) p-value adjustment for adverse event data where events are nested within
bodysystems from a two-arm clinical trial as proposed by {help aefdr##R2012:Mehrotra and Adewale (2012)}.
The FDR procedure is a two-step approach that utilises the structure of adverse event data 
to adjust p-values to reduce the false discovery rate.


{marker options}{...}
{title:Options}

{phang}
{opt bodysys(varname)} specifies the variable containing the higher level AE name/identifier. 
{cmd:bodysys(varname)} is required and may be a numeric or a string variable.

{phang}
{opt event(varname)} specifies the variable containing the lower level AE name/identifier. 
{cmd:event(varname)} is required and may be a numeric or a string variable.

{phang}
{opt pvalueadj(varname)} indicates the variable containing the unadjusted p-values at the {cmd: event()} level.
{cmd:pvalueadj(varname)} is required and must be a numeric variable.

{phang}
{opt fdrval(#)} indicates the alpha value at which events will be flagged if the adjusted p-values fall below;
default is {cmd:fdrval(0.1)}.

{marker remarks}{...}
{title:Remarks}

{phang2}{help aefdr##general_remarks:General remarks}{p_end}

{marker general_remarks}{...}
    {title:General remarks}

{pstd}
(1) Summary data are required in long format with one row per event.

{pstd}
(2) The command creates a new dataset with one row per event containing summary level data
including a variable, {it: p2} containing the adjusted p-value for each event in {cmd:event}; 
a variable, {it: p2_bs} containing the adjusted p-value for each event in {cmd:bodysys}; and a variable, 
{it: flag} which equals 1 if events satisfy the p-value threshold specified in {cmd:fdrval}.

{pstd}
(3) Once the command finishes running the new dataset is stored in memory and saved in the current working directory.
If users want to keep the original dataset in memory we recommend using the {cmd: preserve} and {cmd: restore} commands.
See {it:{help preserve}} for further details.

     
{marker examples}{...}
{title:Examples}

{pstd}
Analysing an example dataset{p_end}
{phang2}{cmd:. use example_aefdr.dta}{p_end}

{pstd}
FDR adjustment {p_end}
{phang2}{cmd:. aefdr , bodysys(bodysystem) event(ae) pvalueadj(pvalue_unadj)}{p_end}

{pstd}
FDR adjustment using the {cmd:fdrval} option to change the alpha value at which signals are raised{p_end}
{phang2}{cmd:. use example_aefdr.dta, clear}{p_end}
{phang2}{cmd:. aefdr , bodysys(bodysystem) event(ae) pvalueadj(pvalue_unadj) fdrval(0.1)}{p_end}

{marker references}{...}
{title:References}

{marker R2012}{...}
{phang}
Mehrotra, D. V. and A. J. Adewale. 2012. Flagging clinical adverse experiences: Reducing false discoveries without materially compromising power for detecting true signals. 
{it:Statistics in Medicine} 31(18): 1918-1930. 

{marker R2004}{...}
{phang}
Mehrotra, D. V. and J. F. Heyse. 2004. Use of the false discovery rate for evaluating clinical safety data.. 
{it:Statistical Methods in Medical Research} 13(3): 227-238. 


{title:Authors}

{pstd}
Rachel Phillips{break}
Imperial College London, UK{break}
r.phillips@imperial.ac.uk

{pstd}
Suzie Cro{break}
Imperial College London, UK{break}
