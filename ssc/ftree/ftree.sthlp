{smcl}
{* 06Feb2010}{* 1Oct2010}{* 22Dec2018}{...}
{hline}
help for {hi:ftree}{right: version 3.0}
{right:{stata ssc install ftree, replace: get the newest version}}
{hline}

{title:Directory Informations Saver}


{title:Description}


{p 4 4 2}
{cmd:ftree} save informations of the current directory into a txt file.


{title:Syntax}


{p 4 8 2}{cmd:ftree} {cmd:,} {cmdab:s:ave(}{it:filename}{cmd:)} [ {cmdab:p:ath(}{it:string}{cmd:)} {cmdab:d:ir(}{it:string2}{cmd:)} ] {p_end}


{synoptset 20 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{p2coldent :* {cmdab:s:ave(}{it:filename}{cmd:)}}name of the txt file {p_end}
{p2coldent :* {cmdab:p:ath(}{it:string1}{cmd:)}}directory where the txt file saved to{p_end}
{p2coldent :* {cmdab:d:ir(}{it:string2}{cmd:)}}can be specify as {it:d(dir)} {it:d(tree)} or {it:d(catalogue)} {p_end}
{synoptline}
{p2colreset}{...}


{title:Technical note}


{pstd} This program runs only on Windows System!{p_end}


{title:Examples}


{pstd}save informations of the current directory into txt file named {cmd:mydir} :{p_end}

{p 4 8 2}. {stata ftree, save(mydir)}{p_end}

{p 4 8 2}. {stata "ftree, save(mydir) path(d:\)"}{p_end}

{p 4 8 2}. {stata "ftree, s(mydir) p(d:\) d(dir)"}{p_end}

{p 4 8 2}. {stata "ftree, s(mydir) p(d:\) d(tree)"}{p_end}

{p 4 8 2}. {stata "ftree, s(mydir) p(d:\) d(catalogue)"}{p_end}


{title:Acknowledgments}


{pstd}I wish to thank Lian Yujun (Lingnan College, Sun Yat-Sen University) for his good advise {p_end}
{pstd}to add a new option of {it:d(catalogue)}.
{break}


{title:For problems and suggestions}


{pstd}
{cmd:Author: Liu wei}, The School of Sociology and Population Studies, Renmin University of China. {cmd:Address: }Zhongguancun Street No. 59, Haidian District, Beijing, China. {cmd:ZIP Code:} 100872. 
{cmd:E-mail:} {browse "mailto:liuv@ruc.edu.cn":liuv@ruc.edu.cn} {break}


{title:Also see}


{pstd}
Other Commands I have written: {p_end}

{synoptset 30 }{...}
{synopt:{help curvefit} (if installed)} {stata ssc install curvefit} (to install){p_end}
{synopt:{help deci} (if installed)} {stata ssc install deci} (to install){p_end}
{synopt:{help fdta} (if installed)} {stata ssc install fdta} (to install){p_end}
{synopt:{help ftrans} (if installed)} {stata ssc install ftrans} (to install){p_end}
{synopt:{help freplace} (if installed)} {stata ssc install freplace} (to install){p_end}
{synopt:{help elife} (if installed)} {stata ssc install elife} (to install){p_end}
{synopt:{help fren} (if installed)} {stata ssc install fren} (to install){p_end}
{synopt:{help equation} (if installed)} {stata ssc install equation} (to install){p_end}
{p2colreset}{...}

