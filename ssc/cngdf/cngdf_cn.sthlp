{smcl}
{* *! version 2.17  2021.02.3}{...}
{cmd:help cngdf}
{hline}

{title:Title}

{p2colset 5 18 18 2}{...}
{p2col :{cmd:cngdf} {hline 2}}自动计算任意基期的GDP平减指数！包括全国GDP平减指数与分省GDP平减指数。
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
必须包括year(int)选项,全国GDP平减指数范围为1978至2019年；分省GDP平减指数时间范围为1993至2019年。
{p_end}
{synopt:{cmdab:china}}
如果包含 china 选项，则计算全国GDP平减指数。如果不包含 china 选项,则计算分省GDP平减指数。
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

{pstd}例子1：计算以2000年为基期的分省GDP平减指数{p_end}

{phang2}. {stata "cngdf,year(2000)"}{p_end}
{phang2}. {stata "br"}{p_end}

{pstd}例子2：计算以2000年为基期的全国GDP平减指数{p_end}

{phang2}. {stata "cngdf,year(2000) china"}{p_end}

{pstd}例子3：计算以1978年为基期的全国GDP平减指数{p_end}

{phang2}. {stata "cngdf,year(1978) china"}{p_end}

{title:Author}

{phang}
{cmd:Bolin, Song (松柏林)} Shenzhen University, China. {cmd:wechat}：YJYSY91{break}
{p_end}