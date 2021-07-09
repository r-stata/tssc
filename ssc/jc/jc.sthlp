{smcl}
{* *! version 1.0  05jul2015}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "jc##syntax"}{...}
{viewerjumpto "Description" "jc##description"}{...}
{viewerjumpto "Remarks" "jc##remarks"}{...}
{viewerjumpto "Dependencies" "jc##dependencies"}{...}
{title:Title}

{phang}
{bf:jc} {hline 2} Post-estimation macros and scalars for {cmd:javacall}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:jc}
{it:class}
{it:method}
[{varlist}]
{ifin}
[{cmd:,} {opt args(argument_list)}]


{marker description}{...}
{title:Description}

{pstd}
{cmd:jc} is a convenience method providing extended functionality to {cmd:javacall}.
{cmd:jc} maps post-estimation scalars and macros, which aren't accessible from within Java plugins, to general use scalars and macros, which are accessible from within Java plugins, before calling {cmd:javacall}.
That is, all {cmd:e(X)} macros and scalars are accessible as {cmd:e_X}, e.g. {cmd:e(cmd)} as {cmd:e_cmd}; same for {cmd:r(X)}.
The syntax of {cmd:jc} and {cmd:javacall} is identical.

{marker remarks}{...}
{title:Remarks}

{pstd}
See {browse "https://github.com/philippbc/java-stata-dpl":github.com/philippbc/java-stata-dpl}  for more documentation and help forums.

{marker dependencies}{...}
{title:Dependencies}

{pstd}
Stata's SFI API for error logging ({browse "http://www.stata.com/java/api/index.html"})

