/*-------------------------------------------------------------------------------
  zippkg.ado: Stata module to create ZIP archives of community-contributed content for offline distribution

    Copyright (C) 2019  Daniel Bela (daniel.bela@lifbi.de)

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
*! zippkg.ado: Stata module to create ZIP archives of community-contributed content for offline distribution
*! Daniel Bela (daniel.bela@lifbi.de), Leibniz Institute for Educational Trajectories (LIfBi), Germany
*! version 1.0 26 March 2019 - initialized development version release
program define zippkg , nclass
	// version requirements (and string functions dependent on Stata version)
	version 12
	if (_caller()<14) {
		local substr_fcn substr
		local strpos_fcn strpos
		local word_fcn word
		local strlower_fcn strlower
		local strtrim_fcn strtrim
	}
	else {
		local substr_fcn usubstr
		local strpos_fcn ustrpos
		local word_fcn ustrword
		local strlower_fcn ustrlower
		local strtrim_fcn ustrtrim
	}
	// convert input syntax from ||-separator notation to ()-binding notation
	local pipepos=`strpos_fcn'(`"`macval(0)'"',`"||"')
	if (`pipepos'!=0) {
		local zero : copy local 0
		local 0
		while (`pipepos'!=0) {
			local before=`substr_fcn'(`"`macval(zero)'"',1,`pipepos'-1)
			local zero=`substr_fcn'(`"`macval(zero)'"',`pipepos'+2,.)
			local pipepos=`strpos_fcn'(`"`macval(zero)'"',`"||"')
			local nextpart=cond(`substr_fcn'(`word_fcn'(`"`macval(before)'"',1),1,1)==`","',`"`macval(before)'"',`"(`macval(before)')"')
			local 0 `macval(0)' `macval(nextpart)'
			if (`pipepos'==0) {
				local nextpart=cond(`substr_fcn'(`word_fcn'(`"`macval(zero)'"',1),1,1)==`","',`"`macval(zero)'"',`"(`macval(zero)')"')
				local 0 `macval(0)' `macval(nextpart)'
			}
		}
	}
	// parse syntax
	syntax anything(everything equalok id="package specification" name=pkgspecs) ///
		[ , FLat single SAVing(string asis) replace Verbose noTRACKfile From(string) all CHECKSUMs ]
	// list of possible global options
	local global_opts flat saving replace verbose trackfile from all checksums
	// list of possible pkgspec options
	local pkgspec_opts flat saving replace trackfile from all
	// list of possible pkgspec options that have to be applied per saved archive file
	local targetarchive_opts flat replace trackfile
	if (`"`verbose'"'==`"verbose"') display as result in smcl `"{text}parsing global options..."'
	// parse global options, set defaults
	foreach global_opt of local global_opts {
		if (!missing(`"``global_opt''"')) {
			local glob_`global_opt' ``global_opt''
			if (`"`verbose'"'==`"verbose"') {
				if (inlist(`"`global_opt'"',`"saving"',`"from"')) display as result in smcl `"{tab}{text}...detected global option {result:`global_opt'(``global_opt'')}"'
				else display as result in smcl `"{tab}{text}...detected global option {result:`global_opt'}"'
			}
		}
	}
	if (missing(`"`glob_saving'"')) local glob_saving `"./zippkg.zip"'
	if (!missing(`"`single'"')) local glob_saving ./zippkg\`speccounter'.zip
	if (missing(`"`glob_from'"')) local glob_from `"ssc"'
	// parse pkgspecs
	local speccounter 0
	local targetarchivecounter 0
	if (`strpos_fcn'(`"`macval(pkgspecs)'"',`"("')==0) local pkgspecs (`macval(pkgspecs)')
	while (!missing(`"`macval(pkgspecs)'"')) {
		gettoken pkgspec`++speccounter' pkgspecs : pkgspecs , match(parens) bind quotes
		if (`"`verbose'"'==`"verbose"') display as result in smcl `"{text}parsing {it:pkgspec} {result:`speccounter'}..."'
		local 0 `pkgspec`speccounter''
		// concatenate options
		syntax namelist(min=1 name=pkgspec`speccounter'_pkglist id="package list") [ , FLat SAVing(string asis) replace noTRACKfile From(string) all ]
		if (`"`verbose'"'==`"verbose"') display as result in smcl `"{tab}{text}...list of packages to download is {result:`pkgspec`speccounter'_pkglist'}"'
		local pkgspec`speccounter'_installopts
		foreach pkgspec_opt of local pkgspec_opts {
			if (missing(`"``pkgspec_opt''"')) local pkgspec`speccounter'_`pkgspec_opt' : copy local glob_`pkgspec_opt'
			else {
				local pkgspec`speccounter'_`pkgspec_opt' : copy local `pkgspec_opt'
				if (`"`verbose'"'==`"verbose"') {
					if (inlist(`"`pkgspec_opt'"',`"saving"',`"from"')) display as result in smcl `"{tab}{text}...detected {it:pkgspec} option {result:`pkgspec_opt'(``pkgspec_opt'')}"'
					else display as result in smcl `"{tab}{text}...detected {it:pkgspec} option {result:`pkgspec_opt'}"'
				}
			}
		}
		if (`strlower_fcn'(`"`macval(pkgspec`speccounter'_from)'"')==`"ssc"') local pkgspec`speccounter'_installcmd ssc install
		else {
			local pkgspec`speccounter'_installcmd net install
			local pkgspec`speccounter'_installopts `macval(pkgspec`speccounter'_installopts)' from(`macval(pkgspec`speccounter'_from)')
		}
		if (!missing(`"`macval(pkgspec`speccounter'_all)'"')) local pkgspec`speccounter'_installopts `macval(pkgspec`speccounter'_installopts)' `macval(pkgspec`speccounter'_all)'
		if (!missing(`strtrim_fcn'(`"`macval(pkgspec`speccounter'_installopts)'"'))) local pkgspec`speccounter'_installopts `", `macval(pkgspec`speccounter'_installopts)'"'
		// determine target ZIP archive name
		if (`: list pkgspec`speccounter'_saving in targetarchives'==1) {
			local targetnum: list posof `"`pkgspec`speccounter'_saving'"' in targetarchives
			local targetarchive`targetnum'_pkgspecs : list targetarchive`targetnum'_pkgspecs | speccounter
		}
		else {
			local targetarchives : list targetarchives | pkgspec`speccounter'_saving
			local targetarchive`++targetarchivecounter'_pkgspecs `speccounter'
			foreach targetarchive_opt of local targetarchive_opts {
				if (!missing(`"`macval(targetarchive`targetarchivecounter'_`targetarchive_opt')'"')) {
					if (`"`macval(targetarchive`targetarchivecounter'_`targetarchive_opt')'"'!=`"`macval(pkgspec`speccounter'_`targetarchive_opt')'"') display as error `"option clash for archiving {input:`pkgspec`speccounter'_saving'}; will use {input:`pkgspec`speccounter'_`targetarchive_opt''}"'
				}
				else local targetarchive`targetarchivecounter'_zipopts `macval(targetarchive`targetarchivecounter'_zipopts)' `macval(pkgspec`speccounter'_`targetarchive_opt')'
			}
		}
	}
	// create archives
	if (`"`checksums'"'==`"checksums"') {
		local oldchecksumval `c(checksum)'
		if (`"`oldchecksumval'"'!=`"on"') set checksum on
	}
	forvalues num=1/`targetarchivecounter' {
		// target name
		local savename : word `num' of `targetarchives'
		if (`"`verbose'"'==`"verbose"') display as result in smcl `"{text}downloading material to be included in {result:`savename'}..."'
		// create temporary directory
		_create_tempsubdir `"`c(tmpdir)'"'
		local tmppath `s(tempdirfullpath)'
		if (`"`verbose'"'==`"verbose"') display as result in smcl `"{tab}{text}...created temporary directory {result:`tmppath'}"'
		// download stuff
		foreach specnum of local targetarchive`num'_pkgspecs {
			if (`"`verbose'"'==`"verbose"') display as result in smcl `"{tab}{text}...downloading package`=cond(`: word count `pkgspec`specnum'_pkglist''>1,`"s"',`""')' {result:`pkgspec`specnum'_pkglist'} (via {input:`pkgspec`specnum'_installcmd'} {it:pkg}{input:`pkgname'`pkgspec`specnum'_installopts'})"'
			foreach pkgname of local pkgspec`specnum'_pkglist {
				net set ado `"`tmppath'"'
				if (`"`pkgspec`specnum'_all'"'==`"all"') net set other `"`tmppath'"'
				capture : `pkgspec`specnum'_installcmd' `pkgname'`pkgspec`specnum'_installopts'
				net set ado PLUS
				if (`"`pkgspec`specnum'_all'"'==`"all"') net set other
				if (_rc!=0) {
					display as error in smcl `"package download failed, package `pkgname' will not be included in ZIP archive {it:`savename'}!"'
					if (`"`verbose'"'==`"verbose"') display as error in smcl `"{tab}used syntax was: {input}`pkgspec`specnum'_installcmd' `pkgname'`pkgspec`specnum'_installopts'"'
				}
			}
		}
		// create archive
		capture : noisily _zipdir `"`tmppath'"' , saving(`"`savename'"') `targetarchive`targetarchivecounter'_zipopts' `verbose'
		if (_rc!=0) {
			display as error in smcl `"creating ZIP archive file {input:`savename'} failed!"'
			if (`"`verbose'"'==`"verbose"') display as error in smcl `"{tab}used syntax was: {input}_zipdir `"`tmppath'"' , saving(`"`savename'"') `targetarchive`targetarchivecounter'_zipopts' `verbose'"'
		}
		// clean up
		if (`"`verbose'"'==`"verbose"') display as result in smcl `"{tab}{text}...erasing temporary directory {result:`tmppath'}"'
		_rm_dircontents `"`tmppath'"'
		 rmdir `"`tmppath'"'
	}
	if (`"`checksums'"'==`"checksums"' & `"`oldchecksumval'"'!=`"on"') set checksum off
	// exit
	exit 0
end
/* subroutine: create ZIP archive from a complete directory, descending by one level */
program define _zipdir , nclass
	syntax anything(everything name=parentdir id="directory name") ,  ///
		saving(string) [ flat replace noTRACKFILE verbose ]
	local parentdir `parentdir'
	if (`"`flat'"'==`"flat"') local archivetargets flattargets
	else {
		local archivebase `"`parentdir'"'
		local archivetargets allfiles
	}
	local allfiles : dir "`parentdir'" files "*" , respectcase
	if (`"`trackfile'"'==`"notrackfile"') {
		local allfiles : subinstr local allfiles `""stata.trk""' "" , all word
	}
	local subdirs : dir "`parentdir'" dirs "*" , respectcase
	foreach subdir of local subdirs {
		local subdirfiles : dir "`parentdir'/`subdir'" files "*" , respectcase
		foreach file of local subdirfiles {
			local newfile `""`subdir'/`file'""'
			local allfiles : list allfiles | newfile
		}
	}
	if (`"`flat'"'==`"flat"') {
		_create_tempsubdir `"`c(tmpdir)'"'
		local archivebase `s(tempdirfullpath)'
		foreach file of local allfiles {
			mata : st_local("filename",pathbasename(`"`file'"'))
			quietly : copy `"`parentdir'/`file'"' `"`archivebase'/`filename'"'
			local flattargets `"`flattargets' `"`filename'"'"'
		}
	}
	local oldpwd `"`c(pwd)'"'
	quietly : cd `"`archivebase'"'
	if (`"`verbose'"'==`"verbose"') {
		display as result in smcl `"{text}creating archive {result}`saving'{text}"'
		local q noisily
	}
	else local q quietly
	local mode create
	if (!missing(`"`replace'"')) {
		capture : confirm file `"`saving'"'
		if (_rc==0) {
			quietly : rm `"`saving'"'
			local mode replace
		}
	}
	`q' zipfile ``archivetargets'' , saving(`"`saving'"')
	quietly : cd `"`oldpwd'"'
	display as result in smcl `"{text}archive {result}`saving'{text} `mode'd"'
	if (`"`flat'"'==`"flat"') {
		_rm_dircontents `"`archivebase'"'
		 rmdir `"`archivebase'"'
	}
	exit 0
end
/* subroutine: remove all files from a directory, descending by one level */
program define _rm_dircontents , nclass
	syntax anything(everything name=dirname id="directory name")
	local dirname `dirname'
	local subdirs : dir "`dirname'" dirs "*" , respectcase
	foreach subdir of local subdirs {
		local subdirfiles : dir "`dirname'/`subdir'" files "*" , respectcase
		foreach file of local subdirfiles {
			rm `"`dirname'/`subdir'/`file'"'
		}
		rmdir `"`dirname'/`subdir'"'
	}
	local dirfiles : dir "`dirname'" files "*" , respectcase
	foreach file of local dirfiles {
		rm `"`dirname'/`file'"'
	}
	exit 0
end
/* subroutine: create a temporary subdirectory not yet existent */
program define _create_tempsubdir , sclass
	syntax anything(everything name=parent id="parent directory")
	local parent `parent'
	local counter 0
	tempname subdirname
	capture : mkdir `"`parent'/`subdirname'"'
	while (_rc!=0) {
		if (`++counter'>1000) {
			display as error in smcl `"Error: could not create random subdirectory inside of {it:`parent'} in 1000 tries. Is the parent directory corretly specified?"'
			exit 693
		}
		tempname subdirname
		capture : mkdir `"`parent'/`subdirname'"'
	}
	sreturn local tempdirname `"`subdirname'"'
	sreturn local tempdirfullpath `"`parent'/`subdirname'"'
	exit 0
end
// EOF
