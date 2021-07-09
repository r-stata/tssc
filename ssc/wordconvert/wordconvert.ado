program define wordconvert
	version 12.0
	syntax anything(id="file source" name=filesource), [replace encoding(string)]
	
	token `"`filesource'"'
	
	if `"`2'"' == "" {
		disp as error `"you need to specify two files."'
		error 198
	}
	
	if `"`3'"' != "" {
		disp as error `"you can only specify two files."'
		error 198
	}

	if fileexists(`"`1'"') == 0 {
		disp as error `"file `1' not found"'
		error 198
	}

	if fileexists(`"`2'"') == 1 & "`replace'" == "" {
		disp as error `"file `2' has already existed, please specify the option replace"'
		error 198
	}

	if regexm(`"`1'"', "(\.doc|\.docx|\.dot|\.pdf|\.xps|\.rtf|\.htm|\.html)$") == 0 {
		disp as error `"filename extension is not specified correctly in `1'"'
		error 198
	}

	if regexm(`"`2'"', "(\.doc|\.docx|\.dot|\.pdf|\.xps|\.rtf|\.htm|\.html)$") == 0 {
		disp as error `"filename extension is not specified correctly in `2'"'
		error 198
	}
	
	if "`encoding'" != "" & `=c(stata_version)' < 14 {
		disp as error `"the option encoding could only be used in version 14 or above"'
		error 198
	}
	
	if `=c(stata_version)' >= 14 & "`encoding'" == "" {
		disp as text "you are using Stata version `=c(stata_version)', be sure that the names and locations of the files do not have characters ASCII can not recognize, or you need to specify the option encoding()"
	}
	
	if index(`"`1'"', "/") + index(`"`1'"', "\") == 0 {
		local 1 `"`=c(pwd)'/`1'"'
	}

	if index(`"`2'"', "/") + index(`"`2'"', "\") == 0 {
		local 2 `"`=c(pwd)'/`2'"'
	}
	
	if "`encoding'" != "" {
		local 1 = `"`=ustrto(`"`1'"', "`encoding'", 1)'"'
		local 2 = `"`=ustrto(`"`2'"', "`encoding'", 1)'"'
	}

	qui {
		tempname handle
		file open `handle' using wordconvert.ps1, write replace
		file write `handle' `"\$word = new-object -ComObject "word.application""' _n
		file write `handle' `"\$word.Visible = \$false"' _n
		if regexm(`"`2'"', "\.pdf$") {
			file write `handle' `"\$format = 17"' _n
		}
		else if regexm(`"`2'"', "\.xps$") {
			file write `handle' `"\$format = 18"' _n
		}
		else if regexm(`"`2'"', "\.rtf$") {
			file write `handle' `"\$format = 6"' _n
		}
		else if regexm(`"`2'"', "(\.doc|\.dot)$") {
			file write `handle' `"\$format = 0"' _n
		}
		else if regexm(`"`2'"', "(\.htm|\.html)$"){
			file write `handle' `"\$format = 10"' _n
		}
		else {
			file write `handle' `"\$format = 12"' _n
		}
		file write `handle' `"\$doc = \$word.documents.open("`1'")"' _n
		file write `handle' `"\$doc.SaveAs([ref]"`2'", [ref]\$format)"' _n
		file write `handle' `"\$doc.Close()"' _n
		file write `handle' `"\$word.quit()"'
		file close `handle'

		! powershell "`=c(pwd)'/wordconvert.ps1"
		
		cap erase wordconvert.ps1
		while _rc != 0 {
			! del wordconvert.ps1 /f
		}
	}

end
