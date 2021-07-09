{smcl}
{* *! version 1.4  07aug2020}{...}
{it: v1.4, 07aug2020}

{title:Title}

{phang}
{bf:(KIT) Living Income Tools} {hline 2} Tables and Bar charts of the Gap to the Living Income Benchmark.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: kitli_gap2bm}
{it:li_benchmark} {ifin}, arguments

{synoptset 45 tabbed}{...}
{synopthdr:mandatory arguments}
{synoptline}

{synopt :{opth hh_income:(varname)}} {varname} of total household income {p_end}

{synopthdr:optional arguments}
{synoptline}

{syntab: Income composition}

{synopt :{opth main_income:(varname)}} {varname} of total income from main source, for example main crop sales {p_end}
{synopt :{opth food_value:(varname)}} {varname} of value attributable to food produced and consumed at home {p_end}

{syntab: Metric}

{synopt :{opt metric:(mean)}}  computes {help mean} (default) {p_end}
{synopt :{opt metric:(median)}}  computes {help egen:medians} {p_end}
{synopt :{opt metric:(FGT)}}  computes the {it: FGT} index {p_end}

{syntab: Calculation}

{synopt :{cmd:as_share}} computes share of the benchmark value instead of absolute (default). Applicable only for  {opt metric:(mean)} and {opt metric:(median)}{p_end}

{syntab: Grouping}

{synopt :{opth grouping_var:(varname)}} grouping variable {p_end}

{syntab: Labels}

{synopt :{opt label_benchmark:(text)}} Text for benchmark name. Default "Living Income Benchmark" {p_end}
{synopt :{opt label_currency:(text)}} Text for currency name. Default "USD" {p_end}
{synopt :{opt label_time:(text)}} Text for time period name. Default "year" {p_end}
{synopt :{opt label_hh_income:(text)}} Text for total income Default "Total income". Used if {opth main_income:(varname)} is NOT provided {p_end}
{synopt :{opt label_main_income:(text)}} Text for main income. Default "Income from main crop". Used if {opth main_income:(varname)} is provided {p_end}
{synopt :{opt label_other_than_main_income:(text)}} Text for remaining income. Default "Other income". Used if {opth main_income:(varname)} is provided {p_end}
{synopt :{opt label_food_value:(text)}} Text for value of food. Default "Value of crops consumed at home". Used if {opth food_value:(varname)} is provided {p_end}


{syntab: Graph colors}

{synopt :{opth color_hh_income:(colorstyle)}} Color of total income. Default "blue%30"
(or "blue" if older than stata 15). Used if {opth main_income:(varname)} is NOT provided {p_end}
{synopt :{opth color_main_income:(colorstyle)}} Color of main source of income. Default "blue%30" 
(or "blue" if older than stata 15). Used if {opth main_income:(varname)} is provided{p_end}
{synopt :{opth color_other_than_main_income:(colorstyle)}} Color of remaining income. Default "ebblue%30" (or "ebblue" if older than stata 15)
. Used if {opth main_income:(varname)} is provided {p_end}
{synopt :{opth color_food_value:(colorstyle)}} Color of the intrinsic value of food consumed at home. Default "orange%30" (or
 "orange" if older than stata 15). Used if {opth food_value:(varname)} is provided {p_end}
{synopt :{opth color_gap:(colorstyle)}} Color of the gap to the living income benchmark. Default "red%30" (or "red"
 if older than stata 15) {p_end}


{syntab: Graph exporting}

{synopt :{cmd:show_graph}} shows graph comparing to the benchmark  {p_end}
{synopt :{opt save_graph_as:(text)}} main stub of filename to be saved. Graphs will be saved as png format {p_end}

{synoptline}


{title:Description}

{pstd}
{cmd: kitli_gap2bm} produces tables and bar charts of the Gap to the Living Income Benchmark, optionally per group.

{pstd} It produces graphs similar to what can be seen at:

{pstd} {browse "https://www.kit.nl/wp-content/uploads/2019/01/Analysis-of-the-income.pdf"}

{pstd} {browse "https://docs.wixstatic.com/ugd/0c5ab3_93560a9b816d40c3a28daaa686e972a5.pdf"}

{pstd} It computes, optionally, the mean or median household income and breaks it down into main income, other income, 
gap to the living income benchmark. Optionally it includes the intrinsic value of food crops produced and consumed at home. 
Optionally, it computes the FGT index.

{pstd} This function includes options to customize key elements of the graphs. 
Please notice, however, that all graphs can be further edited using Stata's {help graph_editor} capabilities. 


{title:Arguments}

{dlgtab:Main}

{pmore}
{cmd:li_benchmark} {varname} which containts the living income benchmark value per observation.
{p_end}

{dlgtab:Mandatory}

{pmore}
{opth hh_income:(varname)} {varname} of total household income, including the main income source
but excluding intrinsic value of food produced at home. 


{pmore}{it:{cmd:li_benchmark} and {opth hh_income:(varname)} need to be in the same currency and unit (e.g., USD per household).}
{p_end}


{dlgtab:Income composition}
{pmore}

{pmore}
{opth main_income:(varname)} {varname} of total income from main source, for example main crop sales. If provided, the outputs assume there is one main income source.
 The calculations are done  only for complete observations, i.e., if 
{opth main_income:(varname)} is provided, observations
where {opth main_income:(varname)} is missing will be excluded from the calculations. 

{pmore}
{opth food_value:(varname)} {varname} of the value of food produced and consumed at home. If provided, it is added to the total income. 
The calculations are done only for complete observations, i.e., if {opth food_value:(varname)} is provided, 
observations where
{opth food_value:(varname)} is missing will be excluded from the calculations. 
If provided, it will be added to the {opth hh_income:(varname)}


{pmore}{it: {opth main_income:(varname)}  and {opth food_value:(varname)} need to be in the same currency and unit as {it:{cmd:li_benchmark}} (e.g., USD per household).}
{p_end}

{dlgtab:Metric}
{pmore}

{pmore}
{opt metric:(mean)}  computes {help mean} and compare means to the living income benchmark (default) {p_end}

{pmore}
{opt metric:(median)}  computes {help egen:medians} and compare median values to the living income benchmark {p_end}

{pmore}
{opt metric:(FGT)}  computes the {it: FGT} index.
The Foster–Greer–Thorbecke (FGT) indices focuses on those below a reference threshold, by assigning a gap value of 0 to 
those above the line. It provides an indication of the depth of the poverty among the poor.  
We adapt the original poverty gap metric by replacing the poverty line with the Living Income Benchmark. 
It takes the mean of the income gap per household, as a share, assigning a gap of 0 to those 
above the benchmark line. {p_end}

{dlgtab:Calculation}
{pmore}

{pmore}
{cmd:as_share} computes shares of the benchmark value instead of absolute (default), i.e. all values shown are in percentage of the benchmark value and add up to 100%. {p_end}


{dlgtab:Grouping}
{pmore}
{opth grouping_var:(varname)} grouping variable. If specified, tables will be per group and bar charts will have one bar per group. {p_end}


{dlgtab: Labels}
{pmore}
{opth label_benchmark:(text)} Text for benchmark name. If not specified,  {it:Living Income Benchmark} is shown. {p_end}

{pmore}
{opth label_currency:(text)} Text for currency name. If not specified,  {it:USD} is shown. {p_end}

{pmore}
{opth label_time :(text)} Text for time. If not specified, {it:year} is shown. {p_end}

{pmore}
{opth label_hh_income:(text)} Text for total household income. If not specified, {it:Total income} is shown. Only in case {it:main_income} is NOT provided{p_end}

{pmore}
{opth label_main_income:(text)} Text for main income. If not specified, {it:Income from main crop} is shown. Only in case {it:main_income} is provided {p_end}

{pmore}
{opth label_other_than_main_income:(text)} Text for remaining income. If not specified, {it:Other income}  is shown. Only in case {it:main_income} is provided {p_end}

{pmore}
{opth label_food_value:(text)} Text for intrinsic value of food. If not specified,  {it:Value of crops consumed at home} is shown. Only in case {it:food_value} is provided {p_end}


{dlgtab: Graph colors}
{pmore}{it:For more information see {help colorstyle}}. Please notice that transparency in colors ("%30")
is only available from stata version 15 onwards. If stata version is older than 15
the default values will skip the transparency.

{pmore}
{opth color_hh_income:(colorstyle)} Color of main source of income. Default "blue%30".  {p_end}

{pmore}
{opth color_main_income:(colorstyle)} Color of main source of income. Default "blue%30".  {p_end}

{pmore}
{opth color_other_than_main_income:(colorstyle)} Color of remaining income. Default "ebblue%30" {p_end}

{pmore}
{opth color_food_value:(colorstyle)} Color of the intrinsic value of food consumed at home. Default "orange%30". Only in case {it:food_value} is provided {p_end}

{pmore}
{opth color_gap:(colorstyle)} Color of the gap to the living income benchmark. Default "red%30" {p_end}



{dlgtab: Graph exporting}

{pmore}
{cmd:show_graph} shows graph comparing to the benchmark {p_end}

{pmore}
{opt save_graph_as:(text)} main stub of filename to be saved. Graphs will be saved as png format (appended to the filename). {p_end}



{title:Examples}

{phang}Setup

{phang}{cmd:. use https://raw.githubusercontent.com/mtyszler/KIT_LivingIncome/master/kitli_exampledata.dta}
({stata "use https://raw.githubusercontent.com/mtyszler/KIT_LivingIncome/master/kitli_exampledata.dta":{it:click to run}}) {p_end}

{phang}Tables by group, means

{phang}{cmd:. kitli_gap2bm benchmark, hh_income (total_hh_income_2018) main_income(total_cocoa_income_2018) grouping_var(grouping) }
({stata "kitli_gap2bm benchmark, hh_income (total_hh_income_2018) main_income(total_cocoa_income_2018) grouping_var(grouping) ":{it:click to run}}) 
{p_end}

{phang}Bar Chart by group, means

{phang}{cmd:. kitli_gap2bm benchmark, hh_income (total_hh_income_2018) main_income(total_cocoa_income_2018) grouping_var(grouping) show_graph }
({stata "kitli_gap2bm benchmark, hh_income (total_hh_income_2018) main_income(total_cocoa_income_2018) grouping_var(grouping) show_graph":{it:click to run}}) 
{p_end}

{phang}Bar Chart by group, means, saving

{phang}{cmd:. kitli_gap2bm benchmark, hh_income (total_hh_income_2018) main_income(total_cocoa_income_2018) grouping_var(grouping) show_graph save_graph_as(example_barchart)}
({stata "kitli_gap2bm benchmark, hh_income (total_hh_income_2018) main_income(total_cocoa_income_2018) grouping_var(grouping) show_graph save_graph_as(example_barchart)":{it:click to run}}) 
{p_end}

{phang}Bar Chart by group, medians

{phang}{cmd:. kitli_gap2bm benchmark, hh_income (total_hh_income_2018) main_income(total_cocoa_income_2018) grouping_var(grouping) show_graph metric(median)}
({stata "kitli_gap2bm benchmark, hh_income (total_hh_income_2018) main_income(total_cocoa_income_2018) grouping_var(grouping) show_graph metric(median)":{it:click to run}}) 
{p_end}

{phang}Bar Chart by group, means as share

{phang}{cmd:.  kitli_gap2bm benchmark, hh_income (total_hh_income_2018) main_income(total_cocoa_income_2018) grouping_var(grouping) show_graph as_share}
({stata " kitli_gap2bm benchmark, hh_income (total_hh_income_2018) main_income(total_cocoa_income_2018) grouping_var(grouping) show_graph as_share":{it:click to run}}) 
{p_end}

{phang}Bar Chart by group, FGT index

{phang}{cmd:.  kitli_gap2bm benchmark, hh_income (total_hh_income_2018)  grouping_var(grouping) show_graph metric(FGT)}
({stata "kitli_gap2bm benchmark, hh_income (total_hh_income_2018)  grouping_var(grouping) show_graph metric(FGT)":{it:click to run}}) 
{p_end}

{phang}Bar Chart by group, means with food value

{phang}{cmd:. kitli_gap2bm benchmark, hh_income (total_hh_income_2018) main_income(total_cocoa_income_2018) food_value(food_value) grouping_var(grouping) show_graph}
({stata "kitli_gap2bm benchmark, hh_income (total_hh_income_2018) main_income(total_cocoa_income_2018) food_value(food_value) grouping_var(grouping) show_graph":{it:click to run}}) 
{p_end}

{title:Saved results}

{pstd}
{cmd:kitli_gap2bm} saves the following in {cmd:r()}, depending on the options provided:

{synoptset 20 tabbed}{...}
{p2col 5 35 24 2: Scalars}{p_end}
{pmore}
{it: If groups are provided, the results names are appended with the group number} {p_end}

{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(main_income)}} mean or median of the main income{p_end}
{synopt:{cmd:r(other_than_main_income)}} mean or median of the other than main income{p_end}
{synopt:{cmd:r(total_income)}} mean or median of the total income{p_end}
{synopt:{cmd:r(food_value)}} mean or median of the intrinsic value of food produced and consumed at home{p_end}
{synopt:{cmd:r(gap)}} mean or median of gap to the benchmark value{p_end}
{synopt:{cmd:r(FGT)}} FGT index{p_end}
{synopt:{cmd:r(benchmark)}} mean or median of the benchmark value{p_end}


{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(metric)}}metric calculated: mean, median of FGT{p_end}
{synopt:{cmd:r(calculation)}}level or share{p_end}
{synopt:{cmd:r(grouping_var)}}variable used for groupings{p_end}


{title:Citation}
{phang}
{cmd:kitli_gap2bm} is not an official Stata command. It is a free contribution to the research community, like a paper.
Please cite it as such:{p_end}

{phang}
Tyszler, et al. (2020). Living Income Calculations Toolbox. KIT ROYAL TROPICAL 
INSTITUTE and COSA. Available at: {browse "https://github.com/mtyszler/KIT_LivingIncome/"} 
{p_end}

{phang}
If you have requests or suggestions, please do so at our repository:  {browse "https://github.com/mtyszler/KIT_LivingIncome/"} {p_end}


{title:Authors}
{phang} Marcelo Tyszler {bf:{it: (Package maintainer)}}. KIT Royal Tropical Institute, Netherlands. {browse "mailto:m.tyszler@kit.nl":m.tyszler@kit.nl} {p_end}

{phang} Carlos de los Rios. COSA.  {browse "mailto:cd@thecosa.org":cd@thecosa.org}{p_end}


{title:References}
{phang}
Github repository:  {browse "https://github.com/mtyszler/KIT_LivingIncome/"} {p_end}


