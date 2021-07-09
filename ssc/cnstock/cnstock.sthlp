{smcl}
{* 15nov2016}{...}
{cmd:help cnstock}{right: }
{hline}

{title:Title}


{phang}
{bf:cnstock} {hline 2} Downloads stock names and stock codes for China 's listed companies from China Finance Information
                       Network(http://cfi.cn/).


{title:Syntax}

{p 8 18 2}
{cmdab:cnstock} {it: exchange}{cmd:,}
[{it:options}]

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt path(foldername)}}Specify a folder where output .dta files will be saved in{p_end}


{synoptline}
{p2colreset}{...}


{pstd}{it:exchange} exchange is Chinese Securities Market. For each valid exchange, they represent different meanings of security markerts.Examples of Exchange and the names of the Exchange are as following: {p_end}
{pstd} {hi:SHA}:Shanghai A-share  {p_end}
{pstd} {hi:SZM}:Shenzhen Stock Exchange {p_end}
{pstd} {hi:SZSM}:Small and Medium-sized Enterprises of Shenzhen {p_end}
{pstd} {hi:SZGE}:Growth Enterprise Market of Shenzhen {p_end}
{pstd} {hi:SHB}:Shanghai B-share {p_end}
{pstd} {hi:SZB}:Shenzhen B-share {p_end}


{pstd}You can download stock names and stock codes for all the listed firms if choosing {it: command all} markets {p_end}


{pstd}{it:path} specifies the folder where the output .dta files are to be saved. {p_end}
{pstd} The folders can be either existed or not. {p_end}
{pstd} If the folder specified does not exist, {cmd:cnstock} will create it automatically. {p_end}


{title:Examples}

{phang}
{stata `"cnstock SHA"'}
{p_end}

{pstd}
It will extract a list of all the stock codes and stock names for all the A-share firms listed in Shanghai.

{phang}
{stata `"cnstock SZM"'}
{p_end}

{pstd}
It will extract a list of all the stock codes and stock names for all the firms listed in Shenzhen Exchange's mainboard.

{phang}
{stata `"cnstock SZM SZSM SZGE"'}
{p_end}

{pstd}
It will extract a list of all the stock codes and stock names for all the firms listed in Shenzhen's mainboard,Small and Medium-sized Enterprises board and the Growth Enterprise Board.

{phang}
{stata `"cnstock all,path(D:/temp/)"'}
{p_end}

{pstd}
It will extract a list of all the stock codes and stock names for all the the listed firms in China, whether Shanghai or Shenzhen, A-share or B-share, etc, with output files saving to folder D:/temp/.



{title:Authors}

{pstd}Chuntao LI{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@zuel.edu.cn{p_end}

{pstd}Zijian LI{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}jeremylee_41@163.com{p_end}

{pstd}Yuan XUE{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}xueyuan@hust.edu.cn{p_end}




