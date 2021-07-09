{smcl}
{* *! version 1.0.0  17feb2019}{...}
{vieweralsosee "ssc describe charlist" "net describe http://fmwww.bc.edu/repec/bocode/c/charlist"}{...}
{vieweralsosee "ssc describe listsome" "net describe http://fmwww.bc.edu/repec/bocode/l/listsome"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] hexdump" "help hexdump"}{...}
{vieweralsosee "[D] unicode" "help unicode"}{...}
{vieweralsosee "help chartabb" "help chartabb"}{...}
{vieweralsosee "help ustrto()" "help ustrto()"}{...}
{vieweralsosee "help ustrfix()" "help ustrfix()"}{...}
{viewerjumpto "Syntax" "chartab##syntax"}{...}
{viewerjumpto "Description" "chartab##description"}{...}
{viewerjumpto "Options" "chartab##options"}{...}
{viewerjumpto "Examples" "chartab##examples"}{...}
{viewerjumpto "Stored results" "chartab##stored_results"}{...}
{viewerjumpto "References" "chartab##references"}{...}
{viewerjumpto "Unicode license" "chartab##license"}{...}
{viewerjumpto "Author" "chartab##author"}{...}

{title:Title}

{phang}
{cmd:chartab} {hline 2} Table of Unicode character frequency counts


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:chartab} [{varlist}] {ifin} [{cmd:,} {it:options}]

{synoptset 25}{...}
{synopthdr}
{synoptline}
{synopt :{opth f:iles(filename:filenames)}}list of file names (or URLs) to process{p_end}
{synopt :{opth sc:alars(scalar:string_scalars)}}list of string scalars to process{p_end}
{synopt :{opth l:iterals(strings:string_literals)}}list of string literals to process{p_end}
{synopt :{opt noa:scii}}do not tally or report frequency counts for ASCII characters {p_end}
{synopt :{opt r:eplace}}replace the data in memory with tabulation results{p_end}
{synopt :{opt st:ore}}create {help stored results} for each Unicode character observed{p_end}
{synopt :{opth u:cd(filename:UCDfilename)}}specify a custom UCD (Unicode Character Database){p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
The {cmd:chartab} command 
(requires Stata version 14 or higher)
produces a table of Unicode character frequency counts.
The companion {help chartabb} command 
(requires Stata version 10 or higher)
produces a table of byte code frequency counts.

{pstd}
{cmd:chartab} can process any combination of 
string variables, 
files, 
string scalars, and
string {help strings:literals} in a single run.
The table produced reports the Unicode character frequency counts
from all sources combined.

{pstd}
Before Stata version 14, 
a character is encoded using a single byte.
This allows for 256 distinct values. 
The first 128 byte codes (values 0 to 127) are ASCII codes.
There is no standard for the remaining byte codes (values 128 to 255).

{pstd}
Starting with Stata version 14, 
Stata operates as if all characters are encoded in UTF-8.
This is a storage-efficient Unicode encoding where ASCII characters
are encoded using a single byte
(using the same ASCII byte code).
All other Unicode characters are encoded using a 
multi-byte sequence (from two to four bytes, 
each with a value greater than 127).
So by design, UTF-8 is backwards compatible with ASCII.

{pstd}
{cmd:chartab} produces a table that includes,
for each Unicode character found in the source, 
the decimal value of the code point (which can be used
with Stata's {help uchar()} function), 
its hexadecimal string representation in UTF-8
(which can be used with the {help ustrunescape()} function),
the glyph (the visual representation of the character),
the frequency count, 
and finally the Unicode unique name of the character.
The table is by default printed in the {hi:Results} window
but you can instead replace the data in memory with the results
if you specify the {opt r:eplace} option.

{pstd}
{cmd:chartab} processes ASCII and multi-byte UTF-8 sequences separately.
If you are not interested in frequency counts for ASCII characters, 
you can specify the {opt noa:scii} option and {cmd:chartab} may run
a bit faster.

{pstd}
If you feed {cmd:chartab} text that is not encoded in UTF-8,
each invalid UTF-8 byte sequence will be replaced 
by a Unicode Replacement Character ({hi:uchar(65533)} or {hi:\ufffd} in hex).
See {help ustrfix()}.
Stata has {help unicode_advice:Unicode utilities} to translate text to UTF-8.


{marker options}{...}
{title:Options}

{dlgtab:Options}

{phang}{opth f:iles(filename:filenames)} specifies a list of files to process.
You can also specify URLs instead of a {it:filenames}. 

{phang}{opth sc:alars(scalar:string_scalars)} specifies a list of string
scalar names to process.

{phang}{opth l:iterals(strings:string_literals)} specifies a list of string
{help strings:literals} to process.

{phang}{opt noa:scii} if you do not want to tabulate ASCII characters.

{phang}{opt r:eplace} to replace the data in memory with the tabulation results
(and skip printing the table in the {bf:Results} window).

{phang}{opt st:ore} to store the frequency count for each Unicode code point observed
in the source.

{phang}{opth u:cd(filename:UCDfilename)} to supply a custom UCD.
A sizable portion of the Unicode space is reserved for private-use characters.
This option can be used to associate unique names for 
these private-use characters.


{marker examples}{...}
{title:Examples}

{pstd}
String data encoded in ASCII can be used with Unicode Stata without translation
because single-byte UTF-8 encodings match ASCII codes:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - auto1}{...}
	version 14

	sysuse auto, clear
	chartab make
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata chartab_run auto1 using chartab.sthlp:click to run})}

{pstd}
You can use {cmd:chartab} with string scalars and string literals:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - various}{...}
	version 14

	scalar s = "Citroën C–Elysée II"
	chartab , scalar(s)

	chartab , literal("Citroën C–Elysée II")
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata chartab_run various using chartab.sthlp:click to run})}

{pstd}
{cmd:chartab} can also process files.
Use the {opt noa:scii} option if you are only interested in multi-byte 
UTF-8 characters:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - file}{...}
	version 14

	sysuse auto, clear
	replace make = "Citroën C–Elysée II" in 64

	tempfile f
	export delimited make using "`f'"

	clear
	chartab, file("`f'") noascii
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata chartab_run file using chartab.sthlp:click to run})}

{pstd}
You can also process a URL as if it were a local file.
In the following example, {cmd:chartab} will process this
{browse "https://www.w3.org/2001/06/utf-8-test/UTF-8-demo.html":UTF-8 sample web page}.
There are a lot of Unicode characters so we use the {opt r:eplace} option.
With the results in memory, we use Stata's {cmd:ustrto()} function to convert
each Unicode character to ASCII. 
This can be useful to remove accents from letters but notice the last observation
listed.
You can browse the results to see that most of the Unicode
characters have no suitable equivalent in ASCII.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - url}{...}
	version 14

	// the original UTF-8 plain-text file is encapsulated in HTML
	type "https://www.w3.org/2001/06/utf-8-test/UTF-8-demo.html"

	chartab, file("https://www.w3.org/2001/06/utf-8-test/UTF-8-demo.html") replace

	// convert each character to ASCII
	gen c = ustrto(ustrnormalize(cp_char, "nfd"), "ascii", 2)
	list if cp_dec > 127 & c != ""
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata chartab_run url using chartab.sthlp:click to run})}


{marker stored_results}{...}
{title:Stored results}

{pstd}
{cmd:chartab} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(fc)}}number of Unicode characters{p_end}
{synopt:{cmd:r(distinct)}}number of distinct Unicode characters{p_end}
{synopt:{cmd:r(fc_ascii)}}number of ASCII characters{p_end}
{synopt:{cmd:r(dis_ascii)}}number of distinct ASCII characters{p_end}
{synopt:{cmd:r(fc_mb_utf8)}}number of multi-byte Unicode characters{p_end}
{synopt:{cmd:r(dis_mb_utf8)}}number of distinct multi-byte Unicode characters{p_end}
{synopt:{cmd:r(urc)}}number of Unicode Replacement Character{p_end}
{synopt:{cmd:r(has_urc)}}0 if the Unicode Replacement Character is not observed, 1 otherwise{p_end}
{synopt:{cmd:r(ucdsize)}}number of code points in the repertoire of the supplied UCD (Unicode Character Database){p_end}
{p2colreset}{...}

{pstd}
The Unicode code space spans 17 contiguous planes, each with 16-bit code points
(17 * 2^16 == 1,114,112 code points).
Some code points cannot be encoded in UTF-8.
When the {opt st:ore} option is specified, {cmd:chartab} also stores in {cmd:r()} 
the frequency count for all UTF-8 characters observed in the source:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(c0)}}number of {cmd:uchar(0)}{p_end}
{synopt:{cmd:r(c1)}}number of {cmd:uchar(1)}{p_end}
{synopt:{cmd:r(c2)}}number of {cmd:uchar(2)}{p_end}
{synopt:{cmd:...}}{cmd:...}{p_end}
{synopt:{cmd:r(c1114111)}}number of {cmd:uchar(1114111)}{p_end}
{p2colreset}{...}

{synoptset 20 tabbed}{...}
{p2col 5 20 22 2: macros}{p_end}
{synopt:{cmd:r(ascii_printable)}}{it:list of printable ASCII code points observed}{p_end}
{synopt:{cmd:r(ascii_control)}}{it:list of ASCII control code points observed}{p_end}
{synopt:{cmd:r(multibyte)}}{it:list of multi-byte UTF-8 code points observed}{p_end}
{p2colreset}{...}
{pstd}


{marker references}{...}
{title:References}

{pstd}
The Unicode Consortium.  
{browse "http://www.unicode.org/versions/Unicode11.0.0/":The Unicode Standard, Version 11.0.0},
(Mountain View, CA: The Unicode Consortium, 2018. ISBN 978-1-936213-19-1).

{pstd}
Unicode Standard Annex #42: {browse "http://www.unicode.org/reports/tr42/":Unicode Character Database in XML}.

{pstd}
Unicode Standard Annex #44: {browse "http://www.unicode.org/reports/tr44/":Unicode Character Database}.

{pstd}
Flat version of the UCD: 
{browse "https://www.unicode.org/Public/UCD/latest/ucdxml/ucd.all.flat.zip"}

{pstd}
SIL International, NRSI: Computers & Writing Systems, 
{browse "https://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa":Mapping codepoints to Unicode encoding forms}. 
        
{pstd}
Wikipedia, 
{browse "https://en.wikipedia.org/wiki/UTF-8":UTF-8}.


{marker license}{...}
{title:License to redistribute the UCD}

{pstd}
The {cmd:chartab} package includes a subset of the UCD (Unicode Character Database).
Pursuant to the {browse "https://www.unicode.org/license.html":Unicode, Inc. License Agreement},
the copyright and permission notice appears at the end of 
the {cmd:chartab} ado-file.


{marker author}{...}
{title:Author}

{pstd}Robert Picard{p_end}
{pstd}robertpicard@gmail.com{p_end}
