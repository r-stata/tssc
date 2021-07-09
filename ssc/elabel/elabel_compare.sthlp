{smcl}
{cmd:help elabel compare}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel compare} {hline 2} Compare value labels


{title:Syntax}

{p 8 12 2}
{cmd:elabel compare}
{it:{help elabel##elblnamelist:lblname1}}
{it:{help elabel##elblnamelist:lblname2}}
[ {helpb elabel##iffeexp:iff {it:eexp}} ]
[ {cmd:,} {opt assertidentical} ]


{title:Description}

{pstd}
{cmd:elabel compare} compares two sets of value labels. 


{title:Options}

{phang}
{opt assertidentical} verifies that {it:lblname1} and {it:lblname2} 
define the same integer-to-text mappings and exits with the respective 
error message if they do not. If {opt assertidentical} is specified, only 
{cmd:r(name}{it:#}{cmd:)} and {cmd:r(identical)} are returned in {cmd:r()}.


{title:Examples}

{pstd}
Load example data

{phang2}{stata sysuse nlsw88:. sysuse nlsw88}{p_end}
{phang2}{stata describe:. describe}{p_end}

{pstd}
Modify two value labels and compare them

{phang2}{stata elabel define marlbl gradlbl .a "N/A" , add:. elabel define marlbl gradlbl .a "N/A" , add}{p_end}
{phang2}{stata elabel compare marlbl gradlbl:. elabel compare marlbl gradlbl}{p_end}

{pstd}
Copy a value label and verify the result

{phang2}{stata elabel copy marlbl marlbl2:. elabel copy marlbl marlbl2}{p_end}
{phang2}{stata elabel compare marlbl marlbl2:. elabel compare marlbl marlbl2}{p_end}


{title:Saved results}

{pstd}
{cmd:elabel compare} saves the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 16 tabbed}{...}
{synopt:{cmd:r(min}{it:#}{cmd:)}}minimum nonmissing value 
in {it:lblname#}
{p_end}
{synopt:{cmd:r(max}{it:#}{cmd:)}}maximum nonmissing value
in {it:lblname#}
{p_end}
{synopt:{cmd:r(nemiss}{it:#}{cmd:)}}number of extended 
missing values in {it:lblname#}
{p_end}
{synopt:{cmd:r(k}{it:#}{cmd:)}}number of mapped values
in {it:lblname#}
{p_end}
{synopt:{cmd:r(k)}}number of mapped values
common to both {it:lblname1} and {it:lblname2}
{p_end}
{synopt:{cmd:r(identical)}}whether value labels are 
identical
{p_end}

{pstd}
Macros{p_end}
{synoptset 16 tabbed}{...}
{synopt:{cmd:r(name}{it:#}{cmd:)}}{it:lblname#}
{p_end}
{synopt:{cmd:r(values}{it:#}{cmd:)}}integer values
in {it:lblname#}
{p_end}
{synopt:{cmd:r(labels}{it:#}{cmd:)}}text associated 
with integer values in {it:lblname#}
{p_end}
{synopt:{cmd:r(values)}}integer values
common to both {it:lblname1} and {it:lblname2}
{p_end}
{synopt:{cmd:r(labels)}}text associated with integer 
values common to both {it:lblname1} and {it:lblname2}
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
if installed: {help elabel}, {help labeldup}
{p_end}
