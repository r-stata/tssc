*! unicode2ascii 1.1; 4 February 2016
*! Translates Unicode characters in datasets and text files to extended ASCII
*! Saves version 11, 12, or 13
*! Requires Stata 14.1 (28jan2016 update)
*! Authors: Svend Juul and Morten Frydenberg
program unicode2ascii
version 14.1
syntax anything(name=FILESPEC id="File list") ///
	[, Encoding(string)                       ///
	Version(numlist >=11 <=13 integer)        ///
	Suffix(string)                            ///
	nodata                                    /// 
	replace]

if "`encoding'" == ""   local encoding "$UnicodeEncoding"
if "`encoding'" == ""   local encoding "Windows-1252"
if "`version'"  == ""   local version = 13
local txtsuffix "`suffix'"
local dtasuffix "`suffix'"
if "`suffix'"   == ""   local txtsuffix "_asc"
if "`suffix'"   == ""   local dtasuffix = "_v`version'"
local pwd = c(pwd)

display as text _n "{hline 71}"                                    ///
	_n " Directory: `pwd'"                                         ///
	_n "{hline 71}"                                                ///
	_n "{col 6}Source files{col 41}Result files, ASCII compatible" ///
	_n "{hline 36}{col 40}{hline 32}"

// Expand file list
local NF = wordcount("`FILESPEC'")
local FILELIST ""
forvalues N = 1/`NF' {
	local F : word `N' of `FILESPEC'
	local FF : dir . files "`F'" , respectcase
	local FILELIST = `"`FILELIST' `FF'"'
}

foreach F14 of local FILELIST {            // Name of destination file (`F13')
	local L = strrpos("`F14'", ".")        // Position of last "."
	local F1 = substr("`F14'", 1, `L'-1)
	local F2 = substr("`F14'", `L', .)
		
	// .dta file
	if strlower("`F2'") == ".dta" { 
		local F13 = "`F1'`dtasuffix'`F2'"
		find_version "`F14'"
		local dtaversion = r(sv)
		if `r(sv)' == 0 {
			display as err "{col 6}`F14': Not a Stata dataset"
		}	
		else if `dtaversion'>=14 {
			quietly capture unicode analyze "`F14'" , redo
			if r(N_utf8) {
				transdta "`F14'" "`F13'" , encoding(`encoding') version(`version') `replace'
			}
			else { 
				quietly use "`F14'" , clear
				quietly saveold "`F13'" , version(`version') `replace'
			}
			display as res "v`dtaversion': `F14' {col 37}{hline 2}> `F13'"
		}
		else if `dtaversion'>`version' {
			quietly use "`F14'" , clear
			quietly saveold "`F13'" , version(`version') `replace'
			display as res "v`dtaversion': `F14' {col 37}{hline 2}> `F13'"
		}
		else display as res "v`dtaversion': `F14' {col 37} =  `F14'"
	}
	// text file
	else if strpos(".ado.do.mata.log.txt.csv.sthlp.class.dlg.idlg.ihlp.smcl.stbcal", strlower("`F2'")) { 
		local F13 = "`F1'`txtsuffix'`F2'"
		clear
		quietly capture unicode analyze "`F14'" , redo
		if r(N_utf8) {
			quietly capture unicode convertfile "`F14'" "`F13'" , dstencoding(`encoding') `replace'
			display as res "unc: `F14'{col 37}{hline 2}> `F13'"
		}
		else display as res "asc: `F14'{col 37} =  `F14'"
	}
}
display as text "{hline 71}"
display as text "{hline 2}> File translated; new result file name" ///
	"{col 49}= File not translated"
display as text "{hline 71}"
end

************************** Program find_version *****************************
program find_version , rclass
version 14
args F
quietly capture dtaversion "`F'"
local DV = r(version)
if _rc != 0 {
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

************************** Program transdta ****************************	
program transdta
version 14
syntax anything(name=FILELIST) , Encoding(string) Version(numlist) [nodata replace]

local F14 : word 1 of `FILELIST'
local F13 : word 2 of `FILELIST'
quietly use "`F14'" , clear

// keep track of sorted data
local SORTEDBY = ustrto("`:sortedby'" , "`encoding'" , 1)

// Convert variable names using clonevar taking care of notes
foreach V of varlist _all {
	local V1 = ustrto("`V'" , "`encoding'" , 1)
	if "`V1'" != "`V'" {
		clonevar `V1' =`V' 
		drop `V'
	}		
}

// notes             See help notes_  (note the trailing underscore)
notes _dir NOTES
if "`NOTES'" != "" {
	local NVARS = wordcount("`NOTES'")       // How many variables (and _dta) have notes?
	forvalues N = 1/`NVARS' {                // Which variables (and _dta) have notes?
		local VAR : word `N' of `NOTES'      // For each variable (and _dta) with notes:
		notes _count NNOTES : `VAR'          // How many notes for the variable (or _dta)?
		forvalues NNUM = 1/`NNOTES' {        // For each note:
			notes _fetch NOTE : `VAR' `NNUM' // fetch it and convert it.
			local NOTE2 = ustrto("`NOTE'" , "`encoding'" , 1)
			if "`NOTE2'" != "`NOTE'" {
				quietly notes replace `VAR' in `NNUM' : `NOTE2'
			}
		}
	}
}	
	
// Convert string variable values
if "`nodata'" == "" {
	quietly ds , has(type string)
	if "`r(varlist)'" != "" {
		foreach V of varlist `r(varlist)' {
			quietly replace `V' = ustrto(`V' , "`encoding'" , 1)
		}
	}
}

// Languages. Data labels and variable lables.
quietly label language
local NL = r(k)                  // Number of languages
local LANGUAGES = r(languages)
forvalues L=1/`NL' {
	local LANGUAGE : word `L' of `LANGUAGES'
	quietly label language `LANGUAGE'

	// Convert data label
	local DATALAB : data label
	if "`DATALAB'" != "" {
		local DATALAB = ustrto("`DATALAB'" , "`encoding'" , 1)
		label data "`DATALAB'"
	}
	
	// Convert variable labels
	foreach V of varlist _all {
		local VARLAB : variable label `V'
		if "`VARLAB'" != "" {
			local VARLAB = ustrto("`VARLAB'" , "`encoding'" , 1)
			label variable `V' "`VARLAB'"
		}
	}
}

// Convert value label contents
quietly : label dir
local VALLABS = r(names)
if "`VALLABS'" != "" {
	tempfile LAB14_DO LAB13_DO
	quietly label save using `LAB14_DO'
	quietly unicode convertfile `LAB14_DO' `LAB13_DO' , dstencoding(`encoding')
	run `LAB13_DO'
}

// Convert value label names
foreach VALLAB in `VALLABS' {
	local VALLAB1 = ustrto("`VALLAB'" , "`encoding'" , 1)
	forvalues L=1/`NL' {
		local LANGUAGE : word `L' of `LANGUAGES'
		quietly label language `LANGUAGE'
		if "`VALLAB1'" != "`VALLAB'" {
			foreach V of varlist _all {
				if "`:value label `V''" == "`VALLAB'"  label values `V' `VALLAB1'
			}
		}
	}
}

if "`SORTEDBY'" != ""  sort `SORTEDBY'

quietly saveold "`F13'" , version(`version') `replace'
end
