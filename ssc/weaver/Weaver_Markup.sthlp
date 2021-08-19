{smcl}

{marker title}{...}
{title:Title}

{phang}
{cmdab:Weaver Markup} {hline 2} Annotates string in HTML log in {bf:{help weaver}} package


{title:Description}

{p 4 4 2}
Weaver Markup is not a Stata command. It is a JavaScript-based markup language 
written for {help Weaver} package to style text and annotate the dynamic document. 
These markup codes can be
used anywhere in the dynamic document. These markup codes can be used with {help txt}
command or options that specify a title or a description in the HTML log. 
The Weaver markup codes are particularly important 
 for styling dynamic text. visit 
 {browse "http://haghish.com/statistics/stata-blog/reproducible-research/dynamic_documents/additional_markup.php":Weaver Markup}
 for more information. {break} 


{title:Syntax} 
{synoptset 23}{...}
{marker additional}
{p2col:{it:Markup}}Description{p_end}
{synoptline}

{syntab:{ul:Headings}}
{synopt :{bf: *-} txt {bf: -*}}prints a {bf:heading 1} in <h1>txt</h1> html tag {p_end}
{synopt :{bf: *--} txt {bf: --*}}prints a {bf:heading 2} in <h2>txt</h2> html tag {p_end}
{synopt :{bf: *---} txt {bf: ---*}}prints a {bf:heading 3} in <h3>txt</h3> html tag {p_end}
{synopt :{bf: *----} txt {bf: ----*}}prints a {bf:heading 4} in <h4>txt</h4> html tag {p_end}

{syntab:{ul:Text decoration}}
{synopt :{bf: #*} txt {bf: *#}}{bf:undescores} the text by adding <u>txt</u> html tag {p_end}
{synopt :{bf: #_} txt {bf: _#}}makes the text {bf:italic} by adding <em>txt</em> html tag {p_end}
{synopt :{bf: #__} txt {bf: __#}}makes the text {bf:bold} by adding <strong>txt</strong> html tag {p_end}
{synopt :{bf: #___} txt {bf: ___#}}makes the text {bf:italic and bold} by adding <strong><em>txt</em><strong> html tag {p_end}

{syntab:{ul:Page & paragraph break}}
{synopt :{bf: line-break}}breaks the text paragraphs and begins a new paragraph{p_end}
{synopt :{bf: page-break}}breaks the page and begins a new page{p_end}

{syntab:{ul:Text alignment}}
{synopt :{bf: [center]} txt {bf: [#]}}aligns the txt to the center of the page {p_end}
{synopt :{bf: [right]} txt {bf: [#]}}aligns the txt to the right side of the page{p_end}
{synopt :{bf: [mono]} txt {bf: [#]}}prints the text in mono-space font. {p_end}
{synopt :{bf: [box]} txt {bf: [#]}}places the text in a colored box to make it more destinctive from the rest of the document. It can be used for emphesizing a text paragraph or a quotation. {p_end}

{syntab:{ul:Text color}}
{synopt :{bf: [blue]} txt {bf: [#]}}changes the txt color to blue {p_end}
{synopt :{bf: [green]} txt {bf: [#]}}changes the txt color to green {p_end}
{synopt :{bf: [red]} txt {bf: [#]}}changes the txt color to red{p_end}
{synopt :{bf: [purple]} txt {bf: [#]}}changes the txt color to purple {p_end}
{synopt :{bf: [pink]} txt {bf: [#]}}changes the txt color to pink {p_end}
{synopt :{bf: [orange]} txt {bf: [#]}}changes the txt color to orange {p_end}

{syntab:{ul:Text Highlighter}}
{synopt :{bf: [-yellow]} txt {bf: [#]}}changes the txt background color to yellow {p_end}
{synopt :{bf: [-blue]} txt {bf: [#]}}changes the txt background color to blue {p_end}
{synopt :{bf: [-green]} txt {bf: [#]}}changes the txt background color to green {p_end}
{synopt :{bf: [-pink]} txt {bf: [#]}}changes the txt background color to pink {p_end}
{synopt :{bf: [-purple]} txt {bf: [#]}}changes the txt background color to purple {p_end}
{synopt :{bf: [-gray]} txt {bf: [#]}}changes the txt background color to gray {p_end}

{syntab:{ul:Link}}
{synopt :{bf: [-- "}link{bf:" --][- }txt{bf:  -]}}assigns a link to the corresponding txt {p_end}

{synoptline}
{p2colreset}{...}


{marker example}{...}
{title:Example of interactive use}

{pstd}
You want to display a {bf:Heading}, {bf:Subheading}, {bf:subsubheading}, and 
{bf:subsubsubheading} in the HTML log. Use the heading syntax. 

{phang2}{cmd:. txt *- This Is Heading -*}{p_end}
{phang2}{cmd:. txt *-- This Is Subheading --*}{p_end}
{phang2}{cmd:. txt *--- This Is Subsubheading ---*}{p_end}
{phang2}{cmd:. txt *---- This Is Subsubsubheading ----*}{p_end}

{pstd}
You have a local macro representing a {bf:P-Value} and you want to display it as 
{bf:Bold} and highlight it with yellow marker if it is less or equal to 0.05. 

{phang2}{cmd:. if `p' <= 0.05 txt [-yellow] #__`p'__# [#]}


{title:Related Packages}

{psee}
{space 0}{bf:{help Weaver}} : Creating HTML and PDF dynamic documents

{psee}
{space 0}{bf:{help Markdoc}}: Converting SMCL to any format using Pandoc


