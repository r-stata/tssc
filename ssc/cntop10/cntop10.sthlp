{smcl}
{* 1Jan2019}{...}
{cmd:help cntop10}{right: }
{hline}

{title:Title}

{phang}
{bf:cntop10} {hline 2} Downloads information of top 10 shareholders for a list of stock codes from HeXun(a web site providing financial information in China, www.hexun.com)

{title:Syntax}

{p 8 18 2}
{cmdab:cntop10} {it: codelist} {cmd:,} [{it:options}]

{marker description}{...}
{title:Description}

{pstd}{it:codelist} is a list of stock codes to be downloaded from Hexun. They are separated by spaces. 
For each code, there will be one stata format data file as an output containing the top 10 shareholders' information for that stock.
The code will be the file name, with .dta as the extension. In China, stocks are identified by a six digit numbers, not tickers as in the United States. Examples of codes and the names are as following: {p_end}
 
{pstd} {hi:Stock Codes and Stock Names:} {p_end}
{pstd} {hi:000001} Pingan Bank  {p_end}
{pstd} {hi:000002} Vank Real Estate Co. Ltd. {p_end}
{pstd} {hi:600000} Pudong Development Bank {p_end}
{pstd} {hi:600005} Wuhan Steel Co. Ltd. {p_end}
{pstd} {hi:900901} INESA Electron Co.,Ltd. {p_end}

{pstd}The leading zeros in each code can be omitted. {p_end}

{pstd}{it:path} specifies the folder where the output .dta files are to be saved. {p_end}
{pstd}The folders can be either existed or a new folder. {p_end}
{pstd}If the folder specified does not exist, {cmd: cntop10} will create it automatically. {p_end}

{marker options}{...}
{title:Options for cntop10}

{phang}
{opt path(foldername)}: specify a folder where output .dta files will be saved in.{p_end}


{title:Examples}

{phang}
{stata `"cntop10 600000"'}
{p_end}
{phang}
{stata `"cntop10 600000, path(c:/temp/)"'}
{p_end}
{phang}
{stata `"cntop10 2, path(c:/temp/)"'}
{p_end}
{phang}
{stata `"cntop10 600000 000001 600810"'}
{p_end}
{phang}
{stata `"cntop10 600000 000001 600810, path(c:/temp/)"'}
{p_end}


{title:Authors}

{pstd}Chuntao Li{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@zuel.edu.cn{p_end}

{pstd}Xueli Sun{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}13212746629@163.com{p_end}

{pstd}Yuan Xue{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}xueyuan@hust.edu.cn{p_end}
