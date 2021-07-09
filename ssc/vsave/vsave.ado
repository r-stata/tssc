*! version 2.1.0 17oct2016 daniel klein
program vsave
	version 11.2
	
	local release = trunc(c(stata_version))
	local _caller = trunc(_caller())
	
	if (`_caller' < 11) {
		vsave_error_version `release' 498
	}
	
	if (!replay()) {
		local 0 `"using `0'"'
	}
	
	capture noisily syntax [ using/ ] ///
	[ , Version(numlist max = 1 >= 11 <= `release') * ]
	
	if (_rc) {
		if (_rc == 125) {
			vsave_error_version `release' 198
		}
		exit _rc
	}
	
	if mi("`using'") {
		if mi(c(filename)) {
			display as error "invalid file specification"
			exit 198
		}
		local using "`c(filename)'"
	}
	
	if ("`version'" != "") {
		local version = trunc(`version')
	}
	else {
		local version `_caller'
	}
	
	if (`version' > 12) {
		vsave_rusure "`using'" `version' exit
		`exit'
	}
	
	if ((`version' < `release') & (`release' >= 13)) {
		local old old
		if (`release' > 13) {
			local asversion version(`version')
		}
	}
	
	if mi("`asversion'") {
		if ((`version' < 13) & (`release' > 11)) {
			local version 12
			local addtext ", which can be read by Stata 11 or 12"
		}
		display as text "(saving in Stata `version' format`addtext')"
	}
	
	capture noisily {
		save`old' "`using'" , `asversion' `options'
	}
	
	exit _rc
end

program vsave_error_version
	version 11.2
	
	args release rc
	
	display as error "version must be 11<={it:#}<=`release'"
	
	exit `rc'
end

program vsave_rusure
	version 13.1
	
	args using version exit
	
	local `version' 0
	local 14 118
	local 13 117
	
	mata : st_local("dta", pathsuffix(st_local("using")))
	if mi("`dta'") {
		local using "`using'.dta"
	}
	
	capture confirm file "`using'"
	if (_rc) {
		exit 0
	}
	
	nobreak {
		tempname r
		_return hold `r'
		quietly dtaversion "`using'"
		local previous = r(version)
		_return restore `r'
	}
	
	if (`previous' == ``version'') {
		exit 0
	}
	
	capture window stopbox rusure "`using'" ///
	"was last saved in a format other than Stata `version'." ///
	"Do you want to save it in Stata format `version' now?"
	
	if (_rc) {
		c_local `exit' exit 0
	}
	
	exit 0
end

exit

2.1.0	16oct2016	warning now if using format != version
					also warning is no longer an error
2.0.0	16oct2016	filename is optional
					new option -version()-
					pass thru any options to -save[old]-
					warning if filename format < version
1.0.1	14oct2016	double bug fix
1.0.0	14oct2016	initial draft sent to Michael Stepner
