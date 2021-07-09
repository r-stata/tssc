*! email
*! v 1.0.0
*! 19FEB2013
*! William R. Buchanan
*! Performing Arts & Creative Education Solutions Consulting
*! http://www.paces-consulting.org

cap prog drop email
prog email
version 12.1
syntax , From(str) To(str) Subject(str) [Body(str) Attachment(str) Directory(str)]

if "`to'" == "" | "`from'" == "" {
	err 198
	di in red `"Must include 'To' and 'From' email addresses"'
}

if "`attachment'" != "" {
	if "`directory'" == "" {
		err 198
		di in red "Must include file path to attachment to send attachments"
	}
	else {
		tempname em
		tempfile email
		
		file open `em' using `"`email'.py"', w replace
		file write `em' "import smtplib" _n
		file write `em' "from email.mime.application import MIMEApplication" _n
		file write `em' "from email.mime.multipart import MIMEMultipart" _n
		file write `em' "from email.MIMEText import MIMEText" _n
		file write `em' "msg = MIMEMultipart()" _n
		file write `em' "msg['Subject'] = '`subject''" _n
		file write `em' "msg['From'] = '`from'' " _n
		file write `em' "msg['To'] = '`to'' " _n
		file write `em' "part = MIMEText('`body'')" _n
		file write `em' "msg.attach(part)" _n
		file write `em' `"part = MIMEApplication(open("`directory'/`attachment'").read())"' _n
		file write `em' `"part.add_header('Content-Disposition', 'attachment', filename = "`attachment'")"' _n
		file write `em' "msg.attach(part)" _n
		file write `em' "s = smtplib.SMTP('localhost')" _n
		file write `em' "s.sendmail(msg['From'], msg['To'], msg.as_string())" _n
		file write `em' "s.quit()"
		file close `em'
		
		! python "`email'.py"
	}
}	
else {	
	tempname em msg
	tempfile email
	file open `msg' using body.txt, w replace
	file write `msg' `"`body'"' _n
	file close `msg'

	file open `em' using `email'.py, w replace
	file write `em' `"import smtplib"' _n
	file write `em' `"from email.mime.text import MIMEText"' _n
	file write `em' `"fp = open('body.txt', 'rb')"' _n
	file write `em' `"msg = MIMEText(fp.read())"' _n
	file write `em' `"fp.close"' _n
	file write `em' `"msg['Subject'] = '`subject''"' _n
	file write `em' `"msg['From'] = '`from''"' _n
	file write `em' `"msg['To'] = '`to''"' _n 
	file write `em' `"s = smtplib.SMTP('localhost')"' _n
	file write `em' `"s.sendmail(msg['From'], msg['To'], msg.as_string())"' _n
	file write `em' `"s.quit()"' _n
	file close `em'
	! python "`email'.py"
	rm body.txt
}

end


