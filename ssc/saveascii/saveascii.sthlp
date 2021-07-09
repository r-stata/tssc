{smcl}
{* *! version 1.3 15 March 2017}{...}
{vieweralsosee "nepsmgmt" "help NEPSmgmt"}{...}
{vieweralsosee "saveold" "help saveold"}{...}
{vieweralsosee "encodings" "help encodings"}{...}
{vieweralsosee "unicode" "help unicode"}{...}
{vieweralsosee "unicode translate" "help unicode_translate"}{...}
{vieweralsosee "unicode analyze" "help unicode_translate"}{...}
{vieweralsosee "unicode encoding" "help unicode_encoding"}{...}
{viewerjumpto "Syntax" "saveascii##syntax"}{...}
{viewerjumpto "Description" "saveascii##description"}{...}
{viewerjumpto "Options" "saveascii##options"}{...}
{viewerjumpto "Remarks" "saveascii##remarks"}{...}
{viewerjumpto "Examples" "saveascii##examples"}{...}
{viewerjumpto "Author" "saveascii##author"}{...}
{viewerjumpto "Also see" "saveascii##alsosee"}{...}
help for {cmd:saveascii}{right:version 1.3 (15 March 2017)}
{hline}


{title:Title}

{phang}
{bf:saveascii} {hline 2} A convenient wrapper for {cmd:saveold} , incorporating
translation of unicode characters to extended ASCII encodings


{title:Table of contents}

	{help saveascii##syntax:Syntax}
	{help saveascii##description:Description}
	{help saveascii##options:Options}
	{help saveascii##remarks:Remarks}
	{help saveascii##examples:Examples}
	{help saveascii##author:Author}
	{help saveascii##alsosee:Also see}


{marker syntax}
{title:Syntax}

{phang}
Save data in memory to file in Stata 13, 12, or 11 format, converting all
characters from unicode to extended ASCII

{p 8 16 2}
{cmd:saveascii}
{it:{help filename}}
[{cmd:,}
{opt v:ersion(#)} {opt nol:abel} {opt replace} {opt all} {opt nod:ata} {opt enc:oding(enc)} {opt nop:reserve} {opt v:erbose}]


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Default options of {cmd:saveold}}{...}
{synopt :{opt v:ersion(#)}}specify version 11<={it:#}<=13;
default is {cmd:version(13)}, meaning Stata 13 format{p_end}
{synopt :{opt nol:abel}}omit value labels from the saved dataset{p_end}
{synopt :{opt replace}}overwrite existing dataset{p_end}
{synopt :{opt all}}save {cmd:e(sample)} with the dataset; programmer's option
{p_end}

{syntab:Advanced options of {cmd:saveascii}}
{synopt:{opt nod:ata}}only convert meta data, leave data set content as it is
{p_end}
{synopt:{opt enc:oding(enc)}}use {it:enc}
as target encoding for file translation{p_end}
{synopt:{opt nop:reserve}}do not preserve the active (unconverted) dataset in memory{p_end}
{synopt:{opt v:erbose}}give verbose output{p_end}
{synoptline}
{p2colreset}{...}


{marker description}
{title:Description}

{pstd}
{cmd:saveascii} acts as a wrapper for Stata's {cmd:saveold} command.
In contrast to this Stata command,
it converts all string contents of the data set
(i.e. variable names, data and variable labels, value label names and contents,
characteristics' names and contents) from unicode to extended ASCII,
when the target format is older than Stata 14.
Thereby, it is designed to be a seamless replacement to Stata's regular
{cmd:saveold}. This means that {cmd:saveascii} is to be used in the same way as
{cmd:saveold} itself, and behaves exactly like {cmd:saveold}
in Stata versions older than 14.
{p_end}

{pstd}
In most cases, the results of using {cmd:saveascii}
would be identical to those of {cmd:saveold}.
This is especially true if you use {cmd:saveascii}
on Stata versions prior to 14, where it simply passes all arguments on to
{cmd:saveold}.
In Stata 14 or newer, however, {cmd:saveascii}
performs some conversion steps before calling {it:saveold}.
All string contents of the data set that contain unicode characters are
converted to extended ASCII, and the resulting data is saved using
{cmd:saveold}.
{p_end}

{pstd}
The idea for this progam came from a
{browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/1290766":thread on Statalist},
where Svend Juul and Alan Riley discussed the topic.
Most of Alan Rileys proposed solutions from this thread have been incorporated
into {cmd:saveascii},
and all credits regarding these parts belong to him (and / or StataCorp).
{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Default}

{phang}
{opt version(#)} is an option of Stata's regular {cmd:saveold}.
It specifies which previous {cmd:.dta} file format is to be
used.  {it:#} may be {cmd:13}, {cmd:12}, or {cmd:11}.  The default is
{cmd:version(13)}, meaning Stata 13 format.  To save datasets in the modern,
Stata 14 format, use the {cmd:save} command, not {cmd:saveold}.

{phang}
{opt nolabel} is an option of Stata's regular {cmd:saveold}.
It omits value labels from the saved dataset.
The associations between variables and value-label names, however,
are saved along with the dataset label and the variable labels.

{phang}
{opt replace} is an option of Stata's regular {cmd:saveold}.
It permits {opt saveold} to overwrite an existing dataset.

{phang}
{opt all}  is an option of Stata's regular {cmd:saveold}.
It is for use by programmers.  If specified, {cmd:e(sample)} will
be saved with the dataset.  You could run a regression; {cmd:save mydata, all};
{cmd:drop _all}; {cmd:use mydata}; and {cmd:predict yhat if e(sample)}.

{dlgtab:Advanced}

{phang}
{opt nodata} if specified,
contents of the data set will not be altered before it is saved;
only meta data will be converted.
This means that variable name and string variable content conversion is skipped.
It may at least lead to export problems with long string variables,
if the target version is below Stata 13, and {cmd:saveold} can not continue.
You have been warned.
{p_end}

{phang}
{opt encoding(enc)} if specified,
{it:enc} will be used as the target encoding for the file saved
when unicode translation is performed.
See {help encodings} on a detailed description;
all encodings listed there or by {stata unicode encoding list}
are valid arguments to be used as {it:enc}.
If the option {opt encoding(enc)} is not used,
the default code page of the current operating system is assumed:
{it:windows-1252} on Windows machines,
{it:macroman} on Mac OS machines,
and {it:ISO-8859-1} on Unix and Linux machines.{break}
Note that you can also define a global macro
{it:{c S|}{c -(}SAVEASCII_encoding{c )-}} containing {it:enc}
as the desired target encoding to use, overriding this option.
{p_end}

{phang}
{opt nopreserve} overrides {help preserve:preserving} the active dataset in memory;
after finishing conversion, the converted dataset will stay in memory
(and possibly be barely readable for the human eye);
this can speed up conversion for larger datasets.
{p_end}

{phang}
{opt verbose} gives verbose output during the process.
Possibly needed for debugging conversion problems.
{p_end}


{marker remarks}
{title:Remarks}

{pstd}
{cmd:saveascii}, by performing unicode conversion,
oversimplifies the problem of unicode translation:{break}
It assumes a default target encoding, depending on the current operating system,
for the file saved (unless a different encoding is specified by you, the user,
using the option {opt encoding(enc)} or the global macro
{bf:{c S|}{c -(}SAVEASCII_encoding{c )-}}).
Only {it:assuming} a proper target encoding can produce strange results if the
assumed encoding is different from the encoding used by an older version
of Stata that later on opens the file;
please refer to Stata 14's help on {help unicode},
{help encodings} and {help unicode_encoding:unicode encoding}
for details on this topic.
{p_end}

{pstd}
When the final data set is eventually saved using {cmd:saveold},
Stata may issue messages like this for each converted string:{break}
. note: variable label "�"
contains unicode and thus may not display well in Stata {it:#}.{break}
This message originates from {cmd:saveold} itself,
which can not be aware of the fact that all contents already have been
converted to the target encoding, and can be safely ignored.
{p_end}

{pstd}
The source code of the program is licensed under the
GNU General Public License version 3 or later.
The corresponding license text can be found on the internet at
{browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}


{marker examples}
{title:Examples}

{phang}All {cmd:saveold} examples in Stata's
{help save##examples:help for saveold} apply,
with "{cmd:saveold}" replaced by "{cmd:saveascii}".{break}
If, by now, you do not understand the meaning of the three additional options
{opt nodata}, {opt encoding(enc)} and {opt verbose},
you either will never need them or {cmd:saveascii} is not meant for you.{p_end}


{marker author}
{title:Author}

{pstd}
Daniel Bela ({browse "mailto:daniel.bela@lifbi.de":daniel.bela@lifbi.de}),
Leibniz Institute for Educational Trajectories (LIfBi), Germany.
{p_end}


{marker alsosee}
{title:Also see}

{psee}
{help NEPSmgmt} (if installed), {help saveold}, {help encodings}, {help unicode},
{help unicode_translate:unicode translate},
{help unicode_translate:unicode analyze},
{help unicode_encoding:unicode encoding}
{p_end}
