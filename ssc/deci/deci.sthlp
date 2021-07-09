{smcl}
{* 24Mar2010}{* 20Oct2010}{...}
{hline}
help for {hi:deci}{right: version 2.0}
{right:{stata ssc install deci, replace: get the newest version}}
{hline}


{title:Variable Base conversion}


{title:Description}


{pstd}
{cmd:deci} provides a base conversion within various number system, for example, decimal, binary, hexadecimal, octal etc, which is based on the command 
{help inbase} and {help inten}.

{pstd}
{cmd:Note}: {stata help varlist:{it:varlist}}'s missing values will be droped.


{title:Syntax}


{p 4 4 2}
{cmd:deci}
{stata help varlist:{it:varlist}} 
{cmd:,} {cmdab:f:rom(}{it:numeric}{cmd:)} {cmdab:t:o(}{it:numeric}{cmd:)} [{cmdab:g:enerate(}{it:string}{cmd:)}]{break}

{synoptset 20 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{p2coldent :* {cmdab:f:rom(}{it:numeric}{cmd:)}}{it:varlist} number system, which must in range [2,62].{p_end}
{p2coldent :* {cmdab:t:o(}{it:numeric}{cmd:)}}the new number system, which must in range [2,62].{p_end}
{p2coldent :* {cmdab:g:enerate(}{it:string}{cmd:)}}create a new variable. when left blank, {it:varlist} will be replaced.{p_end}
{synoptline}
{p2colreset}{...}

{pstd}

{title:Examples}


{phang}. {stata clear all}

{phang}. {stata set obs 1000}

{phang}. {stata gen x1=int(1000*runiform())}

{phang}. {stata gen str3 x2=string(x1)}

{phang}. Convert variable '{cmd:x1}' from {cmd:decimal} system to {cmd:binary} system and generate a new veriable '{cmd:x1_1}':

{phang}. {stata deci x1, f(10) t(2) gen(x1_1)}

{phang}. Convert variable '{cmd:x2}' from {cmd:decimal} system to {cmd:octal} system:

{phang}. {stata deci x2, f(10) t(8)}

{phang}. Convert variable '{cmd:x2}' from {cmd:octal} system to {cmd:binary} system and generate a new veriable '{cmd:x2_1}':

{phang}. {stata deci x2, f(8) t(2) g(x2_1)}

{phang}. Convert variable '{cmd:x2_1}' from {cmd:binary} system to {cmd:hexadecimal} system:

{phang}. {stata deci x2_1, f(2) t(16)}


{title:Bugs}

{pstd}
{cmd:deci} does not verify that you do not use digits beyond the base.
For instance, you can type '{cmd:deci x, f(16) t(10)}' while x[1]='1g'.


{title:For problems and suggestions}


{pstd}
{cmd:Author: Liu wei}, The School of Sociology and Population Studies, Renmin University of China. {cmd:Address: }Zhongguancun Street No. 59, Haidian District, Beijing, China. {cmd:ZIP Code:} 100872. 
{cmd:E-mail:} {browse "mailto:liuv@ruc.edu.cn":liuv@ruc.edu.cn} {break}


{title:Also see}


{pstd}
Other Commands I have written: {p_end}

{synoptset 30 }{...}
{synopt:{help curvefit} (if installed)} {stata ssc install curvefit} (to install){p_end}
{synopt:{help fdta} (if installed)} {stata ssc install fdta} (to install){p_end}
{synopt:{help ftrans} (if installed)} {stata ssc install ftrans} (to install){p_end}
{synopt:{help freplace} (if installed)} {stata ssc install freplace} (to install){p_end}
{synopt:{help elife} (if installed)} {stata ssc install elife} (to install){p_end}
{synopt:{help ftree} (if installed)} {stata ssc install ftree} (to install){p_end}
{synopt:{help fren} (if installed)} {stata ssc install fren} (to install){p_end}
{synopt:{help equation} (if installed)} {stata ssc install equation} (to install){p_end}
{p2colreset}{...}

