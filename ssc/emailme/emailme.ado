*Created by Ed Gerrrish.  Email egerrish@indiana.edu (or egerrish@gmail.com) with questions or comments
*Version 1.1 of emailme

cap program drop emailme
program define emailme, nclass
  
version 12.0

syntax  anything(name=to) , Username(string) Password(string) From(string) [Subject(string) Body(string) ALTernate(string)] //smtp(string) port(string)

   if index("`to'","@")<=1 {
      disp as error "To Email Address missing @"
	  exit
	  }
	  
	  if index("`to'",".")==0    {
      disp as error "To Email Address missing ."
	  exit
	  }
	  
	  if index("`from'","@")<=1 {
      disp as error "From Email Address missing @"
	  exit
	  }
	  
	  if index("`from'",".")==0    {
      disp as error "From Email Address missing ."
	  exit
	  }

	  if "`username'" == ""   {
      disp as error "Missing Username"
	  exit
	  }
	  
	  if "`password'" == ""   {
      disp as error "Missing Password"
	  exit
	  }
	  
cap file close text 
qui file open text using emailme.ps1, text write replace
	file write text "$" `"SMTPClient = New-Object Net.Mail.SmtpClient("smtp.gmail.com", 587)"'
	file write text _newline "$" `"SMTPClient.EnableSsl = "' "$" `"true"'
	file write text _newline "$" `"SMTPClient.Credentials = New-Object System.Net.NetworkCredential("`username'", "`password'");"'
	file write text _newline "$" `"SMTPClient.Send("`from'", "`to'", "`subject'","`body'")"'
	if "`alternate'" ~= "" file write text _newline "$" `"SMTPClient.Send("`from'", "`alternate'", "`subject'","`body'")"'
file close text
	
winexec powershell.exe .\emailme.ps1

sleep 2000

erase emailme.ps1

end
