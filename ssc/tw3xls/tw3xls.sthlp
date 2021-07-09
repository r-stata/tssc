{smcl}
{* *! version 1.7  2017-04-20}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Author" "examplehelpfile##author"}{...}
{title:Title}

{phang}
{bf:tw3xls} {hline 2} Export tabulation results of three or four variables to Excel with a nice formatting  


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:tw3xls}
{it:rowvar colvar supercolvar}
{ifin}
[{cmdab:using} {it:filename}]
[{cmd:,}
    {cmdab:by}({it:groupvar})
    {cmdab:show} 
	 {cmdab:t:otal}({it:rows cols}) 
	 {cmdab:sort}({it:low|high}) 
	 {cmdab:top}({it:#}) 
	 {cmdab:mi:ssing}({it:#}) 
	 {cmdab:f:ormat}({it:basic merge}) 
	 {cmdab:st:ub}({it:string}) 
	 {cmdab:sheet}({it:string}) 
	 {cmdab:replace} 
	 {cmdab:modify} 
]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt using}}specify an export file name; can be used with or without file extension{p_end}

{syntab:Options}
{synopt :{opt by}(groupvar)}a grouping variable to generate a series of  three-way tables for each level of {it:groupvar}{p_end}
{synopt :{opt show}}display corresponding tabulation with a help of a -{stata "help table":table}- command{p_end}
{synopt :{opt t:otal}(rows cols)}add an additional column and/or row with totals. Both options can be applied at the same time{p_end}
{synopt :{opt sort}(low|high)}sort tabulation results in ascending (low) or descending (high) order{p_end}
{synopt :{opt f:ormat}(basic merge)}format output tables. 'basic' option adds borders, alignment of cells and merging of header cells. 'merge' merges supercolumn header cells{p_end}
{synopt :{opt top(#)}}select top {it:#} values in the output table(s). Default is descending order. Can be combined with a {it:sort()} option to select top {it:#} values in ascending order{p_end}
{synopt :{opt mi:ssing(#)}}replace cells with zero frequencies to a numeric value {it:#}. By default zero frequency cells will be blank in Excel.{p_end}
{synopt :{opt st:ub}(string)}save tabulation results into Stata matrices with a {it:string} prefix{p_end}
{synopt :{opt sheet}(string)}name of the sheet to save tabulation results; default is "Data"{p_end}
{synopt :{opt replace}}overwrite the export file; default option{p_end}
{synopt :{opt modify}}keep previous data in the export file but overwrites data in a sheet: on a specific sheet or on a default sheet "Data" if no sheet name is specified{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:tw3xls} works faster while saving as *.xls though formatting may be broken on a large number of tables.
Saving as *.xlsx correctly displays all formatting but works slower.
{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:tw3xls} serves to save three-way frequency tables into Excel with an appropriate formatting.
It is very useful when dealing with a large number of tables, especially when the tables should be pre-formatted.
The output will be written to a spreadsheet file format (usually *.xls or *.xlsx). If you want to work with the tables further, they are saved in {it:rclass} and can be put into Stata matrices named by {opt stub(string)}.
Number of variables is limited to three, you can add the fourth variable in {opt by(groupvar)} option which will produce a set of three-way tables: one for each level of the fourth variable.

{p 4 4 2}{it:Note}: when saving as *.xls the program works much faster comparing to saving as *.xlsx, however the formatting may be broken for some tables. Saving as *.xlsx fixes that issue but requires more time to proceed.{p_end}


{p 40 20 2}(Go up to {it:{help tw3xls##syntax:Syntax}}){p_end}
{marker options}{...}
{title:Options description}
{synoptset 20 tabbed}{...}
{dlgtab: Options}

{synopt :{opt by(groupvar)}}adding this option produces a set of three-way tables for each unique value of the {it:groupvar}.
The {it:groupvar} can be both string or numeric. When using this option, each output table will have a header indicating a corresponding {it:groupvar} value.{p_end}
{synopt :{opt show}}display tabulation results in the Output window as if Stata's -{stata "help table":table}- command is used.{p_end}
{synopt :{opt t:otal(rows cols)}}add an additional column and/or row with totals to the output table(s).
The suboptions can be abbreviated to {cmd:r}, {cmd:ro}, {cmd:row} and {cmd:c}, {cmd:co}, {cmd:col}. Both suboptions can be applied at the same time{p_end}
{synopt :{opt sort(low|high)}}sort tabulation results in ascending (lowest to highest) or descending (highest to lowest) order. 
Only one sorting option can be used at a time. Can be abbreviated down to {cmd:l} for {cmd:low} and {cmd:h} for {cmd:high}.{p_end}
{synopt :{opt f:ormat(basic merge)}}add formatting to output tables. 
{cmd:basic} option (also can be written as {cmd:b}, {cmd:ba}, {cmd:bas}) adds borders around all cells, vertical and horizontal alignment 
and merges all headers except supercolumns. {cmd:merge} option ({cmd:m}, {cmd:me}) merges table supercolumns in the export file.
Both suboptions can substantially increase computation time: {cmd:basic} by ~10%, {cmd:merge} by ~80% {p_end}
{synopt :{opt top(#)}}select first {it:#} rows for each tabulation result based on total row values. Values are sorted in descending order by default. To get a reverse order, must be combined with a {cmd:sort(low)} option. When using in conjunction with {cmd:total(cols)} the last row will contain total values for a complete table.{p_end}
{synopt :{opt mi:ssing(#)}}replace cells with zero frequencies to another numeric value {it:#}. 
If none is specified, all cells with zero frequency will be blank.{p_end}
{synopt :{opt stub(string)}}save output tables into matrices with a {it:string} prefix, 
i.e. {it:stub(mat)} will produce a series of matrices: mat{it:1} when there is no {cmd:by(groupvar)} option and mat{it:1}, ..., mat{it:k} when {cmd:by(groupvar)} is used.{p_end}
{synopt :{opt sheet(string)}}name a worksheet to export the data as {it:string}. When no sheet name is specified, a default name is used: "Data". 
This option may be useful when saving multiple tabulation results into one file but on different tabs.{p_end}
{synopt :{opt replace}}replace an output file; if {cmd:modify} is not specified that would be a default option.{p_end}
{synopt :{opt modify}}modify an output file; useful when saving several tabulation results into one file but on different tabs using {cmd:sheet(string)} option.{p_end}


{p 40 20 2}(Go up to {it:{help tw3xls##syntax:Syntax}}){p_end}
{marker Examples}{...}
{title:Examples}{p 50 20 2}{p_end}
{pstd}

{p 8 12}Use 1978 Automobile Dataset:{p_end}
{p 8 12}{stata "sysuse auto" :. sysuse auto}{p_end}

{p 8 12}Convert encoded variable to a string to get string labels in the output file instead of numbers:{p_end}
{p 8 12}{stata "decode foreign, gen(foreign_str)" :. decode foreign, gen(foreign_str)}{p_end}

{p 8 12}Save a three-way tabulation into example1.xlsx; save output table into matrix "ms", replace missing values (zero frequencies) with ".", show corresponding tabulation using Stata's -table- command:{p_end}
{p 8 12}{stata "tw3xls mpg rep78 foreign using example1, stub(ms) missing(.) show" :. tw3xls mpg rep78 foreign using example1, stub(ms) missing(.) show}{p_end}

{p 8 12}Modify the same file, add a sheet "Data2" on which a set of three-way tables is stored for each level of the "headroom" variable, and replace all zero-frequency cells values with 0:{p_end}
{p 8 12}{stata "tw3xls mpg rep78 foreign_str using example1, by(headroom) stub(ms) mi(0) show sheet(Data2) modify" :. tw3xls mpg rep78 foreign_str using example1, by(headroom) stub(ms) mi(0) show sheet(Data2) modify}{p_end}

{p 8 12}Replace the current file, add row and column totals, sort each table in a descending order:{p_end}
{p 8 12}{stata "tw3xls mpg rep78 foreign_str using example1, by(headroom) total(c r) sort(h) replace" :. tw3xls mpg rep78 foreign_str using example1, by(headroom) total(c r) sort(h) replace}{p_end}

{p 8 12}Same as previous, but adds formatting: {it:basic} (borders, cell alignment) and {it:merge} (merge column labels and center them vertically):{p_end}
{p 8 12}{stata "tw3xls mpg rep78 foreign_str using example1, by(headroom) total(c r) sort(h) form(b m) replace" :. tw3xls mpg rep78 foreign_str using example1, by(headroom) total(c r) sort(h) form(b m) replace}{p_end}

{p 8 12}Select first 5 rows in descending order:{p_end}
{p 8 12}{stata "tw3xls mpg rep78 foreign_str using example1, by(headroom) total(c r) form(b m) top(5) replace" :. tw3xls mpg rep78 foreign_str using example1, by(headroom) total(c r) form(b m) top(5) replace}{p_end}


{p 40 20 2}(Go up to {it:{help tw3xls##syntax:Syntax}}){p_end}
{marker remarks}
{title:Remarks}

{p 5 6 2}
1. {cmd:tw3xls} saves only frequency tables.

{p 5 6 2}
2. {cmd:tw3xls} works with both string and numeric data. For encoded variables please create string variables via -{stata "help decode":decode}- - it stores labels as text instead of numbers in the output file.

{p 5 6 2}
3. For a fast export don't use -{it:format()}- options: that will save tables and headers as a plain text without formatting and significantly increase computation speed.

{p 5 6 2}
4. Output files with the same name will be overwritten by default unless -{it:modify}- is specified. 

{p 5 6 2}
5. Alternatives/similar programs: 

{p 10 12 2}
a) For three-way tables: -{stata "findit tab3way":tab3way}- in conjunction with -{stata "findit logout":logout}-.

{p 10 12 2}
b) For one/two-way tables: -{stata "findit tabout":tabout}-, -{stata "findit tab2xl":tab2xl}- and -tab2xl2-. The latter command can be found here: {browse "https://github.com/leoshibata/tab2xl2/"}

{marker aut}
{title:Author}

{p 5 6 2} Andrey Ampilogov, Freelancer, a.ampilogov@gmail.com {p_end}

