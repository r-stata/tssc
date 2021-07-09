{smcl}
{* *! version 3.2 2020-04-20}{...}
{hline}
help for {cmd:table1_mc}
{hline}

{title:Title}

{p2colset 5 15 21 2}{...}
{p2col: {bf:table1_mc}}{hline 2} Create "Table 1" of baseline characteristics for a manuscript

{title:Syntax}

{p 8 18 2}
{opt table1_mc} {ifin} {weight}, {opt vars(var_spec)} [{it:options}]

{phang}{it:var_spec} = {it: varname vartype} [{it:{help fmt:%fmt1}} [{it:{help fmt:%fmt2}}]] [ \ {it:varname vartype} [{it:{help fmt:%fmt1}} [{it:{help fmt:%fmt2}}]] \ ...]

{phang}where {it: vartype} is one of:{p_end}
{tab}contn  - continuous, normally distributed  (mean and SD will be reported)
{tab}contln - continuous, log normally distributed (geometric mean and GSD reported)
{tab}conts  - continuous, neither log normally or normally distributed (median and IQR reported)
{tab}cat    - categorical, groups compared using Pearson's chi-squared test
{tab}cate   - categorical, groups compared using Fisher's exact test
{tab}bin    - binary (0/1), groups compared using Pearson's chi-squared test
{tab}bine   - binary (0/1), groups compared using Fisher's exact test

{phang}{opt fweight}s are allowed; see {help weight}


{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:#Columns/Rows}
{synopt:{opt by(varname)}}group observations by {it:varname}, which must be either (i) string, or (ii) numeric and contain only non-negative integers, whether or not a value label is attached{p_end}
{synopt:{opt total(before|after)}}include a total column before/after presenting by group{p_end}
{synopt:{opt one:col}}report categorical variable levels underneath variable name instead of in separate column{p_end}
{synopt:{opt mis:sing}}don't exclude missing values from categorical variables (not binary) {p_end}
{synopt:{opt test}}include column describing the significance test used{p_end}
{synopt:{opt pairwise123}}report pairwise comparisons (unadjusted for multiple comparisons) between first 3 groups, ignoring any missing data{p_end}

{syntab:Contents of Cells}
{synopt:{cmdab:f:ormat(}{it:{help fmt:%fmt}}{cmd:)}}default display format for continuous variables{p_end}
{synopt:{cmdab:percf:ormat(}{it:{help fmt:%fmt}}{cmd:)}}default display format for percentages for categorical/binary vars{p_end}
{synopt:{cmdab:nf:ormat(}{it:{help fmt:%fmt}}{cmd:)}}display format for n and N; default is nformat(%12.0fc){p_end}
{synopt:{opt iqrmiddle("string")}}allows for e.g. median (Q1, Q3) using iqrmiddle(", ") rather than median (Q1-Q3){p_end}
{synopt:{opt sdleft("string")}}allows for e.g. mean±sd using sdleft("±") rather than mean (SD){p_end}
{synopt:{opt sdright("string")}}allows for e.g. mean±sd using sdright("") rather than mean (SD){p_end}
{synopt:{opt gsdleft("string")}}allows for presentation other than: geometric_mean (×/geometric_SD){p_end}
{synopt:{opt gsdright("string")}}allows for presentation other than: geometric_mean (×/geometric_SD){p_end}
{synopt:{opt percsign("string")}}default is percsign("%"); consider percsign(""){p_end}
{synopt:{opt nospace:lowpercent}}report e.g. (3%) instead of the default ( 3%), [the default can look nice if output is right/left justified]{p_end}
{synopt:{opt extraspace}}helps alignment of p-values and ( 3%) in .docx file if non-monospaced datafont (e.g. Calibri - the default) used with the accompanying command {bf:table1_mc_dta2docx}{p_end}
{synopt:{opt percent}}report % rather than n (%) for categorical/binary vars{p_end}
{synopt:{opt percent_n}}report % (n) rather than n (%) for categorical/binary vars{p_end}
{synopt:{opt slashN}}report n/N instead of n for categorical/binary vars {p_end}
{synopt:{opt catrowperc}}report row percentages rather than column percentages for categorical vars (but not binary vars) {p_end}
{synopt:{opt pdp(#)}}max number of decimal places in p-value when p-value < 0.10; default is pdp(3){p_end}
{synopt:{opt gurmeet}}equivalent to specifying:  percformat(%5.1f) percent_n percsign("") iqrmiddle(",") sdleft(" [±") sdright("]") gsdleft(" [×/") gsdright("]") onecol extraspace{p_end}

{syntab:Output}
{synopt:{cmdab:sav:ing(}{it}{help filename}{sf} [, {help import_excel##exportoptions:export_excel_options}{sf}]{cmd:)}}save table to Excel file{p_end}
{synopt:{opt clear}}replace the dataset in memory with the table{p_end}


{title:Description}

{pstd}
{opt table1_mc} generates a "Table 1" of characteristics for a manuscript. Such a table generally
includes a collection of baseline characteristics which may be either continuous or categorical. The
observations are often grouped, with a "p-value" column on the right comparing the characteristics
between groups.{p_end}

{pstd}The {bf:vars} option is required and contains a list of the variable(s) to be included as
rows in the table. Each variable must also have a type specified ({it:contn}, {it:contln}, {it:conts}, {it:cat},
{it:cate}, {it:bin} or {it:bine} - see above). If the observations are grouped using {bf:by()}, a
significance test is performed to compare each characteristic between groups. {it:contln} and {it:contn} variables
are compared using ANOVA (with and without log transformation of positive values respectively),
{it:conts} variables are compared using the Wilcoxon rank-sum (2 groups)
or Kruskal-Wallis (>2 groups) test, {it:cat} and {it:bin} variables are compared using Pearson's
chi-squared test, and {it:cate} and {it:bine} variables are compared using Fisher's exact test.
{bf:pairwise123} reports p-values from applying those same tests between 2 groups.
Specifying the {bf:test} option adds a column to the table describing the test used.{p_end}

{pstd}The display format of each variable in the table depends on the variable type. For a continuous
variable the default display format is the same as that variable's current display format. You can
change the table's default display format of summary statistics for continuous variables using the {bf:format()} option.
 After each variable's type you may
optionally specify a display format to override the table's default by specifying {it:{help fmt:%fmt1}}.
Specification of {it:{help fmt:%fmt2}} also, will affect the display format of IQR/SD/geometric SD.
For categorical/binary variables the default is to
display the column percentage using either 0 or 1 decimal place depending on the total frequency. You
can change this default using the {bf:percformat()} option.{p_end}

{pstd}The geometric SD is equivalent to the multiplicative standard deviation.
The default times-divide symbol is very similar to that proposed by Limpert & Stahel (2011).{p_end}

{pstd}The underlying results table can be (i) saved to an Excel file using the {bf:saving()} option, and/or 
(ii) kept in memory, replacing the original dataset, using the {bf:clear} option, 
and optionally -with Stata 15.1- be saved into a .docx file using the command {help table1_mc_dta2docx:table1_mc_dta2docx}.{p_end}


{title:Remarks}

{pstd}{cmd:table1_mc} is an extension and modification of Phil Clayton's {cmd:table1} command.{p_end}  
{pstd}Other user written commands that do similar things include:{break}
 {cmd:baselinetable} ... very nice, but no p-values. Can use any statistics from summarise, can't report geometric mean and geometric SD.{break}
 {cmd:tabout} ... http://tabout.net.au/docs/home.php{break}
 {cmd:sumtable} ... two stats in two (not one) columns, generally not as flexible, no p-values{break}
 {cmd:partchart} ... quite similar but strangely doesn't seem to express IQR as (Q1-Q3), reporting instead the difference between the two quartiles{break}
 {cmd:tabxml} ... survey data frequencies and/or % for categorical variables, means and SE / CI for continuous variables. To avoid matsum error message: . net install sg100, from(http://www.stata.com/stb/stb47){break}
 {cmd:basetable} ... "can be used for survey analysis". Nice, can do 95% CIs for each group. http://www.bruunisejs.dk/StataHacks/My%20commands/basetable/basetable_demo/{p_end}

{pstd}See also http://blog.stata.com/2017/04/06/creating-excel-tables-with-putexcel-part-3-writing-custom-reports-for-arbitrary-variables/{p_end}


{pstd}While {cmd:table1_mc} does not report an effect size (e.g. differences in means, medians or proportions) & associated 95% CI for a variable when there are 2 or more groups, readers might consider calculating and reporting these also.{p_end}


{title:Examples}

{phang}{sf:. }{stata "sysuse auto, clear"}{p_end}
{phang}{sf:. }{stata "generate much_headroom = (headroom>3)"}{p_end}
{phang}{sf:. }{stata "table1_mc, by(foreign) vars(price conts \ price contln %5.0f %4.2f \ weight contn %5.0f \ rep78 cate \ much_headroom bine)"}{p_end}

{pstd}{sf: To save the resulting table in an .xlsx file and replace the dataset in memory}{break}
{sf:. }{stata `"table1_mc, by(foreign) vars(price conts \ price contln %5.0f %4.2f \ weight contn %5.0f \ rep78 cate \ much_headroom bine) saving("N:\example Table 1.xlsx", replace) clear"'}{p_end}


{pstd}{bf: To save the resulting table in a .docx file [Stata 15.1 required]}{break}
Use the {bf:clear} option of table1_mc together with the command {help table1_mc_dta2docx:table1_mc_dta2docx}:{p_end}
{pstd}{sf:. }{stata "sysuse auto, clear"} {break} 
{sf:. }{stata "preserve"} {break}
{sf:. }{stata "table1_mc, by(foreign) vars(price conts \ weight contn %5.0f \ rep78 cate) extraspace clear"} {break}
{sf:Note the above command used the} {bf:clear} {sf:option} {break}
{sf:. }{stata `"table1_mc_dta2docx using "N:\example Table 1.docx", replace"'} {break}
{sf:. }{stata "restore"} {p_end}



{title:References}

{phang}Limpert E, Stahel WA. Problems with Using the Normal Distribution – and Ways to Improve Quality and Efficiency of Data Analysis. PLoS ONE. 2011;6(7):e21403. doi:10.1371/journal.pone.0021403.{p_end} 
{phang}table1 - Phil Clayton, ANZDATA Registry, Australia.{p_end}


{title:Author}

{p 4 4 2}
Mark Chatfield, The University of Queensland, Australia.{break}
m.chatfield@uq.edu.au{break}
