{smcl}
{* 26/Oct/2020}{...}
{vieweralsosee "[R] tab2" "help tab2"}{...}
{cmd:help mtab2}{right: ({browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":User-written stata packages: mtab})}
{hline}

{title:Title}

{p 4 4 2}{hi:mtab2} {hline 2} Store the results (frequencies and percentages) in {helpb matrix} for two-way table

{title:Syntax}

{p 8 17 2}
{cmd:mtab2}
{helpb varlist}
{ifin}
[{cmd:,} {it:options}
]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt nol:abel}}display numeric codes rather than value labels{p_end}
{synopt :{opt m:issing}}treat missing values like other values{p_end}
{synopt :{opt r:ow}}report relative frequency within its row of each cell{p_end}
{synopt :{opt c:ol}}report relative frequency within its column of each cell{p_end}
{synoptline}

{title:Description}

{pstd}
Command {helpb mtab2} makes a two-way table and store the results (frequencies and percentages) in {helpb matrix}.{p_end}

{title:Options} 

{phang} 
{opt nolabel} causes the numeric codes to be displayed rather than the value labels.

{phang} 
{opt missing} requests that missing values be treated like other values in calculations of counts, percentages.

{phang} 
{opt row} displays the relative frequency of each cell within its row in a two-way table.

{phang} 
{opt col}  displays the relative frequency of each cell within its column in a two-way table.


{title:Examples}

{pstd}

{phang} 1. load an oneline data {p_end}
{phang}{stata "webuse lbw": .webuse lbw} {p_end}

{phang} 2. makes an one-way table and store the results (frequencies and percentages){p_end}
{phang}{stata "mtab2 smoke low": .mtab2 smoke low} {p_end}
{phang}{stata "mtab2 smoke low, row": .mtab2 smoke low, row} {p_end}
{phang}{stata "mtab2 smoke low, col": .mtab2 smoke low, col} {p_end}

{title:More examples} click on {browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":her}


{title:Author}

{pstd}
Chunsen Wu, the University of Southern Denmark; Odense University Hospital, Denmark{break} 
{browse cwu@health.sdu.dk}{break} 
{browse chunsen.wu@rsyd.dk}


{title:Also see}

{p 7 14 2}
Help: {helpb mtab}, {helpb mtab1}, {helpb msum}, {helpb mest}, {helpb mmat}, {helpb mexcel}, and {helpb mobs}
{p_end}
