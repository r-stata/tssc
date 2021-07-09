{smcl}
{* 2018年3月9日}
{hline}
{cmd:help cncm}{right: }
{hline}

{title:标题}

{phang}
{bf:cncm} {hline 2} 中国传统色地图。{p_end}

{title:语法}

{p 8 18 2}
{cmd:cncm} {bf: [, {opt q:uietly}}{bf: {opt c:olor}(}{it:num}{bf:)]}


{marker options}{...}
{title:选项}

{phang} {bf: {opt q:uietly}}: 选择是否显示“正在排列颜色，请稍后···”这句话；{p_end}
{phang} {bf: {opt c:olor}(}{it:num}{bf:)}: 选择色板，有1，2，3三个选项；{p_end}

{title:示例}

{phang}
{stata `"cncm, c(1)"'}
{p_end}
{phang}
{stata `"cncm, c(2)"'}
{p_end}
{phang}
{stata `"cncm, c(3)"'}
{p_end}
{phang}
{stata `"cncm"'}
{p_end}

{title:作者}

{pstd}程振兴{p_end}
{pstd}暨南大学·经济学院·金融学{p_end}
{pstd}中国·广州{p_end}
{pstd}{browse "http://www.czxa.top":个人网站}{p_end}
{pstd}Email {browse "mailto:czxjnu@163.com":czxjnu@163.com}{p_end}
