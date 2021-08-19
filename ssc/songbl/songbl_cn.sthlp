{smcl}
{* *! version 4.0 *! Update: 2021/3/15 12:32}{...}

{cmd:加入 Stata 交流群微信：{browse "https://note.youdao.com/ynoteshare1/index.html?id=720635d3824de83e0e764a60eb34e54c&type=note":songbl_stata}}

{hline}

{title:公告}

{synoptset 30 }{...}
{cmd:    致使用Songbl命令的Stata爱好者公告：{stata "songbl 公告":songbl公告}}

{cmd:    上传Stata资源到Songbl数据库的链接：{browse "https://www.wjx.top/vj/rkaS2hv.aspx":https://www.wjx.top/vj/rkaS2hv.aspx}}
{p2colreset}{...}

{title:Title}

{p2colset 5 16 16 2}{...}
{p2col:{hi: songbl} {hline 2}}在 Stata 命令窗口中对微信公众号、爬虫俱乐部、连享会网站等推文的关键词检索与结果输出。 
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}


{p 4 14 2}
{cmd:songbl}
{bind:[{it:keywords},}
{cmdab:m:link}
{cmdab:mt:ext}
{cmdab:mu:rl}
{cmdab:w:link}
{cmdab:wt:ext}
{cmdab:wu:rl}
{cmdab:l:ine}
{cmdab:n:(#)}
{cmdab:noc:at}
{cmdab:p:aper}
{cmdab:g:ap}
{cmdab:auth:or(string) }
{cmdab:c:ls}
{cmdab:f:ile(string)}
{cmdab:n:avigation }
{cmdab:ti:me}
{cmdab:save}
{cmdab:replace}
{cmdab:l:ine}
{cmdab:clip}
{cmdab:ssc}
{cmdab:fy}
{cmdab:care}
{cmdab:dir}
{cmdab:s:ou}]

{p 8 14 2}

{synoptset 14}{...}
{synopthdr:Options}
{synoptline}
{bf:基础选项}
{synopt:{cmdab:c:ls}}
清屏后显示结果
{p_end}
{synopt:{cmdab:noc:at}}
不输出推文分类信息
{p_end}
{synopt:{cmdab:ti:me}}
输出检索所耗时间
{p_end}
{synopt:{cmdab:g:ap}}
在输出的推文结果之间进行空格一行
{p_end}
{synopt:{cmdab:l:ine}}
搜索推文的另一种输出风格,具有表格划线
{p_end}
{synopt:{cmdab:auth:or(string)}}
按照推文来源进行检索，author(连享会)表示仅检索来自连享会的推文
{p_end}
{synopt:{cmdab:n:um(#)}}
指定要列出的最新推文的数量；N(10)是默认值。与 songbl new 搭配使用
{p_end}
{synopt:{cmdab:f:ile(string)}}
括号内为文档类型，包括 do/txt/docx/pdf 等。例如 file(do) 表示在 stata 打开以 .do 结尾的 do 文档推文
{p_end}

{bf:资源选项}
{synopt:{cmdab:dir}}
当前目录路径下，电脑文件资源的递归搜索。{cmd:{browse "https://baike.baidu.com/item/%E9%80%9A%E9%85%8D%E7%AC%A6/92991?fr=aladdin":支持* 、？等通配符，与strmatch（）函数的使用规则一致}}
{p_end}
{synopt:{cmdab:p:aper}}
论文资源。检索论文资源，并输出论文超链接。输入 ：songbl paper 浏览已有论文分类
{p_end}
{synopt:{cmdab:ssc}}
外部命令资源。检索3000多个外部命令的中文介绍。输入 ：songbl new,ssc 浏览最新外部命令
{p_end}
{synopt:{cmdab:n:avigation}}
导航资源。例如打开《中国工业经济》目录：songbl cie,n 更多导航功能详看：songbl all
{p_end}
{synopt:{cmdab:fy}}
命令中文帮助文档资源。首先把帮助文档 .sthlp 文件转为 .html 文件，然后借助浏览器(chrome)中的网页翻译转为中文。
{p_end}
{synopt:{cmdab:s:ou}}
网页搜索资源。搜索来源包括计量圈、百度、微信公众号、经管之家、知乎。
{p_end}
		     {bf:注：}默认情况下，检索为推文资源。此外，把资源分类主要为了提高检索速度与精准度。
{bf:分享选项}
{synopt:{cmdab:m:link}}
输出第1种 Markdown 形式的推文信息
{p_end}
{synopt:{cmdab:mt:ext}}
输出第2种 Markdown 形式的推文信息
{p_end}
{synopt:{cmdab:mu:rl}}
输出第3种 Markdown 形式的推文信息
{p_end}
{synopt:{cmdab:w:link}}
输出第1种 Weixin 分享形式推文信息
{p_end}
{synopt:{cmdab:wt:ext}}
输出第2种 Weixin 分享形式推文信息
{p_end}
{synopt:{cmdab:wu:rl}}
输出第3种 Weixin 分享形式推文信息
{p_end}
{synopt:{cmdab:clip}}
点击超链接可以剪切分享推文，与 Wlink 搭配使用
{p_end}
{synopt:{cmdab:save(string)}}
save 选项将利用文档来打开分享的内容，包括 txt/md/docx/doc/xls/xlsx/sas 等。建议使用 save(txt) 格式输出。
{p_end}
{synopt:{cmdab:replace}}
作用同 save 选项，replace 选项将生成分享内容的 STATA 数据集。使用 replace 选项将会导致已导进 STATA 的数据被清空替换成分享内容的 STATA 数据集
{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{opt songbl} 可以让用户在 Stata 命令窗口中轻松检索并打开几千篇来自微信公众号、爬虫俱乐部、连享会网站、经管之家等的Stata推文。
用户也可以分类浏览并下载几百篇来自 {browse "http://ciejournal.ajcass.org/":《中国工业经济》}   的论文与代码，以及几千篇来自《社会》、《金融研究》、《世界经济》、《劳动经济研究》
等期刊论文。资源仍在不断增加中.....


{marker Examples}{...}
{title:Examples}

{ul:主要功能}

{pstd}搜索推文

{phang2}. {stata "songbl DID"}{p_end}

{pstd}搜索论文

{phang2}. {stata "songbl 中国工业经济,p"}{p_end}

{pstd}搜索外部命令

{phang2}. {stata "songbl 变量名,ssc"}{p_end}

{pstd}搜索电脑D盘目录下mp4格式的视频

{phang2}. {stata "cd D:\"}{p_end}
{phang2}. {stata "songbl *.mp4,dir"}{p_end}


{ul:文件搜索}

{pstd}打印所有外部命令{p_end}

{phang2}. {stata "cd `c(sysdir_plus)'"}{p_end}
{phang2}. {stata "songbl ,dir"}{p_end}

{pstd}打印所有外部命令的 [.ado] 文件{p_end}

{phang2}. {stata "cd `c(sysdir_plus)'"}{p_end}
{phang2}. {stata "songbl *.ado,dir"}{p_end}

{pstd}搜索 [songbl.ado] 文件{p_end}

{phang2}. {stata "cd `c(sysdir_plus)'"}{p_end}
{phang2}. {stata "songbl songbl.ado,dir"}{p_end}

{pstd}搜索 s 开头的文件{p_end}

{phang2}. {stata "cd `c(sysdir_plus)'"}{p_end}
{phang2}. {stata "songbl s*,dir"}{p_end}

{pstd}搜索至少含有两个 s 的 ado 文件{p_end}

{phang2}. {stata "cd `c(sysdir_plus)'"}{p_end}
{phang2}. {stata "songbl *s*s*.ado,dir"}{p_end}

{pstd}搜索 s 开头，并且是6个字符的ado文件{p_end}

{phang2}. {stata "cd `c(sysdir_plus)'"}{p_end}
{phang2}. {stata "songbl s?????.ado,dir"}{p_end}


{ul:导航功能}

{pstd} The Stata Journals {p_end}

{phang2}. {stata "songbl sj,n"}{p_end}

{pstd} 中国工业经济 {p_end}

{phang2}. {stata "songbl cie,n"}{p_end}

{pstd} ssci 论文导航{p_end}

{phang2}. {stata "songbl ssci,n"}{p_end}

{pstd} cssci 论文导航{p_end}

{phang2}. {stata "songbl cssci1,n"}{p_end}

{pstd}songbl导航大全{p_end}

{phang2}. {stata "songbl all"}{p_end}

{pstd}推文主题分类导航{p_end}

{phang2}. {stata "songbl"}{p_end}

{pstd}知网经济学期刊分类导航{p_end}

{phang2}. {stata "songbl zw"}{p_end}

{pstd}常用STATA与学术网站导航{p_end}

{phang2}. {stata "songbl stata"}{p_end}

{pstd}常用社会科学数据库网站导航{p_end}

{phang2}. {stata "songbl data"}{p_end}

{pstd}可直接打开论文链接的期刊分类导航{p_end}

{phang2}. {stata "songbl paper"}{p_end}


{ul:推文搜索}

{pstd}按照资源更新时间来查看推文，默认设置为前10条

{phang2}. {stata "songbl new "}{p_end}

{pstd}同上，但是空格一行打印

{phang2}. {stata "songbl new,g "}{p_end}

{pstd}查看前20条最新推文

{phang2}. {stata "songbl new,n(20)"}{p_end}

{pstd}查看最新推文的另一种输出风格

{phang2}. {stata "songbl new,l"}{p_end}

{pstd}搜索推文的另一种输出风格

{phang2}. {stata "songbl psm,l"}{p_end}

{pstd}同上，但是空格一行输出

{phang2}. {stata "songbl psm,l g"}{p_end}

{pstd}输出标题中包含 [IV-GMM] 关键词的推文超链接{p_end}

{phang2}. {stata "songbl IV-GMM"}{p_end}

{pstd}输出来自连享会的推文超链接{p_end}

{phang2}. {stata "songbl PSM,auth(连享会)"}{p_end}

{pstd}输出来自爬虫俱乐部的推文超链接{p_end}

{phang2}. {stata "songbl 变量,auth(爬虫俱乐部)"}{p_end}

{pstd}输出标题中包含 [连享会历史文章] 关键词的推文超链接,并在stata打开以.do结尾的推文do文档{p_end}

{phang2}. {stata "songbl  连享会历史文章,f(do)"}{p_end}

{pstd}输出的推文结果之间空格一行{p_end}

{phang2}. {stata "songbl 日期,gap"}{p_end}

{pstd}不输出推文分类信息{p_end}

{phang2}. {stata "songbl DID,noc"}{p_end}

{pstd}清屏后输出结果{p_end}

{phang2}. {stata "songbl Stata绘图,c"}{p_end}

{pstd}支持大小写关键词的推文超链接检索{p_end}

{phang2}. {stata "songbl DiD"}{p_end}

{pstd}输出含有 [DID] 和 [倍分法] 的推文超链接 (交集){p_end}

{phang2}. {stata "songbl did 倍分法"}{p_end}

{pstd}输出含有 [空间] 、[面板] 和 [数据] 的推文超链接 (交集){p_end}

{phang2}. {stata "songbl 空间 面板 数据"}{p_end}

{pstd}输出含有 [空间] 或者 [面板]  的推文超链接 (并集){p_end}

{phang2}. {stata "songbl 空间 + 面板 "}{p_end}

{pstd}输出同时含有关键词 [空间计量] [stata] (交集),且不包括关键词 [面板] 的推文超链接 {p_end}

{phang2}. {stata "songbl 空间计量 stata - 面板 "}{p_end}
 
 
{ul:论文搜索}
 
{pstd}输出 《金融研究》的论文超链接{p_end}

{phang2}. {stata "songbl 金融研究,paper"}{p_end} 

{pstd}输出 《中国工业经济》企业出口的论文超链接{p_end}

{phang2}. {stata "songbl 中国工业经济 企业出口,p"}{p_end} 

{pstd}输出 《中国工业经济》》2021年第6期论文超链接{p_end}

{phang2}. {stata "songbl 中国工业经济 2021 6,p"}{p_end} 

{ul:命令搜索}

{pstd}谷歌翻译 append 命令 Help 文档，借助浏览器(chrome)点击右键翻译转为中文。

{phang2}. {stata "songbl append,fy "}{p_end}

{pstd}按照资源更新时间来查看外部命令，默认设置为前10条

{phang2}. {stata "songbl new,ssc"}{p_end}

{pstd}搜索与 [标签] 有关的外部命令

{phang2}. {stata "songbl 标签,ssc"}{p_end}	

{pstd}同上，但是空格一行打印

{phang2}. {stata "songbl 标签,ssc g"}{p_end}

{pstd}同上，但另一种输出风格

{phang2}. {stata "songbl 标签,ssc l"}{p_end}


{ul:分享功能}

{pstd}以推文标题：URL的形式输出结果{p_end}

{phang2}. {stata "songbl Stata教程,w"}{p_end}

{pstd}点击超链接可以剪切分享推文，与 Wlink 搭配使用

{phang2}. {stata "songbl psm,wlink clip "}{p_end}

{pstd}同 Wlink ，但输出的效果略有不同{p_end}

{phang2}. {stata "songbl Stata教程,wt"}{p_end}

{pstd}同上，但输出的效果略有不同{p_end}

{phang2}. {stata "songbl Stata教程,wu"}{p_end}

{pstd}三种输出方式进行比较{p_end}

{phang2}. {stata "songbl 倍分法DID pdf,w wt wu cls"}{p_end}

{pstd}输出 markdowm 表格

{phang2}. {stata "songbl new,l m "}{p_end}

{pstd}以 Markdown 格式输出推文链接{p_end}

{phang2}. {stata "songbl DID pdf, m"}{p_end}

{pstd}同上，但输出的效果略有不同{p_end}

{phang2}. {stata "songbl DID 倍分法 pdf, mt"}{p_end}

{pstd}同上，但输出的效果略有不同{p_end}

{phang2}. {stata "songbl DID 倍分法 pdf, mu"}{p_end}

{pstd}三种输出方式进行比较{p_end}

{phang2}. {stata "songbl 倍分法 DID pdf,m mt mu cls"}{p_end}

{pstd}不输出推文分类信息{p_end}

{phang2}. {stata "songbl DID 倍分法, w  m noc"}{p_end}

{pstd}利用 TXT 文档打开分享的内容{p_end}

{phang2}. {stata "songbl new ,m save(txt) line"}{p_end}
{phang2}. {stata "songbl sj-9,w save(txt) paper"}{p_end}
{phang2}. {stata "songbl sj-9,m save(txt) paper"}{p_end}

{pstd}生成分享内容的 STATA 数据集。注意：使用 replace 选项将会导致已导进 STATA 的数据被清空替换成分享的内容 STATA 数据集{p_end}

{phang2}. {stata "songbl sj-9,w replace paper"}{p_end}
{phang2}. {stata "songbl sj-9,m replace paper"}{p_end}


{ul:网页搜索}

{pstd} 网页搜索关于 DID 的资源 {p_end}

{phang2}. {stata "songbl DID,s"}{p_end}

{pstd} 网页搜索关于 PSM 的资源 {p_end}

{phang2}. {stata "songbl PSM,s"}{p_end}

{pstd} 搜索"计量圈"关于 DID 的资源：键入 "计量圈" 的任意字符{p_end}

{phang2}. {stata "songbl DID,s(计)"}{p_end}
{phang2}. {stata "songbl DID,s(量圈)"}{p_end}
{phang2}. {stata "songbl DID,s(计量圈)"}{p_end}

{pstd} 搜索"经管之家"关于 PSM 的资源：键入 "经管之家" 的任意字符{p_end}

{phang2}. {stata "songbl PSM,s(经)"}{p_end}
{phang2}. {stata "songbl PSM,s(管)"}{p_end}
{phang2}. {stata "songbl PSM,s(经管之家)"}{p_end}

{pstd} 同时搜索"计量圈、百度、微信公众号、经管之家、知乎"关于 "songbl" 的内容{p_end}

{phang2}. {stata "songbl Stata,s(all)"}{p_end}


{ul:其他功能}

{pstd}输出检索结果后面带有返回推文分类目录或者论文分类目录的快捷方式{p_end}

{phang2}. {stata "songbl PSM,time"}{p_end}

{pstd}随机生成一篇推文、命令或者论文

{phang2}. {stata "songbl r"}{p_end}
{phang2}. {stata "songbl r,ssc"}{p_end}
{phang2}. {stata "songbl r,paper"}{p_end}

{pstd}随机生成一句话，激励科研工作者

{phang2}. {stata "songbl care"}{p_end}

{pstd}随机播放松柏林的歌单，科研的路途中少不了音乐。需要先安装 {stata "ssc install imusic":imusic} 命令

{phang2}. {stata "songbl music"}{p_end}

{pstd}Stata科研之余，消遣放松网站导航{p_end}

{phang2}. {stata "songbl happy"}{p_end}

{title:Author}

{phang}
{cmd:Bolin, Song (松柏林)} Shenzhen University, China. wechat：{cmd:songbl_stata}{break}
{p_end}


{title:Also see}

{synoptset 30 }{...}
{synopt:{help lianxh} (if installed)} {stata ssc install lianxh} (to install){p_end}
{p2colreset}{...}

