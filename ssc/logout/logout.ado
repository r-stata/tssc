*! version 1.0.4 05nov2009 logout by roywada@hotmail.com
*! Converts log or ASCII files into various output formats

program define logout

local _original `0'
	
	versionSet
	version `version'

/* "using" no longer used
* encase the colon in file name in quotes, avoiding string function length limits

local behind `"`0'"'
local 0 ""
gettoken front behind: behind, parse(" ,")
local 0 ""
local done 0
while `"`front'"'~="" & `done'==0 {
	if `"`front'"'=="using" {
		
		gettoken rest behind: behind, parse(" ,")
		* strip off quotes
		gettoken first second: rest, parse(" ")
		cap local rest: list clean local(rest)
		
		* take off colon at the end
		local goldfish ""
		if index(`"`rest'"',":")~=0 {
			local end=substr(`"`rest'"',length(`"`rest'"'),length(`"`rest'"'))
			if "`end'"==":" {
				local rest=substr(`"`rest'"',1,`=length(`"`rest'"')-1')
				local goldfish " : "
			}
		}
		
		* colon reattached with a space at the end
		* .txt attached here for seeout working with _pref.ado
		local rabbit `"""'
		if index(`"`rest'"', ".")==0 {
			local using `"`rabbit'`rest'.txt`rabbit'`goldfish'"'
		}
		else {
			local using `"`rabbit'`rest'`rabbit'`goldfish'"'
		}
		local 0 `"`0' using `using' `behind'"'
		local done 1
	}
	else {
		local 0 `"`0' `front'"'
		gettoken front behind: behind, parse(" ,")
	}
}
*/


gettoken first second : 0, parse(":") `bind' match(par) quotes
local 0 `"`first'"'
while `"`first'"'~=":" & `"`first'"'~="" {
	gettoken first second : second, parse(":") `bind' match(par) quotes
}
if `"`0'"'==":" {
	* colon only when shorthand combined with prefix
	local 0
}
else {
	* not used
	local _0 `"`0'"'
}

*** shorthand syntax if use file is missing
syntax[, use(string) save(string) FIX1(numlist) clear FIX fixcut(numlist) text smcl* range(string asis)]
	
	if "`fixcut'"~="" {
		local fix fix
	}
	
	if "`clear'"~="clear" {
		preserve
	}
	
	if "`fix1'"~="" {
		local fix "fix"
	}
	
	if "`Version7'"=="" & "`fix'"=="" {
		* must be fix
		local fix fix
		noi di in yellow "fix option inserted"
	}
	
	* regular stuff
	if `"`use'"'~="" {
		* with use file
		* `second' could contain " " only ???
		
		gettoken a b : second, parse(" ")
		if `"`a'"'~="" {
			noi di in red "cannot combine {opt use( )} with command statements at end; use one or the other"
			exit 198
		}
		
		if "`fix1'"=="" {
			local fix1 5
		}
		
		*`second'
		if `"`range'"'~="" {
			tempfile capfile2
			gettoken one two: range, parse("/")
			gettoken splash two: two, parse("/")
			_chewfile using `"`use'"', save(`capfile2') replace begin(`one') end(`two')
			
			_logout, use(`"`capfile2'"') save(`"`save'"') `options' fix1(`fix1') `clear' `fix' fixcut(`fixcut') original(`_original') range(`range')
		}
		else {
			_logout, use(`"`use'"') save(`"`save'"') `options' fix1(`fix1') `clear' `fix' fixcut(`fixcut') original(`_original') range(`range')
		}
	}
	else {
		* with temporary file
		tempfile capfile
		local tempfile tempfile
		
		if "`Version7'"=="" {
			* a permanent file name for version 7
			local capfile "logout.txt"
		}
		
		* `second' could contain " " only
		gettoken a b : second, parse(" ")
		if `"`a'"'~="" {
			cap unabcmd `a'
			if _rc==0 {
				* it's a command
				if (`"`r(cmd)'"'=="table" | `"`r(cmd)'"'=="tabstat") & "`fix1'"=="" {
					local fix1 1
				}
			}
			if "`fix1'"=="" {
				local fix1 5
			}
			
			noi caplog using `"`capfile'"', tempfile replace `text' `smcl' subspace: `second'
			
			if `"`range'"'~="" {
				tempfile capfile2
				gettoken one two: range, parse("/")
				gettoken splash two: two, parse("/")
				_chewfile using `"`capfile'"', save(`capfile2') replace begin(`one') end(`two')
				
				_logout, use(`"`capfile2'"')  save(`"`save'"') `options' fix1(`fix1') tempfile `clear' `fix' fixcut(`fixcut') original(`_original') range(`range')
			}
			else {
				_logout, use(`"`capfile'"')  save(`"`save'"') `options' fix1(`fix1') tempfile `clear' `fix' fixcut(`fixcut') original(`_original') range(`range')
			}
		}
		else {
			
			if "`fix1'"=="" {
				local fix1 5
			}
			
			* range needs to be activated here for dataout functionality
			_logout, save(`"`save'"') `options' fix1(`fix1') `clear' `fix' fixcut(`fixcut') original(`_original') range(`range')
		}
	}
end


********************************************************************************************


program define _logout

	versionSet
	version `version'

*syntax [using/] , [save(string) nounwrap excel word tex col row ignore(string) drop(string) clear dta ]
syntax,  [ save(string) use(string) nounwrap NOWIPE excel dta tex word clear /*
	*/ NOAUTO raw right FIX FIX1(numlist >=-100 <=100 max=1) replace tempfile /*
	*/ auto(integer 3) dec(numlist int >=0 <=11) fixcut(numlist) range(str asis)] original(str asis) 

* note: options original and range are not really used here:

qui {

local colsizeMax 1
if `"`save'"'~="" {
	* assign save name
	local beg_dot = index(`"`save'"',".")
	if `beg_dot'~=0 {
		local strippedname = substr(`"`save'"',1,`=`beg_dot'-1')
		local save `"`strippedname'.txt"'
	}
	else {
		* `save' has no extension
		local strippedname `"`save'"'
		local save `"`save'.txt"'
	}
	
	cap confirm file `"`save'"'
	if !_rc & "`replace'"~="replace" {
		* it exists
		noi di in red `"`save' exists; specify {opt replace}"'
		exit 198
	}
}
else {
	tempfile tempsave
	local save `"`tempsave'"'
}

if "`use'"~="" {
	
	if "`tempfile'"~="tempfile" {
		local beg_dot = index(`"`use'"',".")
		if `beg_dot'~=0 {
			local strippedname1 = substr(`"`use'"',1,`=`beg_dot'-1')
			
			* no need to reassign name
			*local use `"`strippedname1'.txt"'
		}
		else {
			* `use' has no extension
			local strippedname1 `"`use'"'
			local use `"`use'.txt"'
		}
	}
	
	if "`drop'"~="" {
		if "`unwrap'"=="nounwrap" {
			noi di in red "Cannot combine {opt nounwrap} and {opt drop( )}"
			exit 198
		}
		else {
			local unwrap "unwrap"
		}
	}
	
	
	clear
	
	cap file close _all
	
	*local 0 `"using `0'"'
	tempname source saving
	
	if "`unwrap'"~="nounwrap" {
	*** wrapping text problem ONLY
		
		local linenum = 0
		
		file open `source' using `"`use'"', read
		file open `saving' using `"`save'"', write text replace
		
		file read `source' line
		
		* first line
		if r(eof)==0 {
			local linenum = `linenum' + 1
			local last_macvalline `"`macval(line)'"'
			file read `source' line
		}
		
		* subsequent lines
		local _n
		while r(eof)==0 {
			
			local linenum = `linenum' + 1
			cap tokenize `"`macval(last_macvalline)'"', parse(" []:")
			
			* handle the grave accent thing
			if _rc~=0 {
				noi di in yel `"line `linenum' contains a grave accent (or something), attempt was made to convert it into "grave_accent""'
				local last_macvalline : subinstr local last_macvalline "`" "grave_accent", all
				
				gettoken 1 2 : last_macvalline, parse(" []:")
			}
			
			if `"`1'"'==">" {
				* remove the first instance of ">"
				local last_macvalline : subinstr local last_macvalline "> " ""
				file write `saving' `"`macval(last_macvalline)'"'
			}
			else {
				file write `saving' `_n'
				cap file write `saving' `"`macval(last_macvalline)'"'
				if _rc~=0 {
					noi di in yel `"line `linenum' was unable to be written, left blank"'
					file write `saving' ""
				}
			}
			local _n "_n"
			
			local last_macvalline `"`macval(line)'"'
			file read `source' line
		}
		* the last line
			
			local linenum = `linenum' + 1
			cap tokenize `"`macval(last_macvalline)'"', parse(" []:")
			
			* handle the grave accent thing
			if _rc~=0 {
				noi di in yel `"line `linenum' contains a grave accent (or something), attempt was made to convert it into "grave_accent""'
				local last_macvalline : subinstr local last_macvalline "`" "grave_accent", all
				
				gettoken 1 2 : last_macvalline, parse(" []:")
			}
			
			if `"`1'"'==">" {
				* remove the first instance of ">"
				local last_macvalline : subinstr local last_macvalline ">" ""
				file write `saving' `"`macval(last_macvalline)'"'
			}
			else {
				file write `saving' `_n'
				cap file write `saving' `"`macval(last_macvalline)'"'
				if _rc~=0 {
					noi di in yel `"line `linenum' was unable to be written, left blank"'
					file write `saving' ""
				}
			}
			local _n "_n"
			
		* close out with the last line
		file write `saving' _n
		
		file close `source'
		file close `saving'
	}
	
	
	if "`unwrap'"~="nounwrap" {
		file open `source' using `"`save'"', read
	}
	else {
		file open `source' using `"`use'"', read
	}
	
	if "`fix'"=="fix" {
		*** fix files
		_logfix, use(`use') fix1(`fix1') fixcut(`fixcut')
	}
	else {
		*** delimited files
		
		local col_size 98
		
		local linenum = 1
		
		file read `source' line
		local OBS 50
		set obs `OBS'
		
		
		if "`raw'"=="raw" {
			gen str7 raw=""
			replace raw=`"`line'"' in 1
			
			local _format= "`: format raw'"
			local _widths=substr("`_format'",2,length(trim("`_format'"))-2)
			format raw %-`_widths's
		}
		
		
		gen rowLine=.
		gen tokenMax=.
		
		* this adjusted
		forval num=1/`colsizeMax' {
			gen str2 t`num'=""
		}
		
		
		while r(eof)==0 {
			if `linenum'>`OBS'-1 {
				local OBS=`OBS'+50
				cap set obs `OBS'
				if _rc==198 {
					noi di in red "Cannot increase observation number beyond `OBS': probably need more memory"
				}
			}
			
			*display %4.0f `linenum' _asis `"  `macval(line)'"'
			
			local checking=substr(trim(`"`macval(line)'"'),1,5)
			*noi di `"`checking'"'
			
			if `"`checking'"'=="-----" {
				replace rowLine=`linenum' in `linenum'
				replace t1=`"`checking'"' in `linenum'
			}
			else {
				local macvalline `"`macval(line)'"'
				local macvalline : subinstr local macvalline "Prob > chi2" "Prob>chi2", all
				local macvalline : subinstr local macvalline "Number of groups" "Number_of_groups", all
				local macvalline : subinstr local macvalline "Obs per group: min" "Obs_per_group_min", all
				
				local macvalline : subinstr local macvalline "Number of obs" "Number_of_obs", all
				local macvalline : subinstr local macvalline "Root MSE" "Root_MSE", all
				local macvalline : subinstr local macvalline "Prob > F" "Prob>F", all
				
				local macvalline : subinstr local macvalline "Std. Err." "Std.Err.", all
				local macvalline : subinstr local macvalline "Std. Dev." "Std.Dev.", all
				local macvalline : subinstr local macvalline "95% Conf." "95%_Conf.", all
				local macvalline : subinstr local macvalline "Sum of Wgt." "Sum_of_Wgt.", all
				local macvalline : subinstr local macvalline "log pseudolikelihood" "log_pseudolikelihood", all
				
				cap tokenize `"`macvalline'"', parse(" []:`=char(9)'")
				
				* handle the grave accent thing
				if _rc~=0 {
					noi di in yel `"line `linenum' contains a grave accent (or something), attempt was made to convert it into "grave_accent""'
					local macvalline : subinstr local macvalline "`" "grave_accent", all
					
					tokenize `"`macvalline'"', parse(" []:`=char(9)'")
				}
				
				* numToken is the token number
				* numCol is the column number
				local numToken=1
				local numCol=1
				
				local stop ""
				replace rowLine=`linenum' in `linenum'
				while `"``numToken''"'~="" & "`stop'"~="stop" {
					
					if    `"``numToken''"'~="[" & /*
					*/	`"``numToken''"'~="]" & /*
					*/	`"``numToken''"'~=":" & /*
					*/	`"``numToken''"'~="|" & /*
					*/	`"``numToken''"'~="`=char(9)'" {
						
						* add more columns if necessary
						if `numToken'>=`colsizeMax' {
							local colsizeMax=`colsizeMax'+1
							gen str2 t`colsizeMax'=""
							if "`c(flavor)'"=="small" & `colsizeMax'>=`col_size' {
								noi di in yel `"Stata flavor "small", unable to have more than 99 columns"'
								local stop stop
							}
						}
						
						*noi di in red `"``numToken''"' _c
						*noi di in green ""
						
						replace t`numCol'=`"``numToken''"' in `linenum'
						
					/*	
						* auto-digits
						local check = `"``numToken''"'
						capture confirm number `check'
						
						*noi di in green "`=_rc'"
						
						if _rc==0 & "`noauto'"~="noauto" {
							
							* only if a number
							autodigits2 `"``numToken''"' `auto'
							local valstr = string(`check',"%12.`r(valstr)'")
							
						*noi di in yel `"`valstr'"'
							
							/* prevent adding non-signnificant 0 at the end
							****** does NOT handle scientific notations, or does it?
							local beg_dot1 = index(`"``numToken''"',".")
							local stripped1 = substr(`"``numToken''"',`=`beg_dot1'+1',.)
							local length1 : length local stripped1
							
							local beg_dot2 = index(`"`valstr'"',".")
							local stripped2 = substr(`"`valstr'"',`=`beg_dot2'+1',.)
							local length2 : length local stripped2
							
							if `length2'<=`length1' & `length2'~=0 & `beg_dot2'~=0 & `length1'>0 {
								replace t`numCol'=`"`valstr'"' in `linenum'
							}
							else {
								replace t`numCol'=`"``numToken''"' in `linenum'
							} */
							
							replace t`numCol'=`"`valstr'"' in `linenum'
						}
						else {
							* only if not a number
							replace t`numCol'=`"``numToken''"' in `linenum'
						}
					*/
						replace tokenMax=`numCol' in `linenum'
						local numCol=`numCol'+1
					}
					local numToken=`numToken'+1
				}
			}
			file read `source' line
			
			* noi di `"`macval(line)' dd `r(eof)'"'
			
			local linenum = `linenum' + 1
			if "`raw'"=="raw" {
				replace raw=`"`macval(line)'"' in `linenum'
			}
		}
		
		
		/* works with pre-tokenized columns, but not used because tokenize better if already unwrapped as above,
		* mostly due to the handling of rabbit-ears poking out
		
		* wrapping text problem
		if "`unwrap'"~="nounwrap" {
			* skip first line
			forval num=`=_N'(-1)2 {
				if token1==">" in `num' {
					* counter keeps track of which column being moved to the right end of the previous row
					* token1 is skipped since it has <
					forval counter=2/`=tokenMax[`num']' {
						replace t`=tokenMax[`num'-1]+`=`counter'-1''=t`counter'[`num'] in `=`num'-1'
					}
					replace tokenMax=tokenMax[`num'-1]+tokenMax[`num'] in `=`num'-1'
				}
			}
		}
		*/
		
		/* this is slow
		local num `colsizeMax'
		local stop ""
		while `num' > 1 & "`stop'"=="" {
			count if t`num'==""
			if r(N)==_N {
				drop t`num'
			}
			else {
				local stop "stop"
			}
			local num=`num'-1
		}
		*/
		
		
		* clean up
		if "`row'"~="row" {
			drop rowLine
		}
		if "`col'"~="col" {
			drop tokenMax
		}
		
		* drop extra columns indiscriminately
		* this is slow
		foreach var of varlist _all {
		count if `var'==""
		if r(N)==_N {
			drop `var'
		}
	}
	
	* drop from top
	gen rowmiss=0
	foreach var of varlist _all {
		* cap because rowmiss is non-string
		cap replace rowmiss=rowmiss+1 if `var'~="" & "`var'"~="rowmiss"
	}
	local N=_N
	local oldN
	while "`N'"~="`oldN'" {
		local oldN=_N
		drop in 1 if rowmiss==0
		local N=_N
	}
	
	* drop from bottom
	local N=_N
	local oldN
	while "`N'"~="`oldN'" {
		local oldN=_N
		drop in `oldN' if rowmiss==0
		local N=_N
	}
	drop rowmiss
	
	file close `source'
	file close _all
	} /*** delimited files */
} /* if "`using'"~="" */


if "`nowipe'"~="nowipe" & "`fix'"~="fix" {
	cap drop if t1=="-----" | t1=="opened" | t1=="log" | t1=="." | t1=="closed"
}


/* workaround to see if heading should be reported
local noheading 0
local test 0
foreach var of varlist 
	local temp=instr("`var'",1,2)
	capture confirm string `temp'
		if _rc==0 {
			local * only if a string
			local test 1
		}
 	}
	local temp=instr("`var'",2,3)
	capture confirm number `temp'
		if _rc==0 & "`test'"=="1" {
			* only if a number
			local noheading=`noheading'+1
		}
 	}
}
*/

* replace the gap holders for value labels
* heading for _dataout
if "`use'"~=""  | "`clear'"=="clear" {
	* not being used as dataout
	local head "head"
	foreach var of varlist _all {
		replace `var'= subinstr(`var',"_"," ",.)
		local heading "nohead"
	}
	else {
		*local heading "head"
		* make it always nohead
		local heading "nohead"
	}
}


local heading "nohead"


} /* quietly */


* display the fix command
if "`fixcutCollect'"~="" {
	*di in yel `"  logcut`original' fixcut(`fixcutCollect')"'
	gettoken one two: fixcutCollect, parse(" ")
	di in yel `"  fixcut(`one'`two')"'
}


* display unless temp file was used or not given at all (used the current file in memory)
if "`tempfile'"~="tempfile" & `"`usingTerm'"'~="" {
	local usingTerm `"`use'"'
	local cl_text `"{browse `"`usingTerm'"'}"'
	noi di as txt `"`cl_text'"'
}

* export files
local doit
local doit "`doit'`excel'"
local doit "`doit'`word'"
local doit "`doit'`tex'"
local doit "`doit'`dta'"

if `"`doit'"'~="" {
	di
	
	* add one row if 2 or less
	local N=_N
	if `N'<3 {
		qui {
			tempvar order
			if `N'==0 {
				set obs 3
			}
			else {
				* `N'==1 | `N'==2 
				gen `order'=_n
				set obs 3
				local N=_N
				replace `order'=0 in `N'
				sort `order'
				drop `order'
			}
		}
	}
	
	if "`dec'"~="" {
		local noauto "noauto"
	}
	
	if "`save'"=="" {
		noi di in red "must specify {opt save( )}"
		exit 198
	}
	
	* workaround for names
	ds8
	local names `"`r(varlist)'"'
	
	local strippednameUse `"`strippedname'"'
	if `"`strippedname'"'=="" {
		local strippednameUse `"`strippedname1'"'
	}
	
	_dataout, save(`"`strippednameUse'"') `excel' `tex' `word' `dta' `replace' `heading' `noauto' auto(`auto') dec(`dec')
	
	* folder
	_cdout
	
	local num 1
	foreach var of varlist _all {
		local temp: word `num' of `names'
		ren `var' `temp'
		local num=`num'+1
	}
}

/*
file open `saving' using `save', write text replace
forval linenum=1/`=_N' {
	local content=raw[`linenum']
	file write `saving' `"`macval(content)'"' _n
	local linenum = `linenum' + 1
}
file close _all
*/


end


********************************************************************************************


program define _logfix

	versionSet
	version `version'

qui {

syntax, use(string) FIX1(numlist) [fixcut(numlist)]
	
	*** determine the widths of file
	local infix
	forval num=1/45 {
		local infix "`infix' str1 t`num' `num'-`num'" 
	}
	infix `infix' using `"`use'"', clear
	local col_size 45
	
	* checking the end of file:
	count if t41~=""
	local rN41 `r(N)'
	
	count if t42~=""
	local rN42 `r(N)'
	
	count if t43~=""
	local rN43 `r(N)'
	
	count if t44~=""
	local rN44 `r(N)'
	
	count if t45~=""
	local rN45 `r(N)'
	
	local count=`rN41'+`rN42'+`rN43'+`rN44'+`rN45'
	if `count'~=0 {
		* do over
		local infix
		forval num=1/495 {
			local infix "`infix' str1 t`num' `num'-`num'" 
		}
		infix `infix' using `"`use'"', clear
		local col_size 495
	}
	
	*drop if t1=="-" & t2=="-" & t3=="-" & t4=="-" & t5=="-"
	
	_infix, use(`use') fix1(`fix1') col_size(`col_size') fixcut(`fixcut')
	
	/* example
	gen indicate=1 if rowmiss==0
	replace indicate=sum(indicate)
	
	
	
	*logout, save(mystuff1) excel fix(10) replace noauto: reg price mpg rep78 head
	*logout, save(mystuff2) excel nowipe replace noauto: reg price mpg rep78 head
	
	_infix in 8/`=_N', use(`use') fix1(10) col_size(`col_size') fixcut(`fixcut')
	
	gen wave=2	
	save fixing, replace
	
	_infix in 1/7, use(`use') fix1(19) col_size(`col_size')	 fixcut(`fixcut')
	
	append using fixing
	replace wave=1 if wave==.
	
	aorder t*
	browse
	logleft, wave_top(1) wave_bot(2)
	browse
	*/
	
	
	cap drop rowmiss
	cap drop indicate
}

* return
c_local fixcutCollect `"`fixcutCollect'"'

end /* logfix */


********************************************************************************************


program define logleft
	
	syntax, wave_top(numlist) wave_bot(numlist)
	unab varList: t*
	tokenize `varList'
	local varCount: word count varList
	local var1 1
	local var2 2
	
	while "``var2''"~="" {
		count if ``var1''~="" & wave==`wave_top'
		local rN1_top=r(N)
		count if ``var1''~="" & wave==`wave_bot'
		local rN1_bot=r(N)
		
		count if ``var2''~="" & wave==`wave_top'
		local rN2_top=r(N)
		count if ``var2''~="" & wave==`wave_bot'
		local rN2_bot=r(N)
		
		if `rN1_top'~=0 & `rN1_bot'==0 & `rN2_top'==0 & `rN2_bot'~=0 {
			replace ``var1''=``var2'' if wave==`wave_bot'
			drop ``var2''
			local var1=`var1'+1
			local var2=`var2'+1
		}
		else if `rN1_top'==0 & `rN1_bot'~=0 & `rN2_top'~=0 & `rN2_bot'==0 {
			replace ``var1''=``var2'' if wave==`wave_top'
			drop ``var2''
			local var1=`var1'+1
			local var2=`var2'+1
		}
		else if `rN1_top'==0 & `rN1_bot'==0 {
			drop ``var1''
		}
		local var1=`var1'+1
		local var2=`var2'+1
	}
	
end


********************************************************************************************


program define _infix

	versionSet
	version `version'

qui {

syntax [in], use(string) FIX1(numlist) col_size(numlist) [fixcut(numlist)]
	local infix
	forval num=1/`col_size' {
		local infix "`infix' str1 t`num' `num'-`num'" 
	}
	infix `infix' `in' using `"`use'"', clear
	
* must be beyond square
local N=_N
if `N'<`col_size' {
	local new_size=`col_size'+5
	set obs `new_size'
}

* replace the lines
ds8

tokenize `dsVarlist'
local num 0
local one=1+`num'
local two=2+`num'
local three=3+`num'

* 165, 127, 216
while "``three''"~="" {
	
	replace ``one''="¥Ø" if ``one''=="-" & ``two''=="-" & ``three''=="-"
	replace ``two''="¥Ø" if ``one''=="¥Ø" & ``two''=="-" & ``three''=="-"
	replace ``three''="¥Ø" if ``one''=="¥Ø" & ``two''=="¥Ø" & ``three''=="-"
	replace ``three''="¥Ø" if ``one''=="¥Ø" & ``two''=="¥Ø" & ``three''=="+"
	
	local num=`num'+1
	local one=1+`num'
	local two=2+`num'
	local three=3+`num'
}

ds8
local thisMany: word count `dsVarlist'


gen height=.
forval num=1/`col_size' {
	qui count if t`num'~="" & t`num'~="¥Ø"
	di "`r(N)' " _c
	replace height=`r(N)' in `num'
}

/*
gen id=_n if _n<=100
line height id 

sort height
drop id
gen id=_n if _n<=100
line height id
*/

sum height, det


forval wave=1/50 {

	* limit
	local times=`fix1'/1000*`wave'
	local parameter=`r(max)'*`times'
	
	gen trend`wave'=.
	replace trend`wave'=-1 if (height<height[_n-1]-`parameter' & height[_n-1]~=.)
	
	gen minima`wave'=.
	*replace minima`wave'=1 if trend`wave'==-1 & height<`parameter'
	replace minima`wave'=1 if trend`wave'==-1
	
	* replace if still dropping in height
	forval num=1/10 {
		replace minima`wave'=0 if minima`wave'==1 & height>=height[_n+1]==1
		replace minima`wave'=1 if minima`wave'[_n-1]==0 & minima`wave'==.
	}
}

egen minima=rsum(minima*)
order minima*

*tab minima

/*
local infix
local begin 1

forval num=1/`thisMany' {
	local content=minima[`num']
	if `content'>25 {
		local width=`num'-`begin'+1
		local infix "`infix' str`width' t`num' `begin'-`num'" 
		local begin=`num'+1
	}
}
* noi di "`infix'"

infix `infix' `in' using `"`use'"', clear
*/

local infix
local fixcutCollect
local begin 1
	
* automatically infix
forval num=1/`thisMany' {
	local content=minima[`num']
	if `content'>25 {
		local width=`num'-`begin'+1
		local infix "`infix' str`width' t`num' `begin'-`num'" 
		local fixcutCollect "`fixcutCollect' `num'"
		local begin=`num'+1
	}
}
*noi di in red "`infix'"
*noi di in red "`fixcutCollect'"
infix `infix' `in' using `"`use'"', clear

if "`fixcut'"~="" {
	
	local infix
	local fixcutCollect
	local begin 1

	* manually infix
	local num 1
	tokenize `fixcut'
	while "``num''"~="" {
		local width=``num''-`begin'+1
		local infix "`infix' str`width' t``num'' `begin'-``num''" 
		local fixcutCollect "`fixcutCollect' ``num''"
		local begin=``num''+1
		local num=`num'+1
	}
	*noi di in red "`infix'"
	*noi di in red "`fixcutCollect'"
	infix `infix' `in' using `"`use'"', clear
	local fixcut fixcutCollect
}

* drop verticals first
local N=_N
foreach var of varlist _all {
	count if `var'=="|"
	if `r(N)'>.5*`N' {
		drop `var'
	}
}

* stronger codes for manual infix as well
* replace the horizontal lines
tempvar length test
cap gen `length'=.
cap gen `test'=.
foreach var of varlist _all {
	cap replace `length'=length(`var')
	cap replace `test'=(`length'-length(subinstr(`var',"-","",.)))/`length' if `length'>2
	cap replace `var'="" if `test'>=0.5
}
drop `length' `test'
	
	/* older
	* replace the horizontal lines
	tempvar length test
	cap gen `length'=.
	cap gen str7 `test'=""
	foreach var of varlist _all {
		cap replace `length'=length(`var')
		cap replace `test'=subinstr(`var',"-","",.) if `length'>2
		cap replace `var'="" if `test'==""
	}
	drop `length' `test'
	*/
	
	/* oldest
	replace the horizontal lines
	foreach var of varlist _all {
		local N=_N
		forval num=1/`N' {
			local content=`var'[`num']
			local length=length(`"`content'"')
			if `length'>2 {
				local test : subinstr local content "-" "", all
				if "`test'"=="" {
					replace `var'="" in `num'
				}
			}
		}
	}
	*/
	
compress


} /* quietly */

************ needs to cut at left if not rising anymore

* drop extra columns indiscriminately
* this is slow
foreach var of varlist _all {
	count if `var'==""
	if r(N)==_N {
		drop `var'
	}
}


* drop from top
gen rowmiss=0
foreach var of varlist _all {
	* cap because rowmiss is non-string
	cap replace rowmiss=rowmiss+1 if `var'~="" & "`var'"~="rowmiss"
}
local N=_N
local oldN
while "`N'"~="`oldN'" {
	local oldN=_N
	drop in 1 if rowmiss==0
	local N=_N
}



* drop from bottom
local N=_N
local oldN
while "`N'"~="`oldN'" {
	local oldN=_N
	drop in `oldN' if rowmiss==0
	local N=_N
}


* return
c_local fixcutCollect `"`fixcutCollect'"'

end /* _infix */


********************************************************************************************


*** ripped from dataout Apr 2008
program define _dataout

syntax [using/], [save(string) excel tex word dta NOHEAD HEAD replace NOAUTO auto(integer 3) dec(numlist int >=0 <=11)]
version 7

if "`fix1'"~="" {
	local fix "fix"
}

if `"`using'"'=="" & "`save'"=="" {
		noi di in red "must specify {opt using} or {opt save( )}"
		exit 198
}

if "`using'"~="" {
	* attach .txt if nothing attached
	local beg_dot = index(`"`using'"',".")
	if `beg_dot'==0 {
		local using `"`using'.txt"'
	}
}


if "`save'"=="" {
	* assign save name
	local beg_dot = index(`"`using'"',".")
	local strippedname = substr(`"`using'"',1,`=`beg_dot'-1')
	local save "`strippedname'_logout.txt"
}
else {
	* assign save name
	local beg_dot = index(`"`save'"',".")
	if `beg_dot'~=0 {
		local strippedname = substr(`"`save'"',1,`=`beg_dot'-1')
		local save `"`strippedname'.txt"'
	}
	else {
		* `save' has no extension
		local strippedname `"`save'"'
		local save `"`save'.txt"'
	}
	
	
	if `"`using'"'=="" {
		* if using file was not specified but save was:
		local beg_dot = index(`"`save'"',".")
		if `beg_dot'~=0 {
			local strippedname = substr(`"`save'"',1,`=`beg_dot'-1')
		}
		else {
			local strippedname `"`save'"'
		}
	}
}


qui {

if `"`using'"'~="" {
	preserve
	qui insheet using `"`using'"', noname clear
}

*foreach var of varlist _all {
*	tostring `var', replace force
*}
stringMaker

if "`dec'"~="" {
	* apply decimals
	foreach var of varlist _all {
		local N=_N
		forval num=1/`N' {
			local content=`var'[`num']
			
			capture confirm number `content'
			if _rc==0 {
				* only if a number
				replace `var' = string(`content',"%12.`dec'fc") in `num'
			}
			else {
				* only if not a number
				*replace `var'=`"`content'"' in `num'
			}
		}
	}
}



if "`noauto'"~="noauto" & "`dec'"=="" {
	* apply autodigits
	foreach var of varlist _all {
		local N=_N
		forval num=1/`N' {
			local content=`var'[`num']
			
			capture confirm number `content'
			if _rc==0 {
				* only if a number
				autodigits2 `content' `auto' `less'
				replace `var' = string(`content',"%12.`r(valstr)'") in `num'
			}
			else {
				* only if not a number
				*replace `var'=`"`content'"' in `num'
			}
		}
	}
}


if ("`nohead'"~="nohead" & `"`using'"'=="") | "`head'"=="head" {
	* moves the variable names down
	local N=_N+1
	tempvar id
	gen `id'=_n
	set obs `N'
	replace `id'=0 in `N'
	sort `id'
	drop `id'
	local num 1
	foreach var of varlist _all {
		replace `var'="`var'" in 1
	}
}


* needs to be renamed regardless
local num 1
foreach var of varlist _all {
	ren `var' v`num'
	local num=`num'+1
}




*** dta file thing
if "`dta'"=="dta" {
	cap confirm file `"`strippedname'.dta"'
	if !_rc & "`replace'"~="replace" {
		* it exists
		noi di in red `"`strippedname'.dta exists; specify {opt replace}"'
		exit 198
	}
	
	save `"`strippedname'"', replace
	
	*local usingTerm `"`strippedname'.dta"'
	*local cl `"{browse logout, seefile(`"`usingTerm'"'):`usingTerm'}"'
	*noi di as txt `"`cl'"'
}


*** Excel xml file thing
if "`excel'"=="excel" {
	tempfile file1
	
	cap confirm file `"`strippedname'.xml"'
	if !_rc & "`replace'"~="replace" {
		* it exists
		noi di in red `"`strippedname'.xml exists; specify {opt replace}"'
		exit 198
	}
	
	save `file1', replace
	if "`raw'"=="raw" {
		replace raw=`"""' + raw + `"""'
	}
	
local titleWide 0
local headBorder 1
local N=_N
local bottomBorder `N'

	*use `outing',clear
*	_xmlout using `"`strippedname'"', excelFile(`excelFile') nonames titleWide(`titleWide') /*
*		*/ headBorder(`headBorder') bottomBorder(`bottomBorder') 
	
	local N=_N
	
	_xmlout using `"`strippedname'"',  nonames headBorder(1) bottomBorder(`N')
	local usingTerm `"`strippedname'.xml"'
	local cl `"{browse `"`usingTerm'"'}"'
	noi di as txt `"`cl'"'
	
	use `file1', clear
}


if "`word'"=="word" | "`tex'"=="tex" {
	cap preserve
	if ("`nohead'"=="nohead" & `"`using'"'~="") & "`head'"~="head" {
		* `using' indicates
		* files not yet named v*
		local num 1
		foreach var of varlist _all {
			ren `var' v`num'
			local num=`num'+1
		}
	}

*** Word rtf file thing
if "`word'"=="word" {

	cap confirm file `"`strippedname'.rtf"'
	if !_rc & "`replace'"~="replace" {
		* it exists
		noi di in red `"`strippedname'.rtf exists; specify {opt replace}"'
		exit 198
	}

local titleWide 0
local headBorder 2
local N=_N
local bottomBorder `N'

local totrows `N'
	
	* there must be varlist to avoid error
	*_wordout v* `"`using'"',  titleWide(`titleWide') headBorder(`headBorder') bottomBorder(`bottomBorder') replace nopretty
	_wordout v* using `"`strippedname'"', wordFile(`wordFile') titleWide(`titleWide') /*
		*/ headBorder(`headBorder') bottomBorder(`bottomBorder') replace nopretty
	local temp `r(documentname)'
	
	* strip off "using" and quotes
	gettoken part rest: temp, parse(" ")
	gettoken usingTerm second: rest, parse(" ")
	
	local cl_word `"{browse `"`usingTerm'"'}"'
	noi di as txt `"`cl_word'"'

}

*** LaTeX thing
*** (will mess up the original file)
if "`tex'"=="tex" {
	
local titleWide 0
local headBorder 1
local N=_N
local bottomBorder `N'
	
	cap confirm file `"`strippedname'.tex"'
	if !_rc & "`replace'"~="replace" {
		* it exists
		noi di in red `"`strippedname'.tex exists; specify {opt replace}"'
		exit 198
	}
	
	* make certain `1' is not `"`using'"' (another context)
	
	_texout v* using `"`strippedname'"', texFile(`texFile') titleWide(`titleWide') headBorder(`headBorder') bottomBorder(`bottomBorder') `texopts' replace
	
	if `"`texFile'"'=="" {
		local endName "tex"
	}
	else {
		local endName "`texFile'"
	}
	
	local usingTerm `"`strippedname'.`endName'"'
	local cl_tex `"{browse `"`usingTerm'"'}"'
	noi di as txt `"`cl_tex'"'

}
}

} /* quietly */

end


********************************************************************************************


*** ripped from outreg2 Mar 2008
program define autodigits2, rclass
version 7.0

* getting the significant digits
args input auto less

if `input'~=. {
	local times=0
	local left=0
	
	* integer checked by modified mod function
	if round((`input' - int(`input')),0.0000000001)==0 {
		local whole=1
	}
	else {
		local whole=0
		* non-interger
		 if `input'<. {
			
			* digits that need to be moved if it were only decimals: take the ceiling of log 10 of absolute value of decimals
			local times=abs(int(ln(abs(`input'-int(`input')))/ln(10)-1))	
			
			* the whole number: take the ceiling of log 10 of absolute value
			local left=int(ln(abs(`input'))/ln(10)+1)
		}
	}
	
	
	* assign the fixed decimal values into aadec
	if `whole'==1 {
		local aadec=0
	}
	else if .>`left' & `left'>0 {
		* reduce the left by one if more than zero to accept one extra digit
		if `left'<=`auto' {
			local aadec=`auto'-`left'+1
		}
		else {
			local aadec=0
		}
	}
	else {
		local aadec=`times'+`auto'-1
	}
	
	if "`less'"=="" {
		* needs to between 0 and 11
		if `aadec'<0 {
			local aadec=0
		}
		*if `aadec'<11 {
		if `aadec'<7 {
			* use fixed
			local valstr "`aadec'f"
		}
		else {
			* use exponential
			local valstr "`=`auto'-1'e"
		}
	}
	else {
		* needs to between 0 and 11
		local aadec=`aadec'-`less'
		if `aadec'<0 {
			local aadec=0
		}
		*if `aadec'<10 {
		if `aadec'<7 {
			* use fixed
			local valstr "`aadec'f"
		}
		else {
			* use exponential
			local valstr "`=`auto'-1'e"
		}
	}
	
	* make it exponential if too big
	if `input'>1000000 & `input'<. {
		local valstr "`=`auto'-0'e"		
	}
	
	* make it exponential if too negative (small)
	if `input'<-1000000 & `input'<. {
		local valstr "`=`auto'-0'e"		
	}
	
	return scalar value=`aadec'
	return local valstr="`valstr'"
}
else {
	* it is a missing value
	return scalar value=.
	return local valstr="missing"
}
end


********************************************************************************************


* ripped from outreg2 on Apr2009
* 27oct2009 nopretty fixed

program define _texout, sortpreserve
* based on out2tex version 0.9 4oct01 by john_gallup@alum.swarthmore.edu
version 7.0
	
	* add one if only one v* column exists
	unab list: v*
	local count: word count `list'
	if `count'==1 {
		gen str v2=""
		order v*
	}
	if `count'==0 {
		exit
	}
	
	if "`1'" == "using" {
		syntax using/ [, texFile(string) Landscape Fragment NOPRetty PRetty	/*
		*/	Fontsize(numlist integer max=1 >=10 <=12) noBorder Cellborder	/*
		*/	Appendpage noPAgenum a4 a5 b5 LETter LEGal EXecutive replace	/*
		*/	Fast											]
		
		if "`pretty'"=="pretty" {
			local nopretty ""		
		}
		
		if "`fast'" == "" {
			preserve
		}
		
		loadout using `"`using'"', clear
		local numcol	= `r(numcol)'
		local titleWide  = `r(titleWide)'
		local headBorder = `r(headBorder)'
		local bottomBorder	= `r(bottomBorder)'
		local totrows	= _N
		
		local varname "v1"
		unab statvars : v2-v`numcol'
	}
	else {
		syntax varlist using/, titleWide(int) headBorder(int) bottomBorder(int)		/*
		*/	[texFile(string) TOtrows(int 0) Landscape Fragment NOPRetty PRetty	/*
		*/	Fontsize(numlist integer max=1 >=10 <=12) noBorder Cellborder		/*
		*/	Appendpage noPAgenum a4 a5 b5 LETter LEGal EXecutive replace		]
		if `totrows'==0 {
			local totrows = _N
		}
		local numcols : word count `varlist'
		gettoken varname statvars : varlist
		local fast 1
	}
	
	if "`pretty'"=="pretty" {
		local pretty ""
	}
	else {
		local pretty "NOT PRETTY AT ALL"
	}
	
	local colhead1 = `titleWide' + 1
	local strow1 = `headBorder' + 1
	
	* insert $<$ to be handled in LaTeX conversion
	local N=_N
	forval num=`bottomBorder'/`N' {
		local temp=v1[`num']
		tokenize `"`temp'"', parse (" <")
		local count 1
		local newTex ""
		local noSpace 0
		while `"``count''"'~="" {
			if `"``count''"'=="<" {
				local `count' "$<$"
				local newTex `"`newTex'``count''"'
				local noSpace 1
			}
			else {
				if `noSpace'~=1 {
					local newTex `"`newTex' ``count''"'
				}
				else {
					local newTex `"`newTex'``count''"'					
					local noSpace 0
				}
			}
			local count=`count'+1
		}
		replace v1=`"`newTex'"' in `num'
	}
	
	*** replace if equation column present
	count if v1=="EQUATION"
	if `r(N)'~=0 {
		tempvar myvar
		* use v2 instead
		replace v1 = v2 in `=`bottomBorder'+1'/`totrows'
		replace v2 = "" in `=`bottomBorder'+1'/`totrows'
		
		* change the string length
		gen str5 `myvar' =""
		replace `myvar' =v2
		drop v2
		ren `myvar' v2
		order v1 v2
	}
	
	/* if file extension specified in `"`using'"', replace it with ".tex" for output
	local next_dot = index(`"`using'"', ".")
	if `next_dot' {
		local using = substr("`using'",1,`=`next_dot'-1')
	}
	*/
	
	if `"`texFile'"'=="" {
		local endName "tex"
	}
	else {
		local endName "`texFile'"
	}
	
	local using `"using "`using'.`endName'""'
	local fsize = ("`fontsize'" != "")
	if `fsize' {
		local fontsize "`fontsize'pt"
	}
	local lscp = ("`landscape'" != "") 
	if (`lscp' & `fsize') {
		local landscape ",landscape"
	}
	local pretty	= ("`pretty'" == "")
	local cborder  = ("`cellborder'" != "")
	local noborder = ("`border'" != "")
	local nopagen  = ("`pagenum'" != "")
	local nofrag	= ("`fragment'" == "")
	
	if `cborder' & `noborder' {
		di in red "may not specify both cellborder and noborder options"
		exit 198
	}
	
	local nopt : word count `a4' `a5' `b5' `letter' `legal' `executive'
	if `nopt' > 1 {
		di in red "choose only one of a4, a5, b5, letter, legal, executive"
		exit 198 
	}
	local pagesize "`a4'`a5'`b5'`letter'`legal'`executive'"
	if "`pagesize'"=="" | "`letter'"!="" {
		local pwidth  "8.5in"
		local pheight "11in"
	}
	else if "`legal'"!="" {
		local pwidth  "8.5in"
		local pheight "14in"
	}
	else if "`executive'"!="" {
		local pwidth  "7.25in"
		local pheight "10.5in"
	}
	else if "`a4'"!="" {
		local pwidth  "210mm"
		local pheight "297mm"
	}
	else if "`a5'"!="" {
		local pwidth  "148mm"
		local pheight "210mm"
	}
	else if "`b5'"!="" {
		local pwidth  "176mm"
		local pheight "250mm"
	}
	if `lscp' {
		local temp	 "`pwidth'"
		local pwidth  "`pheight'"
		local pheight "`temp'"
	}
	if "`pagesize'"!="" {
		local pagesize "`pagesize'paper"
		if (`lscp' | `fsize') {
			local pagesize ",`pagesize'"
		}
	}
	if `cborder' & `noborder' {
		di in red "may not specify both cellborder and noborder options"
		exit 198
	}
	
	quietly {
		tempvar has_eqn st2_row last_st pad0 pad1 pad2_n padN order
		
		* replace % with \%, and _ with \_ if <2 $'s (i.e. not an inline equation: $...$
		* has_eqn indicates that varname has 2+ $'s
		
		gen byte `has_eqn' = index(`varname',"$")
		
		* make sure there are 2+ "$" in varname
		replace `has_eqn' = index(substr(`varname',`has_eqn'+1,.),"$")>0 if `has_eqn'>0
		replace `varname'= subinstr(`varname',"_", "\_", .) if !`has_eqn'
		replace `varname'= subinstr(`varname',"%", "\%", .)
		
		if `pretty' {
			replace `varname'= subinword(`varname',"R-squared", "\$R^2$", 1) in `strow1'/`bottomBorder'
			replace `varname'= subinstr(`varname'," t stat", " \em t \em stat", 1) in `bottomBorder'/`totrows'
			replace `varname'= subinstr(`varname'," z stat", " \em z \em stat", 1) in `bottomBorder'/`totrows'
		}
		
		foreach svar of local statvars { /* make replacements for column headings rows of statvars */
			replace `has_eqn' = index(`svar',"$") in `colhead1'/`headBorder'
			replace `has_eqn' = index(substr(`svar',`has_eqn'+1,.),"$")>0 in `colhead1'/`headBorder' if `has_eqn'>0
			replace `svar'= subinstr(`svar',"_", "\_", .) in `colhead1'/`headBorder' if !`has_eqn'
			replace `svar'= subinstr(`svar',"%", "\%", .) in `colhead1'/`headBorder'
			
			/* replace <, >, {, }, | with $<$, $>$, \{, \}, and $|$ in stats rows */
			/* which can be used as brackets by outstat */
			replace `svar'= subinstr(`svar',"<", "$<$", .) in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',">", "$>$", .) in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',"{", "\{", .)  in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',"}", "\}", .)  in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',"|", "$|$", .) in `strow1'/`bottomBorder'
		}
		
		if `pretty' {  /* make title fonts large; notes & t stats small */
			local blarge "\begin{large}"
			local elarge "\end{large}"
			local bfnsize "\begin{footnotesize}"
			local efnsize "\end{footnotesize}"
		}
		if `cborder' {
			local vline "|"
		}
		gen str20 `pad0' = ""
		gen str20 `padN' = ""
		if `titleWide' {
			replace `pad0' = "\multicolumn{`numcols'}{`vline'c`vline'}{`blarge'" in 1 / `titleWide'
			replace `padN' = "`elarge'} \\\" in 1 / `titleWide'
		}
		if `bottomBorder' < `totrows' {
			local noterow1 = `bottomBorder' + 1
			replace `pad0' = "\multicolumn{`numcols'}{`vline'c`vline'}{`bfnsize'" in `noterow1' / l
			replace `padN' = "`efnsize'} \\\" in `noterow1' / l
		}
		
		gen str3 `pad1' = " & " in `colhead1' / `bottomBorder'
		if `numcols' > 2 {
			gen str3 `pad2_n' = `pad1'
		}
		if `pretty' { /* make stats 2-N small font */
			local strow1 = `headBorder' + 1
			gen byte `st2_row' = 0
			replace `st2_row' = (trim(`varname') == "") in `strow1' / `bottomBorder'	 /* only stats 2+ */
			gen byte `last_st' = (`st2_row' & `varname'[_n+1] != "")			 /* last stats row */
			if !`cborder' {
				replace `pad0'	= "\vspace{4pt}" if `last_st'
			}
				replace `pad1'	= `pad1' + "`bfnsize'" if `st2_row'
				if `numcols' > 2 {
					replace `pad2_n' = "`efnsize'" + `pad2_n' + "`bfnsize'" if `st2_row'
				}
				replace `padN'	= "`efnsize'" if `st2_row'
			}
		
			replace `padN' = `padN' + " \\\" in `colhead1' / `bottomBorder'
			if `cborder' {
				replace `padN' = `padN' + " \hline"
			}
			else {
			if !`noborder' {
				if `headBorder' {
					if `titleWide' {
						replace `padN' = `padN' + " \hline" in `titleWide'
					}
					replace `padN' = `padN' + " \hline" in `headBorder'
				}
				replace `padN' = `padN' + " \hline" in `bottomBorder'
			}
		}
		
		local vlist "`pad0' `varname' `pad1'"
		tokenize `statvars'
		local ncols_1 = `numcols' - 1
		local ncols_2 = `ncols_1' - 1
		forvalues v = 1/`ncols_2' {
			local vlist "`vlist' ``v'' `pad2_n'"
		}
		local vlist "`vlist' ``ncols_1'' `padN'"
		
		local texheadfootrows = `nofrag' + `pretty' + 1	/* in both headers and footers */ 
		local texheadrow = 2 * `nofrag' + `nopagen' + `texheadfootrows'
		local texfootrow = `texheadfootrows'
		local newtotrows = `totrows' + `texheadrow' + `texfootrow'
		if `newtotrows' > _N {
			local oldN = _N
			set obs `newtotrows'
		}
		else {
			local oldN = 0
		}
		gen long `order' = _n + `texheadrow' in 1 / `totrows'
		local newtexhrow1 = `totrows' + 1
		local newtexhrowN = `totrows' + `texheadrow'
		replace `order' = _n - `totrows' in `newtexhrow1' / `newtexhrowN'
		sort `order'
		
		
		* insert TeX header lines
		local ccc : display _dup(`ncols_1') "`vline'c"
		if `nofrag' {
			replace `pad0' = "\documentclass[`fontsize'`landscape'`pagesize']{article}" in 1
			replace `pad0' = "\setlength{\pdfpagewidth}{`pwidth'} \setlength{\pdfpageheight}{`pheight'}" in 2
			replace `pad0' = "\begin{document}" in 3
			replace `pad0' = "\end{document}" in `newtotrows'  
		}
		if `nopagen' {
			local row = `texheadrow' - 1 - `pretty'
			replace `pad0' = "\thispagestyle{empty}" in `row'
		}
		if `pretty' {
			local row = `texheadrow' - 1
			replace `pad0' = "\begin{center}" in `row'
			local row = `newtotrows' - `texfootrow' + 2
			replace `pad0' = "\end{center}"	in `row'
		}
		local row = `texheadrow'
		replace `pad0' = "\begin{tabular}{`vline'l`ccc'`vline'}" in `row'
		if (!`titleWide' | `cborder') & !`noborder' {
			replace `pad0' = `pad0' + " \hline" in `row'
		}
		local row = `newtotrows' - `texfootrow' + 1
		replace `pad0' = "\end{tabular}" in `row'
		
		outfile `vlist' `using' in 1/`newtotrows', `replace' runtogether
		
		* delete new rows created for TeX table, if any
		if `oldN' {
			keep in 1/`totrows'
		}
	} /* quietly */
end  /* end _texout */


********************************************************************************************


* ripped from outreg2 on Mar2009
program define _wordout, sortpreserve rclass
version 7.0
* based on version 0.9 4oct01 by john_gallup@alum.swarthmore.edu
	if "`1'" == "using" {
		syntax using/ [, wordFile(string) Landscape Fragment noPRetty	/*
		*/	Fontsize(numlist max=1 >0) noBorder Cellborder			/*
		*/	Appendpage PAgesize(string)						/*
		*/	Lmargin(numlist max=1 >=0.5) Rmargin(numlist max=1 >=0.5) 	/*
		*/	Tmargin(numlist max=1 >=0.5) Bmargin(numlist max=1 >=0.5) 	/*
		*/	replace Fast]
		
		if "`fast'" == "" {preserve}
		loadout using `"`using'"', clear
		local numcol	= `r(numcol)'
		local titleWide  = `r(titleWide)'
		local headBorder = `r(headBorder)'
		local bottomBorder	= `r(bottomBorder)'
		local totrows	= _N
		local varname "v1"
		unab statvars : v2-v`numcol'
	}
	else {
		syntax varlist using/, titleWide(int) headBorder(int) bottomBorder(int)		/*
		*/	[wordFile(string) TOtrows(int 0) Landscape Fragment noPRetty	/*
		*/	Fontsize(numlist max=1 >0) noBorder Cellborder				/*
		*/	Appendpage PAgesize(string)							/*
		*/	Lmargin(numlist max=1 >=0.5) Rmargin(numlist max=1 >=0.5)		/*
		*/	Tmargin(numlist max=1 >=0.5) Bmargin(numlist max=1 >=0.5)		/*
		*/	replace]
		if `totrows'==0 {
			local totrows = _N
		}
		local numcols : word count `varlist'
		gettoken varname statvars : varlist
		local fast 1
	}
	
	local colhead1 = `titleWide' + 1
	local strow1 = `headBorder' + 1
	
	
	*** replace if equation column present
	local hack 0
	count if v1=="EQUATION"
	if `r(N)'~=0 {
		* use v2 instead
		replace v1 = v2 in `=`bottomBorder'+1'/`totrows'
		replace v2 = "" in `=`bottomBorder'+1'/`totrows'
		
		* change the string length
		gen str5 myvar =""
		replace myvar =v2
		drop v2
		ren myvar v2
		order v1 v2
		
		local hack 1
	}
	
	/* if file extension specified in `"`using'"', replace it with ".rtf" for output
	local next_dot = index(`"`using'"', ".")
	if `next_dot' {
		local using = substr(`"`using'"',1,`=`next_dot'-1')
	}
	*/
	
	if `"`wordFile'"'=="" {
		local endName "rtf"
	}
	else {
		local endName "`wordFile'"
	}
	
	local using `"using "`using'.`endName'""'
	return local documentname `"`using'"'
	
	if "`fontsize'" == "" {
		local fontsize "12"
	}
	
	local lscp = ("`landscape'" != "") 
	local pretty	= ("`pretty'" == "")
	local cborder  = ("`cellborder'" != "")
	local noborder = ("`border'" != "")
	local stdborder = (!`noborder' & !`cborder')
	local nopagen  = ("`pagenum'" != "")
	local nofrag	= ("`fragment'" == "")
	
	
	if `cborder' & !`noborder' {
		di in red "may not specify both cellborder and noborder options"
		exit 198
	}
	
	* reformat "R-squared" and italicize "t" or "z"
	if `pretty' {
		quietly {
			replace `varname'= subinword(`varname',"R-squared", "{\i R{\super 2}}", 1) in `strow1'/`bottomBorder'
			replace `varname'= subinstr(`varname'," t stat", " {\i t} stat", 1) in `bottomBorder'/`totrows'
			replace `varname'= subinstr(`varname'," z stat", " {\i z} stat", 1) in `bottomBorder'/`totrows'
		}
	}
	
	* font sizes in points*2
	local font2 = int(`fontsize'*2)
	if `pretty' {
		/* make title fonts large; notes & t stats small */
		local fslarge = "\fs" + string(int(`font2' * 1.2))
		local fsmed	= "\fs" + string(`font2')
		local fssmall = "\fs" + string(int(`font2' * 0.8))
		local sa0 "\sa0"	/* put space after t stats rows */
		local gapsize = int(`fontsize'*0.4*20)  /* 40% of point size converted to twips */
		local sa_gap "\sa`gapsize'"
	}
	else {
		local fs0 = "\fs" + string(`font2')
	}
	
	local onecolhead = (`headBorder' - `titleWide' == 1)
			/* onecolhead = true if only one row of column headings */
	if `stdborder' {
		if !`onecolhead' {
			* runs here
			*local trbrdrt "\clbrdrt\brdrs"	/* table top is overlined */
			*local trbrdrt "\trbrdrt\brdrs"	/* table top is overlined */
			
			local clbrdr_uo "\clbrdrt\brdrs"	/* cells are overlined */
			local clbrdr_ul "\clbrdrb\brdrs"	/* cells are underlined */
		}
		else {
			/* cells are over- and underlined */
			local clbrdr_ul "\clbrdrt\brdrs\clbrdrb\brdrs"
		
		}
		local trbrdrb "\trbrdrb\brdrs"
	}
	if `cborder' {
		/* if !cborder then clbrdr is blank */
		local clbrdr "\clbrdrt\brdrs\clbrdrb\brdrs\clbrdrl\brdrs\clbrdrr\brdrs"
	}
	
	* figure out max str widths to make cell boundaries
	* cell width in twips = (max str width) * (pt size) * 12
	* (12 found by trial and error)
	local twipconst = int(`fontsize' * 12 )
	tempvar newvarname
	qui gen str80 `newvarname' = `varname' in `strow1'/`bottomBorder'
	
	local newvarlist "`newvarname' `statvars'"
	qui compress `newvarlist'
	local cellpos = 0
	foreach avar of local newvarlist {
		local strwidth : type `avar'
		local strwidth = subinstr("`strwidth'", "str", "", .)
		local strwidth = `strwidth' + 1  /* add buffer */
		local cellpos = `cellpos' + `strwidth'*`twipconst'

		* hacking
		if `hack'==1 & "`avar'"=="`newvarname'" & `cellpos'<1350 {
			local cellpos=1350 
		}
		local clwidths "`clwidths'`clbrdr'\cellx`cellpos'"
		
		* put in underline at bottom of header in clwidth_ul
		local clwidth_ul "`clwidth_ul'`clbrdr_ul'\cellx`cellpos'"
		
		* put in overline
		local clwidth_ol "`clwidth_ol'`clbrdr_uo'\cellx`cellpos'"
	}
	
	if `stdborder' {
		if `onecolhead' {
			local clwidth1 "`clwidth_ul'"
		}
		else {
			local clwidth1 "`clwidths'"
			local clwidth2 "`clwidth_ul'"
		}
		local clwidth3 "`clwidths'"
	}
	else{
		local clwidth1 "`clwidths'"
	}
	
	* statistics row formatting
	tempvar prettyfmt
	qui gen str12 `prettyfmt' = ""  /* empty unless `pretty' */
	if `pretty' {
		* make stats 2-N small font
		tempvar st2_row last_st
		quietly {
			gen byte `st2_row' = 0
			replace `st2_row' = (trim(`varname') == "") in `strow1' / `bottomBorder'	 /* only stats 2+ */
			gen byte `last_st' = (`st2_row' & `varname'[_n+1] != "")			 /* last stats row */
			replace `prettyfmt' = "`sa0'" in `strow1' / `bottomBorder'
			replace `prettyfmt' = "`sa_gap'"  if `last_st' in `strow1' / `bottomBorder'
			replace `prettyfmt' = `prettyfmt' + "`fsmed'" if !`st2_row' in `strow1' / `bottomBorder'
			replace `prettyfmt' = `prettyfmt' + "`fssmall'"  if `st2_row' in `strow1' / `bottomBorder'
		}
	}
	
	* create macros with file write contents
	
	forvalues row = `colhead1'/`bottomBorder' { 
		local svarfmt`row' `"(`prettyfmt'[`row']) "\ql " (`varname'[`row']) "\cell""'
		foreach avar of local statvars {
			local svarfmt`row' `"`svarfmt`row''"\qc " (`avar'[`row']) "\cell""' 
		}
		local svarfmt`row' `"`svarfmt`row''"\row" _n"'
	}
	
	* write file
	tempname rtfile
	file open `rtfile' `using', write `replace'
	file write `rtfile' "{\rtf1`fs0'" _n  /* change if not roman: \deff0{\fonttbl{\f0\froman}} */
	
	* title
	if `titleWide' {
		file write `rtfile' "\pard\qc`fslarge'" _n
		forvalues row = 1/`titleWide' {
			file write `rtfile' (`varname'[`row']) "\par" _n
		}
	}
	
	* The top line
	file write `rtfile' "\trowd\trgaph75\trleft-75\intbl\trqc`fsmed'`trbrdrt'`clwidth_ol'" _n
	*file write `rtfile' "\trowd\trgaph75\trleft-75\intbl\trqc`fsmed'`trbrdrt'`clwidth1'" _n
	
	local headBorder_1 = `headBorder' - 1
	* write header rows 1 to N-1
	
	forvalues row = `colhead1'/`headBorder_1' {
		file write `rtfile' `svarfmt`row''
		* turn off the overlining the first time it's run
		file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`clwidth3'" _n
	}
	file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`clwidth2'" _n
	
	* write last header row
	file write `rtfile' `svarfmt`headBorder''

	local bottomBorder_1 = `bottomBorder' - 1
	/* turn off cell underlining */
	file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`clwidth3'" _n
	
	* table contents
	forvalues row = `strow1'/`bottomBorder_1' {
		file write `rtfile' `svarfmt`row''
	}
	
	if `stdborder' {
		/* write last row */
		*file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`trbrdrb'`clwidths'" _n
		* make it underline
		file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`trbrdrb'`clwidth_ul'" _n
		file write `rtfile' `svarfmt`bottomBorder''
	}
	
	/* write notes rows */
	if `bottomBorder' < `totrows' {
		local noterow1 = `bottomBorder' + 1
		file write `rtfile' "\pard\qc`fssmall'" _n
		forvalues row = `noterow1'/`totrows' {
			file write `rtfile' (`varname'[`row']) "\par" _n
		}
	}
	
	* write closing curly bracket
	file write `rtfile' "}"
end  /* end _wordout */


********************************************************************************************


* ripped from outreg2 on Mar2009
program define _xmlout
version 7.0

	versionSet
	version `version'

* emulates the output produced by xmlsave:
* xmlsave myfile, replace doctype(excel) legible

syntax using/ [, excelFile(string) LEGible noNAMes titleWide(integer 0) /*
	*/ headBorder(integer 10) bottomBorder(integer 10)  ]

* assumes all columns are string; if numbers, then the format needs to be checked

*local legible legible

if "`legible'"=="legible" {
	local _n "_n"
}

tempname source saving

if `"`excelFile'"'=="" {
	local endName "xml"
}
else {
	local endName "`excelFile'"
}
	
local save `"`using'.`endName'"'

*file open `source' using `"`using'"', read
file open `saving' using `"`save'"', write text replace

*file write `saving' `"`macval(line)'"'
file write `saving' `"<?xml version="1.0" encoding="US-ASCII" standalone="yes"?>"' `_n'
file write `saving' `"<?mso-application progid="Excel.Sheet"?>"' `_n'
file write `saving' `"<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet""' `_n'
file write `saving' `" xmlns:o="urn:schemas-microsoft-com:office:office""' `_n'
file write `saving' `" xmlns:x="urn:schemas-microsoft-com:office:excel""' `_n'
file write `saving' `" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet""' `_n'
file write `saving' `" xmlns:html="http://www.w3.org/TR/REC-html40">"' `_n'
file write `saving' `"<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">"' `_n'
file write `saving' `"<Author></Author>"' `_n'
file write `saving' `"<LastAuthor></LastAuthor>"' `_n'
file write `saving' `"<Created></Created>"' `_n'
file write `saving' `"<LastSaved></LastSaved>"' `_n'
file write `saving' `"<Company></Company>"' `_n'
file write `saving' `"<Version></Version>"' `_n'
file write `saving' `"</DocumentProperties>"' `_n'
file write `saving' `"<ExcelWorkbook  xmlns="urn:schemas-microsoft-com:office:excel">"' `_n'
file write `saving' `"<ProtectStructure>False</ProtectStructure>"' `_n'
file write `saving' `"<ProtectWindows>False</ProtectWindows>"' `_n'
file write `saving' `"</ExcelWorkbook>"' `_n'
file write `saving' `"<Styles>"' `_n'

* styles
file write `saving' `"<Style ss:ID="Default" ss:Name="Normal">"' `_n'
file write `saving' `"<Alignment ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<Borders/>"' `_n'
file write `saving' `"<Font/>"' `_n'
file write `saving' `"<Interior/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"<Protection/>"' `_n'
file write `saving' `"</Style>"' `_n'

* bold & (center)
file write `saving' `"<Style ss:ID="s1">"' `_n'
*file write `saving' `"<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<Font ss:Bold="1" ss:Size='12'/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"</Style>"' `_n'

* top border & center
file write `saving' `"<Style ss:ID="s21">"' `_n'
file write `saving' `"<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"<Borders>"' `_n'
file write `saving' `"<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>"' `_n'
file write `saving' `"</Borders>"' `_n'
file write `saving' `"</Style>"' `_n'

* main body (no border) & center
file write `saving' `"<Style ss:ID="s22">"' `_n'
file write `saving' `"<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"</Style>"' `_n'

* bottom border & center
file write `saving' `"<Style ss:ID="s23">"' `_n'
file write `saving' `"<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"<Borders>"' `_n'
file write `saving' `"<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>"' `_n'
file write `saving' `"</Borders>"' `_n'
file write `saving' `"</Style>"' `_n'

* goldfish (no border, left-justified)
file write `saving' `"<Style ss:ID="s24">"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"</Style>"' `_n'

* top border
file write `saving' `"<Style ss:ID="s31">"' `_n'
file write `saving' `"<Borders>"' `_n'
file write `saving' `"<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>"' `_n'
file write `saving' `"</Borders>"' `_n'
file write `saving' `"</Style>"' `_n'

* main body (no border)
file write `saving' `"<Style ss:ID="s32">"' `_n'
file write `saving' `"<Borders/>"' `_n'
file write `saving' `"</Style>"' `_n'

* bottom border & center
file write `saving' `"<Style ss:ID="s33">"' `_n'
file write `saving' `"<Borders>"' `_n'
file write `saving' `"<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>"' `_n'
file write `saving' `"</Borders>"' `_n'
file write `saving' `"</Style>"' `_n'

file write `saving' `"</Styles>"' `_n'
file write `saving' `"<Names>"' `_n'
file write `saving' `"</Names>"' `_n'
file write `saving' `"<Worksheet ss:Name="Sheet1">"' `_n'

* set up file size
qui describe, short

local N=_N
local tableN `N'

if "`names'"~="nonames" {
	* add one if variable names are to be inserted
	local tableN=`N'+1
}
else {
	* add one for the look
	local tableN=`N'+1
}

file write `saving' `"<Table ss:ExpandedColumnCount="`r(k)'" ss:ExpandedRowCount="`tableN'""' `_n'
file write `saving' `" x:FullColumns="1" x:FullRows="1">"' `_n'

* should be tostring and format here if dealing with numbers
	
	ds8
	
	* write the variable names at the top or empty row
	if "`names'"~="nonames" {
		file write `saving' `"<Row>"' `_n'
		foreach var in  `dsVarlist' {
			if "`Version7'"~="" {
				file write `saving' `"<Cell ss:StyleID="s1"><Data ss:Type="String">`macval(var)'</Data></Cell>"' _n
			}
			else {
				file write `saving' `"<Cell ss:StyleID="s1"><Data ss:Type="String">`var'</Data></Cell>"' _n				
			}
		}
		file write `saving' `"</Row>"' `_n'
	}
	else {
		file write `saving' `"<Row>"' `_n'
		file write `saving' `"</Row>"' `_n'
	}

* title
local count `titleWide'
local total 1
while `count'~=0 {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`total') n(`N') style(`" ss:StyleID="s1""') style1(`" ss:StyleID="s1""')
	local count=`count'-1
	local total=`total'+1
}

* top border
local count=`total'
forval num=`count'/`count' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s21""') style1(`" ss:StyleID="s31""')
	local total=`total'+1
}

* ctitle
local count=`total'
forval num=`count'/`headBorder' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s22""') style1(`" ss:StyleID="s32""')
	local total=`total'+1
}

* top border (closes ctitle)
local count=`total'
forval num=`count'/`count' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s21""') style1(`" ss:StyleID="s31""')
	local total=`total'+1
}

* body
local count=`total'
forval num=`count'/`=`bottomBorder'-1' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s22""') style1(`" ss:StyleID="s32""')
	local total=`total'+1
}

* bottom border (closes body)
local count=`total'
forval num=`count'/`count' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s23""') style1(`" ss:StyleID="s33""')
	local total=`total'+1
}

* goldfish
if `N'>`total' {
	local count=`total'
	forval num=`count'/`N' {
		xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s24""') style1(`" ss:StyleID="s24""') 
		local total=`total'+1
	}
}

/*
forval num=1/`N' {
	
	file write `saving' `"<Row>"' `_n'
	
	*foreach var in  `=r(varlist)' {
	foreach var in  `dsVarlist' {
		
		*local stuff `=`var'[`num']'
		local stuff=`var' in `num'
		
		local stuff : subinstr local stuff "<" "&lt;", all
		local stuff : subinstr local stuff ">" "&gt;", all
		
		* the main body
		if "`Version7'"~="" {
			file write `saving' `"<Cell`style'><Data ss:Type="String">`macval(stuff)'</Data></Cell>"' `_n'
		}
		else {
			file write `saving' `"<Cell`style'><Data ss:Type="String">`stuff'</Data></Cell>"' `_n'
		}
	}
	file write `saving' `"</Row>"' `_n'
}
*/

file write `saving' `"</Table>"' `_n'
file write `saving' `"<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">"' `_n'
file write `saving' `"<ProtectedObjects>False</ProtectedObjects>"' `_n'
file write `saving' `"<ProtectedScenarios>False</ProtectedScenarios>"' `_n'
file write `saving' `"</WorksheetOptions>"' `_n'
file write `saving' `"</Worksheet>"' `_n'
file write `saving' `"</Workbook>"' `_n'

* close out with the last line
*file write `saving' _n
*file close `source'

file close `saving'

end /* _xmlout */


********************************************************************************************

* ripped from outreg2 on Mar2009
program define xmlstack

syntax, saving(string) dsVarlist(string) num(numlist) n(numlist) style(string) style1(string)

local N `n'

*forval num=1/`N' {
	
	file write `saving' `"<Row>"' `_n'
	
	local count 0
	
	*foreach var in  `=r(varlist)' {
	foreach var in  `dsVarlist' {
		
		if `count'==0 {
			local STYLE `"`style1'"'
		}
		else {
			local STYLE `"`style'"'
		}
		
		*local stuff `=`var'[`num']'
		local stuff=`var' in `num'
		
		local stuff : subinstr local stuff "<" "&lt;", all
		local stuff : subinstr local stuff ">" "&gt;", all
		
		* the main body
		if "`Version7'"~="" {
			file write `saving' `"<Cell`STYLE'><Data ss:Type="String">`macval(stuff)'</Data></Cell>"' `_n'
		}
		else {
			file write `saving' `"<Cell`STYLE'><Data ss:Type="String">`stuff'</Data></Cell>"' `_n'
		}
		
		local count=`count'+1
	}
	file write `saving' `"</Row>"' `_n'
*}

end /* xmlstack */


********************************************************************************************


*** ripped from outreg2 Mar 2009
program define ds8
	* get you the list of variable like -ds- does for version 8
	version 7.0
	qui ds
	if "`r(varlist)'"=="" {
		local dsVarlist ""
		foreach var of varlist _all {
			local dsVarlist "`dsVarlist' `var'"
		}
		c_local dsVarlist `dsVarlist'
	}
	else {
		c_local dsVarlist `r(varlist)'
	}
end


********************************************************************************************


program define stringMaker
	* makes a string out variables
	tempvar temp
	foreach var of varlist _all {
		cap confirm string var `var'
		if _rc {
			* not a string
			gen str2 `temp'=""
			replace  `temp' = string(`var')
			move `var' `temp'
			drop `var'
			ren `temp' `var'
		}
	}
end


********************************************************************************************


* cdout 1.0.1 Apr2009 by roywada@hotmail.com
* opens the current directory for your viewing pleasure

* the following disabled 14oct2009: cap winexec cmd /c start .
* displays "current directory" instead of cdout or the folder location
* displays dir" instead of cdout or the folder location

program define _cdout
cap version 7.0

*cap winexec cmd /c start .
*cap !start cmd /c start .

if _rc~=0 {
        * version 6 or earlier
        di `"{stata `"cdout"':dir}"'
}
else {
        * invisible to Stata 7
        local Version7
        local Version7 `c(stata_version)'
        
        if "`Version7'"=="" {
                * it is version 7 or earlier
                di `"{stata `"cdout"':dir}"'
        }
        else if `Version7'>=8.0 {
                version 8.0
                di `"{browse `"`c(pwd)'"':dir}"'
        }
}

end


********************************************************************************************


* chewfile version 1.0.1 17Aug2009 by roywada@hotmail.com
* quick and easy way to chew and digest excessive large ASCII file

program define _chewfile
version 8.0

syntax using/, [save(string) begin(numlist max=1) end(string) clear parse(string) replace semiclear]

if `"`parse'"'=="" {
        local parse `"`=char(9)'"'
}

if "`begin'"=="" {
        local begin 1
}

if "`end'"=="" {
        local end .
}

if "`clear'"=="" & `"`save'"'=="" {
        if "`semiclear'"=="" {
                noi di in red "must specify {opt clear} or {opt save( )}
                exit 198
        }
}

if "`semiclear'"=="semiclear" {
        qui drop *
        qui set obs 0
}
else if "`clear'"=="clear" {
        clear
        qui set obs 0
}

if `"`save'"'=="" {
        tempfile dump
        local save `dump'
}

tempname fh outout
local linenum = 0
file open `fh' using `"`using'"', read

qui file open `outout' using `"`save'"', write `replace'

file read `fh' line

while r(eof)==0 {
        local linenum = `linenum' + 1
        local addedRow 0
        if `linenum'>=`begin' & `linenum'<=`end' {
                if `addedRow'==0 {
                        qui set obs `=`=_N'+1'
                }
                
                *display %4.0f `linenum' _asis `"`macval(line)'"'
                file write `outout' `"`macval(line)'"' _n
                
                if "`clear'"=="clear" | "`semiclear'"=="semiclear" {
                        tokenize `"`macval(line)'"', parse(`"`parse'"')
                        local num 1
                        local colnum 1
                        while "``num''"~="" {
                                local needOneMore 0
                                if `"``num''"'~=`"`parse'"' {
                                        cap gen str3 var`colnum'=""
                                        cap replace var`colnum'="``num''" in `linenum'
                                        if _rc~=0 {
                                                qui set obs `=`=_N'+1'
                                                cap replace var`colnum'="``num''" in `linenum'
                                                local addedRow 1
                                        }
                                        *local colnum=`colnum'+1
                                }
                                else {
                                        cap gen str3 var`colnum'=""
                                        local colnum=`colnum'+1
                                }
                                local num=`num'+1
                        }
                }
        }
        file read `fh' line
}

file close `fh'
file close `outout'
end


********************************************************************************************


* 03nov2009, ripped from outreg2 on 05nov2009
prog define versionSet
	* sends back the version as c_local
	version 7.0
	
	* invisible to Stata 7
	cap local Version7 `c(stata_version)'
	c_local Version7 `Version7'
	
	if "`Version7'"=="" {
		* it is version 7
		c_local version 7
	}
	else if `Version7'>=8.2 {
		version 8.2
		c_local version 8.2
	}
	
	if "`Version7'"=="" {
		c_local bind ""
	}
	else {
		c_local bind "bind"
	}

end

exit



* version 1.0.1 May2009 logout by roywada@hotmail.com
cap no longer takes off the bottom line
noauto auto( ) dec( ) hooked up
_logfix split into _infix, unfinished
logleft done, not implemented
caplog has correct version control, enabling eret list
value labels handled as proposed by Karl Keesman at sales@survey-design.com.au
fix handles the horizontal lines

*ssc de version 1.0.2 05May2009 logout by roywada@hotmail.com
the bottomline no longer taken off by unwrap function
the horizontal lines starting in the middle handled during delimited routine

* version 1.0.3 14oct2009
fixed the compound quotes for `save'
unwraps correctly (previously left an extra space)
fixcut( ) option
_cdout inserted
_chewfile inserted
range( ) option

* 1.0.4
di before _cdout
nopretty for _texout fixed??
versionSet
error with fixcut( ) rectified
_infix drop vertical lines before horizontal line


needs work:
logout, save(mytable) excel replace: eret list
plus the ":" wipe or not
user specified infix


dataout circa Apr 2009 needs to be replaced with version 1.0.4 07sep2009


