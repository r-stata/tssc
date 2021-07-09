{smcl}
{* 19Sep2016}{...}
{hi:help cnintraday}
{hline}

{title:Title}

{phang}
{bf:cnintraday} {hline 2} Download intraday stock quotations for a list of stock codes in a given date 
from SinaFinance(http://finance.sina.com.cn/), a website providing financial information in China.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:cnintraday}{it: codelist}{cmd:,}[{it:options}]

{phang}
{it:codelist} is a list of stock codes to be downloaded from SinaFinance. The stock codes must be separated by spaces.
For each valid stock code and given date, there will be one Stata-format data file as her output, 
which will contain all the intraday quotations for every 3 seconds. The code and the date will be the filename 
with {cmd:.dta} as the extension. In China, stocks are identified by six-digit numbers. Examples of stock codes and 
the names of their corresponding firms are as follows:

{phang2} {hi:000001} Pingan Bank  {p_end}
{phang2} {hi:000002} Vanke Real Estate Co., Ltd. {p_end}
{phang2} {hi:600000} Pudong Development Bank {p_end}
{phang2} {hi:600005} Wuhan Steel Co., Ltd. {p_end}
{phang2} {hi:900901} INESA Electron Co., Ltd. {p_end}

{phang2}
The leading zeros in each stock code can be omitted.



{marker description}{...}
{title:Description}

{pstd}
{cmd:cnintraday} automatically downloads  intraday trading quotations for every 3 seconds for a list of stock codes in a given date 
from SinaFinance(http://finance.sina.com.cn/), conditional on whether there are transactions. The information you get includes trading 
time, trading price, price change, trading volume, trading amount in RMB and trade direction.{p_end}


{marker options}{...}
{title:Options for cnintraday}

{phang}
{opt date(string)} specifies the date in which you want to get the intraday trading quotations for the list of stock codes.
You should input the date information in a format of %dCY-N-D(2016-01-31, for example), a 10 byte length. If you input a 
non-trading date or in wrong format, you will not get any information. If you do not specify this option, you will get 
trading details for the current date, no information will be download if the current date is not a trading date.{p_end}

{phang}
{opt path(foldername)} specifies a folder to save the downloaded intraday trading quotation files. If the folder is not 
existing, cnintraday will create it automatically. If the option is not specified, the output will be saved to the 
current working directory. Users are strongly recommended to explicitly specify this option.


{marker example}{...}
{title:Example}

{phang}
{stata `"cnintraday 2"'}
{p_end}

{pstd}
You can get today's detailed quotation records for Vanke Real EstateCo. Ltd.

{phang}
{stata `"cnintraday 2, date(2011-12-02)"'}
{p_end}

{pstd}
You can get the detailed quotation records for Vanke Real Estate Co. Ltd on 2nd Dec 2011.

{phang}
{stata `"cnintraday 2 600000"'}
{p_end}

{pstd}
You can get today's detailed quotation records for Vanke Real Estate and Pudong Development Bank.

{phang}
{stata `"cnintraday 2, path(C:/temp/)"'}
{p_end}

{pstd}
You can get the detailed quotation records for Vanke Real Estate today, with output files saving to folder C:/temp/.

{phang}
{stata `"cnintraday 2 600000, date(2011-12-02) path(C:/temp/)"'}
{p_end}

{pstd}
You can get the detailed quotation records for Vanke Real Estate and Pudong Development Bank on 2 Dec 2011, with output files saving to folder C:/temp/.


{title:Author}

{pstd}Chuntao LI{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@zuel.edu.cn{p_end}

{pstd}Yuan XUE{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}xueyuan@hust.edu.cn{p_end}



