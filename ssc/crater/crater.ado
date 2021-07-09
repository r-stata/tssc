*! version 10.1.1 march 20, 2013
program define crater, rclass
	version 6.0, missing
	syntax varlist(min=2)

	local n : word count `varlist'
	if `n' > 2 { 
		di "too many raters entered"
		exit 102
	}

	parse "`varlist'", parse(" ")
	local r `1'
	local c `2'
	if "`tab'"=="" { 
		local tab "*"
		local skip "noisily di"
	}
	else {	local tab "noisily tab" }
	
	*both obs
	quietly tab `r' `c'
	local nm=`r(N)'
	
	*human only
	quietly tab `r' `c' if `r'!=., missing
	local nh = `r(N)'
	
	*missing computer
	local mc=`nh'-`nm'
	local mp = `mc'/`nh'
	
	*summary table of scores
	
	
	di as text "SUMMARY TABLE OF SCORES"
	di as text "_______________________________________________________________"
	di as text "#human scores     "  %11.0f `nh' 
	di as text "#w/computer score "   %11.0f `nm'
	di as text "# missing         " %11.0f `mc'
	di as text "% missing         " %11.2f `mp'*100 "%"

	
	*
    quietly kap `r' `c' 
	local mprope =   `r(prop_o)' 
	local wmprope= (`mprope'*`nm')/`nh'
	local mpropa=`r(N)'
	quietly correlate `r' `c'
	local acor=`r(rho)'
	
	tempvar temp1
	quietly gen `temp1' = abs(`c'-`r')
	quietly summ `temp1' if `temp1'<=1
	
	local mpropa= `r(N)'/`nm'
	local wmpropa = `r(N)'/`nh'
	
		
	di as text " "
	di as text "SUMMARY TABLE OF AGREEMENT"
	di as text "_______________________________________________________________"
	di as text "Model 		N 	Prop.Exact  Prop.Adj    correlation"
	di as text "Matched     " %11.0f `nm' " " %11.4f `mprope'    " "  %11.4f `mpropa' " " %11.4f `acor'
	di as text "W/Missing   " %11.0f `nh' " " %11.4f `wmprope'  " "  %11.4f `wmpropa'     

	quietly kap `r' `c'
	local uwk=`r(kappa)'       
    local uwkz=`r(z)'           
    local uwkse=`r(se)'        
	
	quietly kap `r' `c', wgt(w)
	local wk=`r(kappa)'       
    local wkz=`r(z)'           
    local wkse=`r(se)'        
		
	quietly kap `r' `c', wgt(w2)
	local qwk=`r(kappa)'       
    local qwkz=`r(z)'           
    local qwkse=`r(se)'  
	
	di as text " "
	
	di as text "SUMMARY TABLE OF KAPPA COEFFICIENTS"
	di as text "_______________________________________________________________"
	di as text "Model 	   	k              z         SE
	di as text "Unweighted     " %11.4f `uwk' " " %11.4f `uwkz' %11.4f `uwkse'
	di as text "Weighted  	   " %11.4f `wk' " " %11.4f `wkz' %11.4f `wkse'
	di as text "Quadratic      " %11.4f `qwk' " " %11.4f `qwkz' %11.4f `qwkse'
	
	quietly sum `r' if `c'!=.
	local evh=`r(mean)'
	local vh=`r(Var)'
	
	quietly summ `c' if `r'!=.
	local evc=`r(mean)'
	local vc = `r(Var)'
	
	local dm=`evc'-`evh'
	
	local smd=(`evc'-`evh')/((`vc'+`vh')/2)
	di as text " "
	di as text "SUMMARY TABLE OF DIFFERENCES (human-computer)"
	di as text "_______________________________________________________________"
	di as text "Mean Difference   " %11.4f `dm' 
	di as text "SMD               " %11.4f `smd' 
	
	
end

	
		
		
		
		
		



