{smcl}
{* 26Nov2018}{...}
{cmd:help cnar}{right: }
{hline}

{title:Title}


{phang}
{bf:cnar} {hline 2} Downloads historical financial data for a list of Chinese public firms from Hexun (a website providing financial information in China, http://www.hexun.com/).


{title:Syntax}

{p 8 18 2}
{cmdab:cnar} {it: codelist}{cmd:,} [{it:options}]

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt path(foldername)}}Specifies a folder where the output .dta files will be saved.{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}{cmd: cnar} is used to download historical financial data for a list of Chinese public firms from Hexun. Compared to{cmd: chinafin}, the variable names are more readable (use Chinese character), 
the financial data are more abundant, and the comments of the financial reports are provided. {p_end}

{pstd}{it:codelist} is a list of stock codes to be downloaded from Hexun. They are separated by space. For each code, there will be one stata format data file as the output containing all the financial information for that stock. 
The file name is same as the code, with .dta as its extension. In China, stocks are coded in six digits, not tickers as in the United States. Examples of codes and the names are as follows: {p_end}

{pstd} {hi:Stock Codes and Stock Names:} {p_end}
{pstd} {hi:000001} Ping An Bank Co., Ltd. {p_end}
{pstd} {hi:000002} China Vanke Co., Ltd. {p_end}
{pstd} {hi:600000} Shanghai Pudong Development Bank Co., Ltd. {p_end}
{pstd} {hi:900901} Inesa Intelligent Tech Inc. {p_end}

{pstd}Note: The leading zeros in each code can be omitted. {p_end}

{pstd}{it:path} specifies the folder where the output .dta files are to be saved. The folder can be either existed or a new folder. If the folder specified does not exist, {cmd: cnar} will create it automatically.{p_end}


{title:Examples}

{phang}
{stata `"cnar 600900"'}
{p_end}
{phang}
{stata `"cnar 600900, path(c:/temp/)"'}
{p_end}
{phang}
{stata `"cnar 2, path(c:/temp/)"'}
{p_end}
{phang}
{stata `"cnar 600900 000001 2"'}
{p_end}
{phang}
{stata `"cnar 600000 000001 2, path(c:/temp/)"'}
{p_end}

{title:Acknowledgments}

{pstd}We owe many thanks to Xuan Zhang, Chuntao Li and Cheng Pan, since their excellent work on {cmd: chinafin} helps a lot when designing this new code. Of course, all the errors belong to the authors.

{title:Authors}

{pstd}Chuntao Li{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@zuel.edu.cn{p_end}

{pstd}Jinyang Li{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}ljy940704@163.com{p_end}

{pstd}Yuan Xue{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}xueyuan@hust.edu.cn{p_end}
