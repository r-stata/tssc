*! ascii2unicode 1.1; 4 February 2016
*! Translates Stata data and text files to Unicode if necessary.
*! Requires Stata 14.1 (28jan2016 update)
*! Authors: Svend Juul and Morten Frydenberg
program ascii2unicode
version 14.1
syntax anything(name=FILESPEC id="File list") ///
	[, Encoding(string) Suffix(string) Detail nodata replace ]
preserve
clear

if "`encoding'" == "" local encoding "$UnicodeEncoding"
if "`encoding'" == "" local encoding "Windows-1252"
quietly unicode encoding set "`encoding'"
local txtsuffix "`suffix'"
local dtasuffix "`suffix'"
if "`suffix'"   == ""   local txtsuffix "_asc"
if "`suffix'"   == ""   local dtasuffix = "_v`version'"
local pwd = c(pwd)

display as text _n "{hline 72}"                      ///
	_n "Directory: `pwd'"                            ///
	_n "{hline 72}"                                  ///
	_n "Source files"                                ///
	   "{col 40}Result files, Unicode compatible"    ///
	_n "{hline 35}{col 39}{hline 34}"

// Expand file list
local NF = wordcount("`FILESPEC'")
local FILELIST ""
forvalues N = 1/`NF' {
	local F : word `N' of `FILESPEC'
	local FF : dir . files "`F'" , respectcase
	local FILELIST = `"`FILELIST' `FF'"'
}

// Examine each file. Translate if needed.
foreach FA of local FILELIST { 
	asc2uni "`FA'" , pwd(`pwd') encoding(`encoding') `detail' `nodata' `replace'
}
display as text "{hline 72}"
display as text "{hline 2}> File translated; source file name change" ///
	"{col 50}= File not translated"
display as text "{hline 72}"
end
	
***************************** Program asc2uni ******************************	
program asc2uni
version 14
syntax anything(name=FA) , pwd(string) encoding(string) [ , detail nodata replace]
quietly cd "`pwd'"

local L = strrpos(`FA', ".")        // Position of last "."
local F1 = substr(`FA', 1, `L'-1)
local F2 = substr(`FA', `L', .)
	
// Check existence of file. Skip file if problems. 
capture confirm file `FA'
if _rc !=0 {
	display as err `"File `FA' in directory `pwd' does not exist"'
	exit
}
if !strpos(".dta.ado.do.mata.log.txt.csv.sthlp.class.dlg.idlg.ihlp.smcl.stbcal", ///
		strlower("`F2'")) exit
	
// Rename backup files, if any.
rename_bakfiles `FA'
quietly cd "`pwd'"

// Analysis, translation
if "`detail'" == ""   quietly capture unicode analyze `FA' , `nodata' redo
else  capture unicode analyze `FA' , `nodata' redo
if r(N_needed) {           // Translation needed
	local POSTF "_asc"
	if strlower("`F2'") == ".dta" {
		find_version `FA'
		if `r(sv)' == 0  display as err " Not a Stata dataset:  "`FA'
		else if "`r(sv)'" == "" exit
		else local POSTF = "_v`r(sv)'"
	}
	local FB = `"`F1'`POSTF'`F2'"'
	quietly copy `FA' "`FB'" , replace
	quietly capture unicode translate `FA' , `nodata'
	display as res "`FB'{col 36}{hline 2}> "`FA'
}
else display as res `FA'"{col 37}=  "`FA'
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
