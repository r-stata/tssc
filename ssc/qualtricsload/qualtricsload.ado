*! version 0.1.0 20feb2019 Nicholas J. G. Winter
program qualtricsload
	version 15.1

	#delimit ;
	syntax anything(name=surveyid id="Survey ID"), 	[
		APItoken(string)
		DATAcenter(string)
		format(string)
		noDISPlayorder
		TIMEzone(string)
		STARTdate(string)
		ENDdate(string)
		NEWline(string)
		comma
		USELABels
		SEENunansweredrecode(string)
		MULTIselectseenunansweredrecode(string)

		saving(string) 	// can contain ', replace'
		replace 		// redundant with saving, replace
		stcmd
		debug			// undocumented
		]
		;

	local jars 
		stataQualtrics-0.1.0.jar 
		httpclient-4.5.5.jar 
		httpcore-4.4.9.jar 
		jackson-databind-2.6.7.2.jar 
		jackson-core-2.6.7.jar 
		jackson-annotations-2.6.0.jar
		;
	#delimit cr
	foreach jar of local jars {
		qui which `jar'
	}

	if "`format'"=="" {
		local format spss
	}

	// parse saving
	if `"`saving'"'!="" {
		local 0 `saving'
		syntax anything(name=saving) , [ REPLACE2 ]
		// redundant replace options
		if "`replace2'"=="replace2" {
			local replace replace
		}
	}
	else {
		// no saving specified, so get survey name
		javacall edu.virginia.nwinter.stataQualtricsSurveyExport surveyInfo, jars(`jars')
		local saving `qualtricsSurveyName' 
	}

	// ensure saving has extension
	if "`stcmd'"=="stcmd" & ustrright("`saving'",4)!=".dta" {
		local saving `saving'.dta
	}
	else if "`format'"=="spss" & ustrright("`saving'",4)!=".sav" {
		local saving `saving'.sav
	}
	else if "`format'"=="json" & ustrright("`saving'",5)!=".json" {
		local saving `saving'.json
	}
	else if "`format'"=="csv" & ustrright("`saving'",4)!=".csv" {
		local saving `saving'.csv
	}

	if "`stcmd'"=="stcmd" {
		capture which stcmd
		if _rc {
			di as error "stcmd not found."
			di as error "Make sure you have Stat-transfer installed and have properly configured the stcmd program"
			di as error `"See {stata:ssc describe stcmd} and {browse "https://stattransfer.com/":https://stattransfer.com/}."'
			exit 199
		}
		// put saving-->stataSaving
		local stataSaving `saving'
		tempfile saving 
		local format spss
	}
	if !inlist("`format'","spss","csv","tsv","json","ndjson") {
		di as error "format() invalid"
		exit 198
	}

	// check file already exists
	if "`replace'"=="" {
		if "`stataSaving'"!="" {
			local theFile `stataSaving'
		}
		else {
			local theFile `saving'
		}
		capture confirm file "`theFile'"
		if !_rc {
			di as error "file `theFile' already exists"
			exit 602
		}
	}

	local cmd javacall edu.virginia.nwinter.stataQualtricsSurveyExport main, jars(`jars')
	// di `"[`cmd']"'
	`cmd'

	if "`stcmd'"!=""{
		if "`stataSaving'"=="" {
			// get Q fn
			local stataSaving : subinstr local qualtricsDatasetName ".sav" ".dta"
		} 
		if ustrright("`stataSaving'",4)!=".dta" {
			local stataSaving `stataSaving'.dta
		}
		if "`replace'"=="replace" {
			local stcmdYOpt -y
		}
		di "{txt}Running Stat-transfer..." 
		// di `"---> `cmd'"'
		qui stcmd spss "`saving'" stata "`stataSaving'" `stcmdYOpt'
		di `"{stata `"use "`stataSaving'""':`stataSaving'} {txt}saved"'
	}
	else {
		di `"{res}`saving'{txt} saved"'
	}



end
