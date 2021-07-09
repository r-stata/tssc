{smcl}
{* *! version February 14, 2020 @ 10:30:21}{...}
{vieweralsosee "[P] putdocx" "help putdocx "}{...}
{vieweralsosee "[P] putpdf" "help putpdf "}{...}
{viewerjumpto "Syntax" "putwrap##syntax"}{...}
{viewerjumpto "Description" "putwrap##description"}{...}
{viewerjumpto "Options" "putwrap##options"}{...}
{viewerjumpto "Remarks" "putwrap##remarks"}{...}
{viewerjumpto "Examples" "putwrap##examples"}{...}
{viewerjumpto "Author" "putwrap##author"}{...}
{...}
{title:Title}

{phang}
{cmd:putwrap} {hline 2} Wrapper to simplify {help putdocx} and {help putpdf} files
{p_end}

{marker syntax}{...}
{title:Syntax}

{* put the syntax in what follows. Don't forget to use [ ] around optional items}{...}
{p 8 16 2}
   {cmd: putwrap}
   {help using} {it:filename}
   [{cmd:,}
   {it:options}
   ]
{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:putwrap} is a simple-minded wrapper for making {help putdocx} and
{help putpdf} easier to use. It allows new paragraphs to be defined
using blank lines and text to be typed as-is, negating the need for
endless {cmd:putxxx paragraph} and {cmd:putxxx text} commands. The aim
is to make a more-readable source document.  
{p_end}


{marker options}{...}
{title:Options}

{phang}{opt saving(filename)} allows overriding the default file name for the do-file saved by {cmd:putwrap}.   
{p_end}

{pmore}The default value of the generated do-file depends on the
extension of the {help using} file.
If the {help using} file is named, say {cmd:simple.wrap}, then the
resulting do-file will be named {cmd:simple.do}.
If the {help using} file is named, say {cmd:simple.do}, however, then the resulting do-file will be named {cmd:simple_conv.do}.
{p_end}

{phang}{opt replace} allows replacing the generated do-file.
{p_end}

{phang}{opt defpar(str)} allows specifying arguments for the generated {cmd:putxxx paragraph} commands.
This probably is better handled by setting the style for the document as a whole, but the option could be useful if the source document were split into pieces with different styles.
{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
Both {help putdocx} and {help putpdf} require every paragraph to start
with a {cmd:putxxx paragraph}.
They also require that simple text be embedded in {cmd:putxxx text}
commands.
This makes simple narrative text nearly impossible to read in the base
document.
{cmd:putwrap} allows narrative text to be written as simple text without these markers.
{p_end}

{pstd}
The rules are simple enough:
{p_end}

{pin}To make a new paragraph, put in at least one blank line.
{p_end}

{pin}To start Stata (non-narrative) code, type
{p_end}
{pin2}{cmd:putxxx pause}
{p_end}

{pin}To go back to narrative mode, type
{p_end}
{pin2}{cmd:putxxx resume}
{p_end}

{pin}If you would like to include comments in the narrative, start them with an {cmd:*}.
{p_end}

{pin}If you need something fancier than the default formatting in the narrative, use standard {help putpdf} or {help putdocx} commands.
{p_end}

{pstd}
This is meant to be a very simple-minded wrapper (and perhaps to get
others interested in better simple-minded wrappers). It is not a markdown
processor or anything which replaces the directives of {cmd:putxxx}
with another language. It is just a simpler way to write narrative. 
{p_end}

{pstd}
One final note: Do not use a continuation comment (///) between {cmd:putdocx} and {cmd:pause} or between {cmd:putdocx} and {cmd:resume}. It is not only silly to split such a short line, it will cause an error because of the way {cmd:putwrap} looks for these two added subcommands.
{p_end}

{marker examples}{...}
{title:Example}{* Be sure to change Example(s) to either Example or Examples}

{pstd}Here is an example to illustrate what a file would look like (it
is included in the ancillary files as {cmd:example.do}).
Note: copying and pasting the following as an example will not work
well, because the resulting leading spaces get preserved in the
narrative.
{p_end}

{pin}
{cmd:putdocx clear}
{p_end}
{pin}
{cmd:putdocx begin}
{p_end}
{pin}
{cmd:putdocx paragraph, style(Heading1)}
{p_end}
{pin}
This is the title for this document
{p_end}

{pin}
This for text inside of the document. It can go on and on. After all, most documents are mostly text. It can have new paragraphs without a bunch of extra commands. The important part is that it is halfway possible to read what is being done here.
{p_end}

{pin}
This is now a second paragraph, which is starting with two linebreaks in a row. The two line breaks are just the equivalent of a simple {cmd:putdocx paragraph}, with no options.
{p_end}

{pin}If you wanted to be fancy, and have the {cmd:putdocx} command above show up like code in the docx document, you still do standard {cmd:putdocx} work.
The blank lines are equivalent of a simple 
{p_end}
{pin}
{cmd:putdocx text ("putdocx paragraph"), font("Courier New",10)}
{p_end}
{pin}
 with no options. 
{p_end}

{pin}
Now we can put in some Stata code... which will not appear in the document.
{p_end}
{pin}
* Star-comments can be used to make things readable
{p_end}
{pin}
* The indentation of the code is not not special... it is for readability
{p_end}
{pin}
{cmd:putdocx pause}
{p_end}
{pin2}
{cmd:sysuse auto, clear}
{p_end}
{pin2}
{cmd:gen gp100m = 100/mpg}
{p_end}
{pin2}
{cmd:graph matrix gp100m weight length turn}
{p_end}
{pin2}
{cmd:graph export gphmat.png, replace}
{p_end}
{pin2}
{cmd:regress gp100m weight length turn i.foreign}
{p_end}
{pin2}
{cmd:** end of Stata code}
{p_end}
{pin}
{cmd:putdocx resume}
{p_end}
{pin}
 Now some results from our analysis. First a picture of the results
{p_end}
{pin}
{cmd:putdocx image gphmat.png, width(4)}
{break}
{p_end}

{pin}
Now the result of the regression:
{p_end}
{pin}
{cmd:putdocx table reg = etable}
{p_end}

{pin}
* tables require a new paragraph to flush the table, hence the blank line
{p_end}
{pin}
There we go... some analysis and some text in one document.
This still has some programmerish stuff in it, but it can be typed and read a bit more quickly.
{p_end}
{pin}
{cmd:putdocx save example, replace}
{p_end}

{marker stored_results}{...}
{title:Stored results}

{pstd}{* replace r() with e() for an estimation command}
None
{p_end}

{marker author}{...}
{title:Author}

{pstd}
Bill Rising, StataCorp{break}
email: brising@stata.com{break}
web: {browse "http://louabill.org":http://louabill.org}
{p_end}
