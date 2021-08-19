{smcl}

{marker title}{...}
{title:Title}

{p 4 4 2}
LaTeX mathematical notations are popular, but they are not siupported in HTML 
format. 
{help Weaver} package uses {browse "http://docs.mathjax.org/en/latest/":MathJax} 
JavaScript to render LaTeX Mathematical notations in the HTML dynamic document. 
You can read more about rendering LaTeX notations in HTML in the link below.
 
{p 4 4 2}
{c 149} {browse "http://docs.mathjax.org/en/latest/tex.html#tex-and-latex-in-html-documents":MathJax LaTeX Math Documentation}


{title:Writing mathematical notations}

{p 4 4 2}
To write LaTeX mathematical notations in {help Weaver} log (in both HTML ot LaTeX), 
the notation must be written in {bf:{help txt}} 
command which is in charge of writing text in Weaver log. The mathematical notation 
also must be separated from the rest of the text. If the notation is meant to 
be rendered within the text paragraph, it must being with "{bf:\(}" and end with "{bf:\)}". 
In order to render the notations on a separate line, 
in the center of the document, The notation should begin with "{bf:\[}" and end with "{bf:\]}"

{p 4 4 2}
Note that for writing mathematical notations in the LaTeX log, the single "{bf:$}" 
and double "{bf:$$}" can also be used for generating inline and centered notations 
respectively. {bf:Writing notations with dollar sign in the HTML log can damage the document} 

{synoptset 24}{...}
{marker mathnotation}
{p2col:{it:Markup}}Description{p_end}
{synoptline}

{synopt :{bf: \( } LaTeX notation {bf: \)}}render mathematical notation within text paragraph {p_end}
{synopt :{bf: \[} LaTeX notation {bf: \]}}render mathematical notation in the center of a separate line {p_end}

{synoptline}
{p2colreset}{...}


{marker example}{...}
{title:Example of mathematical notations}

{pstd}
You want to write the formula of a simple linear regression with a single predictor and you want to 
discuss it within the text paragraph, using {bf:LaTeX} mathematical markup notation, this 
formula will be rendered identically in both HTML and LaTeX log files: 

{phang2}{cmd:. txt \( \widehat{\mu} (x) = \beta{_0} + \beta{_1} x \)}{p_end}

{pstd}
and to render the same notation in the center of the document, on a separate line, type:

{phang2}{cmd:. txt \[ \widehat{\mu} (x) = \beta{_0} + \beta{_1} x \]}{p_end}


{title:Related Packages}

{psee}
{space 0}{bf:{help Weaver}} : Creating HTML and PDF dynamic documents



