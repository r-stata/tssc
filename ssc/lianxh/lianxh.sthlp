{smcl}
{* *! version 3  11Apr2021}{...}
{cmd:help lianxh {stata "help lianxh_cn": Chinese Version}}
{hline}

{title:Title}

{p2colset 5 16 16 2}{...}
{p2col:{hi: lianxh} {hline 2}}Search and share Stata resources and blogs within Stata Command Window.{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 4} Quick syntax

{p 8 14 2}
{cmd:. lianxh}

{p 8 14 2}
{cmd:. lianxh all}

{p 4} Full syntax

{p 8 14 2}
{cmd:lianxh}
{bind:[{it:keywords},}
{cmdab:m:link}
{cmdab:mt:ext}
{cmdab:w:eixin}
{cmdab:s:aving(}{it:string}{cmd:)}
{cmdab:cls}
{cmdab:noc:at}
{bind:{cmdab:c:atfirst}]}

{p 8 14 2}

{synoptset 14}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:m:link}}
List markdown text in form of item for blog posts
{p_end}
{synopt:{cmdab:mt:ext}}
List markdown text for blog posts
{p_end}
{synopt:{cmdab:w:eixin}}
List blog posts in form of Wechat (Weixin): BlogTitle: URL
{p_end}
{synopt:{cmdab:s:aving(}{it:string}{cmd:)}}
Save the 
The retrieval result is saved as a markdown / CSV / TXT document with the specified name
{p_end}
{synopt:{cmdab:cls}}
Display the result after clearing the Results window
{p_end}
{synopt:{cmdab:noc:at}}
Do not list the category of posts. It needs to be used with {opt mlink} or {opt mtext}
{p_end}
{synopt:{cmdab:c:atfirst}}
List categories of all posts, and then posts. It needs to be used with {opt mtext}
{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{bf:lianxh} make it easy for users to search blog posts and useful links from within Stata command window.
You can also list common Stata resource links, including Stata official website, 
Stata {browse "https://www.stata.com/support/faqs/":FAQs},
{browse "https://www.statalist.org/forums/":Statalist},
{browse "https://www.stata-journal.com/":Stata Journal},
{browse "https://data.princeton.edu/stata/":Stata online tutorial}, {browse "https://www.lianxh.cn/news/e87e5976686d5.html":replication data & programs} etc.
	
	

{title:Examples}

{pstd}

{ul:General Usage}

{pstd}Presents some common Stata resource links, including: replication websites, online courses, Stata Blogs, Statalists, etc{p_end}

{phang2}. {stata "lianxh "}{p_end}

{pstd}List all Blog Topics{p_end}

{phang2}. {stata "lianxh all"}{p_end}   

{pstd}List posts with keyword -DID-{p_end}

{phang2}. {stata "lianxh DID"}{p_end}

{pstd}List posts with keywords -DID- or -倍分法-{p_end}

{phang2}. {stata "lianxh DID 倍分法"}{p_end}

{pstd}List posts with keywords -DID- and -Stata-{p_end}

{phang2}. {stata "lianxh DID+Stata"}{p_end}
{phang2}. {stata "lianxh DID Stata +"}{p_end}

{pstd}Export the results to a markdown file named -mydid.md-{p_end}

{phang2}. {stata "lianxh DID, saving(mydid)"}{p_end}

{pstd}Specify the folder{p_end}

{phang2}. {stata "lianxh DID, s(D:/连享会推文/mydid)"}{p_end}

{pstd}List the post in Wechat format, BlogTile: URL{p_end}

{phang2}. {stata "lianxh DID, w"}{p_end}

{pstd}Display the result after clearing the Results window{p_end}

{phang2}. {stata "lianxh DID, cls"}{p_end}


{ul:Quich Usage}

{pstd}List all Blog topics{p_end}

{phang2}. {stata "lianxh all"}{p_end}


{ul:For Markdown user}

Note: You can share your results with your friend in Wechat (Weixin) or your Blog.

{pstd}List markdown text with link of the blog posts{p_end}

{phang2}. {stata "lianxh DID, m"}{p_end}

{pstd}A similar one: ^-^{p_end}

{phang2}. {stata "lianxh DID 倍分法, mt"}{p_end}
{phang2}. {stata "lianxh DID 倍分法, mt m"}{p_end}

Attention-1: {opt nocat} should be used with {opt mlink} or {opt mtext}

{phang2}. {stata "lianxh DID, m  noc"}{p_end}
{phang2}. {stata "lianxh DID, mt noc"}{p_end}

Attention-2: {opt catfirst} should be used with {opt mlink} ^-^

{phang2}. {stata "lianxh DID, m c"}{p_end}


{title:Author}

{phang}
{cmd:Yujun, Lian} Lingnan College, Sun Yat-Sen University, China.{break}
E-mail: {browse "mailto:arlionn@163.com":arlionn@163.com}. {break}
Blog: {browse "https://www.lianxh.cn":lianxh.cn} {break}
{p_end}

{phang}
{cmd:Junjie, Kang} Lingnan College, Sun Yat-Sen University, China.{break}
E-mail: {browse "mailto:642070192@qq.com":642070192@qq.com}. {break}
{p_end}

{phang}
{cmd:Ruihan, Liu} Lingnan College, Sun Yat-Sen University, China.{break}
E-mail: {browse "mailto:2428172451@qq.com":2428172451@qq.com}. {break}
{p_end}


{title:For problems and suggestions}

{p 4 4 2}
Any problems or suggestions are welcome, please Email to
{browse "mailto:arlionn@163.com":arlionn@163.com}. 

{p 4 4 2}	
You can also submit keywords you can't find and suggestions here:
{browse "https://www.wjx.cn/jq/98072236.aspx":[Click]}.

{p 4 4 2}
The latest version of package can be obtained from the project home page: {browse "https://gitee.com/arlionn/lianxh":https://gitee.com/arlionn/lianxh}


{title:Also see}

{psee} 
Online:  
{help songbl} (if installed),  
{help lxhuse} (if installed),
{help lxh} (if installed)
