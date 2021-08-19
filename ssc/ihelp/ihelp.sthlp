{smcl}
{* 15June2021}{...}
{cmd:help ihelp {stata "help ihelp_cn": Chinese Version}}{right: }
{hline}

{title:Title}

{p2colset 5 14 14 2}{...}
{p2col:{hi:ihelp} {hline 2}} Display the help documents in PDF format using the default browser {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:ihelp} {cmd:}{it:command_name} [{cmd:,}
{opt m:arkdown}
{opt w:eixin}
{opt c:lipoff}]


{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt m:arkdown}}display the link containing help documents via markdown and copy the contents to the clipboard{p_end}
{synopt:{opt w:eixin}}display the link containing help documents via command:URL and copy the contents to the clipboard{p_end}
{synopt:{opt c:lipoff}}deselect copying to the clipboard{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{title:Description}

{pstd}
{cmd:ihelp} displays the help documents of the specified commands via browsers. {helpb help} displays the help documents in a simple but inconvenient manner, while Stata manual offers detailed command instructions, 
and the relevant PDF formats also have better reading experiences. {helpb ihelp} can open more detailed help documents in PDF format via the browser, which can facilitate reading and translation; it can also list commands
similar to the specified command from the Stata manual.{p_end}


{title:Options}

{phang}
{opt markdown} display the link containing help documents via markdown and copy the contents to the clipboard

{phang}
{opt wexin} display the link containing help documents via command:URL and copy the contents to the clipboard

{phang}
{cmd:clipoff} deselect copying to the clipboard


{title:Examples}

{phang}* {ul:Basic function}: open help document

{phang2}{inp:.} {stata "ihelp pwcorr":ihelp pwcorr}{p_end}
{phang2}{inp:.} {stata "ihelp clip()":ihelp clip()}{p_end}
{phang2}{inp:.} {stata "ihelp twoway scatter":ihelp twoway scatter}{p_end}
{phang2}{inp:.} {stata "ihelp sum":ihelp sum}{p_end}
{phang2}{inp:.} {stata "ihelp tab":ihelp tab}{p_end}

{phang}* {ul:Auxiliary function}: output link

{phang2}{inp:.} {stata "ihelp twoway scatter, m":ihelp twoway scatter, m}{p_end}
{phang2}{inp:.} {stata "ihelp import excel, w":ihelp import excel, w}{p_end}


{title:Stored results}

{pstd}
You can view the stored results through {stata "return list": return list} (see {help return}) after using {cmd:ihelp}:

{synoptset 15 tabbed}{...}
{synopt:{cmd:. r(link)}}Link to Help file (URL){p_end}
{synopt:{cmd:. r(link_m)}}Link to Help file (Markdown format){p_end}
{synopt:{cmd:. r(link_w)}}Link to Help file (Command:URL format){p_end}


{title:Author}

{pstd} {cmd:Yujun, Lian* (连玉君)}{p_end}
{pstd} . Lingnan College, Sun Yat-Sen University, China. {p_end}
{pstd} . E-mail: {browse "mailto:arlionn@163.com":arlionn@163.com} {p_end}
{pstd} . Blog: {browse "lianxh.cn":https://www.lianxh.cn}.{p_end}

{pstd} Yongli, Chen (陈勇吏) {p_end}
{pstd} . Antai College of Economics and Management, Shanghai Jiao Tong University, China.{p_end}
{pstd} . E-mail: {browse "mailto:yongli_chan@163.com":yongli_chan@163.com}{p_end}


{title:Also see}

{pstd} Online: {help help}{p_end}

