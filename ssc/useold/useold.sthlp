{smcl}
{* *! version 1.2 11 July 2016}{...}
{vieweralsosee "nepsmgmt" "help NEPSmgmt"}{...}
{vieweralsosee "use" "help use"}{...}
{vieweralsosee "encodings" "help encodings"}{...}
{vieweralsosee "unicode" "help unicode"}{...}
{vieweralsosee "unicode translate" "help unicode_translate"}{...}
{vieweralsosee "unicode analyze" "help unicode_translate"}{...}
{vieweralsosee "unicode encoding" "help unicode_encoding"}{...}
{viewerjumpto "Syntax" "useold##syntax"}{...}
{viewerjumpto "Description" "useold##description"}{...}
{viewerjumpto "Options" "useold##options"}{...}
{viewerjumpto "Remarks" "useold##remarks"}{...}
{viewerjumpto "Examples" "useold##examples"}{...}
{viewerjumpto "Author" "useold##author"}{...}
{viewerjumpto "Saved results" "useold##results"}{...}
{viewerjumpto "Also see" "useold##alsosee"}{...}
help for {cmd:useold}{right:version 1.2 (11 July 2016)}
{hline}


{title:Title}

{phang}
{bf:useold} {hline 2}
A convenient wrapper for {cmd:unicode translate}
when used under Stata 14 or younger
{p_end}


{title:Table of contents}

	{help useold##syntax:Syntax}
	{help useold##description:Description}
	{help useold##options:Options}
	{help useold##remarks:Remarks}
	{help useold##examples:Examples}
	{help useold##author:Author}
	{help useold##results:Saved results}
	{help useold##alsosee:Also see}


{marker syntax}
{title:Syntax}

{phang}
Load Stata-format dataset

{p 8 12 2}
{cmd:useold}
{it:{help filename}}
[{cmd:,}
{opt clear}
{opt nol:abel}
{opt enc:oding(enc)}
{opt v:erbose}]


{phang}
Load subset of Stata-format dataset

{p 8 12 2}
{cmd:useold}
[{varlist}]
{ifin}
{cmd:using}
{it:{help filename}}
[{cmd:,}
{opt clear}
{opt nol:abel}
{opt enc:oding(enc)}
{opt v:erbose}]


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Default options of {cmd:use}}
{synopt:{opt clear}}specifies that it is okay to replace the data in memory,
even though the current data have not been saved to disk{p_end}
{synopt:{opt nol:abel}}prevents value labels in the saved data from being loaded
{p_end}

{syntab:Advanced options of {cmd:useold}}
{synopt:{opt enc:oding(enc)}}use {it:enc} as source encoding for file
translation, if conversion is necessary{p_end}
{synopt:{opt v:erbose}}give verbose output{p_end}
{synoptline}
{p2colreset}{...}


{marker description}
{title:Description}

{pstd}
{cmd:useold} acts as a wrapper for Stata 14's unicode translation commands
{cmd:unicode translate} and {cmd:unicode analyze},
when used in Stata 14, converting the file to use into unicode.
Thereby,
it is designed to be a seamless replacement to Stata's regular {cmd:use}.
This means that {cmd:useold} is to be used in the same way as {cmd:use} itself,
and behaves exactly like {cmd:use} in Stata versions older than 14.{p_end}

{pstd}
In most cases,
the results of using {cmd:useold} would be identical to those of {cmd:use}.
This is especially true if you use {cmd:useold} on Stata versions prior to 14,
where it simply passes all arguments on to {cmd:use}.
In Stata 14 or newer, however,
{cmd:useold} performs a data check on the file to be used prior to opening it.
After copying the file to a temporary file,
it is first checked with {cmd:unicode analyze}
in order to determine if a unicode conversion process is needed for the file.
If not, again, all arguments are passed on to Stata's {cmd:use}.
Else, the file is converted to unicode using Stata 14's {cmd:unicode translate},
and the resulting file is opened.
In any case, the original data set file remains untouched.{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Default}

{phang}
{opt clear} is an option of Stata's regular {cmd:use}.
When the final data set is openend, this argument is passed on to {cmd:use}.
{p_end}

{phang}
{opt nolabel} is an option of Stata's regular {cmd:use}.
When the final data set is openend, this argument is passed on to {cmd:use}.
{p_end}

{dlgtab:Advanced}

{phang}
{opt encoding(enc)} if specified,
{it:enc} will be used as the source encoding for the input file,
if unicode translation is performed.
See {help encodings} on a detailed description;
all encodings listed there or by {stata unicode encoding list}
are valid arguments to be used as {it:enc}.
If the option {opt encoding(enc)} is not used,
the default code page of the current operating system is assumed:
{it:windows-1252} on Windows machines,
{it:macroman} on Mac OS machines,
and {it:ISO-8859-1} on Unix and Linux machines.{break}
Note that you can also define a global macro
{it:{c S|}{c -(}USEOLD_encoding{c )-}} containing {it:enc}
as the desired input encoding to use, overriding this option.{p_end}

{phang}
{opt verbose} gives verbose output during the process.
Possibly needed for debugging conversion problems.
{p_end}


{marker remarks}
{title:Remarks}

{pstd}
{cmd:useold}, by performing file conversion,
oversimplifies the problem of unicode translation:{break}
It assumes a default input encoding, depending on the current operating system,
of the source file (unless a different encoding is specified by you, the user,
using the option {opt encoding(enc)} or the global macro
{bf:{c S|}{c -(}USEOLD_encoding{c )-}}).
This is due to the fact that the true encoding of a given input file can not be
validly detected by Stata (or probably any other program).
Only {it:assuming} a proper input encoding can produce strange results if the
assumed encoding is different from the real encoding of the file;
please refer to Stata 14's help on {help unicode},
{help encodings} and {help unicode_encoding:unicode encoding}
for details on this topic.
{p_end}

{pstd}
{error}{bf:Warning:}{text} Note that in case that the target file had to be
translated to unicode prior to using it,
it is the temporary copy of the file that is actually opened.
This results in an unavoidable issue:
Stata's internal macro {it:c(filename)}
now points to the name of the temporary file,
not the originally file name.
Eventually, it is not valid to use Stata's internal {it:c(filename)}
or a simple {cmd:save , replace} (without explicitly specifying a file name)
after this.{break}
If this is the case, {cmd:useold} will issue a warning message to let you know.
In any case, it leaves a macro {it:r(filename)}
that can be used as a replacement to {it:c(filename)}.
{p_end}

{pstd}
The source code of the program is licensed under the
GNU General Public License version 3 or later.
The corresponding license text can be found on the internet at
{browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}


{marker examples}
{title:Examples}

{phang}All examples in Stata's {help use##examples:help for use} apply,
with "{cmd:use}" replaced by "{cmd:useold}".{break}
If, by now, you do not understand the meaning of the two additional options
{opt encoding(enc)} and {opt verbose}, you either will never need them or
{cmd:useold} is not meant for you.{p_end}


{marker results}
{title:Saved results}

{pstd}
{cmd:useold} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(filename)}}the file name of the target file that has been opened
{p_end}
{p2colreset}{...}


{marker author}
{title:Author}

{pstd}
Daniel Bela ({browse "mailto:daniel.bela@lifbi.de":daniel.bela@lifbi.de}),
Leibniz Institute for Educational Trajectories (LIfBi), Germany.
{p_end}


{marker alsosee}
{title:Also see}

{psee}
{help NEPSmgmt} (if installed), {help use}, {help encodings}, {help unicode},
{help unicode_translate:unicode translate},
{help unicode_translate:unicode analyze},
{help unicode_encoding:unicode encoding}
{p_end}
