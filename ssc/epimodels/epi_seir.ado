program define epi_seir, rclass
	
    version 16.0

	syntax , [beta(real 0.00) gamma(real 0.00) sigma(real 0.00) ///
	          mu(real 0.00) nu(real 0.00) ///
	         susceptible(real 0.00) exposed(real 0.00) ///
			  infected(real 0.00) recovered(real 0.00) ///
			 days(real 30) day0(string) steps(real 1) percent ///
			 nograph colormodel ///
			 newframe(string) pdfreport(string) clear *]

	local modeltitle = "SEIR Model"
	local mcolnames "t S E I R"
	local varlabels "Time Susceptible Exposed Infected Recovered"
	local datefmt "%dCY-N-D"
	local indexi = strpos(strupper(subinstr(`"`mcolnames'"', " ", "", .)),"I")

	if (`"`colormodel'"'!="") local lc `"color(blue orange red green)"'

	local totpop = `susceptible' + `exposed' + `infected' + `recovered'
	epimodels_util check_total_population `totpop'
	epimodels_util check_day0_date `day0'
	epimodels_util check_days `days'
	epimodels_util check_steps `steps'	

	tempname M		 
	mata epimodels_seir("`M'")

	// todo: if {opt nodata} has been specified, do not put data to any dataset
	// todo: if frame name has been specified, put the data into that frame
	
	if (`"`percent'"'=="percent") {
	  tempname Z
	  matrix `Z' = `M'[1..`=rowsof(`M')',2..5] * 100 / `totpop'
	  matrix `M' = `M'[1..`=rowsof(`M')',1] , `Z'
	  local ylabel="% of population"
	  local mcolnames = `"`=strlower("`mcolnames'")'"'
	  local digits=2
	  local tc=""
	}
	else {
	  local ylabel="Population"
	  local digits=0
	  local tc="c"
	  local yf = "ylabel(,format(%20.4gc))"
	}

	matrix colnames `M' = `mcolnames'
		  
	`clear'
	quietly svmat double `M', names(col)
	
	mata epi_applylabels()
	epimodels_util makedatevar t, day0(`"`day0'"') datefmt("`datefmt'")

	return matrix seir=`M'
	
	local ivar `"`:word `indexi' of `mcolnames''"'
	
	epimodels_util ditable t, ///
	    days(`days') day0(`"`day0'"') ///
		modeltitle(`"`modeltitle'"') ///
		varlabels(`"`varlabels'"') ylabel(`"`ylabel'"') ///
        mcolnames(`"`mcolnames'"') ivar(`ivar') ///
		datefmt(`"`datefmt'"') digits(`digits') comma(`tc') `percent'		

	return scalar maxinfect=r(maxinfect)
	return scalar t_maxinfect=r(t_maxinfect)
	return scalar d_maxinfect=r(d_maxinfect)
	return scalar o_maxinfect=r(o_maxinfect)	
	return local model_params="{&beta}=`beta', {&gamma}=`gamma', {&sigma}=`sigma', {&mu}=`mu', {&nu}=`nu'"
	mata st_local("greek", epi_greek("beta = `beta', gamma = `gamma', sigma = `sigma', mu = `mu', nu = `nu'"))
	local greek=subinstr(`"`greek'"'," = ","=",.)	
	return local umodel_params="`greek'"
	
	if (`"`graph'"'!="nograph") {
	
		twoway line `:word 2 of `mcolnames'' `:word 3 of `mcolnames'' ///
					`:word 4 of `mcolnames'' `:word 5 of `mcolnames'' t, ///
		   legend(cols(1) ring(0) pos(2) region(lwidth(none) )) ///
		   xtitle("`:variable label t'") ytitle("`ylabel'") ///
		   title("`modeltitle'") `yf' `lc' xlabel(, grid) `options'

		if (`"`pdfreport'"'!="") {
			tempfile modelimg
			local modelimg `"`modelimg'.png"'
			quietly graph export `"`modelimg'"', as(png)
	    }	   
	}
	
	if (`"`pdfreport'"'!="") {
		capture noisily epimodels_util pdfreport `mcolnames', ///
			modelname("SEIR") modelparams("`greek'") ///
			modelgraph(`"`modelimg'"') save("`pdfreport'")
		local rc=_rc
		
		if (`"`modelimg'"'!="") capture erase `"`modelimg'"'
		error `rc'
	}
end

// END OF FILE