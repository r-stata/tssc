program define svytabs
version 7.0
*! version 4.0.1 by Michael Blasnik 3/11/2001
*! generates complex tables for publication using svytab
syntax varlist [if], [by(varname) MUlti VCol2(varlist) SUBpops(varlist) /*
  */ STars SAVing(str) APPend REPlace DETail noTItle CTitle(str) TEXT(str) /*
  */ ROW(int 2) CI SE LEVel(int $S_level) NRaw NPop CHKval FLagerr(int 0) /*
   */ deff ifchi(str) SCreen ]
quietly {
set more off
set linesize 200
svy_get strata
local strvar "`s(varname)'"
svy_get psu
local psuvar "`s(psu)'"
marksample touse, novarlist 
markout `touse' `strvar' `psuvar', strok
* check for global macros set for options
if "`npop'"=="" & "$tabnpop"=="1" {local npop "npop"}
if "`nraw'"=="" & "$tabnraw"=="1" {local nraw "nraw"}
tempname vPcnt vrawsum
if "`chkval'"=="" & "$tabchkv"=="1" {local chkval "chkval"}
if `flagerr'==0 & real("$tabflag")<. {local flagerr "$tabflag"}
if "`se'"=="" & "$tabse"=="1" {local se "se"}
if "`ci'"=="" & "$tabci"=="1" {local ci "ci"}
if "`deff'"=="" & "$tabdeff"=="1" {local deff "deff"}
if "`detail'"!="" | "$tabdet"=="1" {local noi "noisily"}
if "`ci'"!="" | `flagerr'>0 {local svyci "ci"}
local cilevel=`level'+(100-`level')/2
if "`screen'"=="" {
	local delim ","
	local nfmt "%6.1f"
	}
else {
	local delim " "
	local nfmt "%8.1f"
	local sfmt "%8s"	
}
* create fake byvar if none specified, tricks svytab into working
local fakeby=0
if "`by'"=="" {
	if "`stars'"!="" {
		di as error "stars option meaningless without by(var)"
		exit 198
	}
	tempvar dummy
	gen byte `dummy'=0
	local by "`dummy'"
	local fakeby=1
}
* get lengths of varlist(s) and check if OK
local v1cnt: word count `varlist'
local v2cnt: word count `vcol2'
if `v1cnt'!=`v2cnt' & "`vcol2'"!="" {
		di in red "Second varlist not same length as primary"
		exit 198
}
if "`multi'"!="" & (`v1cnt'>1 | `v2cnt'>0) {
	di in red "Can only specify 1 variable with multi option"
	exit 198
}
local col "col"
* set up logging of output
local fliplog = ("`detail'"!="") & ("`saving'"!="")
qui log
local logname "`r(filename)'"
local logon "`r(status)'"
if "`saving'"!="" {
	cap log close
	log using ${tabdir}`saving', `append' `replace' text
	set linesize 255
}
if "`detail'"!="" & "`logname'"=="" {
	di in red "Detail option is useless without a log file open"
	exit 198
}

* create title line of table
if "`title'"=="" & "`saving'"!="" {
	if substr(lower("`saving'"),1,5)=="table" {
		local title =substr("`saving'",1,5)+" "+substr("`saving'",6,.)
		local title "`title'. `text'"
	}
	else {local title "`saving'. `text'"}
}
if "`title'`saving'"=="" & "`text'"!="" {local title "`text'"}

if "`ctitle'"!="" {local head2 "`ctitle'"}

tempname v deffv erow ecol pct colsum
local spopN: word count `subpops'
local spopN=max(1,`spopN')
local bylab: value label `by'

* get variable and value labels
tokenize "`varlist'"
local c1wid=max(8,length("`ctitle'"))
local i=1
while "``i''"!="" {
	local vallb`i': value label ``i''
	local varlb`i': variable label ``i''
	if "`varlb`i''"=="" {local varlb`i' "``i''"}
	* get rid of commas from any labels to maintain comma parsing
	local varlb`i': subinstr local varlb`i' `","' `"-"' , all
	if "`ctitle'"=="" & "`multi'"!="" {
			local head2 "`varlb`i''"
			local c1wid=max(`c1wid',length("`varlb`i''"))	
	}
	local tablb`i' : char ``i''[tablab]
	if "`tablb`i''"=="" {local tablb`i' "``i''"}
	local c1wid=max(`c1wid',length("`tablb`i''"))
	local i=`i'+1
}
local c1wid=`c1wid'+1
if "`screen'"!="" {local scrn "%-`c1wid's "}
if "`multi'"!="" & "`screen'"!="" {
		local head2a "`head2'"
		local head2 ""
}
else {
	if "`head2'"=="" {local head2 " "}
	local head2 : di `scrn' "`head2'"
}
if `fakeby'==0 {local head1 : di `scrn' " "}
if "`npop'"!="" {local head3 : di `scrn' " "}
* go through varlist
local vl=1 /* keep track of which varlist if vcol2 is specified */
local i=1
local var: word `i' of `varlist'
while "`var'"!="" {
	if `vl'==1 & "`multi'"=="" {
			local disp: di `scrn' "`tablb`i''"
			local sedisp: di `scrn' " "
			local cidisp: di `scrn' " "
			local deffdi: di `scrn' " "
			local star
	}
	* go through subpops
	forvalues spopn =1/`spopN'{	
		local spop: word `spopn' of `subpops'
		if "`spop'"!="" {local subpop "subpop(`spop')"}
		cap local spopnm: char `spop'[tablab]
		if "`spopnm'"==""  {local spopnm "`spop'"}
		if "`screen'"!="" {local spopnm: di `sfmt' abbrev("`spopnm'",8)}
		* on first go within an spop, get col pop counts & make headers
		if `i'==1 { 
			tempname Pcnt Pcat
			if "`spop'"!="" {local ifspop " & `spop'<. "}
			tab `by' if `touse' `ifspop' , matcell(`Pcnt') matrow(`Pcat') `subpop'
			local pcats=rowsof(`Pcnt')
			forvalues k=1/`pcats' {
				local Pcol`k'=`Pcnt'[`k',1]
				local Pcat`k'=`Pcat'[`k',1]
				if "`bylab'"!="" {
					local Pcnam`k': label `bylab' `Pcat`k''
					}
				else {local Pcnam`k'=`Pcat`k''}
				local Pcnam`k': subinstr local Pcnam`k' `","' `"-"' , all
				if "`screen'"!="" {
					local Pcnam`k': di `sfmt' abbrev("`Pcnam`k''",8)
				}
				if !`fakeby' {local head2 "`head2'`delim'`Pcnam`k''"}
				if "`spop'"!="" {local head1 "`head1'`delim'`spopnm'"}
				if "`npop'"!="" {
					local npopd: di `sfmt' "(n=`Pcol`k'')"
					local head3 "`head3'`delim'`npopd'"
				}
			}
			if `pcats'<2 & `fakeby'==0 {local warn1 "Warning <2 columns detected"}
			local oldnrow=0
		}
		* now run the svytab command & log it as needed
		if `fliplog' {
			cap log close
			log using `logname' , append 
		}
		* if special condition for chi2 test, do it now and grab p
		if "`ifchi'"!=""{
			`noi' di "svytab `var' `by' if `touse' & `ifchi', `col' `subpop' "
			`noi' svytab `var' `by' if `touse' & `ifchi', `col' `subpop' 
			local pvar=e(p_Pear)
		}
		`noi' di "svytab `var' `by' if `touse', `col' `subpop' `svyci' `se' `deff'"
		`noi' svytab `var' `by' if `touse', `col' `subpop' `svyci' `se' `deff'
		if `fliplog' {
			log close
			log using ${dir}`saving', append text
		}
		* capture results of command
		local nrow=e(r)
		local ncol=e(c)
		mat `erow'=e(Row)
		mat `ecol'=e(Col)
		mat `pct'=e(Prop)
		local starlen=length("`star'")
		local star
		if "`ifchi'"=="" {local pvar=e(p_Pear)}
		mat `colsum'=J(1,`nrow',1)
		mat `colsum'=`colsum'*`pct' /* sum up column total proportions */
		if "`se'`svyci'"!="" {mat `v'=e(V)}
		if "`deff'"!="" {mat `deffv'=e(Deff)}
		local t=invttail(e(N_psu)-e(N_strata),`cilevel'/100)
		if `i'>1 & `nrow'!=`oldnrow' {local warn2 "Warning, inconsistent number of rows"}
		local oldnrow=`nrow'
		if `nrow'>(max(2,`row')) & "`multi'"=="" {local warn3 "`warn3' `var'"}

		* if chkval option, grab name of category for var of interest
		local rowval
		if "`chkval'"!="" & `spopn'==`spopN' & "`multi'"==""{
			local rowvl=`erow'[1,`row']
			cap local rowval: label `vallb`i'' `rowvl'
			if "`rowval'"=="" {local rowval "`rowvl'"}
			local rowval: subinstr local rowval `","' `"-"' , all
			local rowval "`delim'`rowval'"
		}

		*calc statistical significance and add asterisks as needed
		if "`stars'"!=""  {
			if `pvar'==. {local warn4 "`warn4'`var' "}
			else {local star=substr("**",1,(`pvar'<.05)+(`pvar'<.01))}
		}

		* if raw counts wanted, do tab to get them into matrix
		if "`nraw'"!="" {
			tab `var' `by' if `touse' `ifspop',`subpop' matcell(`vPcnt')
			mat `vrawsum'=J(1,`nrow',1)
			mat `vrawsum'=`vrawsum'*`vPcnt' 
		}
		* now loop through categories of byvar
		* j is counter for column of byvar in pop 
		local k=1 /* counter for column of byvar in results matrix */
		forvalues j=1/`pcats' {
			local kplus=(`ecol'[1,`k']==`Pcat`j'') /* don't increment if column missing */
			if "`multi'"=="" {
				cap local resval=`pct'[`row',`k']/(`colsum'[1,`k']*`kplus')
				local res=string(100*`resval',"`nfmt'")
				if "`res'"=="." {local res="--"}
				if "`screen'"!="" & `j'==1 { /* adjust screen display for asterisks */
					local rfmt=8-`starlen'
					local rfmt="%`rfmt's"
				}
				else {local rfmt "`sfmt'"}
				local res: di `rfmt' "`res'"
				local disp "`disp'`delim'`res'"

				* accumulate min & max counts by varlistcol,column,subpop
				if "`nraw'"!="" {
					if `resval'!=. {local Nraw=`vrawsum'[1,`k']}
					else {local Nraw=0}
					if `i'==1 {
						local r`vl'n`j's`spopn'=`Nraw'
						local r`vl'x`j's`spopn'=`Nraw'
					}
				local r`vl'n`j's`spopn'=min(`Nraw',`r`vl'n`j's`spopn'')
				local r`vl'x`j's`spopn'=max(`Nraw',`r`vl'x`j's`spopn'')
				}

				* get standard errors or confidence intervals as requested
				if "`se'`svyci'"!=""  {
					local elemnt=(`row'-1)*`ncol'+`k'
					secalc `v' `elemnt' `resval' `t' `flagerr' 
					if "`se'"!="" {local sedisp: di "`sedisp'`delim'" `sfmt' "`r(se)'"}
					if "`ci'"!="" {local cidisp: di "`cidisp'`delim'" `sfmt' "`r(ci)'"}
					if `r(cimax)'>`flagerr' & `flagerr'>0 {local disp "`disp'~"}
				}

				* get deff as requested
				if "`deff'"!="" {
					local elemnt=(`row'-1)*`ncol'+`k'
					local deffval=`deffv'[1,`elemnt']
					local deffval=string(`deffval',"%5.2f")
					local deffdi: di "`deffdi'`delim'" `sfmt' "{`deffval'}"
				}
			}

			else { /*else it's a multirow x-tab */				

				* get row labels of multicat var
				if `k'==1 & `spopn'==1 { 
					local labwid=`c1wid'
					forvalues r=1/`nrow' {
						local val=`erow'[1,`r']
						if "`vallb`i''"!=""{
							local rlab: label `vallb`i'' `val'
						}
						else {local rlab "`val'"}
						local rlab: subinstr local rlab `","' `"-"' , all
						local disp`r' "`rlab'"
						local labwid=max(`labwid',length("`rlab'"))
					}
					if "`screen'"!="" {
						local xspace=`labwid'-`c1wid'
						if `xspace'>0 {
							local head1: di _dup(`xspace') " "  "`head1'"
							local head3: di _dup(`xspace') " "  "`head3'"
						}
						local head2: di %-`labwid's "`head2a'" %1s "`head2'"
						forvalues r=1/`nrow' {
							local disp`r': di %-`labwid's "`disp`r''"
							local sedis`r': di %`labwid's " "
							local cidis`r': di %`labwid's " "
							local deffd`r': di %`labwid's " "

						}
					}    
				}

				forvalues r=1/`nrow' {
					cap local resval=`pct'[`r',`k']/(`colsum'[1,`k']*`kplus')
					local res=string(100*`resval',"`nfmt'")
					if "`res'"=="." {local res="--"}
					if "`screen'"!="" & `j'==1{
						local rfmt=8-`starlen'
						local rfmt="%`rfmt's"
					}
					else {local rfmt "`sfmt'"}
					local res: di `rfmt' "`res'"
					local disp`r' "`disp`r''`delim'`res'"

					* get std err or conf int as requested
					if "`se'`svyci'"!="" {
						local elemnt=(`r'-1)*`ncol'+`k'
						secalc `v' `elemnt' `resval' `t' `flagerr' 
						if "`se'"!="" {local sedis`r': di "`sedis`r''`delim'" `sfmt' "`r(se)'"}
						if "`ci'"!="" {local cidis`r': di "`cidis`r''`delim'" `sfmt' "`r(ci)'"}
						if `r(cimax)'>`flagerr' & `flagerr'>0  {local disp`r' "`disp`r''~"}
					}

					* get deff as requested
					if "`deff'"!="" {
						local elemnt=(`r'-1)*`ncol'+`k'
						local deffval=`deffv'[1,`elemnt']
						local deffval=string(`deffval',"%5.2f")
						local deffd`r': di "`deffd`r''`delim'" `sfmt' "{`deffval'}"
					}
				if `j'==`pcats' {local disp`r' "`disp`r''`star'"}
				}
			} /* done with else its a multirow xtab */

			local k=`k'+`kplus'
		}
		local disp "`disp'`star'"
	} /* go on to next subpop */

	* display header
	if `i'==1 & (`vl'==2 | (`vl'==1 & `v2cnt'==0)){
		if "`title'"!="notitle" {noi di as text "`title'"}
		if trim("`head1'")=="" & trim("`head2'")!="" {noi di as text "`head2'"}
		else {
			if `fakeby'==1 & trim("`head2'`head1'")!="" {noi di as text "`head2'`head1'"}
			else if trim("`head1'")!="" | trim("`head2'")!="" {noi di as text "`head1'" _newline "`head2'"}
		}
		if "`npop'"!="" {noi di as result "`head3'"}
	}
	* display results
	if "`multi'"=="" & (`vl'==2 | (`vl'==1 & `v2cnt'==0)) {
		noi di as result "`disp'`rowval'"
		if "`se'"!="" & "`sedisp'"!="" {noi di as result "`sedisp'"}
		if "`ci'"!="" & "`cidisp'"!="" {noi di as result "`cidisp'"}
		if "`deff'"!="" & "`deffdi'"!="" {noi di as result "`deffdi'"}
	}
	* increment to next var on list
	if `vl'==1 & `v2cnt'>0 {
		local var: word `i' of `vcol2'
		local vl=2
	}
	else {
		local vl=1
		local i=`i'+1
		local var: word `i' of `varlist'
	}
} /* go on to next variable */

* if its multicat, then display all results at end
if "`multi'"!="" {
	local r=1
	while "`disp`r''"!="" {
		noi di as result "`disp`r''"
		if "`se'"!="" & "`sedis`r''"!="" {noi di as result "`sedis`r''"}
		if "`ci'"!="" & "`cidis`r''"!="" {noi di as result "`cidis`r''"}
		if "`deff'"!="" & "`deffd`r''"!="" {noi di as result "`deffd`r''"}
		local r=`r'+1
	}
}

* display min & max counts by column
if "`nraw'"!="" {
	local rndisp: di `scrn' "Raw Counts"
	local ivl=1
	while `ivl'<=(2-(`v2cnt'==0)) {
		forvalues ispop=1/`spopN' {
			forvalues icol=1/`pcats' {
				local rndis: di `sfmt' "`r`ivl'n`icol's`ispop''..`r`ivl'x`icol's`ispop''"
				local rndisp "`rndisp'`delim'`rndis'"
			}
		}
		local ivl=`ivl'+1
	}
	noi di as result "`rndisp'"
}

* display notes and warnings
if "`se'"!="" {noi di as text "standard errors displayed in parentheses below values"}
if "`ci'"!="" {noi di as text "`level'% confidence intervals displayed in parentheses below values"}
if "`deff'"!="" {noi di as text "deff displayed in braces below values"}
if `flagerr'>0 {
noi di as text "values with more than `flagerr' percentage point uncertainty at `level'% confidence flagged with ~"
}
if "`stars'"!="" & `pvar'<. {
	if "`ifchi'"!="" {local ifchi " (`ifchi')"}
noi di as text "statistically signficant differences by `by'`ifchi' flagged: *=(p<.05) **=(p<.01)"
}

if "`warn1'"!="" {noi di as text "`saving': `warn1'"}
if "`warn2'"!="" {noi di as text "`saving': `warn2'"}
if "`warn3'"!="" {noi di as text "`saving': Warning, more than 2 levels detected for `warn3'"}
if "`warn4'"!="" {noi di as text "`saving': Warning: Chi-square could not be calculated for `warn4'"}

* clean up logs
if "`saving'"!="" {log close}
if "`logname'"!="" & "`saving'"!="" {
	log using `logname', append
	log `logon'
}

set more on
} /* end of quietly zone */
end 


program define secalc, rclass
version 7.0
args v elemnt resval t flagerr
local seval=sqrt(`v'[`elemnt',`elemnt'])
local sevald=string(100*`seval',"%6.1f")
if `resval'==. {
	local seval=.
	local sevald "--"
}
local sedi "(`sevald')"
local ub=1/(1+exp(-(log(`resval'/(1-`resval'))- /*
*/ `t'*`seval'/(`resval'*(1-`resval')))))
local lb=1/(1+exp(-(log(`resval'/(1-`resval'))+ /*
*/ `t'*`seval'/(`resval'*(1-`resval')))))
local cimx=100*max(`ub'-`resval',`resval'-`lb')
local lb=string(100*`lb',"%5.1f")
local ub=string(100*`ub',"%5.1f")
local cidi "(`lb'-`ub')"
return local se "`sedi'"
return local ci "`cidi'"
return local cimax "`cimx'"
end


