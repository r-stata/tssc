{smcl}
{* *! version 1.14 19May2021}{...}
{cmd:help for imusic}
{hline}


{title:Title}

{p2colset 5 16 16 2}{...}
{p2col:{hi: imusic} {hline 2}}Find music and enjoy while working on Stata.{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 4 14 2}
{cmd:imusic}
{bind:[{it:keywords},}
{cmdab:l:ist(#)}
{cmdab:p:latform}
{cmdab:br:owse}
{cmdab:s:top}
{cmdab:k:ind}
{cmdab:l:ink}
{cmdab:s:top}
{cmdab:m:arkdown}
{cmdab:a:utoplay}
{bind:{cmdab:nd:escription}]}


{marker description}{...}
{title:Description}

{pstd}
{bf:imusic} let you search what you would like to listen and play it online or locally in Stata without affecting your work.

{pstd}
This gadget has been tested for China users. The songs mainly come from two Chinese online music platforms:
one is Tencent music ({browse "https://y.qq.com/":https://y.qq.com}), and the other is Netease music ({browse "https://music.163.com/":https://music.163.com/}).
For users outside China, we haven't tested it yet. If you encounter any problems in using {bf:imusic},
or you want to add new music platform to {bf:imusic}, please email us.{p_end} 


{title:Options}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt  l:ist(#)}}Display # results in result window. The default is 1.{p_end}

{synopt:{opt  p:latform(string)}}Specify which music platform to be searched.{p_end}
{p 26 4 2}Specify {cmdab:p(t)} or {cmdab:p(T)} means Tencent music ({browse "https://y.qq.com/":https://y.qq.com}).{p_end}
{p 26 4 2}Specify {cmdab:p(n)} or {cmdab:p(N)} means Netease music ({browse "https://music.163.com/":https://music.163.com/}).{p_end}
{p 26 26 2}Specify {cmdab:p(l)} or {cmdab:p(L)} means your local music folder.
In this case, you should execute {cmd:global songpath "D:\music"} before using {cmd:imusic},
where {bf:"D:\music"} should be replaced with your own forlder path.{p_end}
			
{synopt:{opt  br:owse}}Open the link directly in your web browser. Only for {cmd:p(t/T)} or {cmd:p(n/N)}.{p_end}

{synopt:{opt  s:top}}Stop the music if {bf:p(l/L)}. Only for Windows(groove.exe or QQMusic.exe){p_end}

{synopt:{opt  k:ind}}Specify which type you're searching, default is single.{p_end}
{p 26 4 2}single=1; album=10; songlist=1000; Radio=1009; MV=1014{p_end}
{p 26 4 2}MV is not available for Netease; songlist & radio is not available for Tencent{p_end}

{synopt:{opt  l:ink}}Show link.{p_end}

{synopt:{opt  n:l}}Do not show lyrics.{p_end}

{synopt:{opt  m:arkdown}}Show link in markdown format.{p_end}

{synopt:{opt  a:utoplay}}Browse a website that can autoplay music.{p_end}
{p 26 4 2}Isn't available when search non-single on Tencent{p_end}

{synopt:{opt  nd:escription}}Do not show description.{p_end}
					
{synoptline}


{title:Examples}

{pstd}Show me a song randomly{p_end}

{phang2}. {stata "imusic"}{p_end}

{pstd}List one song with keyword "海阔天空"{p_end}

{phang2}. {stata "imusic 海阔天空"}{p_end}   

{pstd}List 10 songs with keyword "see you again"{p_end}

{phang2}. {stata "imusic see you again, l(10)"}{p_end}   

{pstd}List 5 songs with keyword "see you again" in Markdown format{p_end}

{phang2}. {stata "imusic see you again, l(5) m"}{p_end}   

{pstd}List 5 songs with keyword "梁祝" from platform Tencent  ({browse "https://music.163.com/":https://music.163.com/}){p_end}

{phang2}. {stata "imusic 梁祝, l(5) p(t)"}{p_end}   

 
{title:Shortcoming}

{pstd}platform(l) is not available when Mac system or default music player is Netease.{p_end}
{pstd}It'll take some time when you want to listen to a random song.{p_end}


{title:Acknowledgement}

{p 4 8 2}
Codes from {help sxpose} by Prof. N.J. Cox have been incorporated.


{title:Author}

{phang}
{cmd:Jingyi, Zheng (郑静怡)} Lingnan College, Sun Yat-Sen University, China.{break}
E-mail: {browse "mailto:zhengjy57@sysu.edu.cn":zhengjy57@sysu.edu.cn} {break}
{p_end}

{phang}
{cmd:Yujun, Lian* (连玉君)} Lingnan College, Sun Yat-Sen University, China.{break}
E-mail: {browse "mailto:arlionn@163.com":arlionn@163.com} {break}
Blog: {browse "https://www.lianxh.cn":lianxh.cn} {break}
{p_end}


{title:Support}
	
{pstd}Please visit {browse "https://gitee.com/arlionn/imusic":https://gitee.com/arlionn/imusic}.{p_end}

{pstd}To uninstall, you can use 
{stata ado uninstall imusic }{p_end}

