{smcl}
{cmd:help elabel recode}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel recode} {hline 2} Recode value labels


{title:Syntax}

{p 8 12 2}
{cmd:elabel recode}
{it:{help elabel##elblnamelist:elblnamelist}}
{cmd:(}{it:{help elabel_recode##rule:rule}}{cmd:)}
[ {cmd:(}{it:{help elabel_recode##rule:rule}}{cmd:)} {it:...} ]
[ {help elabel##iffeexp:{bf:iff} {it:eexp}} ]
[ {cmd:,} {it:options} ]


{marker rule}{...}
{p 4 10 2}
where {it:rule} is 
{{it:#}|{it:{help elabel_recode##nlist:numlist}}} 
{cmd:=}
{{it:#}|{it:{help elabel_recode##nlist:numlist}}}
[ {cmd:"}{it:label}{cmd:"} [ {cmd:"}{it:label}{cmd:"} {it:...} ]]


{title:Description}

{pstd}
{cmd:elabel recode} recodes values in value labels. Values that are not 
specified in {it:rules} are left unchanged. 

{pstd}
If {it:numlist} on the right-hand side of a {it:rule} contains more 
than one value, it must contain as many values as the {it:numlist} on 
the left-hand side; the mapping of values is one-to-one. Likewise, if 
more than one {it:label} is specified, the number of {it:labels} must 
match the number of values in the {it:numlist} on the right-hand 
side. If no {it:label} is specified, the {it:label} that is associated 
with the (last specified) respective value on the left-hand side is 
used. 

{marker nlist}{...}
{pstd}
{it:{help numlist}} is interpreted in the usual way and, additionally, may 
contain sequences of missing value codes such as {cmd:.a/.c}. Noninteger 
values are not allowed in {it:numlist}. If {it:numlist} or {it:label} 
contain spaces, {it:label} must be enclosed in quotes.


{title:Options}

{phang}
{opt de:fine(newlblnamelist)} specifies names for the value labels that 
will contain the recoded values. {it:newlblnamelist} may contain 
{help elabel##varvaluelabel:{it:varname}{bf::}{it:lblname}}.

{p 8 10 2}
If neither {opt prefix()} (see below) 
nor {opt define()} is specified, existing value labels are modified. 

{phang}
{opt pre:fix(str)} is an alternative to {opt define()}; the option 
prefixes old value label names with {it:str} and stores the recoded 
values under those new value label names.

{p 8 10 2}
If neither {opt define()} (see above) 
nor {opt prefix()} is specified, existing value labels are modified.  

{phang}
{opt sep:arator(char)} in rules, in which no {it:label} is specified, 
combines labels of the values on the left-hand side, using {it:char} 
as the separator. 

{phang}
{opt copy:rest} copies values (and associated text) that are excluded 
by {help elabel##iffeexp:{bf:iff} {it:eexp}} from old value labels.

{phang}
{opt var:list} additionally returns, in {cmd:r(varlist)}, 
the variable names that have one of the recoded value labels 
attached (in any {help label language:label language}). 

{pstd}
{opt d:ryrun} does not recode values but lists implied new value labels 
below old value labels.


{title:Examples}

{pstd}
Define value label {cmd:agreelbl}

{phang2}{stata elabel define agreelbl 1 "agree" 2 "neutral" 3 "disagree":. elabel define agreelbl 1 "agree" 2 "neutral" 3 "disagree"}{p_end}

{pstd}
Change the direction of values in {cmd:agreelbl} from 1, 2, 3 to 3, 2, 1
and store the result in value label {cmd:disagreelbl}

{phang2}{stata elabel recode agreelbl (1/3 = 3/1) , define(disagreelbl):. elabel recode agreelbl (1/3 = 3/1) , define(disagreelbl)}{p_end}

{pstd}
Change value 2 in both value labels to .a, assigning the label "neither nor"; do 
not perform changes but list old and implied new value labels

{phang2}{stata elabel recode agreelbl disagreelbl (2 = .a "neither nor") , dryrun:. elabel recode agreelbl disagreelbl (2 = .a "neither nor") , dryrun}{p_end}


{title:Saved results}

{pstd}
{cmd:elabel recode} saves the following in {cmd:r()}:

{pstd}
Macros{p_end}
{synoptset 12 tabbed}{...}
{synopt:{cmd:r(rules)}}transformation rules with all labels removed
{p_end}
{synoptset 12 tabbed}{...}
{synopt:{cmd:r(varlist)}}variables that have one of the recoded 
labels attached
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
if installed: {help elabel}
{p_end}
