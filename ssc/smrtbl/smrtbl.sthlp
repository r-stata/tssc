{smcl}

{title:Title}

{phang}
{bf:smrtbl} {hline 2} Place a one- or two-way table in an active docx using putdocx.

{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmdab:smrtbl} [{varlist}] [if] [in] [, options]

{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt numl:ab}}Add variable label values to output. This option executes {cmd:numlabel, add} before producing output.{p_end}
{synopt:{opt noc:ond}}Suppress output of {it:if} and {it:in} conditionals. Default behavior is to note each table with {it:if} and {it:in} conditionals applied.{p_end}
{synopt:{opt desc:ription}}Provide a description for output. Default behavior is to provide a generic description.{p_end}
{synopt:{opt ti:tle}}Provide a title for output. Default behavior is to provide a generic title.{p_end}

{marker description}
{title:Description}

{pstd}
{cmd:smrtbl} produces a one-way table when there is one categorical variable in {varlist}. When two categorical variables specified in {varlist}, {cmd:smrtbl} produces a two-way table. This command will also work with categorical variables which remain as string data types; that have not been encoded as integers.

{pstd}
When an if or in condition is specified {cmd:smrtbl} will report that condition in the putdocx.

{marker example}
{title:Example}

{phang}{cmd:. use http://www.stata-press.com/data/r15/nlswork.dta}{p_end}

{phang}. // Start putdocx, enter contextual information. {p_end}
{phang}{cmd:. capture putdocx clear}{p_end}
{phang}{cmd:. putdocx begin}{p_end}
{phang}{cmd:. putdocx paragraph, style(Title)}{p_end}
{phang}{cmd:. putdocx text ("Demonstration Title")}{p_end}
{phang}{cmd:. putdocx paragraph, style(Subtitle)}{p_end}
{phang}{cmd:. putdocx text ("Demonstration Produced `c(current_date)'")}{p_end}
{phang}{cmd:. putdocx paragraph}{p_end}
{phang}{cmd:. putdocx text ("Following this paragraph will be a two-way tabulation of age and race.")}{p_end}

{phang}. // Demonstrate smrtble. {p_end}
{phang}{cmd:. smrtbl age race}{p_end}

{phang}. // Enter additional contextual information. {p_end}
{phang}{cmd:. putdocx paragraph}{p_end}
{phang}{cmd:. putdocx text ("Following this paragraph will be two one-way tabulations of race and then age.")}{p_end}

{phang}. // Demonstrate smrtble. {p_end}
{phang}{cmd:. smrtbl race}{p_end}
{phang}{cmd:. smrtbl age}{p_end}

{phang}{cmd:. putdocx save "smrtblDemo.docx"}{p_end}

{marker author}
{title:Author}

{phang}     Adam Ross Nelson{p_end}
{phang}     {browse "https://github.com/adamrossnelson"}{p_end}
