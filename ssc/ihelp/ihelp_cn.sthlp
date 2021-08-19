{smcl}
{* 15June2021}{...}
{cmd:help ihelp {stata "help ihelp": English version}}{right: }
{hline}

{title:标题}

{p2colset 5 14 14 2}{...}
{p2col:{hi:ihelp} {hline 2}} 在浏览器窗口显示PDF格式的帮助文件 {p_end}
{p2colreset}{...}


{title:语法}

{p 8 16 2}
{cmd:ihelp} {cmd:}{it:command_name} [{cmd:,}
{opt m:arkdown}
{opt w:eixin}
{opt c:lipoff}]


{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt m:arkdown}}以 Markdown 形式显示帮助文件的链接，并复制到剪切板{p_end}
{synopt:{opt w:eixin}}以 命令:URL 的形式显示帮助文件的链接，并复制到剪切板{p_end}
{synopt:{opt c:lipoff}}取消复制到剪切板{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{title:简介}

{pstd}
{cmd:ihelp} 用来显示指定命令的帮助文件。{helpb help} 的帮助文件通常比较简略且不易阅读，而Stata手册中
提供了丰富详细的命令说明，其使用的PDF格式也具有良好的阅读体验。{helpb ihelp} 可以在浏览器中打开
更详细的PDF格式的帮助文档，方便阅读和翻译；还可以列示Stata手册中，与指定命令相似的命令。{p_end}


{title:选项}

{phang}
{opt markdown} 以 Markdown 形式显示帮助文件的链接，并复制到剪切板

{phang}
{opt wexin} 以 命令:URL 的形式显示帮助文件的链接，并复制到剪切板

{phang}
{cmd:clipoff} 取消复制到剪切板


{title:举例}

{phang}* {ul:基本功能}：打开帮助文档

{phang2}{inp:.} {stata "ihelp pwcorr":ihelp pwcorr}{p_end}
{phang2}{inp:.} {stata "ihelp clip()":ihelp clip()}{p_end}
{phang2}{inp:.} {stata "ihelp twoway scatter":ihelp twoway scatter}{p_end}
{phang2}{inp:.} {stata "ihelp sum":ihelp sum}{p_end}
{phang2}{inp:.} {stata "ihelp tab":ihelp tab}{p_end}

{phang}* {ul:辅助功能}：输出链接

{phang2}{inp:.} {stata "ihelp twoway scatter, m":ihelp twoway scatter, m}{p_end}
{phang2}{inp:.} {stata "ihelp import excel, w":ihelp import excel, w}{p_end}


{title:存储结果}

{pstd}
可以通过{stata "return list": return list} 查看 {cmd:ihelp} 后的存储结果 (参见 {help return}):

{synoptset 15 tabbed}{...}
{synopt:{cmd:. r(link)}}帮助文件链接（URL）{p_end}
{synopt:{cmd:. r(link_m)}}帮助文件链接（Markdown 形式）{p_end}
{synopt:{cmd:. r(link_w)}}帮助文件链接（命令:URL 形式）{p_end}


{title:作者}

{pstd} {cmd:Yujun Lian* (连玉君)}{p_end}
{pstd} . Lingnan College, Sun Yat-Sen University, China. {p_end}
{pstd} . E-mail: {browse "mailto:arlionn@163.com":arlionn@163.com} {p_end}
{pstd} . Blog: {browse "lianxh.cn":https://www.lianxh.cn}.{p_end}

{pstd} Yongli Chen (陈勇吏) {p_end}
{pstd} . Antai College of Economics and Management, Shanghai Jiao Tong University, China.{p_end}
{pstd} . E-mail: {browse "mailto:yongli_chan@163.com":yongli_chan@163.com}{p_end}


{title:Also see}

{pstd} Online: {helpb help}{p_end}

