program define scheme_scientific_ex
	
	if "`1'" == "1" {
		twoway (line mpg weight if foreign, sort)(line mpg weight if !foreign, sort), ylabel(0(10)50) xlabel(1000(1000)5000) ///
			legend(label(1 "Foreign") label(2 "Domestic")) scheme(scientific)
	}
	if "`1'" == "2" {
		twoway (connected mpg weight if rep78==2,sort)(connected mpg weight if rep78==3,sort) ///
			(connected mpg weight if rep78==4,sort)(connected mpg weight if rep78==5,sort), ///
			ylabel(10(10)50) xlabel(1500(1000)5500) legend(label(1 "rep78=2") label(2 "rep78=3") ///
			label(3 "rep78=4") label(4 "rep78=5")) scheme(scientific)
	}
	if "`1'" == "3" {
		twoway (connected mpg weight if rep78==2,sort)( connected mpg weight if rep78==3,sort), ///
			ylabel(10(10)50) legend(label(1 "rep78=2") label(2 "rep78=3")) ///
			scheme(scientific) xscale(off) name(rep23, replace)

		twoway (connected mpg weight if rep78==4,sort)( connected mpg weight if rep78==5,sort), ///
			ylabel(10(10)50) xlabel(1500(1000)5500) legend(label(1 "rep78=4") label(2 "rep78=5")) ///
			scheme(scientific) name(rep45,replace)

		graph combine rep23 rep45,cols(1) imargin(b=1 t=1) scheme(scientific)
	}
	if "`1'" == "4" {
		webuse drugtr, clear
		stcox age drug
		stcurve, survival at1(drug=1) at2(drug=0) scheme(scientific)
	}
	
end


