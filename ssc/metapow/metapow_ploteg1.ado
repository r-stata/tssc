program define metapow_ploteg1
	version 11.2
	preserve
	use http://fmwww.bc.edu/repec/bocode/m/metapow_eg1
	set seed 8226111
	metapowplot nrxpain rxmeanpain rxsdpain ncomppain compmeanpain compsdpain, nit(100) type(clinical) measure(nostandard) model(random) pow(-20) inference(lci) start(50) stop(550) step(100) graph(lowess)
	restore
end
