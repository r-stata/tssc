{smcl}

{title:Title}

{phang}
{bf:smrcol} {hline 2} Produces a table of dummy varaibles and related summary statistics in an active docx using putdocx.

{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmdab:smrcol} [{varlist}] [if] [in] [, options]

{p 8 17 2} Where [{varlist}] is one or more indicator variables.

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
{cmd:smrcol} produces a table of dummy varaibles and related summary statistics. For each dummy/indicator variable {cmd:smrcol} will generate a table row that places the variable label in column one, the count of missing values in column two, the count that equal zero in column three, the count that equal one in column four, and the percent equaling one in column five.

{pstd}
Provides alternate format for displaying indicator variable summary statistics including indicator variable interaction results.

{pstd}
When an if or in condition is specified {cmd:smrtbl} will report that condition in the putdocx.

{marker usecase}
{title:Use Case}

{pstd}
Useful when reporting categorical counts which are not mutually exclusive. For example, a survey might ask "Indicate what degree(s) have you completed (check all that apply)." The results of this question could not be reported with a simple one-way tabulation because many respondents might have completed multiple degrees. 

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
{phang}{cmd:. putdocx text ("The following is a tabulation of race and grad status including selected interactions.")}{p_end}

{phang}. // Demonstrate smrcol. {p_end}
{phang}{cmd:. smrcol race_ind1 white_grad race_ind2 black_grad race_ind3 other_grad, desc("Race and graduate indicator descriptives.")}{p_end}

{phang}{cmd:. putdocx save "smrcolDemo.docx"}{p_end}

{marker author}
{title:Author}

{phang}     Adam Ross Nelson{p_end}
{phang}     {browse "https://github.com/adamrossnelson"}{p_end}
