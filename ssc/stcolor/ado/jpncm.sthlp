{smcl}
{* 2018年3月6日}
{hline}
{cmd:help jpncm}{right: }
{hline}

{title:标题}

{phang}
{bf:jpncm} {hline 2} 日本传统色地图。{p_end}

{title:语法}

{p 8 18 2}
{cmd:jpncm} {bf: [, {opt q:uietly}}{bf: {opt c:olor}(}{it:color}{bf:)]}


{marker options}{...}
{title:选项}

{phang} {bf: {opt q:uietly}}: 选择是否显示“正在排列颜色，请稍后···”这句话；{p_end}
{phang} {bf: {opt c:olor}(}{it:color}{bf:)}: 选择色卡；{p_end}

{title:示例}

{phang}
{stata `"jpncm, c(red)"'}
{p_end}
{phang}
{stata `"jpncm, c(brown)"'}
{p_end}
{phang}
{stata `"jpncm, c(green)"'}
{p_end}
{phang}
{stata `"jpncm, c(yellow)"'}
{p_end}

{title:作者}

{pstd}程振兴{p_end}
{pstd}暨南大学·经济学院·金融学{p_end}
{pstd}中国·广州{p_end}
{pstd}{browse "http://www.czxa.top":个人网站}{p_end}
{pstd}Email {browse "mailto:czxjnu@163.com":czxjnu@163.com}{p_end}
