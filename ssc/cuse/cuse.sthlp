{smcl}
{* 2019年6月3日}
{hline}
{cmd:help cuse}{right: }
{hline}

{title:标题}

{phang}
{bf:cuse} {hline 2} 构建自己的 Stata 数据集仓库。{p_end}

{title:语法}

{p 8 18 2}
{cmdab:cuse} {cmd: filename} {cmd:,} [{cmd:{opt c:lear}} {cmd:{opt w:eb}} {cmd:{opt s:avetosystem}}]


{title:描述}
{pstd}{space 3}{cmd: filename}: 需要使用的数据集的名字。{p_end}

{marker options}{...}
{title:选项}

{phang}
{cmd:{opt c:lear}}: 选择是否清空当前数据集。{p_end}

{phang}
{cmd:{opt w:eb}}: 指定调用远端仓库的数据集。默认调用本地仓库的数据集。{p_end}

{phang}
{cmd:{opt s:avetosystem}}: 指定是否需要将该数据集存入系统文件夹中，以方便使用sysuse命令调用。{p_end}

{title:示例}

{phang}
{stata `"cuse station, c"'}
{p_end}
{phang}
{stata `"cuse population, c w"'}
{p_end}
{phang}
{stata `"cuse huaihe, c w s"'}
{p_end}

{title:作者}

{pstd}程振兴{p_end}
{pstd}山东大学蓝绿发展研究院{p_end}
{pstd}山东威海{p_end}
{pstd}ssc@tidyfriday.cn, 18200993720(微信){p_end}
