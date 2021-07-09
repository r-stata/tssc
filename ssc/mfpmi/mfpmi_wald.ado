*! version 1.1.0  09apr2015
program define mfpmi_wald, eclass 
	local VV : di "version " string(_caller()) ", missing:"
	version 10
	vercheck mfpmi_wald_10 1.0.0
	vercheck mim 2.1.8
	local cmdline : copy local 0
	mata: _parse_colon("hascolon", "rhscmd")	// _parse_colon() is stored in _parse_colon.mo
	if (`hascolon') {
	        `VV' newmfp `"`0'"' `"`rhscmd'"'
	}
	else {
	        `VV' mfpmi_wald_10 `0'
	}
	// ereturn cmdline overwrites e(cmdline) from mfp_10
	ereturn local cmdline `"mfp `cmdline'"'
end

program define newmfp
	local VV : di "version " string(_caller()) ", missing:"
	version 10
	args 0 statacmd

	// Extract mfp options
	syntax, [*]
	local mfpopts `options'

/*
	It is important that the mfpoptions precede the Stata command options.
	To ensure this, must extract the Stata options and reconstruct the command
	before presenting it to mfpmi_wald_10.
*/
	local 0 `statacmd'
	syntax [anything] [if] [in] [aw fw pw iw], [*]
	if `"`weight'"' != "" local wgt [`weight'`exp']
	local options `options' hascolon
	`VV' mfpmi_wald_10 `anything' `if' `in' `wgt', mfpopts(`mfpopts') `options'
end

*! version 1.0.0 IRW/PR 17dec2010.
program define vercheck, sclass
version 9.2
local progname `1'
local vermin `2'
local not_fatal `3'
// If arg `not_fatal' is set to anything, program exits without an error.
if missing("`not_fatal'") local exitcode 498
tempname fh
qui findfile `progname'.ado
local filename `r(fn)'
file open `fh' using `"`filename'"', read
local stop 0
while `stop'==0 {
	file read `fh' line
	if r(eof) continue, break
	tokenize `"`line'"'
	if "`1'" != "*!" continue, break
	while "`1'" != "" {
		mac shift
		if inlist("`1'","version","ver","v") {
			local vernum `2'
			local stop 1
			continue, break
		}
	}
	if "`vernum'"!="" continue, break
}

sreturn local version `vernum'

if "`vermin'" != "" {
	if "`vernum'"=="" local match nover
	else {
		local vermin2 = subinstr("`vermin'","."," ",.)
		local vernum2 = subinstr("`vernum'","."," ",.)
		local words = max(wordcount("`vermin2'"),wordcount("`vernum2'"))
		local match equal
		forvalues i=1/`words' {
			if word("`vermin2'",`i') == word("`vernum2'",`i') continue
			if word("`vermin2'",`i') > word("`vernum2'",`i') local match old
			if word("`vermin2'",`i') < word("`vernum2'",`i') local match new
			continue, break
		}
	}
	if "`match'"=="old" {
		di as error `"`filename' is version `vernum' which is older than target `vermin'"'
		exit `exitcode'
	}
	if "`match'"=="nover" {
		di as error `"`filename' has no version number found"'
		exit `exitcode'
	}
	if "`match'"=="new" {
		di `"`filename' is version `vernum' which is newer than target `vermin'"'
	}
/*
	if "`match'"=="equal" {
		di `"`filename' is version `vernum' which equals target `vermin'"'
	}
*/
}
else {
	if "`vernum'"!="" di as text `"`filename' is version `vernum'"'
	else di as text `"`filename' has no version number found"'
}
		
end
