{smcl}
{right:version 1.1 September, 2014}
{cmd:help Synlight}
{hline}

{title:Title}

{phang}
{bf:synlight} {hline 2} Is a Stata HTML syntax highlighter. It converts {it:smcl} logfile to HTML and highlight Stata syntax.  Visit 
{browse "http://www.stata-blog.com/synlight.php":{bf:Synlight Homepage}}
 for a complete guide on using Synlight package.


{title:Author} 
        {p 4 4 2}E. F. Haghish{break} 
	Center for Medical Biometry and Medical Informatics{break}
	University of Freiburg, Germany{break} 
        {browse haghish@imbi.uni-freiburg.de}{break}
	{browse "http://stata-blog.com/ketchup.php":{it:http://stata-blog.com/ketchup}}{break}


{title:Syntax}

{p 8 17 2}
{cmdab:syn:light}
{it:smclfile}
[{cmd:,} {it:erase replace style(name) title() font(str) cmdfont(str) size() css(str)}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt replace}}replace the {it:htmlfile} if already exists{p_end}
{synopt:{opt erase}}erase the {it:smclfile} after generating the HTML output {p_end}
{synopt:{opt sty:le(name)}}specifies the style theme which can be {opt st:ata}, {opt dar:ing}, {opt mid:night}, {opt sun:set}, {opt imbi}, {opt bl:ackforest}, {opt des:ert}, and {opt cob:alt} {p_end}
{synopt:{opt s:ize(int)}}specifies the font size{p_end}
{synopt:{opt cf:ont(str)}}specifies the font of Stata commands{p_end}
{synopt:{opt f:ont(str)}}specifies the font of Stata outputs{p_end}
{synopt:{opt t:itle(str)}}specify the title of the HTML file{p_end}
{synopt:{opt css(str)}}specify the path to external CSS Style SHeet{p_end}
{synoptline}
{p2colreset}{...}



{title:Description}

{pstd}
{cmd:synlight} is a HTML-based Stata syntax highlighter. It takes a Stata 
{it:smcl} logfile  as input, converts it to HTML, and post-processes the HTML 
file to highlight Stata syntax. The output can be easily copy-pasted into websites/HTML documents.


{title:Options}

{dlgtab:Main}

{phang}
{opt replace} rewrites a new HTML file if already exists.

{phang}
{opt erase} removes the {it:smclfile} after converting it to HTML.

{phang}
{opt sty:le(name)} specifies the theme of the HTML document and also the CSS style sheet for syntax highlighting. The current version of {bf:synlight} provides 8 syntax styles which are {opt st:ata}, {opt dar:ing}, {opt sun:set}, {opt mid:night}, {opt imbi}, {opt bl:ackforest}, {opt des:ert}, and {opt cob:alt}. 

{phang}
{opt s:ize(int)} specifies the font size of the HTML document. The default is 12px. 

{phang}
{opt cf:ont(str)} specifies the font for the Stata command. The default font family for Stata
commands are {bf:"Menlo-Regular"}, {bf:"Monaco"}, {bf:"Courier New"} respectively. If the user's
OS does not support the first font, the latter font will be selected. All fonts are available
for download on {browse "http://www.stata-blog.com/synlight.php":{bf:Synlight Homepage}}. 

{phang}
{opt f:ont(str)} specifies the font for the Stata output. The default font {bf:"Courier New"}. 

{phang}
{opt t:itle(str)} prints the title of the HTML file on the top of the document. 

{phang}
{opt css(str)} links an external CSS style sheet to the document. If an external CSS is used,
{cmd:synlight} will only include CSS files that are essential for maintaining the essential
document which are the fonts, body, and classes of "<code>" and "<div>" tags. Stata codes are classified in {bf:<code class="code">} and Stata outputs are included in {bf:<div class="output">} tag. If the CSS includes similar information, the default basic CSS style will be ignored. In order to specify the file path to the external css, write the full file path or alternatively, the relative file path to the external file ({browse "http://stata-blog.com/packages/synlight/example.php":{it:Click here to see an example}}).



{title:Remarks}


{pstd}
To activate the full power of the {cmd:synlight} package, you should separate the arithmetic operators from one another. For example, in a command such as "{bf:local num =1+1}", only {bf:"local"}, and the digits will be highlighted and "{bf:=}" and "{bf:+}" signs will not highlight.
However, if the command is written as "{bf:local num = 1 + 1}", all arithmetic operators will be 
highlighted. This decision has been made to avoid potential threat of highlighting something in the 
Stata command which is not supposed to be highlighted. 

{pstd}
When a command is nested with a brace (such as loops, etc), although very unlikely, but {bf:do not add any comment after the braces}. The braces should be that last character in the line. Also, 
avoid adding empty lines while using nested braces. The reason is that {cmd:synlight} attempts to
put all lines related to nested braces into the "{bf:<code>}" and empty lines confuse the program. 

{pstd}
If the logfile is closed using "{bf:qui log c}" command, {cmd:synlight} automatically removes it from the end of the HTML file. However, any other command for terminating the logfile will be registered in the HTML file. This code was added to avoid unnecessary command at the end of the
HTML document.

{pstd}
The {bf:imbi} style is named after "The Center for Medical Biometry and Medical Informatics (IMBI)" in University of Freiburg, where learned Stata programming and met amazing colleagues. 


{title:Example}
{pstd}
Only specify the name of the logfile, without the file suffix. 

{phang}{cmd:. synlight {it:smclfile}, replace style(imbi) size(14) cfont(Monaco) font("Lucida Console")}


{title:Also see}

{psee}
{space 0}{bf:{help Weaver}}: Advanced HTML & PDF Dynamic Report producer

{psee}
{space 0}{bf:{help Ketchup}}: Converting SMCL to a modern-looking HTML or PDF using Pandoc

{psee}
{space 0}{bf:{help MarkDoc}}: Converting SMCL to Markdown and other formats using Pandoc


