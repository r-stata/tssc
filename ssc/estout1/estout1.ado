*! version 1.04, Ben Jann, 02dec2005

program define estout1
version 8.2

local allvalues "b se t p"

syntax [anything] [using] [ , EQuations(passthru) Keep(passthru) Drop(passthru) ///
 nob B2(string) se SE2(string) SEDrop(string) SEKeep(string)  ///
 t T2(string) abs TDrop(string) TKeep(string) ///
 p P2(string) PDrop(string) PKeep(string) ///
 star STAR2(string) starsym(string) starpos(string) DETACHstar ///
 Stats(string) STFmt(string) STLabels(string asis) STStar STStar2(string) ///
 eform Label CONSlbl(string) Wide noHead ///
 VARwidth(integer -1) MODELwidth(integer -1) ///
 PREHead(string asis) POSTHead(string asis) PREFoot(string asis) POSTFoot(string asis) ///
 BEGin(string) end(string) DELimiter(string) style(string) ///
 Replace Append noTYpe showtabs ]

local eform="`eform'"!=""
local wide="`wide'"!=""
local head="`head'"==""

*b-, se-, t-, p-Values, formats
if "`abs'"!=""&"`t'"==""&`"`t2'"'=="" local t t
foreach v of local allvalues {
	if "``v''"!=""&`"``v'2'"'!="" {
		di as error "`v'() and ``v'' may not be specified together"
		exit 198
	}
	if "`v'"=="b" {
		local b="`b'"==""
		local bfmt "%9.3f"
	}
	else local `v'=`"``v'2'"'!=""|"``v''"!=""|`"``v'keep'"'!=""
	if ``v'' {
		local temp: word count ``v'2'
		if `temp'>2 {
			di as error `"`v'(``v'2') not allowed"'
			exit 198
		}
		local `v'par 0
		tokenize `"``v'2'"'
		while `"`1'"'!="" {
			capt local temp: display `1' 1
			if _rc|index(`"`1'"',"%")!=1 {
				if substr("parentheses",1,length(`"`1'"'))==`"`1'"' local `v'par 1
				else {
					di as error `"`1' in `v'(``v'2') not allowed"'
					exit 198
				}
			}
			else local `v'fmt "`1'"
			mac shift
		}
		if "``v'fmt'"=="" local `v'fmt "`bfmt'"
	}
}

*Default format/labels/stars for overall statistics
local stats: list uniq stats
if "`stfmt'"=="" local stfmt "`bfmt'"
if `"`stlabels'"'=="" local stlabels `"`stats'"'
if `"`conslbl'"'=="" local conslbl "_cons"
if `"`ststar'"'!=""&`"`ststar2'"'!="" {
	di as error "ststar() and ststar may not be specified together"
	exit 198
}
else if `"`ststar'"'!="" {
	local ststar2: word 1 of `stats'
}
else if `"`ststar2'"'!="" {
	local stats: list stats | ststar2
}
if `"`ststar2'"'!="" {
	local ststarst "p df_m F chi2"
}

*Stars
if "`star2'"!=""&"`star'"!="" {
	di as error "star() and star may not be specified together"
	exit 198
}
if `"`starpos'"'!=""&!`:list starpos in allvalues' {
	di as error `"starpos(`starpos') not allowed"'
	exit 198
}
local star="`star'"!=""|`"`starsym'"'!=""|"`starpos'"!=""|"`star2'"!=""
if "`star2'"==""&(`star'|`"`ststar2'"'!="") {
	local nstar: word count `starsym'
	if `nstar'==0 local nstar 3
	if `nstar'>=1 local star2 "`star2'0.05 "
	if `nstar'>=2 local star2 "`star2'0.01 "
	if `nstar'>=3 local star2 "`star2'0.001"
	}
if `star'|`"`ststar2'"'!="" {
	local nstar: word count `star2'
	if `"`starsym'"'=="" {
		if `nstar'>=1 local starsym "*"
		if `nstar'>=2 local starsym "`starsym' **"
		if `nstar'>=3 local starsym "`starsym' ***"
		if `nstar'>3 {
			di as error "please specify starsym()"
			exit 198
		}
	}
	local temp: word count `starsym'
	if `temp'!=`nstar' {
		di as error "star() and starsym() do not match"
		exit 198
	}
	forv i=2/`nstar' {
		if (`:word `i' of `star2''>`:word `=`i'-1' of `star2'') | ///
		 (`:word `i' of `star2''<0) | (`:word `=`i'-1' of `star2''>1) {
			di as error "significance thresholds not in descending order or outside [0,1]"
			exit 198
		}
	}
}
foreach v of local allvalues {
	if ``v'' {
		local values "`values'`v'"
		if `star'&"`starpos'"=="" local starpos "`v'"
		}
	if "`starpos'"=="`v'" {
		if !``v'' {
			di as error "starpos(`v') not allowed unless `v' is secified"
			exit 198
		}
		local values "`values'star"
	}
	local values "`values' "
}
local values: list retok values
if `star'&"`values'"=="" {
	di as error "star not allowed in this context"
	exit 198
}

*begin of line, delimiter, end of line, Modelwidth/Varwidth
if `"`style'"'=="html" {
	if `"`begin'"'=="" local begin "<tr><td>"
	if `"`delimiter'"'=="" local delimiter "</td><td>"
	if `"`end'"'=="" local end "</td></tr>"
}
else if `"`style'"'=="tex" {
	if `"`delimiter'"'=="" local delimiter "&"
	if `"`end'"'=="" {
		local end "\\\\"
	}
}
else if `"`style'"'=="tab" {
	if `modelwidth'<0 local modelwidth 0
	if `varwidth'<0 local varwidth 0
}
else if `"`style'"'!="" {
	di as error `"style(`style') not allowed"'
	exit 198
}
if `"`begin'"'!="" {
	local begin `"`"`macval(begin)'"'"'
}
if `"`delimiter'"'!="" {
	local delimiter `"`"`macval(delimiter)'"'"'
}
if `"`end'"'!="" {
	local end `"`"`macval(end)'"'"'
}
if `modelwidth'<0 local modelwidth 12
if `varwidth'<0 local varwidth 12
if `"`style'"'=="tab" & `"`delimiter'"'=="" local delimiter _tab

if `modelwidth'>0 {
	local fmt_m "%`modelwidth's"
	if `star'|`"`ststar2'"'!="" {
		forv i=1/`nstar' {
			local istar: word `i' of `macval(starsym)'
			local temp2=max(length("`temp2'"),length(`"`macval(istar)'"'))
		}
		local fmt_star "%-`temp2's"
		local _skipstar "_skip(`temp2')"
	}
}
if (`star'|`"`ststar2'"'!="")&"`detachstar'"!="" {
	local _skipstar `"`macval(delimiter)' `_skipstar'"'
	local detachstar `"`macval(delimiter)'"'
}
else local detachstar
if `varwidth'>0 local fmt_v "%-`varwidth's"
if `wide' {
	local i 0
	foreach v of local values {
		if `++i'==1 continue
		local wdel `"`macval(wdel)'`macval(delimiter)' _skip(`modelwidth') "'
		if index("`v'","star") {
			local wdel `"`macval(wdel)'`macval(_skipstar)' "'
		}
	}
}

*Get coefficients/variances/statistics/varlist/keep/drop
qui estimates table `anything', stats(`stats' df_r `ststarst') `equations' `keep' `drop'
local models `r(names)'
local M: word count `models'
tempname B St df_r
mat `St'=r(stats)
mat `df_r'=`St'["df_r",1...]
if `"`ststar2'"'!="" {
	tempname st_p df_m F chi2 stp
	mat `st_p'=`St'["p",1...]
	mat `df_m'=`St'["df_m",1...]
	mat `F'=`St'["F",1...]
	mat `chi2'=`St'["chi2",1...]
}
mat `B'=r(coef)
local R=rowsof(`B')
local varlist: rownames `B'
local eqlist: roweq `B'
local eqs: list uniq eqlist
local eqs: word count `eqs'
local eqs=`eqs'>1
local fullvarlist: rowfullnames `B'
foreach v of local allvalues {
	if "`v'"=="b" continue
	if `"``v'keep'"'!="" {
		if `"``v'drop'"'!="" {
			di as error "`v'drop() not allowed if `v'keep() is specified"
			exit 198
		}
		Keep `B' `"``v'keep'"'
	}
	else if `"``v'drop'"'!="" {
		if !``v'' {
			di as error "`v'drop() not allowed unless `v' is specified"
			exit 198
		}
		Drop `B' `"``v'drop'"'
	}
	else local temp `"`fullvarlist'"'
	local `v'drop: list fullvarlist - temp
}

*Open temporary output file
tempfile tfile
tempname file
file open `file' using `"`tfile'"', write text

*Prehead
if `"`prehead'"'!="" {
	local L: word count `prehead'
	forv l=1/`L' {
		local temp: word `l' of `macval(prehead)'
		file write `file' `"`macval(temp)'"' _n
	}
}

*Head of table
if `head' {
	file write `file' `macval(begin)' _skip(`varwidth')
	forv m=1/`M' {
		local model: word `m' of `models'
		file write `file' `macval(delimiter)' `fmt_m' ("`model'")
		if !`wide'|index("`: word 1 of `values''","star")|"`ststar2'"!="" {
			file write `file' `macval(_skipstar)'
		}
		if `wide' {
			file write `file' `macval(wdel)'
		}
	}
	file write `file' `macval(end)' _n
	if `wide'&"`values'"!="" {
		file write `file' `macval(begin)' _skip(`varwidth')
		forv m=1/`M' {
			foreach v of local values {
				local istar=index("`v'","star")
				if `istar' local v=substr("`v'",1,`istar'-1)
				file write `file' `macval(delimiter)'
				file write `file' `fmt_m' ("`v'")
				if `istar'|("`v'"=="`: word 1 of `values''"&"`ststar2'"!="") {
					file write `file' `macval(_skipstar)'
				}
			}
		}
		file write `file' `macval(end)' _n
	}
}

*Posthead
if `"`posthead'"'!="" {
	local L: word count `posthead'
	forv l=1/`L' {
		local temp: word `l' of `macval(posthead)'
		file write `file' `"`macval(temp)'"' _n
	}
}

*Body of table: loop over table rows
if "`values'"!="" {
	forv r=1/`R' {

		*Equation names
		local eqvar: word `r' of `fullvarlist'
		if `eqs' {
			local eqrlast `"`eqr'"'
			local eqr: word `r' of `eqlist'
			if `"`eqr'"'!=`"`eqrlast'"' {
				file write `file' `macval(begin)' `"`eqr'"' `macval(end)' _n
			}
		}

*Variable names/labels
		local var: word `r' of `varlist'
		if "`label'"!="" {
			capture local varl: var l `var'
			if _rc|`"`varl'"'=="" {
				local varl `var'
			}
		}
		else local varl `var'
		if "`var'"=="_cons" {
			local varl `"`macval(conslbl)'"'
		}
		file write `file' `macval(begin)' `fmt_v' (`"`macval(varl)'"')

*Table cells
*if long, loop thru models within values: (modelloop 1) -> valueloop -> modelloop 2
*if wide, loop thru values within models:  modelloop 1 -> valueloop -> (modelloop 2)
		if `wide' local MM `M'
		else local MM 1
		forv mm=1/`MM' {
			if `wide' local MMM `mm'
			else local MMM `M'
			local newline 0
			foreach v of local values {
				local istar=index("`v'","star")
				if `istar' local v=substr("`v'",1,`istar'-1)
				if `: list eqvar in `v'drop'&!`wide' continue
				if !`wide'&`newline++' {
					file write `file' `"`macval(begin)'"' _skip(`varwidth')
				}
				forv m=`mm'/`MMM' {
					file write `file' `macval(_skipvw)' `macval(delimiter)'
					if `: list eqvar in `v'drop' {
						file write `file' _skip(`modelwidth')
					}
					else {
						`v'Value `B'[`r',`=`m'*2-1'] `B'[`r',`=`m'*2'] `df_r'[1,`m'] ///
						 ``v'fmt' ``v'par' `eform' `abs'
						file write `file' `fmt_m' ("`value'")
					}
					if `istar' {
						pValue `B'[`r',`=`m'*2-1'] `B'[`r',`=`m'*2'] `df_r'[1,`m'] %20.0g 0 0
						Stars `nstar' `"`star2'"' `"`macval(starsym)'"' `value'
						file write `file' `macval(detachstar)' `fmt_star' (`"`macval(value)'"')
					}
					else if !`wide'|("`v'"=="`: word 1 of `values''"&"`ststar2'"!="") {
						file write `file' `macval(_skipstar)'
					}
				}
				if !`wide' {
					file write `file' `macval(end)' _n
				}
			}
		}
		if `wide' {
			file write `file' `macval(end)' _n
		}
	}
}

*Prefoot
if `"`prefoot'"'!="" {
	local L: word count `prefoot'
	forv l=1/`L' {
		local temp: word `l' of `macval(prefoot)'
		file write `file' `"`macval(temp)'"' _n
	}
}

*Foot of table
local S: word count `stats'
forv r=1/`S' {
	local stat: word `r' of `macval(stlabels)'
	if `"`stat'"'=="" local stat: word `r' of `stats'
	file write `file' `macval(begin)' `fmt_v' (`"`macval(stat)'"')
	local format: word `r' of `stfmt'
	if "`format'"=="" local format: word 1 of `stfmt'
	local stat: word `r' of `stats'
	forv m=1/`M' {
		stValue `St'[`r',`m'] `format'
		file write `file' `macval(delimiter)' `fmt_m' ("`value'")
		if "`value'"!=""&`:list stat in ststar2' {
			stpValue `st_p'[1,`m'] `df_r'[1,`m'] `df_m'[1,`m'] `F'[1,`m'] `chi2'[1,`m']
			Stars `nstar' `"`star2'"' `"`macval(starsym)'"' `value'
			file write `file' `macval(detachstar)' `fmt_star' (`"`macval(value)'"')
		}
		else if !`wide'|index("`: word 1 of `values''","star")|"`ststar2'"!="" {
			file write `file' `macval(_skipstar)'
		}
		if `wide' {
			file write `file' `macval(wdel)'
		}
	}
	file write `file' `macval(end)' _n
}

*Postfoot
if `"`postfoot'"'!="" {
	local L: word count `postfoot'
	forv l=1/`L' {
		local temp: word `l' of `macval(postfoot)'
		file write `file' `"`macval(temp)'"' _n
	}
}

*Finish
file close `file'
if `"`using'"'!="" {
	tempname file2
	file open `file2' `using', write text `replace' `append'
	file open `file' using `"`tfile'"', read text
	file read `file' temp
	while r(eof)==0 {
		file write `file2' `"`macval(temp)'"' _n
		file read `file' temp
	}
	file close `file'
	file close `file2'
}
if "`type'"=="" type `"`tfile'"', asis `showtabs'

end

program bValue
	args b var df_r fmt par eform abs
	if `b'==0&`var'==0 local value "(dropped)"
	else if `var'!=.z {
		if `eform' local value: di `fmt' exp(`b')
		else local value: di `fmt' `b'
		local value: list retok value
		if `par' local value "(`value')"
	}
	c_local value `value'
end

program seValue
	args b var df_r fmt par eform abs
	if !(`b'==0&`var'==0)&`var'!=.z {
		if `var'==0 local value .
		else if `eform' local value: di `fmt' sqrt(`var')*exp(`b')
		else local value: di `fmt' sqrt(`var')
		local value: list retok value
		if `par' local value "(`value')"
	}
	c_local value `value'
end

program tValue
	args b var df_r fmt par eform abs
	if !(`b'==0&`var'==0)&`var'!=.z  {
		if `var'==0 local value .
		else local value: di `fmt' `abs'(`b'/sqrt(`var'))
		local value: list retok value
		if `par' local value "(`value')"
	}
	c_local value `value'
end

program pValue
	args b var df_r fmt par eform abs
	if !(`b'==0&`var'==0)&`var'!=.z {
		if `var'==0 local value .
		else if `df_r'<. local value: di `fmt' ttail(`df_r',abs(`b'/sqrt(`var')))*2
		else local value: di `fmt' (1-norm(abs(`b'/sqrt(`var'))))*2
		local value: list retok value
		if `par' local value "(`value')"
	}
	c_local value `value'
end

program stpValue
	args p df_r df_m F chi2
	if inrange(`p',0,1) {
		local value=`p'
	}
	else if `df_m'<.&`df_r'<.&`F'<. {
		local value=Ftail(`df_m',`df_r',`F')
	}
	else if `df_m'<.&`chi2'<. {
		local value=chi2tail(`df_m',`chi2')
	}
	c_local value `value'
end

program Stars
	args nstar star2 starsym P
	if "`P'"!="" {
		if `P'<. {
			local i `nstar'
			while `i'>0&`"`value'"'=="" {
				local istar: word `i' of `star2'
				local istarsym: word `i' of `macval(starsym)'
				if `P'<`istar' {
					local value "`macval(istarsym)'"
				}
				local i=`i'-1
			}
		}
	}
	c_local value `macval(value)'
end

program stValue
	args st fmt
	if `st'!=.z {
		local value: di `fmt' `st'
		local value: list retok value
	}
	c_local value `value'
end

program Keep   //stolen from est_table.ado
	args b spec
	tempname bt
	foreach sp of local spec {
		local row =  rownumb(`b', "`sp'")
		if `row' == . {
			dis as err "coefficient `sp' does not occur in any of the models"
			exit 198
		}
		if index("`sp'",":") > 0 {
			mat `bt' = nullmat(`bt') \ `b'["`sp'",1...]
		}
		else {
			mat `bt' = nullmat(`bt') \ `b'[`row',1...]
		}
	}
	c_local temp `"`: rowfullnames `bt''"'
end

program Drop   //stolen from est_table.ado
	args b spec
	tempname bt
	mat `bt' = `b'
	foreach sp of local spec {
		local isp = rownumb(`bt', "`sp'")
		if `isp' == . {
			dis as err "coefficient `sp' does not occur in any of the models"
			exit 198
		}
		while `isp' != . {
			local nb = rowsof(`bt')
			if `isp' == 1 {
				mat `bt' = `bt'[2...,1...]
			}
			else if `isp' == `nb' {
				mat `bt' = `bt'[1..`=`nb'-1',1...]
			}
			else {
				local im1 = `isp'-1
				local ip1 = `isp'+1
				mat `bt' = `bt'[1..`im1',1...] \ `bt'[`ip1'...,1...]
			}
			local isp = rownumb(`bt', "`sp'")
		}
	}
	c_local temp `"`: rowfullnames `bt''"'
end
