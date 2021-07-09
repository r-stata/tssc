/*-------------------------------------------------------------------------------
  saveascii.ado: a convenient wrapper for -saveold-, incorporating translation of unicode characters to extended ASCII encodings

    Copyright (C) 2015-2017  Daniel Bela (daniel.bela@lifbi.de)

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
*! saveascii.ado: a convenient wrapper for -saveold-, incorporating translation of unicode characters to extended ASCII encodings
*! Daniel Bela (daniel.bela@lifbi.de), Leibniz Institute for Educational Trajectories (LIfBi), Germany
*! This program is incorporating ideas and concepts from Alan Riley (StataCorp), as presented on Statalist in
*! http://www.statalist.org/forums/forum/general-stata-discussion/general/1290766
*! version 1.3 15 March 2017 - major speedup by converting value labels in Mata; reset datasignature if previously set
*! version 1.2 14 February 2017 - bugfix: conversion did not work properly if variable labels, value labels or characteristics contained left single quotes (as in local macro delimiters) (thanks to bug report by K. Wenzig!)
*! version 1.1 11 July 2016 - bugfix: valuel label name conversion did not properly work for multi-lingual datasets; clash of valuel label names after conversion had not been detected (thanks to bug report by S. Juul!)
*! version 1.0.1 31 August 2015 - bugfix in handling characteristics containing double quotes, added option -nopreserve-
*! version 1.0 31 July 2015 - initial release
*! TODO: add routine that converts label language names
program define saveascii , nclass
	version 11.2
	// if calling Stata's version is below 14: pass on to -saveold-, everything's fine
	if (`c(stata_version)'<14) {
		saveold `0'
		exit 0
	}
	// parse syntax
	local 0 `"using `0'"'
	syntax using/ [, noLabel REPLACE ALL Version(passthru) noData ENCoding(string) Verbose noPreserve]
	// encoding to write target file in, if not specified: windows-1252 (Windows machines), macroman (Mac machines), ISO-8859-1 (Unix machines)
	if (missing(`"`encoding'"')) {
		if (!missing(`"${saveascii_encoding}"')) local encoding ${saveascii_encoding}
		else {
			if (`"`c(os)'"'=="Windows") local encoding windows-1252
			else if (`"`c(os)'"'=="MacOSX") local encoding macroman
			else if (`"`c(os)'"'=="Unix") local encoding ISO-8859-1
			else error 459
		}
	}
	// target encoding is Unicode: simply -saveold-
	if (strmatch(lower(`"`encoding'"'),"utf-*")|lower(`"`encoding'"')=="unicode") {
		saveold `"`using'"' , `nolabel' `replace' `all' `version'
		exit 0
	}
	// target version is 14 or newer: simply -saveold-
	if (!missing(`"`version'"')) {
		assert (regexm(`"`version'"',"^version\(([0-9]+\.?[0-9]*)\)$"))
		local versionnum=regexs(1)
		if (`versionnum'>=14) {
			saveold `"`using'"' , `nolabel' `replace' `all' `version'
			exit 0
		}
	}
	else local versionnum=trunc(`c(stata_version)')
	if (strmatch(lower(`"`encoding'"'),"utf-*")|lower(`"`encoding'"')=="unicode") {
		saveold `"`using'"' , `nolabel' `replace' `all' `version'
		exit 0
	}
	// check if targetfile is present, but option -replace- is not used (to save time)
	if (`"`replace'"'!=`"replace"') {
		capture : confirm file `"`using'"'
		if (_rc==0) {
			noisily : display as error in smcl `"file {it:`using'} already exists"'
			exit 602
		}
	}
	// preserve
	if (`"`preserve'"'!=`"nopreserve"') preserve
	// get variable list
	unab allvars : _all
	// convert data set labels, if any
	local datalab : data label
	if (!missing(`"`macval(datalab)'"')) {
		local newdatalab=ustrto(`"`macval(datalab)'"',`"`encoding'"',1)
		if (`"`macval(newdatalab)'"'!=`"`macval(datalab)'"') {
			if (`"`verbose'"'==`"verbose"') display as text in smcl `"...converting data label"'
			label data `"`macval(newdatalab)'"'
		}
	}
	// convert value label unicode contents and names, if any (and option -nolabel- is not specified)
	if (`"`label'"'!=`"nolabel"') {
		quietly : label dir
		foreach container in `r(names)' {
			// convert value label contents
			mata : mata_convertlbl(`"`macval(container)'"',`"`encoding'"')
			// convert value label names
			local newcontainer=ustrto(`"`macval(container)'"',`"`encoding'"',1)
			if (`"`macval(newcontainer)'"'!=`"`macval(container)'"') {
				if (`"`verbose'"'==`"verbose"') display as text in smcl `"...converting name of value label {it:`macval(container)'}"'
				* copy label, attach to variables, drop (old) label
				local newcontainername=ustrtoname(`"`macval(newcontainer)'"',1)
				* cross-check that the new label name is not already taken, append number to it if it is
				* (thanks to S. Juul's bug report!)
				local iterator 0
				capture : label list `macval(newcontainername)'
				while (_rc==0) {
					local newcontainername=ustrtoname(`"`macval(newcontainer)'"',1)+`"`++iterator'"'
					capture : label list `macval(newcontainername)'
				}
				label copy `macval(container)' `macval(newcontainername)'
				if (!missing(`"`affectedvars'"')) label values `affectedvars' `macval(newcontainername)'
				* check if this container also is associated to a variable in an inactive language; apply there
				quietly : label language
				if (`"`r(languages)'"'!=`"`r(language)'"') {
					foreach lang in `r(languages)' {
						if (`"`lang'"'==`"`r(language)'"') continue
						forach var of varlist _all {
							if (`"`: char `var'[_lang_l_`lang']'"'==`"`macval(container)'"') char define `var'[_lang_l_`lang'] `macval(newcontainername)'
						}
					}
				label drop `macval(container)'
			}
		}
	}
	// convert characteristics' unicode contents, if any
	foreach charholder in _dta `allvars' {
		local chars : char `macval(charholder)'[]
		foreach char of local chars {
			local charcontent : char `macval(charholder)'[`macval(char)']
			local newcharcontent=ustrto(`"`macval(charcontent)'"',`"`encoding'"',1)
			if (`"`macval(newcharcontent)'"'!=`"`macval(charcontent)'"') {
				if (`"`verbose'"'==`"verbose"') display as text in smcl `"...converting content of characteristic {it:`macval(charholder)'[`macval(char)']}"'
				char define `macval(charholder)'[`macval(char)'] `"`macval(newcharcontent)'"'
			}
			local newchar=ustrto(`"`macval(char)'"',`"`encoding'"',1)
			if (`"`macval(newchar)'"'!=`"`macval(char)'"') {
				if (`"`verbose'"'==`"verbose"') display as text in smcl `"...converting name of characteristic {it:`macval(charholder)'[`macval(char)']}"'
				char define `macval(charholder)'[`macval(newchar)'] `"`: char `macval(charholder)'[`macval(char)']'"'
				char define `macval(charholder)'[`macval(char)']
			}
		}
	}
	// variable-wise conversion
	foreach var of local allvars {
		// convert string variables' unicode content, if any; recast strL and str#>244, if target version is below 13
		if (regexm(`"`: type `var''"',"^str(.*)$")) {
			local strsubtype=regexs(1)
			if (`"`data'"'!=`"nodata"') {
				// convert string variables' unicode content
				quietly : count if (`macval(var)'!=ustrto(`macval(var)',`"`encoding'"',1) & !(_strisbinary(`macval(var)')))
				if (r(N)>0) {
					if (`"`verbose'"'==`"verbose"') display as text in smcl `"...converting string content of variable {it:`macval(var)'} for {it:`r(N)'} observation(s)"'
					quietly : replace `macval(var)'=ustrto(`macval(var)',`"`encoding'"',1) if !(_strisbinary(`macval(var)'))
				}
				// force-recast long strings to str244, if necessary
				if (`versionnum'<13) {
					if (!inrange(real(`"`strsubtype'"'),1,244)) {
						quietly : count if length(`macval(var)')>244
						if (r(N)==0) quietly : recast str244 `macval(var)'
						else {
							if (`"`verbose'"'==`"verbose"') display as text in smcl `"...variable {it:`macval(var)'} has {it:`r(N)'} observations longer than 244 characters; they will be truncated in order to save the data in Stata `versionnum' format"'
							quietly : recast str244 `macval(var)' , force
						}
					}
				}
			}
		}
		// convert unicode variable labels, if any
		local varlab : variable label `macval(var)'
		if (!missing(`"`macval(varlab)'"')) {
			local newvarlab=ustrto(`"`macval(varlab)'"',`"`encoding'"',1)
			if (`"`macval(newvarlab)'"'!=`"`macval(varlab)'"') {
				if (`"`verbose'"'==`"verbose"') display as text in smcl `"...converting variable label of variable {it:`var'}"'
				label variable `var' `"`macval(newvarlab)'"'
			}
		}
		// convert unicode variable names, if any
		if (`"`data'"'!=`"nodata"') {
			local newname=ustrto(`"`macval(var)'"',`"`encoding'"',1)
			if (`"`macval(newname)'"'!=`"`macval(var)'"') {
				local newname : permname `macval(newname)'
				if (`"`verbose'"'==`"verbose"') display as text in smcl `"...renaming variable {it:`macval(var)'} to {it:`macval(newname)'}"'
				rename `macval(var)' `macval(newname)'
			}
		}
	}
	// if -datasignature- has been set previously, -reset-
	capture : datasignature confirm
	if (_rc!=459) quietly : datasignature set , reset
	// finally, -saveold-
	saveold `"`using'"' , `nolabel' `replace' `all' `version'
	// restore
	if (`"`preserve'"'!=`"nopreserve"') restore
	// quit
	exit 0
end
mata:
	mata set matastrict on
	void mata_convertlbl(string scalar name, string scalar encoding)
	{
		string colvector oldtext
		numeric colvector values
		st_vlload(name,values,oldtext)
		st_vlmodify(name,values,ustrto(oldtext,encoding,1))
	}
end
// EOF
