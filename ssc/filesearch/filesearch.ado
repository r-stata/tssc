/*-------------------------------------------------------------------------------
  filesearch.ado: recursively list files matching to a pattern or regular expression

    Copyright (C) 2018  Daniel Bela (daniel.bela@lifbi.de)

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
*! filesearch.ado: recursively list files matching to a pattern or regular expression
*! Daniel Bela (daniel.bela@lifbi.de), Leibniz Institute for Educational Trajectories (LIfBi), Germany
*! version 1.0 20 September 2018 - initial release
program filesearch , rclass
	version 13
	// parse syntax
	syntax anything(everything equalok name=pattern id="pattern") [ , DIRectory(string) REGEXpression Recursive Maxdepth(numlist integer >-1 missingokay max=1) SUBDIRectories noQuote Local(name local) FULLpath strip quiet ]
	local pattern `macval(pattern)' // this strips surrounding double quotes , if any
	* if (missing(`"`directory'"')) local directory "."
	if (`"`subdirectories'"'=="subdirectories") local matchtype dirs
	else local matchtype files
	local return_quoted=(`"`quote'"'!=`"noquote"')
	local return_fullpath=(`"`fullpath'"'==`"fullpath"')
	local strip_regex=(`"`strip'"'==`"strip"')
	* make 'pattern' a regular expression, unless it is already
	if (missing(`"`regexpression'"')) {
		foreach escapechar in "\" "." "[" "]" "{" "}" "$" "^" {
			local pattern : subinstr local pattern "`escapechar'" "\\`escapechar'" , all
		}
		if (cond(_caller()<14,"u","")+substr(`"`pattern'"',1,1)!="*") local pattern `"^`macval(pattern)'"'
		if (cond(_caller()<14,"u","")+substr(`"`pattern'"',-1,1)!="*") local pattern `"`macval(pattern)'$"'
		local pattern : subinstr local pattern "*" ".*" , all
		local pattern : subinstr local pattern "?" "." , all
	}
	* maxdepth() implies recursive
	if (!missing(`"`maxdepth'"') & missing(`"`recursive'"')) local recursive recursive
	* recursive without maxdepth() implies maxdepth(.)
	if (`"`recursive'"'==`"recursive"') {
		if (missing(`"`maxdepth'"')) local maxdepth .
	}
	* neither recursive nor maxdepth implies maxdepth(0)
	else local maxdepth 0
	if (`"`strip'"'==`"strip"' & missing(`"`regexpression'"')) display as result in smcl `"{phang}{error}Warning: {text}using option {opt strip} is delicate without regular expression matching, as it most likely will lead to empty search results;"'_newline`"{break}{text}please consider formulating your match pattern as regular expression, and using option {opt regexpression} appropriately{p_end}"'
	// execute file search
	mata : _filesearch(`"resultlist"', `"`pattern'"', `"`directory'"', `"`matchtype'"', `"`directory'"', 0, `maxdepth', `return_quoted', `return_fullpath', `strip_regex')
	// return results
	if (!missing(`"`local'"')) {
		c_local `local' : copy local resultlist
		return add
	}
	else {
		if (`"`matchtype'"'==`"files"') return local filenames `"`macval(resultlist)'"'
		else return local dirnames `"`macval(resultlist)'"'
		return add
	}
	// print result
	if (missing(`"`quiet'"')) {
		foreach entry of local resultlist {
			display as result in smcl `"`entry'"'
		}
	}
	// exit
	exit 0
end
set matastrict on
mata :
	void function _filesearch(string scalar lclname, string scalar pattern, string scalar directory, string scalar matchtype, string scalar droppart, real scalar depth, real scalar maxdepth, real scalar quoted, real scalar fullpath, real scalar strip) {
		string colvector preliminary_results , matchcheck_results, matched_results , subdirs
		real scalar counter
		string scalar dirsep
		if (st_global("c(os)")=="Windows") dirsep="\"
		else dirsep=st_global("c(dirsep)")
		if (directory=="") {
			directory="."
		}
		else {
			if (substrfunc(directory,-1,1)=="\"|substrfunc(directory,-1,1)=="/") directory=substrfunc(directory,1,strlenfunc(directory)-1)
			if (direxists(directory)==0) {
				errprintf("%s%s%s\n","Invalid or inaccessible directory {it:",directory,"}, using working directory instead")
				directory="."
			}
		}
		if (depth==0 & fullpath==0) droppart=directory
		// get file list
		preliminary_results=dir(directory, matchtype, "*", 1)
		if (length(preliminary_results)>0) {
			matchcheck_results=subinstrfunc(preliminary_results,subinstrfunc(preliminary_results[1],pathbasename(preliminary_results[1]),"",1),"",1)
			// remove non-matches from preliminary result
			if (fullpath==0) preliminary_results=subinstrfunc(preliminary_results,droppart+dirsep,"",1)
			if (colsum(regexmfunc(matchcheck_results,pattern,0))>0) {
				if (strip==1) matched_results=regexrfunc(select(preliminary_results,regexmfunc(matchcheck_results,pattern,0)), pattern, "", 0)
				else matched_results=select(preliminary_results,regexmfunc(matchcheck_results,pattern,0))
			}
		}
		// return results
		if (length(matched_results)>0) {
			// add previous entries to list, if any
			if (length(st_local(lclname))>0) {
				matched_results=tokens(st_local(lclname))'\matched_results
			}
			// add quotes if requested
			if (quoted==1) {
				matched_results=J(rows(matched_results),1,`"""')+matched_results+J(rows(matched_results),1,`"""')
			}
			// return local to caller
			st_local(lclname,invtokens(matched_results'))
		}
		// recurse to subdirectories, repeat
		if (maxdepth>depth) {
			subdirs=dir(directory,"dirs","*", 1)
			for (counter=1; counter<=rows(subdirs); counter++) {
				_filesearch(lclname,pattern,subdirs[counter],matchtype,droppart,depth+1,maxdepth,quoted,fullpath,strip)
			}
		}
	}
	// provide subinstr-function that is robust regardless of callers' unicode support (for Stata 13 or older)
	string matrix function subinstrfunc(string matrix orig, string matrix from, string matrix to, |real scalar count) {
		if (args()<4) count=.
		if (stataversion()>=1400) return(unicode_subinstrfunc(orig, from, to , count))
		else return(subinstr(orig, from, to , count))
	}
	string matrix function unicode_subinstrfunc(string matrix orig, string matrix from, string matrix to, real scalar count) {
		return(usubinstr(orig, from, to , count))
	}
	// provide substr-function that is robust regardless of callers' unicode support (for Stata 13 or older)
	string matrix function substrfunc(string matrix source, real matrix start, real matrix length) {
		if (stataversion()>=1400) return(unicode_substrfunc(source, start, length))
		else return(substr(source, start, length))
	}
	string matrix function unicode_substrfunc(string matrix source, real matrix start, real matrix length) {
		return(usubstr(source, start, length))
	}
	// provide strlen-function that is robust regardless of callers' unicode support (for Stata 13 or older)
	real matrix function strlenfunc(string matrix source) {
		if (stataversion()>=1400) return(unicode_strlenfunc(source))
		else return(strlen(source))
	}
	real matrix function unicode_strlenfunc(string matrix source) {
		return(ustrlen(source))
	}
	// provide regexm-function that is robust, regardless of callers' unicode support (for Stata 13 or older)
	real matrix function regexmfunc(string matrix source, string matrix regex, |real scalar casing) {
		if (args()<3) casing=0
		if (stataversion()>=1400) return(unicode_regexmfunc(source, regex, casing))
		else return(regexm(source, regex))
	}
	real matrix function unicode_regexmfunc(string matrix source, string matrix regex, real scalar casing) {
		return(ustrregexm(source, regex, casing))
	}
	// provide regexr-function that is robust, regardless of callers' unicode support (for Stata 13 or older)
	string matrix function regexrfunc(string matrix source, string matrix regex, string matrix to, |real scalar casing) {
		if (args()<4) casing=0
		if (stataversion()>=1400) return(unicode_regexrfunc(source, regex, to, casing))
		else return(regexr(source, regex, to))
	}
	string matrix function unicode_regexrfunc(string matrix source, string matrix regex, string matrix to, real scalar casing) {
		return(ustrregexra(source, regex, to, casing))
	}
end
// EOF
