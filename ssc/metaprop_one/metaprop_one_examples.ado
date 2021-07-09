program metaprop_one_examples
	version 13.1
	`1'
end

program define metaprop_one_example_one
	preserve
	di ""
	use "http://fmwww.bc.edu/repec/bocode/a/arbyn2009jcellmolmedfig1.dta", clear
	di in wh ""
	di ". metaprop_one num denom, random by(tgroup) cimethod(exact) /*"
	di "*/ label(namevar=author, yearvar=year) /*"
	di "*/ xlab(.25,0.5,.75,1)xline(0, lcolor(black)) /*"
	di "*/ subti(Atypical cervical cytology, size(4)) /*"
	di "*/ xtitle(Proportion,size(2)) nowt /*"
	di "*/ olineopt(lcolor(red)lpattern(shortdash))/*"
	di "*/ plotregion(icolor(ltbluishgray)) /*" 
	di "*/ diamopt(lcolor(red)) /*"
	di "*/ pointopt(msymbol(x)msize(0))boxopt(msymbol(S) mcolor(black)) /*" 
	di "*/ astext(70) texts(150)"

	
	set more off
	metaprop_one num denom, random by(tgroup) cimethod(exact) /*
	*/ label(namevar=author, yearvar=year) /*
	*/ xlab(.25,0.5,.75,1)xline(0, lcolor(black)) /*
	*/ subti(Atypical cervical cytology, size(4)) /*
	*/ xtitle(Proportion,size(2)) nowt /*
	*/ olineopt(lcolor(red)lpattern(shortdash)) /*
	*/ plotregion(icolor(ltbluishgray)) /* 
	*/ diamopt(lcolor(red)) /*
	*/ pointopt(msymbol(x)msize(0))boxopt(msymbol(S) mcolor(black)) /* 
	*/ astext(70) texts(150)
	restore
end

program define metaprop_one_example_two
	preserve
	di ""
	use "http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2WNL.dta", clear
	di in wh ""
	di ". metaprop_one p16p total, random ftt cimethod(exact)  /*"
	di "*/ label(namevar=author, yearvar=year) sortby(year author) /*"
	di "*/ xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1)xline(0, lcolor(black)) /*"
	di "*/ ti(Positivity of p16 immunostaining, size(4) color(blue)) /*"
	di "*/ subti(Cytology = WNL, size(4) color(blue))  /*"
	di "*/ xtitle(Proportion,size(4)) nowt nostats /*"
	di "*/ olineopt(lcolor(red)lpattern(shortdash)) /*"
	di "*/ diamopt(lcolor(black)) /*"
	di "*/ pointopt(msymbol(x)msize(0))boxopt(msymbol(S) mcolor(black)) /*" 
	di "*/ astext(70) texts(100)"

	
	set more off
	metaprop_one p16p p16tot, random ftt cimethod(exact)/*
	*/ label(namevar=author, yearvar=year) sortby(year author)/*
	*/ xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1) xline(0, lcolor(black)) /*
	*/ ti(Positivity of p16 immunostaining, size(4) color(blue)) /*
	*/ subti(Cytology = WNL, size(4) color(blue)) /*
	*/ xtitle(Proportion,size(3))  nostats nowt /*
	*/ olineopt(lcolor(red) lpattern(shortdash)) /* 
	*/ diamopt(lcolor(black)) /*
	*/ pointopt(msymbol(x)msize(0)) boxopt(msymbol(S) mcolor(black)) /* 
	*/ astext(70)  texts(100)
	restore
end

program define metaprop_one_example_three
	preserve
	di ""
	use "http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2HSIL.dta", clear
	di in wh ""
	di ". metaprop_one p16p p16tot, random ftt cimethod(exact) /*"
	di "*/ label(namevar=author, yearvar=year) sortby(year author) /*"
	di "*/ xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1)xline(0, lcolor(black)) /*"
	di "*/ ti(Positivity of p16 immunostaining, size(4) color(blue)) /*"
	di "*/ subti(Cytology = HSIL, size(4) color(blue))  /*"
	di "*/ xtitle(Proportion,size(4)) nowt nostats /*"
	di "*/ olineopt(lcolor(red)lpattern(shortdash))/*"
	di "*/ diamopt(lcolor(black)) /*"
	di "*/ pointopt(msymbol(x)msize(0))boxopt(msymbol(S) mcolor(black)) /*" 
	di "*/ astext(70) texts(100)"

	
	set more off
	metaprop_one p16p p16tot, random ftt cimethod(exact) /*
	*/ label(namevar=author, yearvar=year) sortby(year author)/*
	*/ xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1) xline(1, lcolor(black)) /*
	*/ ti(Positivity of p16 immunostaining, size(4) color(blue)) /*
	*/ subti(Cytology = HSIL, size(4) color(blue)) /*
	*/ xtitle(Proportion,size(3)) nowt nostats /*
	*/ olineopt(lcolor(red) lpattern(shortdash))/* 
	*/ diamopt(lcolor(black)) /*
	*/ pointopt(msymbol(x)msize(0)) boxopt(msymbol(S) mcolor(black)) /* 
	*/ astext(70)  texts(100)
	restore
end

program define metaprop_one_example_four
	preserve
	di ""
	use "http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2HSIL.dta", clear
	di in wh ""
	di ". metaprop_one p16p p16tot, random groupid(study) logit /*"
	di "*/ label(namevar=author, yearvar=year) sortby(year author) /*"
	di "*/ xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1)xline(0, lcolor(black)) /*"
	di "*/ ti(Positivity of p16 immunostaining, size(4) color(blue)) /*"
	di "*/ subti(Cytology = HSIL, size(4) color(blue))  /*"
	di "*/ xtitle(Proportion,size(4)) nowt nostats /*"
	di "*/ olineopt(lcolor(red)lpattern(shortdash))/*"
	di "*/ diamopt(lcolor(black)) /*"
	di "*/ pointopt(msymbol(s)msize(2)) /*" 
	di "*/ astext(70) texts(100)"

	
	set more off
	metaprop_one p16p p16tot, random groupid(study) logit /*
	*/ label(namevar=author, yearvar=year) sortby(year author)/*
	*/ xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1) xline(1, lcolor(black)) /*
	*/ ti(Positivity of p16 immunostaining, size(4) color(blue)) /*
	*/ subti(Cytology = HSIL, size(4) color(blue)) /*
	*/ xtitle(Proportion,size(3)) nowt nostats /*
	*/ olineopt(lcolor(red) lpattern(shortdash))/* 
	*/ diamopt(lcolor(black)) /*
	*/ pointopt(msymbol(s)msize(2))  /* 
	*/ astext(70)  texts(100)
	restore
end




