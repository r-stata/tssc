{smcl}

{hline}
help for {hi:mmat2tex}
{hline}
{title:Title}

{p 4 4}{cmd:mmat2tex } - export Mata Matrix to LaTeX Table.

{title:Syntax}

{p 4 13}{cmd:mmat2tex }{it:mata-matrixname }{cmd:using}{it: filename} {cmd:[, replace append fmt(}{it:fmt}{cmd:)} 
		{cmd: preheader(}{it:string}{cmd:) postheader(}{it:string}{cmd:) rownames)}{it:string}{cmd:) colnames(}{it:string}{cmd:)}
		{cmd: substitute(}{it:string}{cmd:) insertendrow(}{it:string}{cmd:) coldelimiter(}{it:string}{cmd:) rowdelimiter(}{it:string}{cmd:)}
		{cmdab:coeff:icient(}{it:options}{cmd:) show}	{cmd:]}

{title:Description}

{p 4 4} 
{cmd:mmat2tex} writes mata matrix {it:mata-matrixname} as a LaTeX table into {it:filename}.
Only the body of the table (i.e. rows and columns) is created, but the LaTeX commands can be included using the options {cmd:preheader} and {cmd:bottom}.
The mata matrix can be string, real or complex. {cmd:mmat2tex} includes a program which delays read/write commands in case the file cannot opened/saved.
After 5 occurences it aborts with an error.{p_end}

{title:Options}

{p 4 8}{cmd:replace} specifies that the file will be replaced, while {cmd:append} puts the table at the end of an existing file.
Both cannot used together. If none is specified replace is assumed.{p_end}

{p 4 8}{cmd:fmt(}{help fmt}{cmd:)} format for table. Default ist "%12.2f".
It is possible to set column specific formats.
For example {cmd:fmt(%12.2f %10.4f)} sets the format 12.2f for the first column and for the second and all following %10.4f format.{p_end}

{p 4 8}{cmd:preheader(}{it:string}{cmd:)/postheader(}{it:string}{cmd:)} adds text to the beginning (i.e. before the first and into the first cell) and the end (i.e. after the header) of the table head.{p_end}

{p 4 8}{cmd:colnames(}{it:string}{cmd:)/rownames(}{it:string}{cmd:)} specifies column and row names.{p_end}

{p 4 8}{cmd:bottom(}{it:string}{cmd:)}	adds text at the bottom of the table.{p_end}

{p 4 8}{cmd:substitute(}{it:string}{cmd:)} substitutes strings at the end. eg: substitute(col1 "Column Name") replaces all occurences of col1 with "Column Name".{p_end}

{p 4 8}{cmd:insertendrow(}{it:string}{cmd:)} inserts contents of string at the end of specified row.
Eg: insertendrow(4 "\hline") inserts at the end of the 4th row a \hline.
The string is inserted after the "\\" indicating a new line.
If an entire new row is added, the row delimiter has to be added as well.
Note: If used with append, the number correspond to the row of the final table, including headers.{p_end}

{p 4 8}{cmd:coldelimiter(}{it:string}{cmd:)/rowdelimiter(}{it:string}{cmd:)} sets delimiter for columns (standard "&") and rows (standard "\\").{p_end}

{p 4 8}{cmdab:coeff:icient(}{it:options}{cmd:)} Allows to add significance stars to the coefficients and parenthesis around standard errors. 
Without specifying any options, the entire mata matrix is treated as a matrix with coefficients on the uneven rows (1,3,...) and standard errors on the even rows (2,4,..). 
For example:{p_end}

{col 10}b(1,1) {col 20}b(1,2)
{col 10}se(1,1) {col 20}se(1,2)
{col 10}b(2,1) {col 20}b(2,2)
{col 10}se(2,1) {col 20}se(2,2)

{p 8 8}where se(1,1) is the standard error of the estimated coefficient b(1,1).{p_end}

{p 8 8}The levels for the significance starts are then 10%, 2 stars for 5% and 3 stars for 1%, basing on a two sided T-Test with a degree of freedom of 999. 
The standard errors are put in parenthesis.
For example, significance stars are only added to b(2,1) and b(2,2), then the options would be {cmd:pos((3,1) (4,2))}.

{p 8 8}Alternative settings can be specified in the {it:options}, which are:{p_end}

{col 10}Option {col 30}Description
{col 10}{hline}
{col 10} {cmd:dof(}{it:number}{cmd:)} {col 30} sets the degree of freedom for the twosided t-test.
{col 10} {cmd:par} {col 30} standard errors in parenthesis.
{col 10} {cmd:pos(}{it:cell range}{cmd:)} {col 30} specifies that only a sub matrix is recognized containing estimated coefficients. 
{col 30} The order is {cmd:pos(r1,c1) (r2,c2)}, where {it:(r1,c1)} are the upper left coordinates of the sub matrix, while {it:(r2,c2)} are the lower right coordinates. 
{col 10}{hline}

{p 4 8}{cmd:show} displays output.{p_end}

{title:Example}

{p 4}{matacmd "test1 = (1,0.2,3\4,0.05,6)" : mata test1 = (1,0.2,3\4,0.05,6)} {p_end}
{p 4}{matacmd "test2 = (7,8,9\10,11,12)" : mata test2 = (7,8,9\10,11,12)}{p_end}

{p 4 6}Save matrix "test1" as test.tex, assign row and column names and add a title (run the locals first).{p_end}

{p 6 8}{stata local colrow_names "rownames(row1 row2) colnames(col1 col2 col3)"}{p_end}
{p 6 8}{stata local headers `"preheader("\hline \multicolumn{@M}{|l|}{Table Title} \\ \hline")"'}{p_end}
{p 6 8}{stata local substitute `"substitute(row1 "1st Row" row2 "2nd Row" col1 "Column 1" col2 "Column 2" col3 "Column 3")"'}{p_end}

{p 6 8}{stata mmat2tex test1 using test.tex , replace `colrow_names' `substitute'} {p_end}

{p 4 6}Append table with matrix "test2" and add an additional row between 3th and 4th row of the final table.{p_end}
{p 6 8}{stata local col_subst `"rownames(row3 row4) substitute(row3 "3th Row" row4 "4th Row" )"'}{p_end}
{p 6 8}{stata local inserted `"insertendrow(5 "\multicolumn{@M}{|l|}{Something in the middle} \\") bottom("End of Table")"'}{p_end}
{p 6 8}{stata mmat2tex test2 using test.tex ,  append `col_subst' `inserted'}{p_end}

{p 4 6}Add signficance stars to the 2nd and 3rd column of "test1" and add parenthesis around the standard errors (2nd row).
Set the significance levels as 5%, 1% and 0.1%{p_end}
{p 6 8}{stata mmat2tex test1 using test.tex ,  replace  coefficients(pos((1,2) (2,3)) par level(0.05,0.01,0.001)) }{p_end}


{p 4 6}Specify {help:format} %12.0f for the first column and %12.9g for the remaining ones.{p_end}
{p 6 8}{stata mmat2tex test1 using test.tex ,  replace  fmt("%12.0f %12.9g")}{p_end}

{p 4 6}Include Latex command for a complete Table. {p_end}

{p 6 8}{stata mmat2tex test1 using test.tex ,  replace rownames(row1 row2) colnames(col1 col2 col3) preheader("\begin{table} \begin{tabular}{|l|.|.|.|}\hline \hline") bottom("\end{tabular} \end{table}")}{p_end}

{title:Author}

{p 4}Jan Ditzen (Heriot-Watt University){p_end}
{p 4}Email: {browse "mailto:jd219@hw.ac.uk":jd219@hw.ac.uk}{p_end}
{p 4}Web: {browse "www.jan.ditzen.net":www.jan.ditzen.net}{p_end}
{p 4 8}The substitution routine is gratefully taken from Benn Jan's {help estout} command. Thanks to Nick Cox for his suggestion to use local macros for the examples. Any remaing errors are my own.{p_end}

{title:Also see}
{p 4 4}See also: {help estout}, {help outreg}, {help outreg2}{p_end}
