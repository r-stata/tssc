{smcl}
{* *! version March 3, 2014 @ 13:37:11}{...}
{* link to other help files which could be of use}{...}
{viewerjumpto "Syntax" "parsefilename##syntax"}{...}
{viewerjumpto "Description" "parsefilename##description"}{...}
{viewerjumpto "Options" "parsefilename##options"}{...}
{viewerjumpto "Remarks" "parsefilename##remarks"}{...}
{viewerjumpto "Examples" "parsefilename##examples"}{...}
{viewerjumpto "Stored Results" "parsefilename##stored_results"}{...}
{viewerjumpto "Author" "parsefilename##author"}{...}
{* {viewerjumpto "References" "smcl2do##references"}}{...}
{...}
{vieweralsosee "[M-5] pathjoin()" "help mf_pathjoin"}{...}
{...}
{title:Title}

{phang}
{cmd:parsefilename} {hline 2} title of command
{p_end}

{marker syntax}{...}
{title:Syntax}

{* put the syntax in what follows. Don't forget to use [ ] around optional items}{...}
{p 8 17 2}
   {cmd: parsefilename}
   {help using} {it:filename}
   [{cmd:,}
   {it:options}
   ]
{p_end}

{* the new Stata help format of putting detail before generality}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt defext}}default file extension{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:parsefilename} takes a given filename and default extension and returns the extension and the filename without an extension.
{p_end}


{marker options}{...}
{title:Options}

{phang}{opt defext} is used to declare the default extension without leading {cmd:.} (period/full stop/dot). So, for example a {cmd:do} extension would be specified via {cmd:defext(do)}.
{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:parsefilename} is a programmers' command which is useful for allowing {help using} options with default extensions. It is very simple.
{p_end}


{marker examples}{...}
{title:Example(s)}{* Be sure to change Example(s) to either Example or Examples}

{phang}{cmd:. parsefilename using `using', defext(smcl)}{break}
takes the filename in the local {help macro} {cmd:using} and splits it into the base filename with any specified path and without extension, and the extension with the leading dot.
{p_end}
{phang2}
If {cmd:`using'} were {cmd:bling}, then {cmd:parsefilename} would return
{p_end}
{phang3}{cmd:s(sbase) : bling}{p_end}
{phang3}{cmd:s(sext) : .smcl}{p_end}
{phang2}
If {cmd:`using'} were {cmd:bling.blang}, then {cmd:parsefilename} would return
{p_end}
{phang3}{cmd:s(sbase) : bling}{p_end}
{phang3}{cmd:s(sext) : .blang}{p_end}
{phang2}
If {cmd:`using'} were {cmd:/Users/fred/bling}, then {cmd:parsefilename} would return
{p_end}
{phang3}{cmd:s(sbase) : /Users/fred/bling}{p_end}
{phang3}{cmd:s(sext) : .smcl}{p_end}

{marker stored_results}{...}
{title:Stored results}

{pstd}{* replace r() with e() for an estimation command}
{cmd:parsefilename} stores the following in {cmd:s()}:
{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:s(sbase)}}The base file name without any extension and including any specified path{p_end}
{synopt:{cmd:s(sext)}}The proper file extension including the leading dot/period/full stop ({cmd:.}){p_end}


{marker author}{...}
{title:Author}

{pstd}
Bill Rising, StataCorp{break}
email: brising@stata.com{break}
web: {browse "http://louabill.org":http://louabill.org}
{p_end}
