{smcl}
{* *! version 1.0 Jul2016}{...}
{cmd:help tab2mat}
{hline}


{marker syntax}{...}
{title:Syntax}


{p 8 18 2}
{cmd:tab2mat} {it: {help varname}} 
{ifin}
[{it:{help summarize##weight:weight}}]
{cmd:,}
{bf:matrix(}{it:matname}{bf:)}
[{it:{help rcolp2mat##s_0:options}}]


{marker s_0}

{synoptset 18 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:required}

{synopt:{opt matrix(matname)}}indicate name of matrix for saved results {p_end}


{syntab:optional}

{synopt:{opt nomiss}}exclude missing values{p_end}
{synopt:{opt nofreq}}exclude frequency column{p_end}
{synopt:{opt noperc}}exclude percent column{p_end}
{synopt:{opt total}}add row with total{p_end}
{synoptline}




{marker description}{...}
{title:Description}

{pstd}
{opt tab2mat} produces a one-way table and saves results in a matrix with appropriate labels. Saved matrix can easily be exported to excel (see {it:{help putexcel}}).




{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse nlsw88.dta}{p_end}
{phang}{cmd:. tab2mat race,   matrix(A)}{p_end}
{phang}{cmd:. tab2mat race,   matrix(A) nofreq}{p_end}
{phang}{cmd:. tab2mat union, matrix(A) noperc}{p_end}
{phang}{cmd:. tab2mat union, matrix(A) nomiss}{p_end}
{phang}{cmd:. tab2mat union, matrix(A) nomiss nofreq total}{p_end}


{title:Author}

        Loris P. Fagioli, Irvine Valley College, CA
	lfagioli@ivc.edu



