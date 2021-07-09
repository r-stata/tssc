{smcl}
{hline}
help for {cmd:tfinsert}{right:(Roger Newson)}
{hline}


{title:Insert text from an instream line sequence and/or an existing file into an open text file}

{p 8 21 2}
{cmd:tfinsert} {it:handle} [ {cmd:using} {it:filename} ]
[ , {cmdab:te:rminator}{cmd:(}{it:string}{cmd:)} {cmdab:max:lines}{cmd:(}{it:#}{cmd:)} ]


{title:Description}

{pstd}
The {cmd:tfinsert} package inserts text from an instream dataset and/or an existing text file
into a text file open for text output and identified by a handle recognised by the {helpb file} command.
This allows the user to insert text into a TeX, HTML or XML file
that is being built by a Stata do-file.


{title:Options for {cmd:tfinsert}}

{phang}
{cmd:terminator(}{it:string}{cmd:)} specifies a terminator string,
used to terminate an instream sequence of lines of text following the {cmd:rtfinsert} command.
If {cmd:terminator()} is present,
then {cmd:tfinsert} will insert into the open document the following lines,
until a line containing only the {cmd:terminator()} string is encountered,
or until the number of lines is equal to the {cmd:maxlines()} option (see below).
If both a {cmd:terminator()} option and a {cmd:using} qualifier are present,
then {cmd:tfinsert} will first insert the instream sequence of lines,
and then insert the lines of text from the {cmd:using} file.
Note that the instream lines will be left- and right-trimmed
before being output to the open file.
This will not be a problem if the open output file is a TeX or HTML document.

{phang}
{cmd:maxlines(}{it:#}{cmd:)} specifies a maximum number of lines of RTF code
to read from the instream sequence of lines of RTF code.
If {cmd:maxlines()} is absent,
then it is set to a default value of 1024.


{title:Examples}

{pstd}
The following example builds a HTML file {cmd:mypage1.htm},
using a simple HTML head file {cmd:myhead1.htm}
and a simple HTML foot file {cmd:myfoot1.htm},
and inserting the HTML body text from an instream sequence of lines in the do-file.
The file {cmd:myhead1.htm} is assumed to be as follows:

{p 8 12 2}{cmd:. <head>}{p_end}
{p 8 12 2}{cmd:. </head>}{p_end}
{p 8 12 2}{cmd:. <body>}{p_end}

{pstd}
And the file {cmd:myfoot1.htm} is assumed to be as follows:

{p 8 12 2}{cmd:. </body>}{p_end}

{pstd}
And the Stata code for building {cmd:mypage1.htm} is as follows:

{p 8 12 2}{cmd:. tempname myhandle1}{p_end}
{p 8 12 2}{cmd:. file open `myhandle1' using mypage1.htm, text write replace}{p_end}
{p 8 12 2}{cmd:. tfinsert `myhandle1' using myhead1.htm}{p_end}
{p 8 12 2}{cmd:. tfinsert `myhandle1', terminator(END_HTML)}{p_end}
{p 8 12 2}{cmd:. <p>}{p_end}
{p 8 12 2}{cmd:. Hello, world!!!!}{p_end}
{p 8 12 2}{cmd:. </p>}{p_end}
{p 8 12 2}{cmd:. END_HTML}{p_end}
{p 8 12 2}{cmd:. tfinsert `myhandle1' using myfoot1.htm}{p_end}
{p 8 12 2}{cmd:. file close `myhandle1'}{p_end}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
Manual:  {manlink P file}
{p_end}

{psee}
{space 2}Help:  {manhelp file P}
{p_end}
