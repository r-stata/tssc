* touched NJC 1.1.0 7 January 2010 
*! PAL 1.0.4 February 10 2010 
program sixplot,sortpreserve
/* sixplot for exploratory analysis of an input variable */
	preserve
	version 8    
	syntax varlist(min=1 max=2 numeric) [if] [in]
		tokenize `varlist'
		quietly  { 
		marksample touse
		count if `touse' 
		if r(N) == 0 error 2000 
		local N = r(N) 
		tempname gr1 gr2 gr3 gr4 gr5 gr6
		tempvar seq 
		if "`2'"==""{
		gen long `seq' = _n
		label var `seq' "Observation number" 
			}
			else{
			gen `seq'=`2'
			label var `seq' "`2'"  
			}
		sort `seq'
		if `N' > 300 { 
			local note "note(`N' observations: use batches of 300)" 
		}

		/// scatter plot of varname vs observation number 
		twoway (lfitci `1' `seq', stdf) ///
		(scatter `1' `seq', ms(oh)) if `touse', ///
		yla(, ang(h)) l1title(`1')   title("Sequence plot", size(medsmall)) `note'  ///
		nodraw legend(off) xla(,labels ang(45)) name(`gr1')

		reg `1' `seq' if `touse'
		rvfplot, nodraw name(`gr2') msymbol(oh) title("Residual vs fitted Plot", size(medsmall)) subtitle("Lines at 2*sd and -2*sd",size(medsmall)) yli(`=-2*e(rmse)' `=2*e(rmse)') ylabel(,angle(45)) xlabel(,angle(45))

		/// boxplot of varname
		graph hbox `1' if `touse', title("Boxplot", size(medsmall)) nodraw name(`gr3') yla(,ang(45))
 
		/// difference plot of varname vs observation number 
		tempvar diff 
		gen `diff' = `1' - `1'[_n-1]
		line `diff' `seq' if `touse', title("First difference plot", size(medsmall)) ///
		ms(oh) ytitle(Value - previous value) yla(, ang(h)) xla(,labels ang(45)) nodraw name(`gr4')
 
		/// histogram with 10 bins of varname
		 if c(scheme) == "s1color" | c(scheme) == "s2color" | c(scheme) == "s2color8" {
        histogram `1' if `touse', bin(10) freq fcolor(green) lcolor(black) ///
        gap(2) addlabel yla(, ang(h)) xla(,ang(45)) title("Histogram", size(medsmall)) nodraw name(`gr5')
    }
    else {
        histogram `1' if `touse', bin(10) freq ///
        gap(2) addlabel yla(, ang(h)) xla(,ang(45)) title("Histogram", size(medsmall)) nodraw name(`gr5')
    }


	
/*		histogram `1' if `touse', bin(10) freq fcolor(green) lcolor(black) ///
		gap(2) addlabel yla(, ang(h)) xla(,ang(45)) title("Histogram", size(medsmall)) nodraw name(`gr5')
	*/	

		/// normal quantile plot of varname 
 		qnorm `1' if `touse', ms(oh) yla(, ang(h)) ///
		title("Normal quantile plot", size(medsmall)) nodraw name(`gr6') yla(,ang(45)) xla(,ang(45))
 	} 

	// combined graph 
	graph combine `gr1' `gr2' `gr3' `gr4' `gr5' `gr6', ///
	title("Sixplot for `1'", size(medsmall) justification(center)) ///
	subtitle(`"`if' `in'"', size(medsmall) justification(center)) caption(   data set: `c(filename)',position(6))
	restore
end
 
