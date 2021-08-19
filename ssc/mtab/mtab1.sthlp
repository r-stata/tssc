{smcl}
{* 26/Oct/2020}{...}
{vieweralsosee "[R] tab1" "help tab1"}{...}
{cmd:help mtab1}{right: ({browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":User-written stata packages: mtab})}
{hline}

{title:Title}

{p 4 4 2}{hi:mtab1} {hline 2} Store the results (frequencies and percentages) in {helpb matrix} for one-way table

{title:Syntax}

{p 8 17 2}
{cmd:mtab1}
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
{synoptline}

{title:Description}

{pstd}
Command {helpb mtab1} makes an one-way table and store the results (frequencies and percentages) in {helpb matrix}.{p_end}


{title:Options} 

{phang} 
{opt nolabel} causes the numeric codes to be displayed rather than the value labels.

{phang} 
{opt missing} requests that missing values be treated like other values in calculations of counts, percentages.




{title:Examples}

{pstd}

{phang} 1. load an oneline data {p_end}
{phang}{stata "webuse lbw": .webuse lbw} {p_end}

{phang} 2. makes an one-way table and store the results (frequencies and percentages){p_end}
{phang}{stata "mtab1 smoke": .mtab1 smoke} {p_end}
{phang}{stata "mtab1 low": .mtab1 low} {p_end}
{phang}{stata "mtab1 low if smoke==1": .mtab1 low if smoke==1} {p_end}

{title:More examples} click on {browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":her}


{title:Author}

{pstd}
Chunsen Wu, the University of Southern Denmark; Odense University Hospital, Denmark{break} 
{browse cwu@health.sdu.dk}{break} 
{browse chunsen.wu@rsyd.dk}


{title:Also see}

{p 7 14 2}
Help: {helpb mtab}, {helpb mtab2}, {helpb msum}, {helpb mest}, {helpb mmat}, {helpb mexcel}, and {helpb mobs}
{p_end}
