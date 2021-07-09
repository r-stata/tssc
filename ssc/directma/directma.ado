*! 1.0 Nov 13 2017, Zhen Wang, Mohammad Hassan Murad

program define directMA, rclass
version 13.0
#delimit;
	syntax varlist(min=5 max=6 default=none)  [if] [in], [ ///
	or rr rd wmd cohen hedges glass fixed fixedi random randomi peto reml ml pl eb kh forest funnel///
	filename(string)  ///
	];
#delimit cr

tokenize "`varlist'"
args id study trt 

/*check if id is numeric*/
capture confirm numeric variable `id'
if _rc!=0 {
        display as error "You must have a numeric reference id"
		error 110
    }

	
/*make sure only one model option has been selected*/
local cnt = 0
foreach x in `or' `rr' `rd' `cohen' `hedges' `wmd' `glass' {
        if "``x''"!="" local cnt = `cnt' + 1
    }
    if `cnt' == 0 {
        display as error "You must select an outcome measure: or rr rd cohen hedges glass wmd"
        error 110
    }
    else if `cnt'>=2 {
        display as error "Please select only one outcome measure"
        error 110
    }
	
local cnt = 0
foreach x in fixed fixedi random randomi peto reml ml pl eb kh {
        if "``x''"!="" local cnt = `cnt' + 1
    }
    if `cnt' == 0 {
        display as error "You must select a pooling method: fixed fixedi random randomi peto reml ml pl eb kh"
        error 110
    }
    else if `cnt'>=2 {
        display as error "Please select only one method"
        error 110
    }
	
if !mi("`peto'") {
	if mi("`or'") {
		display as error "Please choose or as the outcome measure"
        error 110
		}
	}

if mi("`filename'") {
	display as error "You must enter a file name"
	error 110
	}

tempfile _temp
qui save `_temp'

if `"`if'"'!=""{
	qui keep `if'
	}
if "`in'"!= ""{
	qui keep `in'
	}
keep `varlist'	

qui putexcel set `filename', replace
qui putexcel A1=("Comparison") B1=("Number of Studies") C1=("`or'`rr'`rd'`cohen'`hedges'`glass'`wmd'") D1=("95% Low CI") /*
*/ E1=("95% High CI")  F1=("p value") G1=("I2") H1=("Het p value") I1=("Tau2") J1=("Pooling Method")

tempvar treatment
sort `trt'
egen `treatment'=group(`trt')
qui sum `treatment'
tempname number
scalar `number'=r(max)

tempvar count
by `trt' `treatment', sort: gen `count'=_n
label var `treatment' "new name"

putexcel L1=("Treatment") M1=("Treatment Code")

local maxtrt=`number'

preserve

qui drop  if `count'>1
qui sort `treatment'

forvalues i=1(1)`maxtrt' {
	qui keep if `treatment'==`i'
	local j=`i'+1
	qui putexcel L`j'=(`trt') M`j'=(`treatment')
	local i=`i'+1
	restore, preserve
}

restore, not

drop `count'
drop `trt'

qui reshape wide `4' `5' `6', i(`id') j("`treatment'" )
if !mi("`fixed'`fixedi'`random'`randomi'`peto'"){	
	local row=2	
	local cnt=0
	tempvar ES seES
	foreach x in or rr rd {
        if "``x''"!="" local cnt = `cnt' + 1
    }
	forvalues i=1(1)`maxtrt'{
		local start=`i'+1
		if "`wmd'"!="" {		
			local temp="nostandard"
		}
		forvalues j=`start'(1)`maxtrt' {
		qui display "*******************************************"
		qui display "Treatment `j' compared to Treatment `i'"
		qui display "*******************************************"
		if `cnt' == 1 {   
			qui count if `4'`j'!=. & `5'`j'!=. & `4'`i'!=. & `5'`i'!=.
			if r(N)>0 {
				if !mi("`forest'") {
					capture metan `4'`j' `5'`j' `4'`i' `5'`i', `or' `rr' `rd' `peto' `fixed' `fixedi' `random' `randomi'  lcols(`study') astext(70)
					capture graph export trt`j'_trt`i'.wmf, replace
					capture graph close
				}
				else if mi("`forest'") {
					capture metan `4'`j' `5'`j' `4'`i' `5'`i', `or' `rr' `rd' `peto' `fixed' `fixedi' `random' `randomi' nograph
				}
				capture gen `ES'=log(_ES)
				capture gen `seES'=_selogES				
				if r(df)>0 & r(df)!=. {	
					capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(r(df)+1) C`row'=(r(ES)) D`row'=(r(ci_low)) E`row'=(r(ci_upp)) /* 
					*/ F`row'=(r(p_z)) G`row'=(r(i_sq)) H`row'=(r(p_het)) I`row'=(r(tau2)) J`row'=("`fixed' `fixedi' `random' `randomi'")
					}
				if r(df)==0 {
					capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(r(df)+1) C`row'=(r(ES)) D`row'=(r(ci_low)) E`row'=(r(ci_upp)) /* 
					*/ F`row'=(r(p_z)) J`row'=("`fixed' `fixedi' `random' `randomi'")
					}
				if r(df)>=9 & !mi("`funnel'") {
					capture metafunnel `ES' `seES', eform
					capture graph export funnel_trt`j'_trt`i'.wmf, replace
					capture graph close
					}	
				}
			else if r(N)==0 {
				capture putexcel  A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(r(N))
				}	
			}
		else { 
			qui count if `4'`j'!=. & `5'`j'!=. &`6'`j'!=. & `4'`i'!=. & `5'`i'!=. & `6'`i'!=.
			if r(N)>0 {
				if !mi("`forest'") {
					capture metan `4'`j' `5'`j' `6'`j' `4'`i' `5'`i' `6'`i', `fixed'  `random' `cohen' `hedges' `glass' `temp' lcols(`study') astext(70)
					capture graph export trt`j'_trt`i'.wmf, replace
					capture graph close	
				}
				else if mi("`forest'") {
					capture metan `4'`j' `5'`j' `6'`j' `4'`i' `5'`i' `6'`i', `fixed'  `random' `cohen' `hedges' `glass' `temp' nograph 
				}
				capture gen `ES'=_ES
				capture gen `seES'=_seES	
				if r(df)>0 & r(df)!=. {	
					capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(r(df)+1) C`row'=(r(ES)) D`row'=(r(ci_low)) E`row'=(r(ci_upp)) /* 
					*/ F`row'=(r(p_z)) G`row'=(r(i_sq)) H`row'=(r(p_het)) I`row'=(r(tau2)) J`row'=("`fixed' `random' `cohen' `hedges' `glass' `temp'")
					}
				if r(df)==0 {
					capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(r(df)+1) C`row'=(r(ES)) D`row'=(r(ci_low)) E`row'=(r(ci_upp)) /* 
					*/ F`row'=(r(p_z)) J`row'=("`fixed' `random' `cohen' `hedges' `glass' `temp'") 
					}			
				}
			else if r(N)==0 {
				capture putexcel  A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(r(N)) 
				}
			if r(df)>=9 & !mi("`funnel'") {
				capture metafunnel `ES' `seES'
				capture graph export funnel_trt`j'_trt`i'.wmf, replace
				capture graph close
				}					
		}		
		local row=`row'+1
		local j=`j'+1
		}
	local i=`i'+1
	local row=`row'+1
	}
}

else if !mi("`reml'`ml'`pl'"){
	local row=2	
	local cnt=0
	tempvar ES seES
	foreach x in or rr rd {
        if "``x''"!="" local cnt = `cnt' + 1
    }
	forvalues i=1(1)`maxtrt'{
		local start=`i'+1
		if "`wmd'"!="" {		
			local temp="nostandard"
		}
		forvalues j=`start'(1)`maxtrt' {
		qui display "*******************************************"
		qui display "Treatment `j' compared to Treatment `i'"
		qui display "*******************************************"
		if `cnt' == 1 {   
			qui count if `4'`j'!=. & `5'`j'!=. &`4'`i'!=. & `5'`i'!=.
			if r(N)>0 {
				capture metan `4'`j' `5'`j' `4'`i' `5'`i', `or' `rr' `rd' nooverall nograph 
				capture gen `ES'=log(_ES)
				capture gen `seES'=_selogES
				if r(df)>0 & r(df)!=. {
					if mi("`forest'") {
						capture metaan `ES' `seES', `reml' `ml' `pl'
					}
					else if !mi("`forest'") {
						capture metaan `ES' `seES', `reml' `ml' `pl' forest astext(70) label(`study')
						capture graph export trt`j'_trt`i'.wmf, replace
						capture graph close	
					}
					local expeff=exp(r(eff))
					local expefflo=exp(r(efflo))
					local expeffup=exp(r(effup))
					local zscore=abs(r(eff))/(sqrt(r(effvar))) 
					local pvalue=normprob(-abs(`zscore'))*2
					capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(r(df)+1) C`row'=(`expeff') D`row'=(`expefflo') /*
					*/ E`row'=(`expeffup') F`row'=(`pvalue') G`row'=(r(Isq)) H`row'=(r(Qpval)) I`row'=(r(tausq_dl)) J`row'=("`reml'`ml'`pl'")			
					if !mi("`pl'"){
						capture putexcel F`row'=("")
						}
					}
				else if r(df)==0 {
					capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(1) C`row'=(r(ES)) D`row'=(r(ci_low)) /*
					*/ E`row'=(r(ci_upp)) F`row'=(r(p_z))	
					}	
				}	
			else if r(N)==0 {
				capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(r(N))					
				}
			if r(df)>=9 & !mi("`funnel'") {
				capture metafunnel `ES' `seES', eform
				capture graph export funnel_trt`j'_trt`i'.wmf, replace
				capture graph close
				}
			}
			else {
			qui count if `4'`j'!=. & `5'`j'!=. & `6'`j'!=. &`4'`i'!=. & `5'`i'!=. & `6'`i'!=.
			if r(N)>0 {
				capture metan `4'`j' `5'`j' `6'`j' `4'`i' `5'`i' `6'`i', `cohen' `hedges' `glass' `temp' nooverall nograph 
				capture gen `ES'=_ES
				capture gen `seES'=_seES
				if r(df)>0 & r(df)!=. { 	
					if mi("`forest'") {
						capture metaan `ES' `seES', `reml' `ml' `pl'
					}
					else if !mi("`forest'") {
						capture metaan `ES' `seES', `reml' `ml' `pl' forest astext(70) label(`study')
						capture graph export trt`j'_trt`i'.wmf, replace
						capture graph close	
					}											
					local zscore=abs(r(eff))/(sqrt(r(effvar))) 
					local pvalue=normprob(-abs(`zscore'))*2
					capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(r(df)+1) C`row'=(r(eff)) D`row'=(r(efflo)) /*
					*/ E`row'=(r(effup)) F`row'=(`pvalue') G`row'=(r(Isq)) H`row'=(r(Qpval)) I`row'=(r(tausq_dl)) J`row'=("`reml'`ml'`pl'")
					if !mi("`pl'"){
						capture putexcel F`row'=("")
						}
					}
				else if r(df)==0 {
					capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(1) C`row'=(r(ES)) D`row'=(r(ci_low)) /*
					*/ E`row'=(r(ci_upp)) F`row'=(r(p_z))	
					}		
				}
			else if r(N)==0 {
				capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(r(N))		
				}
			if r(df)>=9 & !mi("`funnel'") {
				capture metafunnel `ES' `seES'
				capture graph export funnel_trt`j'_trt`i'.wmf, replace
				capture graph close
				}				
			}	
		local row=`row'+1
		local j=`j'+1
		capture drop `ES' `seES'
		}
	local i=`i'+1
	local row=`row'+1
	}
}

else if !mi("`eb'`kh'"){
	local row=2	
	local cnt=0
	tempvar ES seES
	foreach x in or rr rd {
        if "``x''"!="" local cnt = `cnt' + 1
    }
	forvalues i=1(1)`maxtrt'{
		local start=`i'+1
		if "`wmd'"!="" {		
			local temp="nostandard"
		}
		forvalues j=`start'(1)`maxtrt' {
		qui display "*******************************************"
		qui display "Treatment `j' compared to Treatment `i'"
		qui display "*******************************************"
		if `cnt' == 1 {   
			capture metan `4'`j' `5'`j' `4'`i' `5'`i', `or' `rr' `rd' nooverall nograph
			qui gen `ES'=log(_ES)
			qui gen `seES'=_selogES
			if r(df)>=9 & !mi("`funnel'") {
				capture metafunnel `ES' `seES'
				capture graph export funnel_trt`j'_trt`i'.wmf, replace
				capture graph close
				}
			if r(df)>0 & r(df)!=. { 
				capture metareg `ES', wsse(`seES') `eb' eform
				tempname result eff efflo effup pvalue
				matrix `result'=r(table)
				scalar `eff'=`result'[1,1]
				scalar `efflo'=`result'[5,1]
				scalar `effup'=`result'[6,1]
				scalar `pvalue'=`result'[4,1]
				capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(e(N)) C`row'=(`eff') D`row'=(`efflo') /*
				*/ E`row'=(`effup') F`row'=(`pvalue') G`row'=(e(I2)) H`row'=(e(Q)) I`row'=(e(tau2)) J`row'=("`eb' `kh'")
				matrix drop _all
				drop `ES' `seES'
				scalar drop `eff' `efflo' `effup' `pvalue'
				}
			else if r(df)==0 {
				capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(1) C`row'=(r(ES)) D`row'=(r(ci_low)) /*
				*/ E`row'=(r(ci_upp)) F`row'=(r(p_z)) 
				drop `ES' `seES'
				}
			else {
				capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(0) 
				drop `ES' `seES'
				}
			}
		else {
			capture metan `4'`j' `5'`j' `6'`j' `4'`i' `5'`i' `6'`i', `cohen' `hedges' `glass' `temp' nooverall nograph 
			qui gen `ES'=_ES
			qui gen `seES'=_seES
			if r(df)>=9 & !mi("`funnel'") {
				capture metafunnel `ES' `seES'
				capture graph export funnel_trt`j'_trt`i'.wmf, replace
				capture graph close
				}
			if r(df)>0 & r(df)!=. { 
				capture metareg `ES', wsse(`seES') `eb' 
				tempname result eff efflo effup pvalue
				matrix `result'=r(table)
				scalar `eff'=`result'[1,1]
				scalar `efflo'=`result'[5,1]
				scalar `effup'=`result'[6,1]
				scalar `pvalue'=`result'[4,1]
				capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(e(N)) C`row'=(`eff') D`row'=(`efflo') /*
				*/ E`row'=(`effup') F`row'=(`pvalue') G`row'=(e(I2)) H`row'=(e(Q)) I`row'=(e(tau2)) J`row'=("`eb' `kh'")
				matrix drop _all
				drop `ES' `seES'
				scalar drop `eff' `efflo' `effup' `pvalue'
				}
			else if r(df)==0 {
				capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(1) C`row'=(r(ES)) D`row'=(r(ci_low)) /*
				*/ E`row'=(r(ci_upp)) F`row'=(r(p_z))
				drop `ES' `seES'
				}
			else {
				capture putexcel A`row'=("Treatment `j' compared to Treatment `i'") B`row'=(0)
				drop `ES' `seES'
				}
			}	
		local row=`row'+1
		local j=`j'+1
		}
	local i=`i'+1
	local row=`row'+1
	}
}

display "Calculation completed successfully!"	
	
use `_temp', clear
end

	




