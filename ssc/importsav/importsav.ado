*** version 3.0.4 21Jan2020
*** contact information: plus1@sogang.ac.kr

program findr , sclass
	version 10

quietly {

	sreturn local Rpath ""

	capture whereis R
	if _rc==0 {
	* depend on whereis
		local Rpath "`r(R)'"
		if strmatch("`Rpath'", "*R.exe")==1 {
			local Rpath=substr("`Rpath'", 1, strlen("`Rpath'")-4)
		}
	}
	else {
	* depend on expected directories
		capture which whereis
		if _rc==0 {
			noisily mata: printf("{txt}location of R has not been stored with {cmd:whereis.ado}\n")
		}
		else {
			noisily mata: printf("{cmd:whereis.ado}{text} is not installed\n")
		}
		noisily mata: printf("{cmd:importsav.ado}{text} searches expected directories...\n")
		local wd `c(pwd)'
		if c(os)=="Windows" {
		* in Windows
			capture cd "C:\Program Files\R"
			if _rc!=0 {
				capture cd "C:\Program Files (x86)\R"
				if _rc!=0 {
					noisily mata: printf("{cmd:importsav.ado}{text} could not find R in expected directories\n...will depend on the PATH environment variable\n")
					local Rpath R
					local Renv on
				}
			}
			if _rc==0 {
				local Rversion : dir "`c(pwd)'" dirs "R*", respectcase
				local i : word count `Rversion'
				local newest_R : word `i' of `Rversion'
				cd "`newest_R'\bin"
				if c(osdtl)=="64-bit" {
					capture cd x64
				}
				local Rpath "`c(pwd)'\R"
				cd "`wd'"
			}
		}
		else {
		* in macOS
			local Rpath "/usr/bin/R"
			capture confirm file "`Rpath'"
			if _rc!=0 {
				local Rpath "/usr/local/bin/R"
				capture confirm file "`Rpath'"
				if _rc!=0 {
					capture cd "/Library/Frameworks/R.framework/Resources/bin/"
					if _rc==0 {
							local Rpath "`c(pwd)'/R"
					}
					else {
						noisily mata: printf("{cmd:importsav.ado}{text} could not find R in expected directories\n...will depend on the PATH environment variable\n")
						local Rpath R
						local Renv on
					}
					cd "`wd'"
				}
			}
		}
	}

	if "`Renv'"=="on" {
	* depend on environment variables
		if c(os)=="Windows" {
		* in Windows
			local Renv : environ R_HOME
			if "`Renv'"!="" {
			* depend on %R_HOME%
				local Rpath "`Renv'\bin\R"
				if c(osdtl)=="64-bit" {
					local Rpath "`Renv'\bin\x64\R"
				}
				local Renv off
			}
			else {
			* depend on %PATH%
				local Renv : environ PATH
				tokenize `Renv' , p(";")
				local i=1
				while "``i''"!="" {
					if strmatch("``i''","*\R*")==1 {
						local Rpath "``i''\R"
						local Renv off
					}
					local i=`i'+1
				}
			}
		}
		else {
		* in macOS
			local Renv : environ PATH
			tokenize `Renv' , p(":")
			local i=1
			while "``i''"!="" {
				if strmatch("``i''","*/R")==1 {
					local Rpath "``i''"
					local Renv off
				}
				local i=`i'+1
			}
		}
		if "`Renv'"!="off" {
			noisily mata: printf("{cmd:importsav.ado}{error} could not find R on your system\n")
			exit 601
		}
	}

	sreturn local Rpath "`Rpath'"

}

end

program rrepos , sclass
	version 10

quietly {

	sreturn local Rrepos ""

	if strmatch("`c(locale_icudflt)'", "zh*")==1 {
		local Rrepos "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"
	}
	else if strmatch("`c(locale_icudflt)'", "ja*")==1 {
		local Rrepos "https://cran.ism.ac.jp/"
	}
	else if strmatch("`c(locale_icudflt)'", "ko*")==1 & strmatch("`c(locale_icudflt)'", "kok*")!=1 {
		local Rrepos "https://cran.seoul.go.kr/"
	}
	else if strmatch("`c(locale_icudflt)'", "es*")==1 {
		local Rrepos "http://mirror.fcaglp.unlp.edu.ar/CRAN/"
	}
	else if strmatch("`c(locale_icudflt)'", "sv*")==1 {
		local Rrepos "https://ftp.acc.umu.se/mirror/CRAN/"
	}
	else {
		local Rrepos "https://cloud.r-project.org/"
	}

	sreturn local Rrepos "`Rrepos'"

}

end

program getdataname , sclass
	version 10
	syntax [anything]

quietly {

	sreturn local dataname ""
	if "`anything'"=="" {
		local anything "`c(filename)'"
	}
	tokenize "`anything'" , p("/")
	local i=1
	while "``i''"!="" {
		if strmatch(lower("``i''"), "*.dta")==1 | strmatch(lower("``i''"), "*.sav")==1 {
			sreturn local dataname "``i''"
			exit
		}
		local i=`i'+1
	}

}

end

program importsav , sclass
	version 10
	syntax anything [, Encoding(string) Reencode(string) Unicode(string) Compress(integer 256) OFFdefault]

quietly {

	sreturn local spssfile ""
	sreturn local statafile ""
	sreturn local encoding ""
	sreturn local reencode ""

*** get file names
	if upper("`encoding'")=="NULL" | upper("`encoding'")=="NA" | upper("`encoding'")=="OFF" {
		local encoding ""
	}
	if "`encoding'"!="" & "`reencode'"=="" {
		local reencode "`encoding'"
	}
	if upper("`reencode'")=="NA" | upper("`reencode'")=="NULL" | upper("`reencode'")=="OFF" {
		local reencode ""
	}
	if "`reencode'"!="" & "`unicode'"=="" {
		local unicode "`reencode'"
	}
	if upper("`unicode'")=="OFF" | upper("`unicode'")=="NULL" | upper("`unicode'")=="NA" {
		local unicode ""
	}
	if "`encoding'"=="" & "`reencode'"=="" & "`unicode'"=="" & `compress'==256 & "`offefault'"=="" {
	* options: off
		if "`1'"=="haven" & "`2'"!="" {
		* subcommand: haven
			local 0=substr(`"`0'"' , 7, .)
			tokenize `"`0'"'
			local subcommand haven
		}
		else if "`1'"=="foreign" & "`2'"!="" {
		* subcommand: foreign
			local 0=substr(`"`0'"' , 9, .)
			tokenize `"`0'"'
			local subcommand foreign
		}
	}
	else {
	* options: on
		if "`1'"=="haven" & "`2'"!="" {
		* subcommand: haven
			local 0=substr(`"`0'"' , 7, .)
			local subcommand haven
		}
		else if "`1'"=="foreign" & "`2'"!="" {
		* subcommand: foreign
			local 0=substr(`"`0'"' , 9, .)
			local subcommand foreign
		}
		tokenize `"`0'"' , p(", ")
		if "`2'"=="," {
			local 2 ""
		}
	}
	local spssfile "`1'"
	local statafile "`2'"

*** transform file names
	if strmatch(lower("`spssfile'"), "*.sav")!=1 {
		local spssfile "`spssfile'.sav"
	}
	local spssfile=subinstr("`spssfile'", "\", "/", .)
	if "`statafile'"=="" {
		local statafile=substr("`spssfile'", 1, strlen("`spssfile'")-4)
	}
	if strmatch(lower("`statafile'"), "*.dta")!=1 {
		local statafile "`statafile'.dta"
	}
	local statafile=subinstr("`statafile'", "\", "/", .)

*** check file existence
	capture confirm file "`spssfile'"
	if _rc!=0 {
		noisily di as error "file `spssfile' not found"
		exit 601
	}
	noisily findr

*** call subcommands
	sreturn local spssfile "`spssfile'"
	sreturn local statafile "`statafile'"
	sreturn local encoding "`encoding'"
	sreturn local reencode "`reencode'"

	if "`subcommand'"=="haven" {
	* subcommand: haven
		capture importsav_haven
		local tried "haven"
		if _rc==0 {
			getdataname `spssfile'
			noisily mata: printf("{result}`s(dataname)'{text} was successfully converted using {cmd:`tried'}\n")
		}
		else {
			noisily mata: printf("{error}`spssfile' could not be converted using {cmd:`tried'}\n")
			exit 601
		}
	}
	else if "`subcommand'"=="foreign" {
	* subcommand: foreign
		capture importsav_foreign
		local tried "foreign"
		if _rc==0 {
			getdataname `spssfile'
			noisily mata: printf("{result}`s(dataname)'{text} was successfully converted using {cmd:`tried'}\n")
		}
		else {
			noisily mata: printf("{error}`spssfile' could not be converted using {cmd:`tried'}\n")
			exit 601
		}
	}
	else {
	* no subcommands
		capture importsav_haven
		local tried "haven"
		if _rc==0 {
			getdataname `spssfile'
			noisily mata: printf("{result}`s(dataname)'{text} was successfully converted using {cmd:`tried'}\n")
		}
		else {
			noisily mata: printf("{cmd:`tried'}{text} has failed to convert your data\n")
			capture importsav_foreign
			local tried "foreign"
			noisily mata: printf("{cmd:importsav.ado}{text} is trying to use {cmd:`tried'}...\n")
			if _rc==0 {
				getdataname `spssfile'
				noisily mata: printf("{result}`s(dataname)'{text} was successfully converted using {cmd:`tried'}\n")
			}
			else {
				noisily mata: printf("{cmd:`tried'}{text} has failed to convert your data\n{error}your data could not be converted using R packages\n")
				exit 601				
			}
		}
	}
	capture macro drop spssfile statafile encoding reencode dataname

*** options
	if "`tried'"=="foreign" & round(c(stata_version))>=14 & "`unicode'"!="" {
		noisily mata: printf("{text}current version of {result}Stata{text} is newer than {result}13{text} but {result}`statafile'{text} contains {result}extended ASCII{text}...\n\n")
		clear
		unicode encoding set "`unicode'"
		noisily unicode translate "`statafile'", invalid
		noisily mata: printf("\n{text}you are running {result}Stata `c(stata_version)'{text} so {cmd}importsav.ado{text} translated your data to {result}UTF-8\n")
	}

	use "`statafile'", clear

	if "`offdefault'"!="" {
		exit
	}

	memory
	return list , all
	local toobigfile r(data_data_u)
	local compress=`compress'*1024*1024
	if `toobigfile' > `compress' {
		noisily di as text "please wait until compression is done..."
		compress , nocoalesce
		save , replace
		getdataname
		noisily mata: printf("{text}file {result}`s(dataname)'{text} saved\n")
	}

	exit

}

end

program importsav_haven

quietly {

	local spssfile "`s(spssfile)'"
	local statafile "`s(statafile)'"
	local encoding "`s(encoding)'"
	capture erase "`statafile'"

	local bws_dir `c(pwd)'
	local fws_dir=subinstr("`bws_dir'", "\", "/", .)

	local sourcefile=round(runiform()*1000)
	capture file close rsource
	file open rsource using `sourcefile'.R , write text replace

	rrepos
	file write rsource `"if (!require(haven)) install.packages("haven", repos="`s(Rrepos)'"); library(haven)"' _n
	file write rsource `"setwd("`fws_dir'")"' _n
	if "`encoding'"!="" {
		file write rsource `"data<-read_sav("`spssfile'", encoding="`encoding'")"' _n
	}
	else {
		file write rsource `"data<-read_sav("`spssfile'")"' _n
	}
	file write rsource `"data2<-data"' _n
	file write rsource `"n<-1"' _n
	file write rsource `"while (n<length(data)+1) {"' _n
	file write rsource `"	if (is.numeric(data[[n]])==TRUE) {"' _n
	file write rsource `"		if (max(data[[n]], na.rm=TRUE)>=2147483647) {"' _n
	file write rsource `"			if (!require(bit64)) install.packages("bit64", repos="`s(Rrepos)'"); library(bit64)"' _n
	file write rsource `"			class(data2[[n]])<-NULL"' _n
	file write rsource `"			data2[[n]]<-as.integer64.integer64(data2[[n]])"' _n
	file write rsource `"			attr(data2[[n]], "label")<-attr(data[[n]], "label", exact=TRUE)"' _n
	file write rsource `"		}"' _n
	file write rsource `"		else {"' _n
	file write rsource `"			if (all(data[[n]]==as.integer(data[[n]]), na.rm=TRUE)==FALSE) {"' _n
	file write rsource `"				data2[[n]]<-as.numeric(data[[n]])"' _n
	file write rsource `"				attr(data2[[n]], "label")<-attr(data[[n]], "label", exact=TRUE)"' _n
	file write rsource `"			}"' _n
	file write rsource `"		}"' _n
	file write rsource `"	}"' _n
	file write rsource `"	n<-n+1"' _n
	file write rsource `"}"' _n
	file write rsource `"write_dta(data2, "`statafile'")"' _n

	file close rsource
	shell "`s(Rpath)'" --vanilla -f "`sourcefile'.R"
	erase `sourcefile'.R
	confirm file "`statafile'"

}

end

program importsav_foreign
	version 10

quietly {

	local spssfile "`s(spssfile)'"
	local statafile "`s(statafile)'"
	local reencode "`s(reencode)'"
	capture erase "`statafile'"

	local bws_dir `c(pwd)'
	local fws_dir=subinstr("`bws_dir'", "\", "/", .)

	local sourcefile=round(runiform()*1000)
	capture file close rsource
	file open rsource using `sourcefile'.R, write text replace

	file write rsource `"library(foreign)"' _n
	file write rsource `"setwd("`fws_dir'")"' _n
	if "`reencode'"!="" {
		file write rsource `"data<-read.spss("`spssfile'", reencode="`reencode'", to.data.frame=TRUE)"' _n
	}
	else {
		file write rsource `"data<-read.spss("`spssfile'", to.data.frame=TRUE)"' _n
	}
	file write rsource `"write.dta(data, "temporary_`sourcefile'.dta")"' _n
	file write rsource `"data2<-read.dta("temporary_`sourcefile'.dta")"' _n
	file write rsource `"attr(data2, "var.labels")<-attr(data, "variable.labels")"' _n
	file write rsource `"attr(data2, "datalabel")<-"""' _n
	file write rsource `"write.dta(data2, "`statafile'")"' _n

	file close rsource
	shell "`s(Rpath)'" --vanilla -f "`sourcefile'.R"
	erase `sourcefile'.R
	erase "temporary_`sourcefile'.dta"
	confirm file "`statafile'"

}

end
