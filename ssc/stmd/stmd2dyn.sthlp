{vieweralsosee "" "--"}{...}
{smcl}
{* *! version 1.4 17jul2018}{...}
{* *! Doug Hemken}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "stmd" "help stmd"}{...}
{vieweralsosee "dyndoc" "help dyndoc"}{...}
{vieweralsosee "markdown" "help markdown"}{...}
{vieweralsosee "dynamic tags" "help dynamic tags"}{...}
{viewerjumpto "Syntax" "stmd2dyn##syntax"}{...}
{viewerjumpto "Description" "stmd2dyn##description"}{...}
{viewerjumpto "Options" "stmd2dyn##options"}{...}
{viewerjumpto "Remarks" "stmd2dyn##remarks"}{...}
{viewerjumpto "Examples" "stmd2dyn##examples"}{...}
{title:Title}

{phang}
{bf:stmd2dyn} Convert common Markdown to Stata {cmd: dyndoc} 
dynamic document format.{p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:stmd2dyn}
filename
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt sav:ing(filename2)}}save {cmd: dyndoc} file as {it:filename2}{p_end}
{synopt:{opt replace}}replace {it:filename2} if it already exists{p_end}

{syntab:Other}
{synopt :{opt hardwrap}}replace hard wraps (actual line breaks) with
the HTML tag {cmd:<br>}{p_end}
{synopt :{opt nomsg}}suppress message of a link to {it:targetfile}{p_end}
{synopt :{opt noremove}}suppress {cmd:<<dd_remove>> processing{p_end}
{synopt :{opt nostop}}do not stop when an error occurs{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:stmd2dyn} Takes a Markdown document using conventional markdown
	specification and converts it to Stata's dialect using {cmd: dyndoc}
	dynamic tags.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt saving} {it: filename2} to save the {cmd: dyndoc}, which can
	then be processed by Stata.{p_end}

{phang}
{opt replace} replace {it:filename2} if it already exists{p_end}

{dlgtab:More}

{phang}
Additional options which may be passed to {cmd:dydndoc}
are {cmd:hardwrap}, {cmd:nomsg}, {cmd:noremove}, and {cmd:nostop}{p_end}

{phang}
{opt hardwrap} specifies that hard wraps (actual line breaks) in the
Markdown document be replaced with the HTML line break tag {cmd:<br>}.

{phang}
{opt nomsg} suppresses the message that contains a link to the target file.

{phang}
{opt noremove} specifies that {cmd:<<dd_remove>>} and {cmd:<</dd_remove>>} 
tags should not be processed.

{phang}
{opt nostop} allows the document to continue being processed even if an error
occurs.


{marker remarks}{...}
{title:Remarks}

{pstd}
If {it: filename2} is not specified, then {it: filename} with an
.dyn file extension is tried.

{pstd}
For more on how to format documents, see {cmd: help stmd}.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. stmd2dyn using example.stmd}{p_end}


{title:Author}

{p 4} Doug Hemken {p_end}
{p 4} Social Science Computing Cooperative{p_end}
{p 4} Univ of Wisc-Madison{p_end}
{p 4} {browse "mailto:dehemken@wisc.edu":dehemken@wisc.edu}{p_end}
{p 4} https://www.ssc.wisc.edu/~hemken/Stataworkshops{p_end}
{p 4} https://github.com/Hemken/stmd2dyn{p_end}
