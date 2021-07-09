/*-------------------------------------------------------------------------------
  statacmds.ado: get list of all commands known to Stata, including (Stata/Mata/egen) functions and built-ins

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
*! statacmds.ado: get list of all commands known to Stata, including (Stata/Mata/egen) functions and built-ins
*! Daniel Bela (daniel.bela@lifbi.de), Leibniz Institute for Educational Trajectories (LIfBi), Germany
*! version 1.0 20 September 2018 - initial release
program statacmds , rclass
	version 13
	if (_caller()>=14) local u u
	// check if filesearch.ado is present, abort if not
	capture : which filesearch.ado
	if (_rc!=0) {
		display as error in smcl `"{phang}{cmd:statacmds} requires {cmd:filesearch}, available on SSC.{break}To continue, install via {stata ssc install filesearch}.{p_end}"'
		exit 601
	}
	// parse syntax, initialize macros
	syntax [ , noBuiltins noFunctions noMatafunctions noEgenfunctions noADOcommands noUSERfiles noPLUSfiles noPERSONALfiles noOLDPLACEfiles noBASEfiles noSITEfiles ADOPATH noABBreviations noALIASfiles SAVing(string) unclassified replace Verbose ]
	// check paths to search in
	if (`"`adopath'"'==`"adopath"') local searchpaths `"`c(adopath)'"'
	else local searchpaths `"`"BASE"';`"SITE"';`"PLUS"';`"PERSONAL"';`"OLDPLACE"'"'
	if (`"`userfiles'"'==`"nouserfiles"') {
		local personalfiles nopersonalfiles
		local plusfiles noplusfiles
		local oldplacefiles nooldplacefiles
	}
	foreach keyword in "BASE" "SITE" "PLUS" "PERSONAL" "OLDPLACE" {
		local macroname=`u'strlower(`"`keyword'"')+"files"
		if (`"``macroname''"'==`"no`macroname'"') {
			local searchpaths: subinstr local searchpaths "`keyword'" "" , all
		}
	}
	while (`u'strpos(`"`searchpaths'"',`"`""'"')>0) {
		local searchpaths : subinstr local searchpaths `"`""'"' "" , all
	}
	while (`u'strpos(`"`searchpaths'"',`";;"')>0) {
		local searchpaths : subinstr local searchpaths `";;"' ";" , all
	}
	if (`u'substr(`"`searchpaths'"',1,1)==";") local searchpaths=`u'substr(`"`searchpaths'"',2,.)
	if (`u'substr(`"`searchpaths'"',-1,1)==";") local searchpaths=`u'substr(`"`searchpaths'"',1,`u'strlen(`"`searchpaths'"')-1)
	mata : _translate_adopath("searchpaths","searchpaths_semicolon",`"`searchpaths'"')
	// check results that should be returned
	foreach returntype in "builtins" "adocommands" "functions" "matafunctions" "egenfunctions" {
		if (missing(`"``returntype''"')) local returntypes `returntypes' `returntype'
	}
	if (!missing(`"`unclassified'"')) local returntypes `returntypes' unclassifieds
	if (missing(`u'strtrim(`"`returntypes'"'))) {
		display as error in smcl `"{phang}at least one of the options {opt builtins}, {opt adocommands}, {opt functions}, {opt matafunctions}, {opt egenfunctions}, or {opt unclassified} has to be specified.{p_end}"'
		exit 198
	}
	local return_abbreviations=(`"`abbreviations'"'!=`"noabbreviations"')
	if (`"`adocommands'"'!=`"noadocommands"' | `"`egencommands'"'!=`"noegencommands"') {
		local extensionregex "\.((st)?hlp)|(mata)|(ado)$"
	}
	else local extensionregex "\.((st)?hlp)|(mata)$"
	// check outputfile, if option saving() is specified
	if (!missing(`"`saving'"')) {
		local 0 : copy local saving
		syntax anything(name=filename id="file name") [ , replace nocategory SEParator(string) ]
		if (missing(`"`separator'"')) local separator `" "'
		capture : confirm new file `"`filename'"'
		if (_rc!=0) {
			if (`"`replace'"'!=`"replace"') error _rc
			else rm `"`filename'"'
		}
		local filewrite_categories=(`"`category'"'!=`"nocategory"')
		if (`filewrite_categories'==1) local filewrite_separator : copy local separator
	}
	else local filewrite_categories 0
	// tempstuff
	tempname aliashandle
	tempfile cleansed_aliasfile
	// get file lists of ado-files, help-files, and help-alias-files from search directories
	foreach searchpath of local searchpaths {
		if (`"`verbose'"'=="verbose") display as result in smcl `"{text}searching files in directory {result}`searchpath'{text}..."'
		mata : _isdirectory(`"`searchpath'"',`"isdirectory"')
		if (`isdirectory'==0) {
			if (`"`verbose'"'=="verbose") display as result in smcl `"{text}{tab}...directory is non-existent or inaccessible , skipped"'
			continue
		}
		// search for help, ado and mata files
		filesearch `extensionregex' , directory(`"`searchpath'"') recursive local(foundfiles) quiet regexpression
		local resultcount : word count `foundfiles'
		if (`resultcount'>0) {
			if (`"`verbose'"'=="verbose") display as result in smcl `"{text}{tab}...found {result}`resultcount'{text} help, ado or mata files"'
			mata : _classify_match(`"`foundfiles'"',`"`searchpath'"',`"`searchpaths_semicolon'"', `return_abbreviations', `"`returntypes'"', `"`filename'"', `filewrite_categories', `"`macval(filewrite_separator)'"')
		}
		// search for help-alias-files
		if (`"`aliasfiles'"'!=`"noaliasfiles"') {
			filesearch *help_alias.maint , directory(`"`searchpath'"') recursive local(foundfiles) quiet fullpath
			local resultcount : word count `foundfiles'
			if (`resultcount'>0) {
				if (`"`verbose'"'=="verbose") display as result in smcl `"{text}{tab}...found {result}`resultcount'{text} alias files"'
				local aliasfiles : list aliasfiles | foundfiles
			}
		}
	}
	// parse help-alias-files (if any)
	if (`"`aliasfiles'"'!=`"noaliasfiles"') {
		foreach aliasfile of local aliasfiles {
			if (`"`verbose'"'=="verbose") display as result in smcl `"{text}parsing help-alias file {result}`aliasfile'{text}..."'
			mata: _dir_from_path(`"`aliasfile'"',`"dirname"')
			quietly : filefilter `"`aliasfile'"' `"`cleansed_aliasfile'"' , from(\t) to(" ") replace // I have no other clue about how to tokenize on these nasty tab-characters
			file open `aliashandle' using `"`cleansed_aliasfile'"' , read text
			file read `aliashandle' line
			while (r(eof)==0) {
				gettoken aliasname command : line
				local aliasname `aliasname'.alias
				local command `command'.alias
				local aliaslist : list aliaslist | aliasname
				local aliaslist : list aliaslist | command
				file read `aliashandle' line
			}
			file close `aliashandle'
		}
		if (`"`verbose'"'=="verbose") display as result in smcl `"{text}{tab}...found {result}`:word count `aliaslist''{text} aliases in total"'
		mata : _classify_match(`"`aliaslist'"',`"`dirname'"',`"`searchpaths_semicolon'"', `return_abbreviations', `"`returntypes'"', `"`filename'"', `filewrite_categories', `"`macval(filewrite_separator)'"')
	}
	// return results
	foreach returntype of local returntypes {
		local `returntype'count : word count ``returntype''
		local wordcounts `wordcounts' ``returntype'count'
		if (`"`returntype'"'=="unclassifieds") {
			local title "unclassified entries"
			local returnname unclassified
		}
		else local returnname : copy local returntype
		if (`"`returntype'"'=="builtins") local title "Stata built-in commands"
		if (`"`returntype'"'=="adocommands") local title "Stata ADO commands"
		if (`"`returntype'"'=="functions") local title "Stata functions"
		if (`"`returntype'"'=="matafunctions") local title "Mata functions"
		if (`"`returntype'"'=="egenfunctions") local title "{cmd:egen} functions"
		local coltitles `"`coltitles' "`title'""'
		if (``returntype'count'>0) return local `returnname' `"``returntype''"'
	}
	_resultstable "{col 2}search results:" , col1title("result type") col2title("word count") col1contents(`coltitles') col2contents(`wordcounts')
	// exit
	exit 0
end
program define _resultstable , nclass
	* version compatibility: unicode functions for 14 or younger
	if (_caller()<14) {
		local length strlen
	}
	else {
		local length ustrlen
	}
	syntax anything(name=title id="table heading") , col1title(string) col2title(string) col1contents(string asis) col2contents(string asis) [ col1offset(integer 4) ] [ col2offset(integer 4) ] [ tableoffset(integer 4) ]
	* remove surrounding quotes from title, if any
	local title `title'
	* prepare widht parameters
	local col1width=`length'(`"`col1title'"')
	local col2width=`length'(`"`col2title'"')
	local col1_rows 0
	local col2_rows 0
	* read contents to calculate widths
	forvalues num=1/2 {
		foreach contentrow of local col`num'contents {
			local col`num'_row`++col`num'_rows' `contentrow'
			local col`num'width=max(`length'(`"`contentrow'"'),`col`num'width')
		}
	}
	local totalrows=max(`col1_rows',`col2_rows')
	* present table
	display as result in smcl _newline `"{text}`title'"'
	display as result in smcl _newline `"{p2colset `tableoffset' `=`col1width'+`col1offset'+`tableoffset'' `=`col1width'+`col1offset'+`col2offset'' `=c(linesize)-(`col1width'+`col2width'+`col1offset'+`col2offset')'}{p2col :`col1title'}`col2title'{p_end}"'
	display as result in smcl `"{p2line}"'
	forvalues num=1/`totalrows' {
		display as result in smcl `"{text}{p2col :`col1_row`num''}{result}`col2_row`num''{p_end}"'
	}
	display as result in smcl _newline _continue
	exit 0
end
set matastrict on
mata :
	void function _isdirectory(string scalar path, string scalar lclname) {
		st_local(lclname,strofreal(direxists(path)))
	}
	void function _dir_from_path(string scalar filepath, string scalar lclname) {
		string scalar filename
		pathsplit(filepath,directory,filename)
		st_local(lclname,directory)
	}
	void function _classify_match(string scalar filepaths, string scalar basedirectory, string scalar searchpaths, real scalar abbreviations, string scalar returntypes, string scalar writefilename, real scalar writecategories, string scalar categoryseparator) {
		string scalar basename , extension, filename, subdirectory, directory, adocheckname, filepath, findfile_searchpath
		real scalar counter, filehandle, catstring
		string colvector filepathvector
		string rowvector builtins, adocommands, functions, matafunctions, egenfunctions, unclassifieds, returntypevector
		returntypevector=tokens(returntypes)
		if (writefilename!="") {
			filehandle=_fopen(writefilename,"a")
		}
		if (length(st_local("builtins"))>0 & rowsum(returntypevector:=="builtins")==1) {
			builtins=tokens(st_local("builtins"))
		}
		if (length(st_local("adocommands"))>0 & rowsum(returntypevector:=="adocommands")==1) {
			adocommands=tokens(st_local("adocommands"))
		}
		if (length(st_local("functions"))>0 & rowsum(returntypevector:=="functions")==1) {
			functions=tokens(st_local("functions"))
		}
		if (length(st_local("matafunctions"))>0 & rowsum(returntypevector:=="matafunctions")==1) {
			matafunctions=tokens(st_local("matafunctions"))
		}
		if (length(st_local("egenfunctions"))>0 & rowsum(returntypevector:=="egenfunctions")==1) {
			egenfunctions=tokens(st_local("egenfunctions"))
		}
		if (length(st_local("unclassifieds"))>0 & rowsum(returntypevector:=="unclassifieds")==1) {
			unclassifieds=tokens(st_local("unclassifieds"))
		}
		// loop over filepaths elements
		filepathvector=tokens(filepaths)
		for (counter=1; counter<=cols(filepathvector); counter++) {
			filepath=filepathvector[counter]
			adocheckname=J(0,0,"")
			// extract extension
			extension=pathsuffix(filepath)
			// extract subdirectory relative to base directory
			pathsplit(filepath,subdirectory,filename)
			// generate full directory
			directory=pathjoin(basedirectory,subdirectory)
			// extract basename without suffix
			basename=pathbasename(pathrmsuffix(filepath))
			// classify category
			if (extension==".mata") {
				matafunctions=_add_to(matafunctions,"matafunction",basename,returntypevector,abbreviations,filehandle,writecategories,categoryseparator)
				continue
			}
			else if (regexmfunc(basename,`"^(((m)?f)|(mata))_"') & extension!=".ado") {
				// non-ado files starting with "f_" or "mf_" or "mata_" ...
				if (fileexists(directory+st_global("c_dirsep")+basename+".ado")==1) {
					// ... accompanied by an ado file with the same name
					adocommands=_add_to(adocommands,"adocommand",basename,returntypevector,abbreviations,filehandle,writecategories,categoryseparator)
					continue
				}
				else {
					// ... without an ado file with the same name
					if (substrfunc(basename,1,7)=="f_egen_") {
						basename=substrfunc(basename,8,.)
						egenfunctions=_add_to(egenfunctions,"egenfunction",basename,returntypevector,1,filehandle,writecategories,categoryseparator)
						continue
					}
					else if (substrfunc(basename,1,5)=="f_m5_" | substrfunc(basename,1,5)=="f_m4_" | substrfunc(basename,1,5)=="f_m3_") {
						basename=substrfunc(basename,6,.)
						matafunctions=_add_to(matafunctions,"matafunction",basename,returntypevector,1,filehandle,writecategories,categoryseparator)
						continue
					}
					else if (substrfunc(basename,1,3)=="mf_" | substrfunc(basename,1,5)=="mata_") {
						basename=substrfunc(basename,strposfunc(basename,"_")+1,.)
						matafunctions=_add_to(matafunctions,"matafunction",basename,returntypevector,1,filehandle,writecategories,categoryseparator)
						continue
					}
					else if (substrfunc(basename,1,2)=="f_") {
						basename=substrfunc(basename,strposfunc(basename,"_")+1,.)
						functions=_add_to(functions,"function",basename,returntypevector,1,filehandle,writecategories,categoryseparator)
						continue
					}
					else {
						unclassifieds=_add_to(unclassifieds,"unclassified",basename,returntypevector,0,filehandle,writecategories,categoryseparator)
					}
				}
			}
			else if (regexmfunc(basename,`"^_g"') & extension==".ado") {
				// ado files starting with "_g" ...
				if (fileexists(pathjoin(directory,basename+".hlp"))==1 | fileexists(pathjoin(directory,basename+".sthlp"))==1) {
					// ... accompanied by a help file with the same name
					adocommands=_add_to(adocommands,"adocommand",basename,returntypevector,1,filehandle,writecategories,categoryseparator)
					continue
				}
				else {
					// ... without a help file with the same name
					if (regexmfunc(basename,`"^_g((sem)|(s)|(r)|(get))_"')) {
						// ... but matching one of the patterns "_gsem_*", "_gs_*",  "_gr_*", or "_get*" (these seem to be helper commands to gsem, graph, and some estimation commands)
						adocommands=_add_to(adocommands,"adocommand",basename,returntypevector,abbreviations,filehandle,writecategories,categoryseparator)
						continue
					}
					else {
						// ... finally, these should be "real" egen functions
						basename=substrfunc(basename,3,.)
						egenfunctions=_add_to(egenfunctions,"egenfunction",basename,returntypevector,1,filehandle,writecategories,categoryseparator)
						continue
					}
				}
			}
			else {
				// all the rest
				if (_stata(`"unabcmd "'+basename,1)!=0) {
					// not a command
					unclassifieds=_add_to(unclassifieds,"unclassified",basename,returntypevector,0,filehandle,writecategories,categoryseparator)
					continue
				}
				if (abbreviations==0) {
					// an abbreviation?
					if (basename!=st_global("r(cmd)")) continue
				}
				adocheckname=st_global("r(cmd)")
				if (extension==".ado") {
					adocommands=_add_to(adocommands,"adocommand",basename,returntypevector,1,filehandle,writecategories,categoryseparator)
					continue
				}
				if (extension==".hlp" | extension==".sthlp") {
					findfile_searchpath=directory
				}
				else {
					// search path for alias
					findfile_searchpath=searchpaths
				}
				if (findfile(adocheckname+".ado",findfile_searchpath)!="") {
					// it's an ado
					adocommands=_add_to(adocommands,"adocommand",basename,returntypevector,1,filehandle,writecategories,categoryseparator)
					continue
				}
				else {
					// it's probably a built-in
					builtins=_add_to(builtins,"builtin",basename,returntypevector,1,filehandle,writecategories,categoryseparator)
					continue
				}
			}
			unclassifieds=_add_to(unclassifieds,"unclassified",basename,returntypevector,0,filehandle,writecategories,categoryseparator)		
		}
		// return lists to caller
		if (length(builtins)>0) st_local("builtins",invtokens(builtins))
		if (length(adocommands)>0) st_local("adocommands",invtokens(adocommands))
		if (length(functions)>0) st_local("functions",invtokens(functions))
		if (length(matafunctions)>0) st_local("matafunctions",invtokens(matafunctions))
		if (length(egenfunctions)>0) st_local("egenfunctions",invtokens(egenfunctions))
		if (length(unclassifieds)>0) st_local("unclassifieds",invtokens(unclassifieds))
		// close output file
		if (writefilename!="") {
			fclose(filehandle)
		}
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
	// provide substr-function that is robust regardless of callers' unicode support (for Stata 13 or older)
	string matrix function substrfunc(string matrix source, real matrix start, real matrix length) {
		if (stataversion()>=1400) return(unicode_substrfunc(source, start, length))
		else return(substr(source, start, length))
	}
	string matrix function unicode_substrfunc(string matrix source, real matrix start, real matrix length) {
		return(usubstr(source, start, length))
	}
	// provide strpos-function that is robust regardless of callers' unicode support (for Stata 13 or older)
	real matrix function strposfunc(string matrix text, string matrix char) {
		if (stataversion()>=1400) return(unicode_strposfunc(text, char))
		else return(strpos(text, char))
	}
	real matrix function unicode_strposfunc(string matrix text, string matrix char) {
		return(ustrpos(text, char))
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
	// function to translate a specied adopath to a list of directories
	void function _translate_adopath(string scalar lclname, string scalar semiclclname, string scalar dirlist) {
		string rowvector dirvector
		string scalar filesearch_call
		real scalar counter
		dirvector=tokens(dirlist,";")
		dirvector=pathsubsysdir(uniqrows(select(dirvector,dirvector:!=";")')')
		st_local(lclname,invtokens(J(1,cols(dirvector),`"""')+dirvector+J(1,cols(dirvector),`"""')))
		st_local(semiclclname,invtokens(J(1,cols(dirvector),`"""')+dirvector+J(1,cols(dirvector),`"""'),";"))
	}
	// function for adding result to vector
	string rowvector function _add_to(string rowvector list, string scalar listname, string scalar entry, string rowvector returntypevector, real scalar ignore_abbreviations, real scalar filehandle, real scalar writecategories, string scalar separator) {
		if (rowsum(returntypevector:==listname+"s")==0) return(list)
		if (rowsum(list:==entry)==1) return(list)
		// check if it's an abbreviation, ignore if applicable
		if (ignore_abbreviations==1 & (listname=="adocommands" | listname=="builtins")) {
			stata(`"unabcmd "'+entry,1)
			if (entry!=st_global("r(cmd)")) return(list)
		}
		// output to file, if requested
		if (filehandle!=J(1,1,.)) {
			fput(filehandle,entry+(writecategories ? separator+listname : ""))
		}
		// return result list
		return((list,entry))
	}
end
// EOF
