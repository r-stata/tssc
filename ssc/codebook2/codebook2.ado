*! version 2.0  28MAR2005
prog drop _all
program define codebook2
	version 8
	syntax  [anything] [using/]  [, Header Type(string)]
 
 	local varlist="`anything'"
     
     mac drop appx sortorder sortvar

     if  "`type'" != "" | "`header'" != "" {
        local opt = ","
     }
     if "`type'" != ""{
        local tt = "t(`type')"
     }
	if "`using'" != ""{
	   preserve
	   *clear
	   if "`varlist'" != ""{
		   use `varlist' using "`using'" , clear
	   }
	   if "`varlist'" == ""{
		   use "`using'",clear
	   }
	   codeb `varlist' `opt' `header' `tt'
	}
     else{
         codeb `varlist'  `opt' `header' `tt'
     }
end
 
program define codeb	
	syntax  [varlist]  [, Header Type(string)]
	
 
	local origorder : sortedby
	if "`origorder'" == "" {
		tempvar originalsort
		gen `originalsort' = _n
		global sortorder `originalsort'
		if "`using'" == ""{
			global sortvar "UNDETERMINED"
		}
		if "`using'" != ""{
			global sortvar "NOT SORTED"
		}
		
		sort $sortorder
	}
	else {
		global sortorder "`origorder'"
		global sortvar "`origorder'"
	}

	if "`header'" != "" {
		Header
	}

	foreach v of local varlist {
		local vallab : value label `v'
		local varlab : var label `v'
		local stor   : type `v'
		local fmt    : format `v'
		if "`stor'" == "byte" | "`stor'" == "float" | "`stor'" == "int" | /*
		  */ "`stor'" == "long" | "`stor'" == "double" {
		  local an "numeric"
		}
		else { 
		  local an "alphanumeric" 
		}
		if "`vallab'" == "" { 
		  local vallab "none" 
		}

		sort $sortorder

		if  "`type'" != "" {
		 
			local typ_t= "``v'[typ]'"
			char `v'[typ]
			char `v'[typ] "`type'" 
		}

		varhead `v' `vallab'  `an' `fmt' "`varlab'"

		if "``v'[typ]'" == "disc"{
			disc `v' `vallab' `an' `fmt'
		}
		if "``v'[typ]'" == "cont"{
			cont `v' `vallab'
		}
		if "``v'[typ]'" == "date"{
			dodate `v' `vallab' `fmt'
		}
		if "``v'[typ]'" == "id"{
			id `v' 
		}
		if "``v'[typ]'" == "ord"{
			cont `v' `vallab' 
		}
		if "``v'[typ]'" == "appx"{
			global appx $appx `v' 
		}

		if  "`type'" != "" { 
			char `v'[typ]
			char `v'[typ] "`typ_t'" 
		}
	}
 	local duhd : word 1 of $appx

	foreach vvv in $appx{
		if "`vvv'" == "`duhd'"{
			di in gr "{hline 80}"
			di
			di _col(25) in ye "APPENDIX"
			di
		}
  		appx `vvv' `an' `fmt'
 	}
end
 
program define Piece
	args color col len str
	local pcs = int(length(`"`str'"')/`len')
	local pcsa =length(`"`str'"')/`len'
	local npcs =`pcsa'-`pcs'
	if `npcs'!=0{
	  local pcs = `pcs' +1
	}
	if `pcs' == 1{
		local piece : piece 1 `len' of `"`str'"'
		di in `color' `"`piece'"' _c
	}
	else{
		forvalues i=1/`pcs'{
			if `i' == 1{
				local piece : piece `i' `len' of `"`str'"'
				di in `color'  `"`piece'"'   
			}
			if `i' < `pcs' & `i' > 1 {
				local piece : piece `i' `len' of `"`str'"'
				di in `color' _col(`col') `"`piece'"'  
			}
			if `i' == `pcs'{
				local piece : piece `i' `len' of `"`str'"' 
				di in `color' _col(`col') `"`piece'"'  _c
			}
		}
	}
end


program define Header
	syntax [, Notes]
	di
 
	di in gr _col(16) "Dataset:  " _c
	if `"$S_FN"'=="" { 
		di in gr "[no name]"
	}
	else{
		di in ye `"$S_FN"'
	}

	di in gr _col(13) "Last saved:  " _c
	if `"$S_FN"'=="" {
		di in gr "never"
	}
	else if `"$S_FNDATE"'=="" {
		di in gr "unknown"
	}
	else{
		tempvar saveddate
		gen str15 `saveddate' = subinstr(`"$S_FNDATE"'," ","",2)
		/*di in ye `"$S_FNDATE"'*/
		di in ye `saveddate'

		if `"$S_FN"'!="" {
			qui des, short
			if r(changed) {
				di in gr _col(28) "DATA HAVE CHANGED SINCE LAST SAVED"
			}
		}
	}
		local x : data label
		if `"`x'"'=="" {
			local x " "
		}
		di in gr _col(18) "Label:  " in ye `"`x'"'
 
		capture memory
		if _rc {
			if _rc==1 { 
				exit 1 
			}
			local ptrsize 4
		}
		else	local ptrsize = r(size_ptr)
		qui desc, short
		di _col(4) in gr "Number of variables:  " /*
			*/ in ye trim(string(r(k),"%16.0gc"))
		di _col(1) in gr "Number of observations:  " /*
		*/ in ye trim(string(r(N),"%16.0gc"))
		di _col(14) in gr "Sorted By:" in ye _col(26) "$sortvar"
 
		if "`_dta[note0]'" != "" {
			di _col(18) in gr "Notes: " _c 
			forvalues i = 1/ `_dta[note0]' {
				di _col(26) in ye "`_dta[note`i']'"
			}
		} 
		tempvar todaytime todaydate
		gen str5 `todaytime' = substr(`"$S_TIME"',1,5)  
		gen str10 `todaydate' = subinstr(`"$S_DATE"'," ","",.)
		di _col(4) in gr "Codebook Created On:  " in ye `todaydate' " " `todaytime' 
 
end


program define varhead
   args v vallab an fmt varlab 
      local fmt: format `v'
 	local fmta = "%-"+substr("`fmt'",2,.)
	*local fmta = destring `v', i("% - . s") 
	di in gr "{hline 80}"
	*di in red "fmta=`fmta'"
	
	if `"`varlab'"'=="" { 
	   local varlab " " 
	}
	if length(`"`varlab'"')<=40 {
		local l = 77-length(`"`v'"')-length(`"`varlab'"')
		di _col(10) in gr "variable name:  " in ye `"`v' "'
		di _col(9)  in gr "variable label:  "  in ye `"`varlab'"'
	}
	else {
		local l = 77-length(`"`v'"')-40
		di _col(10) in gr "variable name:  " in ye `"`v' "'  
		di _col(9)  in gr "variable label:  "  in ye _c 
		Piece yellow 26 50 `"`varlab'"'
	}
	di
	di _col(19) in gr "type:  " in ye "`an'"
	*di _col(12) in gr "value label:  " in ye `"`vallab'"' 

	if "`an'"=="numeric" & "``v'[typ]'"!="date"{
		quietly sum `v'
		*di _col(18) in gr "range:  " in ye `fmta' r(min) in gr "  to " in ye `fmta' r(max) 
		di _col(18) in gr "range:  " in ye  r(min) in gr "  to " in ye `fmta' r(max) 
	}

	tempvar cnt
	quietly {
		sort `v'
		by `v': gen long `cnt'=1 if _n==1
		replace `cnt'=sum(`cnt')
		local uniq=`cnt'[_N]
		count if missing(`v')
		local miss=r(N)
		local uniq=`uniq'-(r(N)!=0)
		drop `cnt'
		sort $sortorder
		}

	di in gr _col(10) "unique values:  " in ye `"`uniq'"'
	di in gr _col(12) in gr "missing obs:  " in ye `miss' 

	if "``v'[note0]'" != "" {
		di _col(18) in gr "notes:  " _c 
		forvalues i = 1/ ``v'[note0]' {
			di _col(26)  in ye "``v'[note`i']'"
		}
	}
	if "``v'[typ]'" == "appx"{
		di _col(26) in ye "The list of values for this variable is in the Appendix"
	} 
end


program define disc 
	args v vallab an fmt
 
	local bigN =_N
 
	preserve
 
	tempfile allfreqs 
	contract `v'
	rename `v' value
	quietly gen pct = (_freq/`bigN')*100
	sort value
	quietly save `"`allfreqs'"'



	if `"`vallab'"' != "none" {
	tempfile labelfile
	quietly uselabel `vallab',clear  
		quietly {
		keep if lname=="`vallab'"
		local Nl = _N
		sort value
		merge value using "`allfreqs'"
		quietly compress
		gsort -lname value
		} 
		*end quietly
 
		local NN=_N
		local lblfmt : format label
		local valfmt : format value
		local frfmt  : format _freq
 
		tempvar l lab vv val f fmt totfreq
		gen str8 `lab' = `"`lblfmt'"'
		quietly destring `lab', i("s f g %") gen(`l')
		*local lf=`l'+6+26
		local lf=30+15
		local l=`lf'+5
 
		quietly gen str8 `val' = `"`valfmt'"'
		quietly destring `val', i("s f g %") gen(`vv')
		local vf=`vv'+5 + `lf' 
		local vv=`vf'+8
		quietly replace _freq=0 if _freq==.
		quietly gen `totfreq'=sum(_freq)
		di
		di in gr _col(13) "tabulation:  " 
		di in gr _col(13) "Label" _col(`l')  "Value" _col(`vv') "Freq" 
		local nl = 0
		forvalues i=1/`NN'{ 
			if length(label[`i'])<=25 {
				di _col(13)  in ye  label[`i']  _col(`lf') `valfmt' value[`i'] _col(`vf') `frfmt'  _freq[`i']
			}
			else {
				local k = label[`i']
				di _col(13) as txt _c 
				Piece yellow 15 30 "`k'"

				di in ye _col(`lf') `valfmt' value[`i'] _c
				di in ye _col(`vf') `frfmt'  _freq[`i']
			}

			local l2=`l'-2
			if _merge[`i'] == 2 {
				local nl = `nl' + 1
			}
			if `i' == `NN'{
				di
				di  in gr _col(13) "Total"   _col(`vf') `frfmt' `totfreq'[`i']
			}
			local i=`i'+1
		}
		di
		di in ye _col(13) "There are `nl' non-labeled values."		
	}
	else{
 
		local NN=_N
		local N=_N
		local valfmt : format value
		local frfmt : format _freq
		tempvar  vv val f  totfreq 
		gen str8 `val' = `"`valfmt'"'
		quietly destring `val', i("- c s f g %") gen(`vv')
		local vf=int(`vv'/2)+10
		quietly replace _freq=0 if _freq==.
		quietly gen `totfreq'=sum(_freq)
		di
		di in gr _col(13) "tabulation:  "  
		local NN =_N
		if "`an'" == "numeric"{
			local vv=`vf'+5+`vv'
			di in gr  _col(13)    "Value" _col(`vv') "Freq" 
			forvalues i=1/`NN'{
				di _col(13)  in ye `fmt' value[`i']  _col(`vf') `frfmt' _freq[`i']
				if `i'==`NN' {
					local l2=`vv'-8
					di
					di in gr _col(13) "Total"   _col(`l2') `frfmt' `totfreq'[`i'] 
				} 
			local i=`i'+1
			}
		}
		else{
		di in gr  _col(13)    "Value" _col(53) "Freq" 
		forvalues i=1/`NN'{
			if length(value[`i'])<25 {
			local ll =length(value[`i'])
				local l = 77-length(`"`v'"')-length(`"`value[`i']'"')
				di _col(13)  in ye value[`i']  _col(45) `frfmt' _freq[`i']
			}
			else {
				local l = 77-length(`"`v'"')-40
				local k = value[`i']
				di _col(13) as txt _c 
				Piece yellow 15 30 "`k'"
				di in ye _col(45) `frfmt'  _freq[`i']
			}
			if `i'==`NN' {
				local l2=`vv'-2
				di
				di in gr _col(13) "Total"   _col(45) `frfmt' `totfreq'[`i'] 
			} 
		local i=`i'+1
		}
		}
		di
		di in ye _col(26) "There are no labeled values."
	}
di
restore
sort $sortorder
end


program define cont
	args v vallab stor 
	local tabvar `v'
 	local fmt: format `v'
 	local fmta = "%-"+substr("`fmt'",2,.)
 	
	tempvar decode 	 
	capture decode `v', gen(`decode')
	if _rc { 
		di in gr " "
	}
	else {
		local tabvar `"`decode'"'
		sort `v'
		tempvar cnt
		qui by `v': gen byte `cnt'=1 if _n==1 & `v'!=. & `decode'==""
		drop `cnt'
	}

	tempvar cnt first
	sort `v'
	quietly by `v': gen long `cnt'=_N
	quietly by `v': gen byte `first'=1 if _n==1
	sort `first' `v' 
	 
if "``v'[typ]'" != "ord" { 
	if `"`vallab'"'=="none"  {
		qui sum `v'  , detail
	}
	if `"`vallab'"'!="none" {
		tempvar llist
		capture decode `v', g(`llist') maxlength(2)
		*l state sumpop `llist'
		* sum `v' if length(`llist')<1, detail
		 qui sum `v' , detail
	}
}
 
if "``v'[typ]'" == "ord" { 
		qui sum `v'  , detail
}
	if ("`r(mean)'" != "" & "``v'[typ]'" != "disc"){
          local skip = length(string(r(mean)))+3
		di 
		if `"`vallab'"'=="none"{
  			di in gr _col(8) "non-missing obs:" in ye _col(26)  `fmta' r(N)  
  		}
		if `"`vallab'"'!="none"{
  			di in gr _col(8) "non-missing obs:" in ye _col(26)  `fmta' r(N)  
  		}
  		
		di in gr _col(19) "mean:" in ye _col(26) `fmta' r(mean) 
		di in gr _col(17) "median:" in ye _col(26) `fmta' r(p50) 
		di in gr _col(14) "std. dev.:" in ye /*
			*/ _col(26) `fmta' sqrt(r(Var)) 
		
		if "``v'[typ]'" == "ord" & `"`tabvar'"'!=`"`v'"' & `"`vallab'"'!="none" {
			local tabvar `"`decode'"'
			sort `v'
			tempvar cnt
			qui by `v': gen byte `cnt'=1 /*
				*/ if _n==1 & `v'!=. & `decode'!=""
			qui sum `cnt', meanonly 
			if r(sum) { 
				disc  `v' `vallab'
			}
		} /*end if tabvar*/
 	} /*end if r(mean)*/
	capture drop `decode' 
	sort $sortorder 
end


program define id
	args v 

	sort $sortorder
	di
	di in gr _col(15) "examples:  Obs    Value" 
 
	di in ye _col(27)   "1" _c
		local x = `v'[1]
		di _col(35)  `fmt' `"`x'"'
 
	di in ye _col(27)  int(.2*_N) _c
		local x = `v'[int(.2*_N)]
		di _col(35)  `fmt' `"`x'"'
 
	di in ye _col(27)  int(.4*_N) _c
		local x = `v'[int(.4*_N)]
		di _col(35)  `fmt' `"`x'"'

	di in ye _col(27)   int(.6*_N) _c
		local x = `v'[int(.6*_N)]
		di _col(35)  `fmt' `"`x'"'

	di in ye _col(27)  int(.8*_N) _c
		local x = `v'[int(.8*_N)]
		di _col(35)  `fmt' `"`x'"'

	di in ye _col(27)   _N _c
		local x = `v'[_N]
		di _col(35) `fmt' `"`x'"'

	quietly capture{ 
	      
		capture count if substr(`v',1,1)==" "
		if r(N) { 
			local haslead 1 
			local ttl "leading"
		}
		else 	local haslead 0
		capture count if substr(`v',-1,1)==" "
		if r(N) { 
			local hastrai 1 
			local ttl "trailing"		}
		else 	local hastrai 0
		if `haslead' | `hastrai' {
			tempvar clean
			gen `type' `clean'=trim(`v')
			capture assert index(`clean'," ")==0
			drop `clean'
		}
		else	capture assert index(`v'," ")==0
		if _rc { 
			local hasem 1 
			local ttl "embedded"
			}
		else 	local hasem 0
	 
	
	 if `haslead' + `hastrai' + `hasem' >= 2 {
		if `haslead' & `hastrai' & `hasem' {
			local ttl "leading, embedded, and trailing"
		}
		else if `haslead' & `hastrai' {
			local ttl "leading and trailing"
		}
		else if `haslead' & `hasem' { 
			local ttl "leading and embedded"
		}
		else	local ttl "embedded and trialing"
	}
	 if `haslead' | `hastrai' | `hasem' {
		di _n in gr _col(16) "warning:  variable has `ttl' blanks"
	}
	sort $sortorder
end


program define dodate
	args v vallab fmt

	local ch1 = substr(`"`fmt'"',2,1)
	local ch2 = substr(`"`fmt'"',3,1)
	if `"`ch1'"'=="d" {
		local ch1 "t"
		local ch2 "d"
	}
	if `"`ch2'"'=="d" {
		local desc "daily"
		local udesc "days"
	}
	else if `"`ch2'"'=="w" {
		local desc "weekly"
		local udesc "weeks"
	}
	else if `"`ch2'"'=="m" {
		local desc "monthly"
		local udesc "months"
	}
	else if `"`ch2'"'=="q" {
		local desc "quarterly"
		local udesc "quarters"
	}
	else if `"`ch2'"'=="h" {
		local desc "halfyearly"
		local udesc "half years"
	}
	else if `"`ch2'"'=="y" {
		local desc "yearly"
		local udesc "years"
	}

	local bfmt "%t`ch2'"
	quietly sum `v',d
	di
	di _col(18) in gr "range:  " in ye r(min) /*
		*/ in gr " - " in ye r(max)
		di _col(21) in gr "or:  " in ye /*
		*/ trim(string(r(min),"`bfmt'")) in gr " - " in ye /*
		*/ trim(string(r(max),"`bfmt'")) in gr "" 
	qui sum `v', detail
	
	di in gr _col(17) "median:" _col(26) in ye trim(string(r(p50),"`bfmt'")) 
		
	tempvar datemode
	quietly egen `datemode'=mode(`v')
	di in gr _col(19) "mode:"  _col(26) in ye  trim(string(`datemode',"`bfmt'"))
	capture drop `decode' `datemode'

end

program define appx
	args v an fmt
 	local varlab : var lab `v'
 	local vallab : val lab `v'
	local valfmt : format `v'
	di in gr "{hline 80}"
 	di "Code list for variable" in ye " `v': `varlab'
 	
	local bigN =_N
 
	preserve
 
	tempfile allfreqs 
	contract `v'
	rename `v' value
	quietly gen pct = (_freq/`bigN')*100
	sort value
	quietly save `"`allfreqs'"'

	if `"`vallab'"' != "" {
	tempfile labelfile
	quietly uselabel `vallab',clear  
		quietly {
		keep if lname=="`vallab'"
		local Nl = _N
		sort value
		merge value using "`allfreqs'"
		quietly compress
		gsort -lname value
		} 
		*end quietly
 
		local NN=_N
		local lblfmt : format label
		local valfmt : format value
		local frfmt  : format _freq

		tempvar l lab vv val f fmt totfreq
		gen str8 `lab' = `"`lblfmt'"'
		quietly destring `lab', i("s f g %") gen(`l')
		*local lf=`l'+6+26
		local lf=30+15
		local l=`lf'+5
 
		quietly gen str8 `val' = `"`valfmt'"'
		quietly destring `val', i("s f g %") gen(`vv')
		local vf=`vv'+5 + `lf' 
		local vv=`vf'+8
		quietly replace _freq=0 if _freq==.
		quietly gen `totfreq'=sum(_freq)
		di
		di in gr _col(13) "tabulation:  " 
		di in gr _col(13) "Label" _col(`l')  "Value" _col(`vv') "Freq" 
		local nl = 0
		forvalues i=1/`NN'{ 
			if length(label[`i'])<=25 {
				di _col(13)  in ye label[`i']  _col(`lf') `valfmt' value[`i'] _col(`vf') `frfmt'  _freq[`i']
			}
			else {
				local k = label[`i']
				di _col(13) as txt _c 
				Piece yellow 15 30 "`k'"

				di in ye _col(`lf') `valfmt' value[`i'] _c
				di in ye _col(`vf') `frfmt'  _freq[`i']
			}
			local l2=`l'-2
			if _merge[`i'] == 2 {
				local nl = `nl' + 1
			}
			if `i' == `NN'{
				di
				di  in gr _col(13) "Total"   _col(`vf') `frfmt' `totfreq'[`i']
			}
			local i=`i'+1
		}
		di
		di in ye _col(13) "There are `nl' non-labeled values."		
	}
	else{
 
		local NN=_N
		local N=_N
		local valfmt : format value
		local frfmt : format _freq
		tempvar  vv val f  totfreq 
		gen str8 `val' = `"`valfmt'"'
		quietly destring `val', i("- c s f g %") gen(`vv')
		local vf=int(`vv'/2)+10
		quietly replace _freq=0 if _freq==.
		quietly gen `totfreq'=sum(_freq)
		di
 
		local NN =_N
		if "`an'" == "numeric"{
			local vv =`vf'+5+`vv'
			di in gr  _col(13)  "Value" _col(`vv') "Freq" 
			forvalues i=1/`NN'{
				di _col(13)  in ye `fmt' value[`i']  _col(`vf') `frfmt' _freq[`i']
				if `i'==`NN' {
					local l2=`vv'-8
					di
					di in gr _col(13) "Total"   _col(`l2') `frfmt' `totfreq'[`i'] 
				} 
			local i=`i'+1
			}
		}
		else{
		di in gr  _col(13)  "Value" _col(53) "Freq" 
		forvalues i=1/`NN'{
			if length(value[`i'])<=25 {
				local l = 77-length(`"`v'"')-length(`"`value[`i']'"')
				di _col(13)  in ye value[`i']  _col(45) `frfmt' _freq[`i']
			}
			else {
				local l = 77-length(`"`v'"')-40
				local k = value[`i']
				di _col(13) as txt _c 
				Piece yellow 15 30 "`k'"

				di in ye _col(45) `frfmt'  _freq[`i']
			}
			if `i'==`NN' {
				local l2=`vv'-2
				di
				di in gr _col(13) "Total"   _col(45) `frfmt' `totfreq'[`i'] 
			} 
		local i=`i'+1
		}
		}
		di
		di in ye _col(26) "There are no labeled values."
	}
di
restore
sort $sortorder
 
end
