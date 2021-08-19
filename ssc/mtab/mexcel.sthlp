{smcl}
{* 26/Oct/2020}{...}
{vieweralsosee "[P] putexcel" "help putexcel"}{...}
{cmd:help mexcel}{right: ({browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":User-written stata packages: mtab})}
{hline}

{title:Title}

{p 4 4 2}{hi:mexcel} {hline 2} Export results from a {helpb matrix} to an Excel file


{title:Syntax}

{p 8 17 2}
{cmd:mexcel}
{helpb namelist}
{ifin}
[{cmd:,} {it:options}
]

{p 8 17 2}
{helpb namelist} indicates the column names in Excel


{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opth M:atrix(varlist:name)}}the name of {helpb matrix} with results{p_end}
{synopt :{opt r:ow}}the row number in the Excel{p_end}
{synoptline}

{title:Description}

{pstd}
Command {helpb mexcel} export results from {helpb matrix} to Excel.{p_end}


{title:Options} 

{phang} 
{opth M:atrix(varlist:name)} the name of {helpb matrix} with results. 

{phang} 
{opt row} specify which row in Excel to be the starting point. For example if you decided to put the results from E3 - E5, then staring point is 3, therefore row=3


{title:Examples}

{pstd}

{phang} 1. load an oneline data {p_end}
{phang}{stata "webuse lbw": .webuse lbw} {p_end}

{phang} 2. makes an one-way table and store the results (frequencies and percentages){p_end}
{phang}{stata "mtab1 smoke": .mtab1 smoke} {p_end}
{phang}{stata "mat F=r(frequency)": .mat F=r(frequency)} {p_end}
{phang}{stata "mat P=r(percent)": .mat P=r(percent)} {p_end}

{phang} 3. put the results (frequencies and percentages) into Excel{p_end}
{phang}{stata "putexcel set trymtab, sheet(A) modify": .putexcel set trymtab, sheet(A) modify} {p_end}
{phang}{stata "mexcel B, m(F) r(3)": .mexel B, m(F) r(3)} {p_end}
{phang}{stata "mexcel C, m(P) r(3)": .mexel C, m(P) r(3)} {p_end}


{title:More examples} click on {browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":her}


{title:Author}

{pstd}
Chunsen Wu, the University of Southern Denmark; Odense University Hospital, Denmark{break} 
{browse cwu@health.sdu.dk}{break} 
{browse chunsen.wu@rsyd.dk}


{title:Also see}

{p 7 14 2}
Help: {helpb mtab}, {helpb mtab1}, {helpb mtab2}, {helpb msum}, {helpb mest}, {helpb mmat}, and {helpb mobs}
{p_end}
