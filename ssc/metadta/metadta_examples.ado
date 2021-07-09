cap program drop metadta_examples
program metadta_examples
	version 14.0
	`1'
end

program define example_one
	preserve
	di " "
	use "http://fmwww.bc.edu/repec/bocode/t/telomerase.dta", clear
	di  " "
	
	di `". metadta tp tn fp fn, 	///"' 
	di `"{phang}studyid(study) model(random) dp(2) outtable(all)	///{p_end}"'
	di `"{phang}soptions(xtitle("False positive rate") xlabel(0(0.2)1) xscale(range(0 1))	///{p_end}"'
	di `"{pmore}ytitle("Sensitivity") yscale(range(0 1)) ylabel(0(0.2)1, nogrid) ///{p_end}"' 
	di `"{pmore}graphregion(color(white)) plotregion(margin(medium)) xsize(15) ysize(15)	///{p_end}"'
	di `"{pmore}legend(order(1 "Summary" 3 "Observed data" 2  "SROC" 4 "Confidence region" 5 "Prediction region")  ///{p_end}"'
	di `"{pmore2}cols(1) ring(0) bplacement(6))) ///{p_end}"'
	di `"{phang}foptions(graphregion(color(white)) texts(2.5) xlabel(0, 0.5, 1)  ///{p_end}"'
	di `"{pmore}diamopt(color(red)) olineopt(color(red) lpattern(dash))){p_end}"' 
	
	set more off
	#delimit ;
	metadta tp tn fp fn, 
		studyid(study) model(random) dp(2) outtable(all)  
		soptions(xtitle("False positive rate") xlabel(0(0.2)1) xscale(range(0 1))
			ytitle("Sensitivity") yscale(range(0 1)) ylabel(0(0.2)1, nogrid) 
			graphregion(color(white)) plotregion(margin(medium)) xsize(15) ysize(15)
			legend(order(1 "Summary" 3 "Observed data" 2  "SROC" 4 "Confidence region" 5 "Prediction region") 
				cols(1) ring(0) bplacement(6))) 
		foptions(graphregion(color(white)) texts(2.5) xlabel(0, 0.5, 1) 
			diamopt(color(red)) olineopt(color(red) lpattern(dash))) 
	;
	#delimit cr
	restore
end


program define example_two
	preserve
	di _n
	use "http://fmwww.bc.edu/repec/bocode/a/ascus.dta", clear
	di _n

	di `". metadta tp tn fp fn test,  			///"'
	di `"{phang}studyid(studyid) model(random) paired outtable(all)  			///{p_end}"'
	di `"{phang}soptions(xtitle("False positive rate") xlabel(0(0.2)1) xscale(range(0 1)) 			///{p_end}"'
	di `"{pmore}ytitle("Sensitivity") yscale(range(0 1)) ylabel(0(0.2)1, nogrid)  			///{p_end}"'
	di `"{pmore}legend(order(1 "Repeat Cytology" 2 "HC2") ring(0) bplacement(6)) 			///{p_end}"'
	di `"{pmore2}graphregion(color(white)) plotregion(margin(zero)) col(red blue)) 				///{p_end}"'
	di `"{phang}foptions(graphregion(color(white)) outplot(abs) texts(2) xlabel(0, 1, 1) 			///{p_end}"'
	di `"{pmore2}diamopt(color(red)) olineopt(color(red) lpattern(dash)))			{p_end}"'
	
	set more off
	#delimit ;
	metadta tp tn fp fn test, 
		studyid(studyid) model(random) paired outtable(all) 
		soptions(xtitle("False positive rate") xlabel(0(0.2)1) xscale(range(0 1))
			ytitle("Sensitivity") yscale(range(0 1)) ylabel(0(0.2)1, nogrid) 
			legend(order(1 "Repeat Cytology" 2 "HC2") ring(0) bplacement(6))
				graphregion(color(white)) plotregion(margin(zero)) col(red blue)) 	
		foptions(graphregion(color(white)) outplot(abs) texts(2) xlabel(0, 1, 1) 
			diamopt(color(red)) olineopt(color(red) lpattern(dash))) 
	;
	#delimit cr
	restore
end

program define example_three
	preserve
	di _n
	use "http://fmwww.bc.edu/repec/bocode/c/clinself.dta", clear
	di _n
	di `". metadta tp tn fp fn sample Setting,   											///"'
	di `"{phang}studyid(study) interaction(sesp) model(random) 								///{p_end}"'
	di `"{phang}summaryonly  paired outtable(rr) noitable   								///{p_end}"'
	di `"{phang}soptions(xtitle("False positive rate") xlabel(0(0.2)1) xscale(range(0 1))  	///{p_end}"'
	di `"{pmore}ytitle("Sensitivity") yscale(range(0 1)) ylabel(0(0.2)1, nogrid)   			///{p_end}"'
	di `"{pmore}graphregion(color(white)) plotregion(margin(zero)))  						///{p_end}"' 
	di `"{phang}foptions(diamopt(color(red)) olineopt(color(red) lpattern(dash))   			///{p_end}"'
	di `"{pmore}outplot(RR) graphregion(color(white)) texts(2) xlabel(0.7, 1, 1.2))   			{p_end}"'	
	
	set more off
	#delimit ;
	metadta tp tn fp fn sample Setting, 
		studyid(study) interaction(sesp) model(random) 
		summaryonly  paired outtable(rr) noitable 
		soptions(xtitle("False positive rate") xlabel(0(0.2)1) xscale(range(0 1))
			ytitle("Sensitivity") yscale(range(0 1)) ylabel(0(0.2)1, nogrid) 
			graphregion(color(white)) plotregion(margin(zero))) 
		foptions(diamopt(color(red)) olineopt(color(red) lpattern(dash)) 
				outplot(RR) graphregion(color(white)) texts(2) xlabel(0.7, 1, 1.2)) 	
	;
	#delimit cr
	restore
end

program define example_four
	preserve
	di _n
	use "http://fmwww.bc.edu/repec/bocode/c/clinself.dta", clear
	di _n
	di `". metadta tp tn fp fn sample Setting TA,  			///"'
	di `"{phang}studyid(study) interaction(sesp) model(random) paired noitable outtable(rr)   			///{p_end}"'
	di `"{phang}soptions(xtitle("False positive rate") xlabel(0(0.2)1) xscale(range(0 1))  			///{p_end}"'
	di `"{pmore}ytitle("Sensitivity") yscale(range(0 1)) ylabel(0(0.2)1, nogrid)   			///{p_end}"'
	di `"{pmore}graphregion(color(white)) plotregion(margin(zero)))  						///{p_end}"' 
	di `"{phang}foptions(diamopt(color(red)) olineopt(color(red) lpattern(dash))   			///{p_end}"'
	di `"{pmore}outplot(rr) graphregion(color(white)) texts(1.2) xlabel(0.7, 1, 1.3)	///{p_end}"' 
	di `"{pmore}arrowopt(msize(1)))   			{p_end}"'	
	
	set more off
	#delimit ;
	metadta tp tn fp fn sample Setting TA, 
	studyid(study) interaction(sesp) 
		model(random) cov(unstructured)  paired noitable outtable(rr)
		soptions(xtitle("False positive rate") xlabel(0(0.2)1) xscale(range(0 1))
			ytitle("Sensitivity") yscale(range(0 1)) ylabel(0(0.2)1, nogrid) 
			graphregion(color(white)) plotregion(margin(zero))) 
		foptions(outplot(rr) graphregion(color(white)) texts(1.5) xlabel(0.7, 1, 1.3) 
			arrowopt(msize(1)) diamopt(color(red)) olineopt(color(red) lpattern(dash))) 
	;
	#delimit cr
	restore
end




