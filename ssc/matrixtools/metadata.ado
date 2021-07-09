*! Part of package matrixtools v. 0.24
*! Support: Niels Henrik Bruun, nhbr@ph.au.dk
/*
2017-08-31 >	When the dataset changed it is saved 
2017-07-21 >	Bug in metadata regarding value labels fixed
*/
* TODO: Filters such as max filesize
* TODO: Undgå at ikke gemte tilføjelser slettes med metadata
program define metadata
	version 12.1
	syntax [anything(name=vlst)] [using/], ///
			[SAvein(string) Keep noLog SEarchsubdirs noQuietly ///
			Style(string) Caption(string) TOp(string) Undertop(string) Bottom(string)]

	local QUIETLY "quietly"
	if "`quietly'" != "" local QUIETLY ""
	if "`vlst'" == "" local vlst *

	`QUIETLY' {
		display "NoQuietly turned on"
		if "`keep'" == "" {
			if `c(changed)' {
				tempfile tmpdata
				save `tmpdata', replace
				local current_file = `"`tmpdata'"'
			}
			else local current_file = subinstr("$S_FN", "\", "/", .)
		}
		if `"`using'"' != "" {
			mata: __vd = metadata(`"`using'"', `"`vlst'"', `=`"`searchsubdirs'"' != ""')
			mata: __justify = ("-", "-", "", "-", "", "-", "-", "-", "-", "")
		}
		else {
			local current_file = subinstr("$S_FN", "\", "/", .)
			unab __vlst : `vlst'
			mata: __vd = nhb_msa_variable_description(`"`__vlst'"')
			mata: __justify = ("-", "", "-", "-", "-", "-", "")
		}
		clear
		mata: nhb_sae_addvars(strlower(__vd[1,.]), __vd[2..rows(__vd),.])
		compress
		destring, replace
		capture format %15.3f Filesize_kb
		label data "metadata search. See notes for command and pwd"
		notes: COMMAND: metadata `0'
		notes: PWD: `c(pwd)'
		if `"`savein'"' != "" quietly {
			local __replace 0
			if regexm(`"`savein'"', "^(.+) *, *replace *") {
				local __replace = 1
				local savein = regexs(1)
			}
			if regexm(`"`savein'"', ".*\.(dta|smcl|csv|htm|html|tex|latex|md) *$") local style = regexs(1)
			else {
				mata: _error("Suffix must be one of: dta, smcl, csv, htm, html, latex, tex or md")
			}
			if "`style'" == "dta" {
				if `__replace' capture rm `"`savein'"'
				save `"`savein'"', replace
			}
		}
		if `"`current_file'"' != "" & "`keep'" == "" use `"`current_file'"', clear
	}
	if "`log'" != "nolog" {
		if "`style'" != "dta" {
			mata: __vd = nhb_mt_mata_string_matrix_styled(__vd, `"`style'"', ///
							__justify, 1, ///
							`"`caption'"', `"`top'"', `"`undertop'"', ///
							`"`bottom'"', `"`savein'"', strtoreal(`"`__replace'"'))
		}
		else {
			mata: __vd = nhb_mt_mata_string_matrix_styled(__vd, "", ///
							__justify, 1, ///
							`"`caption'"', `"`top'"', `"`undertop'"', ///
							`"`bottom'"', "", 0)
		}
	}
end

mata:
	function metadata(	string scalar dirfilefilter,
						string scalar varfilter,
						real scalar search_subdirs
						)
	{
		real scalar r, R, rc
		string scalar dn, fn, fs
		string matrix dsets, vd, vd_tmp
		
		if ( direxists(dirfilefilter) ) {
			if ( search_subdirs ) {
				dsets = nhb_msa_oswalk(dirfilefilter, "", "*.dta")
			} else {
				dsets = dir(dirfilefilter, "files", "*.dta")
				dsets = J(rows(dsets), 1, dirfilefilter), dsets
			}
		} else {
			pathsplit(dirfilefilter, dn, fn)
			if (dn == "" ) dn = "."
			if ( !regexm(fn, ".dta$") ) fn = sprintf("%s.dta", fn)
			dsets = dn, fn
		}
		if ( rows(dsets) ) {
			dsets[.,1] = subinstr(dsets[.,1], "\", "/")
			dsets[.,1] = subinstr(dsets[.,1], "//", "/")
			vd = J(0, 12, "")
			for(r=1;r<=rows(dsets);r++) {
				fn = sprintf(`"%s/%s"', dsets[r,1], dsets[r,2])
				rc = _stata(sprintf(`"use "%s", clear"', fn))
				if ( !rc ) {
					st_local("__vlst", "")
					rc = _stata(sprintf(`"capture unab __vlst : %s"', varfilter))
					if ( st_local("__vlst") != "" ) {
						vd_tmp = nhb_msa_variable_description(st_local("__vlst"))
						rc = _stata("macro drop __vlst")
						R = rows(vd_tmp)
						fs = nhb_msa_file_size_kb(fn)
						vd = vd \ (J(R-1, 1, (dsets[r,.], fs)), vd_tmp[2..R, .])
					}
				}
			}
			vd = ("Dataset_path", "Dataset", "Filesize kb", vd_tmp[1,.]) \ vd
		} else {
			vd = ("Dataset_path", "Dataset", "Filesize kb", "Name", "Index", "Label", "Value Label Name", "Format", "Value Label Values", "n", "unique", "missing")
			vd = vd \ J(1, cols(vd), "Nothing found")
		}
		return(vd)
	}
end
