{smcl}
{* *! version 1.0 15 Feb 2016}{...}
{viewerjumpto "Syntax" "log2markup##syntax"}{...}
{viewerjumpto "Description" "log2markup##description"}{...}
{viewerjumpto "Markdown" "log2markup##markdown"}{...}
{viewerjumpto "Example, sending Stata log to HTML" "log2markup##examplehtml"}{...}
{viewerjumpto "Example, sending Stata log to LaTex" "log2markup##examplelatex"}{...}
{viewerjumpto "Author" "log2markup##author"}{...}

{title:Title}
{phang}
{bf:log2markup} {hline 2} transform a Stata text log into a markup document

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:log2markup} using [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt using}} logfile to use{p_end}
{synopt:{opt replace}} replace existing markdown file{p_end}
{synopt:{opt log}} direct markdown to result window instead of a file{p_end}
{synopt:{opt extension}} extension to put on the markup modified log file{p_end}
{synopt:{opt codestart}} set your markdown coding for code start, eg 
\begin{stlog} if the document is intended for the Stata Journal{p_end}
{synopt:{opt codeend}} set your markdown coding for code end, eg 
\end{stlog} if the document is intended for the Stata Journal{p_end}
{synopt:{opt samplestart}} set your markdown coding for sample start, eg 
{\smallskip}\begin{stlog} if the document is intended for the Stata Journal{p_end}
{synopt:{opt sampleend}} set your markdown coding for sample end, eg 
\begin{stlog} if the document is intended for the Stata Journal{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:log2markup} extract parts of the text version from the Stata {cmd:log} command and 
transform the logfile into a markup based document with the same name, but 
with extension markup (or otherwise specified in option extension) instead of 
log.{p_end}
{pstd}The author usually uses markdown for writing documents. However other 
users may decide on all sorts of markup languages, eg HTML or LaTex.{break}
The key is that markup of Stata code and Stata output can be set by the 
options.{p_end}
{pstd}So preferences of the author dictates a little digression into markdown.{break}
However others might use eg HTML or LaTex just as easy.{p_end}
{pstd}Markdown is first of all a plain text formatting syntax, a common denominator
of eg html, word and Latex.{p_end}
{pstd}So if it goes in markdown it goes everywhere. This way a markdown document is
base document that easily can be transformed into whatever output is needed.{p_end}
{pstd}{bf:This means easy reuse of text and code.}{break}
At the same time markdown is simple: Easy to read and write.{p_end}
{pstd}And since it is text based it is easy to integrate into log files while 
maintaining readability.{p_end}
{pstd}That said markdown can also be considered limiting by some.{p_end}

{pstd}log2markup produces a markup document based on the log marking described here:{p_end}

{pstd}1. {bf:log2markup is based on the text version from the Stata {cmd:log} command.}{p_end}

{pstd}2. Markdown text blocks are surrounded with {cmd:/***} and {cmd:***/}{p_end}

{pstd}3. Code blocks and markdown text blocks to be ignored are surrounded with 
 {cmd://OFF} and  {cmd://ON} so preparing code and its output can be seen in the log{p_end}

{pstd}4. Comments inside  {cmd:/*} and  {cmd:*/} are ignored in the document so it is also 
possible to keep comments for yourself{p_end}

{pstd}5. Commented code (starting with a {cmd:*} or {cmd://}) are ignored in the output{p_end}

{pstd}6. Code lines as well as their outblocks are marked as markdown code blocks{p_end}

{pstd}7. If a code line is prefixed with  {cmd:/**/} only the code part is used in the 
markdown document{p_end}

{pstd}8. If a code line is prefixed with  {cmd:/***/} only the out put part is used in the 
markdown document. However the output is marked as a code block in the markdown 
document{p_end}

{pstd}9. If a code line is prefixed with  {cmd:/****/} only the code part is used in the 
markdown document, but now the output is inserted as ordinary markdown lines.
Hence output in eg html format can be integreted directly when the markdown 
document is transformed to html. The same goes for Latex{p_end}

{pstd}Most of the code is written in Mata and can be seen in an accompagnying
file: log2markup.mata. 
{p_end}

{pstd}
Besides log2markup there are a set of commands/programs that integrates text 
and output into one document (alfabetic order):
{p_end}

{pstd}
	* {browse "http://www.haghish.com/statistics/stata-blog/reproducible-research/markdoc.php":markdoc}{break}
	* {browse "http://www.stata.com/meeting/italy08/rising_2008.pdf":StatWeave}{break}
	* {browse "http://ideas.repec.org/c/boc/bocode/s457021.html":texdoc}{break}
	* {browse "http://www.haghish.com/statistics/stata-blog/reproducible-research/weaver.php":weaver}{break}
{p_end}

{pstd}
The new command log2markup are in many ways very similar to the above.
It differs from the above commands in following way:
{p_end}

{pstd}
	* texdoc and StatWeave integrates LaTex text with Stata commands and outputs.
  	  However the learning curve for LaTex is quite high. 
	  And worse the writeability and readability of LaTex is bad (the authors opinion)
{p_end}

{pstd}
	* markdoc and and weaver can be based on either of the markup languages 
      markdown, HTML or LaTex or a combination of markdown and one of the other two.
	  The difference to log2markup is that they have integrated the use of CSS, Pandoc
	  and HTML printer into the code.
{p_end}

{marker markdown}{...}
{title:Markdown}
{pstd}The {browse "http://daringfireball.net/projects/markdown/syntax":syntax of markdown} 
is described at 
{browse "http://daringfireball.net/projects/markdown/":John Grubers homepage}.
{p_end}
{pstd}In practice markdown documents are often transformed using eg 
{browse "http://pandoc.org":Pandoc} and so 
{browse "http://pandoc.org/README.html":The Pandoc User Guide} is quite often
necessary if something special has to be accomplished.
{p_end}
{pstd}A homepage giving a quick overview of the markdown syntax is 
{browse "http://www.unexpected-vortices.com/sw/rippledoc/quick-markdown-example.html":here}.
{p_end}
{pstd}Another great source of inspiration on how to use markdown and Pandoc is the 
{browse "http://programminghistorian.org/lessons/sustainable-authorship-in-plain-text-using-pandoc-and-markdown":article by Tenen and Wythoff}
{p_end}

{marker examplehtml}{...}
{title:Example, sending Stata log to HTML}

{phang}{browse "http://www.bruunisejs.dk/StataHacks/My%20commands/log2markup/log2markup_demo/":To see more examples}


{phang}Save the following in a do file and run it to generate a final HTML 
document:

{pstd}

		********************************************************************************
		*** HTML test file *************************************************************
		********************************************************************************

		capture log close
		set linesize 250 // The log should not break output lines
		log using log2markup_test.log, replace

		/***
		<html>
		<head>
		</head>
		<body>
		***/

		/***
		# Document demonstrating the use of log2markup

		Note that html or latex can be inserted as plain text for later transformation.
		***/

		//OFF
		/***
		Text blocks inside `//OFF` and `//ON` is ignored.

		Below is the code for generating the data for the estout table:
		***/
		sysuse auto, clear
		replace price = price / 1000
		replace weight = weight / 1000

		quietly regress price weight mpg
		estimates store m1, title(Model 1)

		generate forXmpg = foreign * mpg

		quietly regress price weight mpg forXmpg foreign
		estimates store m2, title(Model 2)

		label variable foreign "Foreign car type"
		label variable forXmpg "Foreign*Mileage"
		//ON

		/***### A demonstration on integrating Markdown text blocks with Stata commands

		The integration with Stata is demonstrated with an example from the command 
		estout. 

		The output from estout can be written in eg html or Latex. And that will be 
		exploited further below.

		The code leading to the data are hidden in the do file together with a comment 
		between a `//OFF` and a `//ON`. This way the same document keeps all information 
		but only show what is needed.

		If a command is prefixed with `/**/` only the command is shown:
		***/

		/**/estout	*, cells(b(fmt(%9.3f)) se(par))				///
		stats(r2_a N, fmt(%9.3f %9.0g) labels(R-squared))	///
		legend label collabels(none) varlabels(_cons Constant) style(html)

		/*** 
		This the command demonstrating the 2 output examples just below.

		The command prefix `/***/` will make only the output from the command is 
		shown. 

		But then the output will be marked as code, eg surrounded with 
		`<pre><code>` and `</pre></code>` in html.

		Output will look like:
		***/

		/***/estout	*, cells(b(fmt(%9.3f)) se(par))				///
		stats(r2_a N, fmt(%9.3f %9.0g) labels(R-squared))	///
		legend label collabels(none) varlabels(_cons Constant) style(html)

		/***
		When there are no prefix to a command both the command and the output above are
		part of the markdown document.

		The problem above is that the sorrounding html tags here are for code blocks.

		But actually the code tags can be neglected by using the command prefix `/****/` 
		instead.

		Since html and latex can be inserted in markdown. It is at first considered as
		plain text, but when the markdown are changed to html the inserted html becomes
		active.

		Now the table looks like:
		***/

		/*** 
		***output only in pure form *** 
		<table border="1">
		<colgroup>
		<col>
		<col style="background-color:red">
		<col style="background-color:yellow">
		</colgroup>
		***/

		/****/estout	*, cells(b(fmt(%9.3f)) se(par))				///
		stats(r2_a N, fmt(%9.3f %9.0g) labels(R-squared))	///
		legend label collabels(none) varlabels(_cons Constant) style(html)

		/***
		</table>
		***/

		/***
		</body>
		</html>
		***/


		log close
		*** End of logging *************************************************************

		/* Command log2markup converts the log into a markdown document */
		log2markup using log2markup_test.log, replace extension(md)


		/* If Pandoc is installed the following command will generate a html docoment 
		based on the markdown document log2markup_test.md generated by log2markup: */
		shell pandoc -o log2markup_test.html -f markdown -t html log2markup_test.md

		*** End of do file *************************************************************

{marker examplelatex}{...}
{title:Example, sending Stata log to LaTex}

{phang}Save the following in a do file and run it to generate a final LaTex 
document (Example inspired by texdoc documentation):

{pstd}

		********************************************************************************
		*** LaTex test file ************************************************************
		********************************************************************************

		capture log close
		set linesize 250 // The log should not break output lines
		log using ".\output\log2markup tex demo.log", replace

		/*
		This is inspired by the texdoc help file.
		*/
		/***
		% Writing for the Stata Journal
		% Example inspired very much by texdoc documentation

		\documentclass{article}
		\usepackage[article,notstatapress]{sj}
		\usepackage{epsfig}
		\usepackage{stata}
		\usepackage{hyperref}
		\usepackage{shadow}
		\usepackage{natbib}
		\usepackage{chapterbib}
		\bibpunct{(}{)}{;}{a}{}{,}

		\begin{document}

		\section{Exercise 1}
		Open the 1978 Automobile Data and summarize the variables.

		***/

		sysuse auto, clear
		summarize

		/***

		\section{Exercise 2}
		Run a regression of price on milage and weight.

		***/

		regress price mpg weight

		/***
		\section{Exercise 3}
		Draw a scatter plot of price by milage.

		***/

		//OFF
		* part is hidden
		scatter price mpg
		graph export ./output/mygraph.pdf, replace
		graph drop _all
		//ON

		/***
		\begin{center}
		\includegraphics{mygraph.pdf}
		\end{center}

		\bibliographystyle{sj}
		\bibliography{sj}
		%\begin{aboutauthors}
		%Some background information about the author(s).
		%\end{aboutauthors}

		\end{document}
		***/
		log close

		log2markup using ".\output\log2markup tex demo.log", replace extension(tex) ///
			codestart(\begin{stlog}) codeend(\end{stlog}) ///
			samplestart(\begin{stlog}{\smallskip}) sampleend({\smallskip}\end{stlog})


{marker author}{...}
{title:Authors and support}

{phang}{bf:Author:}{break}
 	Niels Henrik Bruun, {break}
	Section for General Practice, {break}
	Dept. Of Public Health, {break}
	Aarhus University
{p_end}
{phang}{bf:Support:} {break}
	{browse "mailto:nhbr@ph.au.dk":nhbr@ph.au.dk}
{p_end}


{title:See Also}

Related Stata commands:

{help log2html}  (if installed)   {stata ssc install log2html} (to install this command)
{help markdoc}   (if installed)   {stata ssc install markdoc} (to install this command)
{help texdoc}    (if installed)   {stata ssc install texdoc} (to install this command)
{help weaver}    (if installed)   {stata ssc install weaver} (to install this command)

And also there are Stata commands for easing up doing tables and graphs in reports:

{help basetable} (if installed)   {stata ssc install bastable} (to install this command)
{help coefplot}  (if installed)   {stata ssc install coefplot} (to install this command)
{help estout}    (if installed)   {stata ssc install estout} (to install this command)
{help mog}       (if installed)   {stata ssc install mog} (to install this command)
{help outreg}    (if installed)   {stata ssc install outreg} (to install this command)
{help outreg2}   (if installed)   {stata ssc install outreg2} (to install this command)
{help sjlog}     (if installed)   {stata ssc install sjlog} (to install this command)
{help table1}    (if installed)   {stata ssc install table1} (to install this command)
{help tabout}    (if installed)   {stata ssc install tabout} (to install this command)
