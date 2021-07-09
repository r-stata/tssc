*! hamiltonfilter version 1.0.1
*! Performs the Hamilton Filter 
*! Diallo Ibrahima Amadou
*! All comments are welcome, 13Mar2020



capture program drop hamiltonfilter
program hamiltonfilter, rclass sortpreserve
	version 14.0
	syntax varname(numeric ts) [if] [in], STUB(string) FREQuency(string)
    quietly tsset
    local panelvar "`r(panelvar)'"
    local timevar  "`r(timevar)'"
	marksample touse
    if "`panelvar'" == ""   {
                            quietly {
                                    tsset
									tempvar ydepvarb
									generate double `ydepvarb' = `varlist' if `touse'
									confirm new var `stub'_trend
									confirm new var `stub'_cycle
									if "`frequency'" == "monthly" {
																	regress `ydepvarb' L(24/35).`ydepvarb' if `touse'
																	predict double `stub'_trend if `touse', xb
																	predict double `stub'_cycle if `touse', residuals
																	label var `stub'_trend "`varlist' Trend from the Hamilton Filter, Monthly"
																	label var `stub'_cycle "`varlist' Cycle from the Hamilton Filter, Monthly"
																	return local frequency "monthly"
									}
									else if "`frequency'" == "quarterly" {
																		regress `ydepvarb' L(8/11).`ydepvarb' if `touse'
																		predict double `stub'_trend if `touse', xb
																		predict double `stub'_cycle if `touse', residuals
																		label var `stub'_trend "`varlist' Trend from the Hamilton Filter, Quarterly"
																		label var `stub'_cycle "`varlist' Cycle from the Hamilton Filter, Quarterly"
																		return local frequency "quarterly"
									}
									else if "`frequency'" == "yearly" {
																	regress `ydepvarb' L(2/3).`ydepvarb' if `touse'
																	predict double `stub'_trend if `touse', xb
																	predict double `stub'_cycle if `touse', residuals
																	label var `stub'_trend "`varlist' Trend from the Hamilton Filter, Yearly"
																	label var `stub'_cycle "`varlist' Cycle from the Hamilton Filter, Yearly"
																	return local frequency "yearly"									  
									}									  
									else {
										display as err "Wrong frequency. The values must be: monthly, quarterly or yearly. Thanks."
										exit 198
									}
							return local varlist "`varlist'"
							return local trendvar "`stub'_trend"
							return local cyclevar "`stub'_cycle"
							}
    }
    else {
        quietly {
                tsset
				tempvar ydepvarb
				generate double `ydepvarb' = `varlist' if `touse'
				confirm new var `stub'_trend
				confirm new var `stub'_cycle
				if "`frequency'" == "monthly" {
												generate double `stub'_trend  = . if `touse'
												label var `stub'_trend "`varlist' Trend from the Hamilton Filter, Monthly Panel"
												generate double `stub'_cycle  = . if `touse'
												label var `stub'_cycle "`varlist' Cycle from the Hamilton Filter, Monthly Panel"
												levelsof `panelvar' if `touse', local(sonlevels)
												confirm new var `stub'_trendprov
												confirm new var `stub'_cycleprov
												foreach i of local sonlevels {
																		regress `ydepvarb' L(24/35).`ydepvarb' if `touse' & `panelvar' == `i'
																		predict double `stub'_trendprov if `touse' & `panelvar' == `i', xb
																		predict double `stub'_cycleprov if `touse' & `panelvar' == `i', residuals
																		replace `stub'_trend = `stub'_trendprov if `touse' & `panelvar' == `i'
																		replace `stub'_cycle = `stub'_cycleprov if `touse' & `panelvar' == `i'
																		drop `stub'_trendprov `stub'_cycleprov
												}
												return local frequency "monthly"
				}
				else if "`frequency'" == "quarterly" {
													generate double `stub'_trend  = . if `touse'
													label var `stub'_trend "`varlist' Trend from the Hamilton Filter, Quarterly Panel"
													generate double `stub'_cycle  = . if `touse'
													label var `stub'_cycle "`varlist' Cycle from the Hamilton Filter, Quarterly Panel"
													levelsof `panelvar' if `touse', local(sonlevels)
													confirm new var `stub'_trendprov
													confirm new var `stub'_cycleprov
													foreach i of local sonlevels {
																			regress `ydepvarb' L(8/11).`ydepvarb' if `touse' & `panelvar' == `i'
																			predict double `stub'_trendprov if `touse' & `panelvar' == `i', xb
																			predict double `stub'_cycleprov if `touse' & `panelvar' == `i', residuals
																			replace `stub'_trend = `stub'_trendprov if `touse' & `panelvar' == `i'
																			replace `stub'_cycle = `stub'_cycleprov if `touse' & `panelvar' == `i'
																			drop `stub'_trendprov `stub'_cycleprov
													}
													return local frequency "quarterly"
				}
				else if "`frequency'" == "yearly" {
												generate double `stub'_trend  = . if `touse'
												label var `stub'_trend "`varlist' Trend from the Hamilton Filter, Yearly Panel"
												generate double `stub'_cycle  = . if `touse'
												label var `stub'_cycle "`varlist' Cycle from the Hamilton Filter, Yearly Panel"
												levelsof `panelvar' if `touse', local(sonlevels)
												confirm new var `stub'_trendprov
												confirm new var `stub'_cycleprov
												foreach i of local sonlevels {
																		regress `ydepvarb' L(2/3).`ydepvarb' if `touse' & `panelvar' == `i'
																		predict double `stub'_trendprov if `touse' & `panelvar' == `i', xb
																		predict double `stub'_cycleprov if `touse' & `panelvar' == `i', residuals
																		replace `stub'_trend = `stub'_trendprov if `touse' & `panelvar' == `i'
																		replace `stub'_cycle = `stub'_cycleprov if `touse' & `panelvar' == `i'
																		drop `stub'_trendprov `stub'_cycleprov
												}
												return local frequency "yearly"
			    }									  
				else {
					display as err "Wrong frequency. The values must be: monthly, quarterly or yearly. Thanks."
					exit 198
				}
				return local varlist "`varlist'"
				return local trendvar "`stub'_trend"
				return local cyclevar "`stub'_cycle"
		}

    }
	
	
end


