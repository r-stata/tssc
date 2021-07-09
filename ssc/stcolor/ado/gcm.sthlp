{smcl}
{* 2018年10月18日}
{hline}
{cmd:help gcm}{right: }
{hline}

{title:标题}

{phang}
{bf:gcm} {hline 2} 谷歌配色地图。{p_end}

{title:语法}

{p 8 18 2}
{cmd:gcm} {bf: [, {opt q:uietly}}{bf: {opt c:olor}(}{it:num}{bf:)]}


{marker options}{...}
{title:选项}

{phang} {bf: {opt q:uietly}}: 选择是否显示“正在排列颜色，请稍后···”这句话；{p_end}
{phang} {bf: {opt c:olor}(}{it:num}{bf:)}: 选择色板，有1，2，3，4，5五个选项，默认为1。{p_end}

{title:示例}

{phang}
{stata `"gcm, c(1)"'}
{p_end}
{phang}
{stata `"gcm, c(2)"'}
{p_end}
{phang}
{stata `"gcm, c(3)"'}
{p_end}
{phang}
{stata `"gcm, c(4)"'}
{p_end}
{phang}
{stata `"gcm, c(5)"'}
{p_end}
{phang}
{stata `"gcm"'}
{p_end}

{title:作者}

{pstd}程振兴{p_end}
{pstd}暨南大学·经济学院·金融学{p_end}
{pstd}中国·广州{p_end}
{pstd}{browse "http://www.czxa.top":个人网站}{p_end}
{pstd}Email {browse "mailto:czxjnu@163.com":czxjnu@163.com}{p_end}
