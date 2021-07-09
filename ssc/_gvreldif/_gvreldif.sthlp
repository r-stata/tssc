{smcl}
{...}
{cmd:help egen vreldif}{right:Author: Stas Kolenikov}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{manlink D egen} {hline 2}}Extensions to generate{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{cmd:egen} {dtype} {newvar} {cmd:= vreldif(}{help varlist:varlist1}{cmd:)} {ifin}
{cmd:, by(}{help varlist:varlist2}{cmd:)}

{pstd}
{cmd: egen ... = vreldif()} creates a variable that contains
the relative differences (see {help mreldif}) of the variables in {it:varlist1}
within the values identified by {it:varlist2}. It is useful to compare results
in two {help append}ed data sets when some minor numeric discrepancies are expected.

{pstd}
{cmd:by(}{it:varlist2}{cmd:)} is required. It is expected that each unique
combination of variables in {it:varlist2} identifies at most two observations
in the data set.

{pstd}Comparable functionality can be achieved by the following Stata pseudocode:

{phang}{cmd:generate {it:newvar} = 0}

{phang}{cmd:foreach x of varlist {it:varlist1} {c -(} }

{phang2}{cmd:bysort {it:varlist2}: replace {it:newvar} = {it:newvar} + reldif( `x'[1], `x'[_N] )}

{phang}{cmd:{c )-}}

{phang}{cmd:bysort {it:varlist2}: replace {it:newvar} = . if _N == 1}


{title:Example}

{phang}{cmd:. sysuse auto, clear}

{phang}{cmd:. set seed 10101}

{phang}{cmd:. gen byte replic = ceil( 0.5+1.5*uniform())}

{phang}{cmd:. expand replic, gen( datacopy )}

{phang}{cmd:. tabulate datacopy}

{phang}{cmd:. replace weight = weight + uniform()}

{phang}{cmd:. egen check1 = vreldif(mpg price), by(make)}

{phang}{cmd:. egen check2 = vreldif(mpg weight), by(make)}

{pstd}The variable {it:check1} should be zero in the observations that were doubled up,
and missing in the unique observations:

{phang}{cmd:. assert check1 == 0 if !missing( check1 )}

{pstd}The variable {it:check2} will not be zero in the observations that were doubled up,
so this assert should fail:

{phang}{cmd:. assert check2 == 0 if !missing( check2 )}

{pstd}Since the differences of the values in the {it:weight} variable between
the two "copies" of data (identified by {it:datacopy} variable) are in the fourth
digit, the non-missing values of {it:check2} should be of the order 1e-4:

{phang}{cmd:. sum check2}
