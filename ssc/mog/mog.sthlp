{smcl}
{* *! version 1.2.8  26jun2009}{...}
{cmd:help mog}
{hline}

{title:Title}

{p 4 11 4}{cmd: mog }{hline 2} Produce one way or two way tables of means (or totals) and perform significance tests and quality control checks{p_end}

{title:Syntax}

{p 4 4 4}{cmd:mog} {it:{help varname:varname1}} {it:{help varname:varname2}} [{it:{help varname:varname3}}] {ifin} {weight} [{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model}
{synopt: {opt tot:al}}changes the command to estimate totals and not means{p_end}

{syntab :SE/Cluster}
{synopt: {opt su:rvey}}mog will use svyset information for variance estimation and weighting{p_end}

{syntab :Reporting{hline 2}estimates}
{synopt: {opt d:ecimals(#)}}number of decimals of estimates, default is 2{p_end}
{synopt: {opt round:(#)}}estimates will be rounded to multiples of this number (see {help round} function), default is 0{hline 2}no rounding{p_end}

{syntab :Reporting{hline 2}significance tests}
{synopt: {opt ref1:(#)}}specifies the reference group to use for varname2, default is 1{p_end}
{synopt: {opt ref2:(#)}}specifies the reference group to use for varname3, default is 1{p_end}
{synopt: {opt sl:(#)}}controls the significance level of tests, default is 0.05{p_end}
{synopt: {opt ret:est}}instructs mog to use estimates from last run{p_end}
{synopt: {opt notest:}}suppresses the insertion of significance test symbols in the table{p_end}
{synopt: {opt F:wer}}display information on the family-wise error rate{p_end}

{syntab :Reporting{hline 2}quality controls}
{synopt: {opt pubs:tand}}show quality control symbols for each estimate{p_end}
{synopt: {opt pubd:ichot}}use more conservative quality controls if varname1 is dichotomous{p_end}
{synopt: {opt minc:ount(#)}}minimum sample size of each estimate, default is 15{p_end}
{synopt: {opth symbm:incount(string)}}symbol that indicates the sample size is too low for an estimate, see mincount, default is "X"{p_end}
{synopt: {opt cvw:arning(#)}}an estimate is "use with caution" grade if its cv is larger than this value and less than cvtoohigh, default is 1/6th{p_end}
{synopt: {opth symbw:arning(string)}}symbol used to indicate an estimate falls in the situation described in option cvwarning, default is "E"{p_end}
{synopt: {opt cvt:oohigh(#)}}an estimate is "too unreliable to use" grade if its cv is larger than this value, default is 1/3rd{p_end}
{synopt: {opth symbt:oohigh(string)}}symbol used to indicate an estimate falls in the situation described in option cvtoohigh, default is "F"{p_end}
	
{syntab :Reporting{hline 2}miscellaneous}
{synopt: {opt nod:etail}}displays only the table{p_end}
{synopt: {opt cellw:idth(#)}}controls the width of table cells{p_end}
{synopt: {opt varw:idth(#)}}controls the width of the first column displaying varname2 labels, default is 15{p_end}
{synopt: {opt u:nderscores}}replaces spaces with underscores in labels{hline 2}helps when copying data{p_end}
{synoptline}
{p 4 6 4}{it:{help varname:varname1}} is the variable for which you want to estimate means.{p_end}
{p 4 6 4}{it:{help varname:varname2}} is a categorical variable over which the means are grouped, creating a one way table.{p_end}
{p 4 6 4}{it:{help varname:varname3}} is an optional 2nd categorical variable over which the means are also grouped, creating a two way table.{p_end}
{p 4 6 4}The {cmd: svy} prefix is not allowed. Use option survey instead.{p_end}
{p 4 6 4}All weight types are allowed; see {help weight}.{p_end}
{p 4 6 4}Weights are not compatible with {opt survey}. If both are used, weight information is ignored.{p_end}
{p 4 6 4}{opt retest} is combatible with changing any reporting option. Useful when estimation is time consuming.{p_end}

{title:Description}

{p 4 4 4}This progam calculates the mean of a variable across
all the combinations of categories of up to two other categorical variables
(the grouping variables) and produces a one or two way table showing the means.
It is essentially a "front-end" for the mean and total commands.

{p 4 4 4}Tests to calculate if there are significant differences from
each cell's estimate and the reference category are performed. Symbols are
placed in the table to indicate the results of the tests. 

{p 4 4 4}{cmd: mog} also performs quality control tests on the sample sizes 
and coefficients of variation (1/t-ratio)
of each estimate. Symbols are placed in the table to indicate if any of these
checks have failed. 

{p 4 4 4}Copy the fixed width tables into a spreadsheet using COPY TABLE. The
underscore option helps copying tables that have labels with spaces.

{p 4 4 4}The command will redisplay the table if it is entered without
arguments, as do many stata commands.

{title:Options}

{phang}
{opt ref1} and {opt ref2} change the reference groups for the grouping
variables varname2 and varname3. Note, do not put in the actual value of the 
the variable, put in the integer that represents the ordinal
rank of the category you want. For instance, if the grouping
variable has values 1, 4, 5.5 and 6, then, if you want the second
category to be the reference group, type in {opt ref1}=2, NOT {opt ref1}=4. Similarly,
if you want the category with value 5.5 to be the
reference group, then type in {opt ref1}=3 (because it is the 3rd
category when they are sorted), NOT {opt ref1}=5.5.

{phang}
{opt round} specifies where the estimate should be 
rounded. Use numbers that work with the {help round} function. Note
that even if a number is rounded to an order of 10, it may
still be displayed to the number of decimals specified
by the {opt decimal} option.

{phang}
{opt sl} specifies the significance level to be used for the
tests. Tests are two-tailed t-tests. Default is 0.05. Other possibilities 
inlcude 0.01, 0.10, and 0.20. The program will function with 
any number between 0 and 1.

{phang}
{opt mincount} specifies the minimum sample size number to
check for when searching through the number of observations for
each cell in the table. All counts are displayed in a table
at the beginning of the output when the program runs. However, {cmd: mog}
checks each value to ensure it is equal to or larger than {opt mincount}. If
it isn't, a warning is displayed. If any cell count is less
than 2, the program terminates as no variance can be estimated
for this estimate. Institutional (company, government body, etc.)
guidelines often require a minimum sample size for an estimate
to be published and made available for public use, and preclude 
the possibility of anyone (if
the observations are people) to be identifiable. The default 
is 15.

{phang}
{opt cellwidth} allows the user to change the number of columns taken
up by each cell. Cell widths are automatically sized to the estimates
size, the number of decimal places and the number of symbols. However, 
one may wish to increase this number in some cases to allow the column
labels to be fully displayed.

{phang}
{opt underscore} replaces spaces, " ", in the value labels of the
grouping variables with underscores, "_". This ensures that the 
copying process of this table to another program will recognize
the columns properly. The default is to NOT make the replacement.

{phang}
{opt nodetail} makes {cmd: mog} run without displaying any preliminary
checks, estimation output, or test results. Only the final table will
be displayed. This is useful to cut back on the amount of output
shown when you have already checked the details and you wish to
tweak other options.  Also useful with the {opt retest} option.
The default is to show the details.

{phang}
{opt retest} reruns {cmd: mog} again, checking to ensure that
the same underlying estimation just performed is being requested again, 
that is, varname1 to varname3 are the same, if and in statements, 
and the same weight or {opt survey} option, and {opt total} option.
However, when it is rerun, the command that perfoms the estimation
will not execute, often saving a lot of time if it uses variance estimation
with bootstrap weights. All reporting options are
changable, such as the reference group for testing ({opt ref1} and {opt ref2}), the significance 
level of the tests ({opt sl}), and formatting options like {opt decimals}, {opt cellwidth}
and {opt underscores}. The default is not to retest. Note: although the estimation 
command {cmd: mean} (or {cmd: total}) is not
rerun, the estimation results from the last {cmd: mog} command must be
the active estimation results in memory. This includes both the estimation
results saved in {cmd: e()}, and {cmd: mog} results saved in {cmd: r()}.

{phang}
{opt survey} tells {cmd: mog} to use the information entered
in the {opt svyset} command regarding the details of the survey design.
The {opt survey} option will over-ride any weights specified. Use one or the other, not both.
The default is not to use the svyset information. It is operationalized
by running the estimation command ({opt mean} or {opt total}) with the svy prefix.

{phang}
{opt fwer} computes the family-wise error rate, based
on each tests p-value in the series of tests for the categories of a grouping variable. 
This may be useful when considering the error rates resulting from useage by a diverse, independent
audience who tend to pick and choose what information they need.
It provides a sense of the overall
error rate for the set of tests in this context.
The default is not to make the calculations.
Not to be confused with joint tests of significance when a set of test results are
used together to develop a conclusion, see {help test} for information
on joint testing and associated adjustments used in multiple tests 
(like bonferonni, sidak, etc.). Use {help test} 
after {cmd: mog} to conduct joint tests, if desired.
The family-wise error rate, the probability
that at least one test in a series of independently used tests is incorrectly rejecting the null.
Formula: 1 - (1-pvalue_1)*...*(1-pvalue_i)*...*(1-pvalue_n)
, i subscripts tests and n is the number of tests.

{phang}
{opt pubstand} will place symbols in the 
table that indicate if an estimate has not passed confidentiality
and reliability standards. Estimates with cell counts less than {opt mincount} will have the
symbol X (changable using using {opt symbmincount}) placed
to their right. Estimates with coefficients of variation (1/t-ratio) greater than
{opt cvtoohigh} will have
an F placed to their right.  Estimates with cvs between {opt cvwarning}
and {opt cvtoohigh} will have an
E placed to their right. Symbols are changeable with {opt symbwarning} and {opt symbtoohigh}. 
There can be an X, E, an F, or neither, but
never more than one. F and E are mutually exclusive. X replaces E and F.

{phang}
{opt pubdichot}. For dichotomous dependent variables for varname1, for instance, indicator
variables showing if an observation has a particular
characteristic, the pubdichot option may be used to
further slice the samples. They are further sliced by not just the grouping
variables, but also the dependent variable, varname1.  This may be
a requirement of your institutional quality assurance
guidelines for total and proportion estimates.
One example is the total number of people who are disabled, by age 
category and sex. If only using the {opt pubstand} option, just the sample sizes 
in a tabulation by age and sex would be checked against {opt mincount} 
for a minium sample size. This may be acceptable for continuous
dependent variables. However for estimating
totals, when there are rare events where maybe only 2 people are 
disabled in a particular category, it is this number, and the 
number not disabled, that are checked individually against {opt mincount}, instead of
the sum of the two (representing the overall sample size of the cell).

{title:Examples}
{hline}
{pstd}Setup{p_end}
{phang2}{cmd:. use auto}{p_end}

{pstd}Estimate the mean of weight over foreign{p_end}
{phang2}{cmd:. mog weight foreign}{p_end}

{pstd}With rounding and no decimals{p_end}
{phang2}{cmd:. mog weight foreign, dec(0) round(100)}{p_end}

{pstd}Recode rep78{p_end}
{phang2}{cmd:. recode rep78 (1/3=3 "Good") (4=4 "Very Good") (5=5 "Exceptionally Good"), gen(rep78new)}{p_end}

{pstd}Now estimate means by foreign and rep78new{p_end}
{phang2}{cmd:. mog weight foreign rep78new, dec(0) round(100)}{p_end}

{pstd}Suppress details with {opt nodetail}{p_end}
{phang2}{cmd:. mog weight foreign rep78new, dec(0) round(100) nodetail}{p_end}

{pstd}Change the reference group for varname2 (rep78new) to the 3rd category{p_end}
{phang2}{cmd:. mog weight foreign rep78new, dec(0) round(100) nodetail ref2(3)}{p_end}

{pstd}Perform quality control checks{p_end}
{phang2}{cmd:. mog weight foreign rep78new, dec(0) round(100) nodetail ref2(3) pubstand}{p_end}

{pstd}Change minimum sample size per estimate to 5{p_end}
{phang2}{cmd:. mog weight foreign rep78new, dec(0) round(100) nodetail ref2(3) pubstand mincount(5)}{p_end}

{pstd}Increase the cellwidth to see all rep78new labels{p_end}
{phang2}{cmd:. mog weight foreign rep78new, dec(0) round(100) nodetail ref2(3) pubstand mincount(5) cellwidth(15)}{p_end}

{pstd}Insert underscores to aid in pasting to a spreadsheet (use copy table option in Edit or shortcut menu){p_end}
{phang2}{cmd:. mog weight foreign rep78new, dec(0) round(100) nodetail ref2(3) pubstand mincount(5) cellwidth(15) und}{p_end}

{pstd}Do not perform significance tests{p_end}
{phang2}{cmd:. mog weight foreign rep78new, dec(0) round(100) nodetail ref2(3) pubstand mincount(5) cellwidth(15) und notest}{p_end}

{pstd}Show only formatted numbers{p_end}
{phang2}{cmd:. mog weight foreign rep78new, dec(0) round(100) nodetail notest}{p_end}
{hline}
{pstd}Setup{p_end}
{phang2}{cmd:. use auto}{p_end}

{pstd}Make a dummay variable to indicate foreign cars{p_end}
{phang2}{cmd:. xi i.foreign}{p_end}

{pstd}Recode rep78{p_end}
{phang2}{cmd:. recode rep78 (1/3=3), gen(rep78new)}{p_end}

{pstd}Estimate the total of weight over foreign and rep78new{p_end}
{phang2}{cmd:. mog weight foreign rep78new, total dec(0)}{p_end}

{pstd}Estimate the total of foreign over rep78new{p_end}
{phang2}{cmd:. mog _Iforeign_1 rep78new, total dec(0)}{p_end}
{hline}

{title:Saved results}

{pstd}{cmd:mog} saves estimation results in {cmd:e()}. See {help mean} or {help total}
for details on what is saved by the respective estimation commands.

{pstd}{cmd:mog} saves one result in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmdtext)}}command as typed{p_end}

{title:Author}

{p 4 4 4}Matt Hurst{p_end}
{p 4 4 4}Statistics Canada{p_end}
{p 4 4 4}matt.hurst@statcan.gc.ca{p_end}
{p 4 4 4}Last revision: December 9, 2010{p_end}

{title:Also see}

{psee}
Manual:  {manlink R mean}; 
{manlink R total}
{p_end}

{psee}
{space 2}Help:  {manhelp mean R}, {manhelp mean_postestimation R:mean postestimation};{break}
{manhelp summarize R},
{manhelp total R},
{manhelp tabulate R},
{manhelp test R}
{p_end}
