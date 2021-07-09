{smcl}
{hline}
help for {cmd:htmlutil}{right:(Roger Newson)}
{hline}


{title:Utilities for writing Hypertext Markup Language (HTML) files}

{pstd}
Open a HTML file

{p 8 21 2}
{cmd:htmlopen} {it:handle} {cmd:using} {help filename:{it:filename}} [ , {cmd:replace} {cmdab:at:tributes}{cmd:(}{it:attributes_list}{cmd:)}
{break}
{cmdab:he:ad} {cmdab:heada:ttributes}{cmd:(}{it:head_attributes_list}{cmd:)}
{cmdab:ti:tle}{cmd:(}{it:string}{cmd:)}
{cmdab:headf:rom}{cmd:(}{help filename:{it:filename}}{cmd:)}
{break}
{cmdab:bo:dy} {cmdab:bodya:ttributes}{cmd:(}{it:body_attributes_list}{cmd:)}
{break}
{opt bom(bom_option)}
{break}
]

{pstd}

{pstd}
where {it:attributes_list} is a list of attributes for the {cmd:<html>} tag in HTML,
{it:head_attributes_list} is a list of attributes for the {cmd:<head>} tag in HTML,
{it:body_attributes_list} is a list of attributes for the {cmd:<body>} tag in HTML,
{it:handle} is a {help file:file handle} as recognized by the {helpb file} utility,
and {it:bom_option} can be an empty string or {cmd:utf-8}.

{pstd}
Insert an image in an open HTML file

{p 8 21 2}
{cmd:htmlimg} {it:handle} [ , {cmdab:at:tributes}{cmd:(}{it:attributes_list}{cmd:)}
]

{pstd}
where {it:attributes_list} is a list of attributes for the {cmd:<img>} tag in HTML,
and {it:handle} is a {help file:file handle} as recognized by the {helpb file} utility.

{pstd}
Insert a hyperlink in an open HTML file

{p 8 21 2}
{cmd:htmllink} {it:handle} [ ,
{cmdab:at:tributes}{cmd:(}{it:attributes_list}{cmd:)} {cmdab:linkt:ext}{cmd:(}{it:link_text}{cmd:)}
]

{pstd}
where {it:attributes_list} is a list of attributes for the {cmd:<img>} tag in HTML,
{it:link_text} is a piece of HTML code,
and {it:handle} is a {help file:file handle} as recognized by the {helpb file} utility.

{pstd}
Close an open HTML file

{p 8 21 2}
{cmd:htmlclose} {it:handle} [ , {cmdab:bo:dy} ]

{pstd}
where {it:handle} is a {help file:file handle} as recognized by the {helpb file} utility.


{title:Description}

{pstd}
The {cmd:htmlutil} package is a suite of file handling utilities
for producing Hypertext Markup Language (HTML) files in Stata.
The user can open the file for input using {cmd:htmlopen},
and close the file using {cmd:htmlclose}.
In between these statements,
the user can insert linked images from files using {cmd:htmlimg},
insert hypertext links using {cmd:htmllink},
insert HTML tables using the  {helpb listtab} package,
and insert more HTML using the {helpb tfinsert} package.
The packages {helpb listtab} and {helpb tfinsert} are downloadable from {help ssc:SSC}.


{title:Options for {cmd:htmlopen}}

{phang}
{cmd:replace} specifies that any existing file with the name specified by the {it:filename}
will be replaced.

{phang}
{cmd:attributes(}{it:attributes_list}{cmd:)} specifies a list of attributes,
to be passed to the {cmd:<HTML>} tag at the start of the HTML file.

{phang}
{cmd:head} specifies that a HTML head will be added to the new HTML file.
If the {cmd:headattributes()}, {cmd:headfrom()} and {cmd:title()} options are not specified,
then this HTML head will contain only the tags {cmd:<head>} and {cmd:</head>}.

{phang}
{cmd:headattributes(}{it:head_attributes_list}{cmd:)} specifies that a HTML head will be added to the new HTML file,
with attributes for the {cmd:<head>} tag specified by the {it:head_attributes_list}.
The {cmd:headattributes()} option implies the {cmd:head} option,
even if {cmd:head} is not specified by the user.

{phang}
{cmd:title(}{it:string}{cmd:)} specifies a title for the HTML document being created,
which will be output in the document head between a {cmd:<title>} tag and a {cmd:</title>} tag,
and will specify the Web page title visible on the browser tab when the HTML file is opened in a browser.
The {cmd:title()} option is not compulsory,
and the HTML document will still open in most browsers if it is not specified.
However, the HTML document will then probably not be a valid HTML document,
under the strict definition of HTML,
and the browser tab will probably display an alien-looking file path,
instead of a friendly-looking Web page title.
The {cmd:title()} option implies the {cmd:head} option,
even if {cmd:head} is not specified by the user.

{phang}
{cmd:headfrom(}{help filename:{it:filename}}{cmd:)} specifies that the HTML head will contain
HTML code from the file specified by the {help filename:{it:filename}}.
If the {cmd:head} option is specified (implicitly or explicitly),
then the code from the {help filename:{it:filename}} will be inserted after the {cmd:<head>} tag,
and before the {cmd:<title>} and {cmd:</title>} tags requested by the {cmd:title()} option.
If the {cmd:head} option is not specified (either explicitly or implicitly),
then the code in the file specified by the {help filename:{it:filename}}
has to start with a HTML {cmd:<head>} tag, and end with a HTML {cmd:</head>} tag,
and should also contain a {cmd:<title>} tag and a {cmd:</title>} tag,
with the Web page title in between.
The {cmd:headfrom()} option enables the user to build libraries of customized HTML head inserts in files,
containing HTML style information, metadata and other specifications,
and to use them regularly in multiple HTML documents, with different titles,
generated using the {cmd:htmlutil} package.
If the file specified by {cmd:headfrom()} does not exist,
then {cmd:htmlopen} will give an error message, but will complete execution normally,
inserting no HTML head insert.

{phang}
{cmd:body} specifies that a HTML {cmd:<body>} tag will be added to the new HTML file,
after any HTML head specified by the {cmd:head}, {cmd:headattributes()} and/or {cmd:headfrom()} options.
If the {cmd:bodyattributes()} option is not specified,
then this tag will have no attributes, and will simply be {cmd:<body>}.

{phang}
{cmd:bodyattributes(}{it:body_attributes_list}{cmd:)} specifies that a HTML {cmd:<body>} tag will be added to the new HTML file,
after any HTML head specified by the {cmd:head}, {cmd:headattributes()} and/or {cmd:headfrom()} options,
with attributes specified by the {it:body_attributes_list}.
The {cmd:bodyatributes()} option implies the {cmd:body()} option,
even if {cmd:body()} is not specified by the user.

{phang}
{opt bom(bom_option)} specifies a byte order marker (BOM) to be the first byte of the HTML output file.
It may be an empty string (the default, specifying no BOM)
or {cmd:utf-8}, specifying the UTF-8 byte order marker {cmd:"\uFEFF"}.
The option {cmd:bom(utf-8)} should be specified if the output HTML file is intended to be a UTF-8 file,
as it should be if there will be {help unicode:Stata unicode strings} in it.


{title:Options for {cmd:htmlimg}}

{phang}
{cmd:attributes(}{it:attributes_list}{cmd:)} specifies a list of attributes for the HTML {cmd:<img>} tag.
These attributes should include a {cmd:src=}{help filename:{it:filename}} attribute,
to specify the image source file.
This image source file might be an exported Stata graphics file, created by the {helpb graph export} command.


{title:Options for {cmd:htmllink}}

{phang}
{cmd:attributes(}{it:attributes_list}{cmd:)} specifies a list of attributes for the HTML {cmd:<a>} tag.
These attributes should include a {cmd:href=}{help filename:{it:filename}} attribute,
to specify the hypertext reference location.

{phang}
{cmd:linktext(}{it:link_text}{cmd:)} specifies the link text
to be inserted in the HTML link between the {cmd:<a>} tag and the {cmd:</a>} tag.
Note that the link text does not have to be plain text, but can be any HTML code.
For instance, it might contain a HTML {cmd:<img>} tag, specifying an image for the reader to click on.


{title:Options for {cmd:htmlclose}}

{phang}
{cmd:body} specifies that a HTML {cmd:</body>} tag should be added just before the {cmd:</html>} tag at the end of the new HTML file.
The {cmd:body} option for {cmd:htmlclose} should be used if and only if the corresponding {cmd:htmlopen} command
also has a {cmd:body} option (supplied explicitly or implicitly).


{title:Remarks}

{pstd}
The {cmd:htmlutil} package produces Hypertext Markup Language (HTML) documents.
The {cmd:htmlopen} command opens a file and initializes the output with the lines

{pstd}{cmd:<!DOCTYPE html>}{p_end}
{pstd}{cmd:<html>}{p_end}

{pstd}
if no {cmd:attributes()} option is supplied, and with the lines

{pstd}{cmd:<!DOCTYPE html>}{p_end}
{pstd}{cmd:<html {it:attributes_list}>}{p_end}

{pstd}
if a non-empty {cmd:attributes()} option is supplied.
The {cmd:htmlopen} command may then add a HTML head,
if one is specified using the {cmd:head} and/or {cmd:headattributes()} and/or {cmd:title()} and/or {cmd:headfrom()} options,
and/or initialize a HTML body by adding a HTML {cmd:<body>} tag,
if one is specified using the {cmd:body} and/or {cmd:bodyattributes()} options.

{pstd}
The {cmd:htmlclose} command outputs, to a file already open for text output, the lines

{pstd}{cmd:</body>}{p_end}
{pstd}{cmd:</html>}{p_end}

{pstd}
if a {cmd:body} option is specified, and only the line

{pstd}{cmd:</html>}{p_end}

{pstd}
if no {cmd:body} option is specified,
and then closes the open file.
This ensures that,
if the {cmd:htmlopen} and {cmd:htmlclose} commands either both specify a HTML body or both do not specify a HTML body,
and if the user outputs well-formed HTML code between the {cmd:htmlopen} and {cmd:htmlclose} statements,
then the HTML document as a whole will be well-formed and readable using a browser.

{pstd}
It is a good idea to enclose all code between a {cmd:htmlopen} command and the corresponding {cmd:htmlclose} command
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
then Stata will transfer control to the {cmd:htmlclose} command
immediately following the {helpb capture:capture noisily} block,
and the new HTML file specified by {cmd:htmlopen} will be closed,
and will be available for inspection by the user,
using a Web browser.

{pstd}
The {help ssc:SSC} package {helpb listtab} can be used for inserting HTML tables into a HTML file created using the {cmd:htmlutil} package.
For more about {helpb listtab}, see {help htmlutil##newson2012:Newson (2012)}.
For more about outputting HTML documents from Stata, see {help htmlutil##quintoetal2012:Quint{c o'} {it:et al.} (2012)},
{help htmlutil##jann2005:Jann (2005)} and {help htmlutil##jann2017:Jann (2017)}.


{title:Examples}

{pstd}
The following example generates a document {cmd:mydoc1.htm},
containing HTML code inserted using the {helpb tfinsert} package,
downloadable from {help ssc:SSC}..

{p 8 12 2}{cmd:. tempname handle1}{p_end}
{p 8 12 2}{cmd:. htmlopen `handle1' using "mydoc1.htm", replace}{p_end}
{p 8 12 2}{cmd:. capture noisily {c -(}}{p_end}
{p 8 12 2}{cmd:. tfinsert `handle1', terminator(END_OF_HTML)}{p_end}
{p 8 12 2}{cmd:. <head>}{p_end}
{p 8 12 2}{cmd:. <title>My Hello World webpage</title>}{p_end}
{p 8 12 2}{cmd:. </head>}{p_end}
{p 8 12 2}{cmd:. <body>}{p_end}
{p 8 12 2}{cmd:. <p>}{p_end}
{p 8 12 2}{cmd:. Hello, World!!!!}{p_end}
{p 8 12 2}{cmd:. </p>}{p_end}
{p 8 12 2}{cmd:. </body>}{p_end}
{p 8 12 2}{cmd:. END_OF_HTML}{p_end}
{p 8 12 2}{cmd:. {c )-}}{p_end}
{p 8 12 2}{cmd:. htmlclose `handle1'}{p_end}

{pstd}
The following example generates a document {cmd:mydoc2.htm},
which contains a HTML table of the mileages and weights of the 22 non-American cars in the {cmd:auto} data.
This table is generated using the {helpb listtab} package,
downloadable from {help ssc:SSC}.
The rest of the HTML is generated using the {helpb tfinsert} package.

{p 8 12 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 12 2}{cmd:. keep if foreign==1}{p_end}
{p 8 12 2}{cmd:. tempname handle2}{p_end}
{p 8 12 2}{cmd:. htmlopen `handle2' using "mydoc2.htm", attributes(lang=en-US) replace}{p_end}
{p 8 12 2}{cmd:. capture noisily {c -(}}{p_end}
{p 8 12 2}{cmd:. tfinsert `handle2', terminator(END_OF_HTML)}{p_end}
{p 8 12 2}{cmd:. <head>}{p_end}
{p 8 12 2}{cmd:. <title>My non-US cars webpage</title>}{p_end}
{p 8 12 2}{cmd:. </head>}{p_end}
{p 8 12 2}{cmd:. <body>}{p_end}
{p 8 12 2}{cmd:. <h1>Mileage and weight in non-US cars</h1>}{p_end}
{p 8 12 2}{cmd:. <table>}{p_end}
{p 8 12 2}{cmd:. END_OF_HTML}{p_end}
{p 8 12 2}{cmd:. listtab make mpg weight, handle(`handle2') rstyle(html) head("<tr><th>Make</th><th>Mileage (mpg)</th><th>Weight (lb)</th></tr>")}{p_end}
{p 8 12 2}{cmd:. tfinsert `handle2', terminator(END_OF_HTML)}{p_end}
{p 8 12 2}{cmd:. </table>}{p_end}
{p 8 12 2}{cmd:. </body>}{p_end}
{p 8 12 2}{cmd:. END_OF_HTML}{p_end}
{p 8 12 2}{cmd:. {c )-}}{p_end}
{p 8 12 2}{cmd:. htmlclose `handle2'}{p_end}

{pstd}
The following example generates a document {cmd:mydoc3.htm},
which contains the same HTML table of the mileages and weights as the previous example.
It also contains a graph of the same data,
produced using {helpb graph export} in Stata to produce a Scalable Vector Graphics ({cmd:.svg}) file {cmd:mydoc3_1.svg},
and inserted into the HTML document using the {cmd:htmlimg} command,
and a hyperlink (inserted using {cmd: htmllink})
to the .pdf graph of the same data in the file {cmd:mydoc3_1.pdf},
also produced using {helpb graph export}.
Note that the attributes list passed to {cmd:htmlimg}
is enclosed in compound quotes,
as the attributes list itself contains double quotes.

{p 8 12 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 12 2}{cmd:. keep if foreign==1}{p_end}
{p 8 12 2}{cmd:. tempname handle3}{p_end}
{p 8 12 2}{cmd:. htmlopen `handle3' using "mydoc3.htm", attributes(lang=en-US) head title("My graphic non-US cars webpage") body replace}{p_end}
{p 8 12 2}{cmd:. capture noisily {c -(}}{p_end}
{p 8 12 2}{cmd:. scatter mpg weight}{p_end}
{p 8 12 2}{cmd:. graph export mydoc3_1.svg, replace}{p_end}
{p 8 12 2}{cmd:. graph export mydoc3_1.pdf, replace}{p_end}
{p 8 12 2}{cmd:. htmlimg `handle3', attributes(`"src="mydoc3_1.svg" style="width:640px;""')}{p_end}
{p 8 12 2}{cmd:. htmllink `handle3', attributes(`"href="mydoc3_1.pdf""') linktext("<p>View the .pdf version of this image</p>")}{p_end}
{p 8 12 2}{cmd:. listtab make mpg weight, handle(`handle3') rstyle(html) head("<table>" "<tr><th>Make</th><th>Mileage (mpg)</th><th>Weight (lb)</th></tr>") foot("</table>")}{p_end}
{p 8 12 2}{cmd:. {c )-}}{p_end}
{p 8 12 2}{cmd:. htmlclose `handle3', body}{p_end}

{pstd}
The following advanced example generates a document {cmd:mydoc4.htm},
which contains the same HTML table of the mileages and weights as the previous examples,
and uses a HTML head insert from a HTML file {cmd:myhead1.htm},
which is inserted into the generated HTML document using the {cmd:headfrom()} option of {cmd:htmlopen}.
The file {cmd:myhead1.htm} contains a HTML head insert,
specifying that tables in the corresponding HTML body will be framed
using solid black lines 4 pixels in width,
and is listed as follows:

{p 8 12 2}{cmd:<style>}{p_end}
{p 8 12 2}{cmd:table, td, th {c -(}}{p_end}
{p 8 12 2}{cmd:border: 4px solid black;}{p_end}
{p 8 12 2}{cmd:{c )-}}{p_end}
{p 8 12 2}{cmd:</style>}{p_end}

{pstd}
The Stata code to use this user-specified customized HTML head insert in a new HTML document is as follows:

{p 8 12 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 12 2}{cmd:. keep if foreign==1}{p_end}
{p 8 12 2}{cmd:. tempname handle4}{p_end}
{p 8 12 2}{cmd:. htmlopen `handle4' using "mydoc4.htm", head headfrom("myhead1.htm") title("My stylish non-US cars webpage") body replace}{p_end}
{p 8 12 2}{cmd:. capture noisily {c -(}}{p_end}
{p 8 12 2}{cmd:. listtab make mpg weight, handle(`handle4') rstyle(html) head("<table>" "<tr><th>Make</th><th>Mileage (mpg)</th><th>Weight (lb)</th></tr>") foot("</table>")}{p_end}
{p 8 12 2}{cmd:. {c )-}}{p_end}
{p 8 12 2}{cmd:. htmlclose `handle4', body}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{marker jann2005}{phang}
Jann, B.  2005.
Making regression tables from stored estimates.
{it:The Stata Journal} 5(3): 288-308.
Download from {browse "http://www.stata-journal.com/article.html?article=st0085":{it:The Stata Journal} website}.

{marker jann2017}{phang}
Jann, B.  2017.
Creating HTML or Markdown documents from within Stata using {cmd:webdoc}.
{it:The Stata Journal} 17(1): 3-38.
Download from {browse "https://www.stata-journal.com/article.html?article=pr0065":{it:The Stata Journal} website}.

{marker newson2012}{phang}
Newson, R. B.  2012.
From resultssets to resultstables in Stata.
{it:The Stata Journal} 12(2): 191-213.
Download from {browse "http://www.stata-journal.com/article.html?article=st0254":{it:The Stata Journal} website}.

{marker quintoetal2012}{phang}
Quint{c o'}, L., S. Sanz, E. De Lazzari, and J. J. Aponte.  2012.
HTML output in Stata.
{it:The Stata Journal} 12(4): 702-717.
Download from {browse "http://www.stata-journal.com/article.html?article=dm0066":{it:The Stata Journal} website}.


{title:Also see}

{psee}
Manual:  {hi: [P] file}
{p_end}

{psee}
{space 2}Help:  {manhelp file P}{break}
{helpb listtab}, {helpb tfinsert} if installed
{p_end}

{psee}
{space 1}Other:  {browse "http://www.w3.org/MarkUp/":The W3C HyperText Markup Language (HTML) Home Page at http://www.w3.org/MarkUp/}
{p_end}
