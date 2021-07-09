*! svtxt version 1.0 \ Dennis Lund Hansen \ dlh@dadlnet.dk \ autum 2018
*! Saves text, chapter marks and section marks to log, without additinal loggin noise

program define svtxt
version 10.0

if `c(userversion)' != `c(stata_version)' {
display as error `"Your current Stata version is `c(stata_version)', but you have set the version to `c(userversion)'?"'
display as error `"Text in -svtxt- will be displayed as in Stata `c(userversion)'"'
display `"If this is intensionally, no action is needed."' 
display as result _n ""
}

_on_colon_parse `0'

local tekstbody_dvpd  `"`s(after)'"'
local 0 `"`s(before)'"'

syntax [name(id=Logname name=logname)] [, Underline Line Chapter Section CHAPTERAscii SECTIONAscii]

if missing(`"`logname'"') {
	capture confirm scalar sv_lognavn_dvpd
	if _rc { 	
	display as error "LOGNAME missing and not previously defined"
	exit 198
	}
}	

	
	
if !missing(`"`logname'"') {
	scalar sv_lognavn_dvpd = `"`logname'"'
}

*control and error messages:

if missing(`"`underline'"') + ///
 missing(`"`line'"') + ///
 missing(`"`chapter'"') + ///
 missing(`"`section'"') + ///
 missing(`"`chapterascii'"') + ///
 missing(`"`sectionascii'"') < 5 {
	display as error "Options in svtxt" 
	error 184
}

	
	

if  missing(`"`tekstbody_dvpd'"')==1 {
	display as error "text is missing"
	exit 198
}


* forming output


* regular text output
if  `"`underline'"' == `"underline"' {
	quietly{
		log on `=scalar(sv_lognavn_dvpd)'
		version `c(userversion)'
		noisily display in smcl  `"{ul on}`tekstbody_dvpd'{ul off}"'
		version 9
		log off `=scalar(sv_lognavn_dvpd)'
	}
} 

if missing(`"`underline'"') + ///
 missing(`"`line'"') + ///
 missing(`"`chapter'"') + ///
 missing(`"`section'"') + ///
 missing(`"`chapterascii'"') + ///
 missing(`"`sectionascii'"') == 6 {
	quietly{
		log on `=scalar(sv_lognavn_dvpd)'
		version `c(userversion)'
		noisily display in smcl  `"`tekstbody_dvpd'"'
		version 9
		noisily display in smcl _n 
		log off `=scalar(sv_lognavn_dvpd)'
	}
} 



if `"`line'"' == `"line"'   {
	quietly{
		log on `=scalar(sv_lognavn_dvpd)'
		noisily display in smcl "{hline 25}" _n
		version `c(userversion)'
		noisily display in smcl  `"`tekstbody_dvpd'"'
		version 9
		noisily display in smcl _n "{hline 25}" _n
		log off `=scalar(sv_lognavn_dvpd)'
	}
} 




* chapter funktion
if `"`chapter'"' == `"chapter"' {
	* setting chapter number
	capture confirm scalar  sv_chapnum_dvpd
	display _rc
	if _rc!=0{
		scalar sv_chapnum_dvpd = 1
		capture scalar sv_secnum_dvpd =0 
	}
	else {
		scalar sv_chapnum_dvpd= sv_chapnum_dvpd+ 1
		capture scalar sv_secnum_dvpd = 0
	}

	quietly{
		log on `=scalar(sv_lognavn_dvpd)'
		noisily display in smcl "{hline}" 
		if `"`chapterascii'"' == `"chapterascii"' {
			noisily display as text "   ________  _____    ____  ________________ "
			noisily display as text "  / ____/ / / /   |  / __ \/_  __/ ____/ __ \"
			noisily display as text " / /   / /_/ / /| | / /_/ / / / / __/ / /_/ /"
			noisily display as text "/ /___/ __  / ___ |/ ____/ / / / /___/ _, _/ "
			noisily display as text "\____/_/ /_/_/  |_/_/     /_/ /_____/_/ |_|  "
		}
		noisily display in smcl "{hline}" _n
		version `c(userversion)'
		noisily display in smcl as result "Chapter `=sv_chapnum_dvpd': `tekstbody_dvpd'" _n
		version 9
		noisily display in smcl "{hline}" 
		noisily display in smcl "{hline}" _n _n
		log off `=scalar(sv_lognavn_dvpd)'
		}
}





* section before chapter
if `"`section'"' == `"section"' {
	capture confirm scalar sv_chapnum_dvpd 
	if _rc!=0 {
		display as error `"Section definede before chapter 1"' _n `"Section vil be namede only by section number"' _n
		capture confirm scalar sv_secnum_dvpd
		if _rc!=0{
			scalar sv_secnum_dvpd = 1
		}
		if _rc==0{
			scalar sv_secnum_dvpd = sv_secnum_dvpd + 1
		}

		quietly{
		log on `=scalar(sv_lognavn_dvpd)'
		if `"`sectionascii'"' == `"sectionascii"' {
			noisily display as text "   _____ __________________________  _   __"
			noisily display as text "  / ___// ____/ ____/_  __/  _/ __ \/ | / /"
			noisily display as text "  \__ \/ __/ / /     / /  / // / / /  |/ / "
			noisily display as text " ___/ / /___/ /___  / / _/ // /_/ / /|  /  "
			noisily display as text "/____/_____/\____/ /_/ /___/\____/_/ |_/   "
		}                                           
		noisily display in smcl as result "{hline 75}" _n
		version `c(userversion)'
		noisily display in smcl as result "Section `=sv_secnum_dvpd': `tekstbody_dvpd'" _n
		version 9
		noisily display in smcl "{hline 75}" _n
		log off `=scalar(sv_lognavn_dvpd)'
		}
	}


* section function
	capture confirm scalar sv_chapnum_dvpd 
	if _rc==0 {
		capture confirm scalar sv_chapnumcopy_dvpd
		if _rc!=0{
			scalar sv_chapnumcopy_dvpd = 0
		}
		
		capture confirm scalar sv_secnum_dvpd
		if _rc!=0{
			scalar sv_secnum_dvpd = 1
		}

		capture confirm scalar sv_secnum_dvpd 
		if (_rc==0 & sv_secnum_dvpd==0) {
			scalar sv_secnum_dvpd = 1
		}

		if sv_chapnumcopy_dvpd==sv_chapnum_dvpd {
			scalar sv_secnum_dvpd = sv_secnum_dvpd +1
		}

		if sv_chapnumcopy_dvpd<sv_chapnum_dvpd {
			scalar sv_secnum_dvpd = 1
		}

		scalar sv_chapnumcopy_dvpd = sv_chapnum_dvpd

		quietly{
			log on `=scalar(sv_lognavn_dvpd)'
			if `"`sectionascii'"' == `"sectionascii"'  {
				noisily display as text "   _____ __________________________  _   __"
				noisily display as text "  / ___// ____/ ____/_  __/  _/ __ \/ | / /"
				noisily display as text "  \__ \/ __/ / /     / /  / // / / /  |/ / "
				noisily display as text " ___/ / /___/ /___  / / _/ // /_/ / /|  /  "
				noisily display as text "/____/_____/\____/ /_/ /___/\____/_/ |_/   "
			}  
			noisily display in smcl "{hline 75}" _n
			version `c(userversion)'
			noisily display in smcl as result "Section `=sv_chapnum_dvpd'.`=sv_secnum_dvpd': `tekstbody_dvpd'" _n
			version 9
			noisily display in smcl "{hline 75}" _n
			log off `=scalar(sv_lognavn_dvpd)'
		}
	}
}
end
