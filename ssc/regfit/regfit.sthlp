{smcl}

{hline}
help for {hi:regfit}{right: version 3.0}
{right:{stata ssc install regfit, replace: get the newest version}}
{hline}

{title:Output The Equation of a Regression}


{title:Description}


{p 4 4 2}
{cmd:regfit} gives the equation after a regression.

{title:Syntax}


{p 4 8 2}{cmd:regfit} {cmd:,} [ {cmdab:f:ormat(}{it:{help %fmt}}{cmd:)} ] {p_end}


{synoptset 20 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{p2coldent :* {cmdab:f:ormat(}{it:{help %fmt}}{cmd:)}}specifies the output format of coefficients, defoult is {cmd:%4.2f} {p_end}
{synoptline}
{p2colreset}{...}


{title:Examples}


{p 4 8 2}. {stata sysuse auto}{p_end}

{p 4 8 2}. {stata reg price weight length i.foreign}{p_end}

{p 4 8 2}. {stata regfit}{p_end}

{p 4 8 2}. {stata regfit, f(%4.3f)}{p_end}

{p 4 8 2}. {stata reg price weight length i.foreign i.rep78 mpg trunk turn displacement gear_ratio}{p_end}

{p 4 8 2}. {stata regfit}{p_end}

{p 4 8 2}. {stata webuse nlswork}{p_end}

{p 4 8 2}. {stata xtreg ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure c.tenure#c.tenure 2.race not_smsa south, be}{p_end}

{p 4 8 2}. {stata regfit}{p_end}


{title:Author}

{phang}
{cmd:Liu wei}, The School of Sociology and Population Studies, Renmin University of China. {break}
E-mail: {browse "mailto:liuv@ruc.edu.cn":liuv@ruc.edu.cn} {break}
{p_end}

{phang}
{cmd:Yujun,Lian (Arlionn)} Department of Finance, Lingnan College, Sun Yat-Sen University.{break}
E-mail: {browse "mailto:arlionn@163.com":arlionn@163.com}. {break}
Blog: {browse "https://www.lianxh.cn":https://www.lianxh.cn} {break}
{p_end}


{title:Also see}

{pstd}
Other Commands We have written: {p_end}

{synoptset 30 }{...}
{synopt:{help curvefit} (if installed)} {stata ssc install curvefit} (to install){p_end}
{synopt:{help deci} (if installed)} {stata ssc install deci} (to install){p_end}
{synopt:{help elife} (if installed)} {stata ssc install elife} (to install){p_end}
{synopt:{help ftrans} (if installed)} {stata ssc install ftrans} (to install){p_end}
{synopt:{help freplace} (if installed)} {stata ssc install freplace} (to install){p_end}
{synopt:{help ftree} (if installed)} {stata ssc install ftree} (to install){p_end}
{synopt:{help fren} (if installed)} {stata ssc install fren} (to install){p_end}
{synopt:{help fdta} (if installed)} {stata ssc install fdta} (to install){p_end}
{synopt:{help bdiff} (if installed)} {stata ssc install bdiff} (to install){p_end}
{synopt:{help winsor2} (if installed)} {stata ssc install winsor2} (to install){p_end}
{synopt:{help hhi5} (if installed)} {stata ssc install hhi5} (to install){p_end}
{synopt:{help uall} (if installed)} {stata ssc install uall} (to install){p_end}
{synopt:{help xtbalance} (if installed)} {stata ssc install xtbalance} (to install){p_end}
{p2colreset}{...}

