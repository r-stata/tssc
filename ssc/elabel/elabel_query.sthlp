{smcl}
{cmd:help elabel query}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel query} {hline 2} Information about {cmd:elabel}


{title:Syntax}

{p 8 12 2}
{cmd:elabel {ul:q}uery}
[ {cmd:,} {it:options} ]


{title:Description}

{pstd}
{cmd:elabel query} displays, and returns in {cmd:s()}, information about 
{cmd:elabel}. The command shows {cmd:elabel}'s internal version and the 
version of Stata/Mata under which {cmd:elabel}'s source code was last 
compiled.

{pstd}
Type {cmd:mata : elabel_about()} to obtain information on the 
pre-compiled {cmd:lelabel.mlib} library.


{title:Options}

{phang}
{opt datetime} additionally displays, and returns in {cmd:s()}, the date 
and time when {cmd:elabel}'s source code was last compiled.


{title:Saved results}

{pstd}
{cmd:elabel query} saves the following in {cmd:s()}:

{pstd}
Macros{p_end}
{synoptset 18 tabbed}{...}
{synopt:{cmd:s(elabel_version)}}{cmd:elabel}'s internal version
{p_end}
{synopt:{cmd:s(stata_version)}}Stata/Mata version under which 
{cmd:elabel}'s source code was last compiled
{p_end}
{synopt:{cmd:s(datetime)}}date and time when {cmd:elabel}'s source 
code was last compiled
{p_end}


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb mata_mlib:[M-3] mata mlib}{p_end}

{psee}
if installed: {help elabel}
{p_end}
