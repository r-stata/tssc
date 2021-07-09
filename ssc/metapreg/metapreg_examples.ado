program metapreg_examples
	version 14.1
	`1'
end

program define metapreg_example_one_one
	preserve
	use "http://fmwww.bc.edu/repec/bocode/a/arbyn2009jcellmolmedfig1.dta", clear
	di ". metapreg num denom, ///"
	di "	studyid(study) ///"
	di "	iv ///"
	di "	model(random)  ///"
	di "	by(tgroup)  ///"
	di "	cimethod(exact) ///"
	di "	label(namevar=author, yearvar=year) ///"
	di "	xlab(.25,0.5,.75,1) ///"
	di "	xline(0, lcolor(black)) ///"
	di "	subti(Atypical cervical cytology, size(4)) ///"
	di "	xtitle(Proportion,size(2))  ///"
	di "	nowt ///"
	di "	olineopt(lcolor(red)lpattern(shortdash)) ///"
	di "	plotregion(icolor(ltbluishgray)) ///"
	di "	diamopt(lcolor(red)) ///"
	di "	pointopt(msymbol(x)msize(0))  ///"
	di "	boxopt(msymbol(S) mcolor(black)) ///"
	di "	astext(70) ///"
	di "	texts(150)	"

	set more off
	
	cap log close
	cap log using "D:\WIV\Projects\Stata\Metapreg\Logs\doczone.txt", text replace
	set more off
	set trace on
	
	metapreg num denom, ///
		studyid(study) ///
		iv ///
		model(random)  ///
		by(tgroup)  ///
		cimethod(exact) ///
		label(namevar=author, yearvar=year) ///
		xlab(.25,0.5,.75,1) ///
		xline(0, lcolor(black)) ///
		subti(Atypical cervical cytology, size(4)) ///
		xtitle(Proportion,size(2))  ///
		nowt ///
		olineopt(lcolor(red)lpattern(shortdash)) ///
		plotregion(icolor(ltbluishgray)) /// 
		diamopt(lcolor(red)) ///
		pointopt(msymbol(x)msize(0))  ///
		boxopt(msymbol(S) mcolor(black)) ///
		astext(70) ///
		texts(150)		
	restore
end

program define metapreg_example_one_two
	preserve
	use "http://fmwww.bc.edu/repec/bocode/a/arbyn2009jcellmolmedfig1.dta", clear
	di ". bys tgroup, rc0: metapreg num denom, ///"
	di "	studyid(study) ///"
	di "	model(random)  ///"
	di "	cimethod(wilson) ///"
	di "	label(namevar=author, yearvar=year) ///"
	di "	xlab(.25,0.5,.75,1) ///"
	di "	xline(0, lcolor(black)) ///"
	di "	subti(Atypical cervical cytology, size(4)) ///"
	di "	xtitle(Proportion,size(2))  ///"
	di "	olineopt(lcolor(red)lpattern(shortdash)) ///"
	di "	plotregion(icolor(ltbluishgray)) /// "
	di "	diamopt(lcolor(red)) ///"
	di "	astext(50) ///"
	di "	texts(90)"

	set more off
	bys tgroup, rc0: metapreg num denom, ///
		studyid(study) ///
		model(random)  ///
		cimethod(wilson) ///
		label(namevar=author, yearvar=year) ///
		xlab(.25,0.5,.75,1) ///
		xline(0, lcolor(black)) ///
		subti(Atypical cervical cytology, size(4)) ///
		xtitle(Proportion,size(2))  ///
		olineopt(lcolor(red)lpattern(shortdash)) ///
		plotregion(icolor(ltbluishgray)) /// 
		diamopt(lcolor(red)) ///
		astext(50) ///
		texts(90)
	restore
end

program define metapreg_example_one_three
	preserve
	use "http://fmwww.bc.edu/repec/bocode/a/arbyn2009jcellmolmedfig1.dta", clear
	di ". decode tgroup, g(STRtgroup)"
	di ""
	di ". metapreg num denom STRtgroup, ///"
	di "	studyid(study) ///"
	di "	outtable(all) ///"
	di "	model(random)  ///"
	di "	cimethod(exact) ///"
	di "	label(namevar=author, yearvar=year) ///"
	di "	xlab(.25,0.5,.75,1) ///"
	di "	xline(0, lcolor(black)) ///"
	di "	subti(Atypical cervical cytology, size(4)) ///"
	di "	xtitle(Proportion,size(2))  ///"
	di "	olineopt(lcolor(red)lpattern(shortdash)) ///"
	di "	plotregion(icolor(ltbluishgray)) ///" 
	di "	diamopt(lcolor(red)) ///"
	di "	astext(50) ///"
	di "	texts(90)"
	
	set more off
	
	decode tgroup, g(STRtgroup)

	metapreg num denom STRtgroup, ///
		studyid(study) ///
		outtable(all) ///
		model(random)  ///
		cimethod(exact) ///
		label(namevar=author, yearvar=year) ///
		xlab(.25,0.5,.75,1) ///
		subti(Atypical cervical cytology, size(4)) ///
		xtitle(Proportion,size(2))  ///
		olineopt(lcolor(red)lpattern(shortdash)) ///
		plotregion(icolor(ltbluishgray)) /// 
		diamopt(lcolor(red)) ///
		astext(50) ///
		texts(90)
		
	restore
end

program define metapreg_example_two_one
	preserve
	use "http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2WNL.dta", clear
	di ". metapreg p16p p16ptot, ///" 
	di "	studyid(study) ///"
	di "	iv ///"
	di "	model(random) ///" 
	di "	ftt ///" 
	di "	label(namevar=author, yearvar=year) ///" 
	di "	sortby(year author) ///"
	di "	xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1) ///"
	di "	xline(0, lcolor(black)) ///"
	di "	ti(Positivity of p16 immunostaining, size(4) color(blue)) ///"
	di "	subti(Cytology = WNL, size(4) color(blue)) ///"
	di "	xtitle(Proportion,size(4)) ///" 
	di "	nowt ///" 
	di "	nostats ///"
	di "	olineopt(lcolor(red)lpattern(shortdash)) ///"
	di "	diamopt(lcolor(black)) ///"
	di "	pointopt(msymbol(x)msize(0)) ///"
	di "	boxopt(msymbol(S) mcolor(black)) ///"
	di "	astext(70) ///" 
	di "	texts(100)"

	set more off

	metapreg p16p p16tot, ///		
		studyid(study) ///
		model(random)  ///
		iv ///		
		ftt ///
		label(namevar=author, yearvar=year) ///
		sortby(year author) ///
		xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1) ///
		xline(0, lcolor(black)) ///
		ti(Positivity of p16 immunostaining, size(4) color(blue)) ///
		subti(Cytology = WNL, size(4) color(blue)) ///
		xtitle(Proportion,size(3)) ///  
		nostats /// 
		nowt ///
		olineopt(lcolor(red) lpattern(shortdash)) ///
		diamopt(lcolor(black)) ///
		pointopt(msymbol(x)msize(0)) /// 
		boxopt(msymbol(S) mcolor(black)) ///
		astext(70) ///  
		texts(100) 
	restore
end

program define metapreg_example_two_two
	preserve
	use "http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2WNL.dta", clear
	di ". metapreg p16p p16tot, ///"
	di "	model(random) /// "
	di "	studyid(study) ///"
	di "	label(namevar=author, yearvar=year) ///" 
	di "	sortby(year author) ///"
	di "	xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1) /// "
	di "	xline(1, lcolor(black)) ///"
	di "	ti(Positivity of p16 immunostaining, size(4) color(blue)) ///"
	di "	subti(Cytology = HSIL, size(4) color(blue)) ///"
	di "	xtitle(Proportion,size(3)) ///"
	di "	nostats ///"
	di "	olineopt(lcolor(red) lpattern(shortdash)) ///"
	di "	diamopt(lcolor(black)) ///"
	di "	pointopt(msymbol(s)msize(2)) /// "
	di "	astext(70) /// " 
	di "	texts(100)"  
	
	set more off
	
	metapreg p16p p16tot, ///
		model(random) ///
		studyid(study) ///
		label(namevar=author, yearvar=year) ///
		sortby(year author) ///
		xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1) ///
		xline(1, lcolor(black)) ///
		ti(Positivity of p16 immunostaining, size(4) color(blue)) ///
		subti(Cytology = HSIL, size(4) color(blue)) ///
		xtitle(Proportion,size(3)) ///
		nostats ///
		olineopt(lcolor(red) lpattern(shortdash)) ///
		diamopt(lcolor(black)) ///
		pointopt(msymbol(s)msize(2)) ///
		astext(70) ///
		texts(100)
	restore

end

program define metapreg_example_three_one
	preserve
	use "https://github.com/VNyaga/Metapreg/blob/master/bcg.dta?raw=true", clear
	di ". metapreg cases_tb population bcg,  ///" 
	di "	studyid(study) ///"
	di "	model(fixed)  /// "
	di "	second(marginal) ///"
	di "	outtable(raw logodds abs rr)  ///"
	di "	tablestat(raw(Raw_Coeff) logodds(Logit) abs(Proportion) rr(Risk_ratio)) ///"
	di "	paired	///"
	di "	outplot(rr) ///"
	di "	plotstat(Risk ratio) ///"
	di "	plotregion(color(white)) /// "
	di "	graphregion(color(white)) /// "
	di "	xlab(0, 1, 2) ///"
	di "	xtick(0, 1, 2)  /// "
	di "	force ///" 
	di "	xtitle(Relative Ratio,size(2)) /// "
	di "	olineopt(lcolor(black) lpattern(shortdash)) ///" 
	di "	diamopt(lcolor(black)) /// "
	di "	rcols(cases_tb population) /// "
	di "	astext(80) /// "
	di "	texts(150)" 

	set more off
	
	metapreg cases_tb population bcg,  /// 
		studyid(study) ///
		model(fixed)  /// 
		second(marginal) ///
		outtable(raw logodds abs rr)  ///
		tablestat(raw(Raw_Coeff) logodds(Logit) abs(Proportion) rr(Risk_ratio)) ///
		paired	///
		outplot(rr) ///
		plotstat(Risk ratio) ///
		plotregion(color(white)) /// 
		graphregion(color(white)) /// 
		xlab(0, 1, 2) /// 
		xtick(0, 1, 2)  /// 
		force /// 
		xtitle(Relative Ratio,size(2)) /// 
		olineopt(lcolor(black) lpattern(shortdash)) /// 
		diamopt(lcolor(black)) /// 
		rcols(cases_tb population) /// 
		astext(80) /// 
		texts(150) 		
	restore
end

program define metapreg_example_three_two
	preserve
	use "https://github.com/VNyaga/Metapreg/blob/master/bcg.dta?raw=true", clear
	di ". metapreg cases_tb population bcg,  /// "
	di "	studyid(study) ///"
	di "	model(random)  /// "
	di "	second(fixed) ///"
	di "	outtable(lor logodds abs rr)  ///"
	di "	paired	///"
	di "	outplot(rr) ///"
	di "	plotregion(color(white)) /// "
	di "	graphregion(color(white)) /// "
	di "	xlab(0, 1, 2) /// "
	di "	xtick(0, 1, 2)  /// "
	di "	force /// "
	di "	xtitle(Relative Ratio,size(2)) /// "
	di "	plotstat(Rel Ratio) ///"
	di "	olineopt(lcolor(black) lpattern(shortdash)) /// "
	di "	diamopt(lcolor(black)) /// "
	di "	rcols(cases_tb population) /// "
	di "	astext(80) /// "
	di "	texts(150) "
		
	set more off
	metapreg cases_tb population bcg,  /// 
		studyid(study) ///
		model(random)  /// 
		second(fixed) ///
		outtable(lor logodds abs rr)  ///
		paired	///
		outplot(rr) ///
		plotregion(color(white)) /// 
		graphregion(color(white)) /// 
		xlab(0, 1, 2) /// 
		xtick(0, 1, 2)  /// 
		force /// 
		xtitle(Relative Ratio,size(2)) /// 
		plotstat(Rel Ratio) ///
		olineopt(lcolor(black) lpattern(shortdash)) /// 
		diamopt(lcolor(black)) /// 
		rcols(cases_tb population) /// 
		astext(80) /// 
		texts(150) 		
	restore
end

program define metapreg_example_three_three
	preserve
	use "https://github.com/VNyaga/Metapreg/blob/master/bcg.dta?raw=true", clear
	di ". metapreg cases_tb population bcg lat,  ///" 
	di "	studyid(study) ///"
	di "	model(fixed, intpoints(1))  /// "
	di "	sortby(lat) ///"
	di "	second(marginal) ///"
	di "	outtable(all) ///"
	di "	paired  ///"
	di "	outplot(rr) ///"
	di "	interaction ///"
	di "	plotregion(color(white)) /// "
	di "	graphregion(color(white)) /// "
	di "	xlab(0, 1, 2) /// "
	di "	xtick(0, 1, 2)  /// "
	di "	force ///" 
	di "	xtitle(Relative Ratio,size(2)) ///" 
	di "	plotstat(Rel Ratio) ///"
	di "	olineopt(lcolor(black) lpattern(shortdash)) ///" 
	di "	diamopt(lcolor(black)) ///" 
	di "	rcols(cases_tb population) /// "
	di "	astext(80) ///" 
	di "	texts(150)" 
	
	set more off
	metapreg cases_tb population bcg lat,  /// 
		studyid(study) ///
		model(fixed, intpoints(1))  /// 
		sortby(lat) ///
		second(marginal) ///
		outtable(all) ///
		paired  ///
		outplot(rr) ///
		interaction ///
		plotregion(color(white)) /// 
		graphregion(color(white)) /// 
		xlab(0, 1, 2) /// 
		xtick(0, 1, 2)  /// 
		force /// 
		xtitle(Relative Ratio,size(2)) /// 
		plotstat(Rel Ratio) ///
		olineopt(lcolor(black) lpattern(shortdash)) /// 
		diamopt(lcolor(black)) /// 
		rcols(cases_tb population) /// 
		astext(80) /// 
		texts(150) 
	restore
end

program define metapreg_example_four_one
	preserve
	use "https://github.com/VNyaga/Metapreg/blob/master/schizo.dta?raw=true", clear
	di ". metapreg response total arm missingdata,  /// "
	di "	studyid(firstauthor) ///"
	di "	sortby(year) ///"
	di "	model(fixed)  /// "
	di "	second(marginal) ///"
	di "	outtable(all) ///"
	di "	paired  ///"
	di "	outplot(rr) ///"
	di "	interaction ///"
	di "	plotregion(color(white)) /// "
	di "	graphregion(color(white)) /// "
	di "	xlab(0, 5, 15) /// "
	di "	xtick(0, 5, 15)  ///" 
	di "	force /// "
	di "	xtitle(Relative Ratio,size(2)) ///" 
	di "	plotstat(Rel Ratio) ///"
	di "	olineopt(lcolor(black) lpattern(shortdash)) /// "
	di "	diamopt(lcolor(black)) /// "
	di "	lcols(firstauthor year) /// "
	di "	astext(80) /// "
	di "	texts(150) "
			
	set more off
	
	metapreg response total arm missingdata,  /// 
		studyid(firstauthor) ///
		sortby(year) ///
		model(fixed)  /// 
		second(marginal) ///
		outtable(all) ///
		paired  ///
		outplot(rr) ///
		interaction ///
		plotregion(color(white)) /// 
		graphregion(color(white)) /// 
		xlab(0, 5, 15) /// 
		xtick(0, 5, 15)  /// 
		force /// 
		xtitle(Relative Ratio,size(2)) /// 
		plotstat(Rel Ratio) ///
		olineopt(lcolor(black) lpattern(shortdash)) /// 
		diamopt(lcolor(black)) /// 
		lcols(firstauthor year) /// 
		astext(80) /// 
		texts(150) 
		
	restore
end

program define metapreg_example_four_two
	preserve
	use "https://github.com/VNyaga/Metapreg/blob/master/schizo.dta?raw=true", clear
	di ". metapreg response total arm missingdata,  /// "
	di "	studyid(firstauthor) ///"
	di "	sortby(missingdata arm year) ///"
	di "	model(fixed)  /// "
	di "	second(marginal) ///"
	di "	outtable(all) ///"
	di "	paired  ///"
	di "	outplot(abs) ///"
	di "	interaction ///"
	di "	plotregion(color(white)) /// "
	di "	graphregion(color(white)) /// "
	di "	xlab(0, 0.5, 1) /// "
	di "	xtick(0, 0.5, 1)  ///" 
	di "	force /// "
	di "	xtitle(Relative Ratio,size(2)) ///" 
	di "	plotstat(Proportion) ///"
	di "	olineopt(lcolor(black) lpattern(shortdash)) /// "
	di "	diamopt(lcolor(black)) /// "
	di "	lcols(firstauthor year) /// "
	di "	astext(80) /// "
	di "	texts(120) "
	
	set more off
	
	metapreg response total arm missingdata,  /// 
		studyid(firstauthor) ///
		sortby(missingdata arm year) ///
		model(fixed)  /// 
		second(marginal) ///
		outtable(all) ///
		paired  ///
		outplot(abs) ///
		interaction ///
		plotregion(color(white)) /// 
		graphregion(color(white)) /// 
		xlab(0, .5, 1) /// 
		xtick(0, 0.5, 1)  /// 
		force /// 
		xtitle(Proportion Response,size(2)) /// 
		plotstat(Proportion) ///
		olineopt(lcolor(black) lpattern(shortdash)) /// 
		diamopt(lcolor(black)) /// 
		lcols(firstauthor year arm missingdata) /// 
		astext(80) /// 
		texts(120) 
		
	restore
end
