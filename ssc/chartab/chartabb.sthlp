{smcl}
{* *! version 1.0.0  14feb2019}{...}

{title:Title}

{phang}
{cmd:chartabb} {hline 2} Table of character byte code frequency counts


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:chartabb} [{varlist}] {ifin} [{cmd:,} {it:options}]

{synoptset 25}{...}
{synopthdr}
{synoptline}
{synopt :{opt f:iles(filenames)}}list of file names (or URLs) to process{p_end}
{synopt :{opth sc:alars(scalar:string_scalars)}}list of string scalars to process{p_end}
{synopt :{opt l:iterals(string_literals)}}list of string literals to process{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
The {cmd:chartabb} command 
(requires Stata version 10 or higher)
produces a table of character byte code frequency counts.
The companion {help chartab} command 
(requires Stata version 14 or higher)
produces a table of Unicode character frequency counts.

{pstd}
{cmd:chartabb} can process any combination of 
string variables, 
files, 
string scalars, and
string literals in a single run.
The table produced reports the frequency count of byte codes
from all sources combined.

{pstd}
In all Stata versions up to 13, 
a character is encoded using a single byte.
This allows for 256 distinct values. 
The first 128 byte codes (values 0 to 127) are ASCII codes.
There is no standard for the remaining byte codes (values 128 to 255).

{pstd}
You may still use {cmd:chartabb} with Stata 14 or higher. 
You will get
byte code frequencies instead of Unicode character frequencies and
the glyph for byte codes (128 to 255) will be that of the Unicode
Replacement Character as these are invalid UTF-8 sequences.

{pstd}
{cmd:chartabb} produces a table that includes,
for each unique byte code found in the source, 
the decimal value of the byte code (which can be used
with Stata's {help char()} function), 
its hexadecimal string representation,
the glyph (the visual representation of the character),
and the frequency count.


{marker options}{...}
{title:Options}

{dlgtab:Options}

{phang}{opt f:iles(filenames)} specifies a list of files to process.
You can also specify a URL instead of a {it:filename}. 

{phang}{opth sc:alars(scalar:string_scalars)} specifies a list of string
scalar names to process.

{phang}{opt l:iterals(string_literals)} specifies a list of string
literals to process.


{marker examples}{...}
{title:Examples}

{pstd}
You can get byte code frequencies for one or more string variables, and you can
even use the standard {ifin} qualifiers:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - auto}{...}
	version 10

	sysuse auto, clear
	gen upmake = upper(make)
	list make upmake if strpos(make,"Toyota")
	chartabb make upmake if strpos(make,"Toyota")
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata chartab_run auto using chartabb.sthlp:click to run})}

{pstd}
{cmd:chartabb} can also process text from string scalars and string literals:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - more}{...}
	version 10

	chartabb, literal("123123")

	scalar s = char(9) + "abc" + char(200) + char(126) + char(127) + char(128)
	chartabb, scalar(s)
	ret list
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata chartab_run more using chartabb.sthlp:click to run})}

{pstd}
{cmd:chartabb} can also process bytes from files. 
In the following example, we store in a temporary tab-delimited file the
full content of the {hi:auto} dataset:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - auto2}{...}
	version 10

	sysuse auto, clear

	tempfile f
	outsheet using "`f'"

	clear
	chartabb, file("`f'")
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata chartab_run auto2 using chartabb.sthlp:click to run})}


{marker stored_results}{...}
{title:Stored results}

{pstd}
{cmd:chartabb} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(Nprintable)}}number of printable ASCII characters (32-126){p_end}
{synopt:{cmd:r(Ncontrol)}}number of ASCII control characters (0-31,127){p_end}
{synopt:{cmd:r(Nextended)}}number of extended ASCII characters (128-255){p_end}
{synopt:{cmd:r(Ntotal)}}number of bytes in total (0-255){p_end}
{p2colreset}{...}

{pstd}
and for byte codes found in the source:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(c0)}}number of {cmd:char(0)}{p_end}
{synopt:{cmd:r(c1)}}number of {cmd:char(1)}{p_end}
{synopt:{cmd:r(c2)}}number of {cmd:char(2)}{p_end}
{synopt:{cmd:...}}{cmd:...}{p_end}
{synopt:{cmd:r(255)}}number of {cmd:char(255)}{p_end}
{p2colreset}{...}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: macros}{p_end}
{synopt:{cmd:r(control)}}{it:list of ASCII control codes observed}{p_end}
{synopt:{cmd:r(printable)}}{it:list of printable ASCII codes observed}{p_end}
{synopt:{cmd:r(extended)}}{it:list of extended ASCII codes observed}{p_end}
{p2colreset}{...}
{pstd}


{marker author}{...}
{title:Author}

{pstd}Robert Picard{p_end}
{pstd}robertpicard@gmail.com{p_end}


{title:Also see}

{psee}
Help:  {manhelp hexdump D}, {helpb chartab}
{p_end}

{psee}
SSC :  {stata "ssc des listsome":listsome}, {stata "ssc des charlist":charlist}
{p_end}

