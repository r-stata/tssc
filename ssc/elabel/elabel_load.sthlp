{smcl}
{cmd:help elabel load}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel load} {hline 2} Define value labels from file


{title:Syntax}

{p 8 12 2}
{cmd:elabel load}
[ {it:lblnamelist} ]
[ {helpb elabel##iffeexp:iff {it:eexp}} ]
{helpb using} {help elabel_load##fn:{it:filename}}
[ {cmd:,} {it:options} ]


{p 4 10 2}
where {it:lblnamelist} may contain wildcard characters

{marker fn}{...}
{p 4 10 2}
{help filename:{it:filename}} is either a do-file 
created by {helpb label:label save} or a Stata dataset 
created by {helpb uselabel}


{title:Description}

{pstd}
{cmd:elabel load} defines value labels from a file containing 
value label names and integer-to-text mappings.

{pstd}
If no file extension is specified, {cmd:.dta} is assumed. If 
file extension is not {cmd:.dta} or {cmd:.do}, {it:filename} 
is tried as a Stata dataset; if it is not a Stata dataset, 
{it:filename} is treated as a do-file.


{title:Options}

{phang}
{opt a:dd} is the same as with {help label##options:label define}, 
and adds integer to text mappings to a value label.

{phang}
{opt modify} is the same as with {help label##options:label define}, 
and modifies existing value labels.

{phang}
{opt replace} is the same as with {help label##options:label define}, 
and redefines value labels.

{phang}
{cmd:lname(}{it:{help varname:strvar}}{cmd:)} specifies the variable 
name in {it:filename} that holds the value label names. 

{phang}
{cmd:value(}{it:{help varname:numvar}}{cmd:)} specifies the variable 
name in {it:filename} that holds the values of value labels. 

{phang}
{cmd:label(}{it:{help varname:strvar}}{cmd:)} specifies the variable 
name in {it:filename} that holds the labels, i.e., text of value labels. 


{title:Examples}

{pstd}
Load example data

{phang2}{stata sysuse nlsw88:. sysuse nlsw88}{p_end}

{pstd}
Replace data in memory with value label information

{phang2}{stata uselabel marlbl occlbl:. uselabel marlbl occlbl}{p_end}
{phang2}{stata list , sepby(lname):. list , sepby(lname)}{p_end}

{pstd}
Save label information in file

{phang2}{stata save mylabels:. save mylabels}{p_end}

{pstd}
Clear memory and define {cmd:occlbl} from the previously saved file

{phang2}{stata clear:. clear}{p_end}
{phang2}{stata label list:. label list}{p_end}
{phang2}{stata elabel load occlbl using mylabels:. elabel load occlbl using mylabels}{p_end}
{phang2}{stata label list:. label list}{p_end}

{pstd}
Erase file {cmd:mylabels.dta} from disk permanently

{phang2}{stata erase mylabels.dta:. erase mylabels.dta}{p_end}


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
if installed: {help elabel}, {help labmask}
{p_end}
