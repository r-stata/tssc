{syntab :Other options}

{syntab :Calculation}
{synopt :{opt days(#)}}Optional number of days for advancing the
 simulations, value of 30 is applied if this parameter is omitted. The dialog entry is limited to 365. {p_end}
{synopt :{opt day0(string)}}Optional date for beginning of the simulations 
in the YYYY-MM-DD format, for example: 2020-02-29 {p_end}
{synopt :{opt steps(#)}}Integer number of simulation steps to be
undertaken within each day of simulation (1..1000). An error code 198 is issued if the number of simulation steps is non-integer or out of range. Default value is 1.{p_end}

{synopt :{opt clear}}permits the data in memory to be cleared{p_end}
{synopt :{opt percent}}indicates the model results should be reported as percentages as opposed to default reporting in absolute numbers.{p_end}
{synopt :{opt pdfreport(filename.pdf)}}optional name of a report file to be saved as PDF.{p_end}

{syntab :Graphing}
{synopt :{opt nograph}}suppress graph{p_end}
{synopt :{opt modelcolor}}indicates that particular fixed colors to be used in the graph, such as infected is red, regardless of the current Stata graphing settings.{p_end}

{syntab :Y axis, X axis, Titles, Legend, Overall, By}
{synopt :{it:twoway_options}}any of the options documented in 
     {manhelpi twoway_options G-3}{p_end}
