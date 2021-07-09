{smcl}
{cmd:help elabel list}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel list} {hline 2} List names and contents of value labels


{title:Syntax}

{p 8 12 2}
{cmd:elabel {ul:l}ist}
[ {it:{help elabel##elblnamelist:elblnamelist}} ]
[ {helpb elabel##iffeexp:iff {it:eexp}} ]
[ {cmd:,} {it:options} ]


{title:Description}

{pstd}
{cmd:elabel list} lists, and returns in {cmd:r()}, the names, integer 
values, and associated text of value labels stored in memory. 


{title:Options}

{phang}
{opt var:list} additionally returns, in {cmd:r(varlist)}, the 
variable names that have {it:lblname} attached (in the current 
{help label language:label language}). For 
{help label language:multilingual datasets}, {cmd:r(lvarlists)} 
contains {cmd:({it:languagename} {it:varlist})} for any 
additional label language in which {it:lblname} is attached to 
at least one variable. 

{phang}
{opt nomem:ory} treats value label names attached to variables as if they 
were defined in memory. The option respects multilingual datasets 
(see {help label language}). 

{phang}
{opt cur:rent} is for use with, and implies, {opt nomemory} and restricts 
not yet defined value labels to those in the current label language. 


{title:Examples}

{pstd}
Load example dataset

{phang2}
{stata sysuse nlsw88:. sysuse nlsw88}
{p_end}

{pstd}
List names and contents of all value labels

{phang2}
{stata elabel list:. elabel list}
{p_end}

{pstd}
List name and contents of value label {cmd:occlbl}

{phang2}
{stata elabel list occlbl:. elabel list occlbl}
{p_end}

{pstd}
List name and contents of the value label attached to {cmd:collgrad}

{phang2}
{stata elabel list (collgrad):. elabel list (collgrad)}
{p_end}


{title:Saved results}

{pstd}
{cmd:elabel list} saves the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 16 tabbed}{...}
{synopt:{cmd:r(min)}}minimum nonmissing value
{p_end}
{synopt:{cmd:r(max)}}maximum nonmissing value
{p_end}
{synopt:{cmd:r(hasmiss)}}whether extended missing 
values are labeled
{p_end}
{synopt:{cmd:r(nemiss)}}number of extended missing 
values
{p_end}
{synopt:{cmd:r(k)}}number of mapped values
{p_end}

{pstd}
Macros{p_end}
{synoptset 16 tabbed}{...}
{synopt:{cmd:r(name)}}value label name
{p_end}
{synopt:{cmd:r(values)}}integer values
{p_end}
{synopt:{cmd:r(labels)}}text associated with integer values
{p_end}


{pstd}
With the {opt varlist} option, {cmd:elabel list} additionally 
saves the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 16 tabbed}{...}
{synopt:{cmd:r(k_languages)}}number of label 
languages, excluding current language
{p_end}

{pstd}
Macros{p_end}
{synoptset 16 tabbed}{...}
{synopt:{cmd:r(varlist)}}variables that have {it:lblname} attached 
in current language
{p_end}
{synopt:{cmd:r(lvarlists)}}variables that have {it:lblname} 
attached in additional languages
{p_end}
{synopt:{cmd:r(language)}}current label language
{p_end}
{synopt:{cmd:r(languages)}}list of label languages, excluding 
current language
{p_end}


{pstd}
With the {opt nomemory} or {opt current} option, {cmd:elabel list} 
additionally saves the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 16 tabbed}{...}
{synopt:{cmd:r(exists)}}whether value label exists 
(i.e., is defined in memory)
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
