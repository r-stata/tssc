{smcl}
{smcl}
{marker title}{...}
{title:Title}

{phang}
{cmdab:txt} {hline 2} Prints string and values of scalar expressions or macros 
in dynamic document. By default, the command writes a 
text paragraph. The primary purpose of the command is writing dynamic text to 
interpret analysis results in the dynamic document. This command belongs 
to {help Weaver} package, but it also supports the 
{help MarkDoc} package. The syntax for both packages is similar, but
the {cmdab:txt} command behaves differently based on which package is in use. 
If Weaver log is on, {cmd:txt} functions for Weaver package only. 
This document only describes the {bf:txt} command in Weaver package. For using the 
command in {help MarkDoc} package 
{browse "https://github.com/haghish/MarkDoc/wiki/txt":see the MarkDoc documentation on GitHub wiki}

{marker syntax}{...}
{title:Syntax}

{p 4 4 2}
Prints dynamic text on the Weaver log or smcl log. The {opt c:ode} subcommand 
prints the output "as is" in the dynamic document. 
	
	{cmdab:txt} [{opt c:ode}] [{it:display_directive} [{it:display_directive} [{it:...}]]]

{pstd}where the {it:display_directive} is

	{help weaver_markup:Weaver Markup}
	{cmd:"}{it:double-quoted string}{cmd:"}
{p 8 16 2}{cmd:{c 96}"}{it:compound double-quoted string}{cmd:"{c 39}}{p_end}
	[{help format:{bf:%}{it:fmt}}] [{cmd:=}]{it:{help exp}}
	{cmd:_skip(#)}
	{cmdab:_col:umn:(}{it:#}{cmd:)}
	{cmdab:_n:ewline}[{cmd:(}{it:#}{cmd:)}]
	{cmdab:_d:up:(}{it:#}{cmd:)}
	{cmd:,}
	{cmd:,,}

{marker description}{...}

{title:Description}

{p 4 4 2}
{bf:txt} prints dynamic text i.e. strings and values of scalar expressions or macros in the Weaver or the 
smcl log-file. {cmd:txt} also prints output from the user-written Stata programs. Any of the 
supported markup languages can be used to alter the string and scalar expressions. This command 
is to some extent similar to {cmd:display} command in Stata. For example, 
it can be used to carry out a mathematical calculation by typing {cmd:txt 1+1}. It also 
supports many of the display directives as well. 

{p 4 4 2}
Note that in contrast to the {help display} command that prints the 
{help scalar} unformatted, the {cmd:txt} command uses the default 
{bf:%10.2f} format for displaying the scalar. This feature helps the users avoid 
specifying the format for every scalar, due to popularity of this 
format. However, specifying the format expression can overrule the default format. 
For example:

	{cmd:. scalar num = 10.123}
	{cmd:. txt "The value of the scalar is " %5.1f num}
	
{pstd}
The example above will print the scalar with only 1 decimal number. 
This feature only supports scalar interpretation and does not affect 
the {help macro} contents.    {break}


{title:Display directives}

{pstd}
The supported {it:display_directive}s are used in do-files and programs
to produce formatted output.  The directives are		 

{synoptset 32}
{synopt:{bf:{help weaver_markup:Weaver Markup}}}A simplified markup language for 
	annotating the content of the HTML log{p_end}
			  
{synopt:{cmd:"}{it:double-quoted string}{cmd:"}}displays the string without
              the quotes{p_end}

{synopt:{cmd:{c 96}"}{it:compound double-quoted string}{cmd:"{c 39}}}display the string
              without the outer quotes; allows embedded quotes{p_end}

{synopt:[{cmd:%}{it:fmt}] [{cmd:=}] {cmd:exp}}allows results to be formatted;
         see {bf:{mansection U 12.5FormatsControllinghowdataaredisplayed:[U] 12.5 Formats: Controlling how data are displayed}}.{p_end}

{synopt:{cmd:_skip(}{it:#}{cmd:)}}skips {it:#} columns{p_end}

{synopt:{cmd:_column(}{it:#}{cmd:)}}skips to the {it:#}th column{p_end}

{synopt:{cmd:_newline}}goes to a new line{p_end}

{synopt:{cmd:_newline(}{it:#}{cmd:)}}skips {it:#} lines{p_end}

{synopt:{cmd:_dup(}{it:#}{cmd:)}}repeats the next directive {it:#} times{p_end}
		 
{synopt:{cmd:,}}displays one blank between two directives{p_end}

{synopt:{cmd:,,}}places no blanks between two directives{p_end}
{p2colreset}{...}


{title:Mathematical notations}

{p 4 4 2}
The {bf:txt} command can be used for writing mathematical notations in Weaver 
package, both in HTML and LaTeX log files. Writing mathematical notations in the 
HTML log is made possible by including {bf:MathJax} engine, a JavaScript-based 
engine for rendering LaTeX notations in HTML format. 
To do so, notations should begin with "{bf:\(}" and end with "{bf:\)}" for 
rendering notations within the text and double dollar sign "{bf:$$}" or alternatively, 
the "{bf:\[}" and "{bf:\]}" for rendering 
notations in a separate line. For more information in this 
regard, see {help Weaver_mathematical_notation:mathematical notations} documentation. 

{p 4 4 2}
When Weaver package is running, the {opt c:ode} subcommand appends the dynamic text to the 

{marker examples}{...}
{title:Examples}

{pstd}As a hand calculator:

{phang2}{cmd:. txt 2 * 2}

{pstd}As might be used in do-files and programs:

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. summarize price}{p_end}
{phang2}{cmd:. txt "mean of Price variable is " r(mean) " and SD is " %9.3f r(sd)}{p_end}

{pstd}If the text only includes string and macro, the double quotations can be ignored. 
The {cmd:txt} command will interpret all of the {it:display_directives} and 
scalars as string (so it{c 39}s not recommended):

{phang2}{cmd:. local n 9.9}{p_end}
{phang2}{cmd:. txt Not recommended, but you may also print the value of {c 96}n{c 39} without double quote}{p_end}


{title:Author}

{p 4 4 2}
{bf:E. F. Haghish}       {break}
Center for Medical Biometry and Medical Informatics    {break}
University of Freiburg, Germany    {break}
{it:and}    {break}
Department of Mathematics and Computer Science    {break}
University of Southern Denmark    {break}
haghish@imbi.uni-freiburg.de    {break}

{p 4 4 2}
{browse "www.haghish.com/weaver":Weaver Homepage}           {break}
Package Updates on  {browse "http://www.twitter.com/Haghish":Twitter} 

    {hline}

{p 4 4 2}
This help file was dynamically produced by {help markdoc:MarkDoc Literate Programming package}

