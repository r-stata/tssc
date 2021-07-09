// program runs old graph command in tandem
// should be able to use other Stata 10 graph options in `options' once removed
// allow labelling of data points? Can extra plots be added?

*! version 1.22 Sep2003
*! version 2.01 Jul2008
*Can add lines corresponding to RR, OR and RD measures. Allows the analyst to see the 
*line fitted to the points (p1,p0)
*Also has logit option added

*2008 update by Ross Harris

program define labbe
version 8
syntax varlist(min=4 max=4) [if] [in] /*
*/ [, RR(string) RRN(string) RD(string) OR(string) NULL PERCent noWT XLOg YLOg /*
*/ SAving(string) YLAbel(string) XLAbel(string) YSCale(string) XSCale(string) LOGIT NOLEGend /*
*/ id(varname) CLOCKvar(varname) gap(real 1) textsize(real 1) symbol(string) wgt(varname) * ] 

local lines = 0
local cmd_legend = ""

preserve
if "`if'`in'"!="" {
	qui keep `if' `in'
}
parse "`varlist'", parse(" ")
tempvar r1 r2 N /* id yrange xrange hsqrwt */
if ~( `1'>=0 & `2'>=0 & `3'>=0 & `4'>=0 ) {
	di in re "Negative cell counts encountered"
	exit 198
}
qui gen `r1'=`1'/(`1'+`2') 
qui gen `r2'=`3'/(`3'+`4') 
cap assert ((`r1'>=0 & `r1'<=1) | `r1'==.) & ((`r2'>=0 & `r2'<=1 ) | `r2'==. )
if _rc!=0 {
	di in re "Data incorrectly specified"
	exit 198
}
qui gen `N' =`1'+`2'+`3'+`4'
if "`wt'"=="" {
	if "`wgt'" != ""{
		local weight "[weight=`wgt']"
	}
	else{
		local weight "[weight=`N']"
	}
}


*display logit scale if needed
if "`logit'"!="" {
	cap {
		assert (`r1'>0) & (`r2'>0)
		assert (`r1'<1) & (`r2'<1)
	}
	if _rc!=0 {
		di in re "Non-finite values encountered"
		exit
	}
	qui replace `r1'=log(`r1'/(1-`r1'))
	qui replace `r2'=log(`r2'/(1-`r2'))
	local subtitl ", logit scale"
}

label var `r1' "Event rate group 1`subtitl'" 
label var `r2' "Event rate group 2`subtitl'"
if strpos("`options'","xtitle(") == 0 & strpos("`options'","ytitle(") == 0{
	local ytitle "Event rate group 1`subtitl'"
	local xtitle "Event rate group 2`subtitl'" 
}

if "`percent'"!="" {
	if "`logit'"!="" {
		di  in re "percent option not valid with logit"
		exit 
	}
	qui replace `r1'=100*`r1'
	qui replace `r2'=100*`r2'
	local scale=100
 }
 else { 
	local scale=1 
}

if ("`xlog'`ylog'"!="") {
	if ("`logit'"!="")  {
		di in re "Cannot use logit and xlog or ylog"
		exit
	}
	if "`rr'`or'`rd'`rrn'"!="" {
		di in re "Cannot use rr(), or(), rd() or rrn() with xlog or ylog"
		exit
	}
}

if "`xlabel'`ylabel'`yscale'`xscale'"=="" { 
	local zero=0
	if "`percent'"!="" {
		if "`xlog'`ylog'"!="" {
			local zero=1
		}
		local ylabel "ylabel(`zero',25,50,75,100)"
		local xlabel "xlabel(`zero',25,50,75,100)"
	}
	if "`percent'"=="" & "`logit'"=="" {
		if "`xlog'`ylog'"!="" {
			local zero=0.01
		}
		local ylabel "ylabel(`zero',0.25,0.5,0.75,1)"
		local xlabel "xlabel(`zero',0.25,0.5,0.75,1)"
	} 
	if "`percent'"=="" & "`logit'"!="" {
*make own labels if on logit scale
		qui sum `r1'
		local r1min=r(min)
		local r1max=r(max)
		qui sum `r2'
		local r2min=r(min)
		local r2max=r(max)
		local lo=min(`r1min',`r2min')
		local hi=max(`r1max',`r2max')
		local ylabel "ylabel(`lo',`hi')"
		local xlabel "xlabel(`lo',`hi')"
	}
}
 else {
	if "`ylabel'"!="" {
		local ylabel "ylabel(`ylabel')"
	}
	if "`xlabel'"!="" {
		local xlabel "xlabel(`xlabel')"
	}
	if "`yscale'"!="" {
		local yscale "yscale(range(`yscale'))"
	}
	if "`xscale'"!="" {
		local xscale "xscale(range(`xscale'))"
	}
}

if "`saving'"!="" {
	local saving "saving(`saving')"
}
*graph `r1' `r2' `weight'  , `options' `xlog' `ylog' `xlabel' `ylabel' `xscale' `yscale'
*gph open, `saving'
*graph
local ay=r(ay)
local by=r(by)
local ax=r(ax)
local bx=r(bx)
local ymax=r(ymax)
local ymin=r(ymin)
local xmax=r(xmax)
local xmin=r(xmin)
local Grmax=min(`ymax', `xmax')
local Grmin=max(`ymin', `xmin')

local xvals = subinstr("`xlabel'","xlabel(","",.)
local yvals = subinstr("`ylabel'","ylabel(","",.)
local xvals = subinstr("`xvals'",")","",.)
local yvals = subinstr("`yvals'",")","",.)
local xvals2 = subinstr("`xscale'","xscale(range(","",.)
local yvals2 = subinstr("`yscale'","yscale(range(","",.)
local xvals2 = subinstr("`xvals2'","))","",.)
local yvals2 = subinstr("`yvals2'","))","",.)

// need to find graph widths etc. manually
qui summ `r1'
local ymin = r(min)
local ymax = r(max)
if "`yvals'" != ""{
	local ymin = min(`ymin',`yvals')
	local ymax = max(`ymax',`yvals')
}
if "`yvals2'" != ""{
	local ymin = min(`ymin',`yvals2')
	local ymax = max(`ymax',`yvals2')
}
qui summ `r2'
local xmin = r(min)
local xmax = r(max)
if "`xvals'" != ""{
	local xmin = min(`xmin',`xvals')
	local xmax = max(`xmax',`xvals')
}
if "`xvals2'" != ""{
	local xmin = min(`xmin',`xvals2')
	local xmax = max(`xmax',`xvals2')
}
local aspect = (`ymax'-`ymin')/(`xmax'-`xmin')

*trap errors :RR, OR,RRN need to be positive; RD in range -1 to 1
local flag= 0

*gph font 300 200
if "`xlog'"!="" {
	local xlog "log"
}
if "`ylog'"!="" {
	local ylog "log"
}

if "`null'"!="" {
*Draw null line 
	if `ymin' < `xmin'{
		local Axco0 = `xmin'
		local Ayco0 = `xmin'
	}
	else{
		local Axco0 = `ymin'
		local Ayco0 = `ymin'
	}
	if `ymax' > `xmax'{
		local Axco1 = `xmax'
		local Ayco1 = `xmax'
	}
	else{
		local Axco1 = `ymax'
		local Ayco1 = `ymax'
	}
	local cmd_null = "(scatteri `Ayco0' `Axco0' `Ayco1' `Axco1', recast(line) lpattern(dash) lcolor(gs6))"
	local lines = `lines'+1
	local q = char(34)
	local cmd_legend = "`cmd_legend' `lines' "+ `"`q'"' + "Null" + `"`q'"'

}

if "`or'"!="" & "`logit'"=="" { 
	*gph pen 5
	parse "`or'", parse(",")
	while "`1'"!="" {
	   local or_gph=`1'
	   if (`or_gph'<=0 ) {
		local flag=10
	   }
	    else {
		if `ymin' > `scale'*(`or_gph'*`xmin'/(`scale'*1-`xmin'+(`or_gph'*`xmin'))) {
			local yco0=`ymin'
			local xco0=`ymin'/(`scale'*`or_gph'+`ymin'-`ymin'*`or_gph')
		 }
		 else {
			local yco0=`scale'*`or_gph'*`xmin'/(`scale'*1-`xmin'+(`or_gph'*`xmin'))
			local xco0=`xmin'
		}
		local Ayco0=`ay'*`yco0' + `by'
		local Axco0=`ax'*`xco0' + `bx'
		if `xmax' < (`scale'*`ymax'/(`scale'*`or_gph'+`ymax'-(`or_gph'*`ymax'))) {
			local cgermax = `xmax'
		}
		else {
			local cgermax = (`scale'*`ymax'/(`scale'*`or_gph'+`ymax'-(`or_gph'*`ymax')))
		}
		local cger=`xco0'
		while `cger'<=`cgermax' {
			local cger = `cger'+`scale'*0.005
			local tger = `scale'*`or_gph'*`cger'/(`scale'*1-`cger'+(`or_gph'*`cger'))
			local Ayco1= `ay'*`tger'+`by'
			local Axco1= `ax'*`cger'+`bx'
			local sub_cmds "`sub_cmds' `tger' `cger'"
			local Ayco0=`Ayco1'
			local Axco0=`Axco1'
		}
		local cmd_or "(scatteri `sub_cmds', recast(line) lcolor(maroon))"
		local lines = `lines'+1
		local q = char(34)
		local cmd_legend = `"`cmd_legend'"' + " `lines' " + `"`q'"' + "Odds ratio" + `"`q'"'
	   }
	   mac shift 2
	}
}

if "`or'"!="" & "`logit'"!="" { 
	*gph pen 9
	parse "`or'", parse(",")
	while "`1'"!="" {
	   if (`1'<=0 ) {
		local flag=10
	   }
	    else {
		local or_lgph=log(`1')
		if `ymin' > `xmin'+`or_lgph' {
			local yco0=`ymin'
			local xco0=`ymin'-`or_lgph'
		 }
		 else {
			local yco0=`xmin'+`or_lgph'
			local xco0=`xmin'
		}
		if `ymax' >`xmax'+`or_lgph' { 
			local yco1=`xmax'+`or_lgph'
			local xco1=`xmax' 
		 }
		 else { 
			local yco1=`ymax'
			local xco1=`ymax'-`or_lgph'
		}
		local Ayco0=`ay'*`yco0' + `by'
		local Axco0=`ax'*`xco0' + `bx'
		local Ayco1=`ay'*`yco1' + `by'
		local Axco1=`ax'*`xco1' + `bx'
		if ( (`ymax'>`yco0') & (`xmax'>`xco0') & (`ymin'<`yco1') & (`xmin'<`xco1') ) { 
			*gph line `Ayco0' `Axco0' `Ayco1' `Axco1'
			local cmd_or2 = "(scatteri `yco0' `xco0' `yco1' `xco1', recast(line) lcolor(maroon))"
			local lines = `lines'+1
			local q = char(34)
			local cmd_legend = `"`cmd_legend'"' + " `lines' " + `"`q'"' + "Odds ratio" + `"`q'"'
		}
	   }
	   mac shift 2
	}
}

if "`rr'"!="" {
	if "`logit'"!="" {
		di in re "rr option not valid with logit"
		exit
	}
	*gph pen 6
	parse "`rr'", parse(",")
	while "`1'"!="" {
	   local rr_gph=`1'
	   if (`rr_gph'<=0 ) {
		local flag=10 
	   }
	    else {
		if `ymin' > `rr_gph'*`xmin' {
			local yco0=`ymin'
			local xco0=`ymin'/`rr_gph'
		 }
		 else {
			local yco0=`rr_gph'*`xmin'
			local xco0=`xmin'
		}
		if `ymax' > `rr_gph'*`xmax' { 
			local yco1=`rr_gph'*`xmax'
			local xco1=`xmax' 
		 }
		 else { 
			local yco1=`ymax'
			local xco1=`ymax'/`rr_gph'
		}
		local Ayco0=`ay'*`yco0' + `by'
		local Axco0=`ax'*`xco0' + `bx'
		local Ayco1=`ay'*`yco1' + `by'
		local Axco1=`ax'*`xco1' + `bx'
		if ( (`ymax'>`yco0') & (`xmax'>`xco0') & (`ymin'<`yco1') & (`xmin'<`xco1') ) { 
			*gph line `Ayco0' `Axco0' `Ayco1' `Axco1'
			local cmd_rr = "(scatteri `yco0' `xco0' `yco1' `xco1', recast(line) lcolor(dkgreen))"
			local lines = `lines'+1
			local q = char(34)
			local cmd_legend = `"`cmd_legend'"' + " `lines' " + `"`q'"' + "Risk ratio" + `"`q'"'
		}
	   }
	   mac shift 2
	}
}

if "`rrn'"!="" {
	if "`logit'"!="" {
		di in re "rrn option not valid with logit"
		exit
	}
	*gph pen 7
	parse "`rrn'", parse(",")
	while "`1'"!="" {
	   local rrn_gph=`1'
	   if (`rrn_gph'<=0 ) {
		local flag=10
	   }
	    else {
		if `ymin' > (`scale'*(1 -`rrn_gph') + `rrn_gph'*`xmin') {
			local yco0=`ymin'
			local xco0=(`ymin'+`scale'*(`rrn_gph'-1))/`rrn_gph'
		 }
		 else {
			local yco0=`scale'*(1-`rrn_gph') + `rrn_gph'*`xmin' 
			local xco0=`xmin'
		}
		if `ymax' >(`scale'*(1-`rrn_gph') + `rrn_gph'*`xmax' ) { 
			local yco1=`scale'*(1-`rrn_gph') + `rrn_gph'*`xmax' 
			local xco1=`xmax' 
		 }
		 else { 
			local yco1=`ymax'
			local xco1=(`ymax'+`scale'*(`rrn_gph'-1))/`rrn_gph'
		}
		local Ayco0=`ay'*`yco0' + `by'
		local Axco0=`ax'*`xco0' + `bx'
		local Ayco1=`ay'*`yco1' + `by'
		local Axco1=`ax'*`xco1' + `bx'
		if ( (`ymax'>`yco0') & (`xmax'>`xco0') & (`ymin'<`yco1') & (`xmin'<`xco1') ) { 
			*gph line `Ayco0' `Axco0' `Ayco1' `Axco1'
			local cmd_rrn = "(scatteri `yco0' `xco0' `yco1' `xco1', recast(line) lcolor(ltgreen))"
			local lines = `lines'+1
			local q = char(34)
			local cmd_legend = `"`cmd_legend'"' + " `lines' " + `"`q'"' + "Risk ratio (non-event)" + `"`q'"'
		}
	   }
	   mac shift 2
	}
}

if "`rd'"!="" {
	if "`logit'"!="" {
		di in re "rd option not valid with logit"
		exit
	}
	*gph pen 8
	parse "`rd'", parse(",")
	while "`1'"!="" {
	   local rd_gph=`1'
	   if (`rd_gph'<=-1 | `rd_gph'>=1 ) {
		local flag=10
	   }
	    else {
		if `ymin' > `xmin'+`scale'*`rd_gph' {
			local yco0=`ymin'
			local xco0=`ymin'-`scale'*`rd_gph'
		 }
		 else {
			local yco0=`xmin'+`scale'*`rd_gph'
			local xco0=`xmin'
		}
		if `ymax' >`xmax'+`rd_gph' { 
			local yco1=`xmax'+`scale'*`rd_gph'
			local xco1=`xmax' 
		 }
		 else { 
			local yco1=`ymax'
			local xco1=`ymax'-`scale'*`rd_gph'
		}
		local Ayco0=`ay'*`yco0' + `by'
		local Axco0=`ax'*`xco0' + `bx'
		local Ayco1=`ay'*`yco1' + `by'
		local Axco1=`ax'*`xco1' + `bx'
		if ( (`ymax'>`yco0') & (`xmax'>`xco0') & (`ymin'<`yco1') & (`xmin'<`xco1') ) { 
			*gph line `Ayco0' `Axco0' `Ayco1' `Axco1'
			local cmd_rd = "(scatteri `yco0' `xco0' `yco1' `xco1', recast(line) lcolor(olive))"
			local lines = `lines'+1
			local q = char(34)
			local cmd_legend = `"`cmd_legend'"' + " `lines' " + `"`q'"' + "Risk difference" + `"`q'"'
		}
	   }
	   mac shift 2
	}
}

*gph close
if `flag'>1 {
	display _n "Note: some effect sizes are outside valid ranges"
}

// RJH EDIT
// sort out xlabel etc. later

local xlabel = subinstr("`xlabel'", "," ," " ,.)
local ylabel = subinstr("`ylabel'", "," ," " ,.)
local q = char(34)
local l2 = `lines'+1
local cmd_legend = `"`cmd_legend'"' + " `l2' " + `"`q'"' + "Studies" + `"`q'"'
if `"`cmd_legend'"' != ""{
	local cmd_legend = "legend(order(" + `"`cmd_legend'"' + ") span)"
}
if "`nolegend'" != "" | (`lines' == 2 & "`null'" != "") | (`lines'<=1){
	local cmd_legend = "legend(off)"
}

if "`id'" != ""{
	tempvar clockVar
	local lsize = min(`textsize'*30/_N,2)
	qui gen `clockVar' = `r2'<`r1'
	qui replace `clockVar' = 3+`clockVar'*6
	if "`clockvar'" != ""{
		qui replace `clockVar' = `clockvar' if `clockvar' < .		// user defined
	}
	tempvar r11 r22 radians
	qui summ `N'
	qui gen `radians' = (`clockVar'/12)*2*_pi
	if `gap' == 0{
		local gap = 0.0001
	}
	local invgap = 17/`gap'	// smaller means more gap
	qui gen `r11' = `r1' + `N'/r(max)*((`ymax'-`ymin')/`invgap')*cos(`radians')
	qui gen `r22' = `r2' + `N'/r(max)*((`xmax'-`xmin')/`invgap')*sin(`radians')

	local cmd_lab "(scatter `r11' `r22', msymbol(none) mlabel(`id') mlabvposition(`clockVar') mlabcolor(black) mlabsize(`lsize'))"
}

if "`symbol'" == ""{
	local s2 = "circle_hollow"
}
else{
	local s2 = "`symbol'"
}
if "`weight'" == ""{
	qui replace `r22' = `r2'
	qui replace `r11' = `r1'
	if "`symbol'" == ""{
		local s2 = "default"
	}
}

qui twoway `cmd_null' `cmd_or' `cmd_or2' `cmd_rr' `cmd_rrn' `cmd_rd'  ///
  (scatter `r1' `r2' `weight', msymbol(`s2') mcolor(navy)) `cmd_lab' ///
  , `options' `xlog' `ylog' `xlabel' `ylabel' `xscale' `yscale' ///
  `cmd_legend' xtitle("`xtitle'") ytitle("`ytitle'") aspect(`aspect')

restore
end

