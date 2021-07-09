*** version 1.2 13Dec2019
*** contact information: plus1@sogang.ac.kr

program sublime
	version 10
	syntax [, Installed Portable KEEPwhereis Manually]

qui {

*** check current operating system
	if "`c(os)'"!="Windows" {
		noisily mata: printf("{cmd}sublime.ado{error} only works on Windows machines\n")
		exit 198
	}

*** memorize cd
	local current "`c(pwd)'"

*** move to Sublime Text
	if "`manually'"!="" {
	* manually: on
		noisily mata: printf("{cmd}sublime.ado{text} will create {result}StataEditor.sublime-settings{text} file in your working directory...\n")
		noisily mata: printf("{text}Move this file to {result}Packages/User{text} directory of {result}Sublime Text\n")
	}
	else {
	* manually: off
		capture macro drop _sldir
		if "`installed'"!="" & "`portable'"!="" {
		* users should not specify both options
			di as error "options installed and portable may not be combined"
			exit 184
		}
		else if "`installed'"!="" {
		* installed: on
			noisily sublime_installed
		}
		else if "`portable'"!="" {
		* portable: on
			global keepwhereis "`keepwhereis'"
			noisily sublime_portable
		}
		else {
		* options: off
			global keepwhereis "`keepwhereis'"
			capture noisily: sublime_portable
			if _rc!=0 {
				noisily sublime_installed
			}
		}
		capture macro drop keepwhereis
	}

*** get Stata info
	capture macro drop _statabit _statafl _stataver _fws_dir
	if `c(bit)'==64 {
		local statabit "-`c(bit)'"
	}
	if `c(MP)'==1 {
		local statafl "StataMP"
	}
	else if `c(SE)'==1 {
		local statafl "StataSE"
	}
	else if "`c(flavor)'"=="IC" {
		local statafl "Stata"
	}
	else {
		local statafl "smStata"
	}
	local stataver=round(`c(stata_version)')
	local fws_dir=subinstr("`c(sysdir_stata)'", "\", "/", .)
	if strmatch("`fws_dir'", "*/")!=1 {
		local fws_dir "`fws_dir'/"
	}

*** write sublime-settings
	capture file close slset
	capture erase "StataEditor.sublime-settings"
	file open slset using "StataEditor.sublime-settings" , write text replace
	file write slset `"{"' _n
	file write slset `"	"extensions":"' _n
	file write slset `"	["' _n
	file write slset `"		"sthlp","' _n
	file write slset `"		"pkg""' _n
	file write slset `"	],"' _n
	file write slset `"	"stata_path": "`fws_dir'`statafl'`statabit'.exe","' _n
	file write slset `"	"stata_version": `stataver',"' _n
	file write slset `"}"' _n
	file close slset

*** register the Stata Automation type library 
	cd "`c(sysdir_stata)'"
	shell `statafl'`statabit' /Regserver

*** reset cd
	noisily mata: printf("{cmd}sublime.ado{text} successfully set up {cmd}StataEditor\n")
	cd "`current'"

}

end

program sublime_installed
	version 10

qui {

	noisily mata: printf("{cmd}sublime.ado{text} will assume that {result}Sublime Text{text} has been {result}installed{text} on your system...\n")
*** depend on environment variable %APPDATA%
	local sldir : environ APPDATA
	local sldir=subinstr("`sldir'", "\", "/", .)
	if strmatch("`sldir'", "*/")==1 {
		local sldir=substr("`sldir'", 1, strlen("`sldir'")-1)
	}
	capture cd "`sldir'/Sublime Text 3/Packages/User"
	if _rc!=0 {
	*** depend on environment variable %USERPROFILE%
		local sldir : environ USERPROFILE
		local sldir=subinstr("`sldir'", "\", "/", .)
		if strmatch("`sldir'", "*/")==1 {
			local sldir=substr("`sldir'", 1, strlen("`sldir'")-1)
		}
		capture cd "`sldir'/AppData/Roaming/Sublime Text 3/Packages/User"
		if _rc!=0 {
		* Sublime Text seems not to be installed
			noisily mata: printf("{result}Sublime Text{error} could not be found on your system\n")
			noisily mata: printf("{text}If you are using {result}portable version{text} of {result}Sublime Text{text},\n")
			noisily mata: printf("{text}please store the directory of {result}Sublime Text{text} with ssc package {cmd}whereis{text} as follows:\n")
			noisily mata: printf(`"{result}. whereis Sublime "path/to/Sublime Text/sublime_text.exe"\n"')
			exit 601
		}
	}

}

end

program sublime_portable
	version 10

qui {

	noisily mata: printf("{cmd}sublime.ado{text} will assume that you are using {result}portable version{text} of {result}Sublime Text{text}...\n")
*** depend on whereis command
	capture whereis Sublime
	if _rc!=0 {
		capture which whereis
		if _rc!=0 {
			noisily mata: printf("{cmd:whereis.ado}{error} is not installed\n")
			capture macro drop keepwhereis
			exit 199
		}
		else {
			noisily mata: printf("{error}location of {result}Sublime Text{error} has not been stored with {cmd:whereis.ado}\n")
			capture macro drop keepwhereis
			exit 601
		}
	}
	local sldir "`r(Sublime)'"
	local sldir=subinstr("`sldir'", "\", "/", .)
	local sldir=substr("`sldir'", 1, strlen("`sldir'")-17)
	capture cd "`sldir'/Data/Packages/User"
	if _rc!=0 {
	* whereis command might have stored the directory of non-portable version
		noisily mata: printf("{cmd}whereis.ado{error} seems to store the path to {result}installed version{error} of {result}Sublime Text\n")
		if "$keepwhereis"!="" {
		* keepwhereis: on
			noisily mata: printf("{error}Please check the directory stored with {cmd}whereis.ado\n")
		}
		else {
		* keepwhereis: off
			sublime_whereis
			noisily mata: printf("{cmd}sublime.ado{error} automatically removed the directory of {result}Sublime Text{error} stored with {cmd}whereis.ado\n")
		}
		capture macro drop keepwhereis
		exit 601
	}

}

end

program sublime_whereis
	version 10

qui {

*** memorize cd
	local current "`c(pwd)'"

*** read whereis.dir
	capture file close wdir
	capture file close wdirnew
	capture macro drop _wline _wlines
	cd "`c(sysdir_plus)'\w"
	file open wdir using "whereis.dir" , read
	file read wdir wline
	local wlines1 "`wline'"
	local i=2
	while r(eof)==0 {
		file read wdir wline
		local wlines`i' "`wline'"
		local i=`i'+1
	}
	file close wdir

*** re-write whereis.dir without the location of Sublime Text
	erase "whereis.dir"
	file open wdirnew using "whereis.dir" , write text replace
	local j=1
	while `j'<`i'-1 {
		if strmatch("`wlines`j''", "Sublime*")!=1 {
			file write wdirnew `"`wlines`j''"' _n
		}
		local j=`j'+1
	}
	file close wdirnew

*** reset cd
	cd "`current'"

}

end
