{smcl}
{* *! version 0.1.1beta 01Jul2018}{...}
{viewerdialog autosum "dialog autosum"}{...}
{viewerjumpto "Syntax" "autosum##syntax"}{...}
{viewerjumpto "Description" "autosum##description"}{...}
{viewerjumpto "Options" "autosum##options"}{...}
{viewerjumpto "Remarks" "autosum##remarks"}{...}
{viewerjumpto "Examples" "autosum##examples"}{...}
{viewerjumpto "Stored results" "autosum##results"}{...}
{title:Title}

{p2colset 5 20 22 2}{...}
{p2col : autosum {hline 2}}Automatically summarise data using various statistical tests and present a comparison table {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{marker overview}{...}
{p 4 8 2}
Overview of Group formats

           {bf:Long - Group format 1}
        {c TLC}{hline 28}{c TRC}         {bf:Wide - Group format 2}
        {c |}{it:Subject  Grouping}      {it:Var}  {c |}   {c TLC}{hline 28}{c TRC}
        {c |}{hline 28}{c |}   {c |} {it:Subject}  {it:Group A} {it:Group B}   {c |}
        {c |} 1  	{it:A}   	31    {c |}   {c |}{hline 28}{c |}
        {c |} 2  	{it:A}   	42    {c |}   {c |}   1      31       23       {c |}
        {c |} 3  	{it:B}   	42    {c |}   {c |}   2      42       13       {c |}
        {c |} 4  	{it:A}   	35    {c |}   {c BLC}{hline 28}{c BRC}
        {c BLC}{hline 28}{c BRC}

        Long format - grouping variable (groupvar)

     	        {cmd:autosum} {it:groupvar}

        Wide format (also used for paired data) - individual groups (groupA, groupB ...)

     	        {cmd:autosum} {it:groupA groupB}



      
{p 4 8 2}
Basic syntax

{phang2}
Generate basic comparison table using single grouping variable

{p 12 16 2}
{cmd:autosum} {helpb autosum##overview:groupvar}
[{it:if}] [{it:in}]
{cmd:,}
[{it:{help autosum##options_table:options}}]

{phang2}
Generate basic comparison table using selected variables in wide format

{p 12 16 2}
{cmd:autosum} {helpb autosum##overview:groupA groupB}
[{it:if}] [{it:in}]
{cmd:,}
[{it:{help autosum##options_table:options}}]


{marker options_table}{...}
{p2colset 10 37 39 2}{...}
{p2col :{it:options}}Description{p_end}
{col 8}{hline}
{p2col 8 37 37 2 :}{p_end}
{p2col :{cmdab:pa:ired*}}use paired group comparison for selected groups {p_end}
{p2col :{cmdab:ex:clude(varlist)}}exclude variables in varlist from analysis{p_end}
{p2col :{cmdab:cut:off(integer)}}define the number categories in variable before it is regarded as continuous (default number is 7){p_end}
{p2col :{cmdab:sf:rancia}}use Shapiro-Francia test to test for normality rather than default Shapiro-Wilk test{p_end}
{p2col :{cmdab:gr:ouping}}manual input of grouping variable, if no other variables specified then all variables are included - see advanced syntax{p_end}
{p2col :{cmdab:cont:inuous}}manual input of continuous variables - see advanced syntax{p_end}
{p2col :{cmdab:cat:egorical}}manual input of categorical variables - see advanced syntax{p_end}
{p2col :{cmdab:exp:ort(filename)}}export comparison table to comma delimited file <filename> in working directory{p_end}
{p2col :{cmdab:p:value(star)}}changes format of p values to make them more presentable (only works with exported file version) {p_end}
{col 8}{hline}
{p2colreset}{...}
{col 8}* paired data is only supported in wide format (group format 2)


{p 4 8 2}
Advanced syntax

{p 8 17 2}
{cmd:autosum, [grouping(varlist)] continuous(varlist) categorical(varlist)}

{pstd}
 Manual entry depends on whether grouping variable is present. If there is a grouping variable then long format  (group format 1) is assumed. 
 If there is no grouping variable, then data is analysed as wide format (group format 2), in which case either continuous or categorical variables are allowed. 
 Paired option also works with manual entry of variables. Use the manual option if autosum is not correctly determining variable type


{marker description}{...}
{title:Description}

{pstd}
{cmd:autosum} automatically detects variable type and performs statistical tests to compare between groups, then presents this in a comparison table 
For more details on usage and grouping, visit {browse "http://autosum.scienceontheweb.net":the autosum blog}


{marker options}{...}
{title:Options}

{phang}
{cmd:paired} ensure to specify this option if comparing between paired data i.e. observations for same subjects (versus unmatched data). 

{phang}
{cmd:exclude(varlist)} use this option to exclude variables that should not be analysed e.g. subject ID. {cmd:autosum} will automatically remove them from the analysis. 

{phang}
{cmd:cutoff(integer)} determine the number of group categories before a numeric integer variable is deemed to be continuous. Alter this if {cmd:autosum} is not correctly determining your variables, or alternatively use the manual entry option.



{marker remarks}{...}
{title:Remarks}

{pstd}
Before using {cmd:autosum}, you need to determine whether the data is in long
or wide form (group formats 1 or 2).  You also must determine the grouping variable if in long format; and whether data is paired or unmatched. 
The user is strongly advised to check the output to ensure that variables are classified correctly
For more information on usage, please visit {browse "http://autosum.scienceontheweb.net":the autosum blog}


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto}

{pstd}List the data{p_end}
{phang2}{cmd:. list}

{pstd}Summarise the data comparing between foreign and domestic groups{p_end}
{phang2}{cmd:. autosum foreign}

{pstd}Export the data in comma delimited file with optimised format for p values{p_end}
{phang2}{cmd:. autosum foreign, export(filename) pvalue(star)}

{pstd}Compare between variables: mpg and turn{p_end}
{phang2}{cmd:. autosum mpg turn}

{pstd}Perform a paired group comparison between mpg and turn{p_end}
{phang2}{cmd:. autosum mpg turn, paired}

    {hline}

{pstd}Manual entry of the following variables: group variable(foreign), compare between mpg and price{p_end}
{phang2}{cmd:. autosum, grouping(foreign) continuous(mpg price)}


    {hline}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:autosum} stores the comparison table in the following matrix:
final


{p2colreset}{...}
