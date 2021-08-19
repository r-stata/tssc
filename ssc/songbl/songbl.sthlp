{smcl}
{* *! version 3.0 1thMarch2021}{...}
{cmd:help songbl {中文帮助文档更加详细：{stata "help songbl_cn": Chinese Version} }}
{hline}

{title:Title}

{p2colset 5 16 16 2}{...}
{p2col:{hi: songbl} {hline 2}} Search and share Stata resources and blogs within Stata Command Window.
 
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}


{p 8 14 2}
{cmd:songbl}
{bind:[{it:keywords},}
{cmdab:m:link}
{cmdab:mt:ext}
{cmdab:w:eixin}
{cmdab:noc:at}
{cmdab:p:aper}
{cmdab:g:ap}
{cmdab:auth:or(string) }
{cmdab:c:ls}
{cmdab:f:ile(string)}]

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
{synopt:{cmdab:noc:at}}
 Do not list the category of posts
{p_end}
{synopt:{cmdab:p:aper}}
Search for papers. Users can enter {cmd:songbl paper} to view the paper classification
{p_end}
{synopt:{cmdab:g:ap}}
Place a space line between the Stata blog results displayed
{p_end}
{synopt:{cmdab:auth:or(string)}}
Search according to the source of ststa blog，{cmd:auth(连享会)} means to retrieve only blog posts from lianxh。
{p_end}
{synopt:{cmdab:f:ile(string)}}
The document types in brackets include do or pdf. {cmd:file(do)} means open a do documentblog that ends with .do
{p_end}
{synopt:{cmdab:c:ls}}
Display the result after clearing the Results window
{p_end}
{synopt:{cmdab:g:ap}}
Place a space line between the Stata blog results displayed
{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{bf:songbl} makes it easy for users to search and open thousands of Stata blog posts and useful Stata links from within Stata command window.
These Stata resources come from the {browse "https://www.lianxh.cn/":连享会}, {browse "https://bbs.pinggu.org/forum-67-1.html":经管之家} etc.
You can also browse the papers and replication data & programs etc  by category from {browse "http://ciejournal.ajcass.org/":China's industrial economy}

	
{marker Examples}{...}
{title:Examples}

{pstd}

{ul:Navigation Function}

{pstd}All Navigation{p_end}

{phang2}. {stata "songbl all"}{p_end}

{pstd} List all Blog Topics{p_end}

{phang2}. {stata "songbl"}{p_end}

{pstd} List all Paper Topics{p_end}

{phang2}. {stata "songbl paper"}{p_end}

{pstd} Browse the latest blog posts

{phang2}. {stata "songbl new "}{p_end}

{pstd}Classified navigation of economic journals{p_end}

{phang2}. {stata "songbl zw"}{p_end}

{pstd}Common Stata and academic website navigation{p_end}

{phang2}. {stata "songbl stata"}{p_end}

{pstd}Common database website navigation{p_end}

{phang2}. {stata "songbl data"}{p_end}



{ul:Basic Function}

{pstd}List posts with keyword [IV-GMM] {p_end}

{phang2}. {stata "songbl IV-GMM"}{p_end}

{pstd}List posts with keyword [PSM] from lianxh.cn {p_end}

{phang2}. {stata "songbl PSM,auth(连享会)"}{p_end}

{pstd}List posts with keyword [name] from stata club{p_end}

{phang2}. {stata "songbl name,auth(爬虫俱乐部)"}{p_end}

{pstd}List papers with keyword [《金融研究》] {p_end}

{phang2}. {stata "songbl 金融研究,p"}{p_end}

{pstd}List posts with keyword [连享会历史文章] ,and open the do document blog{p_end}

{phang2}. {stata "songbl  连享会历史文章,f(do)"}{p_end}

{pstd}Place a space line between the Stata blog results displayed{p_end}

{phang2}. {stata "songbl 日期,gap"}{p_end}

{pstd}Do not list the category of posts.{p_end}

{phang2}. {stata "songbl DID,noc"}{p_end}

{pstd}Display the result after clearing the Results window{p_end}

{phang2}. {stata "songbl PSM,c"}{p_end}

{pstd}List posts with keywords [DID] and [DDD]{p_end}

{phang2}. {stata "songbl did DDD"}{p_end}

{pstd}List posts with keywords [DID] , [DDD] and [Stata]{p_end}

{phang2}. {stata "songbl DID DDD Stata"}{p_end}

{pstd}List posts with keywords [DID] or [PSM]{p_end}

{phang2}. {stata "songbl DID + PSM "}{p_end}

{pstd}List posts with keywords [DID] and [PSM],But not [Stata] {p_end}

{phang2}. {stata "songbl DID DDD - STATA "}{p_end}
 
{pstd}List posts with keywords [DID] or [PSM],But not [Stata] {p_end}

{phang2}. {stata "songbl DID + PSM - stata "}{p_end}



{ul:Share Function}

{pstd} List blog posts in form of Wechat (Weixin): BlogTitle: URL{p_end}

{phang2}. {stata "songbl PSM,w"}{p_end}

{pstd} List markdown text with link of the blog posts{p_end}

{phang2}. {stata "songbl DID, m"}{p_end}

{pstd} A similar one{p_end}

{phang2}. {stata "songbl DID 倍分法, mt"}{p_end}
{phang2}. {stata "songbl DID 倍分法, mt m"}{p_end}

{pstd}A similar one，but do not list the category of posts. {p_end}

{phang2}. {stata "songbl DID 倍分法, mt m w noc"}{p_end}



{title:Author}

{phang}
{cmd:Bolin, Song (松柏林)} Shenzhen University, China. {cmd:wechat}：songbl_stata{break}
{p_end}

{title:Also see}

{synoptset 30 }{...}
{synopt:{help lianxh} (if installed)} {stata ssc install lianxh} (to install){p_end}
{p2colreset}{...}

