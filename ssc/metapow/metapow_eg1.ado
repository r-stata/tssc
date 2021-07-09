program define metapow_eg1
	version 11.2
	preserve
	use http://fmwww.bc.edu/repec/bocode/m/metapow_eg1
	set seed 8226111
	metapow nrxpain rxmeanpain rxsdpain ncomppain compmeanpain compsdpain, ///
					  n(250) nit(1000) type(clinical) measure(nostandard) model(random) pow(-20) inference(lci)

	merge 1:1 _n using "`c(pwd)'\temppow2.dta", nogen noreport
	extfunnel paindiff painse, randomi cpoints(50) null(-20) 				///
		 name(painfunnel20, replace) nometan 									///
		title("PAIN: smallest worthwhile effect = -20", size(medium)) 		///
		xsc(titlegap(medium)) xrange(-100 75) xlabel(-100(25)75)yrange(0 15) scale(1.2) 	///
		legend(order(1 "Unclear if worthwhile" 2 "Clearly not worthwhile" 				///
		3 "Clearly worthwhile" 4 "Smallest worthwhile effect" 	///
		5 "Current pooled estimate" 6 "Current point estimates" 7 "Simulated studies") size(small)) scheme(color)	///
		addplot(scatter indse_es indes, msize(tiny) msym(T) mcol(black)) 
	restore
end
