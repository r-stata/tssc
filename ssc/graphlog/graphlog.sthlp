{smcl}
{* *! version 1.5  09jul2014}{...}
{hi:help graphlog}{right: ({browse "http://www.stata-journal.com/article.html?article=gr0064":SJ15-2: gr0064})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{cmd:graphlog} {hline 2}}Convert log files to PDF files with embedded figures{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmdab:graphlog} {cmd:using} {it:filename} [{cmd:,} 
{opt gdir:ectory(string)}
{cmdab:ps:ize(}{cmdab:a:4}|{cmdab:l:etter)}
{cmdab:po:rientation(}{cmdab:p:ortrait}|{cmdab:l:andscape)}
{opt ms:ize(#)}
{cmdab:fs:ize(10}|{cmd:11}|{cmd:12)}
{opt ls:pacing(#)}
{opt split:output}
{opt sepf:igures}
{opt fw:idth(#)}
{opt en:umerate}
{opt col:or(string)}
{opt enc:oding(string)}
{opt keep:tex}
{opt replace}
{opt open:pdf}]


{marker description}{...}
{title:Description}

{pstd}
{cmd:graphlog} converts already existing log files ({cmd:.txt}, {cmd:.log}, or
{cmd:.smcl} format) to a PDF document.  It will embed figures saved during
the logged session into the PDF document, as long as the graphs have been
saved in {cmd:.png}, {cmd:.gph}, or {cmd:.pdf} format.


{title:Options}

{phang}
{opt gdirectory(string)} specifies the directory where the graphics files are
placed.  This is helpful if {cmd:graphlog} cannot find your graph.

{phang}
{cmd:psize(a4}|{cmd:letter)} determines the paper size of the PDF document.
The default is {cmd:psize(a4)}.

{phang}
{cmd:porientation(portrait}|{cmd:landscape)} determines the page orientation.
The default is {cmd:porientation(portrait)}.

{phang}
{opt msize(#)} specifies the margin size in inches.  The default is
{cmd:msize(0.5)}.  The minimum value is 0.1, and the maximum value is
2.5.

{phang}
{cmd:fsize(10}|{cmd:11}|{cmd:12)} determines the font size.  The default is
{cmd:fsize(11)}.

{phang}
{opt lspacing(#)} specifies the line spacing used in the PDF document.  The
default is {cmd:lspacing(0.7)}

{phang}
{cmd:splitoutput} allows output from one command to be split over multiple
pages.  Use this option to conserve paper.  Normally, {cmd:graphlog} will
split output over multiple pages only if the block of output is too large to
fit on one page.

{phang}
{cmd:sepfigures} forces {cmd:graphlog} to place embedded figures on separate
pages in landscape mode (regardless of the page orientation of the rest of the
PDF document).  If not specified, figures will be embedded on the text pages.

{phang}
{opt fwidth(#)} defines the width of the figures as a fraction of the maximum
text width (that is, as a fraction of the paper width minus the margins).  The
default is {cmd:fwidth(1)}.

{phang}
{cmd:enumerate} adds a footer on each page reading "{cmd:Page} {it:X} {cmd:of}
{it:Y}".

{phang}
{cmd:color} specifies the text color in the PDF. The default is {cmd:color(black)}. For a (non-complete) list of available colors, go to {browse "https://en.wikibooks.org/wiki/LaTeX/Colors#The_68_standard_colors_known_to_dvips"}

{phang}
{cmd:encoding} specifies the character encoding of the log file. The default is {cmd:encoding(uft8)} on Linux/Mac OS X and {cmd:encoding(ansinew)} on Windows. If graphlog doesn't understand your non-latin characters, try another character encoding as described on {browse "https://en.wikibooks.org/wiki/LaTeX/Special_Characters#Input_encoding"}

{phang}
{cmd:keeptex} saves a copy of the TeX file for manual editing.

{phang}
{cmd:replace} allows overwriting an existing PDF or TeX file.

{phang}
{cmd:openpdf} opens the PDF document upon completion.  Available only for
Windows systems.


{marker dependencies}{...}
{title:Dependencies}

{pstd}
For the {cmd:graphlog} command to work, the system must have a LaTeX compiler
with {cmd:pdflatex} installed (free of charge).  For Microsoft Windows, I
recommend using MiKTeX ({browse "http://miktex.org/download"}); for Mac OS X,
MacTeX ({browse "http://tug.org/mactex"}); and for Linux, TeX Live
({browse "http://tug.org/texlive"}).


{marker graphsnotfound}{...}
{title:Help! graphlog cannot find my graphs.}

{pstd}
Because Stata does not write full paths to saved files, sometimes
{cmd:graphlog} will not be able to find the exported graphs.  There are two
ways around this: Either execute the command {cmd:pwd} at least once during
the logged session before the graph is saved, or specifically tell
{cmd:graphlog} which folder to look in by using the option 
{opt gdirectory(string)}.


{marker knownissue1}{...}
{title:Known issue with apostrophes and grave accents}

{pstd}
{cmd:graphlog} may display the error messages 
{bf:program error:  matching close brace not found} or {bf:too few quotes} if
you try to convert a log file containing apostrophes ({cmd:'}) or grave
accents ({cmd:`}).  If you have written grave accents or apostrophes in the
comments of your do-file, you can solve the problem by simply deleting the
problematic characters and rerunning the do-file and {cmd:graphlog}.  If you
are programming Stata using local macros or compound double quotes
({cmd:`""'}), your code probably needs those characters to function properly.
In that case, do the following:

{phang2}
1. Break the lines containing apostrophes or grave accents using {cmd:///} so
that they become short enough to fit one line in the final PDF.

{phang2}
2. Rerun the do-file and {cmd:graphlog}.

{phang2}
3. If the problem persists, increase the number of characters Stata writes to
the log file before creating a line break.  Type {cmd:set} {cmd:linesize}
{it:#} (without the quotes), where {it:#} is the maximum number of characters
on each line.

{phang2}
4. Rerun the do-file and {cmd:graphlog}.


{marker knownissue2}{...}
{title:Known issue with Mac OS X and Linux}

{pstd}
If you are using Mac OS X or Linux and {cmd:graphlog} fails no matter which
log file you try to convert, it may be because Stata cannot find the
{cmd:pdflatex} program used by {cmd:graphlog}. To fix this, run the command {cmd:graphlog_unix_setup} and follow the instructions displayed.

{pstd}
{it:{stata "graphlog_unix_setup":graphlog_unix_setup}}

{marker knownissue3}{...}
{title:Known issue with leading blanks in filenames and directories}

{pstd}
{cmd:graphlog} generally supports paths and file names containing blanks, but {it: not}
leading blanks. Thats is, {cmd:graphlog} understands when a graph is stored as
"my example .pdf" or the directory is "C:/Random user/Documents ". But it
does not understand the filename " example.pdf" or the directory "C:/ RandomUser/Documents".

{marker examples}{...}
{title:Example}

{pstd}Start logging, generate a table and a graph, stop logging, and
convert the log to PDF{p_end}

{phang2}{cmd:. preserve}{p_end}
{phang2}{cmd:. capture log close}{p_end}
{phang2}{cmd:. log using examplelog.log, replace}{p_end}
{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. summarize length}{p_end}
{phang2}{cmd:. scatter trunk length}{p_end}
{phang2}{cmd:. graph export examplegraph.pdf, replace}{p_end}
{phang2}{cmd:. log close}{p_end}
{phang2}{cmd:. graphlog using examplelog.log, replace}{p_end}
{phang2}{cmd:. restore}{p_end}
{phang2}{it:({stata "graphlog_example":click to run})}


{title:Author}

{pstd}Martin Rune Hansen{p_end}
{pstd}Aarhus University Hospital{p_end}
{pstd}Aarhus, Denmark{p_end}
{pstd}mrha@mil.au.dk


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 2: {browse "http://www.stata-journal.com/article.html?article=gr0064":gr0064}{p_end}
