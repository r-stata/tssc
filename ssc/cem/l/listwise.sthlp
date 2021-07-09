{smcl}

{cmd:help listwise}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col:{hi:cem} {hline 2}}Keep only complete cases{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 14 2}
{opt imbalance} {it:varlist} 


{synoptset 20 tabbed}{...}
{marker options}{...}



{title:Description}

{pstd} {cmd:listwise} removes observations that are have missing values in
the varlist.
 
{title:Arguments}

{dlgtab:Main}

{phang} 
{it:varlist} is a list of variables to be use for analysis.  

{title:References and Distribution}

{pstd}
{cmd:cem} is licensed under GLP2. For more information, see: http://gking.harvard.edu/cem/

{pstd} For a full reference on Coarsened Exact Matching, see:

{phang} Stefano M. Iacus, Gary King, and Giuseppe Porro, "Matching for Causal
Inference Without Balance Checking", copy at
<http://gking.harvard.edu/files/abs/cem-abs.shtml>

{pstd} To report bugs or give comments, please contact Matthew Blackwell
<blackwel@fas.harvard.edu>.
