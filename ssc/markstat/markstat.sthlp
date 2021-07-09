{smcl}
{* 26oct2016 18dec2017}{...}
{title:Title}

{phang}
{bf:markstat} {hline 2} Dynamic Documents with Stata and Markdown {hline 2} 2.1

{title:Syntax}

{p 4 6 2}
{cmd:markstat using} {it:filename} [, {opt pdf} {opt docx}
{opt slides} {opt beamer} {opt mathjax} {opt bundle} 
  {opt bib:liography} {opt strict} {opt nodo} {opt nor} {opt keep}]

{phang}
{it:filename} is a required argument specifying the name of the 
Stata-Markdown file. It should have extension {bf: .stmd}, but 
this may be omitted when typing the command. The filename must
be enclosed in double quotes if it contains blanks. 

{title:Options}

{phang}
{opt pdf} is an optional argument used to request generating a
PDF rather than an HTML file. 

{phang}
{opt docx} requests generating a Word document instead.

{phang}
{opt slides} generates an HTML slide show using the S5 engine and the
default Blue Spiral theme, and {opt slides(santiago)} uses the Santiago
theme. Add a {bf:+} for incremental mode, typing {opt slides(+)} or
{opt slides(santiago+)}.

{phang}
{opt beamer} generates a PDF slide show via LaTeX using Beamer and the
default theme, and {opt beamer(theme)} uses any of the many Beamer themes
available, for example {opt beamer(madrid)}. Add a {bf:+} for incremental mode.

{phang}
{opt mathjax} is used to render LaTeX equations in HTML documents,
including S5 slide shows, using the JavaScript library MathJax. Not
needed for PDF or Word documents, where LaTeX equations are rendered natively.

{phang}
{opt bundle} is used to generate self-contained HTML documents, encoding
all images and ancillary CSS and JavaScript files using base64. MathJax
cannot be bundled, but a local link may be used. The option is not
needed for PDF or Word documents, which are always self-contained.

{phang}
{opt bib:liography} is used to resolve citations using a BibTeX 
database, and add a list of references at the end of the document,
see {help markstat##citations:citations} below. Works with all formats.

{phang}
{opt strict} specifies that you are using the strict syntax, as explained in 
the {help markstat##strict:Stata Code} section below. Code fences are now 
detected automatically, so this option can be omitted in most cases.

{phang}
{opt nodo} is used to skip running the Stata do file when you have just
tweaked the narrative. Useful for presentations, where you may change from
S5 to Beamer or try a different theme without rerunning the analysis.
The idea comes from Ben Jann's {bf:nodo} option in {cmd: texdoc}.

{phang}
{opt nor} skips running the R script when you have just tweaked the narrative,
think of it as the R equivalent of {bf:nodo}.

{phang}
{opt keep} controls the fate of intermediate files which are now deleted
to avoid cluttering your hard drive. The default is to keep only {bf:smcl} and
{bf:rout} log files to enable {bf:nodo} and {bf:nor}, in addition of course
to the output files {bf:html}, {bf:pdf} and {bf:docx}. Specify {opt keep(list)}
to specify which additional files to keep, for example {opt keep(do tex)} to
keep the Stata {bf:do} and LaTeX {bf:tex} files, and {opt keep} to keep everything.


{title:Description}

{pstd}
The basic idea of this command is to prepare an input file that 
combines comments and annotations written in Markdown, with Stata 
commands that appear in blocks indented one tab or four spaces, as in the
following example:

 {col 8}{c TLC}{hline 65}{c TRC}
 {col 8}{c |}  Stata Markdown{col 74}{c |}
 {col 8}{c |}  --------------{col 74}{c |}
 {col 8}{c |}{col 74}{c |}
 {col 8}{c |} Let us read the fuel efficiency data that ships with Stata{col 74}{c |}
 {col 8}{c |}{col 74}{c |}
 {col 8}{c |}{col 13}sysuse auto, clear{col 74}{c |}
 {col 8}{c |}{col 74}{c |}
 {col 8}{c |} To study how fuel efficiency depends on weight it is useful to{col 74}{c |}
 {col 8}{c |} transform the dependent variable from "miles per gallon" to{col 74}{c |}
 {col 8}{c |} "gallons per 100 miles"{col 74}{c |}
 {col 8}{c |}{col 74}{c |}
 {col 8}{c |}{col 13} gen gphm = 100/mpg{col 74}{c |}
 {col 8}{c |}{col 74}{c |}
 {col 8}{c |} We then obtain a fairly linear relationship{col 74}{c |}
 {col 8}{c |}{col 74}{c |}
 {col 8}{c |}{col 13} twoway scatter gphm weight | lfit gphm weight,  ///{col 74}{c |}
 {col 8}{c |}{col 13}    ytitle(Gallons per 100 Miles) legend(off){col 74}{c |}
 {col 8}{c |}{col 13} graph export auto.png, width(500) replace{col 74}{c |}
 {col 8}{c |}{col 74}{c |}
 {col 8}{c |} ![Fuel Efficiency by Weight](auto.png){col 74}{c |}
 {col 8}{c |}{col 74}{c |}
 {col 8}{c |} The regression equation estimated by OLS is{col 74}{c |}
 {col 8}{c |}{col 74}{c |}
 {col 8}{c |}{col 13} regress gphm weight{col 74}{c |}
 {col 8}{c |}{col 74}{c |}
 {col 8}{c |} Thus, a car that weighs 1,000 pounds more than another requires{col 74}{c |}
 {col 8}{c |} on average an extra 1.4 gallons to travel 100 miles.{col 74}{c |}
 {col 8}{c |}{col 74}{c |}
 {col 8}{c |} That's all for now!{col 74}{c |}
 {col 8}{c BLC}{hline 65}{c BRC}
{smcl}

{pstd}
Saving this code as {bf:auto.stmd} and running the command
{bf: markstat using auto} produces the web page shown at
{browse "http://data.princeton.edu/stata/markdown/auto"}. 
Adding the option {opt pdf} generates a PDF file, 
and {opt docx} generates a Word document, all from the same script.
See also {help markstat##presentations:presentations} below.

{title:Requirements}

{pstd}
The command uses an external Markdown processor, 
John MacFarlane's {cmd: pandoc},
which can be downloaded for Linux, Mac or Windows from
{browse "http://pandoc.org/installing"}.  Generating Word
documents requires Pandoc 2.0 or higher.

{pstd}
It also requires the Stata command {cmd:whereis}, available from SSC.
This command is used to keep track of ancillary programs and is usually 
installed together with {cmd: markstat}.
After downloading {cmd:pandoc}, you save the location of the 
executable in the {it:whereis} database by running the command
{cmd: whereis pandoc} {it:location}.

{pstd}
If you want to generate PDF output you also need LaTeX, specifically
{cmd: pdflatex}, which comes with MiKTeX on Windows, MacTeX 
on Macs or Live TeX on Linux. You save the  location of the converter 
by running the command {cmd: whereis pdflatex} {it:location}.
This is also used for Beamer presentations.

{pstd}
To properly render Stata logs in PDF format you also need the
LaTeX package {cmd: stata.sty} available from the Stata Journal.
The Stata command {cmd:sjlatex} will install all journal files, but 
we only need this one. I suggest you download if from
{bf:http://www.stata-journal.com/production/sjlatex/stata.sty},
copy it in your local textmf folder and update the TeX database.
Note also that {bf:stata.sty} requires alttt.sty and 
pstricks.sty; these packages are available in most TeX distributions.

{pstd}
For server installations these tooling steps are usually completed 
by a system administrator.

{title:Markdown Code}

{pstd}
Markdown is a lightweight markup language invented by John Gruber.
It is easy to write and, more importantly, it was designed to be
easy to read, without intrusive markings. See {it: Markdown: Basics}
at {browse "http://daringfireball.net/projects/markdown/basics"}
for a quick introduction.

{pstd}
Our example uses only two Markdown features: the use of dashes as
underlining to create a heading at level 2, and the construction
{bf:![alt-text](source)} to create a link to an image given a
title(alt-text) and a source, in our case
{bf:![Fuel Efficiency by Weight](auto.png)}. 
You may use italics, bold and monospace fonts, create
numbered and bulleted lists, insert links, and much more.

{pstd}
Pandoc implements several extensions to Markdown, including metadata, 
basic tables, and pipe tables. It also lets you incorporate inline and
display mathematical equations using LaTeX notation. See John MacFarlane's 
{it:User's Guide} at {browse "http://pandoc.org/MANUAL.html"}
for more information.
 
{title:Stata Code}{marker strict}

{pstd}
The simple indentation rule using one tab or four spaces for Stata code
permits clean input, but precludes some advanced Markdown options, including 
multi-paragraph and nested lists. An alternative is to use the strict syntax,
where code appears in fenced blocks. This syntax is activated by the {opt strict}
option, or set automatically if you use code fences in the first 50 lines of 
your script. In strict mode Stata code goes in blocks like this:

{col 8}```s
{col 8}     // Stata commands go here
{col 8}```

{pstd}
The opening fence may also be coded as {bf:```{c -(}s{c )-}}, with the {bf:s} in
braces. The closing fence is always {bf:```}.

{pstd} 
There is also an option to supress echoing Stata commands in  a strict 
code block, which is indicated by appending a slash to the {bf:s},
so the opening fence is either {bf:```s/} or optionally {bf:```{c -(}s/{c )-}}.
This feature may be useful in producing dynamic documents
where the code itself is of secondary interest.

{pstd}
You may also use inline code to quote Stata results using the syntax

{col 8}`s [fmt] {it:expression}`

{pstd}
where {bf:[fmt]} is an optional format. For example after a regression you may 
retrieve the value of R-squared using {bf:`s e(r2)`}, or 
using {bf:`s %5.2f e(r2)`}  to print the value with just two decimals.  

{pstd}
Inline code is intended for short text, and cannot span more than one line.
The {cmd:markstat} command uses Stata's {cmd:display} command to evaluate
the code, and retrieves only one line of output to be spliced with the text.
The expression may contain macro evaluations and/or compound quotes.

{title:Mata Code}

{pstd}
Stata code can always use {cmd: mata:} to enter Mata and {cmd: end} to exit,
but {cmd: markstat} also allows coding Mata blocks directly, using an {bf: m} 
instead of an {bf: s} in the code fence:

{col 8}```m
{col 8}     // Mata code goes here
{col 8}```

{pstd}
The fence may include optional braces as before, and the code may be supressed 
by appending a slash to the {bf: m}, although this is rare.

{pstd}
Mata results may also be displayed inline using the syntax

{col 8}`m [fmt] {it:expression}`

{pstd}
which is identical to inline Stata but with an {bf: m} instead of an {bf: s}.

{title:R Code}

{pstd}
R code can be included in fenced code blocks using an {bf: r} instead of an {bf:s} 
or {bf:m}:

{col 8}```r
{col 8}     # R code goes here
{col 8}```

{pstd}
The fence may include optional braces as before, and the code may be supressed 
by appending a slash to the {bf: r}. Of course for the code to run you need to
have R installed. You also need to register the location of the R executable
using {cmd:whereis}. 

{pstd}
R results may also be displayed inline using the syntax

{col 8}`r {it:expression}`

{pstd}
which is just like inline Stata or Mata but with an {bf: r} instead of an {bf: s}
or {bf:m} and no format (use R's {bf:round()} instead).

{title:Metadata}

{pstd}
A script may include the title, author and date as metadata at the top of the
document in three lines starting with {bf:%}. Our example could have started

{col 8}% Markstat 2.0
{col 8}% Germán Rodríguez
{col 8}% 31 October 2017

{pstd}
The data field may use inline code {bf:`s c(current_date)`} to get the date from Stata.
Metadata can also be entered using YAML blocks, as explained in the 
{help markstat##website:website} linked at the end.

{title:Presentations}{marker presentations}

{pstd}
A slide show using S5 or Beamer {it:must} start with a metadata block
providing the title, author and date of the presentation, followed by
Stata and Markdown code using the simple or strict syntax.  A simple example 
may be found in the {help markstat##website:website} listed at the bottom.

{pstd}
In a simple presentation, each heading at level 1 defines a slide and
is followed by contents, usually bullet points, figures and tables,
generated using Stata. In a multipart presentation, level-1 headings define
parts and generate title slides, and level-2 headings define slides.
Pandoc figures out the slide level looking for the highest level heading 
followed immediately by contents.

{pstd}
When you create a presentation you include figures using the Markdown syntax
{bf: ![title](source){c -(}width="60%"{c )-}}. I recommend you always specify 
a relative size as shown in this example. If you are using Beamer, add
{bf: {c -(}.fragile{c )-}} to the heading of slides that contain Stata
commands or output (or any verbatim content).  


{title:Citations}{marker citations}

{pstd}
Thanks to the amazing Pandoc, {cmd:markstat} also supports bibliographic
references. In addition to the {opt bib:liography} option, the document
must include a YAML block with the name of the BibTeX database,
and may optionally include a reference to a citation style to use
instead of the default Chicago author-date format.
For more information and examples, see the {help markstat##website:website} linked below.

{title:Website}{marker website}

{pstd}
For more detailed information, including documentation, examples,
and answers to frequently asked questions, please visit
{browse "http://data.princeton.edu/stata/markdown"}.

{title:Author}

{pstd}
Germ{c a'}n Rodr{c i'}guez <grodri@princeton.edu>
{browse "http://data.princeton.edu":data.princeton.edu}.

