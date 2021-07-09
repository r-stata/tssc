{smcl}
{* 19Oct2017}{...}
{hi:help wordconvert}
{hline}

{title:Title}

{phang}
{bf:wordconvert} {hline 2} wordconvert calls PowerShell to transfer files among several types in windows system. It supports windows system with a PowerShell.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:wordconvert} {it:old_file.extension} {it:new_file.extension}{cmd:,} [{it:options}]


{marker description}{...}
{title:Description}

{pstd}
{cmd:wordconvert} calls PowerShell and MS Word to transfer file among several types. The types of both old file and new file can be identified by their extensions. 
Extensions for both the old file and the new file can be .rtf, .doc, .dot, .docx, .pdf and .xps. .docx requires MS Word 2007 or above, and converting .pdf to other types requires MS Word 2013 or above. 
If you meet some bugs when converting files, be sure that other applications such as WPS or a lower version of office have no impact, or you can contact us by email.{p_end}

{pstd}
{cmd:wordconvert} requires your computer has already installed PowerShell and MS Word. {p_end}

{pstd}
Before you run {cmd:wordconvert}, you must set your PowerShell as following:{p_end}
{pstd}
(1)Set Powershell’s ExecutionPolicy to be remotesigned. There are 4 steps as following, and you can also google the website for more visual directions. {p_end}
{phang2}a)From the command line, key in “Powershell” to find the program.{p_end}
{phang2}b)Right click the program line, then choose “run as Administrator”. Then a blue window appears with white cursor blinking, which prompts a command line to be inputted.{p_end}
{phang2}c)Key in set-ExecutionPolicy RemoteSigned and then return.{p_end}
{phang2}d)At the prompt line, key in Y and then press Enter.{p_end}

{pstd}
(2)Add the path where PowerShell is located to the environment variable path:{p_end}
{phang2}a)Find where your PowerShell is located. Suppose and normally, your PowerShell is located at the following folder: “C:\Windows\System32\WindowsPowerShell\v1.0”{p_end}
{phang2}b)Right click My Computer, and then click “Properties” at the pop-up menu.{p_end}
{phang2}c)A larger Dialog box appears. Go to the bottom line of North-West corner to click on “Advanced System Settings”.{p_end}
{phang2}d)At the new “System Property” dialog box, click on “Environmental Variable”, which is at the South-East corner.{p_end}
{phang2}e)A new dialog box called “Environmental Variable” appears. The box is divided into two panels. The lower panel is called “System Variable”. You are required to double click on the “path” 
line in the lower panel, then you will see a new dialog box called “Edit Environmental Variable”.{p_end}
{phang2}f)Add Powershell’s directory to the list and then save.{p_end}

{marker options}{...}
{title:Options for wordconvert}

{phang}
{opt replace} permits to overwrite an existing file. {p_end}

{phang}
{opt encoding(string)} the default encoding of PowerShell is ASCII, when you are using Stata version 14.0 or higher and the name or the location of the file you want to transfer contains characters that 
are not ASCII characters, you need to use the encoding option. Suppose that the file you are transferring is “文档.docx”, with a Chinese file name “文档”, which can be downloaded with the following 
command:{p_end}

{phang2}{cmd:. copy "http://202.114.234.173:8669/appres/COMMONUSE/%E6%96%87%E6%A1%A3.docx" "文档.docx", replace}{p_end}

{phang2}In order to be recognized by PowerShell, you need to use wordconvert with the encoding option as following, which transfers the utf8 Chinese characters to gb2312:{p_end}

{phang2}{cmd:. wordconvert "文档.docx" "文档.rtf", replace encoding(gb2312)}{p_end}

{phang2}The encoding() option can only be used in Stata version 14.0 or higher. To learn more about encoding, see {help encodings}.{p_end}


{marker example}{...}
{title:Example}

{pstd}

{phang}
{stata `"copy "http://202.114.234.173:8669/appres/COMMONUSE/file.rtf" "file.rtf", replace"'}
{p_end}

{phang}
{stata `"wordconvert "file.rtf" "file.docx", replace"'}
{p_end}

{phang}
{stata `"copy "http://202.114.234.173:8669/appres/COMMONUSE/%E6%96%87%E6%A1%A3.docx" "文档.docx", replace"'}
{p_end}

{phang}
{stata `"wordconvert "文档.docx" "文档.rtf", replace encoding(gb2312)"'}
{p_end}


{title:Author}

{pstd}Chuntao LI{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@zuel.edu.cn{p_end}

{pstd}Yuan XUE{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}xueyuan19920310@163.com{p_end}
