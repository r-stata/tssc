{smcl}
{* 2020年8月17日}
{hline}
{cmd:help cnstock3}{right: }
{hline}

{title:标题}

{phang}
{bf:cnstock2} 爬取沪市、深市或两市所有上市公司基本情况数据。{p_end}

{title:语法}

{p 8 18 2}
{cmdab:cnstock3}[, {opt m:arket(string)}]

{title:示例}

{phang}下载两市所有上市公司的基本情况数据：{p_end}
{phang}
{stata `"cnstock3"'}
{p_end}
{phang}下载沪市所有上市公司的基本情况数据：{p_end}
{phang}
{stata `"cnstock3, m(SH)"'}
{p_end}
{phang}下载深市所有上市公司的基本情况数据：{p_end}
{phang}
{stata `"cnstock3, m(SZ)"'}
{p_end}

{title:作者}

{pstd}TidyFriday{p_end}
{pstd}欢迎关注我的微信公众号 RStata～{p_end}
