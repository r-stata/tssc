{smcl}
{* *! version 1.0.0 30mar2021}{...}
{cmd:help sbldo}
{hline}

{pstd}

{title:Title}

{p2colset 5 16 16 2}{...}
{ p2col:{hi: sbldo} {hline 2} }Access Stata do-files of songbl command, 
see {stata "help songbl":songbl}.{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:sbldo}
[
{it:filename}  
{cmd:,}
{cmd:no}
{cmd:replace} 
]

{p 2 8 2}

{synoptset 10}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:no}}
Do not open the dofile.
{p_end}
{synopt:{cmdab:replace}}
Overwrite the dofile with same filename as the dofile loaded. 
{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}{cmd:sbldo} can download and open the do-file of songbl command. When users search the do-file with {stata "help songbl_cn":songbl}  command, they can download and open it with {cmd:sbldo} command. 
In addition, {cmd:sbldo}  can also download and open do-files on the network, such as do-files saved on GitHub or Gitee.

{title:Examples} 

{phang}{stata "sbldo prof" : . sbldo prof}{p_end}
{phang}{stata "sbldo prof,no" : . sbldo prof,no}{p_end}
{phang}{stata "sbldo prof,replace" : . sbldo prof,replace}{p_end}
{phang}{stata "sbldo https://gitee.com/songbolin/stata_do/raw/master/iv.do" : . sbldo https://gitee.com/songbolin/stata_do/raw/master/iv.do}{p_end}

{title:Author}

{phang}
{cmd:Bolin, Song (松柏林)} Shenzhen University, China. {cmd:wechat}：songbl_stata{break}
{p_end}

{title:Other Commands}
{pstd}

{synoptset 30 }{...}
{synopt:{help lianxh} (if installed)} {stata ssc install lianxh} (to install){p_end}
{synopt:{help songbl} (if installed)} {stata ssc install songbl} (to install){p_end}
{synopt:{help cngdf } (if installed)} {stata ssc install cngdf } (to install){p_end}
{p2colreset}{...}


