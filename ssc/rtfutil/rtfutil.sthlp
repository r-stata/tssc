{smcl}
{hline}
help for {cmd:rtfutil}{right:(Roger Newson)}
{hline}


{title:Utilities for writing Rich Text Format (RTF) files}

{pstd}
Open a new RTF file

{p 8 21 2}
{cmd:rtfopen} {it:handle} {cmd:using} {it:filename} [ , {cmd:replace} {cmdab:te:mplate}{cmd:(}{it:template_name}{cmd:)}
{cmdab:pa:per}{cmd:(}{it:paper_size}{cmd:)} {cmdab:la:ndscape}
{cmdab:ma:rgins}{cmd:(}{it:#1 #2 #3 #4}{cmd:)}
]

{pstd}
where {it:template_name} is

{pstd}
{cmd:minimal} | {cmd:fnmono1} | {cmd:fnmono2}

{pstd}
and {it:paper_size} is

{pstd}
{cmd:us} | {cmd:usland} | {cmd:a4} | {cmd:a4land} | {it:#1 #2}

{pstd}
Open an existing RTF file for appending RTF code

{p 8 21 2}
{cmd:rtfappend} {it:handle} {cmd:using} {it:filename} [ , {cmd:replace} {opt fr:om(filename)} ]

{pstd}
Insert some RTF code from an instream line sequence and/or an existing file into an open RTF file

{p 8 21 2}
{cmd:rtfinsert} {it:handle} [ {cmd:using} {it:filename} ]
[ , {cmdab:te:rminator}{cmd:(}{it:string}{cmd:)} {cmdab:max:lines}{cmd:(}{it:#}{cmd:)} ]

{pstd}
Start a new section in an open RTF file

{p 8 21 2}
{cmd:rtfsect} {it:handle} [ , {cmdab:de:fault}
{cmdab:pa:per}{cmd:(}{it:paper_size}{cmd:)} {cmdab:la:ndscape}
{cmdab:ma:rgins}{cmd:(}{it:#1 #2 #3 #4}{cmd:)}
]

{pstd}
Insert a graphic file as a linked object into an open RTF file

{p 8 21 2}
{cmd:rtflink} {it:handle} {cmd:using} {it:filename}

{pstd}
Insert a hyperlink into an open RTF file

{p 8 21 2}
{cmd:rtfhyper} {it:handle} , {cmdab:h:yperlink}{cmd:(}{it:URL}{cmd:)} [ {cmdab:t:ext}{cmd:(}{it:string}{cmd:)} ]

{pstd}
Compute cumulative sums for a number list

{p 8 21 2}
{cmd:rtfcumlist} {help numlist:{it:numlist}} [ , {cmdab:lo:cal}{cmd:(}{help macro:{it:local_macro_name}}{cmd:)} ]

{pstd}
Create a {helpb listtab} row style for specified cell widths

{p 8 21 2}
{cmd:rtfrstyle} [ {varlist} ] [ , {cmdab:cw:idths}{cmd:(}{help numlist:{it:numlist}}{cmd:)} 
{cmd:trgaph(}{it:#}{cmd:)} {cmd:trleft(}{it:#}{cmd:)}
{cmdab:tdp:osition}{cmd:(}{it:tabdef_position}{cmd:)}
{cmdab:tda:dd}{cmd:(}{it:string}{cmd:)} {cmdab:cda:dd}{cmd:(}{it:string_list}{cmd:)}
{cmdab:m:issnum}{cmd:(}{it:string}{cmd:)}
{cmdab:lo:cal}{cmd:(}{help macro:{it:local_macro_name_list}}{cmd:)}
]

{pstd}
where {it:tabdef_position} is

{pstd}
{cmd:b} | {cmd:e} | {cmd:be} | {cmd:eb}

{pstd}
Close an open RTF file

{p 8 21 2}
{cmd:rtfclose} {it:handle}

{pstd}
where {it:handle} is a {help file:file handle} as recognized by the {helpb file} utility.


{title:Description}

{pstd}
The {cmd:rtfutil} package is a suite of file handling utilities
for producing Rich Text Format (RTF) files in Stata,
possibly containing plots and tables.
These RTF files can then be opened by Microsoft Word,
and possibly by alternative free word processors.
The plots can be included by inserting, as linked objects,
graphics files that might be produced by the {helpb graph_export:graph export} command in Stata.
The tables can be included by using the {helpb listtab} command,
downloadable from {help ssc:SSC},
with the {cmd:handle()} option.


{title:Options for {cmd:rtfopen}}

{phang}
{cmd:replace} specifies that any existing file with the name specified by the {it:filename}
will be replaced.

{phang}
{cmd:template(}{it:template_name}{cmd:)} specifies the name of an RTF template,
on which the output RTF file will be based.
A template is a sequence of RTF commands,
which specifies a file with an RTF format but no content,
which will be created if the user uses {cmd:rtfclose} immediately after using {cmd:rtfopen}.
The user may add content by using other commands between {cmd:rtfopen} and {cmd:rtfclose}.
Currently, 3 templates are available.
{cmd:minimal} (the default) specifies that the template begins with the line {cmd:{c -(}\rtf1}
and ends with the line {cmd:{c )-}},
with no font table, no header, and no formatting commands
(apart from any specified by the {cmd:paper()} and {cmd:margins()} options).
{cmd:fnmono1} specifies that the template contains a small font table,
no color table, stylesheet, or info group,
a small set of formatting commands,
and a header group,
displaying only the name of the file specified by {helpb using}
together with the current page number.
{cmd:fnmono2} specifies the same template as {cmd:fnmono1},
except that the header group displays the file name, the current page number,
and the total number of pages in the document.
The option {cmd:template(fnmono2)} may produce RTF documents
that cannot be read correctly by RTF readers other than Microsoft Word.

{phang}
{cmd:paper(}{it:paper_size}{cmd:)} specifies the dimensions (width and height) of the paper
for the output RTF document.
These dimensions may be given as two numbers {it:#1 #2},
where {it:#1} is width (in twips) and {it:#2} is height (in twips),
or they may be given as a named paper size {cmd:us}, {cmd:usland}, {cmd:a4}, or {cmd:a4land},
where {cmd:us} specifies the standard US paper size of width 12240 twips and height 15840 twips,
{cmd:usland} specifies the standard landscaped US paper size of width 15840 twips and height 12240 twips,
{cmd:a4} specifies the standard A4 paper size of width 11909 twips and height 16834 twips,
and {cmd:a4land} specifies the standard landscaped A4 paper size of width 16834 twips and height 11909 twips.
The implied default dimensions in RTF are {cmd:papersize(12240 15840)}, or US paper size.
A twip is 1/1440 of an inch, or 1/20 of a point,
and is the standard unit of length most commonly used in RTF documents.

{phang}
{cmd:landscape} specifies that the orientation of the document, when printed,
will be landscape.
If {cmd:landscape} is not specified, then the orientation will be portrait.
Note that the {cmd:landscape} option is independent of the {cmd:paper()} option.
Therefore, if the user specifies {cmd:paper(usland)} or {cmd:paper(a4land)},
then the user must also specify {cmd:landscape}
for the document to have a landscape orientation when printed.

{phang}
{cmd:margins(}{it:#1 #2 #3 #4}{cmd:)} specifies the left, right, top and bottom margins (in twips)
for the output RTF document.
The implied default in RTF is {cmd:margins(1800 1800 1440 1440)}.


{title:Options for {cmd:rtfappend}}

{phang}
{cmd:replace} specifies that any existing file with the name specified by the {cmd:using} {it:filename}
will be replaced.

{phang}
{cmd:from(}{it:filename}{cmd:)} specifies an input file,
to which additional RTF input will be appended to produce the output file specified by the {cmd:using} {it:filename}.
If {cmd:from()} is unspecified, then {cmd:rtfappend} inputs the file specified by {cmd:using},
assuming that that file already exists,
and overwrites it, if {cmd:replace} is specified.


{title:Options for {cmd:rtfinsert}}

{phang}
{cmd:terminator(}{it:string}{cmd:)} specifies a terminator string,
used to terminate an instream sequence of lines of RTF code following the {cmd:rtfinsert} command.
If {cmd:terminator()} is present,
then {cmd:rtfinsert} will insert into the open RTF document the following lines,
until a line containing only the {cmd:terminator()} string is encountered,
or until the number of lines is equal to the {cmd:maxlines()} option (see below).
If both a {cmd:terminator()} option and a {cmd:using} qualifier are present,
then {cmd:rtfinsert} will first insert the instream sequence of RTF lines,
and then insert the lines of text from the {cmd:using} file.
Note that the {cmd:using} file may not be an existing RTF document,
but may only contain lines of RTF code as text,
without any head lines.
Note, also, that the instream lines will be left- and right-trimmed
before being output to the open RTF file.
This implies that lines continuing a paragraph need to be prefixed with the string {cmd:"\  "},
a backslash followed by 2 spaces.

{phang}
{cmd:maxlines(}{it:#}{cmd:)} specifies a maximum number of lines of RTF code
to read from the instream sequence of lines of RTF code.
If {cmd:maxlines()} is absent,
then it is set to a default value of 1024.


{title:Options for {cmd:rtfsect}}

{phang}
{cmd:default} specifies that all section settings will be restored to the document default,
usually as set by {cmd:rtfopen}.

{phang}
{cmd:paper()}, {cmd:landscape} and {cmd:margins()} are defined as the options of the same names for {cmd:rtfopen}.
However, they apply only to the section, not to the whole document.
This is useful if the user wants to have landscape pages in a mainly portrait document.


{title:Options for {cmd:rtfhyper}}

{phang}
{cmd:hyperlink(}{it:URL}{cmd:)} specifies the uniform resource location (URL) for the hyperlink.
This option must be specified.

{phang}
{cmd:text(}{it:string}{cmd:)} specifies the text used in the hypertext for the hyperlink.
If {cmd:text()} is not specified, then the {cmd:hyperlink()} option is used.
Note that it is the user's responsibility to add underlining, colors,
or any other formatting used to indicate hypertext.


{title:Options for {cmd:rtfcumlist}}

{phang}
{cmd:local(}{help macro:{it:local_macro_name}}{cmd:)} specifies the name of a {help macro:local macro},
in which the result will be saved.
{cmd:rtfcumlist} inputs a {help numlist:{it:numlist}},
and computes, as output, a second number list,
containing the cumulative sums of the input {help numlist:{it:numlist}}.
This is useful if the input {help numlist:{it:numlist}} contains a sequence of table row widths (in twips),
and the user wants the cumulative sums for use in {cmd:cellx}{it:N} control words,
defining the corresponding table row right boundaries (in twips).


{title:Options for {cmd:rtfrstyle}}

{phang}
{cmd:cwidths(}{help numlist:{it:numlist}}{cmd:)} specifies a list of column widths, expressed in twips,
to be used in the generated {helpb listtab} row style.
A {helpb listtab} row style is a combination of the {helpb listtab} options
{cmd:begin()}, {cmd:delimiter()}, {cmd:end()} and {cmd:missnum()}.
The column widths must be positive integers.
If a {varlist} is specified, then the list of column widths is truncated,
or extended on the right with copies of the last column width in the list,
to make the number of column widths equal to the number of variables in the {varlist}.
If {cmd:cwidths()} is not specified,
then it is initialized to a single width of 1440 twips (equal to one inch),
and then extended with copies if a {varlist} is specified.
The final list of column widths is used to construct the RTF table row definition,
which will be output as part of the {helpb listtab} row style.

{phang}
{cmd:trgaph(}{it:#}{cmd:)} specifies half the space between the cells of a table row (expressed in twips).
If absent, then it is set to 40 twips, or 2 points.

{phang}
{cmd:trleft(}{it:#}{cmd:)} specifies the position in twips of the leftmost edge of the table,
with respect to the left edge of its left column.
If absent, then it is set to {it:-trgaph}, where {it:trgaph} is the number set by {cmd:trgaph()}.

{phang}
{cmd:tdposition(}{it:tabdef_position}{cmd:)} specifies whether the RTF table definition
will be part of the {cmd:begin()} option or the {cmd:end()} option
of the {helpb listtab} row style generated.
It may be set to {cmd:b}, {cmd:e}, {cmd:be} or {cmd:eb}.
If it is set to {cmd:b}, then it will be part of the {cmd:begin()} option.
If it is set to {cmd:e}, then it will be part of the {cmd:end()} option.
If it is set to {cmd:be} or {cmd:eb}, then it will be part of both options.
In RTF documents,
the table definition is sometimes part of the beginning of the row definition (before the cells),
and is sometimes part of the end of the row definition (after the cells),
and is sometimes repeated in both places.

{phang}
{cmd:tdadd(}{it:string}{cmd:)} specifies additional RTF commands to be added to the table row definition,
in order to customize the table rows defined by the row style.
For instance, {cmd:tdadd("\trqr")} specifies that the generated table rows will be right-justified
in their page (or in their containing column).

{phang}
{cmd:cdadd(}{it:string_list}{cmd:)} specifies a list of sequences of additional RTF commands,
to be added to the table cell definitions,
in order to customize the table cells generated by the generated {helpb listtab} row style.
The list of strings will be truncated,
or extended on the right with copies of the last string in the list,
to make the number of additional strings equal to the final number of columns.
(The final number of columns is defined as the final number of column widths specified by {cmd:cwidths()},
after any necessary truncation or extension to match the length of the {varlist}.)
If {cmd:cdadd()} is not specified,
then it is initialized to a single empty string ({cmd:""}),
and then extended with copies if there will be more than one column in the table.
The final list of additional strings is used to construct the RTF table cell definitions,
which will be output as part of the {helpb listtab} row style.

{phang}
{cmd:missnum(}{it:string}{cmd:)} specifies the {cmd:missnum()} option
of the generated {helpb listtab} row style.
If not specified, then it is set to an empty string ({cmd:""}).

{phang}
{cmd:local(}{help macro:{it:local_macro_name_list}}{cmd:)} specifies a list of up to 4 names
of local macros,
which, if supplied,
will be set to the {cmd:begin()}, {cmd:delimiter()}, {cmd:end()} and {cmd:missnum()} options,
respectively,
of the row style generated by {cmd:rtfrstyle}.
These macro names can then be used when calling {helpb listtab}.
They can be useful,
because the strings beginning, delimiting and ending RTF table rows are often long and difficult to remember.


{title:Remarks about {cmd:rtfopen} and {cmd:rtfclose}}

{pstd}
The {cmd:rtfopen} command produces minimal Rich Text Format (RTF) documents,
with no character set declaration, default font declaration,
font tables, color tables, stylesheets, info groups,
preliminary formatting commands, headers, footers, or other extra information,
unless the user adds them,
either using the {cmd:template()} option of {cmd:rtfopen}
or using the {helpb file:file write} command.
{cmd:rtfopen} opens a file and initializes the output with a line

{pstd}
{cmd:{c -(}\rtf1}

{pstd}
and possibly other lines of RTF code specified by the {cmd:template()} option.
The {cmd:rtfappend} command opens an existing RTF file for appending additional RTF code
to the end of the file,
just before the terminal {cmd:{c )-}} character used to terminate a well-formed RTF document.
The {cmd:rtfclose} command simply outputs, to a file already open for text output, the line

{pstd}
{cmd:{c )-}}

{pstd}
and then closes the open file.
This ensures that, if the user outputs legible code with no unmatched brackets {cmd:{c -(}} and {cmd:{c )-}},
then the RTF document as a whole will be legible and have no unmatched brackets.

{pstd}
It is a good idea to enclose all code between a {cmd:rtfopen} or {cmd:rtfappend}
command and the corresponding {cmd:rtfclose} command
in a {helpb capture:capture noisily} block,
beginning with the command

{pstd}
{cmd:capture noisily {c -(}}

{pstd}
and ending with the command

{pstd}
{cmd:{c )-}}

{pstd}
This ensures that, if any command in the {helpb capture:capture noisily} block fails,
then Stata will transfer control to the {cmd:rtfclose} command
immediately following the {helpb capture:capture noisily} block,
and the RTF file specified by {cmd:rtfopen} or {cmd:rtfappend} will be closed,
and will be available for inspection by the user,
using Microsoft Word or other RTF file readers.


{title:Remarks about {cmd:rtflink}}

{pstd}
The {helpb using} filename may be a path containing folder names.
However, if there are folder names, then they should be separated by the forward slash
{cmd:/}
and not by the backward slash {cmd:\}
even under Microsoft Windows.

{pstd}
Note that {cmd:rtflink} inserts a graphics file into a RTF document as a linked object,
and not as an embedded object,
using nonstandard RTF code used by Microsoft Word versions in Word 2000 or above.
This implies that the linked object may not be recognized by non-Microsoft word processors
(or obsolete Microsoft word processors)
that use RTF.
It also implies that, if the RTF document is moved to another folder (or another computer),
then the graphics file may no longer be visible,
unless it is moved as well.
And some versions of Microsoft Word do not necessarily display or print
linked {cmd:.eps} files produced by the Stata {helpb graph export} command
at the correct size,
as specified by the {helpb region_options:ysize()} and {helpb region_options:xsize()} options
of a Stata graphics command.
The user may have to convert these linked objects to embedded objects,
in order for them to be displayed at the sizes intended by the Stata graphics command.

{pstd}
Users who wish to include graphics files as embedded objects should probably open the RTF document
(using a post-2000 version of Microsoft Word),
and embed the graphics into the document by clicking on the Microsoft Word hypertext

{pstd}
{cmd:Edit Links to Files}

{pstd}
and checking the check box marked {cmd:Save file in document}.
After the user has done this,
it may be a good idea to revisit {cmd:Edit links to files},
and to check the check box marked {cmd:Break Link}.

{pstd}
This need for manual intervention to produce embedded files
is an annoying and labor-intensive feature of using {cmd:rtflink}.
Also, it has been known for RTF documents with embedded graphics
to have compatability problems when users try to convert them to {browse "http://www.openoffice.org/":OpenOffice}.
However, it probably requires less work than most other available methods,
if the user wanted to produce a RTF document (with tables and graphics) in a hurry,
for colleagues to read using Microsoft Word.
It may be a good idea to convert the generated RTF document to a standard Microsoft Word {cmd:.docx} file,
in order to save space,
before embedding the linked objects.


{title:Miscellaneous remarks about {cmd:rtfutil}}

{pstd}
Note that the {cmd:rtfhyper} command, and the {cmd:template(fnmono2)} option of {cmd:rtfopen},
also use nonstandard RTF additions.
These also may not work in non-Microsoft word processors,
although they appear to work in Microsoft Word.

{pstd}
In general, RTF is designed as a Rich {it:TEXT} Format,
which implements text (and probably tables) to be portable between systems.
Users who introduce graphics, hypertext, and headers or footers containing the total number of pages
into RTF documents for input to Microsoft Word
should probably not expect to be able to port them to other packages.

{pstd}
More information on the use of {cmd:rtfutil} with {helpb listtab} and other {help ssc:SSC} packages
can be found in {help rtfutil##references:Newson (2012)}.
More information on Rich Text Format can be found in {help rtfutil##references:Burke (2003)}.


{title:Technical note about {cmd:rtfrstyle}}

{pstd}
{cmd:rtfrstyle} inputs a variable list and/or a list of column widths,
and outputs a {helpb listtab} row style,
which can be saved in the local macros specified by the {cmd:local()} option,
and has 4 components,
which are values for the {helpb listtab} options {cmd:begin()}, {cmd:delimiter()}, {cmd:end()} and {cmd:misnum()}.
The {cmd:missnum()} option is as specified by the user, defaulting to an empty string ({cmd:""}).
The {cmd:delimiter()} option is the string {cmd:"\cell\pard\intbl "},
which terminates one RTF table cell and initiates another.
The {cmd:begin()} option is {cmd:"{c -(}\trowd\pard\intbl "} if the user specifies {cmd:tdposition(e)},
and otherwise has the syntax {cmd:"{c -(}}{it:<tabdef>}{cmd:\pard\intbl "},
where {it:<tabdef>} is a RTF table definition.
The {cmd:end()} option is {cmd:"\cell\row{c )-}"} if the user specifies {cmd:tdposition(b)}
(either explicitly or by default),
and otherwise has the syntax {cmd:"\cell}{it:<tabdef>}{cmd:\row{c )-}"}.

{pstd}
The RTF table definition {it:<tabdef>} has the syntax

{pstd}
{cmd:"\trowd\trgaph}{it:<trgaph_option>}{cmd:\trleft}{it:<trleft_option><tdadd_option><celldefs>}{cmd:"}

{pstd}
where {it:<trgaph_option>} is the {cmd:trgaph()} option, {it:<trleft_option>} is the {cmd:trleft()} option,
{it:tdadd_option>} is the {cmd:tdadd()} option,
and {it:<celldefs>} is a list of RTF cell definitions (with no intervening commas or spaces),
one for each column of the RTF table to be output by {helpb listtab}.
The {it:k}th cell definition of the {it:<celldefs>} has the syntax

{pstd}
{cmd:"}{it:<cdadd_item>}{cmd:\cellx}{it:<crbound_item>}{cmd:"}

{pstd}
where {it:<crbound_item>} is the {it:k}th cell right boundary
in the final list of cell right boundaries implied by the {cmd:cwidths()} option,
and {it:<cdadd_item>} is the {it:k}th item in the final list of items
implied by the {cmd:cdadd()} option.
Note that {cmd:rtfrstyle} creates a {helpb listtab} row style to create RTF table rows
each enclosed within a RTF group,
beginning with {cmd:{c -(}} and ending with {cmd:{c )-}}.
This prevents paragraph formatting specifications within table rows
from having effects on the formatting of RTF code in the same document after the table.

{pstd}
This syntax allows the user to specify a very wide range of RTF table row styles for input to {helpb listtab}.
The {varlist} used with {cmd:rtfrstyle} should be the same {varlist} later used with {helpb listtab},
as this will ensure that the number of {it:<celldefs>} is the same as the number of columns in the table,
which is the number of variables in the {varlist}.
Microsoft Word usually fails uninformatively if a RTF document contains a table row
with a number of cell definitions unequal to the number of cells.


{title:Examples}

{pstd}
The following example generates a document {cmd:mydoc1.rtf},
which includes, as a linked object, a file {cmd:myplot1.eps},
produced by {helpb graph_export:graph export}.
The {helpb file} command {cmd:file write} is used to add a heading before the plot,
and two paragraphs after the plot,
each containing a hyperlink added using {cmd:rtfhyper}.

{p 8 12 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 12 2}{cmd:. scatter mpg weight, by(foreign) scheme(s2color)}{p_end}
{p 8 12 2}{cmd:. graph export myplot1.eps, replace}{p_end}
{p 8 12 2}{cmd:. tempname handle1}{p_end}
{p 8 12 2}{cmd:. rtfopen `handle1' using "mydoc1.rtf", template(fnmono1) replace}{p_end}
{p 8 12 2}{cmd:. capture noisily {c -(}}{p_end}
{p 8 12 2}{cmd:. file write `handle1' "{c -(}\pard\b Plots of mileage against weight by car origin\par{c )-}" _n}{p_end}
{p 8 12 2}{cmd:. rtflink `handle1' using "myplot1.eps"}{p_end}
{p 8 12 2}{cmd:. file write `handle1' _n "{c -(}\line{c )-}" _n "{c -(}\pard A package for linking plots like these into RTF documents can be downloaded from Roger Newson's website at {c -(}\ul "}{p_end}
{p 8 12 2}{cmd:. rtfhyper `handle1', hyper("http://www.imperial.ac.uk/nhli/r.newson/")}{p_end}
{p 8 12 2}{cmd:. file write `handle1' "{c )-}\par{c )-}"}{p_end}
{p 8 12 2}{cmd:. file write `handle1' "\line" _n "{c -(}\pard Find out more about Stata at "}{p_end}
{p 8 12 2}{cmd:. rtfhyper `handle1', hyper("http://www.stata.com/") text("{c -(}\ul The Stata website{c )-}")}{p_end}
{p 8 12 2}{cmd:. file write `handle1' ".\par{c )-}" _n "\line" _n}{p_end}
{p 8 12 2}{cmd:. {c )-}}{p_end}
{p 8 12 2}{cmd:. rtfclose `handle1'}{p_end}

{pstd}
The following example generates a document {cmd:mydoc2.rtf},
which contains a RTF table of the mileages and weights of the 22 non-American cars in the {cmd:auto} data.
This table is generated using the {helpb listtab} package,
using a RTF row style generated by {cmd:rtfrstyle}.
The numeric variables {cmd:mpg} and {cmd:weight} are converted to string variables before output,
using the {helpb sdecode} package,
adding RTF prefixes causing them to be right-justified in the output RTF table.
The string variable {cmd:make} is not prefixed or suffixed,
implying that (by default) it will be left-justified in the output RTF table.
Note the use of the {cmd:local()} option of {cmd:rtfrstyle},
which generates local macros {cmd:b}, {cmd:d} and {cmd:e},
containing the {cmd:begin()}, {cmd:delimiter()} and {cmd:end()} options,
respectively,
that are then passed to {helpb listtab}.
The {helpb listtab} and {helpb sdecode} packages can be downloaded from {help ssc:SSC}.

{p 8 12 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 12 2}{cmd:. keep if foreign==1}{p_end}
{p 8 12 2}{cmd:. sdecode mpg, replace prefix("\qr{c -(}") suffix("{c )-}")}{p_end}
{p 8 12 2}{cmd:. sdecode weight, replace prefix("\qr{c -(}") suffix("{c )-}")}{p_end}
{p 8 12 2}{cmd:. tempname handle2}{p_end}
{p 8 12 2}{cmd:. rtfopen `handle2' using "mydoc2.rtf", template(fnmono1) replace}{p_end}
{p 8 12 2}{cmd:. capture noisily {c -(}}{p_end}
{p 8 12 2}{cmd:. file write `handle2' "{c -(}\pard\b Mileage and weight in non-US cars\par{c )-}" _n}{p_end}
{p 8 12 2}{cmd:. rtfrstyle make mpg weight, cwidths(2160 1440 1440) local(b d e)}{p_end}
{p 8 12 2}{cmd:. listtab make mpg weight, handle(`handle2') begin("`b'") delim("`d'") end("`e'") head("`b'\ql{c -(}\i Make{c )-}`d'\qr{c -(}\i Mileage (mpg){c )-}`d'\qr{c -(}\i Weight (lb){c )-}`e'")}{p_end}
{p 8 12 2}{cmd:. {c )-}}{p_end}
{p 8 12 2}{cmd:. rtfclose `handle2'}{p_end}

{pstd}
The following example is like the previous example,
except that the generated document is named {cmd:mydoc3.rtf},
and the table (and its heading) are right-justified on their page,
and the cells of the top row of the table (containing the column titles) have upper and lower treble-line borders.
The right-justification is specified by the option {cmd:tdadd("\trqr")}.
The upper and lower borders are specified by the {cmd:cdadd()} option of the first {cmd:rtfrstyle} command,
which generates an alternative {cmd:begin()} option, stored in the macro {cmd:B}.

{p 8 12 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 12 2}{cmd:. keep if foreign==1}{p_end}
{p 8 12 2}{cmd:. sdecode mpg, replace prefix("\qr{c -(}") suffix("{c )-}")}{p_end}
{p 8 12 2}{cmd:. sdecode weight, replace prefix("\qr{c -(}") suffix("{c )-}")}{p_end}
{p 8 12 2}{cmd:. tempname handle3}{p_end}
{p 8 12 2}{cmd:. rtfopen `handle3' using "mydoc3.rtf", template(fnmono1) replace}{p_end}
{p 8 12 2}{cmd:. capture noisily {c -(}}{p_end}
{p 8 12 2}{cmd:. file write `handle3' "{c -(}\pard\qr{c -(}\b Mileage and weight in non-US cars{c )-}\par{c )-}" _n}{p_end}
{p 8 12 2}{cmd:. rtfrstyle make mpg weight, tdadd("\trqr") cdadd("\clbrdrt\brdrw20\brdrtriple\clbrdrb\brdrw20\brdrtriple") cwidths(2160 1440 1440) local(B)}{p_end}
{p 8 12 2}{cmd:. rtfrstyle make mpg weight, tdadd("\trqr") cwidths(2160 1440 1440) local(b d e)}{p_end}
{p 8 12 2}{cmd:. listtab make mpg weight, handle(`handle3') begin("`b'") delim("`d'") end("`e'") head("`B'\ql{c -(}\i Make{c )-}`d'\qr{c -(}\i Mileage (mpg){c )-}`d'\qr{c -(}\i Weight (lb){c )-}`e'")}{p_end}
{p 8 12 2}{cmd:. {c )-}}{p_end}
{p 8 12 2}{cmd:. rtfclose `handle3'}{p_end}

{pstd}
The following example demonstrates the use of {cmd:rtfappend} and {cmd:rtflink}
to add a graph to a file {cmd:mydoc12.rtf},
generated using the {helpb estpost} and {helpb esttab} modules of the SSC package {helpb estout},
written by Ben Jann.
The {helpb estout} and {cmd:rtfutil} packages are complementary,
as more users produce tables using {helpb estout} than using {helpb rtfutil} and {helpb listtab},
but {helpb estout} cannot produce graphs.

{p 8 12 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 12 2}{cmd:. estpost ta foreign}{p_end}
{p 8 12 2}{cmd:. esttab using mydoc12.rtf, replace}{p_end}
{p 8 12 2}{cmd:. tempname handle4}{p_end}
{p 8 12 2}{cmd:. rtfappend `handle4' using mydoc12.rtf, replace}{p_end}
{p 8 12 2}{cmd:. capture noisily {c -(}}{p_end}
{p 8 12 2}{cmd:. scatter mpg weight, by(foreign)}{p_end}
{p 8 12 2}{cmd:. graph export myplot3.eps, replace}{p_end}
{p 8 12 2}{cmd:. rtflink `handle4' using myplot3.eps}{p_end}
{p 8 12 2}{cmd:. file write `handle4' "\line"}{p_end}
{p 8 12 2}{cmd:. {c )-}}{p_end}
{p 8 12 2}{cmd:. rtfclose `handle4'}{p_end}

{pstd}
The following example demonstrates the use of {cmd:rtfinsert}
to insert an instream sequence of lines of RTF code,
terminated by the string {cmd:END_OF_RTF},
into an open RTF document.
Note that lines continuing a paragraph must be prefixed with the string {cmd:"\  "}
(a backslash followed by 2 spaces),
because {cmd:rtfinsert} trims instream lines
on the left and on the right.

{p 8 12 2}{cmd:. tempname handle18}{p_end}
{p 8 12 2}{cmd:. rtfopen `handle18' using  mydoc18.rtf, replace}{p_end}
{p 8 12 2}{cmd:. rtfinsert `handle18', term(END_OF_RTF)}{p_end}
{p 8 12 2}{cmd:. {c -(}\pard}{p_end}
{p 8 12 2}{cmd:. Mary had a little lamb,}{p_end}
{p 8 12 2}{cmd:. \  she also had a fox.}{p_end}
{p 8 12 2}{cmd:. \  The little lamb it gave her love,}{p_end}
{p 8 12 2}{cmd:. \  the fox it gave her {c -(}\i Echinococcus granulosus{c )-}.}{p_end}
{p 8 12 2}{cmd:. \par{c )-}}{p_end}
{p 8 12 2}{cmd:. \line}{p_end}
{p 8 12 2}{cmd:. END_OF_RTF}{p_end}
{p 8 12 2}{cmd:. rtfclose `handle18'}{p_end}

{pstd}
A more advanced example using {cmd:rtfutil} can be found in {help rtfutil##references:Newson (2012)}.


{title:Saved results}

{pstd}
{cmd:rtfcumlist} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(cumlist)}}list of cumulative sums{p_end}
{p2colreset}{...}

{pstd}
{cmd:rtfrstyle} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(trgaph)}}{cmd:trgaph()} option{p_end}
{synopt:{cmd:r(trleft)}}{cmd:trleft()} option{p_end}
{p2colreset}{...}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd: r(tdadd)}}{cmd:tdadd()} option{p_end}
{synopt:{cmd: r(cwidths)}}final list of column widths (in twips){p_end}
{synopt:{cmd: r(crbounds)}}final list of column right boundaries (in twips){p_end}
{synopt:{cmd:r(cdadd)}}final {cmd:cdadd()} option (string list){p_end}
{synopt:{cmd:r(celldefs)}}cell definitions section of table row definition{p_end}
{synopt:{cmd:r(tabdef)}}table row definition{p_end}
{synopt:{cmd: r(begin)}}{cmd:begin()} option of generated row style{p_end}
{synopt:{cmd: r(delimiter)}}{cmd:delimiter()} option of generated row style{p_end}
{synopt:{cmd: r(end)}}{cmd:end()} option of generated row style{p_end}
{synopt:{cmd: r(missnum)}}{cmd:missnum()} option of generated row style{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{marker references}{title:References}

{phang}
Burke S. M.
2003.
{it:RTF Pocket Guide}.
Sebastopol, CA: O'Reilly & Associates Inc.
Download more information from
{browse "http://search.cpan.org/~sburke/RTF-Writer/lib/RTF/Cookbook.pod":Sean Burke's RTF web page}.

{phang}
Newson, R. B.  2012.
From resultssets to resultstables in Stata.
{it:The Stata Journal} 12(2): 191-213.
Download from {browse "http://www.stata-journal.com/article.html?article=st0254":{it:The Stata Journal} website}.


{title:Also see}

{psee}
Manual:  {manlink P file}
{p_end}

{psee}
{space 2}Help:  {manhelp file P}{break}
{helpb listtab}, {helpb sdecode}, {helpb estout}, {helpb esttab}, {helpb estpost} if installed
{p_end}
