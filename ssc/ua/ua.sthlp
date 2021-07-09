{smcl}
{* 21dec2017}{...}
{hi:help ua}
{hline}

{title:Title}

{p 4 4 2}{hi:ua} {hline 2} {cmdab:u:nicode} {cmdab:a:ll}, Prefix command for unicode utilities


{title:Syntax}

{p 14 15 2}
    {cmd:ua} {cmd::} {it:unicode_command}

{p 4 12 6}where, {it:unicode_command} can be any command supported by {helpb unicode:[D] unicode}, including:

{p2colset 8 35 37 2}{...}
{p2col :{manhelp unicode_translate D:unicode translate}}Translate files to Unicode{p_end}
{p2col :{manhelp unicode_encoding D:unicode encoding}}Unicode encoding utilities{p_end}
{p2col :{manhelp unicode_locale D:unicode locale}}Unicode locale utilities{p_end}
{p2col :{manhelp unicode_collator D:unicode collator}}Language-specific Unicode collators{p_end}
{p2col :{manhelp unicode_convertfile D:unicode convertfile}}Low-level file conversion between encodings{p_end}
{p2colreset}{...}


{title:Description}

{p 4 4 6}
Stata's official command {helpb unicode translate} can translate 
files containing extended ASCII (such as accented characters, Chinese,
Japanese, or Korean (CJK) characters, Cyrillic characters, and the like)
to Unicode (UTF-8). For other similar commands, see {helpb unicode:[D] unicode}.

{p 4 4 6}
However, only files in current working directory (CWD) can be done with {helpb unicode} command families.
For users of Stata 13 and earlier, especially old users with many files saved in different 
folders and sub-folders, it is a time-consuming task to translate unicode.

{p 4 4 6}
{cmd:ua} ({cmdab:u:nicode} {cmdab:a:ll}) help you get out of the mess! 

{p 4 4 6}
{cmd:ua} is a prefix command (see {helpb prefix}) 
to {helpb unicode} commands. It provides an easy way to 
unicode files in CWD and files in all subdirectories of CWD recursively. 


{title:Warning}

{p 4 4 6}
We recommend you read {helpb unicode}, and for safety, backup your files and do some tests before you use {cmd:ua}.


{title:Examples}

{p 2 8 2} * Change current working directory (CWD){p_end}
{p 4 8 2} . cd D:\stata15\ado\personal\mypaper{p_end}

{p 2 8 2} * Unicode all {it:.dta} files in CWD and files in sub-directories{p_end}
{p 4 8 2} . ua: unicode encoding set gb18030{p_end}
{p 4 8 2} . ua: unicode translate *.dta{p_end}

{p 2 8 2} * Unicode all files (.do, .ado, .dta, .hlp, etc.) in CWD and files in sub-directories{p_end}
{p 4 8 2} . ua: unicode encoding set gb18030{p_end}
{p 4 8 2} . ua: unicode translate *{p_end}
		
		
{title:Author}

{phang}
{cmd:Yujun,Lian (Arlion)} Department of Finance, Lingnan College, Sun Yat-Sen University.{break}
E-mail: {browse "mailto:arlionn@163.com":arlionn@163.com}. {break}
Blog: {browse "http://www.jianshu.com/u/69a30474ef33":http://www.jianshu.com/u/69a30474ef33}. {break}
{p_end}


{title:Acknowledgements}

{p 4 8 2}
I would like to thank Dr. Hua Peng at StataCorp LP for helpful suggestions.

{p 4 8 2}
Codes from {help rcd} by Nikos Askitas and Dan Blanchette have been incorporated.

{p 4 8 2}


{title:Also see}

{psee}
    Online:  help for {helpb unicode}, {helpb rcd}
