{smcl}
{* 2018年10月18日}
{hline}
{cmd:help hex2rgb}{right: }
{hline}

{title:标题}

{phang}
{bf:hex2rgb} {hline 2} 将16进制颜色代码转为RGB颜色代码，并将返回结果存储在返回值中。{p_end}

{title:语法}

{p 8 18 2}
{cmd:hex2rgb} arg {bf: [,} {bf: {opt p:lay}]}


{marker options}{...}
{title:选项}

{phang} {bf: {opt p:lay}}: 指定绘制该颜色的展示图。{p_end}

{title:示例}

{phang}
{stata `"hex2rgb"'}
{p_end}
{phang}
{stata `"hex2rgb #fce8b2"'}
{p_end}
{phang}
{stata `"hex2rgb #fce8b2, p"'}
{p_end}

{title:作者}

{pstd}程振兴{p_end}
{pstd}暨南大学·经济学院·金融学{p_end}
{pstd}中国·广州{p_end}
{pstd}{browse "http://www.czxa.top":个人网站}{p_end}
{pstd}Email {browse "mailto:czxjnu@163.com":czxjnu@163.com}{p_end}
