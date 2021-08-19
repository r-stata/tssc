
{smcl}
{* 26/Oct/2020}{...}
{vieweralsosee "[U] System variables" "help _variables"}{...}
{cmd:help mobs}{right: ({browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":User-written stata packages: mtab})}
{hline}

{title:Title}

{p 4 4 2}{hi:mobs} {hline 2} Store the results (number of repeated observations within specified variable categories) in {helpb matrix}


{title:Syntax}

{p 8 17 2}
{cmd:mobs}
{helpb varlist}
{ifin}
[{cmd:,} {it:options}
]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt l:evel}}specify level/number of variables. the default is 1{p_end}
{synoptline}

{title:Description}

{pstd}
Command {helpb mobs} generates two variables {it: obs} {it: obst} which indicate the number of repeated observations in each categories.{p_end}


{title:Options} 

{phang} 
{opt level} specify number of variables to be conditioned on while count the number of repeated observations within each joined categories. 




{title:Examples}

{pstd}

{phang} 1. load an oneline data {p_end}
{phang}{stata "webuse nlswork": .webuse nlswork} {p_end}

{phang} 2. Count the number of repeated observations within each id{p_end}
{phang}{stata "mobs idcode year": .mobs idcode year} {p_end}
{phang}After run the above command, you will discover how many repeated given the same {it:idcode} {p_end}
{phang}{stata "mobs idcode year, level(2)": .mobs idcode year, level(2)} {p_end}
{phang}After run the above command, you will discover how many repeated given the same {it:idcode} and the same {it:year}{p_end}



{title:More examples} click on {browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":her}


{title:Author}

{pstd}
Chunsen Wu, the University of Southern Denmark; Odense University Hospital, Denmark{break} 
{browse cwu@health.sdu.dk}{break} 
{browse chunsen.wu@rsyd.dk}


{title:Also see}

{p 7 14 2}
Help: {helpb mtab}, {helpb mtab1}, {helpb mtab2}, {helpb msum}, {helpb mest}, {helpb mmat}, and {helpb mexcel}{p_end}
