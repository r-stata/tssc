{smcl}
{* 23Feb2013}{...}
{cmd:help email}{right: }
{hline}

{title:Title}

{p2colset 5 25 27 2}{...}
{p2col:{hi: psemail} {hline 2}}Send Emails through Stata's do file or via Stata's command line. {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmdab:psemail} {it: toAddress}{cmd:,}
[{it:options}]

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt s(subject)}} Subject line{p_end}
{synopt:{opt b(Email body)}}The body of your email. {p_end}
{synopt:{opt a(attachment)}}Attachement file, better with a folder path. If there are blanks in the file name of path, please use double quoates{p_end}
{synopt:{opt p(n|h|l)}}privority leve, can be h, l and normal. the default is set to be normall{p_end}

{synoptline}
{p2colreset}{...}


{pstd}{it:toAddress} is the receipt's email address. {p_end}
{pstd}The program will first check whether there is an "@" and there are ".", but cannot fully check if the email address is valid. {p_end}

{pstd} The body of the email can be of multiple lines. when input the body sentences, carriage return is replaced by `r`n {p_end}
{pstd} Suppose you are going to use the following three lines as email body{p_end}
{pstd} Hello World!{p_end}
{pstd} Stata can send Emails now.{p_end}
{pstd} Really interesting!{p_end}
{pstd} You need to set the body option as following {p_end}
{pstd} b(Hello World!`r`n Stata can send Emails now.`r`n Really interesting!){p_end}


{title:Example1}

{phang}{cmd:. clear  } {p_end}
{phang}{cmd:. set obs 100 } {p_end}
{phang}{cmd:. gen x = uniform() } {p_end}
{phang}{cmd:. save d:\temp, replace  } {p_end}
{phang}{cmd:. save "d:\temp 1.dta", replace } {p_end}
{phang}{cmd:. psemail chuntao@baf.cuhk.edu.hk, s(test mail 1) b(Hello! World!) } {p_end}
{phang}{cmd:. sleep 3000 } {p_end}
{phang}{cmd:. psemail chuntao@baf.cuhk.edu.hk, s(test mail 2) b(Hello! World!) a(d:\temp.dta) } {p_end}
{phang}{cmd:. sleep 3000 } {p_end}
{phang}{cmd:. psemail chuntao@baf.cuhk.edu.hk, s(test mail 3) b(Hello! World!) a("d:\temp 1.dta") } {p_end}
{phang}{cmd:. sleep 3000 } {p_end}
{phang}{cmd:. psemail chuntao@baf.cuhk.edu.hk, s(test mail 4) b(Hello World!`r`n Stata can send Emails now.`r`n rather funny!) a("d:\temp 1.dta") } {p_end}
{phang}{cmd:. sleep 3000 } {p_end}


{title:Example2}

{pstd} Suppose you have a list of students name, email address and test score.{p_end}
{pstd} Those information are stored in d:\student.dta with three variables as name, email and testscore {p_end}
{pstd} Suppose you want to send each student an email to let them know their own test score.{p_end}
{pstd} A program can be as following.{p_end}

{phang}{cmd:. use d:\student, clear  } {p_end}
{phang}{cmd:. local N=_N  } {p_end}
{phang}{cmd:. forval i =1(1) `N' {c -(}} {p_end}
{phang}{cmd:.   local name = name[`i']  } {p_end}
{phang}{cmd:.   local email = email[`i']  } {p_end}
{phang}{cmd:.   local testscore = testscore[`i']  } {p_end}
{phang}{cmd:.   psemail `email', s(test score) b(Dear `name' `r`n    Your recent test score for mathematics is `test score'.  `r`n Best, `r`n Dr. Tony Lee )  } {p_end}
{phang}{cmd:.   sleep 3000  } {p_end}
{phang}{cmd:. {c )-}} {p_end}



{title:Important Note 1}
{pstd} To install this command, the user have to configer your own stata so that stata knows your email information.{p_end}
{pstd} The user need to change his/her profile.do, normally stored at the default ado directory or personal directory. {p_end}
{pstd} help sysdir for more information.{p_end}
{pstd} After configeration, Suppose you are using a gmail as your own email, and your account is youremail@gmail.com.{p_end}
{pstd} Your profile.do should have the following lines.{p_end}
{pstd} {cmd: global EmailFrom youremail@gmail.com} {p_end}
{pstd} {cmd: global EmailAccount youremail }{p_end}
{pstd} {cmd: global EmailPassword yourpassward } {p_end}
{pstd} {cmd: global EmailSmtpServer smtp.gmail.com} {p_end}
{pstd} {cmd: global EmailSmtpPort 587 } {p_end}
{pstd} {cmd: global EmailSender "Yourname"}{p_end}


{title:Important Note 2}
{pstd} Every time we send an email with email.ado, Stata fires up your powershell{p_end}
{pstd} We use stata to design a powershell .ps1 file {p_end}
{pstd} When the powershell is fire up, it will run the Stata designed .ps1 file {p_end}
{pstd} Since it always takes time to fire up and to close the powershell, we recommand the user to stop the Stata program 3 seconds {p_end}
{pstd} everytime you send an email. {p_end}
{pstd} suppose your email address is mygmail@gmailcom. {p_end}
{pstd} The following code will probably send the same email because Stata runs far more faster than powershell's fire up and closing procedure{p_end}

{phang}{cmd:. forval i =1(1) 3 {c -(}} {p_end}
{phang}{cmd:.   psemail mygmail@gmailcom, s(Test Email`i')  } {p_end}
{phang}{cmd:. {c )-}} {p_end}

{pstd}Add a line to stop Stata for 3 second, you will get your desiable results {p_end}

{phang}{cmd:. forval i =1(1) 3 {c -(}} {p_end}
{phang}{cmd:.   psemail mygmail@gmailcom, s(Test Email`i')  } {p_end}
{phang}{cmd:.   sleep 3000  } {p_end}
{phang}{cmd:. {c )-}} {p_end}



{title:Authors}

{pstd}Xuan Zhang{p_end}
{pstd}Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}
{pstd}zhangx@znufe.edu.cn{p_end}

{pstd}Dongliang Cui{p_end}
{pstd}North East University{p_end}
{pstd}Shenyang, China{p_end}
{pstd}cuidongliang@mail.neu.edu.cn{p_end}

{pstd}Chuntao Li{p_end}
{pstd}Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@znufe.edu.cn{p_end}

