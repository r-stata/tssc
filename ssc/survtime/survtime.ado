*! version 3  Allen Buxton June 2002 /* add origin capacity, change integer to long */ 
*! version 2  Allen Buxton January 2002 
*! add labels to event and censor variables

program define survtime
 
	version 7.0

	syntax [if] [in],Events(varlist) Censors(varlist) [Origin(varlist)] [Generate(string)] [Addone] [Sequenced_events]

	marksample touse
	qui count if `touse'
	if r(N)==0 { error 2000 } 

	local evntlst `"`events'"'
	local censlst `"`censors'"'
	local org `"`origin'"'
	local gen `"`generate'"'

	tokenize `evntlst'
	local evnt_n : word count `evntlst'
	if `evnt_n' == 1 {local singleevent=1}
		else if `evnt_n' > 1 {local singleevent=0}

	tokenize `censlst'
	local cens_n : word count `censlst'
	if `cens_n' == 1 {local singlecensor=1}
		else if `cens_n' > 1 {local singlecensor=0}

	tokenize `gen'
	local wc1 : word count `gen'
	if `wc1' { 
			if `wc1' != 1 { error 198 }
			confirm new var `1'
			confirm new var `1'_d
			local evnt1 `"`1'"'
			local date1 `"`1'_d"'
			local nsave 1		
		}
	else { local nsave 0 }

	if `"`sequenced_events'"'==`"sequenced_events"' { 
		local sqevents 1		
		}
	else { local sqevents 0 }

	if `nsave'==0 {
		capture drop event_i
		capture drop event_d
		confirm new var event_i
		confirm new var event_d
		local evnt1 `"event_i"'
		local date1 `"event_d"'
	}

	tokenize `org'
	local wc1 : word count `org'
	if `wc1' { 
			if `wc1' != 1 { error 198 }
			local useorigin 1		
		}
	else { local useorigin 0 }

	if `"`addone'"'==`"addone"' { 
		local add1 1		
		}
	else { local add1 0 }

	if `useorigin'==1 | `add1'==1 {
		local usedays 1
		}
	else {local usedays 0 }

	capture label drop `evnt1'	

	*display `" one event var: "' `"`singleevent'"'
	*display `"one censor var: "' `"`singlecensor'"'
	*display `"         nsave: "' `"`nsave'"'
	*display `"           seq: "' `"`sqevents'"'
	*display `"           seq: "' `"`sequenced_events'"'
	*display `"        evnt_n: "' `"`evnt_n'"'
	*display `"     useorigin: "' `"`useorigin'"'
	*display `"       usedays: "' `"`usedays'"'
	*display `"          add1: "' `"`add1'"'

	tempvar effective_event
	tempvar effective_censor
	local evntlst_comma=subinstr(`"`evntlst'"',`" "',",",.)
	local censlst_comma=subinstr(`"`censlst'"',`" "',",",.)


	if `singleevent' == 1 {
		qui gen `effective_event'=`evntlst'
	}
	else {
		qui gen `effective_event'=min(`evntlst_comma')
	}

	if `singlecensor' == 1 {
		qui gen `effective_censor'=`censlst'
	}
	else {
		qui gen `effective_censor'=min(`censlst_comma')
	}

tempvar firstdate
qui gen long `firstdate'=min(`effective_event' , `effective_censor')
qui gen long `date1'=`firstdate'

qui gen byte `evnt1'=1 if `firstdate'==`effective_event' & `effective_censor'==`effective_event'
qui replace `evnt1'=1 if `firstdate'==`effective_event' & `effective_censor' > `effective_event'
qui replace `evnt1'=0 if `firstdate'==`effective_censor' & `effective_censor' < `effective_event'
if `sqevents' == 1 {
	local i=1
	foreach var of local evntlst {
		*display `"`var'"'
		tempvar ev`i'
		qui gen long `ev`i'' =`var'
		label define `evnt1' `i' `var' ,modify
		local i = `i'+1
	}
	local i = 1
	local j = `evnt_n'-(`i'-1)
	while `j'>0 {
		qui replace `evnt1'=`j' if `evnt1'>0 & `date1'==`ev`j''
		local i=`i'+1
		local j=`evnt_n'-(`i'-1)
	}
}
else {
	label define `evnt1' 1 "event"
}

if `usedays'==0 { 
format `date1' %d
label val `evnt1' `evnt1'
label define `evnt1' 0 censored ,modify
label var `date1' `"event date: `evntlst'"'
label var `evnt1' `"censor ind: `censlst'"'
}
else {
	if `useorigin'==0 {qui replace `date1'=(`date1'-0)+`add1'}
	else {qui replace `date1'=(`date1'-`org')+`add1'}
	label val `evnt1' `evnt1'
	label define `evnt1' 0 censored ,modify
	label var `date1' `"days_`org'+`add1': `evntlst'"'
	label var `evnt1' `"censor ind: `censlst'"'
}

qui replace `evnt1'=. if `firstdate'==. 
qui replace `evnt1'=. if `touse'==0
qui replace `date1'=. if `touse'==0

end
*========
