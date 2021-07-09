{smcl}
{* *! bhatt version 1.0 October 2015 by Graham K. Brown}{...}
{cmd:help bhatt}{right: ({browse "http://www.grahamkbrown.net":grahamkbrown.net})}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col: {hi:bhatt} {hline 2}}Calculates the Bhattacharyya Coefficient and Bhattacharyya Distance measures 
of overlap between two population distributions{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:bhatt}
{varname}
{ifin}{cmd:,}
{cmd:group(}{it:groupvar}{cmd:)}
{cmd:[ bin(#) ]}

{synoptset 15 tabbed}{...}
{synopthdr:options}
{synoptline}
{p2coldent :* {opt group()}}variable defining the groups{p_end}
{synopt:{opt bin()}}specify number of bins to be used{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt group()} is required.{p_end}
{p 4 6 2}{varname} specifies the variable along which distribution is to be compared.{p_end}
{p 4 6 2}
{it:groupvar} specifies the variable that identifies the groups to be compared. 


{title:Description}

{pstd}
{opt bhatt} calculates the Bhattacharyya Coefficient (BC) and Bhattacharyya Distance (BD) for 
comparing the degree of overlap between two distributions (see Bhattacharyya 1943).  The Bhattacharyya Coefficient 
divides the overall distribution into a number of bins, and compares the proportion of each group within each bin.  It ranges 
from 0 to 1, where 0 indicates no overlap between the two group distributions and 1 indicates complete overlap.  The Bhattacharyya Distance 
is a natural log transformation of BC.

{pstd}
For {it:i}=1/{it:N} bins, BC is calculated as the sum of sqrt[{it:p}({it:i}){it:q}({it:i})], where {it:p}({it:i}) and {it:q}({it:i}) are, repsectively, the proportion of groups 
{it:p} and {it:q} in bin {it:i}. BD is given by the formula BD=-ln(BC).


{title:Options}

{phang}
{cmd:group(}{it:groupvar}{cmd:)} 
specifies the variable that identifies the two groups to be compared.  {it:groupvar} must identify exactly two groups.

{phang}
{cmd:bin(#)}
specifies the number of bins the overall distribution is to be divided into.  If {cmd:bin(#)} is not specified, 
a default value of 10 is used. 

{title:Saved results}

{pstd}
{cmd:bhatt} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(bc)}}Bhattacharyya Coefficient{p_end}
{synopt:{cmd:r(bd)}}Bhattacharyya Distance{p_end}

{title:Author}

{pstd}Graham K. Brown{p_end}
{pstd}Professor of International Development{p_end}
{pstd}University of Western Australia{p_end}
{pstd}Perth, Australia{p_end}
{pstd}graham.brown@uwa.edu.au{p_end}

{title:References}

{p 4 14 2}Article:  Bhattacharyya, A. (1943) 'On a measure of divergence between two statistical populations 
defined by their probability distributions' {it:Bulletin of the Calcutta Mathematical Society}, volume 35, pp. 99-109: {browse "http://www.ams.org/mathscinet-getitem?mr=0010358":MR0010358}


