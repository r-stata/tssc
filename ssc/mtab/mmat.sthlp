{smcl}
{* 26/Oct/2020}{...}
{vieweralsosee "[R] tab1" "help matrix"}{...}
{cmd:help mmat}{right: ({browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":User-written stata packages: mtab})}
{hline}

{title:Title}

{p 4 4 2}{hi:mmat} {hline 2} Extract the results from an existing {helpb matrix} to a new {helpb matrix}


{title:Syntax}

{p 8 17 2}
{cmd:mmat}
{helpb namelist}
[{cmd:,} {it:options}
]

{p 8 17 2}
{helpb namelist} indicates name of the original matrix, which is highly recommended to be named as a capital letter for example A, K, T etc. except for the capital letter B.


{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt R:ow}}indicates the list of rows in the original matrix that should be extracted to a new {helpb matrix}.{p_end}
{synopt :{opt C:ol}}indicates the list of columns  in the original matrix that should be extracted to a new {helpb matrix}.{p_end}
{synoptline}


{title:Description}

{pstd}
Command {helpb mmat} Extract the results from an existing {helpb matrix} to a new {helpb matrix}.{p_end}


{title:Options} 

{phang} 
{opt col} specify a list of rows that should be extracted to a new {helpb matrix}.

{phang} 
{opt col} specify a list of columns that should be extracted to a new {helpb matrix}.


{title:Examples}

{pstd}

{phang} 1. make up a matrix {p_end}
{phang}{stata "mat X=(1,2,3,4,5,6\7,8,9,10,11,12\13,14,15,16,17,18\19,20,21,22,23,24)": .mat X=(1,2,3,4,5,6\7,8,9,10,11,12\13,14,15,16,17,18\19,20,21,22,23,24)} {p_end}
{phang}{stata "mat list X": .mat list X} {p_end}

{phang} 2. Extract the rows (1 2 3) and columns (3 4 5){p_end}
{phang}{stata "mmat X, r(1/3) c(3/5)": .mmat X, r(1/3) c(3/5)} {p_end}

{phang} 3. Extract the rows (1 3) and columns (3 5){p_end}
{phang}{stata "mmat X, r(1 3) c(4 5)": .mmat X, r(1 3) c(3 5)} {p_end}

{phang} 4. Extract all from the fifth column{p_end}
{phang}{stata "mmat X, r(1/4) c(5)": .mmat X, r(1/4) c(5)} {p_end}

{phang} 5. Extract all from the thrid row{p_end}
{phang}{stata "mmat X, r(3) c(1/6)": .mmat X, r(3) c(1/6)} {p_end}

{title:More examples} click on {browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":her}


{title:Author}

{pstd}
Chunsen Wu, the University of Southern Denmark; Odense University Hospital, Denmark{break} 
{browse cwu@health.sdu.dk}{break} 
{browse chunsen.wu@rsyd.dk}


{title:Also see}

{p 7 14 2}
Help: {helpb mtab}, {helpb mtab1}, {helpb mtab2}, {helpb msum}, {helpb mest}, {helpb mexcel}, and {helpb mobs}
{p_end}
