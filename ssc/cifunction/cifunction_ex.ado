program define cifunction_ex
	
	if "`1'" == "1" {
		cifunction 5.736638 2.138812 1.46824 1.35606, se(4.181258 .6520701 .295728 .2748845) eform ///
			fig(xscale(log) xlabel(.3 .5 1 2 5 10 20 50 100) legend(label(1 "35-44") label(2 "45-54") label(3 "55-64") label(4 "65-74") ///
			title("Age Group", size(small))) xtitle("Rate Ratio (Log Scale)")))
	}
	if "`1'" == "2" {
		cifunction 2.222222  2.835165, se(1.319891 1.33843) eform fig(xscale(log) xlabel(.2 .5 1 2 5 10 20) ///
			legend(label(1 "Crude") label(2 "Pooled")) xtitle(Odds Ratio (Log Scale))))
	}
	if "`1'" == "3" {
		cifunction .7 1.2 1.3 3.6, se(.4474236 .2482485 .6337692 1.870876) eform fig(xscale(log) xlabel(.05 .1 .2 .5 1 2 5 10 30) ///
			legend(label(1 "Finland") label(2 "NO/LA") label(3 "Denmark") label(4 "Upstate NY")) xtitle("Relative Ratio (Log Scale)")))
	}
	if "`1'" == "4" {
	cifunction 0.87 0.88, se(.0965065 .0658232) eform fig( xlab(.5(.1)1.3) xtitle("Odds Ratio") legend(label(1 "Eisenberger et al (1998)") ///
			label(2 "Summary of 10 studies") ring(0) position(11))) sav(figdata, replace)
	}
	
end

