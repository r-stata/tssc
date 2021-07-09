{smcl}

{title:Title}

{phang}
{bf:putdocxcrosstab} {hline 2} Produces count twoway tables with putdocx.

{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmdab:putdocxcrosstab} {varlist} [if], [noROWSum] [noCOLsum] [MIssing]

{marker description}
{title:Description}

{pstd}
{putdocxcrosstab} produces a twoway crosstabulation of the two variables in {varlist}. 

{title:Syntax}
{phang}{varlist} must contain two variables{p_end}
{phang}Options:{p_end}
{phang}noROWSum : drops the last column containing row sums{p_end}
{phang}noCOLsum : drops the last row containing column sums{p_end}
{phang}MIssing  : includes missing values{p_end}
{phang}row  : gives percentages by row{p_end}
{phang}col  : gives percentages by column{p_end}
{phang}pformat  : numeric format for percentages{p_end}

{marker example}
{title:Example}

{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. egen pricecat = cut(price), at(0,5000,10000,999999) label}{p_end}
{phang}{cmd:. label variable pricecat "Price (categorical)"}{p_end}
{phang}{cmd:. tab pricecat}{p_end}
{phang}. // Start putdocx, enter contextual information. {p_end}
{phang}{cmd:. capture putdocx clear}{p_end}
{phang}{cmd:. putdocx begin}{p_end}
{phang}{cmd:. putdocx paragraph, style(Title)}{p_end}
{phang}{cmd:. putdocx text ("Demonstration Title")}{p_end}
{phang}{cmd:. putdocx paragraph, style(Subtitle)}{p_end}
{phang}{cmd:. putdocx text ("Demonstration Produced `c(current_date)'")}{p_end}
{phang}{cmd:. putdocx paragraph}{p_end}
{phang}{cmd:. putdocx text ("Following this paragraph will be a one-way frequency tabulation of price by categories.")}{p_end}

{phang}. // Demonstrate putdocxcrosstab. {p_end}
{phang}{cmd:. putdocxcrosstab pricecat foreign}{p_end}

{phang}{cmd:. putdocx save "putdocxcrosstab.docx"}{p_end}

{marker author}
{title:Author}

{phang}     Jan Brogger{p_end}
{phang}     {browse "https://github.com/janbrogger/putdocxcrosstab"}{p_end}
