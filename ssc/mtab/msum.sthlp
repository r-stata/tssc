{smcl}
{* 26/Oct/2020}{...}
{vieweralsosee "[R] summarize" "help summarize"}{...}
{cmd:help msum}{right: ({browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":User-written stata packages: mtab})}
{hline}

{title:Title}

{p 4 4 2}{hi:msum} {hline 2} Store the results in {helpb matrix} for a continous variables

{title:Syntax}

{p 8 17 2}
{cmd:msum}
{helpb varlist}
{ifin}
[{cmd:,} {it:options }
]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opth by:(varlist:groupvar)}}variable defining the groups{p_end}
{synopt :{opt d:etail}}display additional statistics{p_end}
{synopt :{opt m:issing}}treat missing values like other values{p_end}
{synoptline}


{title:Description}

{pstd}
Command {helpb msum} Store the results of mean, standard deviation, quantitles in {helpb matrix}.{p_end}


{title:Options} 

{phang} 
{opth by:(varlist:groupvar)} specifies the {it:groupvar} that defines the two
groups that {opt ttest} will use to test the hypothesis that their means are
equal.  Specifying {opt by(groupvar)} implies an unpaired (two sample) t test.
Do not confuse the {opt by()} option with the {cmd:by} prefix; you can specify
both.

{phang} 
{opt detail} produces additional statistics, including skewness, kurtosis, the four smallest and four largest
        values, and various percentiles.
		
{phang} 
{opt missing} requests that missing values be treated like other values in calculations of counts, percentages.


{title:Examples}

{pstd}

{phang} 1. load an oneline data {p_end}
{phang}{stata "webuse lbw": .webuse lbw} {p_end}

{phang} 2. Store the results (mean, sd, quantitles){p_end}
{phang}{stata "msum bwt": .msum bwt } {p_end}
{phang}{stata "msum bwt, by(smoke)": .msum bwt, by(smoke) } {p_end}
{phang}{stata "msum bwt, by(race)": .msum bwt, by(race) } {p_end}

{title:More examples} click on {browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":her}


{title:Author}

{pstd}
Chunsen Wu, the University of Southern Denmark; Odense University Hospital, Denmark{break} 
{browse cwu@health.sdu.dk}{break} 
{browse chunsen.wu@rsyd.dk}


{title:Also see}

{p 7 14 2}
Help: {helpb mtab}, {helpb mtab1}, {helpb mtab2}, {helpb mest}, {helpb mmat}, {helpb mexcel}, and {helpb mobs}
{p_end}
