{smcl}
{* *! version 1.22  25jan2013}{...}
{cmd:help xls2row} {right: ({browse "http://web.missouri.edu/~kolenikovs/stata/":Stas Kolenikov's webpage})}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col :{hi:xls2row} {hline 2}}Convert a range of cells of an Excel file 
to {cmd:ipfraking}-compatible matrix{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 11 2}
{cmd:xls2row }{it:matrix_name}{cmd: using }{it:filename}
[{cmd:,} {it:options}]

{synoptset 43 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{cmd:cellrange()}}range of cells in Excel file, e.g., B2:D15{p_end}
{synopt :{cmd:sheet()}}the name of the sheet in Excel file to take values from{p_end}
{synopt :{cmd:over(}{it:varname}{cmd:)}}label the columns of the resulting row vector 
    with the values of {it:varname}{p_end}
{synopt :{cmd:scale(}{it:#}{cmd:)}}scale the entries of the row vector so that they sum up 
    to the specified value{p_end}

{title:Description}

{pstd}{cmd:xls2row} is a utility program in {cmd:ipfraking} package that reads
the calibration totals from an Excel file and stores them in the matrix
{it:matrix_name}.
The name of the Excel file, the range of cells and the name of the sheet
to take the values from are required. 
Mathematically speaking, {cmd:xls2row} performs a vec-transformation 
of the matrix, i.e., stores the result by columns.
The rowname of the resulting matrix is the convention name {cmd:_one}.
{p_end}

{pstd}CAUTION: {cmd:xls2row} relies on {help preserve} as an intermediate
step. It is advisable to run {cmd:xls2row} upfront before loading potentially
large datasets that would otherwise be written to disk and restored back
a number of times.{p_end}


{title:Author}

{pstd}Stanislav Kolenikov{p_end}
{pstd}Senior Survey Statistician{p_end}
{pstd}Abt SRBI{p_end}
{pstd}skolenik at gmail dot com{p_end}


{title:Also see}

{psee}{help import excel}, {help matrix rownames}, {help ipfraking} if installed.


