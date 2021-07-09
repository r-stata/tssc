{smcl}
{cmd:help katego}
{hline}

{title:Title}

{phang}
{bf:katego} {hline 2} Tool for categorizing continuous variables


{title:Syntax}

{p 8 17 2}
{cmd:katego} {varname} {newvar} {it:instruction}

{pstd}Where {it:varname} is the continuous variable to be categorized, {it:newvar} is the new variable that will contain the categories and {it:instruction} the value intervals that define each category, in statistical notation.


{title:Description}

{pstd}{cmd:katego} is a tool to quickly split a continuous numerical variable in custom categories. For doing the same on categorical or discrete numerical variables, use {help recode}. For splitting a continuous variable in quantiles, use 
{help xtile}.

{pstd}{cmd:katego} creates a new variable and assigns unique values based on the intervals of {it:varname} specified in the instruction. The lowest category will be coded as 0, the next one as 1, the next one as 2, and so on. Both variable 
and value labels are created.

{pstd}In order to work properly, the intervals specified in the instruction must fulfill the following conditions:{break}
- Written using statistical notation, but with spaces instead of commas.{break}
- Separated by spaces.{break}
- Presented in ascending order.{break}
- Specified without overlaps or gaps between them.{p_end}

{pstd}Negative and decimal numbers are allowed in the intervals of the instruction.

{phang2}{ul:Brief explanation about statistical notation of intervals}{break}
- Open intervals, enclosed in parenthesis, {bf:do not} include its endpoints: x==(3,5) means x>3 & x<5{break}
- Closed intervals, enclosed in square brackets, {bf:do} include its endpoints: x==[3,5] means x>=3 & x<=5{break}
- Half-open intervals do include the endpoint marked with square brackets:{p_end}
{p 16 16 2}x==(3,5] means x>3 & x<=5{break}
x==[3,5) means x>=3 & x<5{p_end}

{pstd}{cmd:katego} identifies and includes intervals above the first one and below the last one stated in the instruction. If the creation of only two categories is intended, {bf:min} or {bf:max} can be provided in the instruction to indicate            respectively the minimum or maximum values of {it:varname} in the dataset. Minimum and maximum values are always included in the interval regardless of the symbol used.

{pstd}See examples below for details.{p_end}


{title:Examples}

{pstd}Open the example dataset{p_end}
{phang2}{cmd:. sysuse auto}

{pstd}Describe the continuous variable to be categorized, in this case weight{p_end}
{phang2}{cmd:. summarize weight, detail}

{pstd}Create a new variable called cw3 with three categories: the first one if weight is equal or less than 2500, the second one if weight is greater than 2500 and less that 3600, and the third one if weight is equal or greater than 3600{p_end}
{phang2}{cmd:. katego weight cw3 (2500 3600)}

{pstd}Check the new variable against the original{p_end}
{phang2}{cmd:. tabstat weight, statistics(count min max) by(cw3)}

{pstd}A verbose way to produce the same results of the previous example{p_end}
{phang2}{cmd:. katego weight cw3 [min 2500] (2500 3600) [3600 max]}

{pstd}Create a variable cw4 with four categories of weight: 0 - less than 1990, 1 - equal or greater than 1990 and less than 2500, 2 - equal or greater than 2500 and equal or less than 3600, 3 - greater than 3600{p_end}
{phang2}{cmd:. katego weight cw4 [1990 2500) [2500 3600]}

{pstd}Describe the created variable{p_end}
{phang2}{cmd:. codebook cw4}

{pstd}Create cw2 with two categories of weight using 2000 as a cut point.{p_end}
{phang2}{cmd:. katego weight cw2 [2000 max]}

{pstd}Same result as above{p_end}
{phang2}{cmd:. katego weight cw2 [min 2000)}

{pstd}Same result as above, but without using {cmd:katego}{p_end}
{phang2}{cmd:. generate cw2 = weight>=2000 & weight!=.}{p_end}
{phang2}{cmd:. label variable cw2 "Categories of weight"}{p_end}
{phang2}{cmd:. label define cw2 0 "< 2000" 1 ">= 2000"}{p_end}
{phang2}{cmd:. label values cw2 cw2}{p_end}


{title:Author}

{pstd}
Andres Gonzalez Rangel{break}
MD, MSc Clinical Epidemiology{break}
Instituto para la Evaluación de la Calidad y Atención en Salud - IECAS{break}
Colombia{break}
andres.gonzalez@iecas.org{p_end}


