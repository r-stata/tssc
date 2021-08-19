{smcl}
{* 26/Oct/2020}{...}
{cmd:help mest}{right: ({browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":User-written stata packages: mtab})}
{hline}

{title:Title}

{p 4 4 2}{hi:mest} {hline 2} Store the results in {helpb matrix} for regression models


{title:Syntax}

{p 8 17 2}
{cmd:mest}
{ifin}
[{cmd:,} {it:options}
]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt C:ol}}indicates a number list of results that should be exported and stored in {helpb matrix}.{p_end}
{synoptline}

{title:Description}

{pstd}
Command {helpb mest} export and store the results (coefficient and confidence level) in {helpb matrix}.{p_end}


{title:Options} 

{phang} 
{opt col} specify a number list of results that should be exported and stored in {helpb matrix}.
If the option {it:base} is added at the end of the regression, the number is counted from the top to the bottom at the coefficient table; Alternatively, immediately after the regression model, you run the commend "{it:mat list r(table)}"
and number can be counted from the left to the right.
The number list allows standard number-list notation. There are a number of shorthand conventions to reduce the amount of typing necessary. For instance: see {helpb numlist}. 


{title:Examples}

{pstd}

{phang} 1. load an oneline data {p_end}
{phang}{stata "webuse lbw": .webuse lbw} {p_end}

{phang} 2. logistic regression (remeber to add the option {it:base} at the end of regression){p_end}
{phang}{stata "logistic low i.race, base": .logistic low i.race, base} {p_end}
{phang}{stata "mest, c(1/3)": .mest, c(1/3)} {p_end}
{phang}{stata "mest, c(2/3)": .mest, c(2/3)} {p_end}

{phang} 3. Linear regression (remeber to add the option {it:base} at the end of regression){p_end}
{phang}{stata "regress bwt age i.race, base": .regress bwt age i.race, base} {p_end}
{phang}{stata "mest, c(1)": .mest, c(1)} {p_end}
{phang}{stata "mest, c(3/4)": .mest, c(3/4)} {p_end}

{title:More examples} click on {browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":her}


{title:Author}

{pstd}
Chunsen Wu, the University of Southern Denmark; Odense University Hospital, Denmark{break} 
{browse cwu@health.sdu.dk}{break} 
{browse chunsen.wu@rsyd.dk}


{title:Also see}

{p 7 14 2}
Help: {helpb mtab}, {helpb mtab1}, {helpb mtab2}, {helpb msum}, {helpb mmat}, {helpb mexcel}, and {helpb mobs}
{p_end}
