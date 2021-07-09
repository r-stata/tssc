*! whichencoding 1.1; 4 February 2016
*! Examine Stata data and text files to determine encoding status.
*! Requires Stata 14.1 (28jan2016 update)
*! Authors: Svend Juul and Morten Frydenberg
program whichencoding
version 14.1
syntax anything(name=FILESPEC id="File list") [, Detail nodata]
preserve
clear
local pwd = c(pwd)

// Table heading
display as res _n "{hline 55}"              ///
	_n "Directory: `pwd'"                   ///
	_n "{hline 55}"                         ///
	_n "File name{col 32}Version  Encoding" ///
	_n "{hline 55}"

// Expand file list
local NF = wordcount(`"`FILESPEC'"')
local FILELIST ""
forvalues N = 1/`NF' {
	local F : word `N' of `FILESPEC'
	local FF : dir . files "`F'" , respectcase 
	local FILELIST = `"`FILELIST' `FF'"'
}

foreach F of local FILELIST {

	local L = strrpos("`F'", ".")        // Position of last "."
	local F1 = substr("`F'", 1, `L'-1)
	local F2 = substr("`F'", `L', .)
	
	// Rename backup files, if any
	rename_bakfiles `"`F'"' 
	quietly cd "`pwd'"
	
    // unicode analyze
	if "`detail'" == "" {
		quietly capture unicode analyze "`F'" , redo `nodata'
	}
	else {
		unicode analyze "`F'" , redo `nodata'
	}
	if r(N_ascii) local ENC " Plain ASCII" 
	if r(N_utf8) local ENC " Unicode"
	if r(N_needed) local ENC " Extended ASCII"
	local FAIL = r(N_failure)
		
	// .dta file
	if strlower("`F2'") == ".dta" {
		// Find Stata version - r(sv)
		find_version "`F'"
		if `r(sv)' == 0  display as err "`F' is not a Stata dataset"
		else if "`r(sv)'" == "" display as res "`F'{col 40}`ENC'"
		else display as res "`F'{col 33} v`r(sv)'{col 40}`ENC'"
		if `FAIL' display as err "`F' is impossible to translate" _n
	}

	// text file
	else if strpos(".ado.do.mata.log.txt.csv.sthlp.class.dlg.idlg.ihlp.smcl.stbcal", strlower("`F2'")) {
		display as res "`F'{col 40}`ENC'"
		if `FAIL' display as err "Impossible to translate: `F'" _n
	}
}
display as res "{hline 55}"
end

************************** Program find_version *****************************
program find_version , rclass
version 14
args F
quietly capture dtaversion "`F'"
local DV = r(version)
if _rc != 0  {
	return local sv = 0
	exit
}
else if `DV'>118 local SV = 15       // not valid forever
else {
	local DVERS "118 117 115 114 113 112 111 110 108 105 104 103 102"
	local SVERS " 14  13  12  10   8   8   7   7   6   5   4   2   1"
	local NV = wordcount("`DVERS'")
	forvalues N =1/`NV' {
		if "`DV'" == word("`DVERS'", `N') {
			local SV = word("`SVERS'", `N')
			continue, break
		}
	}
}
return local sv = `SV'
end

************************** Program rename_bakfiles *****************************
program rename_bakfiles
version 14
args F
quietly {
	capture cd bak.stunicode
	if _rc!=0 exit
	capture confirm file "`F'"
	if _rc==0 {
		copy "`F'" "bak_`F'" , replace
		erase "`F'"
	}
	capture cd status.stunicode
	if _rc !=0 exit
	foreach EXT in oka oku t {
		capture confirm file "`F'.`EXT'"
		if _rc==0 {
			copy "`F'.`EXT'" "bak_`F'.`EXT'" , replace
			erase "`F'.`EXT'"
			exit
		}
	}
}
end
