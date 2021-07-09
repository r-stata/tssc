{smcl}
{viewerjumpto "Syntax" "xtable##syntax"}{...}
{viewerjumpto "Description" "xtable##description"}{...}
{viewerjumpto "Options" "xtable##options"}{...}
{viewerjumpto "Examples" "xtable##examples"}{...}
{viewerjumpto "Stored Results" "xtable##stored"}{...}

{title:Title}

{p 4 4 2}
{bf:xtable} - Export table output to Excel.

{marker syntax}{...}
{title:Syntax}

{p 4 4 2}
{bf:xtable} uses the same syntax of {help table}:

{p 8 8 2} {bf:xtable} {it:rowvar} [ {it:colvar} [ {it:supercolvar} ] ] 
[{it:{help if}}] [{it:{help in}}] [{it:{help weight}}] 
[, {it:table_options}  {it:export_options}]

{p 4 4 2}
where {it:table_options} are any options listed for 
{help table}, except for {it:replace} and {it:name()}. 
Unlike {help table}, {bf:xtable} does not accept the prefix 
{help by} (as in {it:by varlist: xtable}). 


{marker export_options_tbl}{...}
{col 5}{it:export_options}{col 43}{it:Description}
{space 4}{hline}
{col 5}{ul:file}name({it:{help filename}}){col 43}name of the Excel file (passed to {help putexcel}); default is {it:xtable.xlsx}
{col 5}{ul:sh}eet("{it:sheetname}" [, replace]){col 43}write to Excel worksheet {it:sheetname} (passed to {help putexcel})
{col 5}replace{col 43}overwrite Excel file (passed to {help putexcel}); default is to modify if {it:filename} is specified or overwrite xtable.xlsx
{col 5}{ul:mod}ify{col 43}modify Excel file (passed to {help putexcel})
{col 5}{ul:nop}ut	{col 43}do not export table; output will only be available in stored results
{space 4}{hline}


{marker description}{...}
{title:Description}

{p 4 4 2}
{bf:xtable} is a drop-in replacement for {help table}. 
You can just replace {bf:table} with {bf:xtable} in your code and 
use it the same way (see {help xtable##examples:Examples}). The actual tabulation will be 
done by {bf:table}, so you will get the exact same output 
in the results window, plus a link to an Excel 
spreadsheet containing the exported table.

{p 4 4 2}
The only major restriction is that you cannot use 
it with the prefix {help by}. But bear in mind that
you can specify row, column, supercolumn and up to 
four superrow variables, so you can get up to 7-way tabulations.

{p 4 4 2}
{bf:xtable} leverages {bf:table}{c 39}s {it:replace} option to
create a matrix that reproduces as best as possible what is shown 
on screen and then exports it using {help putexcel}.
Because it depends on {bf:putexcel}, {bf:xtable} requires Stata 13.1 
or newer.


{marker options}{...}
{title:Options}

{dlgtab:table_options}

{p 4 4 2}
Please refer to {help table} to see the full range of its capabilities. Formatting options such as {it:cellwidth()}, {it:concise} and {it:format(%}{it:{help fmt}}) will affect only the output shown in the results windows, not the exported table. 

{dlgtab:export_options}

{p 4 4 2}
By default, {bf:xtable} will export the tabulation to a file named "xtable.xlsx" 
in the current working directory, overwriting it if it already exists. 
You can control the exporting process by using the following options,
which will be passed to {help putexcel}:

{phang}
{bf:filename({it:{help filename}})} specifies the name of the Excel file to be used. Default is "xtable.xlsx". 
Both .xlsx and .xls extensions are accepted. If no extension is specified, .xlsx will be used.

{phang}
{bf:sheet("{it:sheetname}")}  specifies the name of the Excel worksheet to be used. 
If the sheet exists in the specified file, the default is to modify it. To replace it, use {bf:sheet(}"{it:sheetname}", replace{bf:)}.    {break}

{phang}
{bf:replace} overwrites the Excel file. Default is to modify if {bf:filename} is 
specified or overwrite "xtable.xlsx".

{phang}
{bf:modify}  modifies the Excel file.

{phang}
{bf:noput} keeps {bf:xtable} from writing to any file. Instead, it will just 
store the matrix in {bf:r(xtable)}, so you can include it in a {help putexcel}
call or use it in any other way (see example below). This might be particularly useful if you use Stata 14 or newer, 
which added formatting options to {bf:putexcel}.


{marker examples}{...}
{title:Examples}

    Setup
        . sysuse auto

    One-way table, multiple statistics, with row totals
        . xtable foreign, cont(mean mpg sd mpg) row

    Two-way table, multiple statistics, specifying filename and sheetname
        . xtable foreign rep78, cont(mean mpg sd mpg) filename(results.xlsx) sheet(table1, replace) replace


	-------------------------------------------------------------

    Setup
        . webuse byssin1

    Four-way table, with frequency weight and row, column and supercolumn totals
        . xtable workplace smokes race [fw=pop], by(sex) c(mean prob) row col scol

    Cancel automatic exporting and use stored matrix with putexcel:
        . xtable workplace smokes race [fw=pop], by(sex) c(mean prob) row col scol noput
        . putexcel A1 = ("A nice and informative title") A3 = matrix(r(xtable), names) using myfile.xlsx, replace



{marker stored}{...}
{title:Stored results}

{phang}
{bf:r(xtable)}: matrix reproducing the specified tabulation. 
If present, value labels for row, column and superrow variables are 
included as {help matrix rownames} and {help matrix colnames}. 




{title:Author}

{p 4 4 2}
Weverthon Machado    {break}
weverthonmachado[at]gmail[dot]com    {break}
{browse "https://weverthonmachado.github.io":weverthonmachado.github.io}{break}

{p 4 4 2}
v1.0.2


