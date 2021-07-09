{smcl}
{* 21July2017}{...}
{hi:help addbefore}
{hline}

{title:Title}

{phang}
{bf:addbefore} {hline 2} Add number or character before a variable 


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:addbefore} {it:varlist} {cmd:,} [{it:options}]

where varlist is a list of non-string variables, or _all.  The * and ? wildcards are also allowed in varlist.


{marker description}{...}
{title:Description}

{pstd}
{cmd:addbefore} can add number or character before a variable, and you can set the digits of the variable as well.


{marker options}{...}
{title:Options for addbefore}

{phang}
{opt g:enerate(newvarlist)} specifies the new variable(s) that will receive the values. If it is specified, then newvarlist 
must have exactly as many variables as there are in varlist; the variable names in the both lists will be presented in same order. 

{phang}
{opt replace} specifies that the new values are to be replaced directly in the variables of varlist. Under this option, {cmd:addbefore} functions as a replace operation.
You must use either gen() or replace, but not both.

{phang}
{opt d:igits(integer)} specifies the digits of the variables. You must specify an integer less than 10, in general, it can basically according to the needs of user.

{phang}
{opt c:har(str)} specifies a character that adds before the variables. For stata13, the length of character must be 1, so it can not be a Chinese character. For stata14 and stata15, character represents a unicode character, and the
number of unicode character must be 1, so it can be a Chinese character. For numeric variable, you must specify the numbers 0 to 9. 


{marker example}{...}
{title:Example}

{pstd}
Use the command {cmd:input} read in the data

{phang}
{stata `"clear"'}
{p_end}
{phang}
{stata `"set more off"'}
{p_end}
{phang}
{stata `"input str15 v1 v2 v3 str15 v4"'}
{p_end}
{phang}
{stata `"a 1 22 a"'}
{p_end}
{phang}
{stata `"dd2 56555 666 dd2"'}
{p_end}
{phang}
{stata `"2 22 55 2"'}
{p_end}
{phang}
{stata `"65 66 228 65"'} 
{p_end}
{phang}
{stata `"889 22 33 889"'} 
{p_end}
{phang}
{stata `"525 55 889 525"'} 
{p_end}
{phang}
{stata `"end"'} 
{p_end}

{pstd}
Add a value before v1 v2 v3 v4 , digit is 7. By default, the character is 0.

{phang}
{stata `"addbefore v1 v2 v3 v4 , digits(7) gen(v5 v6 v7 v8)"'}
{p_end}

{pstd}
Add a value before v2 v3 , digit is 7, and specify the character as 1.

{phang}
{stata `"addbefore v2 v3 , d(7) c(1) replace "'}
{p_end}

{pstd}
Add a value before v1 v4 , digit is 7, and specify the character as a.

{phang}
{stata `"addbefore v1 v4 , d(7) c(a) replace "'}
{p_end}


{title:Author}

{pstd}Haitao SI{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}sht_finance@foxmail.com{p_end}

{pstd}Yuan XUE{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}  xueyuan19920310@163.com{p_end}

{pstd}Muhammad Usman{p_end}
{pstd}Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}
{pstd}  usmanzuel@yahoo.com{p_end}
