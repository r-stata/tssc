

 * Authors:
 * Xuan Zhang, Ph.D., Zhongnan Univ. of Econ. & Law (zhangx@znufe.edu.cn)
 * Dongliang Cui, Ph.D., North Ease University, cuidongliang@mail.neu.edu.cn
 * Chuntao Li, Ph.D. , Zhongnan Univ. of Econ. & Law (chtl@znufe.edu.cn)
 * January 3, 2013
 * Program written by Dr. Xuan Zhang Dr. Chuntao Li and Dr. Dongliang Cui
 * This program can be used to send emails to contacts from Stata's do file or command line
 * Please do not use this code for commerical purpose



*********************************important Settings******************************** 
***************************************************************************
* Users have to configer her/his profile.do 
* the profile must contain the following lines to configer your own email account
* Including your own Email Address, SmtpServer, EmailAccount and PassWord and Probably SmtpPort
* A Sample content of the profile.do is as following

*global EmailFrom your_gmail_account@gmail.com
*global EmailAccount your_gmail_account
*global EmailPassword your_gmail_passward 
*global EmailSmtpServer smtp.gmail.com
*global EmailSmtpPort 587
*global EmailSender "Dr. Chuntao Li"

* if you already have a profile.do, simply add the above six lines to it

capture program drop psemail

 
 program define psemail,rclass
  
 version 12.0
  syntax anything(name=ToAddress),  [s(string) b(string) a(string) p(string)]
   * path, folder to save the downloaded file 
   
     
   if index("`ToAddress'","@")<=1 {
      disp as error "Invalid Email Address"
	  exit
	  }
	  
	  if index("`ToAddress'",".")==0    {
      disp as error "Invalid Email Address"
	  exit
	  }
local Attach_File = "`a'"
tempname handle

file open `handle' using d:\psfile.ps1, text write replace

file write `handle'  _newline  "$" `"smtpServer   ="$EmailSmtpServer""'
file write `handle'  _newline  "$" `"smtpUser     ="$EmailAccount""'
file write `handle'  _newline  "$" `"smtpPassword ="$EmailPassword""'
file write `handle'  _newline  "$" `"MailAddress  ="$EmailFrom""'
file write `handle'  _newline  "$" `"fromName     ="$EmailSender""'

file write `handle'  _newline  "$" `"sslNeed ="' "$" `"false #SMTP server needs SSL should set this attribute"'
file write `handle'  _newline  "$" `"toAddress    ="`ToAddress'""' 

file write `handle'  _newline  "$" `"Subject ="' `"""' "`s'" `"""'
file write `handle'  _newline  "$" `"body = "' `"""' "`b'" `"""'
file write `handle'  _newline  "$" `"file        = "`Attach_File'""'
file write `handle'  _newline  "$" `"mail = New-Object System.Net.Mail.MailMessage"'
*set the addresses
file write `handle'  _newline  "$" `"mail.From = New-Object System.Net.Mail.MailAddress("' "$" `"MailAddress,"' "$" `"fromName)"'
file write `handle'  _newline  "$" `"mail.To.Add("' "$" `"toAddress)"'
*set the content
file write `handle'  _newline  "$" `"mail.Subject = "' "$" `"Subject"'
if "`p'"=="High" | "`p'"=="high" |"`p'"=="H" | "`p'"=="h"   { 
  file write `handle'  _newline  "$" `"mail.Priority  = "High""'
     }
if "`p'"=="Low" | "`p'"=="low" |"`p'"=="L" | "`p'"=="l"   { 
  file write `handle'  _newline  "$" `"mail.Priority  = "Low""'
     }
if "`p'"=="Normal" | "`p'"=="normal" |"`p'"=="N" | "`p'"=="n"   { 
  file write `handle'  _newline  "$" `"mail.Priority  = "Normal""'
     }
	 
file write `handle'  _newline  "$" `"mail.Body = "' "$" `"Body"'
if `"`Attach_File'"'~="" {
    confirm file `"`Attach_File'"'
                if !_rc {
				  file write `handle'  _newline  "$" `"filename= "' "$" `"file"'
                  file write `handle'  _newline  "$" `"attachment = new-Object System.Net.Mail.Attachment("' "$" `"filename)"'
                  file write `handle'  _newline  "$" `"mail.Attachments.Add("' "$" `"attachment)"'
	                     }
		         else {
				 disp as error "Invalid Attachement"
	                     exit
                       }
   }
   
*send the message
file write `handle'  _newline  "$" `"smtp = New-Object System.Net.Mail.SmtpClient -argumentList "' "$" `"smtpServer"'
file write `handle'  _newline  "$" `"smtp.Credentials = New-Object System.Net.NetworkCredential -argumentList "' "$" `"smtpUser,"' "$" `"smtpPassword"'
if index(`"$EmailFrom"',"@gmail") | index(`"$EmailFrom"',"@aggiemail") {
  file write `handle'  _newline  "$" `"smtp.EnableSsl = "' "$" `"true"'
  }
else {
  file write `handle'  _newline  "$" `"smtp.EnableSsl = "' "$" `"sslNeed"'
  }
file write `handle'  _newline  "$" `"smtp.Send("' "$" `"mail)"'

winexec powershell.exe d:\psfile.ps1

end 
