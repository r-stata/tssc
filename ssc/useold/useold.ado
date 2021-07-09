/*-------------------------------------------------------------------------------
  useold.ado: a convenient wrapper for -unicode translate- when used under Stata 14 or younger

    Copyright (C) 2015-2016  Daniel Bela (daniel.bela@lifbi.de)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

-------------------------------------------------------------------------------*/
*! useold.ado: a convenient wrapper for -unicode translate- when used under Stata 14 or younger
*! Daniel Bela (daniel.bela@lifbi.de), Leibniz Institute for Educational Trajectories (LIfBi), Germany
*! version 1.2 11 July 2016 - bugfix: "use ... using"-style syntax did not work properly for converted files (thanks to a bug report by D. Angerer!)
*! version 1.1 30 July 2015 - bugfix: be robust against opening a data file without explicitly specifying file extension '.dta'; dynamically handle assumed source encoding
*! version 1.0 21 July 2015 - initial release
program define useold , rclass
	version 11.2
	// preserve working directory
	local currdir `c(pwd)'
	// if calling Stata's version is below 14: pass on to -use-, everything's fine
	if (`c(stata_version)'<14) {
		use `0'
		exit 0
	}
	// parse syntax
	syntax [anything(everything)] [, clear NOLabel ENCoding(string) Verbose]
	// encoding to assume convert-files to be encoded in, if not specified: windows-1252 (Windows machines), macroman (Mac machines), ISO-8859-1 (Unix machines)
	if (missing(`"`encoding'"')) {
		if (!missing(`"${USEOLD_encoding}"')) local encoding ${USEOLD_encoding}
		else {
			if (`"`c(os)'"'=="Windows") local encoding windows-1252
			else if (`"`c(os)'"'=="MacOSX") local encoding macroman
			else if (`"`c(os)'"'=="Unix") local encoding ISO-8859-1
			else error 459
		}
	}
	// set local noisily to "noisily" , depending on option -verbose-
	if (`"`verbose'"'=="verbose") local noisily noisily
	// detect file name of file to use (careful: parse -use X Y Z using ...-!)
	local usingword using
	if (`: list usingword in anything'==1) {
		local usingwordposition: list posof "`usingword'" in anything
		// -use X Y Z using- is specified: target file name is expected one word after "using"
		local fullname : word `=`usingwordposition'+1' of `anything'
		// emergency fall back, part 1: someone specified a trailing "," (without spacing!) at the end of an (unquoted) file name
		if (regexm(`"`fullname'"',"^(.*),$")) {
			local fullname=regexs(1)
		}
		// emergency fall back, part 2: someone specified ",clear" (without spacing!) at the end of an unquoted file name
		if (regexm(`"`fullname'"',"^(.*),clear$")) {
			local fullname=regexs(1)
		}
		// emergency fall back, part 3: someone specified ",nolabel" (without spacing!) at the end of an unquoted file name
		if (regexm(`"`fullname'"',"^(.*),nol((a)|(ab)|(abe)|(abel))?$")) {
			local fullname=regexs(1)
		}
		// variable list X Y Z has to be extracted from all parameters: everything in -anything- _before_ "using"
		forvalues num=1/`=`usingwordposition'-1' {
			local varname : word `num' of `anything'
			local usevarlist : list usevarlist | varname
		}
	}
	else {
		// simple "use" is specified, target file name is everything before the first comma
		gettoken fullname rest : anything , parse(",")
	}
	// add file extension ".dta", if not explicitly specified
	capture : confirm file `"`fullname'"'
	if (_rc!=0) {
		if (reverse(usubstr(reverse(`"`fullname'"'),1,4))!=".dta") local fullname `fullname'.dta
		confirm file `"`fullname'"'
	}
	// return name of target file
	return local filename `"`fullname'"'
	// copy file to temporary file
	tempname targetfile
	tempfile `targetfile'
	quietly : copy `"`fullname'"' `"``targetfile''"'
	// determine separated directory and file name of ``targetfile''
	local delimpos=ulength(`"``targetfile''"')-ustrpos(reverse(usubinstr(`"``targetfile''"',`"\"',`"`c(dirsep)'"',.)),`"`c(dirsep)'"')+1
	local path=usubstr(`"``targetfile''"',1,`delimpos'-1)
	local file=usubstr(`"``targetfile''"',`delimpos'+1,.)
	if (missing(`"`path'"')) local path .
	// unicode analyze --> check if unicode translation is necessary
	`clear'
	quietly : cd `"`path'"'
	// before beginning: erase leftover unicode translate's backup files (from temporary directory, don't worry), if present
	local olddir : dir "." dirs "bak.stunicode" , respectcase nofail
	if (`"`olddir'"'==`"bak.stunicode"') quietly : unicode erasebackups , badidea
	// analyze
	capture : `noisily' unicode analyze `"`file'"' , redo
	if (_rc!=0) {
		quietly : cd `"`currdir'"'
		error _rc
	}
	// file does not need to be converted: pass on to -use-, everything's fine
	if (`r(N_needed)'==0) {
		capture : unicode erasebackups , badidea
		quietly : cd `"`currdir'"'
		use `anything' , `clear' `nolabel'
		exit 0
	}
	// file needs to be converted: -unicode set- and -unicode translate-
	capture : `noisily' unicode encoding set `encoding'
	if (_rc!=0) {
		quietly : cd `"`currdir'"'
		error _rc
	}
	capture : `noisily' unicode translate `"`file'"'
	if (_rc!=0) {
		quietly : cd `"`currdir'"'
		error _rc
	}
	// erase unicode translate's backup files (from temporary directory, don't worry)
	quietly : unicode erasebackups , badidea
	// open converted file
	if (missing(`"`usevarlist'"')) use `"`path'`c(dirsep)'`file'"' , `clear' `nolabel'
	else use `usevarlist' using `"`path'`c(dirsep)'`file'"' , `clear' `nolabel'
	quietly : cd `"`currdir'"'
	noisily : display as error in smcl `"{bf:Warning:} file had to be converted to unicode:"' _newline(2) `"{col 5}{c -} {bf:{it:c(filename)} will not be adequate} because it refers to a temporary file; use {it:r(filename)} instead!"' _newline `"{col 5}{c -} {bf:do not use} {cmd: save , replace} without a file name now!"' _newline
	// erase temporary file and exit
	erase `"`path'`c(dirsep)'`file'"'
	exit 0
end	
