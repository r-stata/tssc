{smcl}

{title:Title}

{phang}
{bf:smrfmn} {hline 2} Produces table of summary statistics filtered by one or more indicator variables in an active docx using putdocx.

{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmdab:smrfmn} [varname] [{varlist}], desc("Optional descriptive table title")

{p 8 17 2} Where [varname] is a continous variable and [{varlist}] is one or more indicator variables.

{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt noc:ond}}Suppress output of {it:if} and {it:in} conditionals. Default behavior is to note each table with {it:if} and {it:in} conditionals applied.{p_end}
{synopt:{opt desc:ription}}Provide a description for output. Default behavior is to provide a generic description.{p_end}
{synopt:{opt ti:tle}}Provide a title for output. Default behavior is to provide a generic title.{p_end}

{marker description}
{title:Description}

{pstd}
{cmd:smrfmn} produces a table of summary statistics filtered by one or more indicator variables. For each dummy/indicator variable {cmd:smrfmn} will generate a table row of statistics filtered by that indicator. {cmd:smrfmn} places the indicator variable label (or variable name) in column one, the number of observations where the indicator is equal to 1 in column two, the mean meadian and standard deviation in column three, the 25th and 75th percential in column four, the trimmed mean, median, and standard deviation in column five, and the overall minumum and maximum in column six.

{pstd}
When an if or in condition is specified {cmd:smrtbl} will report that condition in the putdocx.

{marker example}
{title:Example}

{phang}{cmd:. use http://www.stata-press.com/data/r15/nlswork.dta}{p_end}

{phang}. // Generate indicator variables and interactions. {p_end}
{phang}{cmd:. tab race, gen(race_ind)}{p_end}
{phang}{cmd:. tab collgrad, gen(col_ind)}{p_end}
{phang}{cmd:. gen white_grad = (race_ind1 == 1 & col_ind2 == 1)}{p_end}
{phang}{cmd:. gen black_grad = (race_ind2 == 1 & col_ind2 == 1)}{p_end}
{phang}{cmd:. gen other_grad = (race_ind3 == 1 & col_ind2 == 1)}{p_end}
{phang}{cmd:. label variable white_grad "race==white & grad == true"}{p_end}
{phang}{cmd:. label variable black_grad "race==black & grad == true"}{p_end}
{phang}{cmd:. label variable other_grad "race==other & grad == true"}{p_end}

{phang}. // Start putdocx, enter contextual information. {p_end}
{phang}{cmd:. capture putdocx clear}{p_end}
{phang}{cmd:. putdocx begin}{p_end}
{phang}{cmd:. putdocx paragraph, style(Title)}{p_end}
{phang}{cmd:. putdocx text ("Demonstration Title")}{p_end}
{phang}{cmd:. putdocx paragraph, style(Subtitle)}{p_end}
{phang}{cmd:. putdocx text ("Demonstration Produced `c(current_date)'")}{p_end}
{phang}{cmd:. putdocx paragraph}{p_end}
{phang}{cmd:. putdocx text ("The following is a tabulation of age summary statistics filtered by selected indicator variables.")}{p_end}

{phang}. // Demonstrate smrfmn. {p_end}
{phang}{cmd:. smrfmn age race_ind1 white_grad race_ind2 black_grad race_ind3 other_grad, desc("Filtered descriptives of age.")}{p_end}

{phang}{cmd:. putdocx save "smrfmnDemo.docx"}{p_end}

{marker author}
{title:Author}

{phang}     Adam Ross Nelson{p_end}
{phang}     {browse "https://github.com/adamrossnelson"}{p_end}
