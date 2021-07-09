{smcl}

{title:Title}

{phang}
{bf:putdocxfreqtable} {hline 2} Produces frequency oneway tables with putdocx.

{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmdab:putdocxfreqtable} {varlist} , [noCUM] [noSUM [PERCDigits(#) [LABLen(#)]]

{marker description}
{title:Description}

{pstd}
{putdocxfreqtable} produces a one-way table when there is one categorical variable in {varlist}. 

{title:Syntax}
{phang}{varlist} must contain one variable{p_end}
{phang}Options:{p_end}
{phang}nocum : drops the cumulative sum in the frequency table {p_end}
{phang}nocum : drops the row sum in the frequency table {p_end}
{phang}PERCDigits : number of digits in percentages. Default 0 {p_end}
{phang}LABLen: maximum length of category labels. Default is no truncation. {p_end}

{marker remarks}
{title:Remarks}
{phang}In the Stata output, category labels are truncated at 32 characters. They are not truncated in the Word document.{p_end}

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

{phang}. // Demonstrate putdocxfreqtable. {p_end}
{phang}{cmd:. putdocxfreqtable pricecat}{p_end}

{phang}{cmd:. putdocx save "putdocxfreqtable.docx"}{p_end}

{marker author}
{title:Author}

{phang}     Jan Brogger{p_end}
{phang}     {browse "https://github.com/janbrogger/putdocxfreqtable"}{p_end}
