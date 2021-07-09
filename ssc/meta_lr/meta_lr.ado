
*! version 1.0.0 16Apr2004  AS

program define meta_lr

version 8.2
set more off

syntax varlist(min=4) [if] [in] [, STratify combine WEighting EForm Fix ylab id(string) BLPattern(passthru) BLColor(passthru) /*
*/ Symbol(passthru) msize(passthru) mcolor(passthru) XSCale(passthru) YSCale(passthru) xline(passthru) XLABel(passthru) /*
*/ YTItle(passthru) XTItle(passthru) SCHeme(passthru)]
qui{
preserve
marksample touse, novarlist
keep if `touse' 
}
global fix  `fix'
global eform  `eform'

tokenize `varlist'
global llrpos `1'
global llrposse `2'
global llrneg `3'
global llrnegse `4'
macro shift 4
global varlist2 `*'

capture assert $llrposse > 0
	if _rc ~=0{
	di in re "standard error must not be negative"
	exit 198
	}
	
capture assert $llrnegse > 0
	if _rc ~=0{
	di in re "standard error must not be negative"
	exit 198
	}

**** Non-stratified analysis

if "`stratify'" == ""{
	
	if "$varlist2" ~=""{
	di in re "stratified variable is not allowed, if option stratify is not given"
	exit 198
	}

	if "`ylab'" ~=""{
	di in re "option ylab is only for stratified analysis"
	exit 198
	}
	
    qui{
    	meta $llrpos $llrposse, `eform'
	local fixpos = $S_1
	local fixposlo = $S_3
	local fixposhi = $S_4
	local ranpos = $S_7
	local ranposlo = $S_9
	local ranposhi = $S_0

	meta $llrneg $llrnegse, `eform'
	local fixneg = $S_1
	local fixneglo = $S_3
	local fixneghi = $S_4
	local ranneg = $S_7
	local ranneglo = $S_9
	local ranneghi = $S_0

	tempname weightpos weightneg obs llrposlo llrposhi llrneglo llrneghi
	gen `obs' = _n
	gen `weightpos' = 1/($llrposse*$llrposse)
	gen `weightneg' = 1/($llrnegse*$llrnegse)
	gen `llrposlo' = $llrpos-1.96*$llrposse
	gen `llrposhi' = $llrpos+1.96*$llrposse

	gen `llrneglo' = $llrneg-1.96*$llrnegse
	gen `llrneghi' = $llrneg+1.96*$llrnegse
	if "`eform'" ~= ""{
	
		replace $llrpos = exp($llrpos)
		replace `llrposlo' = exp(`llrposlo')
		replace `llrposhi' = exp(`llrposhi')
		replace $llrneg = exp($llrneg)
		replace `llrneglo' = exp(`llrneglo')
		replace `llrneghi' = exp(`llrneghi')
	}
	
	count
	local max = r(N)
	local i = 1
	local j = 1
	label value `obs' obs
	while `i' <= `max'{
		local value = `"`value' `j'"'
		local a`j' = `id'[`i']
		label define obs `j' "`a`j''", add
		local i = `i' + 1
		local j = `j' + 1
	}
	}
	if "`fix'" ~= ""{
	
		if "`combine'" == ""{
			if "`id'" == ""{
				if "`weighting'" == ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', hor s(i) `blpattern' `blcolor' || /*
				*/scatter `obs' $llrpos, /*
				*/`symbol' `msize' `mcolor' || rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' /*
				*/|| scatter `obs' $llrneg, `symbol' `msize' `mcolor' legend(off) `xscale' `yscale' `xline' `xlabel'/*
				*/ `ytitle' `xtitle' `scheme'
				}
				
				if "`weighting'" ~= ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', hor s(i) `blpattern' `blcolor' || /*
				*/scatter `obs' $llrpos [aw=`weightpos'], `symbol' `msize' `mcolor' || rcapsym `llrneglo' /*
				*/ `llrneghi' `obs', hor s(i) `blpattern' `blcolor' || scatter `obs' $llrneg [aw= `weightneg'], /*
				*/ `symbol' `msize' `mcolor'  legend(off) `xscale' `yscale' `xline' `xlabel' `ytitle' `xtitle' `scheme'
				}
			}
			if "`id'" ~= ""{
				if "`weighting'" == ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', ylabel(`"`value'"', valuelabel angle(360)) hor s(i) /*
				*/`blpattern' `blcolor' || scatter `obs' $llrpos, `symbol' `msize' `mcolor' || rcapsym `llrneglo' /*
				*/ `llrneghi' `obs', hor s(i) `blpattern' `blcolor' || scatter `obs' $llrneg, `symbol' `msize' `mcolor' /*
				*/ legend(off) `xscale' `yscale' `xline' `xlabel' `ytitle' `xtitle' `scheme'
				}
				
				if "`weighting'" ~= ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', ylabel(`"`value'"', valuelabel angle(360)) hor s(i) /*
				*/ `blpattern' `blcolor' || scatter `obs' $llrpos [aw=`weightpos'], `symbol' `msize' `mcolor' || /*
				*/ rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' || scatter `obs' $llrneg /*
				*/ [aw= `weightneg'], `symbol' `msize' `mcolor'  legend(off) `xscale' `yscale' `xline' `xlabel' /* 
				*/ `ytitle' `xtitle' `scheme'
				}
			}
		}
		
		if "`combine'" ~= ""{
		
			if "`id'" == ""{
				if "`weighting'" == ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', ylabel(-1 "combine", angle(360)) hor s(i) /*
				*/ `blpattern' `blcolor' || scatter `obs' $llrpos, /*
				*/`symbol' `msize' `mcolor' || rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' /*
				*/|| scatter `obs' $llrneg, `symbol' `msize' `mcolor' || scatteri -1 `fixposlo' -0.8 `fixpos', c(l) /*
				*/ s(i) clcolor(black) xline(`fixpos', lpattern(-)) xline(`fixneg', lpattern(-))/*
				*/ || scatteri -1 `fixposlo' -1.2 `fixpos', clcolor(black) c(l) s(i) || scatteri -0.8 `fixpos' -1 /* 
				*/ `fixposhi', clcolor(black) c(l) s(i) || scatteri -1.2 `fixpos' -1 `fixposhi', clcolor(black) c(l) /*
				*/ s(i) || scatteri -1 `fixneglo' -0.8 `fixneg', clcolor(black) c(l) s(i) || scatteri -1 `fixneglo' -1.2 /*
				*/ `fixneg', clcolor(black) c(l) s(i) || scatteri -0.8 `fixneg' -1 `fixneghi', clcolor(black) c(l) s(i) /*
				*/ || scatteri -1.2 `fixneg' -1 `fixneghi', clcolor(black) c(l) s(i)   legend(off) `xscale' `yscale' `xline' /*
				*/ `xlabel' `ytitle' `xtitle' `scheme'
				}
							
				if "`weighting'" ~= ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', ylabel(-1 "combine", angle(360)) hor s(i) /*
				*/ `blpattern' `blcolor' || scatter `obs' $llrpos [aw= `weightpos'], /*
				*/`symbol' `msize' `mcolor' || rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' /*
				*/|| scatter `obs' $llrneg [aw= `weightneg'], `symbol' `msize' `mcolor' || scatteri -1 `fixposlo' -0.8 /*
				*/ `fixpos', clcolor(black) c(l) s(i) xline(`fixpos', lpattern(-)) xline(`fixneg', lpattern(-))/*
				*/ || scatteri -1 `fixposlo' -1.2 `fixpos', clcolor(black) c(l) s(i) || scatteri -0.8 `fixpos' -1 /*
				*/ `fixposhi', clcolor(black) c(l) s(i) || scatteri -1.2 `fixpos' -1 `fixposhi', clcolor(black) c(l) /*
				*/ s(i) || scatteri -1 `fixneglo' -0.8 `fixneg', clcolor(black) c(l) s(i) || scatteri -1 `fixneglo' -1.2 /*
				*/ `fixneg', clcolor(black) c(l) s(i) || scatteri -0.8 `fixneg' -1 `fixneghi', clcolor(black) c(l) s(i) /*
				*/ || scatteri -1.2 `fixneg' -1 `fixneghi', clcolor(black) c(l) s(i)   legend(off) `xscale' `yscale' `xline'/*
				*/ `xlabel' `ytitle' `xtitle' `scheme'
				}
			}
			
			if "`id'" ~= ""{
				if "`weighting'" == ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', ylabel(-1 "combine" `"`value'"', valuelabel angle(360)) hor s(i) /*
				*/ `blpattern' `blcolor' || scatter `obs' $llrpos , /*
				*/`symbol' `msize' `mcolor' || rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' /*
				*/|| scatter `obs' $llrneg, `symbol' `msize' `mcolor' xline(`fixpos', lpattern(-)) xline(`fixneg', lpattern(-))/*
				*/ || scatteri -1 `fixposlo' -0.8 `fixpos', clcolor(black) c(l) s(i)/*
				*/ || scatteri -1 `fixposlo' -1.2 `fixpos', clcolor(black) c(l) s(i) || scatteri -0.8 `fixpos' -1 `fixposhi',/*
				*/ clcolor(black) c(l) s(i) || scatteri -1.2 `fixpos' -1 `fixposhi', clcolor(black) c(l) s(i) || /*
				*/ scatteri -1 `fixneglo' -0.8 `fixneg', clcolor(black) c(l) s(i) || scatteri -1 `fixneglo' -1.2 /*
				*/ `fixneg', clcolor(black) c(l) s(i) || scatteri -0.8 `fixneg' -1 `fixneghi', clcolor(black) c(l) /*
				*/ s(i) || scatteri -1.2 `fixneg' -1 `fixneghi', clcolor(black) c(l) s(i) legend(off) `xscale' /*
				*/ `yscale' `xline' `xlabel' `ytitle' `xtitle' `scheme'
				}
				
				if "`weighting'" ~= ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', ylabel(-1 "combine" `"`value'"', valuelabel angle(360)) /*
				*/ hor s(i) `blpattern' `blcolor' || scatter `obs' $llrpos [aw= `weightpos'], /*
				*/`symbol' `msize' `mcolor' || rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' /*
				*/|| scatter `obs' $llrneg [aw= `weightneg'], `symbol' `msize' `mcolor' xline(`fixpos', lpattern(-))/*
				*/ xline(`fixneg', lpattern(-))|| scatteri -1 `fixposlo' -0.8 `fixpos', clcolor(black) c(l) s(i)/*
				*/ || scatteri -1 `fixposlo' -1.2 `fixpos', clcolor(black) c(l) s(i) || scatteri -0.8 `fixpos' -1 /*
				*/ `fixposhi', clcolor(black) c(l) s(i) || scatteri -1.2 `fixpos' -1 `fixposhi', clcolor(black) /*
				*/ c(l) s(i) || scatteri -1 `fixneglo' -0.8 `fixneg', clcolor(black) c(l) s(i)/*
				*/ || scatteri -1 `fixneglo' -1.2 `fixneg', clcolor(black) c(l) s(i) || scatteri -0.8 `fixneg' -1 /*
				*/ `fixneghi', clcolor(black) c(l) s(i) || scatteri -1.2 `fixneg' -1 `fixneghi', clcolor(black) /*
				*/ c(l) s(i) legend(off) `xscale' `yscale' `xline' `xlabel' `ytitle' `xtitle' `scheme'
				}
			}
		}
	}
	

	if "`fix'" == ""{
	qui{
		if "`eform'" == ""{
		metareg $llrpos, wsse($llrposse) bs(mm)
		local taupos = $S_2
		metareg $llrneg, wsse($llrnegse) bs(mm)
		local tauneg = $S_2
		replace `weightpos' = 1/(`taupos' + $llrposse*$llrposse)
		replace `weightneg' = 1/(`tauneg' + $llrnegse*$llrnegse)
		}
		
		if "`eform'" ~= ""{
		replace $llrpos = log($llrpos)
		replace $llrneg = log($llrneg)
		metareg $llrpos, wsse($llrposse) bs(mm)
		local taupos = $S_2
		metareg $llrneg, wsse($llrnegse) bs(mm)
		local tauneg = $S_2
		replace `weightpos' = 1/(`taupos' + $llrposse*$llrposse)
		replace `weightneg' = 1/(`tauneg' + $llrnegse*$llrnegse)
		replace $llrpos = exp($llrpos)
		replace $llrneg = exp($llrneg)
		}
	}
	
		if "`combine'" == ""{
			if "`id'" == ""{
				if "`weighting'" == ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', hor s(i) `blpattern' `blcolor' || /*
				*/scatter `obs' $llrpos, /*
				*/`symbol' `msize' `mcolor' || rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' /*
				*/|| scatter `obs' $llrneg, `symbol' `msize' `mcolor' legend(off) `xscale' `yscale' `xline' `xlabel'/*
				*/ `ytitle' `xtitle' `scheme'
				}
				
				if "`weighting'" ~= ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', hor s(i) `blpattern' `blcolor' || /*
				*/scatter `obs' $llrpos [aw=`weightpos'], /*
				*/`symbol' `msize' `mcolor' || rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' /*
				*/|| scatter `obs' $llrneg [aw= `weightneg'], `symbol' `msize' `mcolor' legend(off) `xscale' /*
				*/ `yscale' `xline' `xlabel' `ytitle' `xtitle' `scheme'
				}
			}
			
			if "`id'" ~= ""{
				if "`weighting'" == ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', ylabel(`"`value'"', valuelabel angle(360)) hor s(i) /*
				*/`blpattern' `blcolor' || scatter `obs' $llrpos, /*
				*/`symbol' `msize' `mcolor' || rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' /*
				*/|| scatter `obs' $llrneg, `symbol' `msize' `mcolor' legend(off) `xscale' `yscale' `xline' `xlabel'/*
				*/ `ytitle' `xtitle' `scheme'
				}
				
				if "`weighting'" ~= ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', ylabel(`"`value'"', valuelabel angle(360)) hor s(i) /*
				*/ `blpattern' `blcolor' || scatter `obs' $llrpos [aw=`weightpos'], /*
				*/`symbol' `msize' `mcolor' || rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' /*
				*/|| scatter `obs' $llrneg [aw= `weightneg'], `symbol' `msize' `mcolor'  legend(off) `xscale' /*
				*/ `yscale' `xline' `xlabel' `ytitle' `xtitle' `scheme'
				}
			}
		}
		
		if "`combine'" ~= ""{
		
			if "`id'" == ""{
				if "`weighting'" == ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', ylabel(-1 "combine", angle(360)) hor s(i) /*
				*/ `blpattern' `blcolor' || scatter `obs' $llrpos, /*
				*/`symbol' `msize' `mcolor' || rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' /*
				*/|| scatter `obs' $llrneg, `symbol' `msize' `mcolor' || scatteri -1 `ranposlo' -0.8 `ranpos', /*
				*/ clcolor(black) c(l) s(i) xline(`ranpos', lpattern(-)) xline(`ranneg', lpattern(-))/*
				*/ || scatteri -1 `ranposlo' -1.2 `ranpos', clcolor(black) c(l) s(i) || scatteri -0.8 `ranpos' -1 /*
				*/ `ranposhi', clcolor(black) c(l) s(i) || scatteri -1.2 `ranpos' -1 `ranposhi', clcolor(black) /*
				*/ c(l) s(i) || scatteri -1 `ranneglo' -0.8 `ranneg', clcolor(black) c(l) s(i)/*
				*/ || scatteri -1 `ranneglo' -1.2 `ranneg', clcolor(black) c(l) s(i) || scatteri -0.8 `ranneg' -1 /*
				*/ `ranneghi', clcolor(black) c(l) s(i) || scatteri -1.2 `ranneg' -1 `ranneghi', clcolor(black) /*
				*/ c(l) s(i) legend(off) `xscale' `yscale' `xline' `xlabel' `ytitle' `xtitle' `scheme'
				}
				
				if "`weighting'" ~= ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', ylabel(-1 "combine", angle(360)) hor s(i) /*
				*/ `blpattern' `blcolor' || scatter `obs' $llrpos [aw= `weightpos'], /*
				*/`symbol' `msize' `mcolor' || rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' /*
				*/|| scatter `obs' $llrneg [aw= `weightneg'], `symbol' `msize' `mcolor' || scatteri -1 `ranposlo' /*
				*/ -0.8 `ranpos', clcolor(black) c(l) s(i) xline(`ranpos', lpattern(-)) xline(`ranneg', lpattern(-))/*
				*/ || scatteri -1 `ranposlo' -1.2 `ranpos', clcolor(black) c(l) s(i) || scatteri -0.8 `ranpos' -1 /*
				*/ `ranposhi', clcolor(black) c(l) s(i) || scatteri -1.2 `ranpos' -1 `ranposhi', clcolor(black) /*
				*/ c(l) s(i) || scatteri -1 `ranneglo' -0.8 `ranneg', clcolor(black) c(l) s(i)/*
				*/ || scatteri -1 `ranneglo' -1.2 `ranneg', clcolor(black) c(l) s(i) || scatteri -0.8 `ranneg' -1 /*
				*/ `ranneghi', clcolor(black) c(l) s(i) || scatteri -1.2 `ranneg' -1 `ranneghi', clcolor(black) /*
				*/ c(l) s(i) legend(off) `xscale' `yscale' `xline' `xlabel' `ytitle' `xtitle' `scheme'
				}
			}
			
			if "`id'" ~= ""{
				if "`weighting'" == ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs' ,ylabel(-1 "combine" `"`value'"', valuelabel angle(360)) hor s(i) /*
				*/ `blpattern' `blcolor' || scatter `obs' $llrpos , /*
				*/`symbol' `msize' `mcolor' || rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' /*
				*/|| scatter `obs' $llrneg, `symbol' `msize' `mcolor' xline(`ranpos', lpattern(-)) xline(`ranneg', /*
				*/ lpattern(-))|| scatteri -1 `ranposlo' -0.8 `ranpos', clcolor(black) c(l) s(i)/*
				*/ || scatteri -1 `ranposlo' -1.2 `ranpos', clcolor(black) c(l) s(i) || scatteri -0.8 `ranpos' -1 /*
				*/ `ranposhi', clcolor(black) c(l) s(i) || scatteri -1.2 `ranpos' -1 `ranposhi', clcolor(black) /*
				*/ c(l) s(i) || scatteri -1 `ranneglo' -0.8 `ranneg', clcolor(black) c(l) s(i)/*
				*/ || scatteri -1 `ranneglo' -1.2 `ranneg', clcolor(black) c(l) s(i) || scatteri -0.8 `ranneg' -1 /*
				*/ `ranneghi', clcolor(black) c(l) s(i) || scatteri -1.2 `ranneg' -1 `ranneghi', clcolor(black) /*
				*/ c(l) s(i) legend(off) `xscale' `yscale' `xline' `xlabel' `ytitle' `xtitle' `scheme'
				}
				
				if "`weighting'" ~= ""{
				twoway rcapsym `llrposlo' `llrposhi' `obs', ylabel(-1 "combine" `"`value'"', valuelabel angle(360)) /*
				*/ hor s(i) `blpattern' `blcolor' || scatter `obs' $llrpos [aw= `weightpos'], /*
				*/`symbol' `msize' `mcolor' || rcapsym `llrneglo' `llrneghi' `obs', hor s(i) `blpattern' `blcolor' /*
				*/|| scatter `obs' $llrneg [aw= `weightneg'], `symbol' `msize' `mcolor' || scatteri -1 `ranposlo' /*
				*/ -0.8 `ranpos', clcolor(black) c(l) s(i) || scatteri -1 `ranposlo' -1.2 `ranpos', clcolor(black) /*
				*/ c(l) s(i) xline(`ranpos', lpattern(-)) xline(`ranneg', lpattern(-))|| scatteri -0.8 `ranpos' -1 /*
				*/ `ranposhi', clcolor(black) c(l) s(i) || scatteri -1.2 `ranpos' -1 `ranposhi', clcolor(black) /*
				*/ c(l) s(i) || scatteri -1 `ranneglo' -0.8 `ranneg', clcolor(black) c(l) s(i) || scatteri -1 /*
				*/ `ranneglo' -1.2 `ranneg', clcolor(black) c(l) s(i) || scatteri -0.8 `ranneg' -1 `ranneghi', /*
				*/ clcolor(black) c(l) s(i) || scatteri -1.2 `ranneg' -1 `ranneghi', clcolor(black) c(l) s(i) /*
				*/ legend(off) `xscale' `yscale' `xline' `xlabel' `ytitle' `xtitle' `scheme'
				}
			}
		}
	}
}


if "`stratify'" ~= ""{

	if "`combine'" ~=""{
	di in re "option combine is only for non-stratified analysis"
	exit 198
	}

	if "`weighting'" ~=""{
	di in re "option weighting is only for non-stratified analysis"
	exit 198
	}

	if "`id'" ~=""{
	di in re "option id is only for non-stratified analysis"
	exit 198
	}

qui{
saveoutcome
}

	if "`ylab'" == ""{
		twoway rcapsym poslo poshi obs, hor s(i) `blpattern' `blcolor' || scatter obs pos, `symbol' `msize' `mcolor' ||/*
		*/ rcapsym neglo neghi obs, hor s(i) `blpattern' `blcolor' || scatter obs neg, `symbol' `msize' `mcolor' legend(off)/*
		*/ `xscale' `yscale' `xline' `xlabel' `ytitle' `xtitle' `scheme'
	}
	
	if "`ylab'" ~= ""{
		qui{
		local i = 1
		local j = 1
		count 
		local max = r(N)
		sort obs
		label value obs obs
		while `i' <= `max'{
			local a`j' = variable1[`i']
			local b`j' = obs[`i']
			local value = `"`value' `b`j''"'
			label define obs `b`j'' `"`a`j''"', add
			local i = `i' + 1
			local j = `j' + 1
		}
		}
		
		twoway rcapsym poslo poshi obs, ylabel(`"`value'"', valuelabel angle(360)) hor s(i) `blpattern' `blcolor' || /*
		*/ scatter obs pos, `symbol' `msize' `mcolor' ||/*
		*/ rcapsym neglo neghi obs, hor s(i) `blpattern' `blcolor' || scatter obs neg, `symbol' `msize' `mcolor' legend(off)/*
		*/ `xscale' `yscale' `xline' `xlabel' `ytitle' `xtitle' `scheme'
	}
}

macro drop llrpos llrposse llrneg llrnegse numvar varlist2

end



capture program drop saveoutcome
program define saveoutcome, rclass
tokenize $varlist2
local i = 1
	while "``i''"~=""{
		global numvar = `i'
		local i = `i' + 1
		}
		
if "$fix" ~= ""{

	tempname outcome
	tempfile strata
	postfile `outcome' poslo pos poshi neglo neg neghi var using `strata', replace
	local j = 1
	foreach var in $varlist2{
		tempname `var'_group
		egen ``var'_group' = group(`var')
		tab ``var'_group'
		global `var'_group = r(r)
		dis $`var'_group
		
		local i = 1
			while `i' <= $`var'_group{

			meta $llrpos $llrposse if ``var'_group' == `i', $eform
			scalar poslo = $S_3
			scalar pos = $S_1
			scalar poshi = $S_4

			meta $llrneg $llrnegse if ``var'_group' == `i', $eform
			scalar neglo = $S_3
			scalar neg = $S_1
			scalar neghi = $S_4

			post `outcome' (poslo) (pos) (poshi) (neglo) (neg) (neghi) (`j')
			local i = `i' + 1
			}
		local j = `j' + 1
	}
	postclose `outcome' 
}

if "$fix" == ""{

	tempname outcome
	tempfile strata
	local j = 1
	postfile `outcome' poslo pos poshi neglo neg neghi var using `strata', replace
	foreach var in $varlist2{
		tempname `var'_group
		egen ``var'_group' = group(`var')
		tab ``var'_group'
		global `var'_group = r(r)
		dis $`var'_group
		local i = 1
			while `i' <= $`var'_group{

			meta $llrpos $llrposse if ``var'_group' == `i', $eform
			scalar poslo = $S_9
			scalar pos = $S_7
			scalar poshi = $S_0

			meta $llrneg $llrnegse if ``var'_group' == `i', $eform
			scalar neglo = $S_9
			scalar neg = $S_7
			scalar neghi = $S_0
	
			post `outcome' (poslo) (pos) (poshi) (neglo) (neg) (neghi) (`j')
			local i = `i' + 1
			}
		 local j = `j' + 1
	}
	postclose `outcome'
}

	use `strata', clear
	gen obs = _n
	local h = 1
	local i = 0		
	count
	local max = r(N)
	while `h' <= $numvar{
		replace obs = obs + 1 if _n > `i' + $``h''_group
		local i = `i' + $``h''_group
		local h = `h' + 1
	}
		
	gen variable = ""
	local i = 1
		foreach var in $varlist2{
		replace variable = "`var'" if var == `i'
		local i = `i' + 1
		}
	gen variable1 = ""
	sort variable obs
	by variable: gen num = _n
	local i = 1
	while `i' <= `max'{
	local a_`i' = variable[`i']
	local b_`i' = num[`i']
	local c_`i' = `"`a_`i''_`b_`i''"'
	replace variable1 = "`c_`i''" if _n == `i'
	local i = `i' + 1
	}
	
	save, replace
end






