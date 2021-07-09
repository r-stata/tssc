{smcl}
{hline}
help for {cmd:htmltit} {right:(Roger Newson)}
{hline}


{title:Generate a document title variable for a HTML filename variable}

{p 8 15}{cmd:htmltit} {varname} {ifin} {cmd:,} {opth g:enerate(newvarname)} 


{title:Description}

{pstd}
{cmd:htmltit} inputs a string variable,
assumed to contain the file names (or paths) of existing readable HTML documents,
and outputs a new string variable,
to contain the corresponding HTML document titles,
if they can be found in the documents.
{cmd:htmltit} is designed for use by users who want to create HTML documents
containing HTML tables to index (and link to) other HTML documents.
This can be done using the {help ssc:SSC} packages {helpb htmlutil}
(to generate the HTML documents},
{helpb xdir}
(to generate datasets with 1 observation for each of a list of files which may be HTML documents),
and {helpb listtab} (to generate the HTML tables).


{title:Options}

{p 4 8 2}
{opth generate(newvarname)} specifies the name of the new string variable,
containing the document titles.
This option must be present.


{title:Remarks}

{pstd}
{cmd:htmltit} is designed for use in output datasets (or resultssets),
with one observation for each of a list of files,
created using the {helpb xdir} package,
which can be downloaded from {help ssc:SSC}.
It inputs a variable containing file names, or file paths,
some of which may belong to readable HTML documents.
It attempts to find, in each readable document,
the HTML document title,
and to store that document title (if found) in the generated output variable
specified by the {cmd:generate()} option.
It does this by searching down the document (if the document is readable),
and stopping the search if and when it finds a line of text
which (after trimming space characters from the left and the right)
begins with a HTML {cmd:<title>} tag and ends with a HTML {cmd:</title>} tag.
{cmd:htmltit} then writes this line of text
to the corresponding observation of the generated output variable,
after removing the HTML {cmd:<title>} and{cmd:</title>} tags.

{pstd}
A valid HTML document should always have a document title.
Most browsers will open a HTML document without a document title,
but they will then have an alien-looking file location in the browser tab,
instead of a user-friendly document title.
The document title is located in the head of the HTML document,
between a HTML {cmd:<title>} tag and a HTML {cmd:</title>} tag.
It is not strictly compulsory for the document title to be on a single line,
with no other HTML code,
except for space characters to the left of the HTML {cmd:<title>} tag
and space characters to the right of the HTML {cmd:</title>} tag.
However, the document title will probably have this feature in most valid HTML documents,
most of the time.
In particular,
a document title will have this feature if the document was generated
using the {help ssc:SSC} package {helpb htmlutil},
at least if the document title was inserted
using the {cmd:title()} option of the {helpb htmlopen} module.

{pstd}
The {cmd:htmltit} package was written to work with HTML documents written in {help unicode:Unicode}.
The file search procedure therefore uses the Unicode versions of
{help string_functions:Stata string functions}.
This should make {cmd:htmltit} useful for users who wish to generate HTML document indices
using non-ASCII scripts.

{pstd}
The {cmd:htmltit} package was designed for use with the {help ssc:SSC} packages
{helpb htmlutil} (to generate HTML documents),
{helpb xdir} (to generate datasets with 1 observation for each of a list of files),
and {helpb listtab} (to generate HTML tables).
The {helpb htmlutil} package is designed for use with the official Stata {helpb file} suite of commands.
For more about the use of {helpb listtab} to generate tables in HTML and other formats,
see {help htmltit##newson2012:Newson (2012)}.


{title:Examples}

{pstd}
The examples are designed to be demonstrated in an output dataset (or resultsset)
produced by the {help ssc:SSC} package {helpb xdir}.
This resultsset has one observation for each of a list of files,
all of which are HTML documents,
and variables {cmd:dirname} (containing the directory location)
and {cmd:filename} (containing the file name).
The {cmd:htmltit} package adds a new variable,
containing the HTML document titles.

{pstd}
Set-up:

{p 16 20}{cmd:. clear}{p_end}
{p 16 20}{cmd:. xdir, dir(.) pattern(*.htm) norestore}{p_end}
{p 16 20}{cmd:. describe, full}{p_end}
{p 16 20}{cmd:. list, abbr(32)}{p_end}

{pstd}
The following example simply creates a new variable {cmd:doctitle},
containing the document titles,
and lists all the variables for all the documents
for inspection by the user:

{p 16 20}{cmd:. htmltit filename, generate(doctitle)}{p_end}
{p 16 20}{cmd:. describe, full}{p_end}
{p 16 20}{cmd:. list, abbr(32)}{p_end}

{pstd}
The following more advanced example creates a new document title variable {cmd:doctitle2},
and then uses the {help ssc:SSC} package {helpb htmlutil}
to create a very basic HTML document {cmd:index.htm},
which contains a very basic HTML table,
with 2 columns, containing the HTML document file names
and their document titles.
Note that we use a {helpb capture:capture noisily} block
to ensure that,
in the event of an error in any of the output commands between {helpb htmlopen} and {helpb htmlclose},
the HTML document {cmd:index.htm}
will be closed,
and available for inspection by the user
by opening it in a Web browser:

{p 16 20}{cmd:. htmltit filename, generate(doctitle2)}{p_end}
{p 16 20}{cmd:. tempname htmb1}{p_end}
{p 16 20}{cmd:. htmlopen `htmb1' using "index.htm", title("All my HTML files in this folder") replace}{p_end}
{p 16 20}{cmd:. capture noisily {c -(}}{p_end}
{p 16 20}{cmd:. file write `htmb1' "<h1>My HTML files in this folder</h1>" _n}{p_end}
{p 16 20}{cmd:. listtab filename doctitle2, handle(`htmb1') rstyle(html) headline(<table>) footline(</table>)}{p_end}
{p 16 20}{cmd:. {c )-}}{p_end}
{p 16 20}{cmd:. htmlclose `htmb1'}{p_end}

{pstd}
A real-world example would be more advanced than this.
The table would probably have a heading.
And the table entries would probably contain HTML links,
enabling the user to click on entries in a browser and open the corresponding HTML documents.
We might also use the {help ssc:SSC} package {helpb tfinsert}
to insert HTML code to explain the tables.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{marker newson2012}{phang}
Newson, R. B.  2012.
From resultssets to resultstables in Stata.
{it:The Stata Journal} 12(2): 191-213.
Download from {browse "http://www.stata-journal.com/article.html?article=st0254":{it:The Stata Journal} website}.


{title:Also see}

{psee}
Manual:  {hi: [P] file}
{p_end}

{psee}
{space 2}Help:  {manhelp file P}{break}
{helpb xdir}, {helpb htmlutil}, {helpb listtab}, {helpb tfinsert} if installed
{p_end}

{psee}
{space 1}Other:  {browse "http://www.w3.org/MarkUp/":The W3C HyperText Markup Language (HTML) Home Page at http://www.w3.org/MarkUp/}
{p_end}
