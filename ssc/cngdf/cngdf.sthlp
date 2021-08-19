{smcl}
{* *! version 2.17  2021.02.3}{...}
{cmd:help cngdf {stata "help cngdf_cn": Chinese Version}}
{hline}

{title:Title}

{p2colset 5 18 18 2}{...}
{p2col :{cmd:cngdf} {hline 2}}Automatically calculate any base period GDP deflator! Including national GDP deflator and provincial GDP deflator.
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 4} Full syntax

{p 8 14 2}
{cmd:cngdf}{cmdab:,year()}[{cmdab:china}]

{synoptset 14}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:year(int)}}
the {cmd:year(int)} option must exist. the national GDP deflator ranges from 1978 to 2019, and the provincial GDP deflator ranges from 1993 to 2019.
{p_end}
{synopt:{cmdab:china}}
if {cmd:china} option is specified, the national GDP deflator is calculated. if {cmd:china} option is not specified,, the provincial GDP deflator is calculated.
{p_end}
{synoptline}

{marker description}{...}
{p 4} Quick syntax

{p 8 14 2}
{cmd:. cngdf}

{p 8 14 2}
{cmd:. cngdf,year(2000)}

{p 8 14 2}
{cmd:. cngdf,year(2000) china}
	
{marker Examples}{...}
{title:Examples}

{pstd}

{pstd}Calculate the provincial GDP deflator based on the year 2000{p_end}

{phang2}. {stata "cngdf,year(2000)"}{p_end}
{phang2}. {stata "br"}{p_end}

{pstd}Calculate the national GDP deflator based on the year 2000{p_end}

{phang2}. {stata "cngdf,year(2000) china"}{p_end}

{pstd}Calculate the national GDP deflator based on 1978{p_end}

{phang2}. {stata "cngdf,year(1978) china"}{p_end}

{title:Author}

{phang}
{cmd:Bolin, Song (松柏林)} Shenzhen University, China. {cmd:wechat}：YJYSY91{break}
{p_end}
