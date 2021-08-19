{smcl}
{* * KEEP THIS FILE MINIMAL, ESPECIALLY IF THE TEXT IS REPEATED IN OTHER HELP FILES}{...}
{* *! version 3.2  06Oct2015}{...}
{right:Version 3.3.8}
{* *! cmd:help Weaver}{...}

{phang}
{bf:weaver} {hline 2} A general purpose package for creating dynamic report in HTML, LaTeX, and 
PDF. Weaver includes a {help statax:built-in JavaScript syntax highlighter} for Stata code, an engine for 
{help Weaver_mathematical_notation:rendering LaTeX mathematical notations in LaTeX and HTML log files}, 
a number of specialized commands for creating publication-ready {help tbl:dynamic table}, 
{help img:inserting and resizing a figure}, and writing {help txt:dynamic text}. 
Moreover, Weaver also includes a built-in JavaScript-based language called 
{help Weaver_Markup:Weaver markup Language} which allows the users to create a 
sophisticated HTML document using a simplified and minimalistic markup language, 
similar but not identical to Markdown. 

{p 8 8 2}
Weaver is essentially an independent HTML or LaTeX log system
that runs in paralel to Stata log and can be used simultaniously with regular 
smcl or text logfile. In contrast to smcl log file, the main idea of the Weaver 
package is to provide the possibility of deciding which commands, results, and 
figures should appear in the Weaver log (dynamic report). Therefore, Weaver log is 
not autonomous. The big advantage of this approach to 
dynamic reporting is that as the user carries out the data analysis interactively, 
the dynamic document can be viewed in real-time by refreshing the HTML web-browser, 
or opening the LaTeX document in {browse "http://www.texstudio.org/":TeXstudio} or any advanced text editor such as 
{browse "http://www.sublimetext.com/":Sublime Text}, or alternatively, reandering a 
PDF document at any point. 
These features work smoothly for both LaTeX and HTML. Another example 
would be a LaTeX table exported from tabout command which can be merged in 
Weaver's LaTeX log. 

{p 8 8 2}
Weaver is a general purpose package that is designed to effectively handle HTML and 
LaTeX documents. It includes many additional features that makes it a prime package 
for collaborating with all other packages for developing automated outputs such as 
{help MarkDoc}, {help tabout}, etc. Any package that produces LaTeX or HTML output, 
cal collaborate with Weaver because Weaver allows importing HTML and LaTeX
documents. For example, a document written in {browse "https://daringfireball.net/projects/markdown/":Markdown language} 
and exported to LaTeX or HTML using the {help MarkDoc} package, can be simple merged 
into Weaver's LaTeX or HTML log respectively. 

{p 8 8 2}
Visit 
{browse "http://www.haghish.com/statistics/stata-blog/reproducible-research/weaver.php":http://haghish.com/weaver} 
for a complete tutorial on Weaver as well as downloading template do-files. 


{title:Author} 
        {p 8 8 2}E. F. Haghish{break} 
	Center for Medical Biometry and Medical Informatics{break}
	University of Freiburg, Germany{break} 
        {browse haghish@imbi.uni-freiburg.de}{break}
	{browse "http://www.haghish.com/statistics/stata-blog/reproducible-research/weaver.php":{it:http://haghish.com/weaver}}{break}
   Package Updates on {it:{browse "http://twitter.com/Haghish":Twitter}}
   

{title:Related help files}
 
{p 8 8 2}
{help weaver_markup:{c 149} Simplified Weaver Markup Language}{break} 
{help Weaver_mathematical_notation:{c 149} Rendering LaTeX mathematical notations in HTML and LaTeX log files}{break} 
{help statax:{c 149} Statax JavaScript Syntax Highlighter}{break}
{help div:{c 149} {bf:div} command for ncluding Stata code and output in the document}{break} 
{help img:{c 149} {bf:img}  command for inserting a figure or image in the document}{break} 
{help txt:{c 149} {bf:txt}  command for writing dynamic text in the document}{break}
{help tbl:{c 149} {bf:tbl} command for creating dynamic table}{break}

   
{marker summary}{...}
{title:Summary of Weaver commands}

{p 8 8 2}
Weaver includes two sets of commands. The "weave commands" are related to the 
Weaver log file. For example, opening 
and closing a log file, turning the log file on or off, preserving and restoring the 
log file, rendering a pdf document from the log, etc. Therefore, a 
dynamic document begins and ends with these commands. The syntax of "weave commands" 
is very similar to Stata smcl log syntax although Weaver provides more features. 
The other commands which are {help div}, {help txt}, {help img}, and {help tbl} are 
generally related to the content of Weave log. For example, they are used for annotating the 
document, writing code and output to the Weaver log, inserting image, and creating 
dynamic table. These commands
are explained in two separate sections. 

{p 8 8 8}
{opt weave} {cmd:using} {it:{help filename}} [{cmd:,} {opt options}]{break} 
{opt weave} {cmdab:mer:ge} {cmd:using} {it:{help filename}} {break} 
{opt weave} {opt pdf} [{cmd:,} {cmd:replace}] {break} 
{opt weave} {cmdab:q:uery} {break} 
{opt weave} {c -(}{opt of:f}{c |}{opt on}{c )-} {break}
{opt weave} {c -(}{opt preserve}{c |}{opt restore}{c )-} {break}
{opt weave} {opt c:lose} {break} 
{opt weave} {opt setup} {break} 
{bf:{help div}}  [{opt c:ode}{c |}{opt r:esult}] {it:command} {break}
{bf:{help txt}}  [{opt c:ode}] {it:"string"} {break}
{bf:{help img}}  {it:{help filename}} [{cmd:,} {opt options}] {break}
{bf:{help tbl}} {it:(*[,*...] [\ *[,*...] [\ [...]]])} [{cmd:,} {opt options}] {break}



{marker syntax}{...}
{title:Syntax of weave commands}

{phang}
Report status of Weaver log file

{p 8 13 2}
{opt weave} {cmdab:q:uery}


{phang}
Open Weaver log file to begin the dynamic report

{p 8 13 2}
{opt weave} {cmd:using} {it:{help filename}} [{cmd:,} 
{opt instal:l}
{it:{opt no:pdf}}
{opt print:er(str)}
{opt mark:up(name)}
{cmd:append}
{cmd:replace} 
{opt paper:size(name)}
{opt m:argin(int,int,int,int)}
{opt sty:le(name)}
{bf:template(}{it:{help filename}}{bf:)}
{opt land:scape}
{opt toc}
{opt f:ont(name)}
{opt tit:le(str)} 
{opt au:thor(str)} 
{opt aff:iliation(str)} 
{opt add:ress(str)} 
{opt sum:mary(str)}
{opt d:ate}
{opt syn:off} 
{opt noi:sily}
] 


{phang}
Merge a HTML file (html, xhtml, htm) or LaTeX document to Weaver HTML or LaTeX log respectively

{p 8 13 2}
{opt weave} {cmdab:mer:ge} {cmd:using} {it:{help filename}} 


{phang}
PDF live-preview of dynamic document

{p 8 13 2}
{opt weave} {opt pdf} [{cmd:,} {cmd:replace}]


{phang}
Close Weaver log and print the final pdf dynamic document

{p 8 13 2}
{opt weave} {opt c:lose}


{phang}
Temporarily suspend logging or resume logging

{p 8 13 2}
{opt weave} {c -(}{opt of:f}{c |}{opt on}{c )-}


{phang}
Preserve and restore the Weaver log

{p 8 13 2}
{opt weave} {c -(}{opt preserve}{c |}{opt restore}{c )-}


{phang}
Permanently set the default file paths to the required third-party software 

{p 8 13 2}
{opt weave setup} 


{marker syntaxother}{...}
{title:Syntax of annotating commands}

{phang}
{* bf:{ul:div command}}{p_end}{p 4 4 2}
Include both the Stata command and output in the Weaver log. The {opt c:ode} and 
{opt r:esult} subcommands only echo the command or outputs in the Weaver log respectively. 

{p 8 13 2}
{bf:{help div}} [{opt c:ode}{c |}{opt r:esult}] {it:command}


{phang}
Inserts, style, and resize a graph in Weaver log

{p 8 13 2}
{bf:{help img}} {it:{help filename}} [{cmd:,} {opt tit:le(str)} {opt w:idth(int)} 
{opt h:eight(int)} {opt left} {opt center}  ]


{phang}
Create a HTML or LaTeX dynamic table in Weaver log

{p 8 13 2}
{bf:{help tbl}} {it:(*[,*...] [\ *[,*...] [\ [...]]])} [{cmd:,} {opt tit:le(str)} {opt w:idth(int)} 
{opt h:eight(int)} {opt left} {opt center}  ]


{phang}
{* bf:{ul:txt command}}{p_end}{p 4 4 2}
Write and style dynamic text and mathematics
notations. The {opt c:ode} subcommand prints anything as-is on the 
log.  

{p 8 13 2}
{bf:{help txt}} [{opt c:ode}] {it:display_directive}



{title:Weave Options}

{* dlgtab:weave options}
{phang}{cmdab:instal:l} installs the {browse "http://wkhtmltopdf.org/":wkhtmltopdf} 
PDF driver and {browse "http://www.mathjax.org/":MathJaX} automatically in 
the {bf:~/plus/Weaver} directory, if it is not already installed. For manual installation and more details, see below. 
{p_end}

{phang}{cmdab:no:pdf} runs Weaver without requiring any third-party software by 
omitting rendering a PDF and mathematical notations in the HTML log.{p_end}

{phang}{cmdab:print:er:(}{it:string}{cmd:)} defines the file path to the 
wkhtmltopdf or pdfLaTeX drivers. This option is only needed if the third-party
is not automatically installed in 
the {bf:~/plus/Weaver} directory (see {help weaver##trouble:Software troubleshoot} for more details).{p_end}

{phang}{cmdab:mark:up:(}{it:name}{cmd:)} define the log format which can be 
{opt html} or {opt latex}.{p_end}

{phang}{opt replace} replaces the log and pdf files if already exist. {p_end}

{phang}{opt append} appends more content to the existing HTML or LaTeX file. {p_end}

{phang}{cmdab:paper:size:(}{it:name}{cmd:)} defines the page size of the PDF document. The 
default paper size is {bf:A4}, however, Weaver supports most of the popular page sizes 
including {bf:A0}, {bf:A1}, {bf:A2}, {bf:A3}, {bf:A4} {bf:A5} 
{bf:A6}, {bf:A7}, {bf:A8}, {bf:A9}, {bf:B0}, {bf:B1}, {bf:B2}, {bf:B3}, {bf:B4}, {bf:B5}, 
{bf:B6}, {bf:B7}, {bf:B8}, {bf:B9}, {bf:B10}, {bf:C5E}, {bf:Comm10E}, {bf:DLE}, {bf:Executive}, 
{bf:Folio}, {bf:Ledger}, {bf:Legal}, {bf:Letter}, and {bf:Tabloid}. These names can also 
be specified in lower cases. {p_end}

{phang}{opt m:argin(int,int,int,int)} defines 4 integers that change the margins of the 
document clockwise, beginning with the top margin, to the right margin, then bottom margin, 
and then the left margin of the document respectively. The integer sets the margin in terms 
of number of mm. {p_end}

{phang}{cmdab:sty:le:(}{it:name}{cmd:)} change the style of the document. The available 
styles are {bf:modern}, {bf:classic}, {bf:stata}, {bf:elegant}, {bf:minimal}, and {bf:empty}. 
The {bf:stata} style is the default style. The {bf:empty} style creates an empty 
HTML or LaTeX document, allowing the user to create the dynamic document from 
scratch which also excludes all of the JavaScripts programs and the syntax 
highlighter as well or the LaTeX template.{p_end}

{phang}{cmdab:temp:late:(}{it:{help filename}}{cmd:)} link an external style sheet file to allow 
users to change the appearence of the document. All the styles 
relating to the document, syntax highlighter, and the dynamic table can be 
overruled using this option. For HTML log, attach a CSS file and for LaTeX log, write the heading in a file and use it as a template. Weaver can also automatically extract the heading from other LaTeX documents if you use them as templates.{p_end}

{phang}{cmdab:land:scape} flips the page orientation to the landscape mode. {p_end}

{phang}{cmdab:toc} add an automatic table of contents.{p_end}

{phang}{cmdab:f:ont:(}{it:string}{cmd:)} specifie the text font for all 
headings, subheadings, and paragraphs. Each {cmdab:sty:le:(}{it:name}{cmd:)}
option automatically
applies different fonts. Therefore, use this option only if you are 
unsatisfied with the default fonts. Note that the available LaTeX fonts differ 
from HTML fonts. The list of available LaTeX fonts is {bf:cmr}, {bf:lmr}, 
{bf:pbk}, {bf:bch}, {bf:pnc}, {bf:ppl}, {bf:ptm}, {bf:cmss}, {bf:lmss},
  {bf:pag}, {bf:phv}, {bf:cmtt}, {bf:lmtt}, {bf:pcr}  
({browse "http://en.wikibooks.org/wiki/LaTeX/Fonts":Read more about LaTeX fonts}).{p_end}

{phang}{cmdab:tit:le:(}{it:string}{cmd:)} specify the title of Weaver log. {p_end}

{phang}{cmdab:au:thor:(}{it:string}{cmd:)} specify the author name. {p_end}

{phang}{cmdab:aff:iliation:(}{it:string}{cmd:)} prints the author's affiliation 
(or any preferred relevant information). {p_end}

{phang}{cmdab:add:ress:(}{it:string}{cmd:)} prints the author's contact information 
(or any preferred relevant information).{p_end}

{phang}{cmdab:sum:mary:(}{it:string}{cmd:)} add a summary paragraph. {p_end}

{phang}{cmdab:d:ate} prints the current date on the first page{p_end}

{phang}{cmdab:syn:off} turns off {help Statax} JavaScript syntax highlighter engine.{p_end}

{phang}{cmdab:noi:sily} noisily performs Weaver commands ; if specified, Weaver 
commands print outputs on the results windows and thus, {help MarkDoc} 
package can be used with Weaver simultaniously. {p_end}



{title:Description}

{pstd}
The {bf:Weaver} package provides a set of commands for writing and styling a dynamic report 
in Stata. What makes Weaver different from the {help MarkDoc} package - which 
also create dynamic reports- is that Weaver creates an HTML or LaTeX log file that 
runs in paralel to Stata log file and can select 
what Stata commands, outputs, text, and comments to appear in the dynamic 
document. This feature is particularly 
interesting because it avoids starting a new do-file for creating the dynamic document. 
The Weaver log file system is distinguished from smcl log files and thus, the 
user can use them both at the same time, to register all the
commands and results in the Stata smcl log as well as creating a selective 
dynamic document that can also include figures and graphs, render mathematical 
notation, include a syntax highlighter for Stata code, create publication-ready 
dynamic tables, and also dynamic text for interpreting the results of the analysis. 

{pstd}
The biggest advantage of Weaver compared to {help MarkDoc} is 
that it does not need to be compiled and is independent of smcl log files. In 
fact, Weaver is based on HTML or LaTeX and stores
text, commands, and output in these rather than {help smcl}. As a 
result, the document 
can be {bf:live-viewed} in by opening the HTML log file and refreshing the 
browser or using a LaTeX editor such as {browse "http://www.texstudio.org/":TeXstudio} at any point. 


{synoptset 35}{...}
{p2col:Command}Description{p_end}
{synoptline}
{synopt :{opt weave} {cmd:using} {it:{help filename}} [{cmd:,} {it:options}]}creates a HTML or LaTeX log 
for the dynamic document. Therefore, the dynamic document begins with this command. {opt weave} can 
accept several options that determine the title, author name, author information and 
affiliation, date, running head, summary of the report, table of content, document format and style, etc.{p_end}


{synopt :{opt weave} {cmdab:mer:ge} {cmd:using} {it:{help filename}}}Merges the content 
of a file to the HTML or LaTeX log. It can be used for adding existing {bf:html}, 
{bf:htm}, and {bf:xhtml} documents to the HTML log or a LaTeX {bf:tex} document 
to the LaTeX log. Note that in contrast to HTML, LaTeX document has a very 
strict structure, beginning with loading packages, {bf:\begin{c -(}document{c )-}} and 
ending with {bf:\end{c -(}document{c )-}}. If there is a multiplication of this 
command, the LaTeX document will not be compiled. However, Weaver is programmed 
to take care of all of the potential risks in merging LaTeX documents, which means 
if the document that is being merged is not properly prepared for a straightforward 
copy and past, Weaver will identify the problematic code and turn merges them as 
comments and notifies the user.  {p_end}


{synopt :{cmd:weave close}}closes the Weaver log file and prints the pdf document, if the pdf 
driver is installed. The dynamic document ends with this command. {p_end}


{synopt :{opt weave} {cmd:pdf} [{cmd:,} {it:replace}]}creates a 
live-preview pdf document from the HTML or LaTeX log at any point. This command is useful for checking 
the document to make sure its format and content is desirable. {p_end}


{synopt :{cmd:weave {c -(}{opt of:f}{c |}{opt on}{c )-}}}temporarily turnes the log file on or off. {p_end}


{synopt :{cmd:weave {c -(}{opt preserve}{c |}{opt restore}{c )-}}}preserves the current status 
of the Weaver log file and restore it back. These two subcommands are useful while 
doing exploratory analysis and deciding to restore the older version of the Weaver log. {p_end}


{synopt :{cmd:weave setup}}permanently define the paths to executable 
wkhtmltopdf, pdfLaTeX, and MathJax third-party software. {p_end}

{synoptline}
{p2colreset}{...}


{title:Required Software}
{psee}

{pstd}
{marker wk}{...}
As long as the {it:{opt no:pdf}} option is specified, Weaver does not require 
any third-party software. However, for rendering PDF from the HTML or LaTeX log 
files as well as rendering MathJax mathematic notations in the HTML log, Weaver 
requires additional third-party software. 
The required software can be installed 
manually or automatically and both procedures are explained below.


{title:Automatic Installation}

{p 4 4 2}
For automatic installation of wkhtmltopdf and mathJax, use the {cmd:install} option 
when opening a new log file. For example:

{phang}{cmd:. weave using example.tex, install}

{p 4 4 2}
Weaver will automatically check for the software 
on your machine and if it does not access the software, it will download a portable 
version of the software in Weaver directory, which is located in 
{bf:~/ado/plus/Weaver/} on your machine. To find the location of PLUS directory
on your machine check the system directories of Stata by typing 
{stata sysdir} in Stata command window. The usual complete
paths to the Weaver directory are shown below. Note that username refers to your machine's username.

{synoptset 10}{...}
{synopt :{bf:Windows:}}{bf:C:\ado\plus\Weaver}

{synopt :{bf:Macintosh:}}{bf:/Users/}{it:username}{bf:/Library/Application Support/Stata/ado/plus/Weaver} 

{synopt :{bf:Unix:} }{bf:/home/}{it:username}{bf:/ado/plus/Weaver}

{p 4 4 2}
The automatic installation is expected to 
work properly with Microsoft Windows {bf:XP}, Windows {bf:7}, and Windows {bf:8.1}, Macintosh  
{bf:OSX 10.9.5} and {bf:10.10}, Linux {bf:Mint 17 Cinnamon} (32bit & 64bit), {bf:Ubuntu 12} and {bf:14} (64bit), and 
{bf:CentOS 7} (64bit). Other operating systems may require manual software installation.

{p 4 4 2}
Please read the license agreement of {browse "http://wkhtmltopdf.org/":wkhtmltopdf} 
and {browse "http://www.mathjax.org":mathjax} software. By choosing automatic 
installation, you also confirm that you are aware and agreed with the license agreements. 


{title:Manual Installation}

{p 4 4 2}
{browse "http://wkhtmltopdf.org/downloads.html":{bf:wkhtmltopdf}} is a free open source (LGPL) 
command line tools to render HTML into PDF. The application is available for Windows, Mac, 
and Unix as a freeware. Users can download and install this application on their machines and 
give the path to executable wkhtmltopdf using the {opt print:er(str)} or 
specify the path to this application permanently, by editing the {it:weaversetup.ado} 
file using the {cmd:weave setup} command. Visit 
{browse "http://haghish.com/packages/pdf_printer.php":Installing PDF Printers} for more details.

{p 4 4 2}
Weaver also requires {browse "http://www.mathjax.org":mathjax.org} JavaScript 
which renders LaTex mathematical notations in HTML log. This software 
is not required in LaTeX log files. On the main page of mathjax.org, 
you can download {bf:MathJax-master.zip} file and unzip it inside Weaver directory, 
in {bf:~/ado/plus/Weaver/} on your machine. Alternatively, you can define the 
path ro the MathJax-master directory by editing {it:weaversetup.ado} 
file using the {cmd:weaver setup} command. This file is automatically generated the first time the {cmd:weaver setup} command is executed and will serve as a long-term memory file for the 
Weaver as well as {help MarkDoc} package.


{title:Remarks}
{psee}

{pstd}
Weaver interacts with the operating system for installing, creating, replacing, and removing files. 
It is recommended to the users to use the machine as an administrator, run Stata as administrator, 
and make sure they have the permission if creating and replacing files in the working directory. 
Stata should be allowed to remove or replace files in the working directory. 


{title:Example}

{p 4 12 2}
Visit {browse "http://www.haghish.com/statistics/stata-blog/reproducible-research/weaver.php":http://www.haghish.com/weaver}
for downloading example do-files for the Weaver package. {break}


{title:Also see}

{psee}
{space 0}{bf:{help Markdoc}}: Converting SMCL to any format using Pandoc

{psee}
{space 0}{bf:{help Statax}}: JavaScript syntax highighter for Stata

{psee}
{space 0}{bf:{help Synlight}}: SMCL to HTML translator and syntax highlighter

