{smcl}
{* 20aug2016}{...}
{cmd:help ceqgraph progressivity} (beta version; please report bugs) {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqgraph progressivity} {hline 2} Graphs Lorenz curves of pre- and post-fisc income and the concentration curve of post-fisc income with respect to pre-fisc income.

{title:Syntax}

{p 8 11 2}
    {cmd:ceqgraph} {cmdab:pr:ogressivity} {ifin} {weight} [{cmd:,} {it:options}]{break}

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Income concepts}
{synopt :{opth m:arket(varname)}}Market income{p_end}
{synopt :{opth mp:luspensions(varname)}}Market income plus pensions{p_end}
{synopt :{opth c:onsumable(varname)}}Consumable income{p_end}
{synopt :{opth f:inal(varname)}}Final income{p_end}

{syntab:Survey information}
{synopt :{opth hs:ize(varname)}}Number of members in the household
	(should be used when each observation in the data set is a household){p_end}
{synopt :{opth hh:id(varname)}}Unique household identifier variable
	(should be used when each observation in the data set is an individual){p_end}
{synopt :{opth psu(varname)}}Primary sampling unit; can also be set using {help svyset:svyset}{p_end}
{synopt :{opth s:trata(varname)}}Strata (used with complex sampling desings); can also be set using {help svyet:svyset}{p_end}

{syntab:Ignore missing values}
{synopt :{opt ignorem:issing}}Ignore any missing values of income concepts and fiscal interventions

{syntab:Graphing options}
{synopt :{opth scheme(string)}}Set the graph scheme ({stata help scheme}; default is "s1mono"){p_end}
{synopt :{opth path(string)}}The directory to save the graphs in{p_end}
{synopt :{opth graphname(string)}}The prefix of the saved graph names (default is "prog"){p_end}
{synopt :{it:{help twoway_options}}}Any options documented in
   {bind:{bf:[G] {it:twoway_options}}}{p_end}
   
{syntab:Export directly to CEQ Master Workbook (requires Stata 14.1 or newer)}
{synopt :{opth coun:try(string)}}Country{p_end}
{synopt :{opth surv:eyyear(string)}}Year of survey{p_end}
{synopt :{opth auth:ors(string)}}Authors of study{p_end}
{synopt :{opth scen:ario(string)}}Scenario{p_end}
{synopt :{opth grou:p(string)}}Group{p_end}
{synopt :{opth proj:ect(string)}}Project{p_end}
{synopt :{opth sheet(string)}}Name of sheet to write results. Default is "E24. Lorenz Curves"{p_end}
{synopt :{opt open}}Automatically open CEQ Master Workbook with new results added{p_end}
   
{synoptline}	
{p 4 6 2}
{cmd:pweight} allowed; see {help weights}. Alternatively, weights can be specified using {help svyset}. 

{title:Description}

{pstd} 
{cmd:ceqgraph progressivity} graphs Lorenz curves of pre- and post-fisc income and the concentration
curve of post-fisc income with respect to pre-fisc income. These curves are useful to visually assess
whether the tax and transfer system is globally progressive and unambiguously equalizing. Graphs are 
produced for two pre-fisc incomes (market income--given by {opth m:arket(varname)}--and market income
 plus pensions--given by {opth mp:luspensions(varname)}) 
and two post-fisc incomes (consumable income--given by {opth c:onsumable(varname)}--and final
income--given by {opth f:inal(varname)}). 

{pstd}
If the data set is at the individual level (each observation is an individual), the variable with the 
identification code of each household (i.e., it takes the same value for all members within a 
household) should be specified in the {opth hh:id(varname)} option; the {opth hs:ize(varname)} option 
should not be specified. If the data set is at the household level, the number of members in the 
household should be specified in {opth hs:ize(varname)}; the {opth hh:id(varname)} option should not be 
specified. In either case, the weight used should be the household sampling weight and should {it:not} 
be multiplied by the number of members in the household since the program will do this multiplication 
automatically in the case of household-level data. 

{pstd}
There are two options for including information about weights and survey sample design for accurate
estimates and statistical inference. The sampling weight can be entered using 
{weight} or {help svyset}. Information about complex stratified sample designs can also be entered 
using {help svyset} since {cmd:ceqgraph} automatically uses the information specified using 
{help svyset}. Alternatively, the primary sampling unit can be entered using the {opth psu(varname)} option 
and strata can be entered using the {opth s:trata(varname)} option.

{pstd}
By default, {cmd: ceqgraph progressivity} does not allow income concept or fiscal intervention variables to have missing 
values: if a household has 0 income for an income concept, receives 0 from a transfer or a subsidy, 
or pays 0 of a tax, the household should have 0 rather than a missing value. If one of these variables has 
missing values, the command will produce an error. For flexibility, however, the command includes an 
{opt ignorem:issing} option that will drop observations with missing values for any of these variables, thus 
allowing the command to run even if there are missing values. 

{pstd}
Negative incomes are allowed, but a warning is issued for each core income concept that 
has negative values (or positive values when a fiscal intervention is stored as negative values). This is because 
various measures are no longer well-behaved when negative values are included (for example, the Gini coefficient, 
concentration coefficient, or squared poverty gap can exceed 1, and other desirable properties of these measures 
when incomes are non-negative no longer hold when negative values are allowed).

{pstd}
The resulting graphs from {cmd:ceqgraph progressivity} are saved as {bf:prog_`y0'_to_`y1'.gph} 
where `y0' is a letter representing the pre-fisc income concept (either m or mp) and `y1' is a 
letter representing the post-fisc income concept (either c or f).

{pstd}
The resulting graphs from {cmd:ceqgraph progressivity} are saved in the directory specified by the {opth path(string)} option
(or, by default, the current directory) with the file name {bf:`graphname'_`y0'_to_`y1'.gph} where 
`graphname' is the prefix specified by {opth graphname(string)} (or "prog" by default),
`measure' is one of headcount, total, percapita, or normalized, `y0' is a letter representing the 
pre-fisc income concept (either m or mp), and `y1' is a letter representing the post-fisc income 
concept (either c or f).

{pstd}
Results are automatically exported to the CEQ Master Workbook if 
{cmd:using} {it:filename} is specifed in the command, where {it:filename} is the Master Workbook. By 
default, {cmd:ceqgraph progressivity} prints to the sheets titled "E24. Lorenz Curves"; the user can override the sheet names using the 
{opt sheet(string)}. Exporting directly to the Master Workbook requires Stata 14.1 or newer. The Master 
Workbook populated with results from {cmd:ceqgraph progressivity} can be automatically opened if the {opt open} 
option is specified (in this case, {it:filename} cannot have spaces). Results are also saved in 
matrices available from {cmd:return list}. 

{title:Examples}

{pstd}Individual-level data (each observation is an individual){p_end}
{phang} {cmd:. ceqgraph progressivity [pw=w] using C:/Output_Tables.xlsx, hhid(hh_code) psu(psu_var) strata(stra_var) m(ym) mplusp(ymplusp) c(yc) f(yf)}{p_end}

{pstd}Household-level data (each observation is a household){p_end}
{phang} {cmd:. ceqgraph progressivity [pw=w] using C:/Output_Tables.xlsx, hsize(members) psu(psu_var) strata(stra_var) m(ym) mp(ymplusp) c(yc) f(yf)}{p_end}

{title:Saved results}

Pending

{title:Author}

{p 4 4 2}Sean Higgins, CEQ Institute, sean.higgins@ceqinstitute.org


{title:References}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}


