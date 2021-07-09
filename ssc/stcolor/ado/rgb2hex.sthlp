{smcl}
{* 2018年10月18日}
{hline}
{cmd:help rgb2hex}{right: }
{hline}

{title:标题}

{phang}
{bf:rgb2hex} {hline 2} 将RGB颜色代码转为16进制颜色代码，并将返回结果存储在返回值中。{p_end}

{title:语法}

{p 8 18 2}
{cmd:rgb2hex} args {bf: [,} {bf: {opt p:lay}]}


{marker options}{...}
{title:选项}

{phang} {bf: {opt p:lay}}: 指定绘制该颜色的展示图。{p_end}

{title:示例}

{phang}
{stata `"rgb2hex"'}
{p_end}
{phang}
{stata `"rgb2hex 77 25 25"'}
{p_end}
{phang}
{stata `"rgb2hex 77 25 25, p"'}
{p_end}

{title:作者}

{pstd}程振兴{p_end}
{pstd}暨南大学·经济学院·金融学{p_end}
{pstd}中国·广州{p_end}
{pstd}{browse "http://www.czxa.top":个人网站}{p_end}
{pstd}Email {browse "mailto:czxjnu@163.com":czxjnu@163.com}{p_end}
