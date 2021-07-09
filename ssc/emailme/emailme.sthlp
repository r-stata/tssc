{smcl}
{* *! version 1.1 August8, 2014}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:emailme} {hline 2}  This user-written command allows Stata users to send custom emails and/or text messages within a do file using Window's Powershell.exe and a Gmail account.  
Typically helpful for sending messages after a long job. See notes, below, before running for the first time.  Email attachments not supported.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:emailme}
{to_email_address}
{cmd:,} {it: username() password() from() [subject() body() alternate()]}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent :* {opt u:sername}}Gmail username (before the '@' symbol) {p_end}
{p2coldent :* {opt p:assword}}Gmail password (see Note 2) {p_end}
{p2coldent :* {opt f:rom}}From, in 'xxxxxxx@gmail.com' format{p_end}
{synopt:{opt s:ubject}}Subject line{p_end}
{synopt:{opt b:ody}}Email Body text{p_end}
{synopt:{opt alt:ernate}}Secondary email address or text address (see Note 3) {p_end}
{synoptline}
{pstd}* Required.
{p2colreset}{...}


{marker notes}{...}
{title:Notes}
{phang}{bf:Note 1: }This command requires that you allow user-written scripts in Window's Powershell. To do this, type 'winexec powershell.exe' in Stata.  In the window that opens, type 'Set-ExecutionPolicy RemoteSigned' (without quotes) and confirm with `y'.  IMPORTANT. While this does NOT allow downloaded scripts to be run, this could still make your computer more vulnerable to malicious scripts written on your computer.  Use this ado with appropriate caution.{p_end}
{phang}{bf:Note 2: }While this command does not permanently store your password on the local computer, it will be stored in the do file. I highly recommend creating a separate gmail account for this purpose.{p_end}
{phang}{bf:Note 3: }Text addresses are carrier-specific.  Some examples:{p_end}

{p2coldent : Carrier} Email to SMS Gateway{p_end}
{synoptline}
{p2coldent : Alltel}	1234567890@message.alltel.com {p_end}
{p2coldent : AT&T}	1234567890@txt.att.net {p_end}
{p2coldent : Boost Mobile}	1234567890@myboostmobile.com {p_end}
{p2coldent : Nextel}	1234567890@messaging.nextel.com {p_end}
{p2coldent : Sprint PCS}	1234567890@messaging.sprintpcs.com {p_end}
{p2coldent : T-Mobile}	1234567890@tmomail.net {p_end}
{p2coldent : US Cellular}	1234567890@email.uscc.net {p_end}
{p2coldent : Verizon}	1234567890@vtext.com {p_end}
{p2coldent : Virgin Mobile}	1234567890@vmobl.com {p_end}
{synoptline}

{marker examples}{...}
{title:Examples}

{pstd}standard{p_end}

{phang}{cmd:emailme example@gmail.com, username(testemail) password(password1) from(testemail@gmail.com) subject(emailme example) body(emailme example)}{p_end}

{pstd}abbreviated option names{p_end}

{phang}{cmd:emailme example@gmail.com, u(testemail) p(password1) f(testemail@gmail.com) s(emailme example) b(emailme example)}{p_end}

{pstd}email and text (or secondary email){p_end}

{phang}{cmd:emailme example@gmail.com, u(testemail) p(password1) f(testemail@gmail.com) s(emailme example) b(emailme example) alt(1234567890@vtext.com)}{p_end}

{marker author}{...}
{title:Author}

{pstd}Ed Gerrish{p_end}
{pstd}School of Public and Environmental Affairs{p_end}
{pstd}Indiana University{p_end}
{pstd}egerrish@indiana.edu{p_end}
{pstd}egerrish@gmail.com{p_end}

{pstd} {p_end}
