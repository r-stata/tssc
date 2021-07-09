{smcl}
{* *! version 1.0 Jul2016}{...}
{cmd:help rcolp2mat}
{hline}


{marker syntax}{...}
{title:Syntax}


{p 8 18 2}
{cmd:rcolp2mat} 
{it:{help varname:varname1}}
{it:{help varname:varname2}}
{ifin}
[{it:{help tabulate twoway##weight:weight}}]
{cmd:,}
{bf:matrix(}{it:matname}{bf:)}
{bf: row col}
[{it:{help rcolp2mat##s_0:options}}]




{marker s_0}

{synoptset 18 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:required}

{synopt:{opt matrix(matname)}}indicate name of matrix for saved results {p_end}
{synopt:{opt row col}}create row or column percentages. Only one selection allowed {p_end}

{syntab:optional}

{synopt:{opt total}}add row with total % (cannot be used with {bf:detail}){p_end}
{synopt:{opt detail}}add row and column Ns (cannot be used with {bf:total}){p_end}
{synopt:{opt missing}}treat missing values like other values{p_end}
{synoptline}




{marker description}{...}
{title:Description}

{pstd}
{opt rcolp2mat} produces a two-way table with row or column percentages and saves results in a matrix with appropriate labels. Saved matrix can easily be exported to excel (see {it:{help putexcel}}).




{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse nlsw88.dta}{p_end}
{phang}{cmd:. rcolp2mat race union, matrix(A) row}{p_end}
{phang}{cmd:. rcolp2mat race union, matrix(A) row total}{p_end}
{phang}{cmd:. rcolp2mat race union, matrix(A) col detail}{p_end}
{phang}{cmd:. rcolp2mat race union, matrix(A) col total missing}{p_end}

{title:Author}

        Loris P. Fagioli, Irvine Valley College, CA
	lfagioli@ivc.edu


{title:Acknowledgement}

        The subroutine -matcrename- in this program is based on Nick Cox's code and can be found {browse "http://www.stata.com/statalist/archive/2006-11/msg00537.html":here}


