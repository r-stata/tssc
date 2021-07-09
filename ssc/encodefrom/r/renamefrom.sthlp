{smcl}
{* *! version 1.2.0  12jun2017}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "renamefrom##syn"}{...}
{viewerjumpto "Description" "renamefrom##des"}{...}
{viewerjumpto "Options" "renamefrom##opt"}{...}
{viewerjumpto "Examples" "renamefrom##exa"}{...}
{viewerjumpto "Author" "renamefrom##auth"}{...}
{viewerjumpto "Remarks" "renamefrom##rem"}{...}
{title:Title}

{phang}
{bf:renamefrom} {hline 2} Names and labels variables using values stored in an external crosswalk.

{title:Table of contents}

	{help renamefrom##syn:Syntax}
	{help renamefrom##des:Description}
	{help renamefrom##opt:Options}
	{help renamefrom##exa:Examples}
	{help renamefrom##auth:Author}
	{help renamefrom##rem:Remarks}

	
{marker syn}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:renamefrom}
{cmd:using} {help filename}
{cmd:,} {opt filetype(string)} {opt raw(string)} {opt clean(string)}
[{it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Main}

{synopt:{opt raw(string)}}column in external crosswalk that contains existing variable names in memory{p_end}
{synopt:{opt clean(string)}}column in external crosswalk that contains clean variable names{p_end}
{synopt:{opt label(string)}}column in external crosswalk that contains clean variable labels{p_end}

{syntab:Crosswalk}

{synopt:{opt filetype(excel|delimited|stata)}}file type of external crosswalk{p_end}
{synopt:{opt sheet(string)}}sheet name if the external crosswalk is an Excel workbook{p_end}
{synopt:{opt delimiters("chars")}}{it:chars} used as delimiters in the external crosswalk; by default, "\t" or "," {p_end}

{syntab:Missing Values}

{synopt:{opt keepx}}keeps variables in memory if no match in the external crosswalk is found{p_end}
{synopt:{opt dropx}}drops variables in memory if no match in the external crosswalk is found{p_end}
{synopt:{opt keeplabel}}keeps variable labels in memory if no label is specified in the external crosswalk{p_end}
{synopt:{opt namelabel}}labels variables with variable names if no label is specified in the external crosswalk{p_end}

{syntab:Other}

{synopt:{opt if(exp)}}restricts renaming to a subset of values in the external crosswalk{p_end}
{synopt:{opt caseignore}}ignores capitalization when matching variables with raw names{p_end}

{synoptline}



{marker des}{...}
{title:Description}

{pstd}
{cmd:renamefrom} names and labels the variables in memory using values stored in an external crosswalk.  Storing the mapping from raw names to clean names in a crosswalk helps users align names across data sets and spot discrepancies 
between files.


{marker opt}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt raw(string)} specifies the crosswalk column that contains the names of variables in memory. 
If there are variables in memory that are not included in the external crosswalk, the user must 
specify either the {opt dropx} or {opt keepx} option.

{phang}
{opt clean(string)} specifies the crosswalk column that contains clean variable names.

{phang}
{opt label(string)} specifies the crosswalk column that contains clean variable labels. If no label
is specified for a given variable, the default behavior is to leave the label blank. 
The options {opt namelabel} and {opt keeplabel} provide alternatives.
 
{dlgtab:Crosswalk}

{phang}
{opt filetype(excel|delimited|stata)} specifies the file type
of the crosswalk. 
The {it:excel} option is for Excel workbooks with file extensions {bf:.xls}
and {bf:.xlsx}. The {it:delimited} option supports {bf:.csv} and other 
character-delimited text files. The {it:stata} option is for Stata {bf:.dta} files. 

{phang}
{opt sheet(string)} specifies a sheet name for the crosswalk in an Excel workbook. 
This option can only be used with {opt filetype(excel)}. In keeping with the syntax for {help import excel}, the
program defaults to using the workbook's first sheet if no sheet is specified.

{phang}
{opt delimiters("chars")} specifies the delimiter that separates columns in the crosswalk. 
This option can only be used with {opt filetype(delimited)}. For {bf:.csv} crosswalks
the syntax is {opt delimiters(",")}. For tab-delimited crosswalks the syntax is {opt delimiters("\t")}. In keeping with the syntax for {help import delimited},
if no delimiter is specified, Stata will check if the file is delimited by tabs or commas by default. 

{dlgtab:Missing Values}

{phang}
The {opt keepx} and {opt dropx} options determine how the program handles variables
in memory that are not found in the {opt raw} column of the crosswalk.

{phang}
{opt keeplabel} preserves the raw variable label if a clean label is not provided. 
{opt namelabel} applies the raw variable name as the label if a clean label is not provided.
If both options are specified, {opt namelabel} will only label a variable with
its raw name if no clean label was specified {it:and} the variable did not have a
raw label.
 
{dlgtab:Other}

{phang}
{opt if(exp)} restricts renaming to as subset of values in the external crosswalk.
 
{phang}
{opt caseignore} ignores capitalization when matching variables in memory with {opt raw} variable 
names in the crosswalk.


{marker exa}{...}
{title:Examples}

{phang}{cmd:. renamefrom using variables.xlsx, filetype(excel) raw(old_name) clean(new_name) label(label)}{p_end}
{phang}{cmd:. renamefrom using variables.csv, filetype(delimited) delimiters(",") raw(old_name) clean(new_name) label(label)}{p_end}

{marker auth}{...}
{title:Author}

{phang}Sally Hudson{p_end}
{phang}E-mail: sally.hudson@virginia.edu{p_end}
{phang}GitHub: https://github.com/slhudson{p_end}

{marker rem}{...}
{title:Remarks}

{pstd}
This program was developed through work at the School Effectiveness and 
Inequality Initative at MIT. Thanks are due to the many SEII research 
assistants who used and refined it over the years, especially Tyler Hoppenfeld,
Sookyo Jeong, and Alicia Weng. If you encounter any bugs or have suggestions 
for additional features, please feel free to submit a pull request on GitHub. The GitHub repository also contains more examples of this program in use.

