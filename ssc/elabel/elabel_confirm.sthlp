{smcl}
{cmd:help elabel confirm}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel confirm} {hline 2} Argument verification


{title:Syntax}

{p 8 12 2}
{cmd:elabel {ul:conf}irm} 
[ {it:#} [ {cmd:uniq} ] ]
[ {cmd:new} | {cmd:used} ]
{cmd:{ul:lbl}name}
{it:lblname} [ {it:lblname ...} ]
[ {cmd:,} {opt ex:act} ]


{title:Description}

{pstd}
{cmd:elabel confirm} verifies that the specified argumets are of the 
claimed type and exits with error if they are not; see {helpb confirm}.

{pstd}
{cmd:elabel confirm lblname} verifies that {it:lblname} exists, i.e., 
is defined and stored in memory. Option {opt exact} is usually not 
needed. If value label name abbreviations are supported, {it:lblname} 
may be abbreviated. If option {opt exact} is specified, {it:lblname} 
may not be abbreviated.

{pstd}
{cmd:elabel confirm new lblname} verifies that {it:lblname} does not exist, 
i.e., is not defined and stored in memory. For more than one {it:lblname}, 
{cmd:elabel confirm new lblname} verifies that {it:lblnames} are unique. Note 
that {it:lblname} is treated as new even if it is an unambiguous abbreviation 
of an existing value label.

{pstd}
{cmd:elabel confirm used lblname} verifies that {it:lblname} is used by 
(attached to) at least one variable in the dataset. {it:lblname} need 
not be defined and stored in memory. Note that {it:lblname} is treated 
as new even if it is an unambiguous abbreviation of an existing value 
label.

{pstd}
{cmd:elabel confirm {it:#}} [ {cmd:uniq} ] [ {cmd:used} ] {cmd:lblname} 
verifies that exactly {it:#} (unique [used]) {it:lblnames} are specified. 


{title:Examples}

{pstd}
Load example dataset

{phang2}
{stata sysuse nlsw88:. sysuse nlsw88}
{p_end}

{pstd}
Confirm {cmd:occlbl} is an existing value label (which it is)

{phang2}
{stata elabel confirm lblname occlbl:. elabel confirm lblname occlbl}
{p_end}

{pstd}
Confirm that {cmd:occ} is a new label (which it is)

{phang2}
{stata elabel confirm new lblname occ:. elabel confirm new lblname occ}
{p_end}

{pstd}
Confirm that {cmd:occlbl} is a new label (which it is not)

{phang2}
{stata elabel confirm new lblname occlbl:. elabel confirm new lblname occlbl}
{p_end}


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help label}, {help label language}{p_end}

{psee}
if installed: {help elabel}
{p_end}
