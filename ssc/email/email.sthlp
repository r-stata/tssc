{smcl}
{* 19FEB2013}{...}
{hline}
help for {hi:email}
{hline}

{title: Email from Stata}

{title:Syntax}

{p 4}{cmd:email}, 
{cmdab:f:rom}({it:string})
{cmdab:t:o}({it:string})
{cmdab:s:ubject}({it:string})
[{cmdab:b:ody}({it:string})
{cmdab:a:ttachment}({it:string})
{cmdab:d:irectory}({it:string})]

{title: Description}

{p 4 4}{cmd:email} is compatible with Stata v 12.1 and requires Python 2.7.

{p 4 8}{cmd:email} requires the user to specify email addresses for the sender and recipient as well as a subject line.  
Additionally, if a file is to be attached the user must specify the file path to the attachment in the {cmdab:d:irectory}({it:string}) option. 

{title: Options}

{p 4 4}{cmdab:t:o}({it:string}) use this option to specify where the email will be sent. ({it: Currently, emails can be sent to only a single user at a time.})

{p 4 4}{cmdab:f:rom}({it:string}) use this option to specify your email address.

{p 4 4}{cmdab:b:ody}({it:string}) this option is for adding text to the body of the email.

{p 4 4}{cmdab:s:ubject}({it:string}) use this to create a subject heading in the email.

{p 4 4}{cmdab:a:ttachment}({it:string}) specify the full filename ({it:e.g., thisfile.txt}) to be attached to the email here.

{p 4 4}{cmdab:d:irectory}({it:string}) specify the file path to the attached file here ({it: e.g., "/Users/me/Desktop/This/Folder With/My_Files/"})

{title: Examples}

{p 4 4}{cmd:email}, {cmdab:t:o}({it:you@thisaddress.com}) {cmdab:f:rom}({it:me@me.com}) {cmdab:s:ubject}({it:"This is just a test"}) {cmdab:b:ody}({it:"No. Seriously. It is just a test."}) {cmdab:a:ttachment}({it:myfile.txt}) {cmd: directory(}{it:"/Users/my/Folder Is/Here/"}{cmd:)}

{title:Author}

{p 4 4}William R. Buchanan{break}
Executive Director & Founder{break}
Performing Arts & Creative Education Solutions Consulting{break}
http://www.paces-consulting.org
