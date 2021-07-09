{smcl}
{cmd:help elabel duplicates}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel duplicates} {hline 2} Report or remove duplicate value labels


{title:Syntax}

{p 4 8 2}
Report duplicate value labels

{p 8 12 2}
{cmd:elabel} {cmdab:dup:licates} {cmdab:rep:ort}
[ {it:{help elabel##elblnamelist:elblnamelist}} ]


{p 4 8 2}
Remove duplicate value labels

{p 8 12 2}
{cmd:elabel} {cmdab:dup:licates} {cmd:remove}
{it:{help elabel##elblnamelist:elblnamelist}}

{p 8 12 2}
{cmd:elabel} {cmdab:dup:licates} {cmd:retain}
{it:{help elabel##elblnamelist:elblname}}
[ {it:{help elabel##elblnamelist:elblname}} {it:...} ]


{title:Description}

{pstd}
{cmd:elabel duplicates} reports or removes duplicate value labels. Duplicate 
value labels define the same integer-to-text mappings.

{pstd}
{cmd:elabel duplicates report} finds and reports (groups of) duplicate value 
labels among the value labels in {it:elblnamelist} or, if {it:elblnamelist} 
is not specified, among all value labels in memory. To find all duplicates 
of a specific value label, specify exactly one value label name. Results are 
returned in {cmd:r()}.

{pstd}
{cmd:elabel duplicates remove} removes all but the first value label 
(in each group) of duplicate value labels among the value labels in 
{it:elblnamelist}. Duplicate value labels are detached from variables 
and dropped from memory (see {helpb elabel_remove:elabel remove}). The 
retained value labels in each group are attached to variables that 
previously had one of the duplicated value labels attached. 

{pstd}
{cmd:elabel duplicates retain} removes all duplicates of the specified 
value labels. Duplicate value labels are detached from variables and 
dropped from memory (see {helpb elabel_remove:elabel remove}). The retained 
value labels are attached to variables that previously had one of the 
duplicates attached. The specified value label names may not define 
duplicate value labels.


{title:Examples}

{pstd}
Setup

{phang2}{stata sysuse nlsw88:. sysuse nlsw88}{p_end}
{phang2}{stata label define southlbl 0 "no" 1 "yes":. label define southlbl 0 "no" 1 "yes"}{p_end}
{phang2}{stata label values south southlbl:. label values south southlbl}{p_end}
{phang2}{stata label define c_citylbl 0 "no" 1 "yes":. label define c_citylbl 0 "no" 1 "yes"}{p_end}
{phang2}{stata label values c_city c_citylbl:. label values c_city c_citylbl}{p_end}
{phang2}{stata describe south c_city:. describe south c_city}{p_end}

{pstd}
Find and report duplicate value labels

{phang2}{stata elabel duplicates report:. elabel duplicates report}{p_end}

{pstd}
Create one more duplicate value label

{phang2}{stata label define yesno 0 "no" 1 "yes":. label define yesno 0 "no" 1 "yes"}{p_end}

{pstd}
Retain value label {cmd:yesno} and drop {cmd:southlbl} and {cmd:c_citylbl}

{phang2}{stata elabel duplicates retain yesno:. elabel duplicates retain yesno}{p_end}
{phang2}{stata describe south c_city:. describe south c_city}{p_end}


{title:Saved results}

{pstd}
{cmd:elabel duplicates report} saves the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 18 tabbed}{...}
{synopt:{cmd:r(N_duplicates)}}number of (groups of) duplicate 
value labels
{p_end}
{synopt:{cmd:r(n_duplicates}{it:#}{cmd:)}}number of value 
labels in group {it:#}; 0<{it:#}<{cmd:r(N_duplicates)}.
{p_end}

{pstd}
Macros{p_end}
{synoptset 18 tabbed}{...}
{synopt:{cmd:r(duplicates}{it:#}{cmd:)}}duplicate value 
labels in group {it:#}; 0<{it:#}<{cmd:r(N_duplicates)}.
{p_end}


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help label}
{p_end}

{psee}
if installed: {help elabel},
{help elabel_compare:elabel compare}, 
{help labeldup}
{p_end}
